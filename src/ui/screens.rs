//! The content of each screen, between the sidebar and the action bar.
//!
//! Every screen starts with a heading, made of an overline such as "Step 2 of 8" and a title.

use egui::{
    Align, CollapsingHeader, Label, Layout, ProgressBar, RichText, ScrollArea, Separator, Sides,
    Spinner, TextStyle, Ui,
};

use crate::playbook;
use crate::playbook::options::{WizardChoiceKind, Options, PAGES, Page};
use crate::requirements::{Fix, Requirement, Status};
use crate::runner::{self, Run, State};
use crate::ui::theme::{AMETHYST, CHANTERELLE, HONEY, INK, LINEN, MOSS, semibold};
use crate::ui::widgets::{self, Icon, Indicator, Tone};

/// What the playbook is, and what applying it involves.
pub fn welcome(ui: &mut Ui, overline: &str) {
    widgets::heading(ui, overline, playbook::SHORT_DESCRIPTION);
    ui.label(RichText::new(playbook::DESCRIPTION).size(17.0).color(INK));
    widgets::muted(ui, playbook::DETAILS);
    ui.add_space(12.0);
    let duration = format!("{} min", playbook::ESTIMATED_MINUTES);
    let facts = [
        (duration.as_str(), "Approximate duration"),
        ("Internet", "Required during the installation"),
        ("Permanent", "Only undone by reinstalling Windows"),
    ];
    ui.columns(facts.len(), |columns| {
        for (ui, (value, label)) in columns.iter_mut().zip(facts) {
            // Columns are justified, which would stretch the words of wrapped text
            ui.with_layout(Layout::top_down(Align::Min), |ui| {
                widgets::card(ui, |ui| {
                    ui.set_min_height(66.0);
                    ui.spacing_mut().item_spacing.y = 2.0;
                    ui.label(RichText::new(value).font(semibold(18.0)).color(INK));
                    widgets::muted(ui, label);
                });
            });
        }
    });
}

/// The requirements, those needing attention first, and the fixes offered for them.
///
/// Returns the fix the user clicked. `fix_error` tells why the last fix failed.
pub fn requirements(
    ui: &mut Ui,
    overline: &str,
    requirements: &[Requirement],
    checking: bool,
    fix_error: Option<&str>,
) -> Option<Fix> {
    widgets::heading(ui, overline, "Requirements");
    if checking {
        ui.horizontal(|ui| {
            ui.add(Spinner::new().color(AMETHYST));
            widgets::muted(ui, "Checking your system...");
        });
        return None;
    }

    let count = |status| {
        requirements
            .iter()
            .filter(|requirement| requirement.status == status)
            .count()
    };
    match (count(Status::Unmet), count(Status::Warning)) {
        (0, 0) => widgets::callout(ui, Tone::Success, "Your system is ready."),
        (0, _) => widgets::callout(
            ui,
            Tone::Warning,
            "Your system is ready. Warnings don't prevent continuing.",
        ),
        (1, _) => widgets::callout(ui, Tone::Error, "1 requirement must be met to continue."),
        (unmet, _) => widgets::callout(
            ui,
            Tone::Error,
            format!("{unmet} requirements must be met to continue."),
        ),
    }
    if let Some(error) = fix_error {
        widgets::callout(ui, Tone::Error, error);
    }

    let mut sorted: Vec<&Requirement> = requirements.iter().collect();
    sorted.sort_by_key(|requirement| match requirement.status {
        Status::Unmet => 0,
        Status::Warning => 1,
        Status::Met => 2,
    });
    widgets::card(ui, |ui| {
        ui.spacing_mut().item_spacing.y = 6.0;
        let mut clicked = None;
        for (index, requirement) in sorted.into_iter().enumerate() {
            if index > 0 {
                ui.add(Separator::default().spacing(12.0));
            }
            clicked = requirement_row(ui, requirement).or(clicked);
        }
        clicked
    })
}

/// A requirement with its status, and its fix as a button. Returns the fix if clicked.
fn requirement_row(ui: &mut Ui, requirement: &Requirement) -> Option<Fix> {
    ui.horizontal_top(|ui| {
        let (icon, fill, symbol) = match requirement.status {
            Status::Met => (Icon::Check, MOSS, LINEN),
            Status::Warning => (Icon::Exclamation, HONEY, INK),
            Status::Unmet => (Icon::Cross, CHANTERELLE, LINEN),
        };
        widgets::badge(ui, 11.0, icon, fill, symbol);
        ui.vertical(|ui| {
            ui.spacing_mut().item_spacing.y = 4.0;
            ui.label(
                RichText::new(requirement.title)
                    .font(semibold(15.0))
                    .color(INK),
            );
            if !requirement.detail.is_empty() {
                widgets::muted(ui, &requirement.detail);
            }
            let fix = requirement.fix?;
            ui.add_space(4.0);
            widgets::button(ui, fix_label(fix)).clicked().then_some(fix)
        })
        .inner
    })
    .inner
}

/// The label of a fix's button.
fn fix_label(fix: Fix) -> &'static str {
    match fix {
        Fix::OpenWindowsSecurity | Fix::OpenSmartAppControl => "Open Windows Security",
        Fix::DisableUcpd => "Disable UCPD",
        Fix::Restart => "Restart now",
    }
}

/// An option page, whose choices update `options` when clicked.
pub fn options_page(ui: &mut Ui, overline: &str, page: &Page, options: &mut Options) {
    widgets::heading(ui, overline, page.title);
    widgets::muted(ui, page.description);
    if let Some(top_line) = page.top_line {
        widgets::callout(ui, Tone::Note, top_line);
    }
    ui.add_space(6.0);

    match page.kind {
        WizardChoiceKind::Radio => {
            for choice in page.choices {
                let selected = options.contains(choice.name);
                if widgets::choice(ui, Indicator::Radio, selected, choice.text).clicked() {
                    options.select(page, choice.name);
                }
            }
        }
        WizardChoiceKind::Checkbox => {
            for choice in page.choices {
                let selected = options.contains(choice.name);
                if widgets::choice(ui, Indicator::Check, selected, choice.text).clicked() {
                    options.set(choice.name, !selected);
                }
            }
        }
    }
}

/// A last warning, and the choices made on each visible option page.
pub fn review(ui: &mut Ui, overline: &str, options: &Options) {
    widgets::heading(ui, overline, "Review your choices");
    widgets::callout(
        ui,
        Tone::Warning,
        format!(
            "{} will now modify Windows. Save your work and close other programs, then keep the computer on, \
             plugged in and connected for about {} minutes.",
            playbook::NAME,
            playbook::ESTIMATED_MINUTES
        ),
    );
    widgets::card(ui, |ui| {
        let pages = PAGES.iter().filter(|page| options.is_visible(page));
        for (index, page) in pages.enumerate() {
            if index > 0 {
                ui.separator();
            }
            ui.horizontal_top(|ui| {
                ui.scope(|ui| {
                    ui.set_width(150.0);
                    widgets::muted(ui, page.title);
                });
                ui.vertical(|ui| {
                    ui.spacing_mut().item_spacing.y = 2.0;
                    let mut chosen = page
                        .choices
                        .iter()
                        .filter(|choice| options.contains(choice.name))
                        .peekable();
                    if chosen.peek().is_none() {
                        widgets::muted(ui, "None");
                    }
                    for choice in chosen {
                        ui.label(RichText::new(choice.text).color(INK));
                    }
                });
            });
        }
    });
}

/// The progress of the run, then its result.
pub fn run(ui: &mut Ui, overline: &str, run: &Run) {
    match run.state() {
        State::NotStarted => not_started(ui, run),
        State::Running => in_progress(ui, overline, run),
        State::Halted(index) => halted(ui, run, index),
        State::Completed => completed(ui, run),
    }
}

/// Why the run couldn't start.
fn not_started(ui: &mut Ui, run: &Run) {
    result_heading(ui, "The installation couldn't start", false);
    if let Some(failure) = &run.failure {
        widgets::callout(ui, Tone::Error, failure.as_str());
    }
    widgets::muted(ui, "Nothing was changed.");
}

/// The current step and the progress bar.
fn in_progress(ui: &mut Ui, overline: &str, run: &Run) {
    let step = run.current.map(|index| &run.steps[index]);
    widgets::heading(ui, overline, step.map_or("Starting", |step| step.status));
    widgets::muted(ui, playbook::PROGRESS_TEXT);
    ui.add_space(8.0);
    Sides::new().shrink_left().truncate().show(
        ui,
        |ui| {
            if let Some(step) = step {
                widgets::muted(ui, &step.name);
            }
        },
        |ui| {
            let percent = format!("{:.0} %", run.progress() * 100.0);
            ui.label(RichText::new(percent).font(semibold(15.0)).color(AMETHYST));
        },
    );
    ui.add(
        ProgressBar::new(run.progress())
            .fill(AMETHYST)
            .desired_height(10.0)
            .corner_radius(5),
    );
    ui.add_space(8.0);
    details(ui, run);
}

/// The critical step that failed, which stopped the run.
fn halted(ui: &mut Ui, run: &Run, index: usize) {
    result_heading(ui, "The installation stopped", false);
    widgets::callout(
        ui,
        Tone::Error,
        format!("{} failed.", run.steps[index].status),
    );
    widgets::muted(
        ui,
        format!(
            "Windows wasn't marked as modified by {}: fix the problem, then run it again.",
            playbook::NAME
        ),
    );
    report(ui, run, index);
    details(ui, run);
}

/// The success of the run, with the steps that reported errors.
fn completed(ui: &mut Ui, run: &Run) {
    result_heading(ui, "Installation complete", true);
    widgets::muted(ui, "Restart Windows to finish applying the changes.");
    let issues: Vec<usize> = (0..run.steps.len())
        .filter(|&index| run.has_issue(index))
        .collect();
    if !issues.is_empty() {
        let text = match issues.len() {
            1 => "1 step reported errors".to_owned(),
            count => format!("{count} steps reported errors"),
        };
        CollapsingHeader::new(text).show(ui, |ui| {
            for index in issues {
                report(ui, run, index);
            }
        });
    }
    details(ui, run);
}

/// The heading of a finished run, with a badge telling whether it succeeded.
fn result_heading(ui: &mut Ui, title: &str, success: bool) {
    let (icon, color) = if success {
        (Icon::Check, MOSS)
    } else {
        (Icon::Cross, CHANTERELLE)
    };
    widgets::badge(ui, 24.0, icon, color, LINEN);
    ui.label(RichText::new(title).font(semibold(26.0)).color(INK));
}

/// What went wrong in a step.
fn report(ui: &mut Ui, run: &Run, index: usize) {
    let step = &run.steps[index];
    ui.add(Label::new(RichText::new(&step.name).font(semibold(15.0)).color(INK)).truncate());
    if run.has_failed(index)
        && let Some(result) = &run.results[index]
    {
        widgets::muted(ui, runner::describe(result));
    }
    let lines = run.report(index);
    if !lines.is_empty() {
        widgets::console(ui, |ui| {
            for line in lines {
                widgets::console_line(ui, line);
            }
        });
    }
}

/// The whole output of the run, collapsed by default.
fn details(ui: &mut Ui, run: &Run) {
    CollapsingHeader::new("Details").show(ui, |ui| {
        widgets::console(ui, |ui| {
            let row_height = ui.text_style_height(&TextStyle::Monospace);
            ScrollArea::vertical()
                .id_salt("output")
                .max_height(220.0)
                .auto_shrink([false, true])
                .stick_to_bottom(true)
                .show_rows(ui, row_height, run.output.len(), |ui, rows| {
                    for line in &run.output[rows] {
                        widgets::console_line(ui, line);
                    }
                });
        });
    });
}
