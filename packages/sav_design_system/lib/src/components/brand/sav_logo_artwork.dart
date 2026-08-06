import 'dart:ui';

import 'package:sav_design_system/src/painting/sav_path_parser.dart';

/// The Sav logo, as the SVG path strings Figma exports.
///
/// Held as strings rather than as a bundled `.svg` so the artwork needs no
/// third-party renderer and its colours can be injected at paint time. The
/// five brand colourways are one badge drawn with five different gradients,
/// not five assets.
///
/// Paths are parsed once and cached; parsing is not repeated per frame.
abstract final class SavLogoArtwork {
  /// The `viewBox` the paths are drawn in — badge and wordmark together.
  static const Size viewBox = Size(83.3389, 35.6457);

  /// The frame the badge alone occupies.
  ///
  /// The badge sits at the origin and the wordmark to its right, so dropping
  /// the wordmark is a matter of narrowing the frame rather than re-laying
  /// anything out. Very nearly square, which is what makes the badge usable
  /// on its own as an app icon or avatar.
  ///
  /// Asserted against the parsed path in `sav_brand_lockup_test.dart`, so it
  /// cannot drift from the artwork.
  static const Size badgeViewBox = Size(35.7563, 35.6457);

  /// The rounded badge, with the "S" mark cut out of it.
  ///
  /// Two subpaths under the non-zero rule: the outer shape and the counter,
  /// wound oppositely so the mark reads as a hole. This is the path the
  /// gradient fills.
  static const String badgeData =
      'M17.8781 0C3.83472 0 0 3.82286 0 17.8229C0 31.8229 3.82898 35.6457 '
      '17.8781 35.6457C31.9273 35.6457 35.7563 31.8286 35.7563 17.8229C35.7563 '
      '3.81714 31.9273 0 17.8781 0ZM17.9183 28.2171C13.476 28.2171 9.68136 '
      '25.4514 8.17958 21.5486H14.8287C16.4451 21.5486 17.7578 20.3086 17.8724 '
      '18.7314L7.49174 17.56C7.63504 11.9429 12.2493 7.43428 17.9183 '
      '7.43428C22.4179 7.43428 26.2526 10.2686 27.7143 14.2457H20.9276C19.3111 '
      '14.2457 17.9985 15.4857 17.8839 17.0686L28.2645 18.2343C27.6054 23.3371 '
      '23.2204 28.2171 17.9183 28.2171Z';

  /// The "S" of the wordmark.
  static const String _wordmarkS =
      'M49.3653 16.42H49.3481C47.6113 16.1 46.121 15.8314 46.121 '
      '14.4371C46.121 13.26 47.0037 12.3057 48.7749 12.3057C50.5461 12.3057 '
      '51.4345 13.1914 51.4575 14.4143H54.4324C54.312 11.4714 52.0708 9.48286 '
      '48.752 9.48286C45.4331 9.48286 43.0715 11.5686 43.0715 '
      '14.5343C43.0715 18.2543 45.9375 18.7743 48.3679 19.2143H48.3966C50.1391 '
      '19.5343 51.6294 19.8086 51.6294 21.2029C51.6294 22.4771 50.6722 23.3343 '
      '48.729 23.3343C46.7859 23.3343 45.8516 22.4771 45.8286 '
      '21.2029H42.7563C42.8308 24.2657 45.1695 26.1571 48.7348 '
      '26.1571C52.3001 26.1571 54.7133 24.22 54.7133 21.1057C54.7133 17.3914 '
      '51.8301 16.8657 49.3997 16.4257H49.3768L49.3653 16.42Z';

  /// The "a" of the wordmark. Even-odd, so its counter stays open.
  static const String _wordmarkA =
      'M62.8183 13.4029C58.9549 13.4029 56.2494 16.0543 56.2494 '
      '19.9057C56.2494 24.0543 59.3504 26.1629 62.3024 26.1629C64.2227 '
      '26.1629 65.8677 25.2543 66.6072 23.4657V25.8429H69.2898V19.8829C69.2898 '
      '15.98 66.6358 13.4086 62.8183 13.4086V13.4029ZM62.7954 23.4314C60.6573 '
      '23.4314 59.2014 21.9114 59.2014 19.7743C59.2014 17.6371 60.6516 16.1171 '
      '62.7954 16.1171C64.9392 16.1171 66.3607 17.6371 66.3607 '
      '19.7743C66.3607 21.9114 64.9334 23.4314 62.7954 23.4314Z';

  /// The "v" of the wordmark.
  static const String _wordmarkV =
      'M76.8445 23.1629L80.215 13.7171H83.3389L78.5641 25.8371H75.0447L70.2699 '
      '13.7171H73.4684L76.8388 23.1629H76.8445Z';

  static Path? _badge;
  static Path? _wordmark;

  /// The badge path, parsed once.
  static Path get badge => _badge ??= SavPathParser.parse(badgeData);

  /// The "Sav" wordmark, all three glyphs combined into one path.
  ///
  /// The "a" is even-odd while the others are non-zero, so they are parsed
  /// separately and unioned — flattening them under one rule would fill the
  /// "a"'s counter.
  static Path get wordmark => _wordmark ??= Path.combine(
    PathOperation.union,
    Path.combine(
      PathOperation.union,
      SavPathParser.parse(_wordmarkS),
      SavPathParser.parse(_wordmarkA, fillType: PathFillType.evenOdd),
    ),
    SavPathParser.parse(_wordmarkV),
  );
}
