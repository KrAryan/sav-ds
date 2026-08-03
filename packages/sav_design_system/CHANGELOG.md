# Changelog

## 0.1.0

First release. Establishes the foundation and ships `SavButton` as the
reference component that later components follow.

### Added

- **Colour tokens** — `SavColors`, generated from the Figma variable export
  (8 ramps, 40 colours) by `tool/generate_tokens.dart`.
- **Type scale** — `SavTypography`, using DM Sans bundled as a variable font.
  `Title/*` styles fall back to DM Sans pending an Obviously licence.
- **Theme** — `SavTheme.light()` plus the `SavButtonTheme` extension, so
  components can be restyled without forking.
- **`SavButton`** — primary and secondary variants across default, disabled and
  loading states, matching Figma node `86:4022`.
- **`SavSquircle` / `SavSquircleBorder`** — a port of the `figma-squircle`
  plugin the design team draws with, verified to reproduce the exported path.
- **`SavNoise`** — the film-grain overlay, generated at runtime as a cached
  64×64 tile rather than shipped as an asset.
- **Golden tests** covering all six button states.
