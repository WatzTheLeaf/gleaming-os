//! The requirements checked before changing anything, like those of the AtlasOS playbook.
//!
//! `requirements.ps1` gathers facts about the system, which are then turned into requirements.
//! An unmet requirement blocks the installation, unless its status is only a warning.

use std::collections::HashMap;
use std::sync::mpsc::{self, Receiver};
use std::{io, thread};

use crate::playbook::{NAME, SUPPORTED_BUILDS};
use crate::{powershell, system};

/// Windows installed for longer than this is reported as not fresh.
const FRESH_INSTALL_DAYS: u32 = 7;

/// Disables the UserChoice Protection Driver, which blocks changing the default browser, and the
/// scheduled task that would enable it again.
const DISABLE_UCPD: &str = r"
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\UCPD' -Name 'Start' -Value 4 -Type DWord -ErrorAction Stop
Disable-ScheduledTask -TaskPath '\Microsoft\Windows\AppxDeploymentClient\' -TaskName 'UCPD velocity' | Out-Null";

/// Whether a requirement is met.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Status {
    Met,
    /// Unmet, but the user can continue anyway.
    Warning,
    /// Unmet, which blocks the installation.
    Unmet,
}

/// An action offered to the user to meet a requirement.
#[derive(Clone, Copy, Debug)]
pub enum Fix {
    /// Opens Windows Security at the virus & threat protection settings.
    OpenWindowsSecurity,
    /// Opens Windows Security at App & browser control, where Smart App Control is.
    OpenSmartAppControl,
    /// Disables the UserChoice Protection Driver, which takes effect after a restart.
    DisableUcpd,
    /// Restarts Windows.
    Restart,
}

/// A condition for applying the playbook.
pub struct Requirement {
    pub title: &'static str,
    pub status: Status,
    /// What to do about it, empty when met.
    pub detail: String,
    /// Offered when unmet.
    pub fix: Option<Fix>,
}

impl Requirement {
    /// A requirement that blocks the installation when unmet.
    fn required(title: &'static str, met: bool, detail: impl Into<String>) -> Self {
        Self::new(title, met, Status::Unmet, detail.into())
    }

    /// A requirement that only warns when unmet.
    fn recommended(title: &'static str, met: bool, detail: impl Into<String>) -> Self {
        Self::new(title, met, Status::Warning, detail.into())
    }

    /// A requirement whose status is `unmet_status` when unmet, without fix.
    fn new(title: &'static str, met: bool, unmet_status: Status, detail: String) -> Self {
        let (status, detail) = if met {
            (Status::Met, String::new())
        } else {
            (unmet_status, detail)
        };
        Self {
            title,
            status,
            detail,
            fix: None,
        }
    }

    /// Offers `fix` when the requirement is unmet.
    fn with_fix(mut self, fix: Fix) -> Self {
        if self.status != Status::Met {
            self.fix = Some(fix);
        }
        self
    }
}

/// Checks the requirements on a background thread, as the checks take several seconds.
///
/// The requirements are sent once checked, and `ctx` is repainted to show them.
pub fn check(ctx: egui::Context) -> Receiver<Vec<Requirement>> {
    let (sender, receiver) = mpsc::channel();
    thread::spawn(move || {
        let _ = sender.send(evaluate(&facts()));
        ctx.request_repaint();
    });
    receiver
}

/// Applies a fix.
///
/// # Errors
///
/// Returns an error when the program applying the fix can't start, or when disabling the driver
/// fails.
pub fn fix(fix: Fix) -> io::Result<()> {
    match fix {
        Fix::OpenWindowsSecurity => system::open("windowsdefender://threatsettings"),
        Fix::OpenSmartAppControl => system::open("windowsdefender://appbrowser"),
        Fix::DisableUcpd => match powershell::run(DISABLE_UCPD)? {
            output if output.status.success() => Ok(()),
            output => Err(io::Error::other(system::decode_console(&output.stderr))),
        },
        Fix::Restart => system::restart(),
    }
}

/// The facts printed by `requirements.ps1`, as `name=value` lines.
///
/// A fact the script couldn't gather is missing. When the script can't run at all, the Windows
/// build is unknown, which blocks the installation.
fn facts() -> HashMap<String, String> {
    let output = powershell::run(include_str!("requirements.ps1"))
        .map(|output| system::decode_console(&output.stdout))
        .unwrap_or_default();
    output
        .lines()
        .filter_map(|line| line.split_once('='))
        .map(|(name, value)| (name.into(), value.trim().into()))
        .collect()
}

/// Turns the facts into requirements.
fn evaluate(facts: &HashMap<String, String>) -> Vec<Requirement> {
    let text = |name: &str| facts.get(name).map_or("", String::as_str);
    let flag = |name: &str| text(name) == "1";
    let number = |name: &str| text(name).parse::<u32>().unwrap_or_default();
    let (build, days) = (number("build"), number("installed_days"));
    let builds = SUPPORTED_BUILDS.map(|build| build.to_string()).join(", ");
    let (ucpd_detail, ucpd_fix) = if flag("ucpd_disabled") {
        (
            "Restart Windows to finish disabling the User Choice Protection Driver.",
            Fix::Restart,
        )
    } else {
        (
            "The User Choice Protection Driver must be disabled, then Windows restarted.",
            Fix::DisableUcpd,
        )
    };

    vec![
        Requirement::required(
            "Supported Windows version",
            SUPPORTED_BUILDS.contains(&build),
            format!(
                "Windows build {build} isn't supported, {NAME} requires one of the builds {builds}."
            ),
        ),
        Requirement::required(
            "Not applied yet",
            !flag("applied"),
            format!(
                "{NAME} has already been applied on this system. Reinstall Windows to apply it again."
            ),
        ),
        Requirement::required(
            "Defender protections turned off",
            text("defender").is_empty(),
            format!(
                "Turn off in Windows Security > Virus & threat protection settings: {}.",
                text("defender")
            ),
        )
        .with_fix(Fix::OpenWindowsSecurity),
        Requirement::required(
            "Smart App Control turned off",
            number("smart_app_control") == 0,
            "Turn it off in Windows Security > App & browser control > Smart App Control settings, as it \
             blocks tools used during the installation. Only reinstalling Windows turns it back on.",
        )
        .with_fix(Fix::OpenSmartAppControl),
        Requirement::required(
            "No third-party antivirus",
            text("antivirus").is_empty(),
            format!("Uninstall {} first.", text("antivirus")),
        ),
        Requirement::required(
            "Internet connection",
            flag("internet"),
            "Connect to the Internet, software is downloaded during the installation.",
        ),
        Requirement::required(
            "UCPD disabled",
            flag("ucpd_disabled") && !flag("ucpd_running"),
            ucpd_detail,
        )
        .with_fix(ucpd_fix),
        Requirement::required(
            "Plugged in",
            flag("plugged_in"),
            "Plug in the charger, the installation must not be interrupted.",
        ),
        Requirement::recommended(
            "No pending updates",
            !flag("pending"),
            "Updates are waiting for a restart, restarting before applying is recommended.",
        )
        .with_fix(Fix::Restart),
        Requirement::recommended(
            "Fresh installation",
            days <= FRESH_INSTALL_DAYS,
            format!(
                "Windows was installed {days} days ago, {NAME} is meant for a fresh installation."
            ),
        ),
    ]
}
