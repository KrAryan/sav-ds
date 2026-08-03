import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sav_design_system/src/painting/sav_gradient.dart';
import 'package:sav_design_system/src/tokens/sav_colors.g.dart';
import 'package:sav_design_system/src/tokens/sav_dimensions.dart';
import 'package:sav_design_system/src/tokens/sav_typography.dart';

/// Which of the two button treatments to use.
enum SavButtonVariant {
  /// Dark, high-emphasis. The default call to action.
  primary,

  /// Light, lower-emphasis. Pairs with [primary] in a button row.
  secondary,
}

/// A blurred shadow, expressed the way Figma exports it.
///
/// Figma (and SVG) describe blur as a Gaussian **sigma**; Flutter's `BoxShadow`
/// takes a `blurRadius` and converts it with an approximation. Storing sigma
/// directly keeps the value identical to the design source.
@immutable
class SavShadow {
  /// Creates a shadow.
  const SavShadow({
    required this.color,
    required this.offset,
    required this.sigma,
  });

  /// Shadow colour, including its alpha.
  final Color color;

  /// Displacement from the shape.
  final Offset offset;

  /// Gaussian blur sigma, matching SVG's `stdDeviation`.
  final double sigma;

  /// A [MaskFilter] that applies this shadow's blur.
  MaskFilter get maskFilter => MaskFilter.blur(BlurStyle.normal, sigma);

  /// Linearly interpolates between two shadows.
  static SavShadow? lerp(SavShadow? a, SavShadow? b, double t) {
    if (identical(a, b)) return a;
    if (a == null) return b;
    if (b == null) return a;
    return SavShadow(
      color: Color.lerp(a.color, b.color, t)!,
      offset: Offset.lerp(a.offset, b.offset, t)!,
      sigma: lerpDouble(a.sigma, b.sigma, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavShadow &&
          other.color == color &&
          other.offset == offset &&
          other.sigma == sigma;

  @override
  int get hashCode => Object.hash(color, offset, sigma);
}

/// Everything that distinguishes one [SavButtonVariant] from the other.
@immutable
class SavButtonVariantStyle {
  /// Creates a variant style.
  const SavButtonVariantStyle({
    required this.fill,
    required this.border,
    required this.label,
    required this.disabledLabel,
    required this.disabledFillOpacity,
    required this.loadingFillOpacity,
    required this.spinnerTrack,
    required this.spinnerArc,
  });

  /// Surface gradient, at full opacity.
  final SavGradient fill;

  /// Gradient used for the 1dp outline.
  final SavGradient border;

  /// Label colour in the enabled state.
  final Color label;

  /// Label colour when the button is disabled.
  final Color disabledLabel;

  /// Opacity applied to [fill] when disabled.
  final double disabledFillOpacity;

  /// Opacity applied to [fill] while loading.
  final double loadingFillOpacity;

  /// Colour of the spinner's full-circle track.
  final Color spinnerTrack;

  /// Colour of the spinner's rotating arc.
  final Color spinnerArc;

  /// The fill to paint given the current interaction state.
  SavGradient resolveFill({required bool enabled, required bool loading}) {
    if (!enabled) return fill.scaleOpacity(disabledFillOpacity);
    if (loading) return fill.scaleOpacity(loadingFillOpacity);
    return fill;
  }

  /// The label colour to use given the current interaction state.
  Color resolveLabel({required bool enabled}) =>
      enabled ? label : disabledLabel;

  /// Linearly interpolates between two variant styles.
  static SavButtonVariantStyle lerp(
    SavButtonVariantStyle a,
    SavButtonVariantStyle b,
    double t,
  ) => SavButtonVariantStyle(
    fill: SavGradient.lerp(a.fill, b.fill, t)!,
    border: SavGradient.lerp(a.border, b.border, t)!,
    label: Color.lerp(a.label, b.label, t)!,
    disabledLabel: Color.lerp(a.disabledLabel, b.disabledLabel, t)!,
    disabledFillOpacity: lerpDouble(
      a.disabledFillOpacity,
      b.disabledFillOpacity,
      t,
    )!,
    loadingFillOpacity: lerpDouble(
      a.loadingFillOpacity,
      b.loadingFillOpacity,
      t,
    )!,
    spinnerTrack: Color.lerp(a.spinnerTrack, b.spinnerTrack, t)!,
    spinnerArc: Color.lerp(a.spinnerArc, b.spinnerArc, t)!,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavButtonVariantStyle &&
          other.fill == fill &&
          other.border == border &&
          other.label == label &&
          other.disabledLabel == disabledLabel &&
          other.disabledFillOpacity == disabledFillOpacity &&
          other.loadingFillOpacity == loadingFillOpacity &&
          other.spinnerTrack == spinnerTrack &&
          other.spinnerArc == spinnerArc;

  @override
  int get hashCode => Object.hash(
    fill,
    border,
    label,
    disabledLabel,
    disabledFillOpacity,
    loadingFillOpacity,
    spinnerTrack,
    spinnerArc,
  );
}

/// Every token needed to draw one Sav button surface.
///
/// Both `SavButton` and `SavActionButton` are the same surface at different
/// sizes — same squircle, gradients, grain, shadows and state rules — so they
/// share this class rather than duplicating it. [SavButtonTheme] holds one
/// instance per component.
@immutable
class SavButtonStyle {
  /// Creates a button style.
  const SavButtonStyle({
    required this.primary,
    required this.secondary,
    required this.labelStyle,
    required this.height,
    required this.minWidth,
    required this.horizontalPadding,
    required this.smoothing,
    required this.borderWidth,
    required this.dropShadow,
    required this.innerShadow,
    required this.spinnerSize,
    required this.spinnerStrokeWidth,
    required this.spinnerTrackStrokeWidth,
    required this.spinnerRotationDuration,
    required this.pressedOpacity,
    required this.stateChangeDuration,
    required this.focusRingColor,
    required this.focusRingWidth,
    required this.grainIntensity,
  });

  /// Styling for [SavButtonVariant.primary].
  final SavButtonVariantStyle primary;

  /// Styling for [SavButtonVariant.secondary].
  final SavButtonVariantStyle secondary;

  /// Text style for the label. Colour comes from the variant.
  final TextStyle labelStyle;

  /// Button height.
  final double height;

  /// Smallest width the button may shrink to when sizing to its content.
  ///
  /// Taken from the width the component is drawn at in Figma. Use `0` for a
  /// button that should hug its label exactly.
  final double minWidth;

  /// Padding on each side of the content.
  final double horizontalPadding;

  /// Corner-smoothing preset passed to the squircle.
  final int smoothing;

  /// Width of the gradient outline.
  final double borderWidth;

  /// Shadow cast outside the shape.
  final SavShadow dropShadow;

  /// Shadow drawn inside the shape's top-left edge.
  final SavShadow innerShadow;

  /// Diameter of the loading spinner.
  final double spinnerSize;

  /// Stroke width of the spinner's rotating arc.
  final double spinnerStrokeWidth;

  /// Stroke width of the spinner's static track.
  final double spinnerTrackStrokeWidth;

  /// Time for the spinner to complete one rotation.
  final Duration spinnerRotationDuration;

  /// Opacity applied while the button is held down.
  ///
  /// Figma does not define a pressed state, but a production button needs
  /// touch feedback. This is a code-side default — confirm the value with
  /// design, or override it here rather than at the call site.
  final double pressedOpacity;

  /// Duration of press and focus transitions.
  ///
  /// Also not specified in Figma; see [pressedOpacity].
  final Duration stateChangeDuration;

  /// Colour of the keyboard focus ring.
  ///
  /// Not specified in Figma. A visible focus indicator is required for
  /// keyboard accessibility, so one is provided rather than omitted.
  final Color focusRingColor;

  /// Stroke width of the keyboard focus ring.
  final double focusRingWidth;

  /// Multiplier on the film grain's strength.
  ///
  /// `1.0` reproduces the Figma layer exactly: its texture was measured at a
  /// mean alpha of 21/255 with the layer at 40% opacity, and both numbers are
  /// baked into the tile. That is a deliberately faint effect — roughly a 3%
  /// luminance modulation — so raise this if the grain reads too subtly on a
  /// given surface, or set `0` to drop it entirely.
  ///
  /// Values above `1` are clamped per channel by the underlying colour matrix.
  final double grainIntensity;

  /// The style for [variant].
  SavButtonVariantStyle variantStyle(SavButtonVariant variant) =>
      switch (variant) {
        SavButtonVariant.primary => primary,
        SavButtonVariant.secondary => secondary,
      };

  /// Returns a copy with the given fields replaced.
  SavButtonStyle copyWith({
    SavButtonVariantStyle? primary,
    SavButtonVariantStyle? secondary,
    TextStyle? labelStyle,
    double? height,
    double? minWidth,
    double? horizontalPadding,
    int? smoothing,
    double? borderWidth,
    SavShadow? dropShadow,
    SavShadow? innerShadow,
    double? spinnerSize,
    double? spinnerStrokeWidth,
    double? spinnerTrackStrokeWidth,
    Duration? spinnerRotationDuration,
    double? pressedOpacity,
    Duration? stateChangeDuration,
    Color? focusRingColor,
    double? focusRingWidth,
    double? grainIntensity,
  }) => SavButtonStyle(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    labelStyle: labelStyle ?? this.labelStyle,
    height: height ?? this.height,
    minWidth: minWidth ?? this.minWidth,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    smoothing: smoothing ?? this.smoothing,
    borderWidth: borderWidth ?? this.borderWidth,
    dropShadow: dropShadow ?? this.dropShadow,
    innerShadow: innerShadow ?? this.innerShadow,
    spinnerSize: spinnerSize ?? this.spinnerSize,
    spinnerStrokeWidth: spinnerStrokeWidth ?? this.spinnerStrokeWidth,
    spinnerTrackStrokeWidth:
        spinnerTrackStrokeWidth ?? this.spinnerTrackStrokeWidth,
    spinnerRotationDuration:
        spinnerRotationDuration ?? this.spinnerRotationDuration,
    pressedOpacity: pressedOpacity ?? this.pressedOpacity,
    stateChangeDuration: stateChangeDuration ?? this.stateChangeDuration,
    focusRingColor: focusRingColor ?? this.focusRingColor,
    focusRingWidth: focusRingWidth ?? this.focusRingWidth,
    grainIntensity: grainIntensity ?? this.grainIntensity,
  );

  /// Linearly interpolates between two styles.
  static SavButtonStyle lerp(SavButtonStyle a, SavButtonStyle b, double t) =>
      SavButtonStyle(
        primary: SavButtonVariantStyle.lerp(a.primary, b.primary, t),
        secondary: SavButtonVariantStyle.lerp(a.secondary, b.secondary, t),
        labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t)!,
        height: lerpDouble(a.height, b.height, t)!,
        minWidth: lerpDouble(a.minWidth, b.minWidth, t)!,
        horizontalPadding: lerpDouble(
          a.horizontalPadding,
          b.horizontalPadding,
          t,
        )!,
        smoothing: t < 0.5 ? a.smoothing : b.smoothing,
        borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t)!,
        dropShadow: SavShadow.lerp(a.dropShadow, b.dropShadow, t)!,
        innerShadow: SavShadow.lerp(a.innerShadow, b.innerShadow, t)!,
        spinnerSize: lerpDouble(a.spinnerSize, b.spinnerSize, t)!,
        spinnerStrokeWidth: lerpDouble(
          a.spinnerStrokeWidth,
          b.spinnerStrokeWidth,
          t,
        )!,
        spinnerTrackStrokeWidth: lerpDouble(
          a.spinnerTrackStrokeWidth,
          b.spinnerTrackStrokeWidth,
          t,
        )!,
        spinnerRotationDuration: t < 0.5
            ? a.spinnerRotationDuration
            : b.spinnerRotationDuration,
        pressedOpacity: lerpDouble(a.pressedOpacity, b.pressedOpacity, t)!,
        stateChangeDuration: t < 0.5
            ? a.stateChangeDuration
            : b.stateChangeDuration,
        focusRingColor: Color.lerp(a.focusRingColor, b.focusRingColor, t)!,
        focusRingWidth: lerpDouble(a.focusRingWidth, b.focusRingWidth, t)!,
        grainIntensity: lerpDouble(a.grainIntensity, b.grainIntensity, t)!,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavButtonStyle &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.labelStyle == labelStyle &&
          other.height == height &&
          other.minWidth == minWidth &&
          other.horizontalPadding == horizontalPadding &&
          other.smoothing == smoothing &&
          other.borderWidth == borderWidth &&
          other.dropShadow == dropShadow &&
          other.innerShadow == innerShadow &&
          other.spinnerSize == spinnerSize &&
          other.spinnerStrokeWidth == spinnerStrokeWidth &&
          other.spinnerTrackStrokeWidth == spinnerTrackStrokeWidth &&
          other.spinnerRotationDuration == spinnerRotationDuration &&
          other.pressedOpacity == pressedOpacity &&
          other.stateChangeDuration == stateChangeDuration &&
          other.focusRingColor == focusRingColor &&
          other.focusRingWidth == focusRingWidth &&
          other.grainIntensity == grainIntensity;

  @override
  int get hashCode => Object.hashAll(<Object>[
    primary,
    secondary,
    labelStyle,
    height,
    minWidth,
    horizontalPadding,
    smoothing,
    borderWidth,
    dropShadow,
    innerShadow,
    spinnerSize,
    spinnerStrokeWidth,
    spinnerTrackStrokeWidth,
    spinnerRotationDuration,
    pressedOpacity,
    stateChangeDuration,
    focusRingColor,
    focusRingWidth,
    grainIntensity,
  ]);
}

/// Theming for `SavButton` and `SavActionButton`.
///
/// Registered on [ThemeData.extensions] by `SavTheme`. Override it to restyle
/// buttons app-wide without forking a widget:
///
/// ```dart
/// final theme = Theme.of(context);
///
/// Theme(
///   data: theme.copyWith(
///     extensions: [
///       theme.extension<SavButtonTheme>()!.copyWith(
///         action: theme.extension<SavButtonTheme>()!.action.copyWith(
///           minWidth: 0,
///         ),
///       ),
///     ],
///   ),
///   child: child,
/// )
/// ```
@immutable
class SavButtonTheme extends ThemeExtension<SavButtonTheme> {
  /// Creates a button theme.
  const SavButtonTheme({required this.regular, required this.action});

  /// The shipped Sav button styling.
  factory SavButtonTheme.standard() =>
      SavButtonTheme(regular: _regular(), action: _action());

  /// The frame `SavButton` was drawn against in Figma.
  static const Size regularReferenceSize = Size(
    SavSizes.buttonReferenceWidth,
    SavSizes.buttonHeight,
  );

  /// The frame `SavActionButton` was drawn against in Figma.
  static const Size actionReferenceSize = Size(
    SavSizes.actionButtonReferenceWidth,
    SavSizes.actionButtonHeight,
  );

  /// Styling for `SavButton` — the full-width, 48dp call to action.
  final SavButtonStyle regular;

  /// Styling for `SavActionButton` — the compact, 40dp inline button.
  final SavButtonStyle action;

  @override
  SavButtonTheme copyWith({SavButtonStyle? regular, SavButtonStyle? action}) =>
      SavButtonTheme(
        regular: regular ?? this.regular,
        action: action ?? this.action,
      );

  @override
  SavButtonTheme lerp(covariant SavButtonTheme? other, double t) {
    if (other == null) return this;
    return SavButtonTheme(
      regular: SavButtonStyle.lerp(regular, other.regular, t),
      action: SavButtonStyle.lerp(action, other.action, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavButtonTheme &&
          other.regular == regular &&
          other.action == action;

  @override
  int get hashCode => Object.hash(regular, action);

  // --- Shipped values, transcribed from the Figma export ---

  /// Shadows are identical on both components.
  static const SavShadow _dropShadow = SavShadow(
    color: Color(0x0A1F1F1F), // Obsidian @ 4%
    offset: Offset(2, 2),
    sigma: 2,
  );

  static const SavShadow _innerShadow = SavShadow(
    color: Color(0x0A1F1F1F), // Obsidian @ 4%
    offset: Offset(-1, -1),
    sigma: 3,
  );

  static SavButtonStyle _regular() => SavButtonStyle(
    primary: const SavButtonVariantStyle(
      // A radial gradient whose transform is skewed almost flat, so it reads as
      // a diagonal sweep from the top-left rather than a burst.
      fill: SavRadialGradient(
        colors: <Color>[
          SavColors.savPrimaryObsidian,
          SavColors.savPrimarySlate,
          SavColors.savPrimaryObsidian,
        ],
        stops: <double>[0.2, 0.8, 1],
        referenceSize: regularReferenceSize,
        a: 327.952,
        b: 48,
        c: -328.131,
        d: 47.7204,
        e: 1.04778,
        f: 0,
      ),
      border: SavLinearGradient(
        colors: <Color>[
          SavColors.savPrimarySlate,
          SavColors.savPrimaryObsidian,
          Color(0x661F1F1F), // Obsidian @ 40%
          Color(0xCC1F1F1F), // Obsidian @ 80%
        ],
        stops: <double>[0.16, 0.32, 0.8, 1],
        referenceSize: regularReferenceSize,
        from: Offset.zero,
        to: Offset(13.7142, 93.9991),
      ),
      label: SavColors.savPrimaryLumen,
      // The primary label stays put when disabled; the surface carries the
      // state change instead.
      disabledLabel: SavColors.savPrimaryLumen,
      disabledFillOpacity: 0.4,
      loadingFillOpacity: 0.8,
      spinnerTrack: SavColors.savPrimarySterling,
      spinnerArc: SavColors.savPrimaryWhite,
    ),
    secondary: const SavButtonVariantStyle(
      fill: SavLinearGradient(
        colors: <Color>[
          SavColors.savPrimaryLumen,
          SavColors.savPrimaryWhite,
          SavColors.savPrimaryLumen,
        ],
        stops: <double>[0.2, 0.8, 1],
        referenceSize: regularReferenceSize,
        from: Offset.zero,
        to: Offset(13.7142, 93.9991),
      ),
      border: SavLinearGradient(
        colors: <Color>[
          SavColors.savPrimaryWhite,
          SavColors.savPrimaryLumen,
          Color(0x66FFFFFF), // White @ 40%
          Color(0xCCFFFFFF), // White @ 80%
        ],
        stops: <double>[0.16, 0.32, 0.8, 1],
        referenceSize: regularReferenceSize,
        from: Offset.zero,
        to: Offset(13.7142, 93.9991),
      ),
      label: SavColors.savPrimaryObsidian,
      disabledLabel: SavColors.savPrimarySterling,
      // The secondary surface is already light; only the label dims.
      disabledFillOpacity: 1,
      loadingFillOpacity: 1,
      spinnerTrack: SavColors.savPrimarySterling,
      spinnerArc: SavColors.savPrimarySlate,
    ),
    labelStyle: SavTypography.calloutMedium,
    height: SavSizes.buttonHeight,
    // Full-width by default, so there is nothing to hold it open.
    minWidth: 0,
    horizontalPadding: SavSpacing.xl,
    smoothing: SavShape.buttonSmoothing,
    borderWidth: 1,
    dropShadow: _dropShadow,
    innerShadow: _innerShadow,
    spinnerSize: SavSizes.spinnerSize,
    spinnerStrokeWidth: 1.8,
    spinnerTrackStrokeWidth: 1.67,
    spinnerRotationDuration: SavDurations.spinnerRotation,
    pressedOpacity: 0.9,
    stateChangeDuration: SavDurations.stateChange,
    focusRingColor: SavColors.wealthWeave600,
    focusRingWidth: 2,
    grainIntensity: 1,
  );

  static SavButtonStyle _action() => SavButtonStyle(
    primary: const SavButtonVariantStyle(
      // Same normalised geometry as the regular button, re-exported against
      // the smaller frame.
      fill: SavRadialGradient(
        colors: <Color>[
          SavColors.savPrimaryObsidian,
          SavColors.savPrimarySlate,
          SavColors.savPrimaryObsidian,
        ],
        stops: <double>[0.2, 0.8, 1],
        referenceSize: actionReferenceSize,
        a: 147.529,
        b: 40,
        c: -147.609,
        d: 39.767,
        e: 0.47134,
        f: 0,
      ),
      border: SavLinearGradient(
        colors: <Color>[
          SavColors.savPrimarySlate,
          SavColors.savPrimaryObsidian,
          Color(0x661F1F1F), // Obsidian @ 40%
          Color(0xCC1F1F1F), // Obsidian @ 80%
        ],
        stops: <double>[0.16, 0.32, 0.8, 1],
        referenceSize: actionReferenceSize,
        from: Offset.zero,
        to: Offset(20.1498, 74.5541),
      ),
      // Note this is White, not the Lumen the regular button uses.
      label: SavColors.savPrimaryWhite,
      disabledLabel: SavColors.savPrimaryWhite,
      disabledFillOpacity: 0.4,
      loadingFillOpacity: 0.8,
      spinnerTrack: SavColors.savPrimarySterling,
      spinnerArc: SavColors.savPrimaryWhite,
    ),
    secondary: const SavButtonVariantStyle(
      fill: SavLinearGradient(
        colors: <Color>[
          SavColors.savPrimaryLumen,
          SavColors.savPrimaryWhite,
          SavColors.savPrimaryLumen,
        ],
        stops: <double>[0.2, 0.8, 1],
        referenceSize: actionReferenceSize,
        from: Offset.zero,
        to: Offset(20.1498, 74.5541),
      ),
      border: SavLinearGradient(
        colors: <Color>[
          SavColors.savPrimaryWhite,
          SavColors.savPrimaryLumen,
          Color(0x66FFFFFF), // White @ 40%
          Color(0xCCFFFFFF), // White @ 80%
        ],
        stops: <double>[0.16, 0.32, 0.8, 1],
        referenceSize: actionReferenceSize,
        from: Offset.zero,
        to: Offset(20.1498, 74.5541),
      ),
      label: SavColors.savPrimaryObsidian,
      disabledLabel: SavColors.savPrimarySterling,
      disabledFillOpacity: 1,
      loadingFillOpacity: 1,
      spinnerTrack: SavColors.savPrimarySterling,
      spinnerArc: SavColors.savPrimarySlate,
    ),
    labelStyle: SavTypography.bodyBold,
    height: SavSizes.actionButtonHeight,
    minWidth: SavSizes.actionButtonReferenceWidth,
    horizontalPadding: SavSpacing.button,
    smoothing: SavShape.buttonSmoothing,
    borderWidth: 1,
    dropShadow: _dropShadow,
    innerShadow: _innerShadow,
    spinnerSize: SavSizes.actionSpinnerSize,
    spinnerStrokeWidth: 1.62,
    spinnerTrackStrokeWidth: 1.503,
    spinnerRotationDuration: SavDurations.spinnerRotation,
    pressedOpacity: 0.9,
    stateChangeDuration: SavDurations.stateChange,
    focusRingColor: SavColors.wealthWeave600,
    focusRingWidth: 2,
    grainIntensity: 1,
  );
}
