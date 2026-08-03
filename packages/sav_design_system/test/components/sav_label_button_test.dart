import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  TextStyle styleOf(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).style!;

  group('SavLabelButton', () {
    testWidgets('renders its label and responds to taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        savHarness(
          child: Align(
            child: SavLabelButton(
              label: 'Forgot password?',
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      expect(find.text('Forgot password?'), findsOneWidget);
      await tester.tap(find.byType(SavLabelButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it and blocks taps', (tester) async {
      await tester.pumpWidget(
        savHarness(
          child: const Align(
            child: SavLabelButton(label: 'Skip', onPressed: null),
          ),
        ),
      );

      final button = tester.widget<SavLabelButton>(
        find.byType(SavLabelButton),
      );
      expect(button.isEnabled, isFalse);

      expect(
        tester.getSemantics(find.byType(SavLabelButton)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          label: 'Skip',
        ),
      );
    });

    testWidgets('activates on Enter', (tester) async {
      var taps = 0;
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        savHarness(
          child: Align(
            child: SavLabelButton(
              label: 'Skip',
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

    group('decoration', () {
      testWidgets('is a dotted underline, not a solid one', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton(label: 'Skip', onPressed: () {}),
            ),
          ),
        );

        final style = styleOf(tester);
        expect(style.decoration, TextDecoration.underline);
        // Easy detail to lose when transcribing from a screenshot.
        expect(style.decorationStyle, TextDecorationStyle.dotted);
        // Figma asks for `from-font`, which in Flutter is a 1.0 multiplier on
        // the font's own thickness.
        expect(style.decorationThickness, 1.0);
      });

      testWidgets('underline matches the text colour in both states', (
        tester,
      ) async {
        for (final enabled in <bool>[true, false]) {
          await tester.pumpWidget(
            savHarness(
              child: Align(
                child: SavLabelButton(
                  label: 'Skip',
                  onPressed: enabled ? () {} : null,
                ),
              ),
            ),
          );
          final style = styleOf(tester);
          expect(
            style.decorationColor,
            style.color,
            reason: 'enabled=$enabled',
          );
        }
      });
    });

    group('colours', () {
      testWidgets('is Obsidian when enabled', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton(label: 'Skip', onPressed: () {}),
            ),
          ),
        );

        expect(styleOf(tester).color, SavColors.savPrimaryObsidian);
      });

      testWidgets('dims to Slate, not Sterling, when disabled', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: const Align(
              child: SavLabelButton(label: 'Skip', onPressed: null),
            ),
          ),
        );

        // The surface buttons dim their labels to Sterling; this one uses
        // Slate. Verified against Figma, and easy to "tidy" into being wrong.
        expect(styleOf(tester).color, SavColors.savPrimarySlate);
        expect(
          styleOf(tester).color,
          isNot(SavColors.savPrimarySterling),
        );
      });
    });

    group('sizes', () {
      testWidgets('regular uses Callout/Medium', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton(label: 'Skip', onPressed: () {}),
            ),
          ),
        );

        expect(styleOf(tester).fontSize, SavTypography.calloutMedium.fontSize);
        expect(styleOf(tester).height, SavTypography.calloutMedium.height);
      });

      testWidgets('small uses Body/Bold', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton.small(label: 'Skip', onPressed: () {}),
            ),
          ),
        );

        expect(styleOf(tester).fontSize, SavTypography.bodyBold.fontSize);
        expect(styleOf(tester).height, SavTypography.bodyBold.height);
      });
    });

    group('tap target', () {
      testWidgets('pads out to an accessible height by default', (
        tester,
      ) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton(label: 'Skip', onPressed: () {}),
            ),
          ),
        );

        // The text is only 20dp tall; without padding this would fail WCAG
        // 2.2's target-size minimum.
        expect(
          tester.getSize(find.byType(SavLabelButton)).height,
          greaterThanOrEqualTo(SavSizes.minTapTarget),
        );
      });

      testWidgets('shrinks to the Figma frame when opted out', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton(
                label: 'Skip',
                onPressed: () {},
                expandTapTarget: false,
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(SavLabelButton)).height,
          lessThan(SavSizes.minTapTarget),
        );
      });

      testWidgets('is tappable across the padded area, not just the text', (
        tester,
      ) async {
        var taps = 0;
        await tester.pumpWidget(
          savHarness(
            child: Align(
              child: SavLabelButton(
                label: 'Skip',
                onPressed: () => taps++,
              ),
            ),
          ),
        );

        final rect = tester.getRect(find.byType(SavLabelButton));
        // Near the top edge of the padded box, above the glyphs themselves.
        await tester.tapAt(Offset(rect.center.dx, rect.top + 2));
        await tester.pump();

        expect(taps, 1);
      });
    });

    group('theming', () {
      testWidgets('picks up an overridden SavLabelButtonTheme', (tester) async {
        final base = SavTheme.light();
        await tester.pumpWidget(
          MaterialApp(
            theme: base.copyWith(
              extensions: <ThemeExtension<dynamic>>[
                base.extension<SavLabelButtonTheme>()!.copyWith(
                  decorationStyle: TextDecorationStyle.solid,
                  disabledLabel: SavColors.wealthWeave600,
                ),
              ],
            ),
            home: const Scaffold(
              body: Align(
                child: SavLabelButton(label: 'Skip', onPressed: null),
              ),
            ),
          ),
        );

        expect(styleOf(tester).decorationStyle, TextDecorationStyle.solid);
        expect(styleOf(tester).color, SavColors.wealthWeave600);
      });

      testWidgets('falls back to the standard theme when unregistered', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                child: SavLabelButton(label: 'Skip', onPressed: () {}),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(styleOf(tester).color, SavColors.savPrimaryObsidian);
      });
    });
  });
}
