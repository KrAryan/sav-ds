import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

/// Pixel-level regression cover for the six states of the Figma `Button`
/// component (node `86:4022`).
///
/// These are the guard against silent drift in the squircle geometry, the
/// gradients, the grain and the shadows — none of which the behavioural tests
/// can see. Regenerate deliberately with:
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
    // `matchesGoldenFile` rasterises through `OffsetLayer.toImage`, which is
    // fixed at one device pixel per logical pixel. flutter_test's view defaults
    // to a density of 3, so without this the grain would be scaled for a
    // density the capture never uses and every golden would be three times
    // finer than what it depicts.
    //
    // `physicalSize` is pinned alongside it because the logical surface is
    // derived from the two together; changing only the density would resize
    // the frame.
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(savHarness(child: child));
    // Let the spinner reach a fixed rotation. A quarter turn is far enough from
    // 0 and 0.5 that an accidental reset would be obvious in the image.
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byKey(savGoldenKey),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  group('SavButton goldens', () {
    testWidgets('primary / default', (tester) async {
      await expectGolden(
        tester,
        'button_primary_default',
        child: SavButton.primary(label: 'Label', onPressed: () {}),
      );
    });

    testWidgets('primary / disabled', (tester) async {
      await expectGolden(
        tester,
        'button_primary_disabled',
        child: const SavButton.primary(label: 'Label', onPressed: null),
      );
    });

    testWidgets('primary / loading', (tester) async {
      await expectGolden(
        tester,
        'button_primary_loading',
        child: SavButton.primary(
          label: 'Label',
          onPressed: () {},
          isLoading: true,
        ),
      );
    });

    testWidgets('secondary / default', (tester) async {
      await expectGolden(
        tester,
        'button_secondary_default',
        child: SavButton.secondary(label: 'Label', onPressed: () {}),
      );
    });

    testWidgets('secondary / disabled', (tester) async {
      await expectGolden(
        tester,
        'button_secondary_disabled',
        child: const SavButton.secondary(label: 'Label', onPressed: null),
      );
    });

    testWidgets('secondary / loading', (tester) async {
      await expectGolden(
        tester,
        'button_secondary_loading',
        child: SavButton.secondary(
          label: 'Label',
          onPressed: () {},
          isLoading: true,
        ),
      );
    });
  });
}
