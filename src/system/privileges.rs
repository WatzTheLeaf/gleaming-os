//! Starts the programs of the steps as TrustedInstaller, the administrator or the user.
//!
//! The wizard runs as administrator, and borrows the tokens of other processes to act as
//! someone else, as explained in [The Art of Becoming TrustedInstaller]:
//!
//! 1. The debug privilege of administrators opens the token of `winlogon.exe`, which runs as
//!    SYSTEM.
//! 2. Impersonating SYSTEM opens the token of the TrustedInstaller service, started on demand.
//! 3. While impersonating SYSTEM, [`CreateProcessAsUserW`] starts processes with any token.
//!
//! The user's token comes from Windows Explorer, which runs without administrator rights.
//!
//! [The Art of Becoming TrustedInstaller]: https://www.tiraniddo.dev/2017/08/the-art-of-becoming-trustedinstaller.html
//! [`CreateProcessAsUserW`]: https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessasuserw

use std::ffi::c_void;
use std::fs::File;
use std::os::windows::io::{AsRawHandle, FromRawHandle, OwnedHandle};
use std::path::Path;
use std::time::{Duration, Instant};
use std::{io, iter, slice, thread};

use windows::Win32::Foundation::{
    ERROR_NOT_ALL_ASSIGNED, ERROR_SERVICE_ALREADY_RUNNING,
    E_FAIL, GetLastError, HANDLE, HANDLE_FLAGS,
    HANDLE_FLAG_INHERIT, SetHandleInformation,
};
use windows::Win32::Security::{
    AdjustTokenPrivileges, DuplicateTokenEx, LookupPrivilegeValueW, RevertToSelf, SECURITY_ATTRIBUTES,
    SE_ASSIGNPRIMARYTOKEN_NAME, SE_DEBUG_NAME, SE_INCREASE_QUOTA_NAME, SE_PRIVILEGE_ENABLED,
    SE_TCB_NAME, SecurityImpersonation, SetTokenInformation,
    TOKEN_ADJUST_PRIVILEGES, TOKEN_ALL_ACCESS, TOKEN_DUPLICATE, TOKEN_PRIVILEGES, TOKEN_QUERY,
    TOKEN_TYPE, TokenImpersonation, TokenPrimary, TokenSessionId,
};
use windows::Win32::System::Diagnostics::ToolHelp::{
    CreateToolhelp32Snapshot, PROCESSENTRY32W, Process32FirstW, Process32NextW, TH32CS_SNAPPROCESS,
};
use windows::Win32::System::Pipes::CreatePipe;
use windows::Win32::System::RemoteDesktop::ProcessIdToSessionId;
use windows::Win32::System::Services::{
    OpenSCManagerW, OpenServiceW, QueryServiceStatusEx, SC_MANAGER_CONNECT, SC_STATUS_PROCESS_INFO,
    SERVICE_QUERY_STATUS, SERVICE_RUNNING, SERVICE_START, SERVICE_STATUS_PROCESS, SERVICE_STOPPED,
    StartServiceW,
};
use windows::Win32::System::Threading::{
    CREATE_NO_WINDOW, CreateProcessAsUserW, GetCurrentProcess, GetExitCodeProcess, INFINITE,
    OpenProcess, OpenProcessToken, PROCESS_CREATION_FLAGS, PROCESS_INFORMATION,
    PROCESS_QUERY_LIMITED_INFORMATION, STARTF_USESTDHANDLES, STARTUPINFOW, SetThreadToken,
    WaitForSingleObject,
};
use windows::Win32::UI::WindowsAndMessaging::{GetShellWindow, GetWindowThreadProcessId};
use windows::core::{Error, HSTRING, Owned, PCWSTR, PWSTR, w};

use crate::playbook::plan::RunAs;

/// How long Windows is given to restart its shell after Windows Explorer was stopped.
const SHELL_RESTART_TIMEOUT: Duration = Duration::from_secs(10);

/// How long the TrustedInstaller service is given to start.
const SERVICE_START_TIMEOUT: Duration = Duration::from_secs(15);

/// How often a state is checked while waiting for it.
const POLL_INTERVAL: Duration = Duration::from_millis(250);

/// The tokens of each privilege level, acquired once for a run.
pub struct Tokens {
    /// Impersonated to create processes with the other tokens.
    system: Owned<HANDLE>,
    trusted_installer: Owned<HANDLE>,
    admin: Owned<HANDLE>,
    user: Owned<HANDLE>,
}

/// A console program started by [`Tokens::spawn`].
pub struct Child {
    pub process: Process,
    /// The read end of its standard output.
    pub stdout: File,
    /// The read end of its standard error.
    pub stderr: File,
}

/// A started process, whose handle is closed when dropped.
pub struct Process(Owned<HANDLE>);

impl Tokens {
    /// Acquires the tokens, as described in the [module documentation](self).
    ///
    /// # Errors
    ///
    /// Returns an error when a privilege is missing, when the TrustedInstaller service doesn't
    /// start, or when Windows Explorer isn't running.
    pub fn acquire() -> io::Result<Self> {
        let mut own_token = Owned::default();
        unsafe {
            OpenProcessToken(
                GetCurrentProcess(),
                TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
                &mut *own_token,
            )?;
        }
        enable_privileges(*own_token, &[SE_DEBUG_NAME])?;

        let system = duplicate_token(find_process("winlogon.exe")?, TokenImpersonation)?;
        enable_privileges(
            *system,
            &[
                SE_ASSIGNPRIMARYTOKEN_NAME,
                SE_INCREASE_QUOTA_NAME,
                SE_TCB_NAME,
            ],
        )?;

        let trusted_installer = {
            let _system = Impersonation::start(*system)?;
            let token = duplicate_token(start_trusted_installer()?, TokenPrimary)?;
            move_to_current_session(*token)?;
            token
        };

        Ok(Self {
            trusted_installer,
            admin: duplicate_token(std::process::id(), TokenPrimary)?,
            user: duplicate_token(shell_process_id()?, TokenPrimary)?,
            system,
        })
    }

    /// Starts a console program in `directory`, with its standard output and error captured.
    ///
    /// # Errors
    ///
    /// Returns an error when the pipes can't be created or the program can't start.
    pub fn spawn(&self, run_as: RunAs, command_line: &str, directory: &Path) -> io::Result<Child> {
        let (stdout, stdout_write) = pipe()?;
        let (stderr, stderr_write) = pipe()?;
        // Prompts get an empty answer instead of waiting forever
        let stdin = File::open("NUL")?;
        unsafe { SetHandleInformation(raw(&stdin), HANDLE_FLAG_INHERIT.0, HANDLE_FLAG_INHERIT)? };

        let startup = STARTUPINFOW {
            cb: size_of::<STARTUPINFOW>() as u32,
            dwFlags: STARTF_USESTDHANDLES,
            hStdInput: raw(&stdin),
            hStdOutput: *stdout_write,
            hStdError: *stderr_write,
            ..Default::default()
        };
        let process = self.create_process(
            run_as,
            command_line,
            Some(directory),
            &startup,
            true,
            CREATE_NO_WINDOW,
        )?;
        // Only the program keeps the write ends open, so reading ends once it exits
        drop((stdout_write, stderr_write));
        Ok(Child {
            process,
            stdout,
            stderr,
        })
    }

    /// Starts Windows Explorer as the shell, unless Windows restarts it in time.
    ///
    /// Windows restarts its shell by itself once Windows Explorer is stopped, and a second
    /// `explorer.exe` would then open a File Explorer window.
    ///
    /// # Errors
    ///
    /// Returns an error when Windows Explorer can't start.
    pub fn start_shell(&self, run_as: RunAs) -> io::Result<()> {
        let deadline = Instant::now() + SHELL_RESTART_TIMEOUT;
        loop {
            if shell_process_id().is_ok() {
                return Ok(());
            }
            if Instant::now() >= deadline {
                return self.launch(run_as, "explorer.exe");
            }
            thread::sleep(POLL_INTERVAL);
        }
    }

    /// Starts a program without waiting for it.
    fn launch(&self, run_as: RunAs, command_line: &str) -> io::Result<()> {
        let startup = STARTUPINFOW {
            cb: size_of::<STARTUPINFOW>() as u32,
            ..Default::default()
        };
        self.create_process(
            run_as,
            command_line,
            None,
            &startup,
            false,
            PROCESS_CREATION_FLAGS(0),
        )?;
        Ok(())
    }

    /// Creates a process with the token of `run_as`, impersonating SYSTEM for the privileges
    /// this requires.
    fn create_process(
        &self,
        run_as: RunAs,
        command_line: &str,
        directory: Option<&Path>,
        startup: &STARTUPINFOW,
        inherit_handles: bool,
        flags: PROCESS_CREATION_FLAGS,
    ) -> io::Result<Process> {
        let token = match run_as {
            RunAs::TrustedInstaller => &self.trusted_installer,
            RunAs::Admin => &self.admin,
            RunAs::User => &self.user,
        };
        let mut command_line: Vec<u16> = command_line.encode_utf16().chain(iter::once(0)).collect();
        let directory = directory.map(HSTRING::from);
        let mut info = PROCESS_INFORMATION::default();
        let _system = Impersonation::start(*self.system)?;
        unsafe {
            CreateProcessAsUserW(
                Some(**token),
                PCWSTR::null(),
                Some(PWSTR(command_line.as_mut_ptr())),
                None,
                None,
                inherit_handles,
                flags,
                None,
                directory
                    .as_ref()
                    .map_or(PCWSTR::null(), |directory| PCWSTR(directory.as_ptr())),
                startup,
                &mut info,
            )?;
            // Only the process handle is kept
            drop(Owned::new(info.hThread));
            Ok(Process(Owned::new(info.hProcess)))
        }
    }
}

impl Process {
    /// Waits for the process to exit, and returns its exit code.
    ///
    /// # Errors
    ///
    /// Returns an error when the exit code can't be read.
    pub fn wait(&self) -> io::Result<u32> {
        let mut exit_code = 0;
        unsafe {
            WaitForSingleObject(*self.0, INFINITE);
            GetExitCodeProcess(*self.0, &mut exit_code)?;
        }
        Ok(exit_code)
    }
}

/// Impersonates a token on the current thread, until dropped.
struct Impersonation;

impl Impersonation {
    fn start(token: HANDLE) -> io::Result<Self> {
        unsafe { SetThreadToken(None, Some(token))? };
        Ok(Self)
    }
}

impl Drop for Impersonation {
    fn drop(&mut self) {
        let _ = unsafe { RevertToSelf() };
    }
}

/// The handle of a file, which keeps owning it.
fn raw(file: &File) -> HANDLE {
    HANDLE(file.as_raw_handle())
}

/// A pipe whose write end can be inherited by a child process, unlike its read end.
fn pipe() -> io::Result<(File, Owned<HANDLE>)> {
    let inheritable = SECURITY_ATTRIBUTES {
        nLength: size_of::<SECURITY_ATTRIBUTES>() as u32,
        bInheritHandle: true.into(),
        ..Default::default()
    };
    let (mut read, mut write) = (HANDLE::default(), HANDLE::default());
    unsafe {
        CreatePipe(&mut read, &mut write, Some(&inheritable), 0)?;
        let write = Owned::new(write);
        let read = File::from(OwnedHandle::from_raw_handle(read.0));
        SetHandleInformation(raw(&read), HANDLE_FLAG_INHERIT.0, HANDLE_FLAGS(0))?;
        Ok((read, write))
    }
}

/// Enables privileges that the token holds, see [`AdjustTokenPrivileges`].
///
/// [`AdjustTokenPrivileges`]: https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-adjusttokenprivileges
fn enable_privileges(token: HANDLE, names: &[PCWSTR]) -> io::Result<()> {
    for &name in names {
        let mut privileges = TOKEN_PRIVILEGES {
            PrivilegeCount: 1,
            ..Default::default()
        };
        privileges.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
        unsafe {
            LookupPrivilegeValueW(PCWSTR::null(), name, &mut privileges.Privileges[0].Luid)?;
            AdjustTokenPrivileges(token, false, Some(&privileges), 0, None, None)?;
            // The call succeeds even when the token lacks the privilege
            if GetLastError() == ERROR_NOT_ALL_ASSIGNED {
                return Err(Error::from(ERROR_NOT_ALL_ASSIGNED.to_hresult()).into());
            }
        }
    }
    Ok(())
}

/// Duplicates the token of a process, as an impersonation or a primary token.
fn duplicate_token(process_id: u32, token_type: TOKEN_TYPE) -> io::Result<Owned<HANDLE>> {
    unsafe {
        let process = Owned::new(OpenProcess(
            PROCESS_QUERY_LIMITED_INFORMATION,
            false,
            process_id,
        )?);
        let mut token = Owned::default();
        OpenProcessToken(*process, TOKEN_DUPLICATE | TOKEN_QUERY, &mut *token)?;
        let mut duplicate = Owned::default();
        DuplicateTokenEx(
            *token,
            TOKEN_ALL_ACCESS,
            None,
            SecurityImpersonation,
            token_type,
            &mut *duplicate,
        )?;
        Ok(duplicate)
    }
}

/// Moves a token to the session of the wizard.
///
/// A token taken from a service belongs to session 0, whose windows the user doesn't see.
/// Changing it requires the TCB privilege, enabled on SYSTEM's token.
fn move_to_current_session(token: HANDLE) -> io::Result<()> {
    let mut session = 0;
    unsafe {
        ProcessIdToSessionId(std::process::id(), &mut session)?;
        SetTokenInformation(
            token,
            TokenSessionId,
            (&raw const session).cast::<c_void>(),
            size_of::<u32>() as u32,
        )?;
    }
    Ok(())
}

/// The ID of a running process, found by its executable's name.
fn find_process(name: &str) -> io::Result<u32> {
    unsafe {
        let snapshot = Owned::new(CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)?);
        let mut entry = PROCESSENTRY32W {
            dwSize: size_of::<PROCESSENTRY32W>() as u32,
            ..Default::default()
        };
        let mut found = Process32FirstW(*snapshot, &mut entry);
        while found.is_ok() {
            let length = entry
                .szExeFile
                .iter()
                .position(|&c| c == 0)
                .unwrap_or(entry.szExeFile.len());
            if String::from_utf16_lossy(&entry.szExeFile[..length]).eq_ignore_ascii_case(name) {
                return Ok(entry.th32ProcessID);
            }
            found = Process32NextW(*snapshot, &mut entry);
        }
    }
    Err(Error::new(E_FAIL, format!("{name} isn't running")).into())
}

/// Starts the TrustedInstaller service unless it's running, and returns its process ID.
fn start_trusted_installer() -> io::Result<u32> {
    let deadline = Instant::now() + SERVICE_START_TIMEOUT;
    unsafe {
        let manager = Owned::new(OpenSCManagerW(
            PCWSTR::null(),
            PCWSTR::null(),
            SC_MANAGER_CONNECT,
        )?);
        let service = Owned::new(OpenServiceW(
            *manager,
            w!("TrustedInstaller"),
            SERVICE_START | SERVICE_QUERY_STATUS,
        )?);
        while Instant::now() < deadline {
            let mut status = SERVICE_STATUS_PROCESS::default();
            // The status is written as bytes
            let buffer = slice::from_raw_parts_mut(
                (&raw mut status).cast::<u8>(),
                size_of::<SERVICE_STATUS_PROCESS>(),
            );
            QueryServiceStatusEx(*service, SC_STATUS_PROCESS_INFO, Some(buffer), &mut 0)?;
            match status.dwCurrentState {
                SERVICE_RUNNING => return Ok(status.dwProcessId),
                SERVICE_STOPPED => match StartServiceW(*service, None) {
                    Err(error) if error.code() != ERROR_SERVICE_ALREADY_RUNNING.to_hresult() => {
                        return Err(error.into());
                    }
                    _ => {}
                },
                _ => thread::sleep(POLL_INTERVAL),
            }
        }
    }
    Err(Error::new(E_FAIL, "The TrustedInstaller service didn't start").into())
}

/// The ID of Windows Explorer's process, found through the [desktop window] it owns.
///
/// [desktop window]: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getshellwindow
fn shell_process_id() -> io::Result<u32> {
    let mut process_id = 0;
    unsafe { GetWindowThreadProcessId(GetShellWindow(), Some(&mut process_id)) };
    match process_id {
        0 => Err(Error::new(E_FAIL, "Windows Explorer isn't running").into()),
        id => Ok(id),
    }
}
