import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:sav_design_system/src/painting/sav_squircle.dart';

/// An [OutlinedBorder] shaped by [SavSquircle].
///
/// Using a real [ShapeBorder] — rather than clipping by hand at each call site
/// — means ink splashes, `Material.clipBehavior`, and focus rings all follow
/// exactly the same geometry as the painted surface, with the path defined in
/// one place.
@immutable
class SavSquircleBorder extends OutlinedBorder {
  /// Creates a squircle border.
  const SavSquircleBorder({
    super.side = BorderSide.none,
    this.smoothing = SavSquircle.maxSmoothing,
  });

  /// Corner-smoothing preset, between [SavSquircle.minSmoothing] and
  /// [SavSquircle.maxSmoothing].
  final int smoothing;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  ShapeBorder scale(double t) =>
      SavSquircleBorder(side: side.scale(t), smoothing: smoothing);

  @override
  SavSquircleBorder copyWith({BorderSide? side, int? smoothing}) =>
      SavSquircleBorder(
        side: side ?? this.side,
        smoothing: smoothing ?? this.smoothing,
      );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      SavSquircle.path(rect, smoothing: smoothing);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      SavSquircle.path(rect.deflate(side.strokeInset), smoothing: smoothing);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    // A stroked path straddles the path, so offset by half the stroke to honour
    // the side's alignment. Same approach as [StadiumBorder].
    canvas.drawPath(
      SavSquircle.path(
        rect.inflate(side.strokeOffset / 2),
        smoothing: smoothing,
      ),
      side.toPaint(),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SavSquircleBorder) {
      return SavSquircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        smoothing: t < 0.5 ? a.smoothing : smoothing,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SavSquircleBorder) {
      return SavSquircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        smoothing: t < 0.5 ? smoothing : b.smoothing,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavSquircleBorder &&
          other.side == side &&
          other.smoothing == smoothing;

  @override
  int get hashCode => Object.hash(side, smoothing);

  @override
  String toString() => 'SavSquircleBorder($side, smoothing: $smoothing)';
}
