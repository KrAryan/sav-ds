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

/// Theming for `SavButton`.
///
/// Registered on [ThemeData.extensions] by `SavTheme`. Override it to restyle
/// buttons app-wide without forking the widget:
///
/// ```dart
/// Theme(
///   data: theme.copyWith(
///     extensions: [
///       theme.extension<SavButtonTheme>()!.copyWith(height: 56),
///     ],
///   ),
///   child: child,
/// )
/// ```
@immutable
class SavButtonTheme extends ThemeExtension<SavButtonTheme> {
  /// Creates a button theme.
  const SavButtonTheme({
    required this.primary,
    required this.secondary,
    required this.labelStyle,
    required this.height,
    required this.horizontalPadding,
    required this.gap,
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
  });

  /// The shipped Sav button styling.
  factory SavButtonTheme.standard() => SavButtonTheme(
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
        referenceSize: referenceSize,
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
        referenceSize: referenceSize,
        from: Offset.zero,
        to: Offset(13.7142, 93.9991),
      ),
      label: SavColors.savPrimaryLumen,
      // The primary label stays Lumen when disabled; the surface carries the
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
        referenceSize: referenceSize,
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
        referenceSize: referenceSize,
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
    horizontalPadding: SavSpacing.xl,
    gap: SavSpacing.button,
    smoothing: SavShape.buttonSmoothing,
    borderWidth: 1,
    dropShadow: const SavShadow(
      color: Color(0x0A1F1F1F), // Obsidian @ 4%
      offset: Offset(2, 2),
      sigma: 2,
    ),
    innerShadow: const SavShadow(
      color: Color(0x0A1F1F1F), // Obsidian @ 4%
      offset: Offset(-1, -1),
      sigma: 3,
    ),
    spinnerSize: SavSizes.spinnerSize,
    spinnerStrokeWidth: 1.8,
    spinnerTrackStrokeWidth: 1.67,
    spinnerRotationDuration: SavDurations.spinnerRotation,
    pressedOpacity: 0.9,
    stateChangeDuration: SavDurations.stateChange,
    focusRingColor: SavColors.wealthWeave600,
    focusRingWidth: 2,
  );

  /// The frame the Sav button gradients were drawn against in Figma.
  static const Size referenceSize = Size(
    SavSizes.buttonReferenceWidth,
    SavSizes.buttonHeight,
  );

  /// Styling for [SavButtonVariant.primary].
  final SavButtonVariantStyle primary;

  /// Styling for [SavButtonVariant.secondary].
  final SavButtonVariantStyle secondary;

  /// Text style for the label. Colour comes from the variant.
  final TextStyle labelStyle;

  /// Button height.
  final double height;

  /// Padding on each side of the content.
  final double horizontalPadding;

  /// Gap between the label and any adornment.
  final double gap;

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

  /// The style for [variant].
  SavButtonVariantStyle styleFor(SavButtonVariant variant) => switch (variant) {
    SavButtonVariant.primary => primary,
    SavButtonVariant.secondary => secondary,
  };

  @override
  SavButtonTheme copyWith({
    SavButtonVariantStyle? primary,
    SavButtonVariantStyle? secondary,
    TextStyle? labelStyle,
    double? height,
    double? horizontalPadding,
    double? gap,
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
  }) => SavButtonTheme(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    labelStyle: labelStyle ?? this.labelStyle,
    height: height ?? this.height,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    gap: gap ?? this.gap,
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
  );

  @override
  SavButtonTheme lerp(covariant SavButtonTheme? other, double t) {
    if (other == null) return this;
    return SavButtonTheme(
      primary: SavButtonVariantStyle.lerp(primary, other.primary, t),
      secondary: SavButtonVariantStyle.lerp(secondary, other.secondary, t),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      height: lerpDouble(height, other.height, t)!,
      horizontalPadding: lerpDouble(
        horizontalPadding,
        other.horizontalPadding,
        t,
      )!,
      gap: lerpDouble(gap, other.gap, t)!,
      smoothing: t < 0.5 ? smoothing : other.smoothing,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      dropShadow: SavShadow.lerp(dropShadow, other.dropShadow, t)!,
      innerShadow: SavShadow.lerp(innerShadow, other.innerShadow, t)!,
      spinnerSize: lerpDouble(spinnerSize, other.spinnerSize, t)!,
      spinnerStrokeWidth: lerpDouble(
        spinnerStrokeWidth,
        other.spinnerStrokeWidth,
        t,
      )!,
      spinnerTrackStrokeWidth: lerpDouble(
        spinnerTrackStrokeWidth,
        other.spinnerTrackStrokeWidth,
        t,
      )!,
      spinnerRotationDuration: t < 0.5
          ? spinnerRotationDuration
          : other.spinnerRotationDuration,
      pressedOpacity: lerpDouble(pressedOpacity, other.pressedOpacity, t)!,
      stateChangeDuration: t < 0.5
          ? stateChangeDuration
          : other.stateChangeDuration,
      focusRingColor: Color.lerp(focusRingColor, other.focusRingColor, t)!,
      focusRingWidth: lerpDouble(focusRingWidth, other.focusRingWidth, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavButtonTheme &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.labelStyle == labelStyle &&
          other.height == height &&
          other.horizontalPadding == horizontalPadding &&
          other.gap == gap &&
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
          other.focusRingWidth == focusRingWidth;

  @override
  int get hashCode => Object.hashAll(<Object>[
    primary,
    secondary,
    labelStyle,
    height,
    horizontalPadding,
    gap,
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
  ]);
}
