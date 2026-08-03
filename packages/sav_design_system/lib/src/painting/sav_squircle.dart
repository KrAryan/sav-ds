import 'dart:math' as math;
import 'dart:ui';

/// Smooth-cornered rectangle ("squircle") geometry.
///
/// This is a port of the `scotato/figma-squircle` Figma plugin, which is the
/// tool the Sav design team uses to draw component shapes. Porting it —
/// rather than reaching for Flutter's `RoundedSuperellipseBorder` — matters:
/// that class implements the *Apple* superellipse, a visibly different curve.
///
/// The shape is four line segments joined by four cubic Béziers. Each corner is
/// described by two radii:
///
/// * `outerRadius` — where the corner starts, measured along the edge.
/// * `innerRadius` — where the Bézier control points sit. A smaller inner
///   radius pulls the control points closer to the corner, concentrating the
///   curvature and producing the smoothed, "squircular" look.
///
/// The ratio between them is fixed at [ratio], matching the plugin.
abstract final class SavSquircle {
  /// The plugin's fixed inner/outer radius ratio.
  static const double ratio = 0.1765;

  /// Lowest supported `smoothing` preset — nearly a plain rounded rectangle.
  static const int minSmoothing = 1;

  /// Highest supported `smoothing` preset — the most rounded, smoothest corner.
  ///
  /// This is what the Sav button uses.
  static const int maxSmoothing = 10;

  /// The plugin's `c` presets, mapped to their outer-radius ratio.
  ///
  /// Indexed by smoothing level, so index 0 is unused padding.
  static const List<double> _presets = <double>[
    0, // unused
    0.0375,
    0.0750,
    0.1500,
    0.2984,
    0.3320,
    0.3656,
    0.3992,
    0.4328,
    0.4664,
    0.5000,
  ];

  /// The outer corner radius for a shape of [size] at `smoothing`.
  ///
  /// At [maxSmoothing] this is exactly half the shorter side, so the shape is
  /// fully rounded on its short axis.
  static double outerRadius(Size size, {int smoothing = maxSmoothing}) {
    final short = math.min(size.width, size.height);
    if (short <= 0) return 0;
    final preset = _presets[smoothing.clamp(minSmoothing, maxSmoothing)];
    // No preset exceeds 0.5, so this clamp is never load-bearing today; it
    // keeps the shape well-formed if a preset is ever added or overridden.
    return math.min(preset * short, short / 2);
  }

  /// The Bézier control-point radius for a shape of [size] at `smoothing`.
  static double innerRadius(Size size, {int smoothing = maxSmoothing}) {
    final short = math.min(size.width, size.height);
    if (short <= 0) return 0;
    final preset = _presets[smoothing.clamp(minSmoothing, maxSmoothing)];
    return math.min(
      preset * ratio * short,
      outerRadius(size, smoothing: smoothing),
    );
  }

  /// Builds the squircle path filling [rect].
  ///
  /// Returns an empty path for empty or negative rects.
  static Path path(Rect rect, {int smoothing = maxSmoothing}) {
    final path = Path();
    if (rect.width <= 0 || rect.height <= 0) return path;

    final size = rect.size;
    final r2 = outerRadius(size, smoothing: smoothing);
    final r1 = innerRadius(size, smoothing: smoothing);

    final l = rect.left;
    final t = rect.top;
    final r = rect.right;
    final b = rect.bottom;

    return path
      ..moveTo(l, t + r2)
      ..cubicTo(l, t + r1, l + r1, t, l + r2, t) // top-left
      ..lineTo(r - r2, t)
      ..cubicTo(r - r1, t, r, t + r1, r, t + r2) // top-right
      ..lineTo(r, b - r2)
      ..cubicTo(r, b - r1, r - r1, b, r - r2, b) // bottom-right
      ..lineTo(l + r2, b)
      ..cubicTo(l + r1, b, l, b - r1, l, b - r2) // bottom-left
      ..close();
  }
}
