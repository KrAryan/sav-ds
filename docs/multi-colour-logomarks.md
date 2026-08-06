# Multi-colour logomarks: gradient injection and optional elements

A technique note on implementing a brand logomark that ships in several
colourways and has parts that can be switched off.

This is written to be **framework-agnostic**. The examples are in SVG, CSS,
Flutter and Swift, but nothing here depends on a particular design system,
component library or toolchain. If you are handed a Figma component with a
`Colour` property and a boolean toggle, this describes what you are actually
looking at and how to build it once instead of *n* times.

**Contents**

1. [The shape of the problem](#1-the-shape-of-the-problem)
2. [Reading what the design tool exported](#2-reading-what-the-design-tool-exported)
3. [Injecting gradients](#3-injecting-gradients)
4. [Keeping it resolution-independent](#4-keeping-it-resolution-independent)
5. [Gradient pitfalls](#5-gradient-pitfalls)
6. [Optional elements: the boolean property](#6-optional-elements-the-boolean-property)
7. [Testing colour you cannot see](#7-testing-colour-you-cannot-see)

---

## 1. The shape of the problem

A designer hands over a logomark with two properties:

| Property | Values |
|---|---|
| `Colour` | Default, plus four brand colourways |
| `productName` | on / off |

The obvious reading is *ten assets* — five colourways times two states. Export
them all, bundle them, pick one at runtime.

That reading is wrong, and it gets more wrong over time. Add a sixth colourway
and you re-export everything. Ship a dark-surface variant and you double it.
Change one curve in the mark and you regenerate ten files and hope none drifts.

The useful observation is that **the geometry never changes**. Across every
variant, the paths are byte-identical; only two things differ:

- which colours fill them
- whether one element is present

So the artwork is one thing, and colour and composition are parameters applied
to it. Everything below follows from that.

> **How to check this claim on your own artwork.** Export two variants and diff
> the path data. If the `d` attributes match, you have this situation. If they
> do not, find out why before continuing — a designer may have outlined a
> stroke in one variant, which is a different problem.
>
> ```sh
> # Extract just the path geometry and compare.
> for f in variant-a.svg variant-b.svg; do
>   grep -o 'd="[^"]*"' "$f" | shasum | cut -d' ' -f1
> done
> ```

---

## 2. Reading what the design tool exported

Open the exported SVG. A gradient-filled mark looks roughly like this:

```svg
<svg viewBox="0 0 83.34 35.65">
  <path d="M17.88 0C3.83 0 0 3.82 0 17.82 …Z"
        fill="url(#badge)"/>
  <path d="M49.37 16.42H49.35C47.61 16.1 …Z"
        fill="#1F1F1F"/>
  <defs>
    <radialGradient id="badge"
                    cx="0" cy="0" r="1"
                    gradientUnits="userSpaceOnUse"
                    gradientTransform="matrix(-12.93 15.06 -21.94 -18.34 17.88 17.82)">
      <stop offset="0.5" stop-color="#1F1F1F"/>
      <stop offset="1"   stop-color="#B4B4B4"/>
    </radialGradient>
  </defs>
</svg>
```

Three things are worth noticing, because they are what make injection possible.

### The gradient carries no useful geometry of its own

`cx="0" cy="0" r="1"` is a **unit circle at the origin**. That is not where the
gradient is; it is a placeholder. Figma (and Illustrator, and Sketch) put *all*
the real geometry into `gradientTransform`. This is consistent enough to rely
on.

### `gradientTransform` is a 2D affine matrix

`matrix(a b c d e f)` means:

```
| a  c  e |     x' = a·x + c·y + e
| b  d  f |     y' = b·x + d·y + f
| 0  0  1 |
```

Applied to the unit circle, it produces an ellipse where:

- **`(e, f)`** is the centre
- **`(a, b)`** is one semi-axis vector
- **`(c, d)`** is the other semi-axis vector

The two axis vectors are not required to be perpendicular. When they are close
to *anti*-parallel — as in the example above, where `(-12.93, 15.06)` and
`(-21.94, -18.34)` sit at a wide angle — the "radial" gradient is squashed so
flat that it reads as a diagonal sweep rather than a burst. Do not assume a
radial gradient looks radial.

### `gradientUnits` decides the coordinate space

| Value | Meaning |
|---|---|
| `userSpaceOnUse` | Coordinates are in the SVG's own user space (the `viewBox`). This is what design tools emit. |
| `objectBoundingBox` | Coordinates are fractions of the filled shape's bounding box. |

Getting this backwards silently misplaces the gradient. Read the attribute; do
not guess from the numbers.

### What actually varies between colourways

Diff the exports. In the common case, only the `stop-color` values change:

```
Default        stop 0.5 #1F1F1F   stop 1.0 #B4B4B4
Colourway A    stop 0.5 #1E1E52   stop 1.0 #2E79DC
Colourway B    stop 0.5 #2C2354   stop 1.0 #6447A8
```

Note the *offsets* are identical and the *matrix* is identical. That is the
whole basis for injection: **a colourway is a list of colours, nothing more.**

> Check every element, not just the obvious one. It is easy to diff the badge
> gradient, see the pattern, and miss that a second element — a wordmark, a
> registered-trademark glyph — also recolours. Grep the `fill` attributes of
> *all* paths across *all* variants before deciding what is constant:
>
> ```sh
> for f in *.svg; do
>   printf '%-20s ' "$f"
>   grep -o 'fill="#[0-9A-Fa-f]\{6\}"' "$f" | sort -u | tr '\n' ' '
>   echo
> done
> ```

---

## 3. Injecting gradients

The technique: **hold the geometry once, supply the colours at render time.**

Represent a colourway as data, not as an asset:

```
Colourway := { stops: [Colour], plus any flat fills the variant changes }
```

Then the renderer is a pure function of `(geometry, colourway)`.

### Web — CSS custom properties

Inline the SVG once and drive the stops from variables:

```html
<svg viewBox="0 0 83.34 35.65" class="logomark">
  <path d="…" fill="url(#badge)"/>
  <path d="…" fill="var(--logo-wordmark)"/>
  <defs>
    <radialGradient id="badge" cx="0" cy="0" r="1"
                    gradientUnits="userSpaceOnUse"
                    gradientTransform="matrix(-12.93 15.06 -21.94 -18.34 17.88 17.82)">
      <stop offset="0.5" stop-color="var(--logo-stop-0)"/>
      <stop offset="1"   stop-color="var(--logo-stop-1)"/>
    </radialGradient>
  </defs>
</svg>
```

```css
.logomark            { --logo-stop-0:#1F1F1F; --logo-stop-1:#B4B4B4; --logo-wordmark:#1F1F1F; }
.logomark--ocean     { --logo-stop-0:#1E1E52; --logo-stop-1:#2E79DC; --logo-wordmark:#14399F; }
```

One caveat: `<use href="sprite.svg#logo">` will **not** inherit custom
properties across the document boundary. The SVG has to be inline for this to
work.

### Web — templating the markup

If you cannot inline, treat the SVG as a string template and substitute before
parsing:

```js
const TEMPLATE = `<svg …><stop offset="0.5" stop-color="{{stop0}}"/>…</svg>`;

const render = (colourway) =>
  TEMPLATE.replace(/{{(\w+)}}/g, (_, key) => colourway[key]);
```

Escape or validate the substituted values if they can come from user input —
this is string interpolation into markup.

### Flutter

Keep the path data as strings, parse to `Path` once, and build the shader per
colourway. `dart:ui` takes the same affine matrix, as a column-major 4×4:

```dart
Shader badgeShader(Rect rect, List<Color> stops) {
  const view = Size(83.34, 35.65);
  final sx = rect.width / view.width;
  final sy = rect.height / view.height;

  return ui.Gradient.radial(
    Offset.zero,   // the unit circle the SVG declared
    1,
    stops,
    const <double>[0.5, 1.0],
    TileMode.clamp,
    Float64List.fromList(<double>[
      -12.93 * sx,  15.06 * sy, 0, 0,
      -21.94 * sx, -18.34 * sy, 0, 0,
                0,           0, 1, 0,
      17.88 * sx + rect.left, 17.82 * sy + rect.top, 0, 1,
    ]),
  );
}
```

The column-major layout maps to `matrix(a b c d e f)` as
`[a, b, 0, 0,  c, d, 0, 0,  0, 0, 1, 0,  e, f, 0, 1]`.

### iOS / Android

Both platforms can express the same thing. On iOS, `CGGradient` drawn through a
`CGAffineTransform(a:b:c:d:tx:ty:)` built from the identical six numbers. On
Android, `RadialGradient` with `setLocalMatrix()` fed the 3×3 form. In every
case the six exported values transfer unchanged — that is the point of reading
them out of the matrix rather than eyeballing the rendered result.

### What you gain

- **One geometry, *n* colourways.** Adding a colourway is adding a row of data.
- **Colours outside the shipped set.** Because the renderer takes a list, a
  caller can pass any pair — useful for a partner brand or a one-off campaign
  before it has a token.
- **No asset pipeline.** No re-export, no cache-busting, no risk of one variant
  drifting from the others.

---

## 4. Keeping it resolution-independent

Artwork is authored against a fixed frame — the `viewBox`. When you draw it at
some other size, the gradient has to scale with it or it will drift off the
shape.

Given a view box `W × H` rendered into `w × h`, with `sx = w/W`, `sy = h/H`:

```
a' = a·sx    c' = c·sx    e' = e·sx + originX
b' = b·sy    d' = d·sy    f' = f·sy + originY
```

Scale the linear part by the axis scale; scale *and* translate the origin.

Two ways this goes wrong:

**Baking a fixed angle instead of a transform.** CSS exports sometimes reduce a
gradient to `linear-gradient(163.9deg, …)`. That angle is only correct at the
frame's original aspect ratio. Render the same artwork wider or shorter and the
sweep visibly skews. If the design tool draws the gradient corner-to-corner,
express it as corner-to-corner (`begin: topLeft, end: bottomRight` or
equivalent) rather than as a degree value.

**Non-uniform scaling.** If `sx ≠ sy`, the mark distorts. For a logo this is a
brand problem, not a cosmetic one. Assert it in debug:

```dart
assert(
  ((view.width / view.height) - (size.width / size.height)).abs() < 0.01,
  'Logomark given a non-uniform size; the artwork will distort.',
);
```

---

## 5. Gradient pitfalls

### Fill rules decide whether holes are holes

A mark with a counter — a letterform knocked out of a badge — is usually one
path with two subpaths. Whether the inner one is a *hole* or a filled blob
depends on the fill rule:

| Rule | Behaviour |
|---|---|
| `nonzero` (SVG and most renderers' default) | Hole only if the subpaths wind in opposite directions. |
| `evenodd` | Always a hole, regardless of winding. |

Preserve the rule **per path**. Combining paths that use different rules into a
single path under one rule will fill counters that should be open. If you need
one path for performance, combine them with a boolean union rather than by
concatenation.

### Alpha in sampled pixels is usually premultiplied

If you read pixels back for testing, most APIs hand you premultiplied RGBA. A
50%-alpha pure red is `(127, 0, 0, 127)`, not `(255, 0, 0, 127)`. Un-premultiply
before comparing against a source colour, or compare only fully-opaque pixels.

### Stops that do not start at 0 or end at 1

`stop offset="0.5"` means the first colour is flat from 0 to 0.5, then
interpolates. Renderers clamp by default, so this usually transfers correctly —
but if you re-normalise stops to `[0, 1]` "for tidiness" you will change the
appearance.

### Elliptical arcs

If the exported path data contains `A`/`a` commands and your renderer or parser
does not support them, **fail loudly**. Silently skipping an arc draws a subtly
wrong shape that no one notices until it is on a billboard.

---

## 6. Optional elements: the boolean property

The second property — `productName: on/off` — looks trivial. It is where most
of the avoidable mistakes live.

### What the design tool means

In Figma, a boolean property toggles a layer's visibility. It says nothing
about layout, semantics, or what the element's content should be. Those are
decisions you are making, whether or not you notice you are making them.

### Choose the API shape deliberately

There are three reasonable shapes, and they are not interchangeable:

| Shape | Use when |
|---|---|
| `showX: bool` | The element's content is fixed or has a sensible default. Mirrors the design property one-to-one, which keeps the mapping obvious to whoever compares code against Figma. |
| `x: String?` (null hides) | The content varies per call site. One parameter, so a caller cannot ask for a name that is not supplied. |
| `x: Widget?` / slot | The element is arbitrary content the caller composes. |

The strongest argument for `showX: bool` is **traceability**: a reviewer holding
the Figma file next to the code sees the same property with the same name. The
strongest argument against it is the failure mode below.

### Never allow two sources of truth to disagree

This is the one hard rule. If you have both a flag and a value:

```dart
BrandLockup(showProductName: true, productName: null)   // now what?
```

…you have created a state that has no correct rendering. Either collapse them
into one parameter, or make the invalid combination unrepresentable:

```dart
// One parameter: null means hidden. No contradictory state exists.
const Lockup({this.productName});

// Or keep both, and make the flag the only switch — the value always has a
// default, so it can never be "shown but absent".
const Lockup({this.showProductName = true, this.productName = 'String'});
```

The same reasoning applies to disabled states: prefer `onPressed: null` over a
separate `isDisabled` flag, for exactly this reason.

### Match the design's default

If the design tool's default variant has the element **on**, your parameter
defaults to on. This sounds obvious and is regularly got wrong, because the
person writing the component is thinking about the minimal case while the
designer specified the full one. Check the default variant, not the first one
in the list.

### Hiding is a layout decision

`if (show) Element()` removes the element from layout entirely. Sometimes that
is right. Sometimes it causes the container to resize in a way the design never
anticipated — a row that reflows, a centre point that shifts.

Decide explicitly between:

- **Remove** — gone from layout. Correct for a lockup that should hug its
  content.
- **Reserve** — hidden but still occupying space. Correct when something must
  not move, such as a label swapped for a spinner mid-interaction.

```dart
// Remove
if (showProductName) Text(productName),

// Reserve: laid out, painted transparent, so nothing shifts.
Opacity(opacity: showProductName ? 1 : 0, child: Text(productName)),
```

### Hiding is also an accessibility decision

A logomark is meaningful content that assistive technology cannot read from
vector paths. Expose it as a single labelled image and keep the label in sync
with what is actually shown:

```dart
Semantics(
  image: true,
  label: showProductName ? '$brand $productName' : brand,
  child: ExcludeSemantics(child: artwork),
)
```

Two failure modes worth naming:

- **Leaking internals.** If the mark is drawn from text glyphs rather than
  paths, a screen reader may announce stray letters. Wrap the artwork in an
  exclusion and provide one deliberate label.
- **A stale label.** If the label is built once and the toggle changes, the
  announced name no longer matches the rendering. Derive the label from the
  same state that drives the rendering.

### Scaling interacts with it

If the component scales, decide whether the optional element scales too. A
logomark whose wordmark is *artwork* should scale with the mark. One whose
product name is *text* often should not — text has its own type scale, and
scaling it produces sizes that exist nowhere in the type system.

There is no universally correct answer. There is a wrong one: not deciding, and
letting it fall out of the layout code.

---

## 7. Testing colour you cannot see

Colour injected into vector artwork is unusually easy to get wrong and
unusually hard to catch, because it is invisible to the tests people normally
write.

**Widget and DOM tests cannot see it.** They assert structure. A logomark
painted entirely in the wrong colour still has the right nodes.

**Screenshot tests are weaker here than they look.** Cross-platform text and
curve antialiasing produces a noise floor, and the tolerance you need to absorb
it may be larger than the signal you are trying to catch. Work it out
explicitly:

```
frame              400 × 200 = 80,000 px
antialiasing noise            ~640 px  = 0.80%
a wrong colourway  badge only ~1,100 px = 1.40%
```

At a tolerance loose enough to be stable, those are the same order of
magnitude. The screenshot cannot reliably distinguish them, and raising the
tolerance until it passes means it no longer guards the thing you care about.

**So assert the pixels directly.** Rasterise the shape, sample points well
inside it, and check the colour:

```dart
final point = interiorPoint(path);   // found, not guessed — see below
final pixel = samplePixel(raster, point);
expect(pixel, colourway.wordmark);
```

Two details make this reliable:

- **Find the sample point, do not guess it.** Glyphs and marks are thin and
  irregular; a hand-picked coordinate lands in a counter or between strokes
  surprisingly often. Search for a point the path reports as inside *and* whose
  four neighbours are inside, so the sample is clear of any antialiased edge.
- **Assert the invariant, not just the value.** Alongside "this colourway
  paints this colour", assert the rule: that no two colourways share a tone,
  and that the deliberately constant element matches none of them. Those catch
  a whole class of copy-paste error that per-value assertions miss.

Keep the screenshot tests. Just be explicit in the file about what they cover —
layout and geometry — and what covers colour instead.

---

## Summary

- Geometry is invariant across colourways; **colour is the only variable**.
  Build one renderer, parameterise the colour.
- Design tools put all gradient geometry in `gradientTransform`, against a unit
  circle. Read the six numbers; do not re-derive them by eye.
- Scale the matrix with the frame. A baked-in angle only holds at one aspect
  ratio.
- Preserve fill rules per path, or counters fill in.
- A boolean property is three separate decisions: API shape, layout, and
  accessibility. Make each one deliberately.
- Never let a flag and a value contradict each other.
- Screenshot tests cannot reliably guard injected colour. Sample pixels, and
  assert the rule as well as the value.
