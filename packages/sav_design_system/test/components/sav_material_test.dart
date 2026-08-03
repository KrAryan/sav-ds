import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  final theme = SavMaterialTheme.standard();

  group('SavMaterialTheme.gradient', () {
    test('default is the neutral sheen: Lumen, White, White, Lumen', () {
      final gradient = theme.gradient();

      expect(gradient.colors, <Color>[
        SavColors.savPrimaryLumen,
        SavColors.savPrimaryWhite,
        SavColors.savPrimaryWhite,
        SavColors.savPrimaryLumen,
      ]);
      // The exact stop positions Figma exports.
      expect(gradient.stops, <double>[0.10, 0.40, 0.82274, 1]);
    });

    test('tonal inserts one accent stop at 0.69353, ends untouched', () {
      final gradient = theme.gradient(SavMaterialAccent.lushCapital);

      expect(gradient.colors, <Color>[
        SavColors.savPrimaryLumen,
        SavColors.savPrimaryWhite,
        SavColors.lushCapital100, // the /100 wash
        SavColors.savPrimaryWhite,
        SavColors.savPrimaryLumen,
      ]);
      expect(gradient.stops, <double>[0.10, 0.40, 0.69353, 0.82274, 1]);
    });

    test('every accent resolves to its ramp /100', () {
      // The mapping that the whole "tonal" idea rests on. A wrong entry here is
      // invisible until someone notices the wash is the wrong colour.
      const expected = <SavMaterialAccent, Color>{
        SavMaterialAccent.wealthWeave: SavColors.wealthWeave100,
        SavMaterialAccent.lushCapital: SavColors.lushCapital100,
        SavMaterialAccent.goldStandard: SavColors.goldStandard100,
        SavMaterialAccent.purplePower: SavColors.purplePower100,
        SavMaterialAccent.cyanReserve: SavColors.cyanReserve100,
        SavMaterialAccent.satinVault: SavColors.satinVault100,
        SavMaterialAccent.bronzeBounty: SavColors.bronzeBounty100,
      };

      // Guards against a ramp being added without a matching accent.
      expect(expected.length, SavMaterialAccent.values.length);
      for (final accent in SavMaterialAccent.values) {
        expect(accent.tint, expected[accent], reason: accent.name);
        expect(theme.gradient(accent).colors[2], expected[accent]);
      }
    });

    test('carries the Figma angle as a rotation', () {
      final gradient = theme.gradient();
      expect(gradient.transform, isA<GradientRotation>());
      final rotation = gradient.transform! as GradientRotation;
      // (163.896 - 90) degrees in radians.
      expect(rotation.radians, closeTo(1.28974, 0.0001));
    });

    test('an opaque fill keeps the stops fully opaque', () {
      for (final color in theme.gradient().colors) {
        expect(color.a, 1.0);
      }
    });

    test('a translucent fill scales every stop', () {
      final faded = theme.copyWith(fillOpacity: 0.5).gradient();
      for (final color in faded.colors) {
        expect(color.a, closeTo(0.5, 0.001));
      }
    });
  });

  group('SavMaterial widget', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        savHarness(
          background: SavColors.savPrimarySlate,
          child: const SavMaterial(child: Text('Balance')),
        ),
      );

      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('applies the border and shadow from the theme', (tester) async {
      await tester.pumpWidget(
        savHarness(
          background: SavColors.savPrimarySlate,
          child: const SavMaterial(child: SizedBox(width: 200, height: 80)),
        ),
      );

      // Border + gradient live on the inner container.
      final fill = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (c) => (c.decoration as BoxDecoration?)?.gradient != null,
          );
      final decoration = fill.decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.gradient, isNotNull);

      // Shadow is hung on an outer DecoratedBox so a clip can't eat it.
      final shadowed = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.boxShadow != null);
      expect(shadowed.boxShadow!.single, theme.shadow);
    });

    testWidgets('skips the backdrop blur while the fill is opaque', (
      tester,
    ) async {
      await tester.pumpWidget(
        savHarness(
          background: SavColors.savPrimarySlate,
          child: const SavMaterial(child: SizedBox(width: 200, height: 80)),
        ),
      );

      // An opaque surface hides the blur, so paying for the layer would be
      // waste. The default theme is opaque, so there must be no BackdropFilter.
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('adds the backdrop blur once the fill is translucent', (
      tester,
    ) async {
      final base = SavTheme.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: base.copyWith(
            extensions: <ThemeExtension<dynamic>>[
              base.extension<SavMaterialTheme>()!.copyWith(fillOpacity: 0.6),
            ],
          ),
          home: const Scaffold(
            body: Center(
              child: SavMaterial(child: SizedBox(width: 200, height: 80)),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('every accent builds', (tester) async {
      for (final accent in SavMaterialAccent.values) {
        await tester.pumpWidget(
          savHarness(
            background: SavColors.savPrimarySlate,
            child: SavMaterial(
              accent: accent,
              child: const SizedBox(width: 200, height: 80),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: accent.name);
      }
    });

    testWidgets('falls back to the standard theme when unregistered', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SavMaterial(child: Text('Balance')),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Balance'), findsOneWidget);
    });
  });
}
