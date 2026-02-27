# lucide_icons

Lucide Icons ([lucide.dev](https://lucide.dev)) for Flutter.

This is a community fork maintained to keep the package up to date, as the original
[`lucide_icons`](https://pub.dev/packages/lucide_icons) package is no longer actively maintained.
The codebase has been modernized to align with Dart 3 conventions.

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
cp node_modules/lucide-static/font/lucide.ttf  assets/lucide.ttf
```

### **3. Regenerate `lib/lucide_icons.dart`**

```sh
dart run tool/generate_fonts.dart assets/lucide.css
```

The generator parses the CSS file for `.icon-<name>::before { content: "\<hex>"; }` rules and
produces the corresponding Dart constants automatically.
