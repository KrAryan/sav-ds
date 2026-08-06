import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  final theme = SavBrandLockupTheme.standard();

  group('SavBrandColourway', () {
    test(
      'every chromatic colourway takes /800, /600 and /700 from one ramp',
      () {
        // The rule the whole set follows: gradient /800 into /600, wordmark /700
        // between them. A wrong pairing is subtle on screen but wrong in the
        // brand.
        const expected = <SavBrandColourway, (Color, Color, Color)>{
          SavBrandColourway.wealthWeave: (
            SavColors.wealthWeave800,
            SavColors.wealthWeave600,
            SavColors.wealthWeave700,
          ),
          SavBrandColourway.purplePower: (
            SavColors.purplePower800,
            SavColors.purplePower600,
            SavColors.purplePower700,
          ),
          SavBrandColourway.cyanReserve: (
            SavColors.cyanReserve800,
            SavColors.cyanReserve600,
            SavColors.cyanReserve700,
          ),
          SavBrandColourway.goldStandard: (
            SavColors.goldStandard800,
            SavColors.goldStandard600,
            SavColors.goldStandard700,
          ),
        };

        for (final entry in expected.entries) {
          expect(entry.key.shadow, entry.value.$1, reason: entry.key.name);
          expect(entry.key.light, entry.value.$2, reason: entry.key.name);
          expect(entry.key.wordmark, entry.value.$3, reason: entry.key.name);
        }
      },
    );

    test('the neutral colourway runs Obsidian into Sterling', () {
      // The one that breaks the ramp rule, because Sav Primary has no numbered
      // steps.
      expect(SavBrandColourway.neutral.shadow, SavColors.savPrimaryObsidian);
      expect(SavBrandColourway.neutral.light, SavColors.savPrimarySterling);
      expect(SavBrandColourway.neutral.wordmark, SavColors.savPrimaryObsidian);
    });

    test('no two colourways share a wordmark colour', () {
      // The wordmark recolours with the badge; if it did not, four of the five
      // variants would be indistinguishable in the "Sav" glyphs.
      final wordmarks = SavBrandColourway.values.map((c) => c.wordmark).toSet();
      expect(wordmarks, hasLength(SavBrandColourway.values.length));
    });

    test('covers exactly the five Figma variants', () {
      expect(SavBrandColourway.values, hasLength(5));
    });
  });

  group('gradient injection', () {
    test('builds a gradient from any colour pair', () {
      // The point of parsing the artwork from strings: colours are injected at
      // paint time, so one set of paths serves every colourway.
      final gradient = theme.badgeGradient(<Color>[
        SavColors.satinVault800,
        SavColors.satinVault600,
      ]);

      expect(gradient.colors, <Color>[
        SavColors.satinVault800,
        SavColors.satinVault600,
      ]);
      expect(gradient.stops, <double>[0.5, 1]);
    });

    test('carries the Figma gradient transform unchanged', () {
      final gradient = theme.badgeGradient(SavBrandColourway.neutral.colors);
      expect(gradient.a, -12.9325);
      expect(gradient.b, 15.0646);
      expect(gradient.c, -21.9379);
      expect(gradient.d, -18.3367);
      expect(gradient.e, 17.8781);
      expect(gradient.f, 17.8229);
      expect(gradient.referenceSize, SavLogoArtwork.viewBox);
    });

    test('rejects a colour count that does not match the stops', () {
      expect(
        () => theme.badgeGradient(<Color>[SavColors.savPrimaryObsidian]),
        throwsAssertionError,
      );
    });
  });

  group('SavLogoArtwork', () {
    test('parses the badge, keeping the mark as a hole', () {
      final badge = SavLogoArtwork.badge;
      // Filled body of the badge, left of the mark.
      expect(badge.contains(const Offset(3, 17.8)), isTrue);
      // The "S" counter is cut out, so the centre is not filled.
      expect(badge.contains(const Offset(17.9, 17.8)), isFalse);
    });

    test('badge fills its side of the view box', () {
      final bounds = SavLogoArtwork.badge.getBounds();
      expect(bounds.left, closeTo(0, 0.01));
      expect(bounds.top, closeTo(0, 0.01));
      expect(bounds.width, closeTo(35.7563, 0.01));
      expect(bounds.height, closeTo(SavLogoArtwork.viewBox.height, 0.01));
    });

    test('wordmark sits to the right of the badge', () {
      final bounds = SavLogoArtwork.wordmark.getBounds();
      expect(bounds.left, greaterThan(35.7563));
      expect(bounds.right, closeTo(SavLogoArtwork.viewBox.width, 0.01));
    });

    test("keeps the 'a' counter open", () {
      // The 'a' is even-odd while its siblings are non-zero; combining them
      // under one rule would fill the bowl.
      final wordmark = SavLogoArtwork.wordmark;
      expect(wordmark.contains(const Offset(62.8, 19.8)), isFalse);
      // The stroke around it is still filled.
      expect(wordmark.contains(const Offset(62.8, 14.5)), isTrue);
    });

    test('parses each path only once', () {
      expect(identical(SavLogoArtwork.badge, SavLogoArtwork.badge), isTrue);
      expect(
        identical(SavLogoArtwork.wordmark, SavLogoArtwork.wordmark),
        isTrue,
      );
    });
  });

  group('SavBrandLockup widget', () {
    testWidgets('shows the product name by default', (tester) async {
      await tester.pumpWidget(
        savHarness(child: const Align(child: SavBrandLockup())),
      );

      expect(find.text('String'), findsOneWidget);
    });

    testWidgets('hides it when showProductName is false', (tester) async {
      await tester.pumpWidget(
        savHarness(
          child: const Align(child: SavBrandLockup(showProductName: false)),
        ),
      );

      expect(find.text('String'), findsNothing);
    });

    testWidgets('accepts a different product name', (tester) async {
      await tester.pumpWidget(
        savHarness(
          child: const Align(child: SavBrandLockup(productName: 'Wealth')),
        ),
      );

      expect(find.text('Wealth'), findsOneWidget);
    });

    testWidgets('is one accessible image, not stray glyph text', (
      tester,
    ) async {
      await tester.pumpWidget(
        savHarness(child: const Align(child: SavBrandLockup())),
      );

      expect(
        tester.getSemantics(find.byType(SavBrandLockup)),
        matchesSemantics(isImage: true, label: 'Sav String'),
      );
    });

    testWidgets('scales without distorting the artwork', (tester) async {
      await tester.pumpWidget(
        savHarness(
          child: const Align(
            child: SavBrandLockup(showProductName: false, height: 64),
          ),
        ),
      );

      final size = tester.getSize(find.byType(CustomPaint).first);
      expect(size.height, 64);
      // Aspect ratio preserved: a squashed logo is a brand problem.
      expect(
        size.width / size.height,
        closeTo(
          SavLogoArtwork.viewBox.width / SavLogoArtwork.viewBox.height,
          0.001,
        ),
      );
    });

    testWidgets('every colourway builds', (tester) async {
      for (final colourway in SavBrandColourway.values) {
        await tester.pumpWidget(
          savHarness(
            child: Align(child: SavBrandLockup(colourway: colourway)),
          ),
        );
        expect(tester.takeException(), isNull, reason: colourway.name);
      }
    });

    testWidgets('falls back to the standard theme when unregistered', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: SavBrandLockup())),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('String'), findsOneWidget);
    });
  });

  group('painted colour', () {
    // The goldens cannot carry this check. A wrong colourway repaints only the
    // badge — about 1.4% of the golden frame — the same order as the
    // cross-platform antialiasing noise their tolerance has to absorb. So the
    // colours are asserted against real rasterised pixels instead, sampled well
    // inside the silhouette where antialiasing is irrelevant.
    //
    // The badge is rasterised straight from a `PictureRecorder` rather than
    // captured from the widget tree: `RenderRepaintBoundary.toImage` never
    // completes under `flutter_test`, while recording a picture does.
    Future<List<Color>> paintBadge(List<Color> gradientColors) async {
      const view = SavLogoArtwork.viewBox;
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawPath(
        SavLogoArtwork.badge,
        Paint()
          ..shader = theme
              .badgeGradient(gradientColors)
              .createShader(Offset.zero & view),
      );
      final picture = recorder.endRecording();
      final image = picture.toImageSync(36, 36);
      final data = (await image.toByteData())!.buffer.asUint8List();
      picture.dispose();
      image.dispose();

      // Points inside the badge, clear of its edge and of the "S" counter.
      const samples = <Offset>[Offset(6, 10), Offset(6, 26), Offset(30, 18)];
      return <Color>[
        for (final point in samples)
          () {
            final i = (point.dy.toInt() * 36 + point.dx.toInt()) * 4;
            return Color.fromARGB(
              data[i + 3],
              data[i],
              data[i + 1],
              data[i + 2],
            );
          }(),
      ];
    }

    test('neutral paints greyscale', () async {
      final colors = await paintBadge(SavBrandColourway.neutral.colors);

      for (final color in colors) {
        expect(color.a, 1.0, reason: 'badge should be opaque');
        // Obsidian into Sterling has no hue.
        expect((color.r - color.g).abs(), lessThan(0.02), reason: '$color');
        expect((color.g - color.b).abs(), lessThan(0.02), reason: '$color');
      }
    });

    test('each chromatic colourway paints its own hue', () async {
      // The relationships that must hold if the right ramp was injected.
      final checks = <SavBrandColourway, bool Function(Color)>{
        // Wealth Weave is blue.
        SavBrandColourway.wealthWeave: (c) => c.b > c.r && c.b > c.g,
        // Purple Power is violet: red and blue both lead green.
        SavBrandColourway.purplePower: (c) => c.b > c.g && c.r > c.g,
        // Cyan Reserve is teal: green and blue both lead red.
        SavBrandColourway.cyanReserve: (c) => c.g > c.r && c.b > c.r,
        // Gold Standard is warm: red and green both lead blue.
        SavBrandColourway.goldStandard: (c) => c.r > c.b && c.g > c.b,
      };

      for (final entry in checks.entries) {
        final colors = await paintBadge(entry.key.colors);
        for (final color in colors) {
          expect(
            entry.value(color),
            isTrue,
            reason: '${entry.key.name} painted $color',
          );
        }
      }
    });

    // The wordmark is painted as vector glyphs, so a wrong colour is invisible
    // to the widget tests and hidden by the goldens' tolerance. Rasterised and
    // sampled, it is exact.
    Future<Color> paintWordmark(Color color) async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawPath(
        SavLogoArtwork.wordmark,
        Paint()..color = color,
      );
      final picture = recorder.endRecording();
      // The wordmark occupies x 43..83 of the view box; crop to it.
      final image = picture.toImageSync(84, 36);
      final data = (await image.toByteData())!.buffer.asUint8List();
      picture.dispose();
      image.dispose();

      // Found rather than guessed: the glyphs are thin and irregular, so a
      // hand-picked coordinate easily lands in a counter or between strokes.
      // Take a point the path itself reports as inside, with its neighbours
      // inside too so the sample is clear of any antialiased edge.
      final point = _interiorPoint(SavLogoArtwork.wordmark);
      final i = (point.dy.toInt() * 84 + point.dx.toInt()) * 4;
      return Color.fromARGB(data[i + 3], data[i], data[i + 1], data[i + 2]);
    }

    test('the wordmark paints its colourway tone, not a fixed one', () async {
      for (final colourway in SavBrandColourway.values) {
        final painted = await paintWordmark(colourway.wordmark);
        expect(
          painted,
          colourway.wordmark,
          reason: '${colourway.name} wordmark',
        );
      }
    });

    test('the product name style is constant across colourways', () async {
      // Only the badge and wordmark recolour. If the product name ever picked
      // up the ramp, the lockup would read as one coloured blob.
      const theme = SavBrandLockupTheme.standard;
      final style = theme().productNameStyle;
      expect(style.color, SavColors.savPrimaryObsidian.withValues(alpha: 0.8));
      // It is not tied to any colourway's tone.
      for (final colourway in SavBrandColourway.values) {
        expect(style.color, isNot(colourway.wordmark));
        expect(style.color, isNot(colourway.shadow));
      }
    });

    test('a custom injected pair reaches the pixels', () async {
      // The whole point of injecting gradients rather than bundling assets.
      final colors = await paintBadge(<Color>[
        SavColors.satinVault800,
        SavColors.satinVault600,
      ]);

      // Satin Vault is a mauve: red leads green throughout the ramp.
      for (final color in colors) {
        expect(color.r, greaterThan(color.g), reason: '$color');
      }
    });
  });
}

/// A point comfortably inside [path] — inside itself and on all four sides,
/// so a sample there cannot pick up an antialiased edge.
Offset _interiorPoint(Path path) {
  final bounds = path.getBounds();
  for (var y = bounds.top.ceil(); y < bounds.bottom; y++) {
    for (var x = bounds.left.ceil(); x < bounds.right; x++) {
      final point = Offset(x + 0.5, y + 0.5);
      final clear =
          path.contains(point) &&
          path.contains(point.translate(-1, 0)) &&
          path.contains(point.translate(1, 0)) &&
          path.contains(point.translate(0, -1)) &&
          path.contains(point.translate(0, 1));
      if (clear) return Offset(x.toDouble(), y.toDouble());
    }
  }
  throw StateError('No interior point found in $bounds');
}
