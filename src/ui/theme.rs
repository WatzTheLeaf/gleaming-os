//! The look of the wizard: the palette, the fonts and the egui style built from them.
//!
//! Every color of the interface comes from here, so changing the look doesn't touch the screens.
//! The palette's colors keep their French names from the GleamingOS reference, in italics.

use std::path::{Path, PathBuf};
use std::sync::Arc;
use std::{env, fs};

use egui::{
    Color32, Context, CornerRadius, FontData, FontDefinitions, FontFamily, FontId, Stroke,
    TextStyle, Visuals, vec2,
};

/// *Night*: the background of the sidebar and of the consoles.
pub const NIGHT: Color32 = Color32::from_rgb(0x1E, 0x12, 0x36);
/// *Deep purple*: the pressed primary button and the bottom of the sidebar.
pub const DEEP_VIOLET: Color32 = Color32::from_rgb(0x3A, 0x24, 0x70);
/// *Amethyst*: the main color, for primary buttons, selections and progress.
pub const AMETHYST: Color32 = Color32::from_rgb(0x5B, 0x3B, 0xA6);
/// *Mauve*: hovered borders.
pub const MAUVE: Color32 = Color32::from_rgb(0x7E, 0x5C, 0xCB);
/// *Lilac*: light text on dark backgrounds, and the track of the progress bar.
pub const LILAC: Color32 = Color32::from_rgb(0xD6, 0xC8, 0xF5);

/// *Linen*: the background of the screens.
pub const LINEN: Color32 = Color32::from_rgb(0xF5, 0xF0, 0xE6);
/// *Glass*: the background of notes.
pub const GLASS: Color32 = Color32::from_rgb(0xDC, 0xEB, 0xEA);
/// *Limestone*: borders.
pub const LIMESTONE: Color32 = Color32::from_rgb(0xCC, 0xC6, 0xBA);

/// *Moss*: success.
pub const MOSS: Color32 = Color32::from_rgb(0x5C, 0x7A, 0x4C);
/// *Sage*: the tint of success messages.
pub const SAGE: Color32 = Color32::from_rgb(0xA3, 0xB1, 0x8E);

/// *Honey*: warnings, and error lines of the consoles.
pub const HONEY: Color32 = Color32::from_rgb(0xED, 0xBE, 0x5E);
/// *Chanterelle*: errors.
pub const CHANTERELLE: Color32 = Color32::from_rgb(0xC2, 0x7F, 0x45);

/// Text, the ink of the palette.
pub const INK: Color32 = Color32::from_rgb(0x2A, 0x1E, 0x45);
/// Secondary text, ink faded into linen.
pub const MUTED: Color32 = Color32::from_rgb(0x6B, 0x61, 0x78);
/// Cards, a lighter linen.
pub const SURFACE: Color32 = Color32::from_rgb(0xFC, 0xFA, 0xF6);
/// Selected and hovered backgrounds, frosted lilac faded into linen.
pub const LILAC_TINT: Color32 = Color32::from_rgb(0xEE, 0xE7, 0xF8);

/// The corner radius of cards and choices.
pub const RADIUS: CornerRadius = CornerRadius::same(10);

/// The name of the semibold font family.
const SEMIBOLD: &str = "semibold";

/// A semibold font: Segoe UI Semibold, or the regular font when it's missing.
pub fn semibold(size: f32) -> FontId {
    FontId::new(size, FontFamily::Name(SEMIBOLD.into()))
}

/// Applies the theme, which stays light whatever the Windows theme.
pub fn apply(ctx: &Context) {
    install_fonts(ctx);
    ctx.all_styles_mut(|style| {
        style.visuals = visuals();
        style.text_styles = [
            (TextStyle::Small, FontId::proportional(12.5)),
            (TextStyle::Body, FontId::proportional(15.0)),
            (TextStyle::Button, FontId::proportional(15.0)),
            (TextStyle::Heading, semibold(26.0)),
            (TextStyle::Monospace, FontId::monospace(12.5)),
        ]
        .into();
        style.spacing.item_spacing = vec2(10.0, 10.0);
        style.spacing.button_padding = vec2(18.0, 7.0);
    });
}

/// The colors of egui's widgets.
fn visuals() -> Visuals {
    let mut visuals = Visuals::light();
    visuals.panel_fill = LINEN;
    visuals.window_fill = SURFACE;
    // The track of the progress bar
    visuals.extreme_bg_color = LILAC;
    visuals.faint_bg_color = SURFACE;
    visuals.weak_text_color = Some(MUTED);
    visuals.hyperlink_color = LILAC;
    visuals.warn_fg_color = CHANTERELLE;
    visuals.error_fg_color = CHANTERELLE;
    visuals.selection.bg_fill = AMETHYST;
    visuals.selection.stroke = Stroke::new(1.0, LINEN);

    // Secondary buttons by default, the primary one overrides them
    let widgets = &mut visuals.widgets;
    widgets.noninteractive.bg_stroke = Stroke::new(1.0, LIMESTONE);
    widgets.noninteractive.fg_stroke = Stroke::new(1.0, INK);
    for (state, fill, border) in [
        (&mut widgets.inactive, SURFACE, LIMESTONE),
        (&mut widgets.hovered, LILAC_TINT, MAUVE),
        (&mut widgets.active, LILAC, AMETHYST),
        (&mut widgets.open, LILAC_TINT, MAUVE),
    ] {
        state.weak_bg_fill = fill;
        state.bg_fill = fill;
        state.bg_stroke = Stroke::new(1.0, border);
        state.fg_stroke = Stroke::new(1.5, INK);
        state.corner_radius = CornerRadius::same(8);
        state.expansion = 0.0;
    }
    visuals
}

/// Puts the Windows 11 fonts, Segoe UI and Cascadia Mono, before egui's own fonts.
fn install_fonts(ctx: &Context) {
    let directory =
        PathBuf::from(env::var_os("WINDIR").unwrap_or_else(|| r"C:\Windows".into())).join("Fonts");
    let mut fonts = FontDefinitions::default();
    install(
        &mut fonts,
        &directory,
        FontFamily::Proportional,
        &["segoeui.ttf"],
    );
    install(
        &mut fonts,
        &directory,
        FontFamily::Monospace,
        &["CascadiaMono.ttf", "consola.ttf"],
    );
    // Falls back to the regular fonts when the semibold one is missing
    let regular = fonts.families[&FontFamily::Proportional].clone();
    let semibold = FontFamily::Name(SEMIBOLD.into());
    fonts.families.insert(semibold.clone(), regular);
    install(&mut fonts, &directory, semibold, &["seguisb.ttf"]);
    ctx.set_fonts(fonts);
}

/// Puts the first font file found among `files` first in the family.
fn install(fonts: &mut FontDefinitions, directory: &Path, family: FontFamily, files: &[&str]) {
    let found = files
        .iter()
        .find_map(|&file| Some((file, fs::read(directory.join(file)).ok()?)));
    if let Some((file, data)) = found {
        fonts
            .font_data
            .insert(file.into(), Arc::new(FontData::from_owned(data)));
        fonts
            .families
            .entry(family)
            .or_default()
            .insert(0, file.into());
    }
}
