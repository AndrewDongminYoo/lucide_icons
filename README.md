# lucide_icons

Lucide Icons ([lucide.dev](https://lucide.dev)) for Flutter.

This is a community fork maintained to keep the package up to date, as the original
[`lucide_icons`](https://pub.dev/packages/lucide_icons) package is no longer actively maintained.
The codebase has been modernized to align with Dart 3 conventions.

## Installation

This package is not published to pub.dev. Add it as a git dependency in your
`pubspec.yaml`, pinning to a release tag:

```yaml
dependencies:
  lucide_icons:
    git:
      url: https://github.com/AndrewDongminYoo/lucide_icons
      ref: v1.24.0 # any tag, branch, or commit SHA
```

Then run `flutter pub get`. Release tags follow the upstream `lucide-static`
version; see the [tags](https://github.com/AndrewDongminYoo/lucide_icons/tags)
for the latest.

## Usage

```dart
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
`lib/lucide_icons.dart` with inline SVG previews in one step:

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

# 3. Regenerate lib/lucide_icons.dart with inline SVG dartdoc previews
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
