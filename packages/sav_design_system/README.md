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

## Restyling

Override the `SavButtonTheme` extension in a `Theme` scope rather than passing
style arguments at the call site — that keeps every button in the subtree
consistent:

```dart
final theme = Theme.of(context);

Theme(
  data: theme.copyWith(
    extensions: [
      theme.extension<SavButtonTheme>()!.copyWith(height: 56),
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

**Obviously Narrow Semibold** — used by the `Title/*` styles — is a commercial
face from OH no Type Co and requires a paid app-embedding licence. It is **not
bundled**, so those styles currently fall back to DM Sans: correct metrics,
wrong letterforms. To enable it:

1. Drop the licensed files into `assets/fonts/`.
2. Add an `Obviously` family to the `fonts:` section of `pubspec.yaml`.
3. Add `package: 'sav_design_system'` to `SavTypography._title`.

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
