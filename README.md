# lucide_icons_lite

Lightweight [Lucide](https://lucide.dev) icons for Flutter.

This community-maintained package provides the Lucide icon set as `IconData` values backed by one bundled font.
It does not add stroke-weight variants, RTL mirroring, or per-icon widgets.

## Installation

```yaml
dependencies:
  lucide_icons_lite: ^1.39.0
```

Run `flutter pub get` after you add the dependency.
Package versions follow upstream [`lucide-static`](https://www.npmjs.com/package/lucide-static) releases.

## Migration from lucide_icons

Replace the `lucide_icons` dependency with `lucide_icons_lite`.
Replace `package:lucide_icons/lucide_icons.dart` with `package:lucide_icons_lite/lucide_icons_lite.dart`.
The package keeps the `LucideIcons` class.
Use `LucideIcons.circleEuro` in new code.
`LucideIcons.circleEuroSign` remains available as a deprecated alias for applications that used version 1.24.0.

## Usage

```dart
import 'package:lucide_icons_lite/lucide_icons_lite.dart';

Icon(LucideIcons.activity);
```

Visit [lucide.dev](https://lucide.dev) for the full icon list.

## Updating the icon set

Dependabot detects new `lucide-static` releases.
The **Update Lucide icons** workflow regenerates the package and opens a pull request.

Run the same update locally with the repository's `merry` script:

```sh
dart run merry run update-icons
```

The script performs these actions:

```sh
pnpm add lucide-static@latest
cp node_modules/lucide-static/font/lucide.css assets/lucide.css
cp node_modules/lucide-static/font/lucide.ttf assets/lucide.ttf
dart run tool/generate_fonts.dart assets/lucide.css \
  --inline-svg \
  --svg-dir=./node_modules/lucide-static/icons
```

The generator reads `.icon-<name>::before` rules from the CSS file and creates the corresponding Dart constants.
The `--inline-svg` flag adds SVG previews to the generated Dart documentation.
