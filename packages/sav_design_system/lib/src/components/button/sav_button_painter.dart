import 'package:flutter/rendering.dart';
import 'package:sav_design_system/src/painting/sav_noise.dart';
import 'package:sav_design_system/src/painting/sav_squircle.dart';
import 'package:sav_design_system/src/theme/sav_button_theme.dart';

/// Paints a whole button surface in a single pass.
///
/// Every layer Figma stacks — shadow, gradient, grain, inner shadow, outline —
/// is drawn here rather than composed from nested widgets. A `ShaderMask` or
/// `BackdropFilter` per layer would force a separate render surface each, and
/// the grain's `softLight` blend would then need its own `saveLayer`. Drawing
/// them in order onto one canvas keeps a button to a single draw pass with no
/// offscreen allocation.
///
/// Shared by every Sav button; the size differences arrive through
/// [buttonStyle].
class SavButtonPainter extends CustomPainter {
  /// Creates a button painter.
  const SavButtonPainter({
    required this.style,
    required this.buttonStyle,
    required this.enabled,
    required this.loading,
    required this.focused,
    required this.devicePixelRatio,
  });

  /// Styling for the button's variant.
  final SavButtonVariantStyle style;

  /// Sizing, shadow and shape tokens for the component being drawn.
  final SavButtonStyle buttonStyle;

  /// Whether the button has an `onPressed` callback.
  final bool enabled;

  /// Whether the button is showing its loading state.
  final bool loading;

  /// Whether the button holds keyboard focus.
  final bool focused;

  /// Display density, used to keep the grain one texel per device pixel.
  final double devicePixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final path = SavSquircle.path(rect, smoothing: buttonStyle.smoothing);

    _paintDropShadow(canvas, path);
    _paintFill(canvas, rect, path);
    _paintGrain(canvas, path);
    _paintInnerShadow(canvas, rect, path);
    _paintBorder(canvas, rect);
    if (focused) _paintFocusRing(canvas, rect);
  }

  void _paintDropShadow(Canvas canvas, Path path) {
    final shadow = buttonStyle.dropShadow;
    canvas.drawPath(
      path.shift(shadow.offset),
      Paint()
        ..color = shadow.color
        ..maskFilter = shadow.maskFilter,
    );
  }

  void _paintFill(Canvas canvas, Rect rect, Path path) {
    final fill = style.resolveFill(enabled: enabled, loading: loading);
    canvas.drawPath(path, Paint()..shader = fill.createShader(rect));
  }

  /// Draws the film grain over the fill.
  ///
  /// No `saveLayer` here: the blend composites against whatever is already on
  /// the canvas, which inside the shape is the fill just painted. That matches
  /// Figma, where the grain layer is not isolated either and blends with
  /// everything beneath it.
  void _paintGrain(Canvas canvas, Path path) {
    final intensity = buttonStyle.grainIntensity;
    if (intensity <= 0) return;

    final paint = Paint()
      ..shader = SavNoise.shaderFor(devicePixelRatio)
      ..blendMode = SavNoise.blendMode;

    if (intensity != 1) {
      // Scales only the alpha channel. The tile is pure black, so leaving the
      // colour rows as identity is exact rather than an approximation, and it
      // avoids regenerating the shared texture per intensity.
      paint.colorFilter = ColorFilter.matrix(<double>[
        1, 0, 0, 0, 0, //
        0, 1, 0, 0, 0, //
        0, 0, 1, 0, 0, //
        0, 0, 0, intensity, 0, //
      ]);
    }

    canvas.drawPath(path, paint);
  }

  /// Draws the inner shadow along the shape's top-left edge.
  ///
  /// Flutter has no inner-shadow primitive. The shape is used as a clip, and
  /// the *inverse* of an offset copy is filled and blurred inside it — so the
  /// blur bleeds inward from the edge and nothing escapes the silhouette.
  void _paintInnerShadow(Canvas canvas, Rect rect, Path path) {
    final shadow = buttonStyle.innerShadow;
    // Enough margin that the blurred fill covers the clip on every side.
    final margin = shadow.sigma * 3 + shadow.offset.distance + 1;
    canvas
      ..save()
      ..clipPath(path)
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(rect.inflate(margin)),
          path.shift(shadow.offset),
        ),
        Paint()
          ..color = shadow.color
          ..maskFilter = shadow.maskFilter,
      )
      ..restore();
  }

  void _paintBorder(Canvas canvas, Rect rect) {
    final width = buttonStyle.borderWidth;
    if (width <= 0) return;
    canvas.drawPath(
      // Inset by half the stroke so the 1dp outline sits fully inside the
      // silhouette, as it does in the Figma export.
      SavSquircle.path(
        rect.deflate(width / 2),
        smoothing: buttonStyle.smoothing,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        // Gradient coordinates are relative to the full frame, not the inset
        // path, so the shader is built from `rect`.
        ..shader = style.border.createShader(rect),
    );
  }

  /// Draws the keyboard focus indicator just inside the outline.
  ///
  /// Kept within the button's own bounds so it can never overlap a neighbour
  /// in a tight button row.
  void _paintFocusRing(Canvas canvas, Rect rect) {
    final width = buttonStyle.focusRingWidth;
    final inset = buttonStyle.borderWidth + width / 2;
    canvas.drawPath(
      SavSquircle.path(rect.deflate(inset), smoothing: buttonStyle.smoothing),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = buttonStyle.focusRingColor,
    );
  }

  @override
  bool shouldRepaint(SavButtonPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.buttonStyle != buttonStyle ||
      oldDelegate.enabled != enabled ||
      oldDelegate.loading != loading ||
      oldDelegate.focused != focused ||
      oldDelegate.devicePixelRatio != devicePixelRatio;
}
