//! What GleamingOS applies: its description, its options, its steps and its files.
//!
//! The constants below describe it, [`options`] lists its choices, [`plan`] orders the scripts of the
//! `playbook` folder into steps, and [`payload`] embeds that folder.

pub mod options;
pub mod payload;
pub mod plan;

/// The playbook's name, used in messages.
pub const NAME: &str = "GleamingOS";
/// The title of the window and of the sidebar.
pub const TITLE: &str = "GleamingOS v1.0.0";
/// The heading of the welcome screen.
pub const SHORT_DESCRIPTION: &str = "GleamingOS Playbook for Windows 11";
/// The introduction of the welcome screen.
pub const DESCRIPTION: &str =
    "GleamingOS is a personal, disposable-friendly Windows 11 setup based on AtlasOS.";
/// Shown on the welcome screen, under the introduction.
pub const DETAILS: &str = "An open and lightweight modification to Windows based on AtlasOS, designed to optimize privacy \
     and simplify usage.";
/// Shown while the steps run, under the current status.
pub const PROGRESS_TEXT: &str = "GleamingOS is currently installing software, copying its configuration folders, and tweaking \
     Windows.";
/// The approximate duration of the run, shown on the welcome and review screens.
pub const ESTIMATED_MINUTES: u32 = 15;
/// Windows 11 25H2 and 26H2.
pub const SUPPORTED_BUILDS: [u32; 2] = [26200, 26300];
