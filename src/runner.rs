//! Runs the plan on a background thread and tracks its progress for the interface.
//!
//! The background thread reports when each step starts, what it writes and how it ends through a
//! channel. Once per frame, [`Run::update`] applies these events and writes them to the log.

use std::fs::{self, File};
use std::io::{self, BufRead, BufReader, Write};
use std::path::Path;
use std::sync::mpsc::{self, Receiver, Sender};
use std::thread::{self, JoinHandle};
use std::time::{Duration, Instant};

use crate::playbook::options::Options;
use crate::playbook::payload;
use crate::playbook::plan::{self, Command, Step};
use crate::powershell;
use crate::system::privileges::{Child, Tokens};
use crate::system::{self, KeepAwake};

/// How long the output of an exited step is still read, as a process it started can keep the
/// pipes open.
const OUTPUT_GRACE_PERIOD: Duration = Duration::from_secs(2);

/// How many of its last lines are reported for a step that wrote no error.
const REPORT_LINES: usize = 10;

/// The exit code of a finished step, or why it couldn't start.
pub type StepResult = Result<u32, String>;

/// What the background thread reports.
enum Event {
    /// A step started, by index.
    Started(usize),
    Output(Line),
    /// A step ended, by index.
    Finished(usize, StepResult),
    /// The run couldn't start.
    Failed(String),
    /// The background thread ended.
    Done,
}

/// A line written by a step.
pub struct Line {
    /// The index of the step.
    pub step: usize,
    pub text: String,
    /// Whether it was written to the standard error.
    pub error: bool,
}

/// Where a run stands.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum State {
    /// No step ran, see [`Run::failure`].
    NotStarted,
    /// The steps are running.
    Running,
    /// A critical step failed, by index: the run stopped there.
    Halted(usize),
    /// Every step ran, though some may have reported errors.
    Completed,
}

/// A run of the plan, as the interface sees it.
pub struct Run {
    pub steps: Vec<Step>,
    /// The result of each finished step.
    pub results: Vec<Option<StepResult>>,
    /// Every line written by the steps so far.
    pub output: Vec<Line>,
    /// The index of the running step.
    pub current: Option<usize>,
    /// Why the run couldn't start.
    pub failure: Option<String>,
    finished: bool,
    /// How many lines each step wrote to the standard error.
    error_lines: Vec<usize>,
    events: Receiver<Event>,
    /// The log file, unless it couldn't be created.
    log: Option<File>,
    started: Instant,
}

impl Run {
    /// Starts running the steps for the selected options on a background thread.
    ///
    /// `ctx` is repainted on each event, for the interface to show it.
    pub fn start(options: &Options, ctx: egui::Context) -> Self {
        let steps = plan::steps();
        let (sender, events) = mpsc::channel();
        let reporter = Reporter { sender, ctx };
        let worker_steps = steps.clone();
        let option_names = options.names().collect::<Vec<_>>().join(";");
        thread::spawn(move || {
            if let Err(error) = run_steps(&worker_steps, &option_names, &reporter) {
                reporter.send(Event::Failed(error.to_string()));
            }
            reporter.send(Event::Done);
        });

        let log = fs::create_dir_all(payload::directory())
            .and_then(|()| File::create(payload::log_file()));
        Self {
            results: vec![None; steps.len()],
            error_lines: vec![0; steps.len()],
            steps,
            output: Vec::new(),
            current: None,
            failure: None,
            finished: false,
            events,
            log: log.ok(),
            started: Instant::now(),
        }
    }

    /// Applies the events received since the last call, and writes them to the log.
    pub fn update(&mut self) {
        while let Ok(event) = self.events.try_recv() {
            let entry = match event {
                Event::Started(index) => {
                    self.current = Some(index);
                    let step = &self.steps[index];
                    format!("{} > {} ({:?})", step.status, step.name, step.run_as)
                }
                Event::Output(line) => {
                    let entry = format!("  {} {}", if line.error { '!' } else { ' ' }, line.text);
                    self.error_lines[line.step] += usize::from(line.error);
                    self.output.push(line);
                    entry
                }
                Event::Finished(index, result) => {
                    let entry = format!("  = {}", describe(&result));
                    self.results[index] = Some(result);
                    entry
                }
                Event::Failed(error) => {
                    let entry = format!("Failed to start: {error}");
                    self.failure = Some(error);
                    entry
                }
                Event::Done => {
                    self.finished = true;
                    self.current = None;
                    "Done".to_owned()
                }
            };
            if let Some(log) = &mut self.log {
                let _ = writeln!(
                    log,
                    "[{:>7.1}s] {entry}",
                    self.started.elapsed().as_secs_f32()
                );
            }
        }
    }

    /// Where the run stands.
    pub fn state(&self) -> State {
        if self.failure.is_some() {
            State::NotStarted
        } else if !self.finished {
            State::Running
        } else if let Some(index) = self.halted_at() {
            State::Halted(index)
        } else {
            State::Completed
        }
    }

    /// The share of the work done, from 0 to 1, according to the weights of the steps.
    pub fn progress(&self) -> f32 {
        let total: u32 = self.steps.iter().map(|step| step.weight).sum();
        let done: u32 = self
            .steps
            .iter()
            .zip(&self.results)
            .filter(|(_, result)| result.is_some())
            .map(|(step, _)| step.weight)
            .sum();
        done as f32 / total.max(1) as f32
    }

    /// Whether the step ended with a non-zero exit code, or couldn't start.
    pub fn has_failed(&self, index: usize) -> bool {
        self.results[index]
            .as_ref()
            .is_some_and(|result| result != &Ok(0))
    }

    /// Whether the step failed or wrote errors.
    pub fn has_issue(&self, index: usize) -> bool {
        self.has_failed(index) || self.error_lines[index] > 0
    }

    /// The lines showing best what went wrong in a step: its errors, or its last lines when it
    /// wrote no error.
    pub fn report(&self, index: usize) -> Vec<&Line> {
        let lines: Vec<&Line> = self
            .output
            .iter()
            .filter(|line| line.step == index)
            .collect();
        match self.error_lines[index] {
            0 => lines[lines.len().saturating_sub(REPORT_LINES)..].to_vec(),
            _ => lines.into_iter().filter(|line| line.error).collect(),
        }
    }

    /// The critical step whose failure stopped the run.
    fn halted_at(&self) -> Option<usize> {
        (0..self.steps.len()).find(|&index| self.steps[index].critical && self.has_failed(index))
    }
}

/// Describes how a step ended, for the log and the interface.
pub fn describe(result: &StepResult) -> String {
    match result {
        Ok(code) => format!("exit code {code}"),
        Err(error) => format!("couldn't start: {error}"),
    }
}

/// Sends the events of the background thread, and wakes the interface up to show them.
#[derive(Clone)]
struct Reporter {
    sender: Sender<Event>,
    ctx: egui::Context,
}

impl Reporter {
    /// Sends an event and requests a repaint.
    fn send(&self, event: Event) {
        let _ = self.sender.send(event);
        self.ctx.request_repaint();
    }
}

/// Runs the steps in order, until the first critical failure, then deletes the extracted
/// playbook if every step ran.
///
/// # Errors
///
/// Returns an error when the privileges can't be acquired or the playbook can't be extracted,
/// before any step runs.
fn run_steps(steps: &[Step], options: &str, reporter: &Reporter) -> io::Result<()> {
    let tokens = Tokens::acquire()
        .map_err(|error| context("Couldn't get the required privileges", error))?;
    let root =
        payload::extract().map_err(|error| context("Couldn't extract the playbook", error))?;
    let directory = root.join("Files");
    let prelude = prelude(&root, options);
    let _awake = KeepAwake::start();

    for (index, step) in steps.iter().enumerate() {
        reporter.send(Event::Started(index));
        let result = run_step(step, index, &tokens, &directory, &prelude, reporter)
            .map_err(|error| error.to_string());
        let halted = step.critical && result != Ok(0);
        reporter.send(Event::Finished(index, result));
        if halted {
            return Ok(());
        }
    }

    let _ = fs::remove_dir_all(root);
    Ok(())
}

/// The PowerShell code run before each PowerShell step: it gives the selected options to
/// `Test-Option` and imports `Playbook.psm1`, whose functions replace the playbook's actions.
fn prelude(root: &Path, options: &str) -> String {
    let module = root
        .join("Playbook.psm1")
        .display()
        .to_string()
        .replace('\'', "''");
    format!("$env:PLAYBOOK_OPTIONS = '{options}'\nImport-Module '{module}'\n")
}

/// Prefixes an error with what failed.
fn context(message: &str, error: io::Error) -> io::Error {
    io::Error::new(error.kind(), format!("{message}: {error}"))
}

/// Runs a step, forwarding its output, and returns its exit code.
fn run_step(
    step: &Step,
    index: usize,
    tokens: &Tokens,
    directory: &Path,
    prelude: &str,
    reporter: &Reporter,
) -> io::Result<u32> {
    let command_line = match &step.command {
        Command::StartShell => return tokens.start_shell(step.run_as).map(|()| 0),
        Command::Program(command_line) => command_line.clone(),
        Command::PowerShell(script) => powershell::command_line(&format!("{prelude}{script}")),
    };
    let Child {
        process,
        stdout,
        stderr,
    } = tokens.spawn(step.run_as, &command_line, directory)?;
    let readers = [
        forward(stdout, index, false, reporter),
        forward(stderr, index, true, reporter),
    ];
    let exit_code = process.wait()?;

    let deadline = Instant::now() + OUTPUT_GRACE_PERIOD;
    while readers.iter().any(|reader| !reader.is_finished()) && Instant::now() < deadline {
        thread::sleep(Duration::from_millis(10));
    }
    Ok(exit_code)
}

/// Sends each line of a step's output or error stream, from a thread that ends with the stream.
fn forward(output: File, step: usize, error: bool, reporter: &Reporter) -> JoinHandle<()> {
    let reporter = reporter.clone();
    thread::spawn(move || {
        for bytes in BufReader::new(output).split(b'\n').map_while(Result::ok) {
            let text = system::decode_console(&bytes);
            // Progress bars rewrite their line with carriage returns, only their last state is kept
            if let Some(text) = text.split('\r').rev().find(|part| !part.trim().is_empty()) {
                reporter.send(Event::Output(Line {
                    step,
                    text: text.trim_end().to_owned(),
                    error,
                }));
            }
        }
    })
}
