//! The building blocks of the screens, styled with the [`theme`](crate::ui::theme): buttons,
//! cards, callouts, choices and icons.

use egui::epaint::{PathShape, RectShape, TessellationOptions, Tessellator};
use egui::{
    Align2, Button, Color32, CornerRadius, CursorIcon, FontId, Frame, Label, Margin, Mesh, Painter,
    Pos2, Rect, Response, RichText, Role, Sense, Shape, Stroke, StrokeKind, TextStyle,
    TextWrapMode, Ui, WidgetInfo, WidgetText, pos2, vec2,
};

use crate::runner::Line;
use crate::ui::theme::{
    AMETHYST, CHANTERELLE, DEEP_VIOLET, GLASS, HONEY, INK, LILAC, LILAC_TINT, LIMESTONE, LINEN,
    MAUVE, MOSS, MUTED, NIGHT, RADIUS, SAGE, SURFACE, semibold,
};

/// The height of every button.
pub const BUTTON_HEIGHT: f32 = 36.0;
/// The minimum width of buttons.
const BUTTON_WIDTH: f32 = 104.0;

/// The heading of a screen: a small overline, such as "Step 2 of 8", above the title.
pub fn heading(ui: &mut Ui, overline: &str, title: &str) {
    ui.label(
        RichText::new(overline.to_uppercase())
            .font(semibold(12.0))
            .extra_letter_spacing(1.0)
            .color(AMETHYST),
    );
    ui.add_space(-6.0);
    ui.label(RichText::new(title).font(semibold(26.0)).color(INK));
}

/// Secondary text.
pub fn muted(ui: &mut Ui, text: impl Into<String>) -> Response {
    ui.label(RichText::new(text).color(MUTED))
}

/// A secondary button.
pub fn button(ui: &mut Ui, label: &str) -> Response {
    ui.add(Button::new(label).min_size(vec2(BUTTON_WIDTH, BUTTON_HEIGHT)))
}

/// The button of the main action of a screen.
pub fn primary_button(ui: &mut Ui, label: &str, enabled: bool) -> Response {
    ui.scope(|ui| {
        let widgets = &mut ui.visuals_mut().widgets;
        for (state, fill) in [
            (&mut widgets.inactive, AMETHYST),
            (&mut widgets.hovered, MAUVE),
            (&mut widgets.active, DEEP_VIOLET),
        ] {
            state.weak_bg_fill = fill;
            state.bg_stroke = Stroke::new(1.0, fill);
            state.fg_stroke.color = LINEN;
        }
        let text = RichText::new(label).font(semibold(15.0));
        ui.add_enabled(
            enabled,
            Button::new(text).min_size(vec2(BUTTON_WIDTH, BUTTON_HEIGHT)),
        )
    })
    .inner
}

/// A bordered panel, as wide as the available space.
pub fn card<R>(ui: &mut Ui, add_contents: impl FnOnce(&mut Ui) -> R) -> R {
    Frame::new()
        .fill(SURFACE)
        .stroke(Stroke::new(1.0, LIMESTONE))
        .corner_radius(RADIUS)
        .inner_margin(Margin::symmetric(18, 14))
        .show(ui, |ui| {
            ui.set_width(ui.available_width());
            add_contents(ui)
        })
        .inner
}

/// The kind of message of a [`callout`], which sets its colors.
#[derive(Clone, Copy)]
pub enum Tone {
    Note,
    Success,
    Warning,
    Error,
}

/// A highlighted message, with a colored bar on its left.
pub fn callout(ui: &mut Ui, tone: Tone, text: impl Into<WidgetText>) {
    let (fill, accent) = match tone {
        Tone::Note => (GLASS, AMETHYST),
        Tone::Success => (SURFACE.lerp_to_gamma(SAGE, 0.4), MOSS),
        Tone::Warning => (SURFACE.lerp_to_gamma(HONEY, 0.3), HONEY),
        Tone::Error => (SURFACE.lerp_to_gamma(CHANTERELLE, 0.22), CHANTERELLE),
    };
    let rect = Frame::new()
        .fill(fill)
        .corner_radius(8)
        .inner_margin(Margin {
            left: 18,
            right: 14,
            top: 10,
            bottom: 10,
        })
        .show(ui, |ui| {
            ui.set_width(ui.available_width());
            ui.label(text);
        })
        .response
        .rect;
    let bar = Rect::from_min_size(rect.min, vec2(4.0, rect.height()));
    let corners = CornerRadius {
        nw: 8,
        sw: 8,
        ..CornerRadius::ZERO
    };
    ui.painter().rect_filled(bar, corners, accent);
}

/// A symbol drawn on a [`badge`].
#[derive(Clone, Copy)]
pub enum Icon {
    Check,
    Cross,
    Exclamation,
}

/// A disc of color `fill`, with `icon` drawn on it in color `symbol`.
pub fn badge(ui: &mut Ui, radius: f32, icon: Icon, fill: Color32, symbol: Color32) {
    let (rect, _) = ui.allocate_exact_size(vec2(radius, radius) * 2.0, Sense::hover());
    paint_badge(ui.painter(), rect.center(), radius, icon, fill, symbol);
}

/// Paints a [`badge`] at `center`, without taking space in the layout.
fn paint_badge(
    painter: &Painter,
    center: Pos2,
    radius: f32,
    icon: Icon,
    fill: Color32,
    symbol: Color32,
) {
    painter.circle_filled(center, radius, fill);
    let stroke = Stroke::new((radius * 0.22).max(1.5), symbol);
    let point = |x: f32, y: f32| center + vec2(x, y) * radius * 0.5;
    match icon {
        Icon::Check => {
            let points = vec![point(-0.85, 0.05), point(-0.25, 0.6), point(0.85, -0.55)];
            painter.add(PathShape::line(points, stroke));
        }
        Icon::Cross => {
            painter.line_segment([point(-0.6, -0.6), point(0.6, 0.6)], stroke);
            painter.line_segment([point(-0.6, 0.6), point(0.6, -0.6)], stroke);
        }
        Icon::Exclamation => {
            painter.line_segment([point(0.0, -0.9), point(0.0, 0.25)], stroke);
            painter.circle_filled(point(0.0, 0.8), stroke.width * 0.6, symbol);
        }
    }
}

/// The indicator of a [`choice`].
#[derive(Clone, Copy)]
pub enum Indicator {
    Radio,
    Check,
}

/// A card as wide as the available space, selected by clicking anywhere on it.
pub fn choice(ui: &mut Ui, indicator: Indicator, selected: bool, text: &str) -> Response {
    let width = ui.available_width();
    let galley = WidgetText::from(text).into_galley(
        ui,
        Some(TextWrapMode::Wrap),
        width - 64.0,
        TextStyle::Body,
    );
    let height = (galley.size().y + 28.0).max(52.0);
    let (rect, response) = ui.allocate_exact_size(vec2(width, height), Sense::click());
    let role = match indicator {
        Indicator::Radio => Role::RadioButton,
        Indicator::Check => Role::CheckBox,
    };
    response.widget_info(|| WidgetInfo::selected(role, true, selected, text));
    let response = response.on_hover_cursor(CursorIcon::PointingHand);

    let painter = ui.painter();
    let (fill, border) = match (selected, response.hovered()) {
        (true, _) => (LILAC_TINT, Stroke::new(1.5, AMETHYST)),
        (false, true) => (SURFACE, Stroke::new(1.0, MAUVE)),
        (false, false) => (SURFACE, Stroke::new(1.0, LIMESTONE)),
    };
    painter.rect(rect, RADIUS, fill, border, StrokeKind::Inside);

    let center = pos2(rect.left() + 26.0, rect.center().y);
    let square = Rect::from_center_size(center, vec2(18.0, 18.0));
    let outline = Stroke::new(1.5, MUTED);
    match (indicator, selected) {
        (Indicator::Radio, true) => {
            painter.circle_filled(center, 9.0, AMETHYST);
            painter.circle_filled(center, 3.5, LINEN);
        }
        (Indicator::Radio, false) => {
            painter.circle_stroke(center, 8.5, outline);
        }
        (Indicator::Check, true) => {
            painter.rect_filled(square, 5, AMETHYST);
            paint_badge(painter, center, 9.0, Icon::Check, AMETHYST, LINEN);
        }
        (Indicator::Check, false) => {
            painter.rect_stroke(square, 5, outline, StrokeKind::Inside);
        }
    }
    let text_pos = pos2(rect.left() + 48.0, rect.center().y - galley.size().y / 2.0);
    painter.galley(text_pos, galley, INK);
    response
}

/// Paints a vertical gradient, in a rectangle that can have rounded corners.
pub fn paint_gradient(ui: &Ui, rect: Rect, corners: CornerRadius, [top, bottom]: [Color32; 2]) {
    let mut mesh = Mesh::default();
    Tessellator::new(
        ui.ctx().pixels_per_point(),
        TessellationOptions::default(),
        [1, 1],
        Vec::new(),
    )
    .tessellate_rect(&RectShape::filled(rect, corners, Color32::WHITE), &mut mesh);
    // The antialiasing vertices on the edge are transparent, their alpha is kept
    for vertex in &mut mesh.vertices {
        let t = ((vertex.pos.y - rect.top()) / rect.height()).clamp(0.0, 1.0);
        vertex.color = top
            .lerp_to_gamma(bottom, t)
            .gamma_multiply_u8(vertex.color.a());
    }
    ui.painter().add(mesh);
}

/// The brand mark: a cut amethyst.
pub fn gem(ui: &mut Ui, size: f32) {
    let (rect, _) = ui.allocate_exact_size(vec2(size, size), Sense::hover());
    let point = |x: f32, y: f32| rect.center() + vec2(x, y) * size * 0.5;
    let (left, right, bottom, middle) = (
        point(-1.0, -0.2),
        point(1.0, -0.2),
        point(0.0, 0.95),
        point(0.0, -0.2),
    );
    let crown = vec![left, point(-0.5, -0.75), point(0.5, -0.75), right];
    let painter = ui.painter();
    painter.add(Shape::convex_polygon(crown, LILAC, Stroke::NONE));
    painter.add(Shape::convex_polygon(
        vec![left, middle, bottom],
        MAUVE,
        Stroke::NONE,
    ));
    painter.add(Shape::convex_polygon(
        vec![middle, right, bottom],
        AMETHYST,
        Stroke::NONE,
    ));
}

/// Where a [`step`] of the sidebar stands, compared to the current screen.
#[derive(Clone, Copy, PartialEq, Eq)]
pub enum StepState {
    Done,
    Current,
    Upcoming,
}

/// A step of the sidebar.
pub fn step(ui: &mut Ui, label: &str, state: StepState) {
    let (rect, _) = ui.allocate_exact_size(vec2(ui.available_width(), 32.0), Sense::hover());
    let painter = ui.painter();
    let center = pos2(rect.left() + 18.0, rect.center().y);
    let faded = LILAC.gamma_multiply(0.45);
    let (font, color) = match state {
        StepState::Done => {
            paint_badge(painter, center, 8.0, Icon::Check, MAUVE, NIGHT);
            (FontId::proportional(14.5), LILAC)
        }
        StepState::Current => {
            painter.rect_filled(rect, 8, AMETHYST.gamma_multiply(0.55));
            painter.circle_filled(center, 8.0, LINEN);
            painter.circle_filled(center, 3.0, AMETHYST);
            (semibold(14.5), LINEN)
        }
        StepState::Upcoming => {
            painter.circle_stroke(center, 7.0, Stroke::new(1.5, faded));
            (FontId::proportional(14.5), faded)
        }
    };
    painter.text(
        pos2(rect.left() + 36.0, rect.center().y),
        Align2::LEFT_CENTER,
        label,
        font,
        color,
    );
}

/// A panel showing program output on a dark background.
pub fn console<R>(ui: &mut Ui, add_contents: impl FnOnce(&mut Ui) -> R) -> R {
    Frame::new()
        .fill(NIGHT)
        .corner_radius(8)
        .inner_margin(12)
        .show(ui, |ui| {
            ui.set_width(ui.available_width());
            ui.spacing_mut().item_spacing.y = 2.0;
            add_contents(ui)
        })
        .inner
}

/// A line of program output, highlighted when it was written to the standard error.
pub fn console_line(ui: &mut Ui, line: &Line) {
    let color = if line.error { HONEY } else { LILAC };
    ui.add(Label::new(RichText::new(&line.text).monospace().color(color)).truncate());
}
