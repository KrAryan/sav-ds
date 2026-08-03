import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Applies to every test in this package; `flutter_test` loads it
/// automatically.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final local = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _TolerantGoldenComparator(local.basedir);
  await testMain();
}

/// A golden comparator that ignores differences below [_tolerance].
///
/// ## Why a tolerance is needed
///
/// Text rasterisation is not identical across operating systems: macOS and
/// Linux hint and antialias glyphs differently, so the edge pixels of the
/// button's label differ by a hair. Everything the design system actually
/// draws — gradients, grain, squircle geometry, shadows — *is* bit-identical
/// across platforms. That was measured, not assumed: on a Linux CI runner the
/// four goldens containing a label each differed by 0.05% (~220 px), while the
/// two loading goldens, which replace the label with a spinner but exercise
/// the same painting code, matched exactly.
///
/// ## Why this value
///
/// [_tolerance] is set five times the observed glyph noise, which leaves room
/// for another platform's hinting while staying far below any change worth
/// catching. For scale, on these 800x600 goldens the button covers roughly
/// 3.3% of the frame, so a shifted gradient, a wrong colour or a layout change
/// moves one to two orders of magnitude more pixels than this and still fails.
///
/// Sub-pixel geometry is *not* left to the goldens: `SavSquircle`'s radii are
/// asserted exactly against the Figma export in `sav_squircle_test.dart`.
class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(Uri basedir)
    // LocalFileComparator derives its base directory from a test file path,
    // so hand it any file name inside the directory we want.
    : super(basedir.resolve('flutter_test_config.dart'));

  /// Maximum fraction of differing pixels treated as noise.
  static const double _tolerance = 0.0025; // 0.25%

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (result.passed) return true;

    if (result.diffPercent <= _tolerance) {
      debugPrint(
        'Golden "$golden" differs by '
        '${(result.diffPercent * 100).toStringAsFixed(3)}%, '
        'within the ${(_tolerance * 100).toStringAsFixed(2)}% tolerance.',
      );
      return true;
    }

    throw FlutterError(
      await generateFailureOutput(result, golden, basedir),
    );
  }
}
