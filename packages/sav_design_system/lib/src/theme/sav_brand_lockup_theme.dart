import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sav_design_system/src/painting/sav_gradient.dart';
import 'package:sav_design_system/src/tokens/sav_colors.g.dart';
import 'package:sav_design_system/src/tokens/sav_typography.dart';

/// The colourways `SavBrandLockup` ships in.
///
/// A colourway recolours two things: the badge's gradient and the "Sav"
/// wordmark. Both come from one chromatic ramp — the gradient runs the ramp's
/// **`/800` into its `/600`**, and the wordmark takes its **`/700`**, sitting
/// between them.
///
/// The product name beside the lockup is deliberately *not* included. It stays
/// a constant Obsidian at 80% in every variant, so it reads as a separate word
/// rather than part of the mark. See [SavBrandLockupTheme.productNameStyle].
///
/// Only [neutral] breaks the ramp rule, because Sav Primary has no numbered
/// steps.
enum SavBrandColourway {
  /// Obsidian into Sterling, wordmark Obsidian. Figma calls this "Default".
  neutral(
    SavColors.savPrimaryObsidian,
    SavColors.savPrimarySterling,
    SavColors.savPrimaryObsidian,
  ),

  /// `Wealth Weave` — `/800` into `/600`, wordmark `/700`. Figma calls this
  /// "Wealth Wave".
  wealthWeave(
    SavColors.wealthWeave800,
    SavColors.wealthWeave600,
    SavColors.wealthWeave700,
  ),

  /// `Purple Power` — `/800` into `/600`, wordmark `/700`.
  purplePower(
    SavColors.purplePower800,
    SavColors.purplePower600,
    SavColors.purplePower700,
  ),

  /// `Cyan Reserve` — `/800` into `/600`, wordmark `/700`.
  cyanReserve(
    SavColors.cyanReserve800,
    SavColors.cyanReserve600,
    SavColors.cyanReserve700,
  ),

  /// `Gold Standard` — `/800` into `/600`, wordmark `/700`.
  goldStandard(
    SavColors.goldStandard800,
    SavColors.goldStandard600,
    SavColors.goldStandard700,
  );

  const SavBrandColourway(this.shadow, this.light, this.wordmark);

  /// The darker gradient stop, at 50% along the badge.
  final Color shadow;

  /// The lighter gradient stop, at the far end of the badge.
  final Color light;

  /// Colour of the "Sav" wordmark glyphs.
  final Color wordmark;

  /// The badge's two gradient stops, in order.
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
    required this.productNameStyle,
    required this.gap,
    required this.gradientStops,
    this.wordmarkColor,
  });

  /// The shipped Sav lockup styling, transcribed from the Figma export.
  factory SavBrandLockupTheme.standard() => SavBrandLockupTheme(
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

  /// Overrides the wordmark colour for every colourway.
  ///
  /// Normally `null`: the wordmark follows the colourway's ramp, so tying it
  /// to one colour here would flatten all five variants. Set it only when a
  /// surface demands a single fixed treatment — a dark header, say.
  final Color? wordmarkColor;

  /// Text style for the product name beside the logo.
  ///
  /// Constant across colourways by design — the product name is a separate
  /// word, not part of the mark.
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
      wordmarkColor: Color.lerp(wordmarkColor, other.wordmarkColor, t),
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
