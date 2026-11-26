//! The executable, which opens the wizard of the [`gleaming_os`] library.

// No console window opens alongside the wizard
#![windows_subsystem = "windows"]

fn main() -> eframe::Result {
    gleaming_os::run()
}
