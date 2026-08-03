import 'package:flutter/material.dart';
import 'package:sav_catalog/widgets/spec_sheet.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// The interactive entry: every property is a knob.
@UseCase(name: 'Playground', type: SavMaterial, path: '[Components]')
Widget buildSavMaterialPlayground(BuildContext context) {
  final knobs = context.knobs;

  final tonal = knobs.boolean(
    label: 'Tonal',
    description: 'Adds one chromatic accent stop from the ramp below.',
  );
  final accent = knobs.object.dropdown(
    label: 'Accent',
    options: SavMaterialAccent.values,
    labelBuilder: (a) => a.name,
  );
  final radius = knobs.double.slider(
    label: 'Corner radius',
    initialValue: 16,
    max: 48,
    divisions: 12,
  );
  final fillOpacity = knobs.double.slider(
    label: 'Fill opacity',
    initialValue: 1,
    min: 0.3,
    divisions: 14,
    description:
        '1.0 matches Figma (opaque, no visible frost). Lower it to reveal the '
        'backdrop blur — watch the pattern behind the card.',
  );

  final base = Theme.of(context);
  return Theme(
    data: base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        base.extension<SavMaterialTheme>()!.copyWith(fillOpacity: fillOpacity),
      ],
    ),
    child: _Backdrop(
      child: Center(
        child: SavMaterial(
          accent: tonal ? accent : null,
          borderRadius: BorderRadius.circular(radius),
          child: const SizedBox(width: 260, height: 96),
        ),
      ),
    ),
  );
}

/// Every accent, plus the neutral default, over one background.
@UseCase(name: 'Default & tonal', type: SavMaterial, path: '[Components]')
Widget buildSavMaterialGallery(BuildContext context) => _Backdrop(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(SavSpacing.xxl),
    child: Center(
      child: Wrap(
        spacing: SavSpacing.xl,
        runSpacing: SavSpacing.xl,
        children: <Widget>[
          const _Tile(
            label: 'Default',
            child: SavMaterial(child: _TileBody()),
          ),
          for (final accent in SavMaterialAccent.values)
            _Tile(
              label: accent.name,
              child: SavMaterial(accent: accent, child: const _TileBody()),
            ),
        ],
      ),
    ),
  ),
);

/// The frosted effect the backdrop blur is there for.
///
/// Only visible once the fill is translucent — which is why the default
/// (opaque) material shows no blur at all.
@UseCase(name: 'Frosted glass', type: SavMaterial, path: '[Components]')
Widget buildSavMaterialFrosted(BuildContext context) {
  final base = Theme.of(context);
  return _Backdrop(
    behind: const _MutedContent(),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (label, opacity) in const <(String, double)>[
            ('fillOpacity: 1.0 (shipped — solid)', 1.0),
            ('fillOpacity: 0.7', 0.7),
            ('fillOpacity: 0.4 (frosted)', 0.4),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: SavSpacing.xl),
              child: Theme(
                data: base.copyWith(
                  extensions: <ThemeExtension<dynamic>>[
                    base.extension<SavMaterialTheme>()!.copyWith(
                      fillOpacity: opacity,
                    ),
                  ],
                ),
                child: SavMaterial(
                  accent: SavMaterialAccent.cyanReserve,
                  child: Padding(
                    padding: const EdgeInsets.all(SavSpacing.lg),
                    child: Text(
                      label,
                      style: SavTypography.bodyBold.copyWith(
                        color: SavColors.savPrimaryObsidian,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// The written specification a developer needs to use the surface correctly.
@UseCase(name: 'Specs', type: SavMaterial, path: '[Components]')
Widget buildSavMaterialSpecs(BuildContext context) => SpecSheet(
  title: 'SavMaterial',
  subtitle:
      'The frosted-glass surface treatment. Figma: Material page — Default '
      '(86:4046) and Tonal (86:4039 / 93:4092).',
  children: <Widget>[
    const SpecSection(
      title: 'What it is',
      child: SpecList(
        items: <String>[
          'A card / surface background: a diagonal sheen, a white hairline '
              'border, and a soft drop shadow.',
          'Shape-agnostic — it applies to whatever corner radius you give it '
              'and wraps arbitrary content.',
          'Default is neutral; tonal adds one chromatic wash.',
        ],
      ),
    ),
    const SpecSection(
      title: 'API',
      child: SpecTable(
        rows: <String, String>{
          'child': 'Widget, required. The content on the surface.',
          'accent':
              'SavMaterialAccent?. null is the neutral default material; any '
              'of the seven ramps makes it tonal.',
          'borderRadius':
              'BorderRadiusGeometry, default 16dp. The material does not '
              'dictate a shape; this is just how round this surface is.',
          'clipBehavior': 'Clip, default antiAlias.',
        },
      ),
    ),
    SpecSection(
      title: 'The gradient',
      child: SpecTable(
        rows: <String, String>{
          'Direction':
              'Corner to corner, top-left to bottom-right — it follows the '
              'frame at any aspect ratio, as Figma draws it.',
          'Default stops':
              'Lumen 10% → White 40% → White 82.3% → Lumen 100% — a soft '
              'diagonal sheen.',
          'Tonal':
              "The same stops with the accent ramp's /100 inserted at "
              '69.35%, so default and tonal share one sheen.',
          'Accents': SavMaterialAccent.values.map((a) => a.name).join(', '),
        },
      ),
    ),
    const SpecSection(
      title: 'Frosted glass — read this',
      child: SpecTable(
        rows: <String, String>{
          'The spec': 'Figma includes a 6px backdrop blur.',
          'The catch':
              'The exported gradient stops are opaque, so the surface is '
              'solid and the blur has nothing to show through — as authored, '
              'the frost is invisible.',
          'What the code does':
              'Skips the backdrop-blur pass entirely while the fill is opaque, '
              'so nothing is paid for an effect that would not render.',
          'Turning it on':
              'Lower SavMaterialTheme.fillOpacity below 1. The fill becomes '
              'translucent and the blur appears. See the "Frosted glass" use '
              'case. Worth confirming the intended value with design.',
        },
      ),
    ),
    const SpecSection(
      title: 'A naming note for design',
      child: SpecList(
        positive: false,
        items: <String>[
          'The Figma frame "Material/Tonal/Wealth" uses Lush Capital/100 '
              '(green), not Wealth Weave/100 (blue). "Purple" correctly uses '
              'Purple Power. The accents here are keyed by their real ramp, so '
              'the mismatch is Figma-side.',
        ],
      ),
    ),
  ],
);

/// A calm neutral ground for the surfaces to sit on — the same light grey
/// Figma shows them against, so the sheen, the shadow and the tonal wash read
/// without anything competing with them.
///
/// Pass [behind] to place muted content under the surface; only the "Frosted
/// glass" use case needs it, to show the blur softening something.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child, this.behind});

  final Widget child;
  final Widget? behind;

  static const Color _ground = Color(0xFFE9EAEC);

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _ground,
    child: behind == null
        ? child
        : Stack(
            children: <Widget>[
              Positioned.fill(child: behind!),
              child,
            ],
          ),
  );
}

/// Muted placeholder content for the frosted use case — grey bars the blur can
/// soften, standing in for real app content behind a sheet.
class _MutedContent extends StatelessWidget {
  const _MutedContent();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(SavSpacing.xxl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final width in <double>[220, 160, 260, 190, 240])
          Padding(
            padding: const EdgeInsets.only(bottom: SavSpacing.md),
            child: Container(
              width: width,
              height: 14,
              decoration: BoxDecoration(
                color: SavColors.savPrimarySterling,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      child,
      const SizedBox(height: SavSpacing.sm),
      Text(
        label,
        style: SavTypography.captionRegular.copyWith(
          color: SavColors.savPrimarySlate,
        ),
      ),
    ],
  );
}

class _TileBody extends StatelessWidget {
  const _TileBody();

  @override
  Widget build(BuildContext context) => const SizedBox(width: 239, height: 69);
}
