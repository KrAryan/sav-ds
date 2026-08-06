import 'package:flutter/material.dart';
import 'package:sav_catalog/widgets/spec_sheet.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// The interactive entry: every property is a knob, including a live colour
/// pair so the gradient injection can be tried directly.
@UseCase(name: 'Playground', type: SavBrandLockup, path: '[Brand]')
Widget buildSavBrandLockupPlayground(BuildContext context) {
  final knobs = context.knobs;

  final custom = knobs.boolean(
    label: 'Custom gradient',
    description:
        'Bypasses the colourway and injects the two colours below into the '
        'same artwork.',
  );

  return ColoredBox(
    color: SavColors.savPrimaryLumen,
    child: Center(
      child: SavBrandLockup(
        colourway: knobs.object.dropdown(
          label: 'Colourway',
          options: SavBrandColourway.values,
          labelBuilder: (c) => c.name,
        ),
        showProductName: knobs.boolean(
          label: 'Show product name',
          initialValue: true,
        ),
        productName: knobs.string(
          label: 'Product name',
          initialValue: 'String',
        ),
        height: knobs.double.slider(
          label: 'Height',
          initialValue: 35.6457,
          min: 16,
          max: 120,
          divisions: 26,
        ),
        gradientColors: custom
            ? <Color>[
                knobs.color(
                  label: 'Gradient — dark stop',
                  initialValue: SavColors.satinVault800,
                ),
                knobs.color(
                  label: 'Gradient — light stop',
                  initialValue: SavColors.satinVault600,
                ),
              ]
            : null,
      ),
    ),
  );
}

/// Mirrors the Figma component (node `173:329`) one-to-one.
@UseCase(name: 'Colourways', type: SavBrandLockup, path: '[Brand]')
Widget buildSavBrandLockupColourways(BuildContext context) => ColoredBox(
  color: SavColors.savPrimaryLumen,
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(SavSpacing.xxl),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final colourway in SavBrandColourway.values)
            Padding(
              padding: const EdgeInsets.only(bottom: SavSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    colourway.name,
                    style: SavTypography.captionRegular.copyWith(
                      color: SavColors.savPrimarySlate,
                    ),
                  ),
                  const SizedBox(height: SavSpacing.xs),
                  SavBrandLockup(colourway: colourway),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

/// The `productName` property, on and off.
@UseCase(
  name: 'With and without product name',
  type: SavBrandLockup,
  path: '[Brand]',
)
Widget buildSavBrandLockupProductName(BuildContext context) => const ColoredBox(
  color: SavColors.savPrimaryLumen,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SavBrandLockup(),
        SizedBox(height: SavSpacing.xxl),
        SavBrandLockup(showProductName: false),
        SizedBox(height: SavSpacing.xxl),
        // The product name is a plain string, so the lockup carries any
        // sub-brand without new artwork.
        SavBrandLockup(
          colourway: SavBrandColourway.goldStandard,
          productName: 'Wealth',
        ),
      ],
    ),
  ),
);

/// Scaling — the artwork is vector, so it stays crisp at any size.
@UseCase(name: 'Sizes', type: SavBrandLockup, path: '[Brand]')
Widget buildSavBrandLockupSizes(BuildContext context) => ColoredBox(
  color: SavColors.savPrimaryLumen,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final height in <double>[24, 35.6457, 56, 88])
          Padding(
            padding: const EdgeInsets.only(bottom: SavSpacing.xl),
            child: SavBrandLockup(
              colourway: SavBrandColourway.wealthWeave,
              showProductName: false,
              height: height,
            ),
          ),
      ],
    ),
  ),
);

/// The written specification a developer needs to use the lockup correctly.
@UseCase(name: 'Specs', type: SavBrandLockup, path: '[Brand]')
Widget buildSavBrandLockupSpecs(BuildContext context) => SpecSheet(
  title: 'SavBrandLockup',
  subtitle:
      'The Sav badge, wordmark and product name. Figma: node 173:329 — five '
      'Colour variants and a productName toggle.',
  children: <Widget>[
    const SpecSection(
      title: 'API',
      child: SpecTable(
        rows: <String, String>{
          'colourway':
              'SavBrandColourway, default neutral. Five variants matching the '
              'Figma Colour property (Figma names neutral "Default").',
          'showProductName':
              'bool, default true. Mirrors the Figma productName property.',
          'productName':
              'String, default "String". Any sub-brand works — it is text, '
              'not artwork.',
          'height':
              'double?, defaults to the intrinsic 35.65dp. The logo scales; '
              'the product name keeps its own type size, as in Figma.',
          'gradientColors':
              'List<Color>?. Injects a custom pair, bypassing the colourway.',
          'semanticLabel':
              'String?. Defaults to "Sav <productName>" so the artwork is '
              'reachable by screen readers.',
        },
      ),
    ),
    SpecSection(
      title: 'Colourways',
      child: SpecTable(
        rows: <String, String>{
          for (final c in SavBrandColourway.values)
            c.name: c == SavBrandColourway.neutral
                ? 'Obsidian → Sterling. The only one not from a chromatic ramp.'
                : "The ramp's /800 → /600.",
        },
      ),
    ),
    const SpecSection(
      title: 'How the artwork is drawn',
      child: SpecList(
        items: <String>[
          'The logo is held as the SVG path strings Figma exports, parsed into '
              'Flutter Paths by SavPathParser and cached.',
          'Gradients are injected at paint time, so five colourways come from '
              'one set of strings rather than five bundled assets.',
          'That keeps the package free of third-party dependencies — no '
              'flutter_svg — and lets any colour pair be used, not just the '
              'five shipped.',
          'The badge and its "S" counter are one path under the non-zero rule; '
              'the wordmark\'s "a" is even-odd so its bowl stays open.',
        ],
      ),
    ),
    const SpecSection(
      title: "Don't",
      child: SpecList(
        positive: false,
        items: <String>[
          'Stretch it — pass height and let the width follow. A distorted logo '
              'is a brand problem, and an assertion fires in debug if the '
              'aspect ratio is broken.',
          'Recolour the wordmark per screen; override SavBrandLockupTheme if '
              'the whole app needs a different treatment.',
          'Re-export the logo as a PNG. The vector strings stay crisp at every '
              'density.',
        ],
      ),
    ),
    const SpecSection(
      title: 'A note for design',
      child: SpecList(
        positive: false,
        items: <String>[
          'The product name uses sav-transparent/80 — Obsidian at 80%. The '
              'Transparent ramp is not in the variable export, so it cannot '
              'come from a generated token yet.',
          'Its text style is ad-hoc in Figma (20/1.2, weight 550) rather than a '
              'named style, though it matches Heading/Large.',
        ],
      ),
    ),
  ],
);
