import 'package:flutter/material.dart';
import 'package:sav_catalog/widgets/spec_sheet.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// The interactive entry: every property is a knob.
@UseCase(name: 'Playground', type: SavActionButton, path: '[Components]')
Widget buildSavActionButtonPlayground(BuildContext context) {
  final knobs = context.knobs;
  final disabled = knobs.boolean(
    label: 'Disabled',
    description: 'Passes a null onPressed, which is how the button disables.',
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(SavSpacing.xl),
      child: SavActionButton(
        label: knobs.string(label: 'Label', initialValue: 'Label'),
        variant: knobs.object.segmented(
          label: 'Variant',
          options: SavButtonVariant.values,
          labelBuilder: (variant) => variant.name,
        ),
        isLoading: knobs.boolean(label: 'Loading'),
        expand: knobs.boolean(label: 'Expand'),
        onPressed: disabled ? null : () {},
      ),
    ),
  );
}

/// Mirrors the Figma `Action Button` component (node `86:4029`) one-to-one.
@UseCase(name: 'All states', type: SavActionButton, path: '[Components]')
Widget buildSavActionButtonMatrix(BuildContext context) =>
    SingleChildScrollView(
      padding: const EdgeInsets.all(SavSpacing.xxl),
      child: Center(
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
              Wrap(
                spacing: SavSpacing.lg,
                runSpacing: SavSpacing.lg,
                children: <Widget>[
                  for (final state in _ActionState.values)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          state.label,
                          style: SavTypography.captionRegular.copyWith(
                            color: SavColors.savPrimarySlate,
                          ),
                        ),
                        const SizedBox(height: SavSpacing.xs),
                        SavActionButton(
                          label: 'Label',
                          variant: variant,
                          isLoading: state == _ActionState.loading,
                          onPressed: state == _ActionState.disabled
                              ? null
                              : () {},
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: SavSpacing.xxl),
            ],
          ],
        ),
      ),
    );

/// The two button components side by side, at the same scale.
///
/// Choosing between them is the most common question this component raises,
/// so the catalog answers it by showing them together.
@UseCase(name: 'Against SavButton', type: SavActionButton, path: '[Components]')
Widget buildSavActionButtonComparison(BuildContext context) => Center(
  child: Padding(
    padding: const EdgeInsets.all(SavSpacing.xxl),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'SavButton — 48dp, full width, Callout/Medium',
            style: SavTypography.captionRegular.copyWith(
              color: SavColors.savPrimarySlate,
            ),
          ),
          const SizedBox(height: SavSpacing.sm),
          SavButton.primary(label: 'Continue', onPressed: () {}),
          const SizedBox(height: SavSpacing.xxl),
          Text(
            'SavActionButton — 40dp, hugs content, Body/Bold',
            style: SavTypography.captionRegular.copyWith(
              color: SavColors.savPrimarySlate,
            ),
          ),
          const SizedBox(height: SavSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SavActionButton.secondary(label: 'Skip', onPressed: () {}),
              const SizedBox(width: SavSpacing.md),
              SavActionButton.primary(label: 'Top up', onPressed: () {}),
            ],
          ),
        ],
      ),
    ),
  ),
);

/// The written specification a developer needs to use the button correctly.
@UseCase(name: 'Specs', type: SavActionButton, path: '[Components]')
Widget buildSavActionButtonSpecs(BuildContext context) => SpecSheet(
  title: 'SavActionButton',
  subtitle:
      'The compact action control. Figma: Buttons page, node 86:4029. '
      'Two variants x three states.',
  children: <Widget>[
    const SpecSection(
      title: 'When to use it',
      child: SpecList(
        items: <String>[
          'Inline actions inside a card, list row or toolbar.',
          'Paired actions where a full-width button would dominate.',
          'Anywhere the action is secondary to the content around it.',
        ],
      ),
    ),
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
              'Convenience constructors: .primary / .secondary.',
          'isLoading':
              'bool, default false. Swaps the label for a spinner and blocks '
              'taps. The label keeps its space, so the button never resizes.',
          'expand':
              'bool, default false — the opposite of SavButton, because an '
              'action button is a compact control. Set true to fill the width.',
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
          'Height': '${SavSizes.actionButtonHeight.toInt()}dp (fixed)',
          'Minimum width':
              '${SavSizes.actionButtonReferenceWidth.toInt()}dp — the width '
              'the component is drawn at in Figma. Short labels keep it; long '
              'ones grow past it.',
          'Horizontal padding': '${SavSpacing.button.toInt()}dp',
          'Corner shape':
              'Squircle at smoothing ${SavShape.buttonSmoothing} '
              '(figma-squircle). Outer radius = half the height = '
              '${_actionRadius}dp.',
          'Border': '1dp gradient outline, inside the silhouette',
          'Label style': 'Body/Bold — DM Sans 14/18, weight 500',
          'Spinner':
              '${SavSizes.actionSpinnerSize.toInt()}dp, 1.62dp arc over a '
              '1.503dp track',
        },
      ),
    ),
    const SpecSection(
      title: 'How it differs from SavButton',
      child: SpecTable(
        rows: <String, String>{
          'Height': '40dp instead of 48dp.',
          'Width':
              'Hugs its content down to a 148dp floor, rather than filling '
              'the available width.',
          'Label': 'Body/Bold (14/18) instead of Callout/Medium (16/20).',
          'Primary label colour':
              'White, where the regular button uses Lumen. A small but real '
              'difference in the design source, not a simplification.',
          'Everything else':
              'Identical — the same squircle, gradients, grain, shadows and '
              'state rules, drawn by the same painter.',
        },
      ),
    ),
    const SpecSection(
      title: 'States',
      child: SpecTable(
        rows: <String, String>{
          'Default': 'Surface gradient at full opacity.',
          'Disabled':
              'Primary drops the surface to 40% opacity and keeps its White '
              'label. Secondary keeps its surface and dims the label to '
              'Sterling instead.',
          'Loading':
              'Primary drops the surface to 80% opacity. Secondary is '
              'unchanged. Both swap the label for a spinner.',
          'Pressed / focused':
              'Not defined in Figma; same code-side treatment as SavButton.',
        },
      ),
    ),
    const SpecSection(
      title: "Don't",
      child: SpecList(
        positive: false,
        items: <String>[
          'Use it as the main call to action on a screen — use SavButton.',
          'Put more than two side by side; the labels stop being scannable.',
          'Set expand: true inside a parent with unbounded width.',
        ],
      ),
    ),
    const SpecSection(
      title: 'Accessibility',
      child: SpecTable(
        rows: <String, String>{
          'Role': 'Exposed as a button with an enabled/disabled state.',
          'Name': 'Taken from label.',
          'Tap target':
              '40dp tall, which is below the 48dp WCAG 2.2 target-size '
              'minimum. Give it at least 4dp of clearance on each side, or '
              'wrap it so the touch area reaches 48dp.',
          'Keyboard': 'Focusable and activated with Enter or Space.',
        },
      ),
    ),
  ],
);

final int _actionRadius = SavSquircle.outerRadius(
  SavButtonTheme.actionReferenceSize,
).toInt();

enum _ActionState {
  normal('Default'),
  disabled('Disabled'),
  loading('Loading');

  const _ActionState(this.label);

  final String label;
}
