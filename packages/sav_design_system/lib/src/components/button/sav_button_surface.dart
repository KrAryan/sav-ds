import 'package:flutter/material.dart';
import 'package:sav_design_system/src/components/button/sav_button_painter.dart';
import 'package:sav_design_system/src/components/button/sav_spinner.dart';
import 'package:sav_design_system/src/theme/sav_button_theme.dart';

/// The shared implementation behind every Sav button.
///
/// `SavButton` and `SavActionButton` are the same control at two sizes, so the
/// interaction handling, layout and painting live here once and each public
/// widget supplies its own [SavButtonStyle]. Keeping them as two public
/// widgets — rather than one with a size flag — mirrors the two components the
/// design library actually defines.
///
/// This is internal: consumers should use the named widgets.
class SavButtonSurface extends StatefulWidget {
  /// Creates a button surface.
  const SavButtonSurface({
    required this.label,
    required this.onPressed,
    required this.style,
    required this.variant,
    required this.isLoading,
    required this.expand,
    required this.autofocus,
    this.focusNode,
    this.loadingSemanticLabel,
    super.key,
  });

  /// Text shown on the button.
  final String label;

  /// Called when the button is tapped. `null` disables it.
  final VoidCallback? onPressed;

  /// Sizing, colour and shape tokens for this component.
  final SavButtonStyle style;

  /// Which visual treatment to use.
  final SavButtonVariant variant;

  /// Whether to show the loading spinner in place of the label.
  final bool isLoading;

  /// Whether the button fills the available width.
  final bool expand;

  /// Whether the button should take focus when first built.
  final bool autofocus;

  /// An optional focus node to control the button's focus.
  final FocusNode? focusNode;

  /// Announced by screen readers while [isLoading] is set.
  final String? loadingSemanticLabel;

  /// Whether an [onPressed] callback was supplied.
  bool get isEnabled => onPressed != null;

  /// Whether the button currently responds to input.
  bool get isInteractive => isEnabled && !isLoading;

  @override
  State<SavButtonSurface> createState() => _SavButtonSurfaceState();
}

class _SavButtonSurfaceState extends State<SavButtonSurface> {
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
    final style = widget.style;
    final variantStyle = style.variantStyle(widget.variant);
    final interactive = widget.isInteractive;

    final label = Text(
      widget.label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style.labelStyle.copyWith(
        color: variantStyle.resolveLabel(enabled: widget.isEnabled),
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
            trackColor: variantStyle.spinnerTrack,
            arcColor: variantStyle.spinnerArc,
            size: style.spinnerSize,
            strokeWidth: style.spinnerStrokeWidth,
            trackStrokeWidth: style.spinnerTrackStrokeWidth,
            rotationDuration: style.spinnerRotationDuration,
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
            opacity: _pressed ? style.pressedOpacity : 1.0,
            duration: style.stateChangeDuration,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.expand ? 0 : style.minWidth,
              ),
              child: SizedBox(
                height: style.height,
                width: widget.expand ? double.infinity : null,
                child: CustomPaint(
                  painter: SavButtonPainter(
                    style: variantStyle,
                    buttonStyle: style,
                    enabled: widget.isEnabled,
                    loading: widget.isLoading,
                    focused: _focused,
                    devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: style.horizontalPadding,
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
      ),
    );
  }
}
