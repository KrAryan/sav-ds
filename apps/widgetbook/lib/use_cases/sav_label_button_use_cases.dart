import 'package:flutter/material.dart';
import 'package:sav_catalog/widgets/spec_sheet.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// The interactive entry: every property is a knob.
@UseCase(name: 'Playground', type: SavLabelButton, path: '[Components]')
Widget buildSavLabelButtonPlayground(BuildContext context) {
  final knobs = context.knobs;
  final disabled = knobs.boolean(
    label: 'Disabled',
    description: 'Passes a null onPressed, which is how the button disables.',
  );

  return ColoredBox(
    color: SavColors.savPrimaryLumen,
    child: Center(
      child: SavLabelButton(
        label: knobs.string(label: 'Label', initialValue: 'label button'),
        size: knobs.object.segmented(
          label: 'Size',
          options: SavLabelButtonSize.values,
          labelBuilder: (size) => size.name,
        ),
        expandTapTarget: knobs.boolean(
          label: 'Expand tap target',
          initialValue: true,
          description:
              'On by default. Off gives the Figma frame exactly, at the cost '
              'of a target well under 48dp.',
        ),
        onPressed: disabled ? null : () {},
      ),
    ),
  );
}

/// Mirrors the Figma `label button` component (node `116:780`) one-to-one.
@UseCase(name: 'All states', type: SavLabelButton, path: '[Components]')
Widget buildSavLabelButtonMatrix(BuildContext context) => ColoredBox(
  color: SavColors.savPrimaryLumen,
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(SavSpacing.xxl),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final size in SavLabelButtonSize.values) ...<Widget>[
            Text(
              '${size.name[0].toUpperCase()}${size.name.substring(1)}',
              style: SavTypography.headingRegular,
            ),
            const SizedBox(height: SavSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final enabled in <bool>[true, false]) ...<Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        enabled ? 'Default' : 'Disabled',
                        style: SavTypography.captionRegular.copyWith(
                          color: SavColors.savPrimarySlate,
                        ),
                      ),
                      SavLabelButton(
                        label: 'label button',
                        size: size,
                        onPressed: enabled ? () {} : null,
                      ),
                    ],
                  ),
                  const SizedBox(width: SavSpacing.xxl),
                ],
              ],
            ),
            const SizedBox(height: SavSpacing.xl),
          ],
        ],
      ),
    ),
  ),
);

/// Shows what the accessible tap padding actually does.
///
/// The difference is invisible until you outline it, which is exactly why it
/// catches people out when a screen's spacing shifts.
@UseCase(name: 'Tap target', type: SavLabelButton, path: '[Components]')
Widget buildSavLabelButtonTapTarget(BuildContext context) => ColoredBox(
  color: SavColors.savPrimaryLumen,
  child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Outlined(
          caption: 'Default — 48dp target',
          child: SavLabelButton(label: 'label button', onPressed: () {}),
        ),
        const SizedBox(width: SavSpacing.xxl),
        _Outlined(
          caption: 'expandTapTarget: false',
          child: SavLabelButton(
            label: 'label button',
            onPressed: () {},
            expandTapTarget: false,
          ),
        ),
      ],
    ),
  ),
);

/// The written specification a developer needs to use the button correctly.
@UseCase(name: 'Specs', type: SavLabelButton, path: '[Components]')
Widget buildSavLabelButtonSpecs(BuildContext context) => const SpecSheet(
  title: 'SavLabelButton',
  subtitle:
      'The text-only control. Figma: Buttons page, node 116:780. '
      'Two sizes x two states.',
  children: <Widget>[
    SpecSection(
      title: 'When to use it',
      child: SpecList(
        items: <String>[
          'Tertiary actions: "Skip", "Learn more", "Forgot password?".',
          'Inline within a sentence or beneath a form field.',
          'Anywhere even SavActionButton would carry too much weight.',
        ],
      ),
    ),
    SpecSection(
      title: 'API',
      child: SpecTable(
        rows: <String, String>{
          'label': 'String, required. The button text.',
          'onPressed': 'VoidCallback?, required. Pass null to disable.',
          'size':
              'SavLabelButtonSize.regular (default) or .small. '
              'Convenience constructor: SavLabelButton.small.',
          'expandTapTarget':
              'bool, default true. Pads the interactive height out to 48dp. '
              'See "Tap target" below before turning it off.',
          'focusNode / autofocus': 'Standard Flutter focus control.',
        },
      ),
    ),
    SpecSection(
      title: 'No loading state',
      child: SpecList(
        positive: false,
        items: <String>[
          'Figma does not define one, and a text button has nowhere sensible '
              'to put a spinner without shifting the text around it.',
          'If an action needs progress feedback, it wants a surface button — '
              'SavActionButton or SavButton.',
        ],
      ),
    ),
    SpecSection(
      title: 'Measurements',
      child: SpecTable(
        rows: <String, String>{
          'Regular': 'Callout/Medium — DM Sans 16/20, weight 500',
          'Small': 'Body/Bold — DM Sans 14/18, weight 500',
          'Underline':
              'Dotted, thickness taken from the font. Not solid — the most '
              'commonly missed detail on this component.',
          'Enabled colour': 'Sav Primary / Obsidian (#1F1F1F)',
          'Disabled colour':
              'Sav Primary / Slate (#7A7A7A). Note this is Slate, where the '
              'surface buttons dim their labels to Sterling — the label '
              'button sits on the page rather than on a dimmed surface, so it '
              'needs more contrast.',
        },
      ),
    ),
    SpecSection(
      title: 'Tap target',
      child: SpecTable(
        rows: <String, String>{
          'The problem':
              'The text is 18-20dp tall. Shipped as-drawn, that is well under '
              "WCAG 2.2's 48dp target-size minimum.",
          'What the component does':
              'Pads its interactive height to 48dp by default, matching what '
              "Flutter's own buttons do via MaterialTapTargetSize.padded.",
          'What that costs':
              'The padding is part of layout, so the control occupies 48dp of '
              'vertical space even though the text does not. Expect more '
              'spacing than the mockup shows.',
          'Opting out':
              'expandTapTarget: false gives the Figma frame exactly. Only use '
              'it where something else already guarantees a large enough '
              'target.',
        },
      ),
    ),
    SpecSection(
      title: 'Accessibility',
      child: SpecTable(
        rows: <String, String>{
          'Role': 'Exposed as a button with an enabled/disabled state.',
          'Name': 'Taken from label.',
          'Keyboard': 'Focusable and activated with Enter or Space.',
          'Focus':
              'A rounded outline around the text, shown only for keyboard '
              'traversal. Laid out even when hidden, so focus never shifts '
              'the text.',
          'Not colour alone':
              'The underline is always present, so the control does not rely '
              'on colour to read as interactive.',
        },
      ),
    ),
  ],
);

class _Outlined extends StatelessWidget {
  const _Outlined({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        caption,
        style: SavTypography.captionRegular.copyWith(
          color: SavColors.savPrimarySlate,
        ),
      ),
      const SizedBox(height: SavSpacing.xs),
      DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: SavColors.wealthWeave500),
        ),
        child: child,
      ),
    ],
  );
}
