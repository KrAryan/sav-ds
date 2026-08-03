/// The Sav design system.
///
/// Install the theme once at the root of the app, then use the components:
///
/// ```dart
/// MaterialApp(
///   theme: SavTheme.light(),
///   home: Scaffold(
///     body: SavButton.primary(
///       label: 'Continue',
///       onPressed: () {},
///     ),
///   ),
/// );
/// ```
///
/// Browse every component and its states in the catalog:
/// <https://kraryan.github.io/sav-ds/>
library;

export 'src/components/button/sav_action_button.dart';
export 'src/components/button/sav_button.dart';
export 'src/components/button/sav_spinner.dart';
export 'src/painting/sav_gradient.dart';
export 'src/painting/sav_noise.dart';
export 'src/painting/sav_squircle.dart';
export 'src/painting/sav_squircle_border.dart';
export 'src/theme/sav_button_theme.dart';
export 'src/theme/sav_theme.dart';
export 'src/tokens/sav_colors.g.dart';
export 'src/tokens/sav_dimensions.dart';
export 'src/tokens/sav_typography.dart';
