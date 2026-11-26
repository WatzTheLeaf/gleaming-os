//! The ordered steps of the run.
//!
//! Each step runs a script of `playbook\Steps` with the privileges it needs, from the
//! `playbook\Files` folder. Consecutive changes needing the same privileges share a script, made
//! of one section per change, in the order of the run. The scripts read the selected options with
//! the `Test-Option` function of `playbook\Playbook.psm1`.

use RunAs::{Admin, TrustedInstaller, User};

/// Whose privileges a step runs with.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum RunAs {
    /// TrustedInstaller, which can modify protected system files and settings.
    TrustedInstaller,
    /// The user, as administrator.
    Admin,
    /// The user without administrator rights, for their own settings.
    User,
}

/// What a step runs.
#[derive(Clone, Debug)]
pub enum Command {
    /// PowerShell code, run after importing `playbook\Playbook.psm1`.
    PowerShell(String),
    /// A command line whose exit code is checked.
    Program(String),
    /// Starts Windows Explorer as the shell after a script stopped it, unless Windows restarts it
    /// by itself.
    StartShell,
}

/// A step of the run.
#[derive(Clone, Debug)]
pub struct Step {
    /// Shown to the user while the step runs.
    pub status: &'static str,
    /// Identifies the step in the log and in the details: its script or its command.
    pub name: String,
    pub command: Command,
    pub run_as: RunAs,
    /// The share of the progress bar, relative to the other steps.
    pub weight: u32,
    /// Whether a failure stops the run.
    pub critical: bool,
}

impl Step {
    /// Sets the share of the progress bar, 1 by default.
    fn weight(&mut self, weight: u32) -> &mut Self {
        self.weight = weight;
        self
    }

    /// Makes a failure stop the run.
    fn critical(&mut self) -> &mut Self {
        self.critical = true;
        self
    }
}

/// Builds the steps in order, each one taking the status set last.
#[derive(Default)]
struct Plan {
    steps: Vec<Step>,
    status: &'static str,
}

impl Plan {
    /// Sets the status shown during the next steps.
    fn status(&mut self, status: &'static str) {
        self.status = status;
    }

    /// Adds a step, of weight 1 and not critical.
    fn push(&mut self, run_as: RunAs, name: String, command: Command) -> &mut Step {
        self.steps.push(Step {
            status: self.status,
            name,
            command,
            run_as,
            weight: 1,
            critical: false,
        });
        self.steps.last_mut().expect("a step was just pushed")
    }

    /// Adds a script of `playbook\Steps`: a `.ps1` file runs in PowerShell, a `.cmd` file in the
    /// command prompt.
    fn script(&mut self, run_as: RunAs, file: &str) -> &mut Step {
        let command = if file.ends_with(".cmd") {
            Command::Program(format!("cmd.exe /c \"..\\Steps\\{file}\""))
        } else {
            Command::PowerShell(format!("& '..\\Steps\\{file}'"))
        };
        self.push(run_as, file.to_owned(), command)
    }

    /// Adds a program, as a command line.
    fn program(&mut self, run_as: RunAs, command_line: &str) -> &mut Step {
        self.push(
            run_as,
            command_line.to_owned(),
            Command::Program(command_line.to_owned()),
        )
    }

    /// Adds [`Command::StartShell`].
    fn start_shell(&mut self, run_as: RunAs) -> &mut Step {
        self.push(run_as, "explorer.exe".to_owned(), Command::StartShell)
    }
}

/// The steps of the run, in order.
pub fn steps() -> Vec<Step> {
    let mut plan = Plan::default();

    plan.status("Copying files");
    plan.script(TrustedInstaller, "copy-files.ps1")
        .weight(10)
        .critical();

    // First, as precompiling the .NET assemblies makes PowerShell start faster for the next steps
    plan.status("Optimizing PowerShell");
    plan.script(TrustedInstaller, "optimize-powershell.ps1")
        .weight(2);

    // Empties the temporary folders and deletes every shadow copy
    plan.status("Cleaning up");
    plan.script(Admin, "cleanup.ps1");
    // Before the scripts adding pages to the list, as this one replaces the whole list
    plan.script(TrustedInstaller, "set-hidden-settings-pages.ps1");

    plan.status("Enabling DirectPlay");
    plan.program(
        TrustedInstaller,
        r#"DISM.exe /Online /Enable-Feature /FeatureName:"DirectPlay" /NoRestart /All"#,
    )
    .weight(30);
    plan.program(
        TrustedInstaller,
        r#"DISM.exe /Online /Remove-Capability /CapabilityName:"App.StepsRecorder~~~~0.0.1.0" /NoRestart"#,
    )
    .weight(30);

    plan.status("Cleaning the component store");
    plan.program(
        TrustedInstaller,
        "DISM.exe /Online /Cleanup-Image /StartComponentCleanup",
    )
    .weight(50);

    plan.status("Installing Visual C++ Runtimes");
    plan.script(Admin, "install-vcredist.ps1").weight(150);

    // Later steps need Brave (pins, file associations): a failed installation halts the run
    // before Windows is marked as modified, so that the run can be started again
    plan.status("Installing Brave");
    plan.script(Admin, "install-brave.ps1")
        .weight(120)
        .critical();

    plan.status("Disabling File Sharing");
    plan.script(Admin, "disable-file-sharing.ps1");

    plan.status("Disabling Location");
    plan.script(Admin, "disable-location.cmd");

    plan.status("Configuring Indexing");
    // The script expects TrustedInstaller privileges
    plan.script(TrustedInstaller, "minimal-search-indexing.cmd");

    plan.status("Configuring services");
    plan.script(TrustedInstaller, "services.ps1");

    plan.status("Configuring drivers");
    plan.script(TrustedInstaller, "drivers-and-components.ps1")
        .weight(2);

    plan.status("Removing Microsoft Edge");
    // As the user, whose Edge data is removed too
    plan.script(Admin, "remove-edge.ps1");
    plan.script(TrustedInstaller, "remove-edge-appx.ps1");

    plan.status("Removing OneDrive");
    plan.script(TrustedInstaller, "remove-onedrive.cmd");

    plan.status("Removing components");
    plan.script(TrustedInstaller, "remove-components.ps1");

    plan.status("Removing AppX packages");
    plan.script(TrustedInstaller, "remove-appx.ps1");

    plan.status("Clearing AppX caches");
    plan.script(TrustedInstaller, "clear-appx-caches.ps1");

    plan.status("Running networking tweaks");
    plan.script(Admin, "config-network-adapters.cmd");
    plan.script(TrustedInstaller, "networking.ps1").weight(4);

    plan.status("Running performance tweaks");
    plan.script(TrustedInstaller, "config-mmcss.ps1");
    plan.script(Admin, "disable-auto-folder-discovery.ps1");
    plan.script(TrustedInstaller, "performance.ps1").weight(8);

    plan.status("Running privacy tweaks");
    plan.script(TrustedInstaller, "privacy.ps1").weight(34);

    plan.status("Running QoL tweaks");
    plan.script(TrustedInstaller, "boot-wallpaper-start-menu.ps1")
        .weight(3);
    plan.script(Admin, "config-terminal.ps1");
    plan.script(TrustedInstaller, "qol.ps1").weight(18);
    plan.script(User, "remove-python-store-aliases.ps1");
    plan.script(TrustedInstaller, "lilac-tooltips.ps1");
    plan.script(Admin, "gleaming-theme.ps1");
    plan.script(TrustedInstaller, "updates-accessibility-taskbar.ps1")
        .weight(16);
    // The previous scripts stopped Windows Explorer
    plan.start_shell(User);
    plan.script(TrustedInstaller, "taskbar.ps1").weight(3);
    plan.script(Admin, "config-pins.ps1");
    plan.script(TrustedInstaller, "taskbar-and-explorer.ps1")
        .weight(7);
    plan.script(Admin, "disable-network-navigation-pane.ps1");
    plan.script(TrustedInstaller, "explorer.ps1").weight(14);
    plan.script(Admin, "gallery-and-send-to.ps1").weight(2);
    plan.script(TrustedInstaller, "long-paths-and-context-menus.ps1")
        .weight(14);
    plan.script(Admin, "remove-print-context-menu.cmd");
    plan.script(TrustedInstaller, "uac-and-shell.ps1").weight(7);
    // The previous scripts stopped Windows Explorer
    plan.start_shell(User);
    plan.script(TrustedInstaller, "shell-and-startup.ps1")
        .weight(9);

    plan.status("Running security tweaks");
    plan.script(TrustedInstaller, "security.ps1").weight(2);

    plan.status("Running debloating tweaks");
    plan.script(TrustedInstaller, "debloat.ps1").weight(34);

    plan.status("Running scripts");
    plan.script(TrustedInstaller, "system-scripts.ps1")
        .weight(5);

    plan.status("Running miscellaneous tweaks");
    plan.script(TrustedInstaller, "time-and-perf-counters.ps1")
        .weight(2);
    plan.script(User, "add-music-videos-to-home.ps1");
    // Kept last, as AtlasOS does
    plan.script(Admin, "power.ps1").weight(40);

    plan.status("Securing PowerShell execution policy");
    plan.script(TrustedInstaller, "finish.ps1");

    plan.steps
}
