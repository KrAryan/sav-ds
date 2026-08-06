import 'package:flutter/material.dart';
import 'package:sav_design_system/src/components/brand/sav_logo_artwork.dart';
import 'package:sav_design_system/src/painting/sav_gradient.dart';
import 'package:sav_design_system/src/theme/sav_brand_lockup_theme.dart';

/// The Sav brand lockup: the badge, the "Sav" wordmark, and an optional
/// product name.
///
/// ```dart
/// const SavBrandLockup();                                   // Sav String
/// const SavBrandLockup(showProductName: false);             // Sav
/// const SavBrandLockup(colourway: SavBrandColourway.cyanReserve);
/// ```
///
/// ## Colourways
///
/// Five, matching the Figma `Colour` property. Each is the same artwork with a
/// different pair of gradient stops — the badge is drawn from vector strings
/// and the colours are **injected at paint time**, so nothing is duplicated per
/// variant. Pass [gradientColors] to inject a pair the design system does not
/// ship.
///
/// ## Sizing
///
/// The artwork has a fixed aspect ratio. Give it a [height] and the logo scales
/// to match; the product name keeps its own type size, as it does in Figma.
class SavBrandLockup extends StatelessWidget {
  /// Creates a brand lockup.
  const SavBrandLockup({
    this.colourway = SavBrandColourway.neutral,
    this.showProductName = true,
    this.productName = 'String',
    this.height,
    this.gradientColors,
    this.semanticLabel,
    super.key,
  });

  /// Which colourway to draw the badge in.
  final SavBrandColourway colourway;

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

    const size = SavLogoArtwork.viewBox;
    final logoHeight = height ?? size.height;
    final scale = logoHeight / size.height;

    final logo = CustomPaint(
      size: Size(size.width * scale, logoHeight),
      painter: _SavLogoPainter(
        gradient: theme.badgeGradient(gradientColors ?? colourway.colors),
        wordmarkColor: theme.wordmarkColor,
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
  const _SavLogoPainter({required this.gradient, required this.wordmarkColor});

  final SavRadialGradient gradient;
  final Color wordmarkColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const view = SavLogoArtwork.viewBox;
    final rect = Offset.zero & size;

    canvas
      ..save()
      // The paths are authored in view-box units; scale once and draw them
      // as-is rather than transforming every path.
      ..scale(size.width / view.width, size.height / view.height)
      ..drawPath(
        SavLogoArtwork.badge,
        // The gradient is built against the view box, so it is created from
        // the untransformed rect and scaled by the same canvas transform.
        Paint()..shader = gradient.createShader(Offset.zero & view),
      )
      ..drawPath(SavLogoArtwork.wordmark, Paint()..color = wordmarkColor)
      ..restore();

    assert(() {
      // Guards the aspect ratio: a squashed logo is a brand problem, and it is
      // easy to introduce by putting the lockup in a tight Row.
      final expected = view.width / view.height;
      final actual = rect.width / rect.height;
      return (expected - actual).abs() < 0.01;
    }(), 'SavBrandLockup was given a non-uniform size; the logo will distort.');
  }

  @override
  bool shouldRepaint(_SavLogoPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.wordmarkColor != wordmarkColor;
}
