import 'package:sav_design_system/src/painting/sav_squircle.dart';

/// Spacing steps, on a 4dp grid.
abstract final class SavSpacing {
  /// 4dp.
  static const double xs = 4;

  /// 8dp.
  static const double sm = 8;

  /// 10dp — the gap between a button's label and its adornments.
  static const double button = 10;

  /// 12dp.
  static const double md = 12;

  /// 16dp.
  static const double lg = 16;

  /// 24dp.
  static const double xl = 24;

  /// 32dp.
  static const double xxl = 32;
}

/// Corner-shape tokens.
///
/// Sav surfaces are squircles rather than rounded rectangles, so the token is
/// a smoothing preset rather than a radius: `SavSquircle` derives the actual
/// radii from the shape's size. See `SavSquircle` for why.
abstract final class SavShape {
  /// Smoothing preset for buttons.
  ///
  /// The Sav button is drawn at the `figma-squircle` plugin's maximum, which
  /// makes the outer radius exactly half the shorter side.
  static const int buttonSmoothing = SavSquircle.maxSmoothing;
}

/// Fixed sizes taken from the component specs.
abstract final class SavSizes {
  /// Height of a standard button.
  static const double buttonHeight = 48;

  /// Reference width of a standard button in Figma.
  ///
  /// Buttons are normally full-width; this is the size the design was drawn at
  /// and what the golden tests pin.
  static const double buttonReferenceWidth = 329;

  /// Height of an action button.
  static const double actionButtonHeight = 40;

  /// Width the action button is drawn at in Figma.
  ///
  /// Used as its minimum width: the component is a fixed 148dp in the design,
  /// with the label centred in it, so a short label should not collapse the
  /// button. It still grows for longer labels.
  static const double actionButtonReferenceWidth = 148;

  /// Diameter of the in-button loading spinner.
  static const double spinnerSize = 20;

  /// Diameter of the spinner inside an action button.
  static const double actionSpinnerSize = 18;

  /// The spinner's arc radius, as a fraction of its overall size.
  ///
  /// Figma draws `r = 8.3333` in a 20dp spinner and `r = 7.5` in an 18dp one —
  /// both exactly `5/12`. The remainder is deliberate breathing room, so the
  /// radius is a proportion of the box rather than something derived from the
  /// stroke width.
  static const double spinnerRadiusRatio = 5 / 12;

  /// Minimum interactive target, per WCAG 2.2 target-size guidance.
  static const double minTapTarget = 48;
}

/// Motion tokens.
abstract final class SavDurations {
  /// Press / hover state transitions.
  static const Duration stateChange = Duration(milliseconds: 150);

  /// One full rotation of the loading spinner.
  static const Duration spinnerRotation = Duration(milliseconds: 1000);
}
