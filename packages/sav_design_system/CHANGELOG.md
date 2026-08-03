# Changelog

## 0.4.1

Fixes the `SavMaterial` gradient direction.

- The sheen now runs **corner to corner** (top-left to bottom-right), following
  the frame the way Figma draws it. The first cut used the CSS export's fixed
  163.9° angle, which is that diagonal only for the reference frame size and
  skewed the sheen — and hid the tonal wash — on the wide, short surfaces the
  component is actually used on.
- `SavMaterialTheme` now exposes `begin` / `end` alignments instead of
  `angleDegrees`.

## 0.4.0

Adds the Material surface from the Figma Material page.

### Added

- **`SavMaterial`** — Sav's surface fill and stroke: a corner-to-corner sheen
  gradient (top-left to bottom-right), a white hairline stroke, and a soft
  shadow. Shape-agnostic; applied to a frame at a caller-supplied corner radius.
- **`SavMaterialAccent`** and **`SavMaterialTheme`** — a tonal material adds one
  gradient stop from a chromatic ramp's `/100`. All seven ramps are supported.
- Goldens for the default surface and a representative set of tonal accents.

### Notes

- The 6px backdrop blur the spec calls for is inert with the opaque stops Figma
  exports, so it is skipped until `SavMaterialTheme.fillOpacity` drops below 1.
  The frosted machinery is in place and tunable; the intended opacity is an open
  question for design.
- The Figma frame `Material/Tonal/Wealth` washes in Lush Capital (green), not
  Wealth Weave (blue). Accents here are keyed by their real ramp, so the
  mismatch stays on the Figma side.

## 0.3.0

Completes the Figma Buttons page.

### Added

- **`SavLabelButton`** — the text-only control, matching Figma node `116:780`.
  Two sizes (`Callout/Medium` and `Body/Bold`) across default and disabled,
  with the dotted underline the design specifies.
- **`SavLabelButtonTheme`** — its own extension, kept separate from
  `SavButtonTheme` because a control with no surface shares none of the
  gradient, grain, shadow or spinner tokens.
- Goldens for all four `SavLabelButton` states.
- `savHarness` in tests now takes a `background`, so text-only components can
  be reviewed against the ground they actually sit on.

### Notes

- The label button dims to **Slate**, not the Sterling the surface buttons use.
  Confirmed against Figma rather than inferred from the sibling components,
  which would have got it wrong.
- The control pads its interactive height to 48dp by default. The Figma frame
  is only 18-20dp tall, which is below WCAG 2.2's target-size minimum; set
  `expandTapTarget: false` for the frame exactly.

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
