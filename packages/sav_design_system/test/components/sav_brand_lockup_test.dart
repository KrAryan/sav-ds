import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  final theme = SavBrandLockupTheme.standard();

  group('SavBrandColourway', () {
    test('every chromatic colourway runs its ramp /800 into /600', () {
      // The rule the whole set follows. A wrong pairing is subtle on screen
      // but wrong in the brand.
      const expected = <SavBrandColourway, (Color, Color)>{
        SavBrandColourway.wealthWeave: (
          SavColors.wealthWeave800,
          SavColors.wealthWeave600,
        ),
        SavBrandColourway.purplePower: (
          SavColors.purplePower800,
          SavColors.purplePower600,
        ),
        SavBrandColourway.cyanReserve: (
          SavColors.cyanReserve800,
          SavColors.cyanReserve600,
        ),
        SavBrandColourway.goldStandard: (
          SavColors.goldStandard800,
          SavColors.goldStandard600,
        ),
      };

      for (final entry in expected.entries) {
        expect(entry.key.shadow, entry.value.$1, reason: entry.key.name);
        expect(entry.key.light, entry.value.$2, reason: entry.key.name);
      }
    });

    test('the neutral colourway runs Obsidian into Sterling', () {
      // The one that breaks the /800 -> /600 rule, because Sav Primary has no
      // numbered steps.
      expect(SavBrandColourway.neutral.shadow, SavColors.savPrimaryObsidian);
      expect(SavBrandColourway.neutral.light, SavColors.savPrimarySterling);
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
