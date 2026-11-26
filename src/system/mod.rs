//! The Windows APIs the wizard calls directly, and the only place with `unsafe` code.
//!
//! The [`windows`](https://docs.rs/windows) crate marks the Win32 functions as `unsafe` because
//! they take raw pointers and handles. Here, every pointer comes from a live local variable, and every handle is kept in
//! an [`Owned`](windows::core::Owned), which closes it when dropped.

pub mod privileges;

use std::ffi::c_void;
use std::process::Command;
use std::{io, ptr};

use raw_window_handle::{HasWindowHandle, RawWindowHandle};
use windows::Win32::Foundation::{HWND, LPARAM, WPARAM};
use windows::Win32::Globalization::{CP_OEMCP, MULTI_BYTE_TO_WIDE_CHAR_FLAGS, MultiByteToWideChar};
use windows::Win32::System::LibraryLoader::GetModuleHandleW;
use windows::Win32::System::Power::{ES_CONTINUOUS, ES_SYSTEM_REQUIRED, SetThreadExecutionState};
use windows::Win32::UI::HiDpi::{GetDpiForWindow, GetSystemMetricsForDpi};
use windows::Win32::UI::WindowsAndMessaging::{
    ICON_BIG, ICON_SMALL, IMAGE_ICON, LR_DEFAULTCOLOR, LoadImageW, SM_CXICON, SM_CXSMICON,
    SendMessageW, WM_SETICON,
};
use windows::core::PCWSTR;

/// Keeps Windows from sleeping while alive, as long as it stays on the thread that created it.
///
/// See [`SetThreadExecutionState`](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate).
pub struct KeepAwake;

impl KeepAwake {
    /// Keeps Windows awake until the returned value is dropped.
    pub fn start() -> Self {
        unsafe { SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED) };
        Self
    }
}

impl Drop for KeepAwake {
    fn drop(&mut self) {
        unsafe { SetThreadExecutionState(ES_CONTINUOUS) };
    }
}

/// Opens a file or a URL as the standard user, through Windows Explorer.
///
/// # Errors
///
/// Returns an error when Windows Explorer can't start.
pub fn open(target: &str) -> io::Result<()> {
    Command::new("explorer.exe").arg(target).spawn().map(drop)
}

/// Restarts Windows now.
///
/// # Errors
///
/// Returns an error when `shutdown.exe` can't start.
pub fn restart() -> io::Result<()> {
    Command::new("shutdown.exe")
        .args(["/r", "/t", "0"])
        .spawn()
        .map(drop)
}

/// Shows the icon embedded by `build.rs` on the window, at the sizes matching its DPI.
pub fn set_window_icon(window: &impl HasWindowHandle) {
    let Ok(handle) = window.window_handle() else {
        return;
    };
    let RawWindowHandle::Win32(handle) = handle.as_raw() else {
        return;
    };
    let window = HWND(handle.hwnd.get() as *mut c_void);
    unsafe {
        let Ok(module) = GetModuleHandleW(None) else {
            return;
        };
        let dpi = GetDpiForWindow(window);
        for (kind, metric) in [(ICON_BIG, SM_CXICON), (ICON_SMALL, SM_CXSMICON)] {
            let size = GetSystemMetricsForDpi(metric, dpi);
            let Ok(icon) = LoadImageW(
                Some(module.into()),
                // MAKEINTRESOURCE(1): winresource gives the icon the ID 1
                PCWSTR(ptr::without_provenance(1)),
                IMAGE_ICON,
                size,
                size,
                LR_DEFAULTCOLOR,
            ) else {
                continue;
            };
            SendMessageW(
                window,
                WM_SETICON,
                Some(WPARAM(kind as usize)),
                Some(LPARAM(icon.0 as isize)),
            );
        }
    }
}

/// Decodes the output of a console program, which writes in the OEM code page.
///
/// See [`MultiByteToWideChar`](https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar).
pub fn decode_console(bytes: &[u8]) -> String {
    if bytes.is_empty() {
        return String::new();
    }
    let flags = MULTI_BYTE_TO_WIDE_CHAR_FLAGS(0);
    unsafe {
        let mut wide = vec![0; MultiByteToWideChar(CP_OEMCP, flags, bytes, None) as usize];
        MultiByteToWideChar(CP_OEMCP, flags, bytes, Some(&mut wide));
        String::from_utf16_lossy(&wide)
    }
}
