import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sav_design_system/src/theme/sav_material_theme.dart';

/// The Sav frosted-glass surface treatment.
///
/// A "Material" is Sav's card/surface background: a soft diagonal sheen, a white
/// hairline border, and a gentle drop shadow. It is **shape-agnostic** — it
/// applies to whatever [borderRadius] the caller gives it — and wraps arbitrary
/// content.
///
/// ```dart
/// SavMaterial(
///   child: Padding(
///     padding: const EdgeInsets.all(SavSpacing.lg),
///     child: balanceCard,
///   ),
/// );
/// ```
///
/// ## Default vs tonal
///
/// Passing an [accent] makes it *tonal*: the neutral sheen gains one extra
/// gradient stop washed in from that chromatic ramp's `/100` colour. Leaving it
/// `null` is the neutral *default* material.
///
/// ```dart
/// SavMaterial(
///   accent: SavMaterialAccent.lushCapital, // a faint green wash
///   child: portfolioCard,
/// );
/// ```
///
/// ## Frosted glass
///
/// The Figma spec includes a 6px backdrop blur. As authored the gradient stops
/// are opaque, so the surface is solid and the blur has nothing to reveal —
/// `SavMaterial` therefore skips the (costly) blur pass whenever the fill is
/// opaque. Lower [SavMaterialTheme.fillOpacity] below `1` to make the surface
/// translucent and turn the frost on.
class SavMaterial extends StatelessWidget {
  /// Creates a material surface.
  const SavMaterial({
    required this.child,
    this.accent,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  /// The content painted on the surface.
  final Widget child;

  /// The chromatic wash, or `null` for the neutral default material.
  final SavMaterialAccent? accent;

  /// Corner radius of the surface, its border and its clip.
  ///
  /// The material treatment does not care about shape; this is only how round
  /// you want *this* surface. Defaults to a gentle 16dp.
  final BorderRadiusGeometry borderRadius;

  /// How to clip the child (and the backdrop blur) to the surface.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<SavMaterialTheme>() ??
        SavMaterialTheme.standard();

    // The fill + border, without the shadow — the shadow is hung separately so
    // it is never clipped away by the surface's own clip.
    final fill = BoxDecoration(
      gradient: theme.gradient(accent),
      borderRadius: borderRadius,
      border: Border.all(
        color: theme.borderColor,
        width: theme.borderWidth,
      ),
    );

    Widget surface = Container(
      clipBehavior: clipBehavior,
      decoration: fill,
      child: child,
    );

    // Only pay for the backdrop blur when a translucent fill would let it
    // show; an opaque surface has nothing behind it to blur.
    if (theme.fillOpacity < 1.0 && theme.blurSigma > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: theme.blurSigma,
          sigmaY: theme.blurSigma,
        ),
        child: surface,
      );
      surface = ClipRRect(
        borderRadius: borderRadius.resolve(Directionality.maybeOf(context)),
        clipBehavior: clipBehavior,
        child: surface,
      );
    }

    // Shadow last, on the outside, so it is cast by the finished shape.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[theme.shadow],
      ),
      child: surface,
    );
  }
}
