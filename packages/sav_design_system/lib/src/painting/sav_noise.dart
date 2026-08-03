import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The film-grain texture layered over Sav's gradient surfaces.
///
/// ## Why this is generated rather than shipped as an asset
///
/// Figma exports this layer as a 658x96 RGBA PNG — 75 KB for one button. It is
/// also not tileable, so every surface size would need its own export.
///
/// Measuring that export showed the grain is far simpler than a full-colour
/// image: every pixel is **pure black**, and only the alpha varies. So the same
/// look is reproducible from a small tile of black pixels with randomised
/// alpha, which costs zero asset bytes and one 64x64 texture (16 KB of GPU
/// memory) shared by every surface in the app.
///
/// A fragment shader would be lighter still, but `FragmentProgram` is not
/// implemented on Flutter web's CanvasKit backend, and the design-system
/// catalog is a web app — so the grain would silently vanish exactly where the
/// team reviews it.
///
/// ## Matching the source
///
/// Measured from the Figma export (63,168 px):
/// alpha mean 21.2, median 15, max 102, essentially uncorrelated between
/// neighbours once the 2x export scale is accounted for. An exponential
/// distribution with mean 21.2 reproduces that median exactly, so that is what
/// `_generate` samples.
///
/// The Figma layer also carries `opacity: 40%`. That is folded into the tile's
/// alpha instead of being applied at paint time: because both layer opacity and
/// source alpha scale the blend result linearly, pre-multiplying is exactly
/// equivalent and saves a `saveLayer` on every paint.
abstract final class SavNoise {
  /// Width and height of the repeating tile, in logical pixels.
  static const int tileSize = 64;

  /// Blend mode the grain must be drawn with to match Figma's `soft-light`.
  static const BlendMode blendMode = BlendMode.softLight;

  /// Mean alpha of the source texture, on a 0-255 scale.
  static const double _sourceMeanAlpha = 21.16;

  /// Maximum alpha observed in the source texture, on a 0-255 scale.
  static const double _sourceMaxAlpha = 102;

  /// The `opacity: 40%` carried by the Figma layer, folded in here.
  static const double _layerOpacity = 0.4;

  /// Distinct alpha levels in the generated tile.
  ///
  /// The effective alpha range after [_layerOpacity] is only 0-41, so 16 levels
  /// puts every step below the threshold of visibility while keeping generation
  /// to 16 batched draw calls instead of 4,096 individual ones.
  static const int _levels = 16;

  /// Fixed seed: golden tests must see the same grain on every run.
  static const int _seed = 0x5A7D5;

  static ui.Image? _tile;
  static final Map<double, ui.ImageShader> _shaders =
      <double, ui.ImageShader>{};

  /// The repeating grain tile, generated on first use and cached process-wide.
  static ui.Image get tile => _tile ??= _generate();

  /// A shader that tiles [tile] so one texel covers exactly one **device**
  /// pixel.
  ///
  /// A canvas works in logical pixels, so an untransformed shader stretches
  /// each grain texel across `devicePixelRatio` device pixels — 2x2 blocks on a
  /// typical retina screen or browser, 3x3 on a phone. That reads as coarse
  /// blotches rather than film grain, and makes the texture change character
  /// with the display. Scaling by `1 / devicePixelRatio` pins the grain to the
  /// pixel grid so it looks the same everywhere.
  ///
  /// Paint it with [blendMode]; the layer opacity is already baked into the
  /// tile's alpha.
  static ui.ImageShader shaderFor(double devicePixelRatio) {
    final scale = devicePixelRatio > 0 ? 1 / devicePixelRatio : 1.0;
    return _shaders.putIfAbsent(
      scale,
      () => ui.ImageShader(
        tile,
        TileMode.repeated,
        TileMode.repeated,
        Float64List.fromList(<double>[
          scale, 0, 0, 0, //
          0, scale, 0, 0, //
          0, 0, 1, 0, //
          0, 0, 0, 1, //
        ]),
      ),
    );
  }

  /// Discards the cached tile and shaders. Only useful in tests.
  @visibleForTesting
  static void debugReset() {
    for (final shader in _shaders.values) {
      shader.dispose();
    }
    _shaders.clear();
    _tile?.dispose();
    _tile = null;
  }

  static ui.Image _generate() {
    final random = _Xorshift32(_seed);
    const mean = _sourceMeanAlpha * _layerOpacity;
    const maxAlpha = _sourceMaxAlpha * _layerOpacity;

    // Bucket pixels by quantised alpha so the tile is drawn in `_levels`
    // batched calls rather than one per pixel.
    final buckets = List.generate(_levels, (_) => <double>[], growable: false);
    for (var y = 0; y < tileSize; y++) {
      for (var x = 0; x < tileSize; x++) {
        // Inverse-transform sampling of an exponential distribution.
        final alpha = math.min(
          -math.log(1 - random.nextDouble()) * mean,
          maxAlpha,
        );
        final level = (alpha / maxAlpha * (_levels - 1)).round();
        if (level == 0) continue; // fully transparent: nothing to draw
        buckets[level]
          ..add(x + 0.5)
          ..add(y + 0.5);
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;

    for (var level = 1; level < _levels; level++) {
      final points = buckets[level];
      if (points.isEmpty) continue;
      paint.color = Color.fromARGB(
        (level / (_levels - 1) * maxAlpha).round(),
        0,
        0,
        0,
      );
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.fromList(points),
        paint,
      );
    }

    final picture = recorder.endRecording();
    try {
      return picture.toImageSync(tileSize, tileSize);
    } finally {
      picture.dispose();
    }
  }
}

/// Deterministic PRNG.
///
/// `dart:math`'s `Random` does not guarantee a stable sequence across releases
/// or platforms; golden tests need one that does.
class _Xorshift32 {
  _Xorshift32(this._state) : assert(_state != 0, 'seed must be non-zero');

  int _state;

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    return _state = x & 0xFFFFFFFF;
  }

  /// A double in `[0, 1)`.
  double nextDouble() => _next() / 0x100000000;
}
