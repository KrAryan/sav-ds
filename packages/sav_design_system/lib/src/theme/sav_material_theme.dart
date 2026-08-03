import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sav_design_system/src/tokens/sav_colors.g.dart';

/// The chromatic tint a tonal `SavMaterial` can carry.
///
/// A tonal material is the neutral surface with **one extra gradient stop**
/// washed in from a chromatic ramp's lightest step (`/100`). Each value here
/// names one of the seven ramps; [SavMaterialAccent.tint] resolves it to that
/// `/100` colour.
enum SavMaterialAccent {
  /// `Wealth Weave / 100` — #F2F6FC.
  wealthWeave(SavColors.wealthWeave100),

  /// `Lush Capital / 100` — #F1F9F1.
  lushCapital(SavColors.lushCapital100),

  /// `Gold Standard / 100` — #F9FBF1.
  goldStandard(SavColors.goldStandard100),

  /// `Purple Power / 100` — #F6F4F9.
  purplePower(SavColors.purplePower100),

  /// `Cyan Reserve / 100` — #F3F9F8.
  cyanReserve(SavColors.cyanReserve100),

  /// `Satin Vault / 100` — #F9F5F9.
  satinVault(SavColors.satinVault100),

  /// `Bronze Bounty / 100` — #FEF8F3.
  bronzeBounty(SavColors.bronzeBounty100);

  const SavMaterialAccent(this.tint);

  /// The `/100` colour this accent washes into the surface.
  final Color tint;
}

/// Theming for `SavMaterial` — Sav's surface fill and stroke.
///
/// A "Material" is the fill + stroke you apply to a frame: a corner-to-corner
/// sheen gradient, a white hairline stroke, a soft drop shadow, and a backdrop
/// blur. The gradient is neutral by default and gains one accent stop when
/// tonal.
///
/// The treatment is **shape-agnostic**: nothing here dictates a corner radius.
/// `SavMaterial` clips and strokes whatever [BorderRadiusGeometry] the caller
/// gives it.
@immutable
class SavMaterialTheme extends ThemeExtension<SavMaterialTheme> {
  /// Creates a material theme.
  const SavMaterialTheme({
    required this.neutralColor,
    required this.highlightColor,
    required this.begin,
    required this.end,
    required this.accentStop,
    required this.borderColor,
    required this.borderWidth,
    required this.shadow,
    required this.blurSigma,
    required this.fillOpacity,
  });

  /// The shipped Sav material styling, transcribed from the Figma export.
  factory SavMaterialTheme.standard() => const SavMaterialTheme(
    neutralColor: SavColors.savPrimaryLumen,
    highlightColor: SavColors.savPrimaryWhite,
    // Figma authors the fill as a corner-to-corner gradient: the two handles
    // sit on the top-left and bottom-right corners, and it scales with the
    // frame. (The CSS export's fixed 163.9° angle is only that diagonal for
    // the reference frame size and skews the sheen on any other aspect ratio.)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    accentStop: 0.69353,
    borderColor: SavColors.savPrimaryWhite,
    borderWidth: 1,
    shadow: BoxShadow(
      color: Color(0x147A7A7A), // Slate @ 8%
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
    // CSS `backdrop-blur-[6px]`: the px value is the Gaussian sigma.
    blurSigma: 6,
    // The Figma stops are opaque, so the surface is solid and the backdrop
    // blur has nothing to show through. Lower this to reveal the frost — see
    // `SavMaterial`.
    fillOpacity: 1,
  );

  /// The recessed tone of the sheen — Lumen, at the gradient's ends.
  final Color neutralColor;

  /// The raised tone of the sheen — White, through the middle.
  final Color highlightColor;

  /// Where the gradient begins — the first stop's corner.
  final AlignmentGeometry begin;

  /// Where the gradient ends — the last stop's corner.
  final AlignmentGeometry end;

  /// Position of the tonal accent stop, in `[0, 1]`.
  ///
  /// Sits between the two highlight stops so the wash reads as a soft band
  /// rather than an edge.
  final double accentStop;

  /// Colour of the hairline border.
  final Color borderColor;

  /// Width of the hairline border.
  final double borderWidth;

  /// The drop shadow.
  final BoxShadow shadow;

  /// Gaussian sigma of the backdrop blur.
  final double blurSigma;

  /// Opacity applied to the whole gradient fill.
  ///
  /// `1` (the shipped value) matches Figma's opaque stops exactly, and lets
  /// `SavMaterial` skip the backdrop-blur pass entirely — an opaque fill has
  /// nothing to blur behind it. Below `1`, the fill becomes translucent and
  /// the frosted-glass blur becomes visible.
  final double fillOpacity;

  /// The base gradient stops, neutral, with no accent.
  ///
  /// Lumen at the ends, White across the middle — a soft diagonal sheen.
  static const List<double> _baseStops = <double>[0.10, 0.40, 0.82274, 1];

  /// Builds the fill gradient for [accent] (or the neutral fill if `null`).
  ///
  /// A tonal material is the neutral gradient with the accent's `/100` colour
  /// inserted at [accentStop]; the neutral stops are untouched, so default and
  /// tonal share the same sheen.
  LinearGradient gradient([SavMaterialAccent? accent]) {
    final colors = <Color>[neutralColor, highlightColor];
    final stops = <double>[_baseStops[0], _baseStops[1]];

    if (accent != null) {
      colors.add(accent.tint);
      stops.add(accentStop);
    }

    colors
      ..add(highlightColor)
      ..add(neutralColor);
    stops
      ..add(_baseStops[2])
      ..add(_baseStops[3]);

    return LinearGradient(
      begin: begin,
      end: end,
      colors: fillOpacity >= 1.0
          ? colors
          : <Color>[
              for (final color in colors)
                color.withValues(alpha: color.a * fillOpacity),
            ],
      stops: stops,
    );
  }

  @override
  SavMaterialTheme copyWith({
    Color? neutralColor,
    Color? highlightColor,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    double? accentStop,
    Color? borderColor,
    double? borderWidth,
    BoxShadow? shadow,
    double? blurSigma,
    double? fillOpacity,
  }) => SavMaterialTheme(
    neutralColor: neutralColor ?? this.neutralColor,
    highlightColor: highlightColor ?? this.highlightColor,
    begin: begin ?? this.begin,
    end: end ?? this.end,
    accentStop: accentStop ?? this.accentStop,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    shadow: shadow ?? this.shadow,
    blurSigma: blurSigma ?? this.blurSigma,
    fillOpacity: fillOpacity ?? this.fillOpacity,
  );

  @override
  SavMaterialTheme lerp(covariant SavMaterialTheme? other, double t) {
    if (other == null) return this;
    return SavMaterialTheme(
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      begin: AlignmentGeometry.lerp(begin, other.begin, t)!,
      end: AlignmentGeometry.lerp(end, other.end, t)!,
      accentStop: lerpDouble(accentStop, other.accentStop, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      shadow: BoxShadow.lerp(shadow, other.shadow, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      fillOpacity: lerpDouble(fillOpacity, other.fillOpacity, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavMaterialTheme &&
          other.neutralColor == neutralColor &&
          other.highlightColor == highlightColor &&
          other.begin == begin &&
          other.end == end &&
          other.accentStop == accentStop &&
          other.borderColor == borderColor &&
          other.borderWidth == borderWidth &&
          other.shadow == shadow &&
          other.blurSigma == blurSigma &&
          other.fillOpacity == fillOpacity;

  @override
  int get hashCode => Object.hash(
    neutralColor,
    highlightColor,
    begin,
    end,
    accentStop,
    borderColor,
    borderWidth,
    shadow,
    blurSigma,
    fillOpacity,
  );
}
