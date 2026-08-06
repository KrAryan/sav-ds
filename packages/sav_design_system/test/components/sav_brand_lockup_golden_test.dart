import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

/// Pixel-level regression cover for the Figma brand lockup (node `173:329`),
/// across its five `Colour` variants and the `productName` toggle.
///
/// ```sh
/// flutter test --update-goldens
/// ```
void main() {
  setUpAll(loadSavFonts);

  Future<void> expectGolden(
    WidgetTester tester,
    String name, {
    required Widget child,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(400, 200);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      savHarness(
        width: 320,
        background: SavColors.savPrimaryLumen,
        child: Align(child: child),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byKey(savGoldenKey),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  group('SavBrandLockup goldens', () {
    for (final colourway in SavBrandColourway.values) {
      testWidgets(colourway.name, (tester) async {
        await expectGolden(
          tester,
          'brand_lockup_${colourway.name}',
          child: SavBrandLockup(colourway: colourway),
        );
      });
    }

    testWidgets('without the product name', (tester) async {
      await expectGolden(
        tester,
        'brand_lockup_logo_only',
        child: const SavBrandLockup(showProductName: false),
      );
    });

    testWidgets('scaled up', (tester) async {
      await expectGolden(
        tester,
        'brand_lockup_scaled',
        child: const SavBrandLockup(
          colourway: SavBrandColourway.purplePower,
          height: 64,
        ),
      );
    });
  });
}
