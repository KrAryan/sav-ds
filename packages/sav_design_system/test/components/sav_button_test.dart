import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  group('SavButton', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        savHarness(
          child: SavButton.primary(label: 'Continue', onPressed: () {}),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        savHarness(
          child: SavButton.primary(label: 'Continue', onPressed: () => taps++),
        ),
      );

      await tester.tap(find.byType(SavButton));
      await tester.pump();

      expect(taps, 1);
    });

    group('disabled', () {
      testWidgets('is derived from a null onPressed', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: const SavButton.primary(label: 'Continue', onPressed: null),
          ),
        );

        final button = tester.widget<SavButton>(find.byType(SavButton));
        expect(button.isEnabled, isFalse);
        expect(button.isInteractive, isFalse);
      });

      testWidgets('ignores taps', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: const SavButton.primary(label: 'Continue', onPressed: null),
          ),
        );

        // Nothing to assert a callback against, so assert the semantics node
        // reports the button as unavailable instead.
        expect(
          tester.getSemantics(find.byType(SavButton)),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            label: 'Continue',
          ),
        );
      });

      testWidgets('cannot take focus', (tester) async {
        final node = FocusNode();
        addTearDown(node.dispose);

        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(
              label: 'Continue',
              onPressed: null,
              focusNode: node,
            ),
          ),
        );
        node.requestFocus();
        await tester.pump();

        expect(node.hasFocus, isFalse);
      });
    });

    group('loading', () {
      testWidgets('shows a spinner instead of the label', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(
              label: 'Continue',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        );

        expect(find.byType(SavSpinner), findsOneWidget);
        // The label stays in the tree — hidden, not removed — so the button
        // keeps its width.
        final opacity = tester.widget<Opacity>(
          find.ancestor(
            of: find.text('Continue'),
            matching: find.byType(Opacity),
          ),
        );
        expect(opacity.opacity, 0);
      });

      testWidgets('blocks taps', (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(
              label: 'Continue',
              onPressed: () => taps++,
              isLoading: true,
            ),
          ),
        );

        await tester.tap(find.byType(SavButton));
        await tester.pump();

        expect(taps, 0);
      });

      testWidgets('keeps the same width as the resting state', (tester) async {
        Widget build({required bool loading}) => savHarness(
          width: 400,
          child: Align(
            child: SavButton.primary(
              label: 'Continue',
              onPressed: () {},
              expand: false,
              isLoading: loading,
            ),
          ),
        );

        await tester.pumpWidget(build(loading: false));
        final resting = tester.getSize(find.byType(SavButton));

        await tester.pumpWidget(build(loading: true));
        await tester.pump();
        final loading = tester.getSize(find.byType(SavButton));

        expect(loading, resting);
      });

      testWidgets('reports itself as not enabled', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(
              label: 'Continue',
              onPressed: () {},
              isLoading: true,
              loadingSemanticLabel: 'Loading',
            ),
          ),
        );

        expect(
          tester.getSemantics(find.byType(SavButton)),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            label: 'Continue',
            hint: 'Loading',
          ),
        );
      });
    });

    group('sizing', () {
      testWidgets('fills the available width by default', (tester) async {
        await tester.pumpWidget(
          savHarness(
            width: 400,
            child: SavButton.primary(label: 'Continue', onPressed: () {}),
          ),
        );

        expect(tester.getSize(find.byType(SavButton)).width, 400);
      });

      testWidgets('hugs its label when expand is false', (tester) async {
        await tester.pumpWidget(
          savHarness(
            width: 400,
            child: Align(
              child: SavButton.primary(
                label: 'Go',
                onPressed: () {},
                expand: false,
              ),
            ),
          ),
        );

        expect(tester.getSize(find.byType(SavButton)).width, lessThan(400));
      });

      testWidgets('is the height set by the theme', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(label: 'Continue', onPressed: () {}),
          ),
        );

        expect(
          tester.getSize(find.byType(SavButton)).height,
          SavSizes.buttonHeight,
        );
      });

      testWidgets('meets the minimum tap target', (tester) async {
        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(label: 'Continue', onPressed: () {}),
          ),
        );

        expect(
          tester.getSize(find.byType(SavButton)).height,
          greaterThanOrEqualTo(SavSizes.minTapTarget),
        );
      });
    });

    group('keyboard', () {
      testWidgets('activates on Enter', (tester) async {
        var taps = 0;
        final node = FocusNode();
        addTearDown(node.dispose);

        await tester.pumpWidget(
          savHarness(
            child: SavButton.primary(
              label: 'Continue',
              onPressed: () => taps++,
              focusNode: node,
              autofocus: true,
            ),
          ),
        );
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(taps, 1);
      });
    });

    group('theming', () {
      testWidgets('picks up an overridden SavButtonTheme', (tester) async {
        final base = SavTheme.light();
        await tester.pumpWidget(
          MaterialApp(
            theme: base.copyWith(
              extensions: <ThemeExtension<dynamic>>[
                base.extension<SavButtonTheme>()!.copyWith(
                  regular: base.extension<SavButtonTheme>()!.regular.copyWith(
                    height: 72,
                  ),
                ),
              ],
            ),
            home: Scaffold(
              body: SavButton.primary(label: 'Continue', onPressed: () {}),
            ),
          ),
        );

        expect(tester.getSize(find.byType(SavButton)).height, 72);
      });

      testWidgets('falls back to the standard theme when unregistered', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SavButton.primary(label: 'Continue', onPressed: () {}),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(SavButton)).height,
          SavSizes.buttonHeight,
        );
      });
    });

    testWidgets('many buttons share one grain texture', (tester) async {
      SavNoise.debugReset();
      addTearDown(SavNoise.debugReset);

      await tester.pumpWidget(
        savHarness(
          width: 400,
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: SavSpacing.sm),
              child: SavButton(
                label: 'Button $index',
                variant: SavButtonVariant.values[index.isEven ? 0 : 1],
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // A per-button texture would be 50 allocations of a 64x64 image; the
      // static cache means every button samples the same one.
      expect(identical(SavNoise.tile, SavNoise.tile), isTrue);
      expect(SavNoise.tile.width, SavNoise.tileSize);
    });

    testWidgets('both variants build', (tester) async {
      for (final variant in SavButtonVariant.values) {
        await tester.pumpWidget(
          savHarness(
            child: SavButton(
              label: 'Continue',
              onPressed: () {},
              variant: variant,
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$variant');
      }
    });
  });
}
