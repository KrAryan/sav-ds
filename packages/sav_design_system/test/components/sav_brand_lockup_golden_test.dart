import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/golden_tolerance.dart';
import '../helpers/harness.dart';

/// Pixel-level regression cover for the Figma brand lockup (node `173:329`),
/// across its five `Colour` variants and the `productName` toggle.
///
/// ## Why these run at a wider tolerance
///
/// Measured on a Linux runner, these goldens differ from the macOS masters by
/// 0.80% — sixteen times the button goldens' 0.048%, even though the artwork is
/// smaller. Two things stack up: the frame is 80,000 px against the buttons'
/// 480,000, and the content is almost entirely edges. 62% of the difference is
/// the product name's glyph antialiasing and the rest is curve rasterisation on
/// the badge and wordmark. None of it is visible — most deltas are one or two
/// levels — but as a *fraction of the frame* it dwarfs the default.
///
/// ## What that costs, and what covers it instead
///
/// A tolerance wide enough for 0.80% also swallows a wrong colourway, which
/// repaints only the badge — about 1.4% of the frame. So these images are a
/// visual backstop for layout and geometry, **not** the guard on colour. That
/// job belongs to `sav_brand_lockup_test.dart`, which asserts the ramp pairs
/// exactly and samples the painted pixels to prove the injected gradient
/// actually reached them.
///
/// ```sh
/// flutter test --update-goldens
/// ```
void main() {
  setUpAll(loadSavFonts);
  // 2.5x the measured 0.80% floor, so a slower or newer runner has headroom.
  setUpAll(() => SavGoldenTolerance.use(0.02));
  tearDownAll(() => SavGoldenTolerance.current = SavGoldenTolerance.standard);

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
