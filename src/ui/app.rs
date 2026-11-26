//! The state of the wizard and the navigation between its screens.
//!
//! The steps are listed on the left, the current screen is in the middle, and its actions are at
//! the bottom.

use std::sync::mpsc::Receiver;

use egui::{CornerRadius, Frame, Margin, RichText, ScrollArea, Sides, Ui, ViewportCommand};

use crate::playbook::options::{Options, PAGES};
use crate::playbook::{self, payload};
use crate::requirements::{self, Fix, Requirement, Status};
use crate::runner::{Run, State};
use crate::system;
use crate::ui::screens;
use crate::ui::theme::{self, DEEP_VIOLET, LINEN, NIGHT, semibold};
use crate::ui::widgets::{self, BUTTON_HEIGHT, StepState};

/// The width of the list of steps.
const SIDEBAR_WIDTH: f32 = 232.0;
/// The horizontal margin of the screens and of their actions.
const MARGIN: i8 = 40;

/// A screen of the wizard.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
enum WizardScreen {
    Welcome,
    Requirements,
    /// An option page, by index in [`PAGES`].
    Page(usize),
    Review,
    Run,
}

/// What the user asked for, by clicking a button.
#[derive(Clone, Copy)]
enum UserAction {
    Back,
    Next,
    CheckAgain,
    Fix(Fix),
    OpenLog,
    Restart,
    Close,
}

/// The wizard, run by [`eframe`](https://docs.rs/eframe).
pub struct App {
    screen: WizardScreen,
    options: Options,
    requirements: Vec<Requirement>,
    /// Receives the requirements while they're checked.
    checking: Option<Receiver<Vec<Requirement>>>,
    /// Why the last fix failed.
    fix_error: Option<String>,
    run: Option<Run>,
}

impl App {
    /// Sets the window up and opens the welcome screen.
    pub fn new(cc: &eframe::CreationContext) -> Self {
        system::set_window_icon(cc);
        theme::apply(&cc.egui_ctx);
        Self {
            screen: WizardScreen::Welcome,
            options: Options::default(),
            requirements: Vec::new(),
            checking: None,
            fix_error: None,
            run: None,
        }
    }

    /// Starts checking the requirements again, discarding the previous results.
    fn check_requirements(&mut self, ctx: &egui::Context) {
        self.requirements.clear();
        self.fix_error = None;
        self.checking = Some(requirements::check(ctx.clone()));
    }

    /// Whether the requirements were checked and none is unmet.
    fn requirements_met(&self) -> bool {
        self.checking.is_none()
            && !self.requirements.is_empty()
            && self
                .requirements
                .iter()
                .all(|requirement| requirement.status != Status::Unmet)
    }

    /// Where the run stands, once started.
    fn run_state(&self) -> Option<State> {
        self.run.as_ref().map(Run::state)
    }

    /// The first visible option page after `after`, or the review after the last one.
    fn next_page(&self, after: Option<usize>) -> WizardScreen {
        let first = after.map_or(0, |index| index + 1);
        (first..PAGES.len())
            .find(|&index| self.options.is_visible(&PAGES[index]))
            .map_or(WizardScreen::Review, WizardScreen::Page)
    }

    /// The last visible option page before `before`, or the requirements before the first one.
    fn previous_page(&self, before: usize) -> WizardScreen {
        (0..before)
            .rev()
            .find(|&index| self.options.is_visible(&PAGES[index]))
            .map_or(WizardScreen::Requirements, WizardScreen::Page)
    }

    /// The steps listed in the sidebar, which depend on the visible option pages.
    fn steps(&self) -> Vec<(&'static str, WizardScreen)> {
        let pages = PAGES
            .iter()
            .enumerate()
            .filter(|(_, page)| self.options.is_visible(page))
            .map(|(index, page)| (page.title, WizardScreen::Page(index)));
        [
            ("Welcome", WizardScreen::Welcome),
            ("Requirements", WizardScreen::Requirements),
        ]
        .into_iter()
        .chain(pages)
        .chain([("Review", WizardScreen::Review), ("Install", WizardScreen::Run)])
        .collect()
    }

    /// Goes to the next screen, starting what it needs.
    fn forward(&mut self, ctx: &egui::Context) {
        self.screen = match self.screen {
            WizardScreen::Welcome => {
                self.check_requirements(ctx);
                WizardScreen::Requirements
            }
            WizardScreen::Requirements => self.next_page(None),
            WizardScreen::Page(index) => self.next_page(Some(index)),
            WizardScreen::Review => {
                self.run = Some(Run::start(&self.options.applied(), ctx.clone()));
                WizardScreen::Run
            }
            WizardScreen::Run => WizardScreen::Run,
        };
    }

    /// Goes back to the previous screen.
    fn back(&mut self) {
        self.screen = match self.screen {
            WizardScreen::Requirements => WizardScreen::Welcome,
            WizardScreen::Page(index) => self.previous_page(index),
            WizardScreen::Review => self.previous_page(PAGES.len()),
            screen => screen,
        };
    }

    /// Carries out what the user asked for.
    fn act(&mut self, action: UserAction, ctx: &egui::Context) {
        match action {
            UserAction::Back => self.back(),
            UserAction::Next => self.forward(ctx),
            UserAction::CheckAgain => self.check_requirements(ctx),
            UserAction::Fix(fix) => {
                self.fix_error = requirements::fix(fix).err().map(|error| error.to_string());
                // The other fixes happen outside the wizard, the user checks again once done
                if matches!(fix, Fix::DisableUcpd) && self.fix_error.is_none() {
                    self.check_requirements(ctx);
                }
            }
            UserAction::OpenLog => {
                let _ = system::open(&payload::log_file().to_string_lossy());
            }
            UserAction::Restart => {
                let _ = system::restart();
            }
            UserAction::Close => ctx.send_viewport_cmd(ViewportCommand::Close),
        }
    }

    /// The list of steps, `current` being the index of the current screen in `steps`.
    fn sidebar(&self, ui: &mut Ui, steps: &[(&str, WizardScreen)], current: usize) {
        let bottom = NIGHT.lerp_to_gamma(DEEP_VIOLET, 0.6);
        widgets::paint_gradient(ui, ui.max_rect(), CornerRadius::ZERO, [NIGHT, bottom]);
        let margin = Margin {
            left: 16,
            right: 16,
            top: 28,
            bottom: 20,
        };
        Frame::new().inner_margin(margin).show(ui, |ui| {
            ui.horizontal(|ui| {
                widgets::gem(ui, 26.0);
                ui.label(
                    RichText::new(playbook::TITLE)
                        .font(semibold(17.0))
                        .color(LINEN),
                );
            });
            ui.add_space(24.0);
            ui.spacing_mut().item_spacing.y = 4.0;
            let completed = self.run_state() == Some(State::Completed);
            for (index, (label, _)) in steps.iter().enumerate() {
                let state = if index < current || completed {
                    StepState::Done
                } else if index == current {
                    StepState::Current
                } else {
                    StepState::Upcoming
                };
                widgets::step(ui, label, state);
            }
        });
    }

    /// The buttons of the current screen: its other actions on the left, Back and the main
    /// action on the right.
    fn action_bar(&self, ui: &mut Ui) -> Option<UserAction> {
        let run_state = self.run_state();
        let (left, right) = Sides::new().height(BUTTON_HEIGHT).show(
            ui,
            |ui| match (self.screen, run_state) {
                (WizardScreen::Requirements, _) => widgets::button(ui, "Check again")
                    .clicked()
                    .then_some(UserAction::CheckAgain),
                (WizardScreen::Run, Some(State::Running)) => {
                    widgets::muted(ui, "Don't turn off your computer.");
                    None
                }
                (WizardScreen::Run, Some(State::Halted(_) | State::Completed)) => {
                    widgets::button(ui, "Open log")
                        .clicked()
                        .then_some(UserAction::OpenLog)
                }
                _ => None,
            },
            |ui| {
                // Laid out from the right: the main action comes first
                let (label, action, enabled) = match (self.screen, run_state) {
                    (WizardScreen::Run, Some(State::Running)) => return None,
                    (WizardScreen::Run, Some(State::Completed)) => ("Restart now", UserAction::Restart, true),
                    (WizardScreen::Run, _) => ("Close", UserAction::Close, true),
                    (WizardScreen::Requirements, _) => ("Next", UserAction::Next, self.requirements_met()),
                    (WizardScreen::Review, _) => ("Apply", UserAction::Next, true),
                    _ => ("Next", UserAction::Next, true),
                };
                let mut clicked = widgets::primary_button(ui, label, enabled)
                    .clicked()
                    .then_some(action);
                let secondary = match (self.screen, run_state) {
                    (WizardScreen::Run, Some(State::Completed)) => Some(("Later", UserAction::Close)),
                    (WizardScreen::Welcome | WizardScreen::Run, _) => None,
                    _ => Some(("Back", UserAction::Back)),
                };
                if let Some((label, action)) = secondary
                    && widgets::button(ui, label).clicked()
                {
                    clicked = Some(action);
                }
                clicked
            },
        );
        left.or(right)
    }

    /// The current screen, returning what the user asked for on it.
    fn show_screen(&mut self, ui: &mut Ui, overline: &str) -> Option<UserAction> {
        match self.screen {
            WizardScreen::Welcome => screens::welcome(ui, overline),
            WizardScreen::Requirements => {
                let fix = screens::requirements(
                    ui,
                    overline,
                    &self.requirements,
                    self.checking.is_some(),
                    self.fix_error.as_deref(),
                );
                return fix.map(UserAction::Fix);
            }
            WizardScreen::Page(index) => {
                screens::options_page(ui, overline, &PAGES[index], &mut self.options);
            }
            WizardScreen::Review => screens::review(ui, overline, &self.options),
            WizardScreen::Run => {
                if let Some(run) = &self.run {
                    screens::run(ui, overline, run);
                }
            }
        }
        None
    }
}

impl eframe::App for App {
    /// Applies what the background threads sent since the last frame.
    fn logic(&mut self, _ctx: &egui::Context, _frame: &mut eframe::Frame) {
        if let Some(run) = &mut self.run {
            run.update();
        }
        if let Some(requirements) = self
            .checking
            .as_ref()
            .and_then(|checking| checking.try_recv().ok())
        {
            self.requirements = requirements;
            self.checking = None;
        }
    }

    fn ui(&mut self, ui: &mut Ui, _frame: &mut eframe::Frame) {
        // Stopping in the middle would leave Windows half-modified
        let running = self.run_state() == Some(State::Running);
        if running && ui.input(|input| input.viewport().close_requested()) {
            ui.ctx().send_viewport_cmd(ViewportCommand::CancelClose);
        }

        let steps = self.steps();
        let current = steps
            .iter()
            .position(|&(_, screen)| screen == self.screen)
            .unwrap_or_default();
        let overline = format!("Step {} of {}", current + 1, steps.len());

        egui::Panel::left("steps")
            .exact_size(SIDEBAR_WIDTH)
            .resizable(false)
            .show_separator_line(false)
            .frame(Frame::NONE)
            .show(ui, |ui| self.sidebar(ui, &steps, current));
        let bar_action = egui::Panel::bottom("actions")
            .resizable(false)
            .frame(Frame::new().fill(LINEN).inner_margin(Margin {
                left: MARGIN,
                right: MARGIN,
                top: 14,
                bottom: 16,
            }))
            .show(ui, |ui| self.action_bar(ui))
            .inner;
        let mut screen_action = None;
        egui::CentralPanel::no_frame()
            .frame(Frame::new().fill(LINEN))
            .show(ui, |ui| {
                ScrollArea::vertical()
                    .id_salt(self.screen)
                    .auto_shrink(false)
                    .show(ui, |ui| {
                        let margin = Margin {
                            left: MARGIN,
                            right: MARGIN,
                            top: 32,
                            bottom: 16,
                        };
                        Frame::new().inner_margin(margin).show(ui, |ui| {
                            screen_action = self.show_screen(ui, &overline);
                        });
                    });
            });
        if let Some(action) = bar_action.or(screen_action) {
            self.act(action, ui.ctx());
        }
    }
}
