# Logo Lockup Technique

The lockup uses one set of vector paths. At paint time, it injects a gradient
into the badge and paints the `Sav` wordmark separately with a flat color. No
per-colourway SVG or image assets are needed.

## Usage and Visibility

```dart
const SavBrandLockup(
  colourway: SavBrandColourway.cyanReserve,
  productName: 'Wealth',
  showWordmark: true,    // false: badge-only artwork
  showProductName: true, // false: omit the product text
)
```

`showProductName` only controls the optional text and its gap. `showWordmark`
independently controls the `Sav` vector glyphs. When it is `false`, the artwork
uses the badge-only view box, so it becomes a near-square mark instead of
leaving an empty wordmark gap; the badge gradient and semantic brand label
remain in place.

## Lockup Structure

The component uses one semantic image containing a compact row. The vector
artwork is `CustomPaint`; the optional product name is normal text.

```dart
final artwork = showWordmark
    ? SavLogoArtwork.viewBox
    : SavLogoArtwork.badgeViewBox;
final logoHeight = height ?? artwork.height;
final scale = logoHeight / artwork.height;

return Semantics(
  image: true,
  label: semanticLabel ?? (showProductName ? 'Sav $productName' : 'Sav'),
  child: ExcludeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(artwork.width * scale, logoHeight),
          painter: logoPainter,
        ),
        if (showProductName) ...[
          SizedBox(width: theme.gap * scale),
          Text(productName, style: theme.productNameStyle),
        ],
      ],
    ),
  ),
);
```

This structure lets the badge and wordmark scale as vector artwork while the
product name keeps its own typography. It also keeps the whole lockup available
to assistive technology as one labelled image.

## Gradient Injection

Each colourway provides the badge's dark `/800` and light `/600` colors. The
wordmark uses the same ramp's `/700` tone. Callers can override either element
independently.

```dart
final badgeGradient = theme.badgeGradient(
  gradientColors ?? colourway.colors,
);
final resolvedWordmarkColor =
    wordmarkColor ?? theme.wordmarkColor ?? colourway.wordmark;

canvas
  ..drawPath(
    SavLogoArtwork.badge,
    Paint()..shader = badgeGradient.createShader(Offset.zero & viewBox),
  );

if (showWordmark) {
  canvas.drawPath(
    SavLogoArtwork.wordmark,
    Paint()..color = resolvedWordmarkColor,
  );
}
```

Wordmark color precedence is: instance override → theme override → colourway
default. The product name keeps its independent text style.

## Figma Gradient Technique

Figma exports a radial gradient with a six-value affine transform. The
transform is preserved and scaled to the rendered size, which keeps its skewed
diagonal highlight in the same position whenever the lockup is resized.

```dart
return ui.Gradient.radial(
  Offset.zero,
  1,
  colors,
  const [0.5, 1],
  TileMode.clamp,
  Float64List.fromList([
    a * sx, b * sy, 0, 0,
    c * sx, d * sy, 0, 0,
    0, 0, 1, 0,
    e * sx + rect.left, f * sy + rect.top, 0, 1,
  ]),
);
```

`sx` and `sy` are the rendered width and height divided by the original Figma
frame dimensions.
