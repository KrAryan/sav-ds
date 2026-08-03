import 'package:flutter/material.dart';
import 'package:sav_design_system/src/theme/sav_label_button_theme.dart';

/// A text-only button: an underlined label with no surface behind it.
///
/// ```dart
/// SavLabelButton(
///   label: 'Forgot password?',
///   onPressed: () => recover(),
/// )
/// ```
///
/// The lowest-emphasis control in the family. Use it for tertiary actions —
/// "Skip", "Learn more", "Forgot password?" — where even `SavActionButton`
/// would be too loud.
///
/// ## States
///
/// Only two, matching the Figma component: default and disabled
/// ([onPressed] set to `null`). There is deliberately no loading state; the
/// design does not define one, and a text button has nowhere sensible to put a
/// spinner. If an action needs progress feedback, it wants a surface button.
///
/// ## Tap target
///
/// The text is only 18-20dp tall, well under the 48dp WCAG 2.2 target-size
/// minimum, so the control pads its *interactive* height out to
/// [SavLabelButtonTheme.minTapTarget] by default. This follows Flutter's own
/// buttons, which do the same thing through `MaterialTapTargetSize.padded`.
///
/// The padding participates in layout, so a label button occupies 48dp of
/// vertical space even though its text does not. Set [expandTapTarget] to
/// `false` to get the Figma frame exactly — but only where something else
/// already guarantees an adequate target.
class SavLabelButton extends StatefulWidget {
  /// Creates a label button.
  const SavLabelButton({
    required this.label,
    required this.onPressed,
    this.size = SavLabelButtonSize.regular,
    this.expandTapTarget = true,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Creates a label button at [SavLabelButtonSize.small].
  const SavLabelButton.small({
    required this.label,
    required this.onPressed,
    this.expandTapTarget = true,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : size = SavLabelButtonSize.small;

  /// Text shown on the button.
  final String label;

  /// Called when the button is tapped.
  ///
  /// Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Which of the two sizes to use.
  final SavLabelButtonSize size;

  /// Whether to pad the interactive area out to an accessible height.
  ///
  /// See the class documentation — leaving this `true` is strongly preferred.
  final bool expandTapTarget;

  /// An optional focus node to control the button's focus.
  final FocusNode? focusNode;

  /// Whether the button should take focus when first built.
  final bool autofocus;

  /// Whether an [onPressed] callback was supplied.
  bool get isEnabled => onPressed != null;

  @override
  State<SavLabelButton> createState() => _SavLabelButtonState();
}

class _SavLabelButtonState extends State<SavLabelButton> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed({required bool value}) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleActivate() {
    if (!widget.isEnabled) return;
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<SavLabelButtonTheme>() ??
        SavLabelButtonTheme.standard();
    final enabled = widget.isEnabled;

    // The border is always laid out and only becomes visible on focus, so
    // taking focus cannot shift the text.
    final child = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _focused ? theme.focusRingColor : const Color(0x00000000),
          width: theme.focusRingWidth,
        ),
        borderRadius: BorderRadius.circular(theme.focusRingRadius),
      ),
      padding: EdgeInsets.all(theme.focusRingWidth),
      child: Text(
        widget.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.resolve(widget.size, enabled: enabled),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? _handleActivate : null,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (value) {
          if (_focused == value) return;
          setState(() => _focused = value);
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleActivate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(value: true) : null,
          onTapUp: enabled ? (_) => _setPressed(value: false) : null,
          onTapCancel: enabled ? () => _setPressed(value: false) : null,
          onTap: enabled ? _handleActivate : null,
          child: AnimatedOpacity(
            opacity: _pressed ? theme.pressedOpacity : 1.0,
            duration: theme.stateChangeDuration,
            child: widget.expandTapTarget
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: theme.minTapTarget,
                    ),
                    // Shrink-wraps horizontally, centres vertically inside the
                    // padded-out height.
                    child: Center(
                      widthFactor: 1,
                      child: ExcludeSemantics(child: child),
                    ),
                  )
                : ExcludeSemantics(child: child),
          ),
        ),
      ),
    );
  }
}
