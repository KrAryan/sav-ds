# Changelog

Release history for the Sav design system. Each entry is the `sav_design_system`
package version; see
[`packages/sav_design_system/CHANGELOG.md`](packages/sav_design_system/CHANGELOG.md)
for the full per-release detail.

## 0.7.0

Re-synced colour tokens from the July 2026 Figma export — purely additive, no
existing colour changed. Adds a `200` step and `Highlight 200/400` to every
chromatic ramp, plus `Obsidian`/`White Transparent` ramps (0–80%). `SavColors`
grows from 40 to 79 colours.

## 0.6.0

`SavBrandLockup` gains `showWordmark`, narrowing the artwork to the badge alone
for icon and avatar use.

## 0.5.1

The brand lockup's "Sav" wordmark now recolours with its colourway (the ramp's
`/700`); only the product name stays constant.

## 0.5.0

Adds `SavBrandLockup` and the zero-dependency vector machinery behind it —
`SavPathParser` and paint-time gradient injection, so five colourways come from
one set of path strings. Corrects `SavTypography` optical size at 20px.

## 0.4.1

Fixes the `SavMaterial` gradient to run corner-to-corner, matching Figma at any
aspect ratio.

## 0.4.0

Adds `SavMaterial`, the frosted-glass surface, in a neutral form and seven tonal
accents.

## 0.3.0

Adds `SavLabelButton`, completing the Figma Buttons page.

## 0.2.0

Adds `SavActionButton` and refactors the button theme so both surface buttons
share one implementation (`SavButtonStyle`).

## 0.1.0

First release. Establishes the foundation — generated colour tokens, the type
scale, `SavTheme`, the squircle and film-grain painting primitives — and ships
`SavButton` as the reference component, with the web catalog and CI/Pages
pipeline.
