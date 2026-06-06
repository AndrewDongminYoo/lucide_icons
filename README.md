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
      ref: v1.17.0 # any tag, branch, or commit SHA
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

Icons are distributed as a font via the [`lucide-static`](https://www.npmjs.com/package/lucide-static)
npm package. To update to a newer Lucide release:

### **1. Download the latest font assets**

```sh
npm install lucide-static
```

### **2. Copy font files into `assets/`**

```sh
cp node_modules/lucide-static/font/lucide.css assets/lucide.css
cp node_modules/lucide-static/font/lucide.ttf assets/lucide.ttf
```

### **3. Regenerate `lib/lucide_icons.dart`**

```sh
dart run tool/generate_fonts.dart assets/lucide.css
```

The generator parses the CSS file for `.icon-<name>::before { content: "\<hex>"; }` rules and
produces the corresponding Dart constants automatically.

#### Optional: embed SVG previews in dartdoc

Pass `--inline-svg` to embed each icon's SVG as a base64 data URI in its `///` doc comment.
This enables inline icon previews in the IDE when hovering over a `LucideIcons.*` constant.

```sh
# Use SVGs from the local npm install (fastest)
dart run tool/generate_fonts.dart assets/lucide.css \
  --inline-svg \
  --svg-dir=node_modules/lucide-static/icons

# Fall back to fetching SVGs remotely if the local directory is absent
dart run tool/generate_fonts.dart assets/lucide.css --inline-svg
```
