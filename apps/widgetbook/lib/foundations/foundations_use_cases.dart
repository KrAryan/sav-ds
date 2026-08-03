import 'package:flutter/material.dart';
import 'package:sav_catalog/widgets/spec_sheet.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// The full palette, rendered straight from the generated tokens.
///
/// Reading [SavColors.ramps] rather than a hand-written list means this page
/// cannot drift from `tokens/Default.tokens.json`.
@UseCase(name: 'Palette', type: SavColors, path: '[Foundations]')
Widget buildColorPalette(BuildContext context) => SpecSheet(
  title: 'Colours',
  subtitle:
      '${SavColors.ramps.length} ramps, '
      '${SavColors.ramps.values.fold<int>(0, (n, r) => n + r.length)} tokens. '
      'Generated from the Figma variable export; one mode (Default).',
  children: <Widget>[
    for (final ramp in SavColors.ramps.entries)
      SpecSection(
        title: ramp.key,
        child: Row(
          children: <Widget>[
            for (final step in ramp.value.entries)
              Expanded(
                child: _Swatch(name: step.key, color: step.value),
              ),
          ],
        ),
      ),
  ],
);

/// The type scale, rendered from [SavTypography.scale].
@UseCase(name: 'Type scale', type: SavTypography, path: '[Foundations]')
Widget buildTypeScale(BuildContext context) => SpecSheet(
  title: 'Typography',
  subtitle:
      "DM Sans for body text, bundled as a variable font so the scale's "
      '450/500/550 weights render exactly. Title styles use Obviously Narrow '
      'Semibold, bundled as an .otf.',
  children: <Widget>[
    for (final style in SavTypography.scale.entries)
      SpecSection(
        title: style.key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _describe(style.value),
              style: SavTypography.captionRegular.copyWith(
                color: SavColors.savPrimarySlate,
              ),
            ),
            const SizedBox(height: SavSpacing.sm),
            Text('The quick brown fox jumps', style: style.value),
          ],
        ),
      ),
  ],
);

/// How corner smoothing changes the silhouette.
@UseCase(name: 'Corner smoothing', type: SavSquircle, path: '[Foundations]')
Widget buildSquircleScale(BuildContext context) => SpecSheet(
  title: 'Shape',
  subtitle:
      'Sav surfaces are squircles, not rounded rectangles. The token is a '
      'smoothing preset (1-10); the radii are derived from the shape size. '
      'Buttons use ${SavShape.buttonSmoothing}.',
  children: <Widget>[
    SpecSection(
      title: 'Smoothing presets',
      child: Wrap(
        spacing: SavSpacing.lg,
        runSpacing: SavSpacing.lg,
        children: <Widget>[
          for (
            var smoothing = SavSquircle.minSmoothing;
            smoothing <= SavSquircle.maxSmoothing;
            smoothing++
          )
            Column(
              children: <Widget>[
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: SavColors.savPrimaryObsidian,
                    shape: SavSquircleBorder(smoothing: smoothing),
                  ),
                  child: const SizedBox.square(dimension: 88),
                ),
                const SizedBox(height: SavSpacing.xs),
                Text('$smoothing', style: SavTypography.captionRegular),
              ],
            ),
        ],
      ),
    ),
    SpecSection(
      title: 'Against a rounded rectangle',
      child: Row(
        children: <Widget>[
          const _ShapeSample(
            label: 'Squircle (smoothing ${SavShape.buttonSmoothing})',
            shape: SavSquircleBorder(),
          ),
          const SizedBox(width: SavSpacing.xl),
          _ShapeSample(
            label: 'RoundedRectangle, same radius',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(44),
            ),
          ),
        ],
      ),
    ),
    const SpecSection(
      title: 'Why not RoundedSuperellipseBorder?',
      child: SpecList(
        positive: false,
        items: <String>[
          "Flutter's RoundedSuperellipseBorder is a different curve: it is "
              'the Apple superellipse.',
          'Sav shapes come from the scotato/figma-squircle plugin, so the '
              'package ports that algorithm instead.',
        ],
      ),
    ),
  ],
);

String _describe(TextStyle style) {
  final size = style.fontSize ?? 0;
  final leading = (style.height ?? 1) * size;
  final weight = style.fontVariations
      ?.firstWhere(
        (variation) => variation.axis == 'wght',
        orElse: () => const FontVariation('wght', 400),
      )
      .value;
  final family = style.fontFamily?.split('/').last ?? 'inherit';
  return '$family · ${size.toInt()}/${leading.toInt()}'
      '${weight != null ? ' · weight ${weight.toInt()}' : ''}';
}

String _hex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Pick a readable label colour from the swatch's own luminance rather than
    // hard-coding one, so light and dark steps both stay legible.
    final onColor = color.computeLuminance() > 0.5
        ? SavColors.savPrimaryObsidian
        : SavColors.savPrimaryWhite;

    return Container(
      height: 96,
      padding: const EdgeInsets.all(SavSpacing.sm),
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            name,
            style: SavTypography.captionRegular.copyWith(color: onColor),
          ),
          Text(
            _hex(color),
            style: SavTypography.captionRegular.copyWith(color: onColor),
          ),
        ],
      ),
    );
  }
}

class _ShapeSample extends StatelessWidget {
  const _ShapeSample({required this.label, required this.shape});

  final String label;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      DecoratedBox(
        decoration: ShapeDecoration(
          color: SavColors.savPrimaryObsidian,
          shape: shape,
        ),
        child: const SizedBox(width: 200, height: 88),
      ),
      const SizedBox(height: SavSpacing.xs),
      Text(label, style: SavTypography.captionRegular),
    ],
  );
}
