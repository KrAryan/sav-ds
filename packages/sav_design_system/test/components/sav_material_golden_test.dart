import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

/// Pixel-level regression cover for the Figma `Material` surfaces
/// (nodes `86:4046` default and `86:4039` / `93:4092` tonal).
///
/// The sheen and the tonal wash are very subtle over white, so these are
/// captured over the Sterling ground used elsewhere, at the 239x69 size the
/// component is drawn at in Figma.
///
/// ```sh
/// flutter test --update-goldens
/// ```
void main() {
  Future<void> expectGolden(
    WidgetTester tester,
    String name, {
    SavMaterialAccent? accent,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(320, 160);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      savHarness(
        width: 239,
        child: SavMaterial(
          accent: accent,
          child: const SizedBox(height: 69),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byKey(savGoldenKey),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  group('SavMaterial goldens', () {
    testWidgets('default', (tester) async {
      await expectGolden(tester, 'material_default');
    });

    // One representative tonal per hue family, so a shift in the accent stop or
    // a wrong /100 shows up. The remaining accents differ only in that colour,
    // which the unit test already pins exactly.
    testWidgets('tonal / lush capital', (tester) async {
      await expectGolden(
        tester,
        'material_tonal_lush_capital',
        accent: SavMaterialAccent.lushCapital,
      );
    });

    testWidgets('tonal / purple power', (tester) async {
      await expectGolden(
        tester,
        'material_tonal_purple_power',
        accent: SavMaterialAccent.purplePower,
      );
    });

    testWidgets('tonal / bronze bounty', (tester) async {
      await expectGolden(
        tester,
        'material_tonal_bronze_bounty',
        accent: SavMaterialAccent.bronzeBounty,
      );
    });
  });
}
