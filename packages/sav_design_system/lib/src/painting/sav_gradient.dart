import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A gradient authored in Figma against a fixed-size frame.
///
/// Figma stores gradient geometry relative to the layer it is painted on, so
/// resizing a layer stretches its gradient. Flutter's [Gradient] types express
/// only some of that geometry — in particular they cannot represent the skewed
/// transform Figma puts on a radial fill.
///
/// These types keep the exported coordinates verbatim, in the
/// [referenceSize] frame they were authored against, and rescale them to
/// whatever rect they are painted into. The result matches Figma at any size,
/// not just the size the component was drawn at.
@immutable
sealed class SavGradient {
  const SavGradient({
    required this.colors,
    required this.stops,
    required this.referenceSize,
  });

  /// Gradient colours, in stop order.
  final List<Color> colors;

  /// Stop positions in `[0, 1]`, matching [colors].
  final List<double> stops;

  /// The frame the coordinates were authored against.
  final Size referenceSize;

  /// Builds the shader for [rect].
  ui.Shader createShader(Rect rect);

  /// Returns a copy with every colour's opacity multiplied by [factor].
  ///
  /// Sav's button states are expressed as opacity steps on one gradient rather
  /// than as separate gradients, which is how Figma authors them.
  SavGradient scaleOpacity(double factor);

  /// Linearly interpolates between two gradients.
  ///
  /// Returns `null` if both are `null`. Interpolation requires matching types
  /// and stop counts; otherwise it snaps at the halfway point.
  static SavGradient? lerp(SavGradient? a, SavGradient? b, double t) {
    if (identical(a, b)) return a;
    if (a == null) return b;
    if (b == null) return a;
    if (a.runtimeType != b.runtimeType || a.colors.length != b.colors.length) {
      return t < 0.5 ? a : b;
    }
    final colors = <Color>[
      for (var i = 0; i < a.colors.length; i++)
        Color.lerp(a.colors[i], b.colors[i], t)!,
    ];
    return switch (a) {
      SavLinearGradient() => (b as SavLinearGradient)._withColors(colors, a, t),
      SavRadialGradient() => (b as SavRadialGradient)._withColors(colors, a, t),
    };
  }

  double _sx(Rect rect) => rect.width / referenceSize.width;

  double _sy(Rect rect) => rect.height / referenceSize.height;
}

/// A two-point linear gradient.
@immutable
final class SavLinearGradient extends SavGradient {
  /// Creates a linear gradient from Figma's exported endpoints.
  const SavLinearGradient({
    required super.colors,
    required super.stops,
    required super.referenceSize,
    required this.from,
    required this.to,
  });

  /// Start point, in [SavGradient.referenceSize] coordinates.
  final Offset from;

  /// End point, in [SavGradient.referenceSize] coordinates.
  final Offset to;

  @override
  ui.Shader createShader(Rect rect) {
    final sx = _sx(rect);
    final sy = _sy(rect);
    return ui.Gradient.linear(
      Offset(rect.left + from.dx * sx, rect.top + from.dy * sy),
      Offset(rect.left + to.dx * sx, rect.top + to.dy * sy),
      colors,
      stops,
    );
  }

  @override
  SavLinearGradient scaleOpacity(double factor) => SavLinearGradient(
    colors: <Color>[
      for (final color in colors) color.withValues(alpha: color.a * factor),
    ],
    stops: stops,
    referenceSize: referenceSize,
    from: from,
    to: to,
  );

  SavLinearGradient _withColors(
    List<Color> colors,
    SavLinearGradient a,
    double t,
  ) => SavLinearGradient(
    colors: colors,
    stops: stops,
    referenceSize: referenceSize,
    from: Offset.lerp(a.from, from, t)!,
    to: Offset.lerp(a.to, to, t)!,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavLinearGradient &&
          listEquals(other.colors, colors) &&
          listEquals(other.stops, stops) &&
          other.referenceSize == referenceSize &&
          other.from == from &&
          other.to == to;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(colors),
    Object.hashAll(stops),
    referenceSize,
    from,
    to,
  );
}

/// A radial gradient carrying Figma's full affine transform.
///
/// Figma exports these as an SVG `radialGradient` with `cx=0, cy=0, r=1` plus a
/// `gradientTransform` that maps the unit circle onto the intended ellipse.
/// Sav's primary button uses a heavily skewed transform, which reads as a
/// diagonal sweep rather than a conventional radial burst.
@immutable
final class SavRadialGradient extends SavGradient {
  /// Creates a radial gradient from Figma's exported `gradientTransform`.
  ///
  /// The parameters are the six components of the SVG matrix
  /// `matrix(a b c d e f)`, already translated into the layer's own
  /// coordinate space.
  const SavRadialGradient({
    required super.colors,
    required super.stops,
    required super.referenceSize,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
    required this.f,
  });

  /// `a` of `matrix(a b c d e f)` — x scale.
  final double a;

  /// `b` of `matrix(a b c d e f)` — y skew.
  final double b;

  /// `c` of `matrix(a b c d e f)` — x skew.
  final double c;

  /// `d` of `matrix(a b c d e f)` — y scale.
  final double d;

  /// `e` of `matrix(a b c d e f)` — x translation.
  final double e;

  /// `f` of `matrix(a b c d e f)` — y translation.
  final double f;

  @override
  ui.Shader createShader(Rect rect) {
    final sx = _sx(rect);
    final sy = _sy(rect);
    return ui.Gradient.radial(
      Offset.zero,
      1,
      colors,
      stops,
      TileMode.clamp,
      // Column-major 4x4 form of the scaled 2D affine matrix.
      Float64List.fromList(<double>[
        a * sx, b * sy, 0, 0, //
        c * sx, d * sy, 0, 0, //
        0, 0, 1, 0, //
        e * sx + rect.left, f * sy + rect.top, 0, 1, //
      ]),
    );
  }

  @override
  SavRadialGradient scaleOpacity(double factor) => SavRadialGradient(
    colors: <Color>[
      for (final color in colors) color.withValues(alpha: color.a * factor),
    ],
    stops: stops,
    referenceSize: referenceSize,
    a: a,
    b: b,
    c: c,
    d: d,
    e: e,
    f: f,
  );

  SavRadialGradient _withColors(
    List<Color> colors,
    SavRadialGradient from,
    double t,
  ) => SavRadialGradient(
    colors: colors,
    stops: stops,
    referenceSize: referenceSize,
    a: ui.lerpDouble(from.a, a, t)!,
    b: ui.lerpDouble(from.b, b, t)!,
    c: ui.lerpDouble(from.c, c, t)!,
    d: ui.lerpDouble(from.d, d, t)!,
    e: ui.lerpDouble(from.e, e, t)!,
    f: ui.lerpDouble(from.f, f, t)!,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavRadialGradient &&
          listEquals(other.colors, colors) &&
          listEquals(other.stops, stops) &&
          other.referenceSize == referenceSize &&
          other.a == a &&
          other.b == b &&
          other.c == c &&
          other.d == d &&
          other.e == e &&
          other.f == f;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(colors),
    Object.hashAll(stops),
    referenceSize,
    Object.hash(a, b, c, d, e, f),
  );
}
