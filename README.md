# Sav design system

The Flutter design system for Sav, plus the web catalog the wider team reviews
it in.

| | |
|---|---|
| **Catalog** | <https://kraryan.github.io/sav-ds/> |
| **API reference** | <https://kraryan.github.io/sav-ds/api/> |
| **Design source** | Figma — Buttons, Text, Colors pages |

## Layout

This is a [Dart pub workspace][workspace]: one `flutter pub get` at the root
resolves everything.

```
tokens/Default.tokens.json        Figma variable export — source of truth for colour
packages/sav_design_system/       The package apps depend on
packages/sav_design_system/example/   Minimal consuming app
apps/widgetbook/                  The web catalog
```

The catalog is a **separate app**, not part of the package, so consumers never
pull catalog tooling into a production build.

[workspace]: https://dart.dev/tools/pub/workspaces

## Working on it

```sh
flutter pub get                                    # once, at the root

cd apps/widgetbook && flutter run -d chrome        # browse the catalog
cd packages/sav_design_system && flutter test      # unit, widget and goldens
flutter analyze                                    # whole workspace
dart format .
```

After adding or renaming a use case, regenerate the catalog's navigation:

```sh
cd apps/widgetbook && dart run build_runner build
```

After re-exporting colours from Figma:

```sh
cd packages/sav_design_system && dart run tool/generate_tokens.dart
```

CI fails if either generated output is stale, so neither can silently drift.

## Consuming the package

See [`packages/sav_design_system/README.md`](packages/sav_design_system/README.md)
for installation, the component API, theming and token details.

## Deployment

Pushing to `master` builds the catalog and the dartdoc API reference and
publishes both to GitHub Pages as one site. Pages is already enabled with
**Source: GitHub Actions**; no further setup is needed.

The `--base-href` in `deploy-catalog.yaml` is derived from the repository name,
so the catalog is served from `/sav-ds/`. Renaming the repo therefore moves the
site without any workflow change — but the links in this file, in
`packages/sav_design_system/README.md`, `apps/widgetbook/README.md` and
`packages/sav_design_system/lib/sav_design_system.dart` are hardcoded and would
need updating.

## Open questions for design

Things the code had to decide because Figma does not specify them. Each is a
token on `SavButtonTheme`, so changing them is a one-line edit.

- **Pressed and focus states** are undefined in Figma. The button dips to 90%
  opacity while held and draws a 2dp focus ring for keyboard users.
- **The button's gradients, grain, border and shadows are not bound to Figma
  variables** — only the label colours are. They live as code-side tokens, so a
  change in Figma will not propagate automatically.
- **Binding is inconsistent on the label button**: its Small/Disable colour uses
  the `Sav Primary/Slate` variable, while Regular/Disable has the same value
  typed as a raw `#7a7a7a`. Same colour today, free to drift tomorrow.
- **The label button is drawn at 18-20dp tall**, below WCAG 2.2's 48dp
  target-size minimum. The code pads the interactive area out by default, which
  makes screens taller than the mockups — worth agreeing on.
- **Optical size**: the text styles are named "9pt Regular" (the `opsz = 9`
  named instance) but Figma renders them at `opsz 36`. The code follows the
  rendered value.
- **Two type scales exist** in the Figma file: the dated "Text Styles Style
  Sheet" (implemented) and a separate "Responsive Type Styles" frame with
  different values (not implemented).
- **Semantic colours** — no error/success/warning tokens are defined, so those
  Material roles are derived from the brand neutral and should not be treated
  as approved.
