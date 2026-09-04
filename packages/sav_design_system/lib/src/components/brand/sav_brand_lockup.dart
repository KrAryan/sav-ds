import 'package:flutter/material.dart';
import 'package:sav_design_system/src/components/brand/sav_logo_artwork.dart';
import 'package:sav_design_system/src/painting/sav_gradient.dart';
import 'package:sav_design_system/src/theme/sav_brand_lockup_theme.dart';

/// The Sav brand lockup: the badge, the "Sav" wordmark, and an optional
/// product name.
///
/// ```dart
/// const SavBrandLockup();                                   // [badge] Sav String
/// const SavBrandLockup(showProductName: false);             // [badge] Sav
/// const SavBrandLockup(showWordmark: false);                // [badge] String
/// const SavBrandLockup(                                     // [badge]
///   showWordmark: false,
///   showProductName: false,
/// );
/// const SavBrandLockup(colourway: SavBrandColourway.cyanReserve);
/// ```
///
/// ## Composition
///
/// Three parts, two of which can be switched off independently: the badge
/// (always drawn), the "Sav" wordmark, and the product name.
///
/// Turning the wordmark off **narrows the artwork to the badge** rather than
/// leaving a gap — the badge sits at the origin and the wordmark to its right,
/// so the frame simply gets shorter. That leaves a near-square mark, which is
/// the form an app icon or avatar wants.
///
/// Note [showWordmark] has no counterpart in the Figma component, which only
/// exposes `productName`. It is a code-side addition for the icon-only case.
///
/// ## Colourways
///
/// Five, matching the Figma `Colour` property. A colourway recolours **both**
/// the badge gradient and the "Sav" wordmark, all from one ramp: `/800` into
/// `/600` for the gradient, `/700` for the wordmark.
///
/// The product name stays a constant Obsidian at 80% in every variant, so it
/// reads as a separate word rather than part of the mark.
///
/// The artwork is drawn from vector strings and the colours are **injected at
/// paint time**, so nothing is duplicated per variant. Pass [gradientColors]
/// or [wordmarkColor] to go outside the five shipped ramps.
///
/// ## Sizing
///
/// The artwork has a fixed aspect ratio. Give it a [height] and the logo scales
/// to match; the product name keeps its own type size, as it does in Figma.
class SavBrandLockup extends StatelessWidget {
  /// Creates a brand lockup.
  const SavBrandLockup({
    this.colourway = SavBrandColourway.neutral,
    this.showWordmark = true,
    this.showProductName = true,
    this.productName = 'String',
    this.height,
    this.gradientColors,
    this.wordmarkColor,
    this.semanticLabel,
    super.key,
  });

  /// Which colourway to draw the badge in.
  final SavBrandColourway colourway;

  /// Whether to draw the "Sav" wordmark beside the badge.
  ///
  /// Setting this to `false` narrows the artwork to the badge alone, leaving a
  /// near-square mark. The badge still stands for the brand, so the accessible
  /// label is unchanged.
  final bool showWordmark;

  /// Whether to show [productName] beside the logo.
  ///
  /// Mirrors the Figma component's `productName` property.
  final bool showProductName;

  /// The product name shown beside the logo.
  final String productName;

  /// Height of the logo artwork. Defaults to its intrinsic 35.65dp.
  final double? height;

  /// Overrides the colourway's gradient stops.
  ///
  /// The direct injection point: two colours, dark first. Useful for a product
  /// colour the design system does not have a ramp for yet.
  final List<Color>? gradientColors;

  /// Overrides the "Sav" wordmark colour.
  ///
  /// Defaults to the colourway's own wordmark tone. Set this when the lockup
  /// sits on a surface the ramp does not read against — reversing it to white
  /// on a dark header, for instance.
  final Color? wordmarkColor;

  /// Accessible label for the whole lockup.
  ///
  /// Defaults to the brand name plus the product name, since the artwork
  /// carries meaning that a screen reader cannot otherwise reach.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<SavBrandLockupTheme>() ??
        SavBrandLockupTheme.standard();

    // Both frames share a height, so the scale is the same either way; only
    // the width differs.
    final artwork = showWordmark
        ? SavLogoArtwork.viewBox
        : SavLogoArtwork.badgeViewBox;
    final logoHeight = height ?? artwork.height;
    final scale = logoHeight / artwork.height;

    final logo = CustomPaint(
      size: Size(artwork.width * scale, logoHeight),
      painter: _SavLogoPainter(
        gradient: theme.badgeGradient(gradientColors ?? colourway.colors),
        // Explicit argument first, then a theme-wide override, then the
        // colourway's own tone — which is the normal path.
        wordmarkColor:
            wordmarkColor ?? theme.wordmarkColor ?? colourway.wordmark,
        showWordmark: showWordmark,
      ),
    );

    return Semantics(
      container: true,
      image: true,
      label: semanticLabel ?? (showProductName ? 'Sav $productName' : 'Sav'),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            logo,
            if (showProductName) ...<Widget>[
              SizedBox(width: theme.gap * scale),
              Text(productName, style: theme.productNameStyle),
            ],
          ],
        ),
      ),
    );
  }
}

/// Paints the badge and wordmark, scaled from the artwork's view box.
class _SavLogoPainter extends CustomPainter {
  const _SavLogoPainter({
    required this.gradient,
    required this.wordmarkColor,
    required this.showWordmark,
  });

  final SavRadialGradient gradient;
  final Color wordmarkColor;
  final bool showWordmark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const view = SavLogoArtwork.viewBox;
    final artwork = showWordmark ? view : SavLogoArtwork.badgeViewBox;
    final rect = Offset.zero & size;

    canvas
      ..save()
      // Paths are in view-box units; scale once instead of transforming each.
      // Dropping the wordmark changes only the width, so both axes still share
      // one factor.
      ..scale(size.width / artwork.width, size.height / artwork.height)
      ..drawPath(
        SavLogoArtwork.badge,
        // Shaded against the *full* view box even when only the badge is drawn:
        // its transform is in full-view-box units, so a narrowed frame would
        // squash it horizontally.
        Paint()..shader = gradient.createShader(Offset.zero & view),
      );
    if (showWordmark) {
      canvas.drawPath(SavLogoArtwork.wordmark, Paint()..color = wordmarkColor);
    }
    canvas.restore();

    assert(() {
      // Guards the aspect ratio: a squashed logo is a brand problem, and it is
      // easy to introduce by putting the lockup in a tight Row.
      final expected = artwork.width / artwork.height;
      final actual = rect.width / rect.height;
      return (expected - actual).abs() < 0.01;
    }(), 'SavBrandLockup was given a non-uniform size; the logo will distort.');
  }

  @override
  bool shouldRepaint(_SavLogoPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.wordmarkColor != wordmarkColor ||
      oldDelegate.showWordmark != showWordmark;
}
