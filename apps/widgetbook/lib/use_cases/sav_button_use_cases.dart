import 'package:flutter/material.dart';
import 'package:sav_catalog/widgets/spec_sheet.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// The interactive entry: every property is a knob.
@UseCase(name: 'Playground', type: SavButton, path: '[Components]')
Widget buildSavButtonPlayground(BuildContext context) {
  final knobs = context.knobs;
  final disabled = knobs.boolean(
    label: 'Disabled',
    description: 'Passes a null onPressed, which is how the button disables.',
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(SavSpacing.xl),
      child: SavButton(
        label: knobs.string(label: 'Label', initialValue: 'Label'),
        variant: knobs.object.segmented(
          label: 'Variant',
          options: SavButtonVariant.values,
          labelBuilder: (variant) => variant.name,
        ),
        isLoading: knobs.boolean(label: 'Loading'),
        expand: knobs.boolean(label: 'Expand', initialValue: true),
        onPressed: disabled ? null : () {},
      ),
    ),
  );
}

/// Mirrors the Figma `Button` component (node `86:4022`) one-to-one.
///
/// Reviewers can put this next to the Figma frame and compare directly, which
/// is the check that keeps code and design honest.
@UseCase(name: 'All states', type: SavButton, path: '[Components]')
Widget buildSavButtonMatrix(BuildContext context) => SingleChildScrollView(
  padding: const EdgeInsets.all(SavSpacing.xxl),
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final variant in SavButtonVariant.values) ...<Widget>[
            Text(
              '${variant.name[0].toUpperCase()}${variant.name.substring(1)}',
              style: SavTypography.headingRegular,
            ),
            const SizedBox(height: SavSpacing.md),
            for (final state in _ButtonState.values) ...<Widget>[
              Text(
                state.label,
                style: SavTypography.captionRegular.copyWith(
                  color: SavColors.savPrimarySlate,
                ),
              ),
              const SizedBox(height: SavSpacing.xs),
              SavButton(
                label: 'Label',
                variant: variant,
                isLoading: state == _ButtonState.loading,
                onPressed: state == _ButtonState.disabled ? null : () {},
              ),
              const SizedBox(height: SavSpacing.lg),
            ],
            const SizedBox(height: SavSpacing.md),
          ],
        ],
      ),
    ),
  ),
);

/// Two buttons side by side — the pairing `expand: false` exists for.
@UseCase(name: 'In a row', type: SavButton, path: '[Components]')
Widget buildSavButtonRow(BuildContext context) => Center(
  child: Padding(
    padding: const EdgeInsets.all(SavSpacing.xl),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SavButton.secondary(label: 'Cancel', onPressed: () {}, expand: false),
        const SizedBox(width: SavSpacing.md),
        SavButton.primary(label: 'Confirm', onPressed: () {}, expand: false),
      ],
    ),
  ),
);

/// The written specification a developer needs to use the button correctly.
@UseCase(name: 'Specs', type: SavButton, path: '[Components]')
Widget buildSavButtonSpecs(BuildContext context) => SpecSheet(
  title: 'SavButton',
  subtitle:
      'The primary action control. Figma: Buttons page, node 86:4022. '
      'Two variants x three states.',
  children: <Widget>[
    const SpecSection(
      title: 'API',
      child: SpecTable(
        rows: <String, String>{
          'label': 'String, required. The button text.',
          'onPressed':
              'VoidCallback?, required. Pass null to disable — there is no '
              'separate isDisabled flag, so the two can never disagree.',
          'variant':
              'SavButtonVariant.primary (default) or .secondary. '
              'Convenience constructors: SavButton.primary / .secondary.',
          'isLoading':
              'bool, default false. Swaps the label for a spinner and blocks '
              'taps. The label keeps its space, so the button never resizes.',
          'expand':
              'bool, default true. Full width. Set false to hug the label, '
              'for example in a two-button row.',
          'focusNode / autofocus': 'Standard Flutter focus control.',
          'loadingSemanticLabel':
              'String?. Announced while loading. No default: this package has '
              'no localisations, so pass a translated string.',
        },
      ),
    ),
    SpecSection(
      title: 'Measurements',
      child: SpecTable(
        rows: <String, String>{
          'Height': '${SavSizes.buttonHeight.toInt()}dp (fixed)',
          'Reference width':
              '${SavSizes.buttonReferenceWidth.toInt()}dp — the size the '
              'design was drawn at; buttons are normally full width.',
          'Horizontal padding': '${SavSpacing.xl.toInt()}dp',
          'Corner shape':
              'Squircle at smoothing ${SavShape.buttonSmoothing} '
              '(figma-squircle). Outer radius = half the height = '
              '${_buttonRadius}dp.',
          'Border': '1dp gradient outline, inside the silhouette',
          'Label style': 'Callout/Medium — DM Sans 16/20, weight 500',
          'Spinner':
              '${SavSizes.spinnerSize.toInt()}dp, 1.8dp arc over a '
              '1.67dp track',
        },
      ),
    ),
    const SpecSection(
      title: 'States',
      child: SpecTable(
        rows: <String, String>{
          'Default': 'Surface gradient at full opacity.',
          'Disabled':
              'Primary drops the surface to 40% opacity and keeps its Lumen '
              'label. Secondary keeps its surface and dims the label to '
              'Sterling instead.',
          'Loading':
              'Primary drops the surface to 80% opacity. Secondary is '
              'unchanged. Both swap the label for a spinner.',
          'Pressed':
              'Not defined in Figma. Implemented as a 90% opacity dip so the '
              'button gives touch feedback; override via SavButtonTheme.',
          'Focused':
              'Not defined in Figma. A 2dp ring is drawn inside the outline '
              'for keyboard users, and only appears for keyboard traversal.',
        },
      ),
    ),
    const SpecSection(
      title: 'Do',
      child: SpecList(
        items: <String>[
          'Use one primary button per screen as the main call to action.',
          'Pair a secondary with a primary for cancel/confirm choices.',
          'Set isLoading while an action is in flight, to block double taps.',
          'Keep labels short — the label truncates to a single line.',
        ],
      ),
    ),
    const SpecSection(
      title: "Don't",
      child: SpecList(
        positive: false,
        items: <String>[
          'Wrap it in GestureDetector to change behaviour — pass onPressed.',
          'Restyle one call site — override SavButtonTheme in a Theme scope.',
          'Use expand: true inside a parent with unbounded width.',
          'Rely on colour alone to signal a disabled state.',
        ],
      ),
    ),
    const SpecSection(
      title: 'Accessibility',
      child: SpecTable(
        rows: <String, String>{
          'Role': 'Exposed as a button with an enabled/disabled state.',
          'Name': 'Taken from label.',
          'Tap target': '48dp tall, meeting the WCAG 2.2 target-size minimum.',
          'Keyboard': 'Focusable and activated with Enter or Space.',
          'Loading':
              'Reported as not enabled; pass loadingSemanticLabel for an '
              'explicit announcement.',
        },
      ),
    ),
  ],
);

final int _buttonRadius = SavSquircle.outerRadius(
  SavButtonTheme.referenceSize,
).toInt();

enum _ButtonState {
  normal('Default'),
  disabled('Disabled'),
  loading('Loading');

  const _ButtonState(this.label);

  final String label;
}
