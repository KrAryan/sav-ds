import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sav_design_system/src/tokens/sav_dimensions.dart';

/// The indeterminate spinner shown inside a loading `SavButton`.
///
/// Drawn rather than composed from `CircularProgressIndicator`: the Sav design
/// is a static half-circle arc rotating at a constant rate over a full-circle
/// track, whereas Material's indicator grows and shrinks its sweep.
class SavSpinner extends StatefulWidget {
  /// Creates a spinner.
  const SavSpinner({
    required this.trackColor,
    required this.arcColor,
    required this.size,
    required this.strokeWidth,
    required this.trackStrokeWidth,
    required this.rotationDuration,
    super.key,
  });

  /// Colour of the full-circle track behind the arc.
  final Color trackColor;

  /// Colour of the rotating arc.
  final Color arcColor;

  /// Width and height of the spinner.
  final double size;

  /// Stroke width of the arc.
  final double strokeWidth;

  /// Stroke width of the track.
  final double trackStrokeWidth;

  /// Time taken to complete one rotation.
  final Duration rotationDuration;

  @override
  State<SavSpinner> createState() => _SavSpinnerState();
}

class _SavSpinnerState extends State<SavSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.rotationDuration,
  )..repeat();

  @override
  void didUpdateWidget(SavSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotationDuration != oldWidget.rotationDuration) {
      _controller.duration = widget.rotationDuration;
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(
        painter: _SavSpinnerPainter(
          rotation: _controller,
          trackColor: widget.trackColor,
          arcColor: widget.arcColor,
          strokeWidth: widget.strokeWidth,
          trackStrokeWidth: widget.trackStrokeWidth,
        ),
      ),
    ),
  );
}

class _SavSpinnerPainter extends CustomPainter {
  _SavSpinnerPainter({
    required this.rotation,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
    required this.trackStrokeWidth,
  }) : super(repaint: rotation);

  final Animation<double> rotation;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;
  final double trackStrokeWidth;

  /// The design's arc covers half the circle.
  static const double _sweep = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // A proportion of the box, not something derived from the stroke: Figma
    // draws r = 8.3333 in a 20dp spinner and r = 7.5 in an 18dp one, both
    // exactly 5/12 of the size. See [SavSizes.spinnerRadiusRatio].
    final radius = size.shortestSide * SavSizes.spinnerRadiusRatio;
    if (radius <= 0) return;

    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackStrokeWidth
          ..color = trackColor
          ..isAntiAlias = true,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        // Start at 12 o'clock and sweep clockwise through the right-hand side.
        -math.pi / 2 + rotation.value * 2 * math.pi,
        _sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = arcColor
          ..isAntiAlias = true,
      );
  }

  @override
  bool shouldRepaint(_SavSpinnerPainter oldDelegate) =>
      oldDelegate.trackColor != trackColor ||
      oldDelegate.arcColor != arcColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackStrokeWidth != trackStrokeWidth;
}
