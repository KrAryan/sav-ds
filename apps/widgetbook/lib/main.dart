import 'package:flutter/material.dart';
import 'package:sav_catalog/main.directories.g.dart';
import 'package:sav_design_system/sav_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() => runApp(const SavCatalog());

/// The Sav design system catalog.
///
/// Every component, its states, and its specs — browsable in a browser, so the
/// wider team can review the design system without a Flutter toolchain.
@widgetbook.App()
class SavCatalog extends StatelessWidget {
  /// Creates the catalog app.
  const SavCatalog({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook(
    directories: directories,
    appBuilder: _savAppBuilder,
    // Sav has no dark palette, so a dark catalog chrome would frame every
    // component against a background the design system never uses. Pin the
    // shell to light rather than following the reviewer's OS setting.
    themeMode: ThemeMode.light,
    addons: <WidgetbookAddon<dynamic>>[
      ViewportAddon(<ViewportData>[
        Viewports.none,
        IosViewports.iPhone13Mini,
        IosViewports.iPhone13,
        AndroidViewports.samsungGalaxyS20,
        IosViewports.iPadPro11Inches,
      ]),
      AlignmentAddon(),
      // Sav's type scale sets explicit line heights, so oversized text is the
      // most likely way a component breaks. Worth one click away.
      TextScaleAddon(min: 1, divisions: 4),
      ZoomAddon(),
      InspectorAddon(),
    ],
  );
}

/// Applies the real Sav theme to every use case.
///
/// Without this the catalog would render components against Material defaults,
/// which is exactly the drift the catalog exists to catch.
Widget _savAppBuilder(BuildContext context, Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: SavTheme.light(),
  home: Material(color: SavColors.savPrimaryWhite, child: child),
);
