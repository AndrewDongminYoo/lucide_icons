# Changelog

## 1.16.0 - 2026-05-23

### Added

- Updated icon set to lucide-static@1.16.0 (1,956 unique icons, up from 1,688).
- IDE dartdoc now shows inline SVG preview for each icon.

### Changed

- `LucideIconData` wrapper class removed; icon constants now use `IconData` directly, matching Flutter's own `Icons` class pattern.

### Fixed

- Fixed compile error: `IconData` is a `final` class in Dart 3 and cannot be subclassed outside its library.
- Fixed duplicate Dart identifier errors for aliased icon names (e.g., `arrow-down-0-1` and `arrow-down-01` both resolving to `arrowDown01`); the generator now skips aliases that collide with an already-emitted camelCase name.

### Internal

- Generator (`tool/generate_fonts.dart`) no longer depends on `src/icon_data.dart`.
- Removed Trunk.io configuration.
- Expanded `.gitignore` for development environments.

---

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
