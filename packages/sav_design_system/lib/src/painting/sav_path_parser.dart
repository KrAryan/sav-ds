import 'dart:ui';

/// Parses SVG path data — the `d` attribute — into a Flutter [Path].
///
/// Vector artwork in this package is kept as the **path strings Figma exports**
/// rather than as bundled `.svg` files. That keeps the design system free of
/// third-party dependencies (no `flutter_svg`), and it means colours can be
/// injected at paint time instead of being baked into one asset per colourway
/// — five brand colourways come from one set of strings.
///
/// Supports the command set Figma emits: `M L H V C S Q T Z`, absolute and
/// relative. Elliptical arcs (`A`/`a`) are **not** supported and throw, rather
/// than silently drawing the wrong shape.
abstract final class SavPathParser {
  /// Parses [data] into a [Path] with the given [fillType].
  ///
  /// Throws [FormatException] on malformed or unsupported data.
  static Path parse(
    String data, {
    PathFillType fillType = PathFillType.nonZero,
  }) {
    final path = Path()..fillType = fillType;
    final scanner = _Scanner(data);

    // Current point, subpath start, and the previous curve's control point —
    // the last of these is what `S`/`T` reflect around.
    var current = Offset.zero;
    var start = Offset.zero;
    Offset? lastCubicControl;
    Offset? lastQuadControl;
    var command = '';

    while (!scanner.atEnd) {
      final next = scanner.tryCommand();
      if (next != null) {
        command = next;
      } else if (command.isEmpty) {
        throw FormatException('Path data must start with a command', data);
      } else if (command == 'M') {
        // A repeated coordinate pair after `M` is an implicit `L`, per spec.
        command = 'L';
      } else if (command == 'm') {
        command = 'l';
      }

      final relative = command.toLowerCase() == command;
      Offset resolve(Offset point) => relative ? current + point : point;

      switch (command.toUpperCase()) {
        case 'M':
          current = resolve(scanner.point());
          start = current;
          path.moveTo(current.dx, current.dy);
          lastCubicControl = null;
          lastQuadControl = null;

        case 'L':
          current = resolve(scanner.point());
          path.lineTo(current.dx, current.dy);
          lastCubicControl = null;
          lastQuadControl = null;

        case 'H':
          final x = scanner.number();
          current = Offset(relative ? current.dx + x : x, current.dy);
          path.lineTo(current.dx, current.dy);
          lastCubicControl = null;
          lastQuadControl = null;

        case 'V':
          final y = scanner.number();
          current = Offset(current.dx, relative ? current.dy + y : y);
          path.lineTo(current.dx, current.dy);
          lastCubicControl = null;
          lastQuadControl = null;

        case 'C':
          final c1 = resolve(scanner.point());
          final c2 = resolve(scanner.point());
          current = resolve(scanner.point());
          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, current.dx, current.dy);
          lastCubicControl = c2;
          lastQuadControl = null;

        case 'S':
          // Smooth cubic: the first control point mirrors the previous one.
          final c1 = lastCubicControl == null
              ? current
              : current * 2 - lastCubicControl;
          final c2 = resolve(scanner.point());
          current = resolve(scanner.point());
          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, current.dx, current.dy);
          lastCubicControl = c2;
          lastQuadControl = null;

        case 'Q':
          final c = resolve(scanner.point());
          current = resolve(scanner.point());
          path.quadraticBezierTo(c.dx, c.dy, current.dx, current.dy);
          lastQuadControl = c;
          lastCubicControl = null;

        case 'T':
          // Smooth quadratic: the control point mirrors the previous one.
          final c = lastQuadControl == null
              ? current
              : current * 2 - lastQuadControl;
          current = resolve(scanner.point());
          path.quadraticBezierTo(c.dx, c.dy, current.dx, current.dy);
          lastQuadControl = c;
          lastCubicControl = null;

        case 'Z':
          path.close();
          current = start;
          lastCubicControl = null;
          lastQuadControl = null;

        case 'A':
          throw FormatException(
            'Elliptical arcs are not supported by SavPathParser. Ask the '
            'designer to outline the stroke, or extend this parser.',
            data,
            scanner.offset,
          );

        default:
          throw FormatException(
            'Unknown path command "$command"',
            data,
            scanner.offset,
          );
      }

      scanner.skipSeparators();
    }

    return path;
  }
}

/// A cursor over path data, yielding commands and numbers.
class _Scanner {
  _Scanner(this._data) {
    skipSeparators();
  }

  final String _data;
  int _offset = 0;

  /// Current position, for error reporting.
  int get offset => _offset;

  bool get atEnd => _offset >= _data.length;

  /// Consumes the next character if it is a command letter.
  String? tryCommand() {
    if (atEnd) return null;
    final char = _data[_offset];
    if (_isCommand(char)) {
      _offset++;
      skipSeparators();
      return char;
    }
    return null;
  }

  /// Reads an `x y` pair.
  Offset point() => Offset(number(), number());

  /// Reads one number, including exponent notation.
  double number() {
    skipSeparators();
    final startIndex = _offset;

    if (!atEnd && (_data[_offset] == '-' || _data[_offset] == '+')) _offset++;
    while (!atEnd && _isDigit(_data[_offset])) {
      _offset++;
    }
    if (!atEnd && _data[_offset] == '.') {
      _offset++;
      while (!atEnd && _isDigit(_data[_offset])) {
        _offset++;
      }
    }
    if (!atEnd && (_data[_offset] == 'e' || _data[_offset] == 'E')) {
      _offset++;
      if (!atEnd && (_data[_offset] == '-' || _data[_offset] == '+')) _offset++;
      while (!atEnd && _isDigit(_data[_offset])) {
        _offset++;
      }
    }

    final text = _data.substring(startIndex, _offset);
    final value = double.tryParse(text);
    if (value == null) {
      throw FormatException('Expected a number', _data, startIndex);
    }
    skipSeparators();
    return value;
  }

  /// Skips whitespace and commas, which SVG treats interchangeably.
  void skipSeparators() {
    while (!atEnd) {
      final char = _data[_offset];
      if (char == ' ' ||
          char == ',' ||
          char == '\n' ||
          char == '\r' ||
          char == '\t') {
        _offset++;
      } else {
        break;
      }
    }
  }

  static bool _isDigit(String char) => char.codeUnitAt(0) ^ 0x30 <= 9;

  static bool _isCommand(String char) {
    final code = char.toUpperCase().codeUnitAt(0);
    return code == 0x4D || // M
        code == 0x4C || // L
        code == 0x48 || // H
        code == 0x56 || // V
        code == 0x43 || // C
        code == 0x53 || // S
        code == 0x51 || // Q
        code == 0x54 || // T
        code == 0x41 || // A
        code == 0x5A; // Z
  }
}
