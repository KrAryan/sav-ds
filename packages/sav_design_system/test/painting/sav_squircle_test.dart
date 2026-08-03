import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

void main() {
  group('SavSquircle', () {
    // The Sav button was drawn with the `scotato/figma-squircle` plugin at
    // `mode: simple, c: 10`. Its SVG export is:
    //
    //   M2 26 C2 6.236 6.236 2 26 2 H307 ...
    //
    // which in the layer's own 329x48 coordinates is:
    //
    //   M0 24 C0 4.236 4.236 0 24 0 L305 0 ...
    //
    // These two constants are therefore ground truth: if they drift, the shape
    // no longer matches the design source.
    const buttonSize = Size(329, 48);

    test('reproduces the radii exported from Figma', () {
      expect(SavSquircle.outerRadius(buttonSize), 24.0);
      expect(
        SavSquircle.innerRadius(buttonSize),
        closeTo(4.236, 0.0005),
      );
    });

    test('starts the top edge at width - outerRadius, matching the export', () {
      // `L305 0` in the exported path.
      expect(buttonSize.width - SavSquircle.outerRadius(buttonSize), 305.0);
    });

    test('at max smoothing the outer radius is half the shorter side', () {
      for (final size in <Size>[
        const Size(329, 48),
        const Size(48, 48),
        const Size(20, 48),
        const Size(200, 90),
      ]) {
        expect(
          SavSquircle.outerRadius(size),
          size.shortestSide / 2,
          reason: '$size',
        );
      }
    });

    test('lower smoothing gives a tighter corner', () {
      var previous = double.infinity;
      for (
        var s = SavSquircle.maxSmoothing;
        s >= SavSquircle.minSmoothing;
        s--
      ) {
        final radius = SavSquircle.outerRadius(buttonSize, smoothing: s);
        expect(radius, lessThan(previous), reason: 'smoothing $s');
        previous = radius;
      }
    });

    test('fills its rect exactly', () {
      final path = SavSquircle.path(const Rect.fromLTWH(0, 0, 329, 48));
      final bounds = path.getBounds();
      expect(bounds.left, closeTo(0, 0.001));
      expect(bounds.top, closeTo(0, 0.001));
      expect(bounds.right, closeTo(329, 0.001));
      expect(bounds.bottom, closeTo(48, 0.001));
    });

    test('honours a rect that is not at the origin', () {
      final path = SavSquircle.path(const Rect.fromLTWH(10, 20, 329, 48));
      expect(path.getBounds().left, closeTo(10, 0.001));
      expect(path.getBounds().top, closeTo(20, 0.001));
    });

    test('rounds its corners away', () {
      final path = SavSquircle.path(const Rect.fromLTWH(0, 0, 329, 48));
      // Just inside the bounding box's corner, but outside the squircle.
      expect(path.contains(const Offset(0.5, 0.5)), isFalse);
      expect(path.contains(const Offset(328.5, 47.5)), isFalse);
      // Well inside.
      expect(path.contains(const Offset(164, 24)), isTrue);
    });

    test('stays well-formed when narrower than it is tall', () {
      const size = Size(20, 48);
      final path = SavSquircle.path(const Rect.fromLTWH(0, 0, 20, 48));
      // The corner radii must never exceed half the shorter side, or opposite
      // corners would overlap and the path would self-intersect.
      expect(
        SavSquircle.outerRadius(size),
        lessThanOrEqualTo(size.shortestSide / 2),
      );
      expect(
        SavSquircle.innerRadius(size),
        lessThanOrEqualTo(SavSquircle.outerRadius(size)),
      );
      expect(path.getBounds(), const Rect.fromLTWH(0, 0, 20, 48));
      expect(path.contains(const Offset(10, 24)), isTrue);
    });

    test('returns an empty path for a degenerate rect', () {
      expect(SavSquircle.path(Rect.zero).getBounds(), Rect.zero);
      expect(
        SavSquircle.path(const Rect.fromLTWH(0, 0, -10, 5)).getBounds(),
        Rect.zero,
      );
    });

    test('clamps out-of-range smoothing rather than throwing', () {
      expect(
        SavSquircle.outerRadius(buttonSize, smoothing: 99),
        SavSquircle.outerRadius(buttonSize),
      );
      expect(
        SavSquircle.outerRadius(buttonSize, smoothing: -5),
        SavSquircle.outerRadius(
          buttonSize,
          smoothing: SavSquircle.minSmoothing,
        ),
      );
    });
  });
}
