# Changelog

## 0.2.0

Adds the second component from the Figma Buttons page and refactors the theme
so the two share one implementation.

### Added

- **`SavActionButton`** — the compact 40dp control, matching Figma node
  `86:4029`. Two variants across default, disabled and loading, with the
  smaller `Body/Bold` label and a 148dp minimum width taken from the design.
- **`SavButtonStyle`** — every token needed to draw one button surface.
  `SavButtonTheme` now holds one per component (`regular` and `action`), so a
  third button can be added without duplicating the class again.
- Goldens for all six `SavActionButton` states.

### Changed

- **Optical size is now per style.** Figma renders the 16px Callout styles at
  `opsz 36` and the 14px Body styles at `opsz 32`, so a single constant was
  wrong. `SavTypography.opticalSizeFor` carries both confirmed values and
  extrapolates the rest.
- **Spinner radius corrected.** It was derived from the stroke width, which
  made it slightly too large. Figma draws `r = 8.3333` in a 20dp spinner and
  `r = 7.5` in an 18dp one — both exactly `5/12` of the size, now expressed as
  `SavSizes.spinnerRadiusRatio`.
- `SavButtonTheme` fields moved onto `SavButtonStyle`; `SavButtonTheme.copyWith`
  now takes `regular` and `action`. `SavButtonTheme.referenceSize` is now
  `regularReferenceSize`.
- Removed the unused `gap` token.

## 0.1.0

First release. Establishes the foundation and ships `SavButton` as the
reference component that later components follow.

### Added

- **Colour tokens** — `SavColors`, generated from the Figma variable export
  (8 ramps, 40 colours) by `tool/generate_tokens.dart`.
- **Type scale** — `SavTypography`, using DM Sans bundled as a variable font
  so the scale's 450/500/550 weights render exactly, plus the licensed
  Obviously Narrow Semibold `.otf` for `Title/*`.
- **Theme** — `SavTheme.light()` plus the `SavButtonTheme` extension, so
  components can be restyled without forking.
- **`SavButton`** — primary and secondary variants across default, disabled and
  loading states, matching Figma node `86:4022`.
- **`SavSquircle` / `SavSquircleBorder`** — a port of the `figma-squircle`
  plugin the design team draws with, verified to reproduce the exported path.
- **`SavNoise`** — the film-grain overlay, generated at runtime as a cached
  64×64 tile rather than shipped as an asset. Scaled to one texel per device
  pixel so the grain does not turn blocky on high-density displays, and
  tunable through `SavButtonTheme.grainIntensity`.
- **Golden tests** covering all six button states.
