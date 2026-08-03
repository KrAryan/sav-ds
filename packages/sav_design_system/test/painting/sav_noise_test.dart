import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

void main() {
  group('SavNoise', () {
    tearDown(SavNoise.debugReset);

    test('generates a tile of the declared size', () {
      expect(SavNoise.tile.width, SavNoise.tileSize);
      expect(SavNoise.tile.height, SavNoise.tileSize);
    });

    test('caches the tile so every surface shares one texture', () {
      final first = SavNoise.tile;
      final second = SavNoise.tile;
      expect(identical(first, second), isTrue);
    });

    test('caches the shader too', () {
      expect(identical(SavNoise.shader, SavNoise.shader), isTrue);
    });

    // Golden tests compare rendered pixels, so a grain that changed between
    // runs would make every button golden flake.
    test('is byte-for-byte identical across regenerations', () async {
      final first = await _pixels(SavNoise.tile);
      SavNoise.debugReset();
      final second = await _pixels(SavNoise.tile);

      expect(first.lengthInBytes, second.lengthInBytes);
      expect(first.buffer.asUint8List(), second.buffer.asUint8List());
    });

    test('is black with varying alpha, matching the Figma export', () async {
      final data = (await _pixels(SavNoise.tile)).buffer.asUint8List();

      var maxAlpha = 0;
      var alphaSum = 0;
      final pixelCount = data.length ~/ 4;
      for (var i = 0; i < data.length; i += 4) {
        final a = data[i + 3];
        // Stored premultiplied, so a black pixel has zero in every channel.
        expect(data[i], 0, reason: 'red at byte $i');
        expect(data[i + 1], 0, reason: 'green at byte $i');
        expect(data[i + 2], 0, reason: 'blue at byte $i');
        if (a > maxAlpha) maxAlpha = a;
        alphaSum += a;
      }

      // Figma's texture peaks at alpha 102 with the layer at 40% opacity, which
      // this bakes in: 102 * 0.4 = 40.8.
      expect(maxAlpha, lessThanOrEqualTo(41));
      expect(maxAlpha, greaterThan(30), reason: 'grain should reach its peak');

      // Source mean is 21.16 * 0.4 = 8.5.
      final meanAlpha = alphaSum / pixelCount;
      expect(meanAlpha, closeTo(8.5, 2.5));
    });
  });
}

Future<ByteData> _pixels(ui.Image image) async {
  final data = await image.toByteData();
  return data!;
}
