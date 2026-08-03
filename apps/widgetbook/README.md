# sav_catalog

The web catalog for the Sav design system, deployed to
<https://kraryan.github.io/sav-ds/>.

This is a **consumer** of `sav_design_system`, not part of it — the published
package carries no Widgetbook dependency, so nothing here reaches a production
app bundle.

## Run it

```sh
flutter run -d chrome
```

## Add a use case

1. Write a builder function annotated with `@UseCase` in `lib/use_cases/`
   (components) or `lib/foundations/` (tokens).
2. Regenerate the navigation tree:

   ```sh
   dart run build_runner build
   ```

3. Add its name to the structural assertion in `test/catalog_test.dart`.

CI fails if `main.directories.g.dart` is stale, so a use case cannot silently
go missing from the deployed site.

## What belongs here

Alongside the rendered component, each entry carries the information a
developer needs to use it: the full API, measurements, state behaviour, do/don't
guidance and accessibility notes. See `lib/use_cases/sav_button_use_cases.dart`
for the pattern, and `lib/widgets/spec_sheet.dart` for the building blocks.
