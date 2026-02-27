// ignore_for_file: avoid_print, avoid_catches_without_on_clauses, document_ignores

import 'dart:convert';
import 'dart:io';

const _fallbackLucideStaticVersion = '0.575.0';
const _requestTimeout = Duration(seconds: 12);
const _defaultSvgDir = './node_modules/lucide-static/icons';
const _lucideStaticPackageJson = './node_modules/lucide-static/package.json';

String _resolveLucideStaticVersion() {
  final packageJson = File(_lucideStaticPackageJson);
  if (packageJson.existsSync()) {
    final decoded = jsonDecode(packageJson.readAsStringSync()) as Map<String, dynamic>;
    final version = decoded['version'];
    if (version is String && version.isNotEmpty) {
      return version;
    }
  }
  return _fallbackLucideStaticVersion;
}

String _toCamelCase(String name) {
  final parts = name.split('-');
  return parts.first + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String _toReadableName(String name) => name.replaceAll('-', ' ');

String _normalizeDirPath(String path) {
  if (path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

File? _findLocalSvgFile(String name, List<String> svgDirs) {
  for (final dir in svgDirs) {
    final normalizedDir = _normalizeDirPath(dir);
    final file = File('$normalizedDir/$name.svg');
    if (file.existsSync()) {
      return file;
    }
  }
  return null;
}

String _svgDataUriFromContent(String svgContent) {
  final normalizedSvg = svgContent.trim();
  final base64Svg = base64.encode(utf8.encode(normalizedSvg));
  return 'data:image/svg+xml;base64,$base64Svg';
}

Future<String?> _loadSvgDataUri(
  HttpClient client,
  String name,
  List<String> svgDirs,
  String baseUrl,
) async {
  final localSvgFile = _findLocalSvgFile(name, svgDirs);
  if (localSvgFile != null) {
    final svg = localSvgFile.readAsStringSync();
    return _svgDataUriFromContent(svg);
  }

  final urls = <String>[
    '$baseUrl/$name.svg',
    'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/$name.svg',
  ];

  for (final url in urls) {
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(_requestTimeout);
      final response = await request.close().timeout(_requestTimeout);

      if (response.statusCode != HttpStatus.ok) {
        continue;
      }

      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) {
            buffer.addAll(chunk);
            return buffer;
          })
          .timeout(_requestTimeout);

      final svg = utf8.decode(bytes);
      return _svgDataUriFromContent(svg);
    } catch (_) {
      continue;
    }
  }

  return null;
}

Future<Map<String, String>> _buildSvgDataUriMap(
  List<String> names,
  List<String> svgDirs,
  String baseUrl,
) async {
  final client = HttpClient();
  client.connectionTimeout = _requestTimeout;
  final result = <String, String>{};
  var failed = 0;

  try {
    const batchSize = 8;

    for (var i = 0; i < names.length; i += batchSize) {
      final end = (i + batchSize < names.length) ? i + batchSize : names.length;
      final batch = names.sublist(i, end);

      final fetched = await Future.wait(
        batch.map((name) async {
          final dataUri = await _loadSvgDataUri(client, name, svgDirs, baseUrl);
          return (name: name, dataUri: dataUri);
        }),
      );

      for (final item in fetched) {
        if (item.dataUri != null) {
          result[item.name] = item.dataUri!;
        } else {
          failed++;
        }
      }

      final processed = end;
      print(
        'Fetched SVG previews: ${result.length}/${names.length} (processed $processed, failed $failed)',
      );
    }
  } finally {
    client.close(force: true);
  }

  return result;
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print(
      'Usage: dart run tool/generate_fonts.dart <path-to-css> [--inline-svg] [--svg-dir=path]',
    );
    exit(1);
  }

  final inlineSvg = args.contains('--inline-svg');
  final svgDirArgs = args
      .where((arg) => arg.startsWith('--svg-dir='))
      .map((arg) => arg.substring('--svg-dir='.length))
      .where((arg) => arg.isNotEmpty)
      .toList();
  final svgDirs = svgDirArgs.isEmpty ? <String>[_defaultSvgDir] : svgDirArgs;
  final lucideVersion = _resolveLucideStaticVersion();
  final lucideBaseUrl = 'https://unpkg.com/lucide-static@$lucideVersion/icons';
  final cssPath = args.firstWhere(
    (arg) => !arg.startsWith('--svg-dir=') && arg != '--inline-svg',
    orElse: () => '',
  );

  if (cssPath.isEmpty) {
    print('lucide.css path not provided');
    exit(1);
  }

  final cssFile = File(cssPath);

  if (!cssFile.existsSync()) {
    print('lucide.css file not found');
    exit(1);
  }

  final content = cssFile.readAsStringSync();
  final pattern = RegExp(
    r'\.icon-([^:]+)::before\s*\{\s*content:\s*"\\([0-9a-fA-F]+)";\s*\}',
  );
  final matches = pattern.allMatches(content);
  final names = matches.map((match) => match.group(1)!).toList();
  if (inlineSvg) {
    final existingSvgDirs = svgDirs.where((dir) => Directory(dir).existsSync()).toList();
    if (existingSvgDirs.isEmpty) {
      print(
        'No local SVG directory found. Falling back to remote SVG sources.',
      );
    } else {
      print('Using local SVG directories first: ${existingSvgDirs.join(', ')}');
    }
  }
  final svgDataUris = inlineSvg ? await _buildSvgDataUriMap(names, svgDirs, lucideBaseUrl) : <String, String>{};

  final generatedOutput = <String>[
    '// 🐦 Flutter imports:\n',
    "import 'package:flutter/widgets.dart';\n\n",
    '// 🌎 Project imports:\n',
    "import 'package:lucide_icons/src/icon_data.dart';\n\n",
    '// THIS FILE IS AUTOMATICALLY GENERATED!\n\n',
    'class LucideIcons {',
  ];

  for (final match in matches) {
    final name = match.group(1)!;
    final hex = match.group(2)!.toUpperCase();
    final readableName = _toReadableName(name);

    final inlinePreview = svgDataUris[name];
    if (inlinePreview != null) {
      generatedOutput.add(
        '\n  /// [![]($inlinePreview)](https://lucide.dev/icons/$name)\n',
      );
    } else {
      generatedOutput.add(
        '\n  /// [![]($lucideBaseUrl/$name.svg)](https://lucide.dev/icons/$name)\n',
      );
    }
    generatedOutput.add('  /// Lucide icon named "$readableName".\n');
    generatedOutput.add(
      '  static const IconData ${_toCamelCase(name)} = LucideIconData(0x$hex);\n',
    );
  }

  generatedOutput.add('}\n');

  final output = File('./lib/lucide_icons.dart');
  output.writeAsStringSync(generatedOutput.join());
  print('Generated ${matches.length} icons at ${output.path}');
}
