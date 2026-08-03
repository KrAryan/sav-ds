# sav_design_system

Design tokens, theming and components for Sav Flutter apps.

Browse every component, its states and its specs in the catalog:
**<https://kraryan.github.io/sav-ds/>** — API reference at
**<https://kraryan.github.io/sav-ds/api/>**.

---

## Install

Distribution is not wired up yet, so depend on it from git:

```yaml
dependencies:
  sav_design_system:
    git:
      url: https://github.com/KrAryan/sav-ds.git
      path: packages/sav_design_system
      ref: master # pin a tag or commit for production
```

## Set up

Install the theme once at the root of your app. Components read their styling
from `ThemeData.extensions`, so this is the only wiring required.

```dart
import 'package:sav_design_system/sav_design_system.dart';

MaterialApp(
  theme: SavTheme.light(),
  home: const HomePage(),
);
```

> Sav has one theme today. The Figma library defines a single variable mode
> (`Default`) and no dark palette, so there is no `SavTheme.dark()` yet. It can
> be added later without changing this call site.

## Components

### `SavButton`

```dart
SavButton.primary(
  label: 'Continue',
  onPressed: () => submit(),
);

SavButton.secondary(
  label: 'Cancel',
  onPressed: () => Navigator.pop(context),
  expand: false,
);
```

| Parameter | Default | Notes |
|---|---|---|
| `label` | required | Button text. Truncates to one line. |
| `onPressed` | required | **`null` disables the button.** There is no separate `isDisabled` flag, so the two can never disagree — this matches every built-in Flutter button. |
| `variant` | `primary` | `primary` or `secondary`. |
| `isLoading` | `false` | Swaps the label for a spinner and blocks taps. The label keeps its space, so the button never resizes mid-interaction. |
| `expand` | `true` | Full width. Set `false` to hug the label, e.g. in a two-button row. Requires a bounded width when `true`. |
| `focusNode` / `autofocus` | — | Standard Flutter focus control. |
| `loadingSemanticLabel` | `null` | Announced while loading. No default on purpose: this package ships no localisations, and announcing English inside a non-English app is worse than staying quiet. |

Disabled and loading are distinct states, so they can be combined safely:

```dart
SavButton.primary(
  label: 'Confirm',
  isLoading: submitting,
  onPressed: formIsValid ? submit : null,
);
```

### `SavActionButton`

The compact sibling: 40dp instead of 48dp, `Body/Bold` instead of
`Callout/Medium`, and it hugs its content rather than filling the width. Use it
inline, in a toolbar, or wherever a full-width call to action would dominate.

```dart
Row(
  children: [
    SavActionButton.secondary(label: 'Skip', onPressed: skip),
    const SizedBox(width: SavSpacing.md),
    SavActionButton.primary(label: 'Top up', onPressed: topUp),
  ],
);
```

The API is identical to `SavButton` with two differences:

| Parameter | Difference |
|---|---|
| `expand` | Defaults to **`false`**, not `true` — this is a compact control. |
| width | Will not shrink below **148dp**, the width the component is drawn at in Figma, so a short label still produces the button the design shows. Long labels grow past it. |

> **Accessibility:** at 40dp it sits below the 48dp WCAG 2.2 target-size
> minimum. Give it at least 4dp of clearance on each side, or wrap it so the
> touch area reaches 48dp.

Everything else is shared: the same squircle, gradients, grain, shadows and
state rules, drawn by the same painter.

## Restyling

Override the `SavButtonTheme` extension in a `Theme` scope rather than passing
style arguments at the call site — that keeps every button in the subtree
consistent. The extension holds one `SavButtonStyle` per component, so you can
retune one without touching the other:

```dart
final theme = Theme.of(context);
final buttons = theme.extension<SavButtonTheme>()!;

Theme(
  data: theme.copyWith(
    extensions: [
      buttons.copyWith(
        regular: buttons.regular.copyWith(height: 56),
        action: buttons.action.copyWith(minWidth: 0),
      ),
    ],
  ),
  child: child,
);
```

## Tokens

| Token set | Use |
|---|---|
| `SavColors` | 8 ramps / 40 colours. Generated — see below. |
| `SavTypography` | The type scale, plus `SavTypography.scale` for iterating it. |
| `SavSpacing` | 4dp spacing steps. |
| `SavSizes` | Component measurements. |
| `SavShape` | Corner-smoothing presets. |
| `SavDurations` | Motion. |

### Re-syncing colours from Figma

Colours are generated from the Figma variable export, so the palette can never
drift from design by hand-editing:

1. In Figma, export variables to `tokens/Default.tokens.json` (W3C DTCG format).
2. ```sh
   cd packages/sav_design_system
   dart run tool/generate_tokens.dart
   ```

CI fails if the committed `sav_colors.g.dart` does not match the token file.

## Fonts

**DM Sans** is bundled as a variable font (`wght` 100–1000, `opsz` 9–40) under
the SIL Open Font License; see `assets/fonts/OFL.txt`. One 240 KB file covers
the whole scale, including the non-standard weights (450, 500, 550) the design
uses, which the nine fixed `FontWeight` steps cannot express.

**Obviously Narrow Semibold** — used by the `Title/*` styles — is bundled as an
`.otf`. It is a **commercial face from OH no Type Co**: the copy here is
licensed to Sav, so treat this package as proprietary and do not redistribute
it publicly without checking the licence terms. Only the `.otf` is bundled;
Flutter reads `ttf`/`otf`, while `woff` and `woff2` are CSS-only formats.

DM Sans stays on `fontFamilyFallback` for the title styles, so any glyph the
narrow cut lacks still renders instead of dropping to tofu.

## Shape

Sav surfaces are **squircles**, not rounded rectangles. `SavSquircle` is a port
of the [`scotato/figma-squircle`][squircle] plugin that the design team draws
with, so code and Figma produce the same curve.

Do **not** substitute Flutter's `RoundedSuperellipseBorder` — that is the Apple
superellipse, a visibly different shape.

Use `SavSquircleBorder` wherever you need the shape as a `ShapeBorder` (clips,
ink splashes, `ShapeDecoration`).

[squircle]: https://github.com/scotato/figma-squircle

## Testing

```sh
flutter test                     # widget, golden, and unit tests
flutter test --update-goldens    # after an intentional visual change
```

Golden tests pin all six Figma button states. They are the only check that can
catch drift in the gradients, grain, shadows or corner geometry, so review
image diffs rather than regenerating reflexively.
