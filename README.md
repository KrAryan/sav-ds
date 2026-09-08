# Sav Design System

The Flutter design system for Sav — design tokens, theming and production
components — with a live web catalog the whole team can browse without a
Flutter toolchain.

| | |
|---|---|
| **Catalog** | <https://kraryan.github.io/sav-ds/> |
| **API reference** | <https://kraryan.github.io/sav-ds/api/> |
| **Changelog** | [CHANGELOG.md](CHANGELOG.md) |

## What's inside

Everything reads its styling from `ThemeData.extensions`, so a consumer installs
one theme and uses the widgets — no per-call wiring.

**Components**

| | |
|---|---|
| `SavButton` | Full-width call to action. Primary / secondary × default / disabled / loading. |
| `SavActionButton` | The compact 40dp sibling for inline and toolbar use. |
| `SavLabelButton` | Text-only, dotted underline — the lowest-emphasis control. |
| `SavMaterial` | The frosted-glass card surface. Neutral or one of seven tonal accents. |
| `SavBrandLockup` | The Sav badge + wordmark + product name, in five colourways. |

**Foundations**

- **Colour** — `SavColors`, generated from the Figma variable export (10 ramps).
- **Typography** — `SavTypography`, DM Sans (variable) plus the Obviously title face.
- **Shape, spacing, motion** — `SavSquircle`, `SavSpacing`, `SavSizes`, `SavDurations`.

Browse every component, its states and its written spec in the
[catalog](https://kraryan.github.io/sav-ds/).

## Quick start

```yaml
# pubspec.yaml
dependencies:
  sav_design_system:
    git:
      url: https://github.com/KrAryan/sav-ds.git
      path: packages/sav_design_system
      ref: master # pin a tag or commit for production
```

```dart
import 'package:sav_design_system/sav_design_system.dart';

MaterialApp(
  theme: SavTheme.light(),
  home: Scaffold(
    body: SavButton.primary(label: 'Continue', onPressed: () {}),
  ),
);
```

Full API, theming and token detail:
[`packages/sav_design_system/README.md`](packages/sav_design_system/README.md).

## Repository layout

A [Dart pub workspace][workspace] — one `flutter pub get` at the root resolves
everything.

```
sav-ds/
├── tokens/
│   └── Default.tokens.json              Figma variable export — source of truth for colour
│
├── packages/sav_design_system/          The package apps depend on
│   ├── lib/
│   │   ├── sav_design_system.dart        Public API — the single import consumers use
│   │   └── src/
│   │       ├── components/               Widgets: brand/, button/, material/
│   │       ├── theme/                    ThemeExtensions + per-component style tokens
│   │       ├── painting/                 Gradients, noise, squircles, SVG path parsing
│   │       └── tokens/                   Colours (generated), dimensions, typography
│   ├── test/                             Unit, widget and golden tests (goldens/)
│   ├── tool/generate_tokens.dart         Regenerates src/tokens/sav_colors.g.dart
│   └── example/                          Minimal consuming app
│
├── apps/widgetbook/                     The web catalog (separate app)
│   └── lib/use_cases/                    One catalog entry per component
│
├── docs/                                Standalone engineering notes
└── .github/workflows/                   CI and GitHub Pages deploy
```

The catalog is a **separate app**, not part of the package, so consumers never
pull catalog tooling into a production build.

[workspace]: https://dart.dev/tools/pub/workspaces

## Developing

```sh
flutter pub get                                    # once, at the root

cd apps/widgetbook && flutter run -d chrome        # browse the catalog
cd packages/sav_design_system && flutter test      # unit, widget and goldens
flutter analyze                                    # whole workspace
dart format .
```

After adding or renaming a catalog use case, regenerate its navigation:

```sh
cd apps/widgetbook && dart run build_runner build
```

After re-exporting colours from Figma:

```sh
cd packages/sav_design_system && dart run tool/generate_tokens.dart
```

CI fails if either generated output is stale, so neither can silently drift.
Golden tests pin every component against the Figma render; review the image
diffs on failure rather than regenerating blindly.

## Technique notes

Standalone engineering notes, written to be readable outside this repo:

- [Multi-colour logomarks](docs/multi-colour-logomarks.md) — how gradient
  injection works, why a colourway is data rather than an asset, and how to
  handle a design tool's boolean visibility property without creating a state
  that has no correct rendering.

## Deployment

Pushing to `master` builds the catalog and the dartdoc API reference and
publishes both to GitHub Pages as one site, via
[`.github/workflows/deploy-catalog.yaml`](.github/workflows/deploy-catalog.yaml).
Pages is already configured with **Source: GitHub Actions**.

`--base-href` is derived from the repository name, so the catalog serves from
`/sav-ds/`. Renaming the repo moves the site with no workflow change, but the
hardcoded links in this file, the package README and
`lib/sav_design_system.dart` would need updating.

## Licence

Proprietary — © Sav. See [`packages/sav_design_system/LICENSE`](packages/sav_design_system/LICENSE),
which also records the third-party font licences (DM Sans under the SIL Open
Font License; Obviously Narrow Semibold is a licensed commercial face).
