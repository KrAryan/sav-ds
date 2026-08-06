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
        showWordmark: knobs.boolean(
          label: 'Show wordmark',
          initialValue: true,
          description:
              'Off narrows the artwork to the badge alone — a near-square '
              'mark for app icons and avatars.',
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
        wordmarkColor: custom
            ? knobs.colorOrNull(
                label: 'Wordmark colour',
                initialValue: SavColors.satinVault700,
              )
            : null,
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

/// The two visibility toggles, in all four combinations.
///
/// Shown together because the pair is what people get wrong: dropping the
/// wordmark narrows the artwork to the badge rather than leaving a gap.
@UseCase(name: 'Composition', type: SavBrandLockup, path: '[Brand]')
Widget buildSavBrandLockupComposition(BuildContext context) => ColoredBox(
  color: SavColors.savPrimaryLumen,
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(SavSpacing.xxl),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (label, wordmark, product) in const <(String, bool, bool)>[
            ('Full lockup', true, true),
            ('Wordmark only — showProductName: false', true, false),
            ('Badge + product name — showWordmark: false', false, true),
            ('Badge only — both off', false, false),
          ]) ...<Widget>[
            Text(
              label,
              style: SavTypography.captionRegular.copyWith(
                color: SavColors.savPrimarySlate,
              ),
            ),
            const SizedBox(height: SavSpacing.xs),
            SavBrandLockup(
              showWordmark: wordmark,
              showProductName: product,
            ),
            const SizedBox(height: SavSpacing.xl),
          ],
          Text(
            'The product name is plain text, so the lockup carries any '
            'sub-brand without new artwork.',
            style: SavTypography.captionRegular.copyWith(
              color: SavColors.savPrimarySlate,
            ),
          ),
          const SizedBox(height: SavSpacing.xs),
          const SavBrandLockup(
            colourway: SavBrandColourway.goldStandard,
            productName: 'Wealth',
          ),
        ],
      ),
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
          'showWordmark':
              'bool, default true. Off narrows the artwork to the badge alone, '
              'leaving a near-square mark for icons and avatars. No Figma '
              'counterpart — a code-side addition.',
          'showProductName':
              'bool, default true. Mirrors the Figma productName property.',
          'productName':
              'String, default "String". Any sub-brand works — it is text, '
              'not artwork.',
          'height':
              'double?, defaults to the intrinsic 35.65dp. The logo scales; '
              'the product name keeps its own type size, as in Figma.',
          'gradientColors':
              'List<Color>?. Injects a custom badge pair, bypassing the '
              'colourway.',
          'wordmarkColor':
              'Color?. Overrides the "Sav" glyphs. Defaults to the '
              "colourway's own tone; set it to reverse the lockup out on a "
              'dark surface.',
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
                ? 'Badge Obsidian → Sterling, wordmark Obsidian. The only one '
                      'not from a chromatic ramp.'
                : 'Badge /800 → /600, wordmark /700 — all from the one ramp.',
        },
      ),
    ),
    const SpecSection(
      title: 'What a colourway recolours',
      child: SpecList(
        items: <String>[
          "The badge gradient — the ramp's /800 into its /600.",
          'The "Sav" wordmark — the same ramp\'s /700, sitting between them.',
        ],
      ),
    ),
    const SpecSection(
      title: 'Composition',
      child: SpecList(
        items: <String>[
          'The badge is always drawn. The wordmark and the product name switch '
              'off independently, giving four combinations.',
          'Hiding the wordmark narrows the artwork rather than leaving a gap: '
              'the badge sits at the origin and the wordmark to its right, so '
              'the frame just gets shorter.',
          'The badge alone is near-square, which is the form an app icon or '
              'avatar wants.',
          'The accessible name is unchanged either way — the badge stands for '
              'the brand on its own.',
        ],
      ),
    ),
    const SpecSection(
      title: 'What stays constant',
      child: SpecList(
        positive: false,
        items: <String>[
          'The product name. It is Obsidian at 80% in every variant, so it '
              'reads as a separate word rather than part of the mark.',
        ],
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
