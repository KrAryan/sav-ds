import 'package:flutter/material.dart';
import 'package:sav_design_system/src/theme/sav_button_theme.dart';
import 'package:sav_design_system/src/theme/sav_label_button_theme.dart';
import 'package:sav_design_system/src/tokens/sav_colors.g.dart';
import 'package:sav_design_system/src/tokens/sav_typography.dart';

/// Builds the [ThemeData] that Sav components expect.
///
/// Install it once at the root of the app:
///
/// ```dart
/// MaterialApp(
///   theme: SavTheme.light(),
///   home: const HomePage(),
/// );
/// ```
///
/// Components read their styling from [ThemeData.extensions], so anything
/// wrapped in a [Theme] can be restyled locally without forking a widget.
abstract final class SavTheme {
  /// The Sav theme.
  ///
  /// Sav has a single theme today — the Figma library defines one variable mode
  /// (`Default`) and no dark palette. The method is named `light` so a
  /// `SavTheme.dark()` can be added later without changing this call site.
  static ThemeData light() {
    final colorScheme = _colorScheme();
    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[
        SavButtonTheme.standard(),
        SavLabelButtonTheme.standard(),
      ],
    );
  }

  /// Maps the Sav palette onto Material's colour roles.
  ///
  /// Only the roles the design library actually defines are set. Sav has no
  /// semantic error/success/warning colours yet, so the remaining roles are
  /// derived from the brand neutral and should not be treated as approved
  /// tokens.
  static ColorScheme _colorScheme() =>
      ColorScheme.fromSeed(
        seedColor: SavColors.savPrimaryObsidian,
      ).copyWith(
        primary: SavColors.savPrimaryObsidian,
        onPrimary: SavColors.savPrimaryLumen,
        secondary: SavColors.savPrimaryLumen,
        onSecondary: SavColors.savPrimaryObsidian,
        surface: SavColors.savPrimaryWhite,
        onSurface: SavColors.savPrimaryObsidian,
        surfaceContainerLowest: SavColors.savPrimaryWhite,
        surfaceContainer: SavColors.savPrimaryLumen,
        onSurfaceVariant: SavColors.savPrimarySlate,
        outline: SavColors.savPrimarySterling,
        outlineVariant: SavColors.savPrimaryLumen,
      );

  /// Maps the Sav type scale onto Material's [TextTheme] slots.
  ///
  /// Sav's scale is smaller than Material's, so several slots share a style.
  /// Prefer [SavTypography] directly when you want a named Sav style.
  static TextTheme _textTheme() => TextTheme(
    displayLarge: SavTypography.titleLargeText,
    displayMedium: SavTypography.titleMediumText,
    displaySmall: SavTypography.titleRegularText,
    headlineLarge: SavTypography.titleLargeSymbol,
    headlineMedium: SavTypography.titleMediumSymbol,
    headlineSmall: SavTypography.titleRegularSymbol,
    titleLarge: SavTypography.headingLarge,
    titleMedium: SavTypography.headingRegular,
    titleSmall: SavTypography.calloutBold,
    bodyLarge: SavTypography.calloutRegular,
    bodyMedium: SavTypography.bodyRegular,
    bodySmall: SavTypography.captionRegular,
    labelLarge: SavTypography.calloutMedium,
    labelMedium: SavTypography.bodyBold,
    labelSmall: SavTypography.captionRegular,
  );
}
