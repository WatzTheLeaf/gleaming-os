//! The wizard window, drawn with [`egui`](https://docs.rs/egui).
//!
//! [`App`](app::App) holds the state of the wizard and moves between the [`screens`], which are
//! made of the [`widgets`] and colors of the [`theme`].

pub mod app;
mod screens;
mod theme;
mod widgets;
