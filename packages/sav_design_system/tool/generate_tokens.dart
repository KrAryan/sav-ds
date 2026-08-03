// Generates `lib/src/tokens/sav_colors.g.dart` from the Figma variable export
// at `tokens/Default.tokens.json` (W3C Design Tokens / DTCG format).
//
// Re-syncing colours from Figma is therefore two steps:
//   1. In Figma, export variables to `tokens/Default.tokens.json`.
//   2. `dart run tool/generate_tokens.dart`
//
// The generator is deliberately dependency-free so it can run in CI without a
// `pub get` beyond the package's own.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final repoRoot = _findRepoRoot();
  final input = File(
    args.isNotEmpty ? args[0] : '${repoRoot.path}/tokens/Default.tokens.json',
  );
  final output = File(
    args.length > 1
        ? args[1]
        : '${repoRoot.path}/packages/sav_design_system/lib/src/tokens/'
              'sav_colors.g.dart',
  );

  if (!input.existsSync()) {
    stderr.writeln('Token file not found: ${input.path}');
    exitCode = 1;
    return;
  }

  final json = jsonDecode(input.readAsStringSync()) as Map<String, dynamic>;
  final ramps = _parseRamps(json);
  final total = ramps.values.fold<int>(0, (sum, ramp) => sum + ramp.length);

  output.parent.createSync(recursive: true);
  output.writeAsStringSync(_render(ramps));

  stdout.writeln(
    'Generated ${output.path}\n'
    '  ${ramps.length} ramps, $total colours',
  );
}

/// Walks up from the current directory to the directory holding `tokens/`.
Directory _findRepoRoot() {
  var dir = Directory.current;
  while (true) {
    if (Directory('${dir.path}/tokens').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) return Directory.current;
    dir = parent;
  }
}

/// Ramp name -> (step name -> ARGB value). Insertion order is preserved so the
/// generated file and the catalog both read in the same order as Figma.
Map<String, Map<String, int>> _parseRamps(Map<String, dynamic> json) {
  final ramps = <String, Map<String, int>>{};

  for (final entry in json.entries) {
    // `$extensions` etc. carry file metadata, not tokens.
    if (entry.key.startsWith(r'$')) continue;
    final group = entry.value;
    if (group is! Map<String, dynamic>) continue;

    final steps = <String, int>{};
    for (final step in group.entries) {
      if (step.key.startsWith(r'$')) continue;
      final token = step.value;
      if (token is! Map<String, dynamic>) continue;
      if (token[r'$type'] != 'color') continue;

      final value = token[r'$value'];
      if (value is! Map<String, dynamic>) continue;
      final hex = value['hex'];
      if (hex is! String) continue;
      final alpha = (value['alpha'] as num?)?.toDouble() ?? 1.0;

      steps[step.key] = _toArgb(hex, alpha);
    }
    if (steps.isNotEmpty) ramps[entry.key] = steps;
  }

  return ramps;
}

int _toArgb(String hex, double alpha) {
  final rgb = int.parse(hex.replaceFirst('#', ''), radix: 16);
  final a = (alpha.clamp(0.0, 1.0) * 255).round();
  return (a << 24) | (rgb & 0xFFFFFF);
}

String _render(Map<String, Map<String, int>> ramps) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln('// Source: tokens/Default.tokens.json (Figma variable export).')
    ..writeln('// Regenerate: dart run tool/generate_tokens.dart')
    ..writeln()
    ..writeln("import 'dart:ui';")
    ..writeln()
    ..writeln('/// Every colour in the Sav palette, generated from the Figma')
    ..writeln('/// variable export.')
    ..writeln('///')
    ..writeln('/// Prefer semantic access through the theme where one exists;')
    ..writeln('/// reach for these raw ramp values when defining new tokens.')
    ..writeln('abstract final class SavColors {');

  for (final ramp in ramps.entries) {
    buffer
      ..writeln('  // ${ramp.key}')
      ..writeln();
    for (final step in ramp.value.entries) {
      final name = _fieldName(ramp.key, step.key);
      final hex = step.value.toRadixString(16).padLeft(8, '0').toUpperCase();
      buffer
        ..writeln('  /// `${ramp.key} / ${step.key}` — #${hex.substring(2)}.')
        ..writeln('  static const Color $name = Color(0x$hex);')
        ..writeln();
    }
  }

  buffer
    ..writeln('  /// All ramps, keyed by Figma name, in Figma order.')
    ..writeln('  ///')
    ..writeln("  /// Drives the catalog's Colors page so it never drifts from")
    ..writeln('  /// the tokens.')
    ..writeln('  static const Map<String, Map<String, Color>> ramps = {');
  for (final ramp in ramps.entries) {
    buffer.writeln("    '${ramp.key}': {");
    for (final step in ramp.value.keys) {
      buffer.writeln("      '$step': ${_fieldName(ramp.key, step)},");
    }
    buffer.writeln('    },');
  }
  buffer
    ..writeln('  };')
    ..writeln('}');

  return buffer.toString();
}

/// `('Wealth Weave', '100')` -> `wealthWeave100`.
/// `('Sav Primary', 'Obsidian')` -> `savPrimaryObsidian`.
String _fieldName(String ramp, String step) {
  final words = <String>[
    ...ramp.split(RegExp(r'[\s_-]+')),
    ...step.split(RegExp(r'[\s_-]+')),
  ].where((w) => w.isNotEmpty).toList();

  final buffer = StringBuffer();
  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    if (i == 0) {
      buffer.write(word[0].toLowerCase() + word.substring(1));
    } else {
      buffer.write(word[0].toUpperCase() + word.substring(1));
    }
  }
  return buffer.toString();
}
