import 'package:flutter/material.dart';
import 'package:sav_design_system/src/components/button/sav_button_surface.dart';
import 'package:sav_design_system/src/theme/sav_button_theme.dart';

/// The compact action control of the Sav design system.
///
/// ```dart
/// SavActionButton.primary(
///   label: 'Top up',
///   onPressed: () => topUp(),
/// )
/// ```
///
/// The same surface as `SavButton` — squircle, gradient, grain, shadows — at
/// 40dp instead of 48dp, with the smaller `Body/Bold` label. Use it inline, in
/// a toolbar, or anywhere a full-width call to action would be too heavy.
///
/// ## Sizing
///
/// Unlike `SavButton`, this one sizes to its content by default. It will not
/// shrink below [SavButtonStyle.minWidth] — 148dp, the width the component is
/// drawn at in Figma — so a short label still produces the button the design
/// shows. Set [expand] to fill the available width instead.
///
/// ## States
///
/// Default, disabled (`onPressed: null`) and loading, exactly as `SavButton`.
///
/// ## Styling
///
/// All visual tokens come from [SavButtonTheme.action], registered by
/// `SavTheme`.
class SavActionButton extends StatelessWidget {
  /// Creates a Sav action button.
  const SavActionButton({
    required this.label,
    required this.onPressed,
    this.variant = SavButtonVariant.primary,
    this.isLoading = false,
    this.expand = false,
    this.focusNode,
    this.autofocus = false,
    this.loadingSemanticLabel,
    super.key,
  });

  /// Creates a high-emphasis action button.
  const SavActionButton.primary({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = false,
    this.focusNode,
    this.autofocus = false,
    this.loadingSemanticLabel,
    super.key,
  }) : variant = SavButtonVariant.primary;

  /// Creates a lower-emphasis action button.
  const SavActionButton.secondary({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = false,
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
  /// Defaults to `false`: an action button is a compact control. Requires a
  /// bounded width when `true`.
  final bool expand;

  /// An optional focus node to control the button's focus.
  final FocusNode? focusNode;

  /// Whether the button should take focus when first built.
  final bool autofocus;

  /// Announced by screen readers while [isLoading] is set.
  ///
  /// No default is provided; see `SavButton.loadingSemanticLabel`.
  final String? loadingSemanticLabel;

  /// Whether an [onPressed] callback was supplied.
  bool get isEnabled => onPressed != null;

  /// Whether the button currently responds to input.
  bool get isInteractive => isEnabled && !isLoading;

  @override
  Widget build(BuildContext context) => SavButtonSurface(
    label: label,
    onPressed: onPressed,
    style:
        Theme.of(context).extension<SavButtonTheme>()?.action ??
        SavButtonTheme.standard().action,
    variant: variant,
    isLoading: isLoading,
    expand: expand,
    autofocus: autofocus,
    focusNode: focusNode,
    loadingSemanticLabel: loadingSemanticLabel,
  );
}
