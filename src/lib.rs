//! GleamingOS: a wizard applying a Windows 11 playbook based on [AtlasOS].
//!
//! The playbook, the scripts of the `playbook` folder, is embedded in the executable, which runs it
//! itself.
//!
//! # How it works
//!
//! 1. [`requirements`] checks that Windows can be modified safely.
//! 2. The user picks the [`playbook::options`].
//! 3. [`playbook::plan`] turns them into the ordered steps of the run.
//! 4. [`runner`] extracts the [`playbook::payload`] and runs each step in the background, as
//!    TrustedInstaller, the administrator or the user thanks to [`system::privileges`]. Most
//!    steps are PowerShell scripts, started by [`powershell`].
//!
//! The [`ui`] module shows each of these stages as a screen of the wizard.
//!
//! [AtlasOS]: https://atlasos.net

// The documentation always includes the private items (see `.cargo/config.toml`), so the links
// above to the private modules resolve
#![allow(rustdoc::private_intra_doc_links)]

mod playbook;
mod powershell;
mod requirements;
mod runner;
mod system;
mod ui;

/// Opens the wizard and returns once its window is closed.
///
/// # Errors
///
/// Returns an error when the window can't be created.
pub fn run() -> eframe::Result {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([880.0, 640.0])
            // An empty icon keeps eframe from setting its own, the wizard sets the embedded one
            .with_icon(egui::IconData::default())
            .with_resizable(false)
            .with_maximize_button(false),
        ..Default::default()
    };
    eframe::run_native(
        playbook::TITLE,
        options,
        Box::new(|cc| Ok(Box::new(ui::app::App::new(cc)))),
    )
}
