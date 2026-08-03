import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

/// Pixel-level regression cover for the six states of the Figma
/// `Action Button` component (node `86:4029`).
///
/// Regenerate deliberately with:
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
    // See sav_button_golden_test.dart: `matchesGoldenFile` rasterises at one
    // device pixel per logical pixel, so the view's density has to agree.
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 600);
    addTearDown(tester.view.reset);

    // The button sizes itself to its 148dp minimum, so the harness only needs
    // to be wide enough not to constrain it.
    await tester.pumpWidget(
      savHarness(width: 300, child: Align(child: child)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byKey(savGoldenKey),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  group('SavActionButton goldens', () {
    testWidgets('primary / default', (tester) async {
      await expectGolden(
        tester,
        'action_button_primary_default',
        child: SavActionButton.primary(label: 'Label', onPressed: () {}),
      );
    });

    testWidgets('primary / disabled', (tester) async {
      await expectGolden(
        tester,
        'action_button_primary_disabled',
        child: const SavActionButton.primary(label: 'Label', onPressed: null),
      );
    });

    testWidgets('primary / loading', (tester) async {
      await expectGolden(
        tester,
        'action_button_primary_loading',
        child: SavActionButton.primary(
          label: 'Label',
          onPressed: () {},
          isLoading: true,
        ),
      );
    });

    testWidgets('secondary / default', (tester) async {
      await expectGolden(
        tester,
        'action_button_secondary_default',
        child: SavActionButton.secondary(label: 'Label', onPressed: () {}),
      );
    });

    testWidgets('secondary / disabled', (tester) async {
      await expectGolden(
        tester,
        'action_button_secondary_disabled',
        child: const SavActionButton.secondary(label: 'Label', onPressed: null),
      );
    });

    testWidgets('secondary / loading', (tester) async {
      await expectGolden(
        tester,
        'action_button_secondary_loading',
        child: SavActionButton.secondary(
          label: 'Label',
          onPressed: () {},
          isLoading: true,
        ),
      );
    });
  });
}
