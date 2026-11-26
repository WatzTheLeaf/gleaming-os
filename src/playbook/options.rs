//! The option pages of the wizard, and the options the user selected on them.
//!
//! An option is identified by its name. The selected options decide which steps run in
//! [`plan`](super::plan), and the PowerShell steps check them with the `Test-Option` function of
//! `playbook\Playbook.psm1`.

use std::collections::BTreeSet;

/// How a page presents its choices.
pub enum WizardChoiceKind {
    /// One choice among several.
    Radio,
    /// Any number of choices.
    Checkbox,
}

/// A page of options in the wizard.
pub struct Page {
    pub kind: WizardChoiceKind,
    /// A short name, shown in the list of steps.
    pub title: &'static str,
    pub description: &'static str,
    /// A note highlighted above the choices.
    pub top_line: Option<&'static str>,
    /// The option that must be selected for the page to be shown, see [`Options::is_visible`].
    depends_on: Option<&'static str>,
    pub choices: &'static [Choice],
}

/// A choice of a page, which selects the option of the same name.
pub struct Choice {
    pub name: &'static str,
    /// The label shown to the user.
    pub text: &'static str,
    /// The default choice of a radio page, or the default state of a checkbox.
    pub selected: bool,
}

/// A choice shown with a radio button or a checkbox.
const fn choice(name: &'static str, text: &'static str, selected: bool) -> Choice {
    Choice {
        name,
        text,
        selected,
    }
}

const NOT_CHANGEABLE: Option<&str> = Some("This choice can't be changed after installation.");

/// The option pages, in the order of the wizard.
pub const PAGES: &[Page] = &[
    Page {
        kind: WizardChoiceKind::Radio,
        title: "Defender",
        description: "Disabling Defender reduces security, and is an option for advanced users only.",
        top_line: NOT_CHANGEABLE,
        depends_on: None,
        choices: &[
            choice("defender-enable", "Enable Defender (recommended)", true),
            choice("defender-disable", "Disable Defender", false),
        ],
    },
    Page {
        kind: WizardChoiceKind::Radio,
        title: "Windows Update",
        description: "Updates are important for security, you'll get update notifications regardless.",
        top_line: NOT_CHANGEABLE,
        depends_on: None,
        choices: &[
            choice(
                "auto-updates-disable",
                "Disable Automatic Windows Updates",
                true,
            ),
            choice(
                "auto-updates-default",
                "Enable Automatic Windows Updates",
                false,
            ),
        ],
    },
    Page {
        kind: WizardChoiceKind::Checkbox,
        title: "System options",
        description: "Select the options you would like to use, they can't be changed after installation.",
        top_line: None,
        depends_on: None,
        choices: &[
            choice("disable-hibernation", "Disable Hibernation", true),
            choice(
                "disable-power-saving",
                "Maximum Performance (Disable Power Saving)",
                true,
            ),
            choice("disable-core-isolation", "Disable Core Isolation", true),
            choice("pin-terminal", "Pin Windows Terminal to the taskbar", false),
        ],
    },
    Page {
        kind: WizardChoiceKind::Radio,
        title: "Theme",
        description: "Select the default Windows theme.",
        top_line: Some("Both themes remain available in Windows Settings."),
        depends_on: None,
        choices: &[
            choice("theme-dark", "Dark theme", true),
            choice("theme-light", "Light theme (without transparency)", false),
        ],
    },
    Page {
        kind: WizardChoiceKind::Radio,
        title: "Taskbar",
        description: "Select the taskbar style for the dark theme.",
        top_line: Some("This can be changed later in Settings > Personalization > Colors."),
        depends_on: Some("theme-dark"),
        choices: &[
            choice("taskbar-solid", "Solid taskbar with accent color", true),
            choice(
                "taskbar-transparent",
                "Transparent taskbar without accent color",
                false,
            ),
        ],
    },
    Page {
        kind: WizardChoiceKind::Radio,
        title: "DNS provider",
        description: "Select your DNS provider. DNS over HTTPS will be enabled on all network adapters.",
        top_line: Some("Your DNS requests will be encrypted."),
        depends_on: None,
        choices: &[
            choice("dns-cloudflare", "Cloudflare", true),
            choice("dns-quad9", "Quad9", false),
        ],
    },
];

/// The names of the selected options.
#[derive(Clone)]
pub struct Options(BTreeSet<&'static str>);

impl Default for Options {
    /// The default choices of every page.
    fn default() -> Self {
        let defaults = PAGES
            .iter()
            .flat_map(|page| page.choices)
            .filter(|choice| choice.selected);
        Self(defaults.map(|choice| choice.name).collect())
    }
}

impl Options {
    /// Whether the option is selected.
    pub fn contains(&self, name: &str) -> bool {
        self.0.contains(name)
    }

    /// Selects a choice of a radio page, which deselects the other choices of the page.
    pub fn select(&mut self, page: &Page, name: &'static str) {
        for choice in page.choices {
            self.0.remove(choice.name);
        }
        self.0.insert(name);
    }

    /// Checks or unchecks a checkbox.
    pub fn set(&mut self, name: &'static str, selected: bool) {
        if selected {
            self.0.insert(name);
        } else {
            self.0.remove(name);
        }
    }

    /// Whether the page is shown, according to its [`depends_on`](Page::depends_on) option.
    pub fn is_visible(&self, page: &Page) -> bool {
        page.depends_on.is_none_or(|option| self.contains(option))
    }

    /// The options to apply: those of the visible pages, as hidden pages don't apply.
    pub fn applied(&self) -> Self {
        let visible = PAGES
            .iter()
            .filter(|page| self.is_visible(page))
            .flat_map(|page| page.choices);
        Self(
            visible
                .map(|choice| choice.name)
                .filter(|name| self.contains(name))
                .collect(),
        )
    }

    /// The names of the selected options, in alphabetical order.
    pub fn names(&self) -> impl Iterator<Item = &'static str> {
        self.0.iter().copied()
    }
}
