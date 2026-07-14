# lucide_icons_lite

Lightweight [Lucide](https://lucide.dev) icons for Flutter.

## Why "lite"?

This package ships exactly one thing: the Lucide icon set as `IconData`, backed by
a single icon font. No stroke-weight variants, no RTL mirroring, no per-icon widget
API — just the icons, so your app stays small. If you need those extra features,
reach for a heavier Lucide package instead; this one is the minimal, drop-in choice.

The icon set is kept current with upstream [`lucide-static`](https://www.npmjs.com/package/lucide-static)
by automation (see below), and the codebase follows Dart 3 conventions.

## Installation

```yaml
dependencies:
  lucide_icons_lite: ^1.24.0
```

Then run `flutter pub get`. Package versions follow the upstream `lucide-static`
version.

## Usage

```dart
import 'package:lucide_icons_lite/lucide_icons_lite.dart';

Icon(LucideIcons.activity);
```

Visit [lucide.dev](https://lucide.dev) for the full list of available icons.

## Updating the icon set

Icons are generated from the [`lucide-static`](https://www.npmjs.com/package/lucide-static)
npm package. New releases are detected automatically by Dependabot, which opens a
notification PR; run the **Update Lucide icons** workflow (Actions → Run workflow)
to produce the regenerated PR.

To regenerate locally, use the bundled [merry](https://pub.dev/packages/merry)
script — it upgrades `lucide-static`, copies the font assets, and regenerates
`lib/lucide_icons_lite.dart` with inline SVG previews in one step:

```sh
dart run merry run update-icons
```

<details>
<summary>What the script runs</summary>

```sh
# 1. Upgrade the lucide-static dependency
pnpm add lucide-static@latest

# 2. Copy the font assets into assets/
cp node_modules/lucide-static/font/lucide.css assets/lucide.css
cp node_modules/lucide-static/font/lucide.ttf assets/lucide.ttf

# 3. Regenerate lib/lucide_icons_lite.dart with inline SVG dartdoc previews
dart run tool/generate_fonts.dart assets/lucide.css \
  --inline-svg \
  --svg-dir=./node_modules/lucide-static/icons
```

The generator parses the CSS file for `.icon-<name>::before { content: "\<hex>"; }`
rules and produces the corresponding Dart constants. The `--inline-svg` flag embeds
each icon's SVG as a base64 data URI in its `///` doc comment, enabling inline
previews in the IDE when hovering over a `LucideIcons.*` constant (omit it, or drop
`--svg-dir` to fetch SVGs remotely, if you don't need previews).

</details>
