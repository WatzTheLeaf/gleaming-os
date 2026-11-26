//! Runs PowerShell code.
//!
//! The code is given with `-Command`, so its exit code follows the [rules of `-Command`]: 0 when
//! the last command succeeded, 1 when it failed, unless the code calls `exit`.
//!
//! [rules of `-Command`]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1

use std::os::windows::process::CommandExt;
use std::process::{Command, Output, Stdio};
use std::{io, iter};

use windows::Win32::System::Threading::CREATE_NO_WINDOW;

/// The arguments before the code.
///
/// `-EncodedCommand` would avoid quoting the code, but PowerShell then writes its errors and
/// progress as XML.
const ARGUMENTS: [&str; 5] = [
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-Command",
];

/// The command line running `script`, for Windows APIs that take a single string.
pub fn command_line(script: &str) -> String {
    format!("powershell.exe {} {}", ARGUMENTS.join(" "), quote(script))
}

/// Runs `script` as the current user, who is administrator, and waits for its output.
///
/// # Errors
///
/// Returns an error when PowerShell can't start.
pub fn run(script: &str) -> io::Result<Output> {
    Command::new("powershell.exe")
        .args(ARGUMENTS)
        .arg(script)
        .stdin(Stdio::null())
        .creation_flags(CREATE_NO_WINDOW.0)
        .output()
}

/// Quotes an argument for the [usual parsing of Windows command lines], where backslashes only
/// escape quotes.
///
/// [usual parsing of Windows command lines]: https://learn.microsoft.com/en-us/cpp/cpp/main-function-command-line-args#parsing-c-command-line-arguments
fn quote(argument: &str) -> String {
    let mut quoted = String::from('"');
    let mut backslashes = 0;
    for character in argument.chars() {
        if character == '\\' {
            backslashes += 1;
            continue;
        }
        let escapes = if character == '"' {
            backslashes * 2 + 1
        } else {
            backslashes
        };
        quoted.extend(iter::repeat_n('\\', escapes));
        quoted.push(character);
        backslashes = 0;
    }
    quoted.extend(iter::repeat_n('\\', backslashes * 2));
    quoted.push('"');
    quoted
}
