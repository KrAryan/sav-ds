import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

void main() {
  group('SavPathParser', () {
    test('parses an absolute move and line', () {
      final path = SavPathParser.parse('M10 20 L30 40');
      expect(path.getBounds(), const Rect.fromLTRB(10, 20, 30, 40));
    });

    test('treats commas and whitespace interchangeably', () {
      final a = SavPathParser.parse('M10,20L30,40');
      final b = SavPathParser.parse('M 10 20 L 30 40');
      expect(a.getBounds(), b.getBounds());
    });

    test('reads numbers run together by a minus sign', () {
      // Figma emits "0-5" with no separator; the minus starts a new number.
      final path = SavPathParser.parse('M0 0L10-5');
      expect(path.getBounds(), const Rect.fromLTRB(0, -5, 10, 0));
    });

    test('handles relative commands', () {
      final path = SavPathParser.parse('M10 10 l10 10');
      expect(path.getBounds(), const Rect.fromLTRB(10, 10, 20, 20));
    });

    test('handles H and V, absolute and relative', () {
      expect(
        SavPathParser.parse('M0 0 H50 V25').getBounds(),
        const Rect.fromLTRB(0, 0, 50, 25),
      );
      expect(
        SavPathParser.parse('M10 10 h20 v10').getBounds(),
        const Rect.fromLTRB(10, 10, 30, 20),
      );
    });

    test('repeats an implicit lineTo after moveTo', () {
      // Per spec, extra coordinate pairs after M continue as L.
      final path = SavPathParser.parse('M0 0 10 0 10 10');
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 10, 10));
    });

    test('repeats a command for trailing argument sets', () {
      final path = SavPathParser.parse('M0 0 L10 0 L10 10');
      final implicit = SavPathParser.parse('M0 0 L10 0 10 10');
      expect(implicit.getBounds(), path.getBounds());
    });

    test('closes a subpath and returns to its start', () {
      final path = SavPathParser.parse('M10 10 H30 V30 Z');
      expect(path.contains(const Offset(15, 15)), isTrue);
      expect(path.getBounds(), const Rect.fromLTRB(10, 10, 30, 30));
    });

    test('parses cubic curves', () {
      // `getBounds` reports the control-point hull, not the tight curve
      // bounds, so this is the extent of the control points.
      final path = SavPathParser.parse('M0 0 C0 10 10 10 10 0');
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 10, 10));

      // Hit-testing proves an actual curve was built rather than a straight
      // line: this cubic peaks at y = 7.5, well short of its controls at 10.
      final closed = SavPathParser.parse('M0 0 C0 10 10 10 10 0 Z');
      expect(closed.contains(const Offset(5, 5)), isTrue);
      expect(closed.contains(const Offset(5, 9)), isFalse);
    });

    test('reflects the control point for smooth curves', () {
      // S after C mirrors the previous control point, so this is symmetric.
      final path = SavPathParser.parse('M0 0 C0 10 10 10 10 0 S20 -10 20 0');
      final bounds = path.getBounds();
      expect(bounds.left, 0);
      expect(bounds.right, 20);
      expect(bounds.top, lessThan(0));
      expect(bounds.bottom, greaterThan(0));
    });

    test('parses quadratic curves and their smooth form', () {
      final path = SavPathParser.parse('M0 0 Q5 10 10 0 T20 0');
      expect(path.getBounds().left, 0);
      expect(path.getBounds().right, 20);
    });

    test('parses exponent notation', () {
      final path = SavPathParser.parse('M0 0 L1e2 5e-1');
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 100, 0.5));
    });

    test('honours the fill type, which decides whether holes are holes', () {
      // Two nested squares wound the same way: even-odd punches a hole,
      // non-zero does not. Getting this wrong silently fills the logo's
      // counters.
      const nested = 'M0 0 H100 V100 H0 Z M25 25 H75 V75 H25 Z';
      final evenOdd = SavPathParser.parse(
        nested,
        fillType: PathFillType.evenOdd,
      );
      final nonZero = SavPathParser.parse(nested);

      expect(evenOdd.contains(const Offset(50, 50)), isFalse);
      expect(nonZero.contains(const Offset(50, 50)), isTrue);
      // Both still cover the ring between the squares.
      expect(evenOdd.contains(const Offset(10, 50)), isTrue);
      expect(nonZero.contains(const Offset(10, 50)), isTrue);
    });

    group('errors', () {
      test('rejects elliptical arcs rather than drawing them wrong', () {
        expect(
          () => SavPathParser.parse('M0 0 A5 5 0 0 1 10 10'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('arcs are not supported'),
            ),
          ),
        );
      });

      test('rejects data that does not start with a command', () {
        expect(
          () => SavPathParser.parse('10 20 L30 40'),
          throwsFormatException,
        );
      });

      test('rejects a missing number', () {
        expect(() => SavPathParser.parse('M0 0 L'), throwsFormatException);
      });
    });
  });
}
