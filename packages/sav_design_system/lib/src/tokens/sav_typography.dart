import 'package:flutter/painting.dart';

/// The Sav type scale.
///
/// ## Fonts
///
/// Body text uses **DM Sans**, bundled with this package as a variable font
/// carrying `wght` (100-1000) and `opsz` (9-40) axes.
///
/// Titles are specified in **Obviously Narrow Semibold**, a commercial face
/// from OH no Type Co that requires a paid app-embedding licence. It is *not*
/// bundled. Until licensed files are added, the `Title/*` styles fall back to
/// DM Sans via [TextStyle.fontFamilyFallback] — correct metrics, wrong
/// letterforms. See `README.md` for how to drop the files in.
///
/// ## Why weights are set through `fontVariations`
///
/// The scale uses weights of 450, 500 and 550 — real values on the variable
/// axis that the nine fixed [FontWeight] steps cannot express.
///
/// [TextStyle.fontWeight] is deliberately left unset. Only one face is
/// registered for the family (at the file's default weight of 400), so asking
/// for `w600` would make Skia synthesise a fake bold *on top of* the variation
/// already applied, double-bolding the text.
abstract final class SavTypography {
  /// Family name of the bundled body font.
  static const String fontFamily = 'DM Sans';

  /// Family name of the title font. Not bundled — see the class docs.
  static const String titleFontFamily = 'Obviously';

  static const String _package = 'sav_design_system';

  /// Fully-qualified family name for the bundled font.
  ///
  /// Fonts declared by a package are registered under a `packages/<name>/`
  /// prefix. `TextStyle.package` applies it automatically; fallback lists take
  /// the raw string, so it is spelled out here.
  static const String _qualifiedFontFamily = 'packages/$_package/$fontFamily';

  /// Value applied to DM Sans's optical-size axis.
  ///
  /// Figma reports `opsz 36` for the button label, which is the only style with
  /// a confirmed value; it is applied across the scale for consistency. Note
  /// that Figma *names* these styles "9pt Regular" (the `opsz = 9` named
  /// instance) while rendering them at 36 — worth confirming with design.
  static const double opticalSize = 36;

  /// OpenType features Figma applies to Sav text: case-sensitive forms plus
  /// stylistic sets 1 and 3. All three exist in the bundled DM Sans.
  static const List<FontFeature> features = <FontFeature>[
    // `FontFeature.enable` / `.stylisticSet` are factories and cannot be const,
    // so the tags are spelled out to keep the list a compile-time constant.
    FontFeature('case'),
    FontFeature('ss01'),
    FontFeature('ss03'),
  ];

  // --- Heading (DM Sans) ---

  /// `Heading/Large` — 20/24, weight 550.
  static final TextStyle headingLarge = _sans(
    size: 20,
    leading: 24,
    weight: 550,
  );

  /// `Heading/Regular` — 18/24, weight 500.
  static final TextStyle headingRegular = _sans(
    size: 18,
    leading: 24,
    weight: 500,
  );

  // --- Callout (DM Sans) ---

  /// `Callout/Regular` — 16/20, weight 450.
  static final TextStyle calloutRegular = _sans(
    size: 16,
    leading: 20,
    weight: 450,
  );

  /// `Callout/Medium` — 16/20, weight 500. The button label style.
  static final TextStyle calloutMedium = _sans(
    size: 16,
    leading: 20,
    weight: 500,
  );

  /// `Callout/Bold` — 16/20, weight 550.
  static final TextStyle calloutBold = _sans(
    size: 16,
    leading: 20,
    weight: 550,
  );

  // --- Body (DM Sans) ---

  /// `Body/Regular` — 14/18, weight 400.
  static final TextStyle bodyRegular = _sans(
    size: 14,
    leading: 18,
    weight: 400,
  );

  /// `Body/Bold` — 14/18, weight 500.
  ///
  /// Named "Bold" in Figma but authored at weight 500; the numeric value wins.
  static final TextStyle bodyBold = _sans(size: 14, leading: 18, weight: 500);

  // --- Caption (DM Sans) ---

  /// `Caption/Regular` — 12/14, weight 450.
  static final TextStyle captionRegular = _sans(
    size: 12,
    leading: 14,
    weight: 450,
  );

  // --- Title (Obviously Narrow Semibold — not bundled) ---

  /// `Title/Large/Text` — 48/58.
  static final TextStyle titleLargeText = _title(size: 48, leading: 58);

  /// `Title/Medium/Text` — 40/48.
  static final TextStyle titleMediumText = _title(size: 40, leading: 48);

  /// `Title/Regular/Text` — 24/30.
  static final TextStyle titleRegularText = _title(size: 24, leading: 30);

  /// `Title/Large/Symbol` — 30/52.
  static final TextStyle titleLargeSymbol = _title(size: 30, leading: 52);

  /// `Title/Medium/Symbol` — 30/42.
  static final TextStyle titleMediumSymbol = _title(size: 30, leading: 42);

  /// `Title/Regular/Symbol` — 16/24.
  static final TextStyle titleRegularSymbol = _title(size: 16, leading: 24);

  /// Every named style, in Figma order.
  ///
  /// Drives the catalog's Typography page so it cannot drift from the scale.
  static final Map<String, TextStyle> scale = <String, TextStyle>{
    'Heading/Large': headingLarge,
    'Heading/Regular': headingRegular,
    'Callout/Regular': calloutRegular,
    'Callout/Medium': calloutMedium,
    'Callout/Bold': calloutBold,
    'Body/Regular': bodyRegular,
    'Body/Bold': bodyBold,
    'Caption/Regular': captionRegular,
    'Title/Large/Text': titleLargeText,
    'Title/Medium/Text': titleMediumText,
    'Title/Regular/Text': titleRegularText,
    'Title/Large/Symbol': titleLargeSymbol,
    'Title/Medium/Symbol': titleMediumSymbol,
    'Title/Regular/Symbol': titleRegularSymbol,
  };

  static TextStyle _sans({
    required double size,
    required double leading,
    required double weight,
  }) => TextStyle(
    fontFamily: fontFamily,
    package: _package,
    fontSize: size,
    height: leading / size,
    letterSpacing: 0,
    fontVariations: <FontVariation>[
      FontVariation('wght', weight),
      const FontVariation('opsz', opticalSize),
    ],
    fontFeatures: features,
    // Figma centres the leading around the text; Flutter's default puts it all
    // above. Without this, line boxes sit low against the Figma reference.
    leadingDistribution: TextLeadingDistribution.even,
  );

  static TextStyle _title({required double size, required double leading}) =>
      TextStyle(
        fontFamily: titleFontFamily,
        fontFamilyFallback: const <String>[_qualifiedFontFamily],
        fontSize: size,
        height: leading / size,
        letterSpacing: 0,
        fontWeight: FontWeight.w600, // "Narrow Semibold"
        leadingDistribution: TextLeadingDistribution.even,
      );
}
