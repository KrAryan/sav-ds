import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

/// Pixel-level regression cover for the four states of the Figma
/// `label button` component (node `116:780`).
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

    await tester.pumpWidget(
      savHarness(
        width: 300,
        // A light ground, which is where a text button actually sits.
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

  group('SavLabelButton goldens', () {
    // Pinned without the accessible tap padding so these compare 1:1 with the
    // Figma frame, which is the text box alone.
    testWidgets('regular / default', (tester) async {
      await expectGolden(
        tester,
        'label_button_regular_default',
        child: SavLabelButton(
          label: 'label button',
          onPressed: () {},
          expandTapTarget: false,
        ),
      );
    });

    testWidgets('regular / disabled', (tester) async {
      await expectGolden(
        tester,
        'label_button_regular_disabled',
        child: const SavLabelButton(
          label: 'label button',
          onPressed: null,
          expandTapTarget: false,
        ),
      );
    });

    testWidgets('small / default', (tester) async {
      await expectGolden(
        tester,
        'label_button_small_default',
        child: SavLabelButton.small(
          label: 'label button',
          onPressed: () {},
          expandTapTarget: false,
        ),
      );
    });

    testWidgets('small / disabled', (tester) async {
      await expectGolden(
        tester,
        'label_button_small_disabled',
        child: const SavLabelButton.small(
          label: 'label button',
          onPressed: null,
          expandTapTarget: false,
        ),
      );
    });
  });
}
