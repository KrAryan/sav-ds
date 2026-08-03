import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sav_design_system/src/tokens/sav_colors.g.dart';
import 'package:sav_design_system/src/tokens/sav_dimensions.dart';
import 'package:sav_design_system/src/tokens/sav_typography.dart';

/// The two sizes `SavLabelButton` comes in.
enum SavLabelButtonSize {
  /// 16/20 text. The default.
  regular,

  /// 14/18 text, for denser contexts.
  small,
}

/// Theming for `SavLabelButton`.
///
/// Kept separate from `SavButtonTheme` because a label button is a different
/// kind of control: it has no surface, so none of the gradient, grain, shadow
/// or spinner tokens apply to it.
@immutable
class SavLabelButtonTheme extends ThemeExtension<SavLabelButtonTheme> {
  /// Creates a label button theme.
  const SavLabelButtonTheme({
    required this.regularTextStyle,
    required this.smallTextStyle,
    required this.label,
    required this.disabledLabel,
    required this.decorationStyle,
    required this.pressedOpacity,
    required this.stateChangeDuration,
    required this.focusRingColor,
    required this.focusRingWidth,
    required this.focusRingRadius,
    required this.minTapTarget,
  });

  /// The shipped Sav label button styling.
  factory SavLabelButtonTheme.standard() => SavLabelButtonTheme(
    regularTextStyle: SavTypography.calloutMedium,
    smallTextStyle: SavTypography.bodyBold,
    label: SavColors.savPrimaryObsidian,
    // Slate, not the Sterling the surface buttons dim their labels to. The
    // label button sits on the page background rather than on a dimmed
    // surface, so it needs the extra contrast.
    disabledLabel: SavColors.savPrimarySlate,
    decorationStyle: TextDecorationStyle.dotted,
    pressedOpacity: 0.9,
    stateChangeDuration: SavDurations.stateChange,
    focusRingColor: SavColors.wealthWeave600,
    focusRingWidth: 2,
    focusRingRadius: 4,
    minTapTarget: SavSizes.minTapTarget,
  );

  /// Text style for [SavLabelButtonSize.regular] — `Callout/Medium`.
  final TextStyle regularTextStyle;

  /// Text style for [SavLabelButtonSize.small] — `Body/Bold`.
  final TextStyle smallTextStyle;

  /// Label colour in the enabled state.
  final Color label;

  /// Label colour when the button is disabled.
  final Color disabledLabel;

  /// Style of the underline.
  ///
  /// Figma draws a dotted rule, not a solid one — an easy detail to lose.
  final TextDecorationStyle decorationStyle;

  /// Opacity applied while the button is held down.
  ///
  /// Not defined in Figma; matches the surface buttons so the family behaves
  /// consistently.
  final double pressedOpacity;

  /// Duration of press and focus transitions.
  final Duration stateChangeDuration;

  /// Colour of the keyboard focus ring.
  final Color focusRingColor;

  /// Stroke width of the keyboard focus ring.
  final double focusRingWidth;

  /// Corner radius of the keyboard focus ring.
  ///
  /// A plain rounded rectangle rather than the squircle used by the surface
  /// buttons: there is no surface here for it to trace.
  final double focusRingRadius;

  /// Minimum height of the interactive area.
  ///
  /// The text itself is only 18-20dp tall, far below any accessible target, so
  /// the control pads itself out to this unless told otherwise. See
  /// `SavLabelButton.expandTapTarget`.
  final double minTapTarget;

  /// The text style for [size].
  TextStyle textStyleFor(SavLabelButtonSize size) => switch (size) {
    SavLabelButtonSize.regular => regularTextStyle,
    SavLabelButtonSize.small => smallTextStyle,
  };

  /// The fully resolved text style for [size] in the given state, including
  /// the dotted underline.
  TextStyle resolve(SavLabelButtonSize size, {required bool enabled}) {
    final color = enabled ? label : disabledLabel;
    return textStyleFor(size).copyWith(
      color: color,
      decoration: TextDecoration.underline,
      decorationStyle: decorationStyle,
      // Matching Figma's `text-decoration-thickness: from-font`: Flutter's
      // thickness is a multiplier on the font's own, so 1.0 is exactly that.
      decorationThickness: 1,
      decorationColor: color,
    );
  }

  @override
  SavLabelButtonTheme copyWith({
    TextStyle? regularTextStyle,
    TextStyle? smallTextStyle,
    Color? label,
    Color? disabledLabel,
    TextDecorationStyle? decorationStyle,
    double? pressedOpacity,
    Duration? stateChangeDuration,
    Color? focusRingColor,
    double? focusRingWidth,
    double? focusRingRadius,
    double? minTapTarget,
  }) => SavLabelButtonTheme(
    regularTextStyle: regularTextStyle ?? this.regularTextStyle,
    smallTextStyle: smallTextStyle ?? this.smallTextStyle,
    label: label ?? this.label,
    disabledLabel: disabledLabel ?? this.disabledLabel,
    decorationStyle: decorationStyle ?? this.decorationStyle,
    pressedOpacity: pressedOpacity ?? this.pressedOpacity,
    stateChangeDuration: stateChangeDuration ?? this.stateChangeDuration,
    focusRingColor: focusRingColor ?? this.focusRingColor,
    focusRingWidth: focusRingWidth ?? this.focusRingWidth,
    focusRingRadius: focusRingRadius ?? this.focusRingRadius,
    minTapTarget: minTapTarget ?? this.minTapTarget,
  );

  @override
  SavLabelButtonTheme lerp(covariant SavLabelButtonTheme? other, double t) {
    if (other == null) return this;
    return SavLabelButtonTheme(
      regularTextStyle: TextStyle.lerp(
        regularTextStyle,
        other.regularTextStyle,
        t,
      )!,
      smallTextStyle: TextStyle.lerp(smallTextStyle, other.smallTextStyle, t)!,
      label: Color.lerp(label, other.label, t)!,
      disabledLabel: Color.lerp(disabledLabel, other.disabledLabel, t)!,
      decorationStyle: t < 0.5 ? decorationStyle : other.decorationStyle,
      pressedOpacity: lerpDouble(pressedOpacity, other.pressedOpacity, t)!,
      stateChangeDuration: t < 0.5
          ? stateChangeDuration
          : other.stateChangeDuration,
      focusRingColor: Color.lerp(focusRingColor, other.focusRingColor, t)!,
      focusRingWidth: lerpDouble(focusRingWidth, other.focusRingWidth, t)!,
      focusRingRadius: lerpDouble(focusRingRadius, other.focusRingRadius, t)!,
      minTapTarget: lerpDouble(minTapTarget, other.minTapTarget, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavLabelButtonTheme &&
          other.regularTextStyle == regularTextStyle &&
          other.smallTextStyle == smallTextStyle &&
          other.label == label &&
          other.disabledLabel == disabledLabel &&
          other.decorationStyle == decorationStyle &&
          other.pressedOpacity == pressedOpacity &&
          other.stateChangeDuration == stateChangeDuration &&
          other.focusRingColor == focusRingColor &&
          other.focusRingWidth == focusRingWidth &&
          other.focusRingRadius == focusRingRadius &&
          other.minTapTarget == minTapTarget;

  @override
  int get hashCode => Object.hashAll(<Object>[
    regularTextStyle,
    smallTextStyle,
    label,
    disabledLabel,
    decorationStyle,
    pressedOpacity,
    stateChangeDuration,
    focusRingColor,
    focusRingWidth,
    focusRingRadius,
    minTapTarget,
  ]);
}
