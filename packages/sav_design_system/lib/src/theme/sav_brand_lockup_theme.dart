import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sav_design_system/src/painting/sav_gradient.dart';
import 'package:sav_design_system/src/tokens/sav_colors.g.dart';
import 'package:sav_design_system/src/tokens/sav_typography.dart';

/// The colourways `SavBrandLockup` ships in.
///
/// Every colourway is the same artwork with a different pair of gradient
/// stops, so the badge is drawn once and the colours are injected at paint
/// time rather than baked into five separate assets.
///
/// All five follow one rule: the ramp's **`/800` into its `/600`**. Only the
/// neutral one breaks it, running Obsidian into Sterling.
enum SavBrandColourway {
  /// Obsidian into Sterling. Figma calls this one "Default".
  neutral(SavColors.savPrimaryObsidian, SavColors.savPrimarySterling),

  /// `Wealth Weave / 800` into `/600`. Figma calls this "Wealth Wave".
  wealthWeave(SavColors.wealthWeave800, SavColors.wealthWeave600),

  /// `Purple Power / 800` into `/600`.
  purplePower(SavColors.purplePower800, SavColors.purplePower600),

  /// `Cyan Reserve / 800` into `/600`.
  cyanReserve(SavColors.cyanReserve800, SavColors.cyanReserve600),

  /// `Gold Standard / 800` into `/600`.
  goldStandard(SavColors.goldStandard800, SavColors.goldStandard600);

  const SavBrandColourway(this.shadow, this.light);

  /// The darker stop, at 50% along the gradient.
  final Color shadow;

  /// The lighter stop, at the far end.
  final Color light;

  /// The two stops, in gradient order.
  List<Color> get colors => <Color>[shadow, light];
}

/// Theming for `SavBrandLockup`.
///
/// The badge gradient is not held here — it is composed per colourway (or from
/// caller-supplied colours) by [badgeGradient], so one set of vector strings
/// serves every variant.
@immutable
class SavBrandLockupTheme extends ThemeExtension<SavBrandLockupTheme> {
  /// Creates a brand lockup theme.
  const SavBrandLockupTheme({
    required this.wordmarkColor,
    required this.productNameStyle,
    required this.gap,
    required this.gradientStops,
  });

  /// The shipped Sav lockup styling, transcribed from the Figma export.
  factory SavBrandLockupTheme.standard() => SavBrandLockupTheme(
    wordmarkColor: SavColors.savPrimaryObsidian,
    // 20/1.2 at weight 550 — an ad-hoc style in Figma rather than a named one,
    // so it is spelled out here instead of pointing at the type scale.
    productNameStyle: SavTypography.headingLarge.copyWith(
      // `sav-transparent/80`: Obsidian at 80%. The Transparent ramp is not in
      // the variable export, so it cannot come from a generated token yet.
      color: SavColors.savPrimaryObsidian.withValues(alpha: 0.8),
    ),
    gap: 4,
    gradientStops: const <double>[0.5, 1],
  );

  /// The frame the artwork was drawn against — its intrinsic size.
  static const Size referenceSize = Size(83.3389, 35.6457);

  /// Figma's `gradientTransform` for the badge, in [referenceSize] space.
  ///
  /// A radial gradient skewed and rotated so the highlight falls across the
  /// badge's lower-left. The same transform serves every colourway.
  static const List<double> badgeTransform = <double>[
    -12.9325,
    15.0646,
    -21.9379,
    -18.3367,
    17.8781,
    17.8229,
  ];

  /// Colour of the "Sav" wordmark glyphs.
  final Color wordmarkColor;

  /// Text style for the product name beside the logo.
  final TextStyle productNameStyle;

  /// Space between the logo and the product name.
  final double gap;

  /// Stop positions for the badge gradient.
  final List<double> gradientStops;

  /// Builds the badge gradient from [colors].
  ///
  /// This is the injection point: pass a colourway's pair, or any two colours,
  /// and the same artwork renders in them.
  SavRadialGradient badgeGradient(List<Color> colors) {
    assert(
      colors.length == gradientStops.length,
      'Expected ${gradientStops.length} colours to match the stops, '
      'got ${colors.length}.',
    );
    return SavRadialGradient(
      colors: colors,
      stops: gradientStops,
      referenceSize: referenceSize,
      a: badgeTransform[0],
      b: badgeTransform[1],
      c: badgeTransform[2],
      d: badgeTransform[3],
      e: badgeTransform[4],
      f: badgeTransform[5],
    );
  }

  @override
  SavBrandLockupTheme copyWith({
    Color? wordmarkColor,
    TextStyle? productNameStyle,
    double? gap,
    List<double>? gradientStops,
  }) => SavBrandLockupTheme(
    wordmarkColor: wordmarkColor ?? this.wordmarkColor,
    productNameStyle: productNameStyle ?? this.productNameStyle,
    gap: gap ?? this.gap,
    gradientStops: gradientStops ?? this.gradientStops,
  );

  @override
  SavBrandLockupTheme lerp(covariant SavBrandLockupTheme? other, double t) {
    if (other == null) return this;
    return SavBrandLockupTheme(
      wordmarkColor: Color.lerp(wordmarkColor, other.wordmarkColor, t)!,
      productNameStyle: TextStyle.lerp(
        productNameStyle,
        other.productNameStyle,
        t,
      )!,
      gap: lerpDouble(gap, other.gap, t)!,
      gradientStops: t < 0.5 ? gradientStops : other.gradientStops,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavBrandLockupTheme &&
          other.wordmarkColor == wordmarkColor &&
          other.productNameStyle == productNameStyle &&
          other.gap == gap &&
          listEquals(other.gradientStops, gradientStops);

  @override
  int get hashCode => Object.hash(
    wordmarkColor,
    productNameStyle,
    gap,
    Object.hashAll(gradientStops),
  );
}
