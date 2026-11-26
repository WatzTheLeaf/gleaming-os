//! The `playbook` folder, embedded in the executable and extracted when the run starts.

use std::path::PathBuf;
use std::{env, fs, io};

use include_dir::{Dir, include_dir};

/// The `playbook` folder of the repository.
static PLAYBOOK: Dir = include_dir!("$CARGO_MANIFEST_DIR/playbook");

/// The folder of GleamingOS on the computer: `%ProgramData%\gleaming-os`.
///
/// It is kept out of the temporary folders, which the playbook empties while running.
pub fn directory() -> PathBuf {
    let program_data = env::var_os("ProgramData").unwrap_or_else(|| r"C:\ProgramData".into());
    PathBuf::from(program_data).join(env!("CARGO_PKG_NAME"))
}

/// The log of the last run, in [`directory`].
pub fn log_file() -> PathBuf {
    directory().join(concat!(env!("CARGO_PKG_NAME"), ".log"))
}

/// Extracts the playbook into [`directory`], replacing any previous extraction, and returns
/// its root.
///
/// # Errors
///
/// Returns an error when a file can't be deleted or written.
pub fn extract() -> io::Result<PathBuf> {
    let root = directory().join("playbook");
    if root.exists() {
        fs::remove_dir_all(&root)?;
    }
    fs::create_dir_all(&root)?;
    PLAYBOOK.extract(&root)?;
    Ok(root)
}
