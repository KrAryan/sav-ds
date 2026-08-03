import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  group('SavActionButton', () {
    testWidgets('renders its label and responds to taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        savHarness(
          child: Align(
            child: SavActionButton.primary(
              label: 'Top up',
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      expect(find.text('Top up'), findsOneWidget);
      await tester.tap(find.byType(SavActionButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it', (tester) async {
      await tester.pumpWidget(
        savHarness(
          child: const Align(
            child: SavActionButton.primary(label: 'Top up', onPressed: null),
          ),
        ),
      );

      final button = tester.widget<SavActionButton>(
        find.byType(SavActionButton),
      );
      expect(button.isEnabled, isFalse);
      expect(button.isInteractive, isFalse);
    });

    testWidgets('loading blocks taps and shows a spinner', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        savHarness(
          child: Align(
            child: SavActionButton.primary(
              label: 'Top up',
              onPressed: () => taps++,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(SavSpinner), findsOneWidget);
      await tester.tap(find.byType(SavActionButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('activates on Enter', (tester) async {
      var taps = 0;
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        savHarness(
          child: Align(
            child: SavActionButton.primary(
              label: 'Top up',
              onPressed: () => taps++,
              focusNode: node,
              autofocus: true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(taps, 1);
    });

    group('sizing', () {
      testWidgets('is 40dp tall', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavActionButton.primary(
                label: 'Top up',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(SavActionButton)).height,
          SavSizes.actionButtonHeight,
        );
      });

      testWidgets('holds its Figma width for a short label', (tester) async {
        // The component is a fixed 148dp in Figma with the label centred, so a
        // two-character label must not collapse it.
        await tester.pumpWidget(
          savHarness(
            width: 400,
            child: const Align(
              child: SavActionButton.primary(label: 'OK', onPressed: null),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(SavActionButton)).width,
          SavSizes.actionButtonReferenceWidth,
        );
      });

      testWidgets('grows past its minimum for a long label', (tester) async {
        await tester.pumpWidget(
          savHarness(
            width: 600,
            child: const Align(
              child: SavActionButton.primary(
                label: 'A considerably longer label than the design shows',
                onPressed: null,
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(SavActionButton)).width,
          greaterThan(SavSizes.actionButtonReferenceWidth),
        );
      });

      testWidgets('fills the width when expand is set', (tester) async {
        await tester.pumpWidget(
          savHarness(
            width: 400,
            child: SavActionButton.primary(
              label: 'Top up',
              onPressed: () {},
              expand: true,
            ),
          ),
        );

        expect(tester.getSize(find.byType(SavActionButton)).width, 400);
      });

      testWidgets('is shorter than the regular button', (tester) async {
        // The two components exist precisely to offer different weights; if
        // they ever matched, one of them would be redundant.
        expect(
          SavSizes.actionButtonHeight,
          lessThan(SavSizes.buttonHeight),
        );
      });
    });

    group('theming', () {
      testWidgets('reads the action style, not the regular one', (
        tester,
      ) async {
        final base = SavTheme.light();
        final theme = base.extension<SavButtonTheme>()!;

        await tester.pumpWidget(
          MaterialApp(
            theme: base.copyWith(
              extensions: <ThemeExtension<dynamic>>[
                theme.copyWith(
                  action: theme.action.copyWith(height: 64),
                ),
              ],
            ),
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  SavActionButton.primary(label: 'Action', onPressed: () {}),
                  SavButton.primary(label: 'Regular', onPressed: () {}),
                ],
              ),
            ),
          ),
        );

        expect(tester.getSize(find.byType(SavActionButton)).height, 64);
        // Overriding one component must not disturb the other.
        expect(
          tester.getSize(find.byType(SavButton)).height,
          SavSizes.buttonHeight,
        );
      });

      testWidgets('falls back to the standard style when unregistered', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                child: SavActionButton.primary(
                  label: 'Top up',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(SavActionButton)).height,
          SavSizes.actionButtonHeight,
        );
      });
    });

    testWidgets('both variants build', (tester) async {
      for (final variant in SavButtonVariant.values) {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavActionButton(
                label: 'Top up',
                onPressed: () {},
                variant: variant,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$variant');
      }
    });
  });

  group('spinner geometry', () {
    // The golden tolerance that absorbs cross-platform glyph antialiasing is
    // also wide enough to hide a small circle changing size — the corrected
    // radius here moved the loading goldens by only 0.038%. So the number is
    // asserted directly against Figma rather than left to the images.
    test('matches the radii Figma draws at both sizes', () {
      expect(
        SavSizes.spinnerSize * SavSizes.spinnerRadiusRatio,
        closeTo(8.3333, 0.0005),
      );
      expect(
        SavSizes.actionSpinnerSize * SavSizes.spinnerRadiusRatio,
        closeTo(7.5, 0.0005),
      );
    });
  });
}
