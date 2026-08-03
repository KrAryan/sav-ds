import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sav_design_system/sav_design_system.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadSavFonts);

  group('SavTypography', () {
    test('resolves both bundled families through the package prefix', () {
      // Fonts declared by a package are registered under `packages/<name>/`.
      // Getting this wrong is silent: text just falls back to the system font.
      expect(
        SavTypography.calloutMedium.fontFamily,
        'packages/sav_design_system/${SavTypography.fontFamily}',
      );
      expect(
        SavTypography.titleLargeText.fontFamily,
        'packages/sav_design_system/${SavTypography.titleFontFamily}',
      );
    });

    test('body styles carry their weight on the variable axis', () {
      // The scale uses 450/500/550, which the fixed FontWeight steps cannot
      // express, so the weight has to travel as a font variation.
      double weightOf(TextStyle style) => style.fontVariations!
          .firstWhere((variation) => variation.axis == 'wght')
          .value;

      expect(weightOf(SavTypography.calloutRegular), 450);
      expect(weightOf(SavTypography.calloutMedium), 500);
      expect(weightOf(SavTypography.calloutBold), 550);
      expect(weightOf(SavTypography.headingLarge), 550);
      expect(weightOf(SavTypography.bodyRegular), 400);
    });

    test('body styles leave fontWeight unset to avoid synthetic bolding', () {
      // Only one face is registered for DM Sans, at its default weight of 400.
      // Asking for w600 on top of a variation would make Skia fake a bold.
      expect(SavTypography.calloutBold.fontWeight, isNull);
      expect(SavTypography.headingLarge.fontWeight, isNull);
    });

    test('title styles request the weight the face is registered at', () {
      // Obviously Narrow Semibold reports usWeightClass 600, so matching it
      // exactly means no synthetic bolding either.
      expect(SavTypography.titleLargeText.fontWeight, FontWeight.w600);
    });

    test('every style sets an explicit line height', () {
      for (final entry in SavTypography.scale.entries) {
        expect(entry.value.height, isNotNull, reason: entry.key);
        expect(entry.value.fontSize, isNotNull, reason: entry.key);
      }
    });
  });

  group('Obviously font', () {
    // A missing or misnamed font is invisible in unit tests — the text still
    // lays out, just in the fallback face. Measuring proves it actually loaded.
    testWidgets('renders narrower than the DM Sans fallback', (tester) async {
      Future<double> widthOf(TextStyle style) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: Text('HAMBURGEFONS', style: style, key: const Key('t')),
            ),
          ),
        );
        return tester.getSize(find.byKey(const Key('t'))).width;
      }

      const size = 40.0;
      final title = await widthOf(
        SavTypography.titleMediumText.copyWith(fontSize: size, height: 1),
      );
      final sans = await widthOf(
        SavTypography.headingLarge.copyWith(fontSize: size, height: 1),
      );

      expect(title, greaterThan(0));
      // "Narrow" is the whole point of the cut: if the family failed to
      // resolve, this would fall back to DM Sans and the widths would match.
      expect(
        title,
        lessThan(sans),
        reason:
            'Obviously Narrow ($title) should be narrower than DM Sans '
            '($sans) at the same size — equal widths mean it did not load',
      );
    });
  });
}
