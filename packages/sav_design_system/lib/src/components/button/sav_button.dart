import 'package:flutter/material.dart';
import 'package:sav_design_system/src/components/button/sav_button_painter.dart';
import 'package:sav_design_system/src/components/button/sav_spinner.dart';
import 'package:sav_design_system/src/theme/sav_button_theme.dart';

/// The primary action control of the Sav design system.
///
/// ```dart
/// SavButton.primary(
///   label: 'Continue',
///   onPressed: () => submit(),
/// )
/// ```
///
/// ## States
///
/// The button has three states, matching the Figma component:
///
/// * **Default** — interactive.
/// * **Disabled** — set [onPressed] to `null`. There is deliberately no
///   `isDisabled` flag: a single source of truth cannot contradict itself, and
///   it matches how every built-in Flutter button behaves.
/// * **Loading** — set [isLoading]. Taps are ignored and the label is replaced
///   by a spinner. The label's width is still reserved, so a button that sizes
///   to its content does not jump when loading begins.
///
/// ## Styling
///
/// All visual tokens come from [SavButtonTheme], registered by `SavTheme`.
/// To restyle every button in a subtree, override the extension rather than
/// passing style arguments here — see [SavButtonTheme].
class SavButton extends StatefulWidget {
  /// Creates a Sav button.
  const SavButton({
    required this.label,
    required this.onPressed,
    this.variant = SavButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
    this.focusNode,
    this.autofocus = false,
    this.loadingSemanticLabel,
    super.key,
  });

  /// Creates a high-emphasis button. See [SavButtonVariant.primary].
  const SavButton.primary({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.focusNode,
    this.autofocus = false,
    this.loadingSemanticLabel,
    super.key,
  }) : variant = SavButtonVariant.primary;

  /// Creates a lower-emphasis button. See [SavButtonVariant.secondary].
  const SavButton.secondary({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.focusNode,
    this.autofocus = false,
    this.loadingSemanticLabel,
    super.key,
  }) : variant = SavButtonVariant.secondary;

  /// Text shown on the button.
  final String label;

  /// Called when the button is tapped.
  ///
  /// Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Which visual treatment to use.
  final SavButtonVariant variant;

  /// Whether to show the loading spinner in place of the label.
  final bool isLoading;

  /// Whether the button fills the available width.
  ///
  /// Sav buttons are full-width by default. Set to `false` to size to the
  /// label — for example in a row of two buttons. Requires a bounded width
  /// when `true`.
  final bool expand;

  /// An optional focus node to control the button's focus.
  final FocusNode? focusNode;

  /// Whether the button should take focus when first built.
  final bool autofocus;

  /// Announced by screen readers while [isLoading] is set.
  ///
  /// No default is provided: this package ships no localisations, and
  /// announcing an English string inside a non-English app is worse than
  /// staying quiet. Pass a localised string. Regardless of this value, the
  /// button reports itself as disabled while loading, so assistive technology
  /// already knows it cannot be activated.
  final String? loadingSemanticLabel;

  /// Whether an [onPressed] callback was supplied.
  ///
  /// Note this stays `true` while loading; use [isInteractive] to test whether
  /// a tap will do anything.
  bool get isEnabled => onPressed != null;

  /// Whether the button currently responds to input.
  bool get isInteractive => isEnabled && !isLoading;

  @override
  State<SavButton> createState() => _SavButtonState();
}

class _SavButtonState extends State<SavButton> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed({required bool value}) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleActivate() {
    if (!widget.isInteractive) return;
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<SavButtonTheme>() ??
        SavButtonTheme.standard();
    final style = theme.styleFor(widget.variant);
    final interactive = widget.isInteractive;

    final label = Text(
      widget.label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.labelStyle.copyWith(
        color: style.resolveLabel(enabled: widget.isEnabled),
      ),
    );

    final content = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Laid out even while loading so the button keeps the same intrinsic
        // width in both states.
        Opacity(opacity: widget.isLoading ? 0 : 1, child: label),
        if (widget.isLoading)
          SavSpinner(
            trackColor: style.spinnerTrack,
            arcColor: style.spinnerArc,
            size: theme.spinnerSize,
            strokeWidth: theme.spinnerStrokeWidth,
            trackStrokeWidth: theme.spinnerTrackStrokeWidth,
            rotationDuration: theme.spinnerRotationDuration,
          ),
      ],
    );

    return Semantics(
      container: true,
      button: true,
      enabled: interactive,
      label: widget.label,
      hint: widget.isLoading ? widget.loadingSemanticLabel : null,
      onTap: interactive ? _handleActivate : null,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: interactive,
        mouseCursor: interactive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        // Only reports true for keyboard traversal, so clicking with a mouse
        // does not leave a focus ring behind.
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
          onTapDown: interactive ? (_) => _setPressed(value: true) : null,
          onTapUp: interactive ? (_) => _setPressed(value: false) : null,
          onTapCancel: interactive ? () => _setPressed(value: false) : null,
          onTap: interactive ? _handleActivate : null,
          child: AnimatedOpacity(
            opacity: _pressed ? theme.pressedOpacity : 1.0,
            duration: theme.stateChangeDuration,
            child: SizedBox(
              height: theme.height,
              width: widget.expand ? double.infinity : null,
              child: CustomPaint(
                painter: SavButtonPainter(
                  style: style,
                  theme: theme,
                  enabled: widget.isEnabled,
                  loading: widget.isLoading,
                  focused: _focused,
                  devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.horizontalPadding,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(child: ExcludeSemantics(child: content)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
