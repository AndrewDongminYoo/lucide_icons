# Changelog

## 0.575.0

> Forked from the original `lucide_icons` package and modernized.

### Changed

- Updated icon set to Lucide v0.575.0 (1,688 icons).
- Switched icon generation source from the legacy `lucide-preview.html` to `lucide.css`,
  which is distributed via the `lucide-static` npm package.
- Generator (`tool/generate_fonts.dart`) now parses CSS directly using a regular expression,
  eliminating the `html` and `recase` dev dependencies.
- Modernized codebase to Dart 3 conventions (e.g. `switch` expressions, `///` doc comments,
  `super` parameters).
- Upgraded `very_good_analysis` and SDK constraints (`>=3.8.0 <4.0.0`, Flutter `>=3.24.0`).
