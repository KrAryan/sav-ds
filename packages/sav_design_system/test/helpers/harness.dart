import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sav_design_system/sav_design_system.dart';

/// Registers the bundled fonts so tests render real letterforms.
///
/// `flutter_test` ships a placeholder font and does not read a package's
/// `fonts:` declarations, so goldens would otherwise be full of tofu boxes.
/// The files are read straight off disk: tests run with the package root as
/// the working directory.
Future<void> loadSavFonts() async {
  await Future.wait(<Future<void>>[
    _load(SavTypography.fontFamily, 'assets/fonts/DMSans.ttf'),
    _load(
      SavTypography.titleFontFamily,
      'assets/fonts/Obviously-NarrowSemibold.otf',
    ),
  ]);
}

Future<void> _load(String family, String path) {
  final bytes = File(path).readAsBytesSync();
  return (FontLoader(
    'packages/sav_design_system/$family',
  )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
}

/// Identifies the boundary a golden is captured from.
///
/// Matching on `find.byType(RepaintBoundary).first` would silently pick
/// whichever boundary Material happens to insert highest in the tree, so the
/// framing would shift with an unrelated Flutter upgrade.
const Key savGoldenKey = ValueKey<String>('sav-golden-boundary');

/// Wraps [child] in the Sav theme, sized and padded for a stable golden.
///
/// The background is Sterling rather than white so the secondary button's
/// near-white surface and the drop shadow are both visible. The padding leaves
/// room for that shadow, which is drawn outside the widget's own bounds.
Widget savHarness({required Widget child, double width = 329}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: SavTheme.light(),
  home: Scaffold(
    backgroundColor: SavColors.savPrimarySterling,
    body: RepaintBoundary(
      key: savGoldenKey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);
