/// How much cross-platform rendering noise a golden may show before failing.
///
/// The comparator in `flutter_test_config.dart` reads [current]. It is
/// adjustable because the metric — *fraction of the frame that differs* —
/// does not transfer between goldens of different sizes. The button goldens
/// render into 480,000 px; the brand lockup into 80,000. The same absolute
/// antialiasing noise is roughly sixteen times the percentage in the second.
///
/// Raise it only with a measured floor and a note on what the golden can still
/// catch at that level. See `SavBrandLockup`'s goldens for the pattern.
abstract final class SavGoldenTolerance {
  /// Calibrated to cross-platform glyph antialiasing on the button goldens,
  /// measured at 0.048% on a Linux runner.
  static const double standard = 0.0025;

  /// The value the comparator currently enforces.
  static double current = standard;

  /// Applies [tolerance] for the current test file and restores [standard]
  /// afterwards.
  ///
  /// Call from `setUpAll`; the returned callback belongs in `tearDownAll`.
  static void Function() use(double tolerance) {
    current = tolerance;
    return () => current = standard;
  }
}
