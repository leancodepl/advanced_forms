/// The live examples the landing page embeds.
///
/// They are authored once, as MDX in `docs_app/content/landing/`, and compiled
/// into the docs app's Flutter bundle by `npm run examples:generate`. That
/// script also writes `docs_app/flutter/web/examples.json`, which maps each
/// compiled example to the id the bundle registers it under. This module reads
/// both at build time, so the code shown on the page and the island running
/// next to it are the same snippet by construction.
library;

import 'dart:convert';
import 'dart:io';

const _contentDir = '../docs_app/content/landing';
const _examplesJson = '../docs_app/flutter/web/examples.json';

/// One Dart fence of an example, with the file name its `title` gave it.
class ExampleFile {
  const ExampleFile({required this.name, required this.code});

  final String name;
  final String code;
}

class LandingExample {
  const LandingExample({
    required this.id,
    required this.preview,
    required this.title,
    required this.files,
  });

  /// The id the Flutter bundle registered the example under.
  final String id;

  /// The widget the island mounts.
  final String preview;

  /// The frame's title-bar text.
  final String title;

  final List<ExampleFile> files;
}

final _tag = RegExp(r'<AdvancedFormsExample\b([^>]*)>');
final _attribute = RegExp(r'(\w+)="([^"]*)"');
final _fence = RegExp(
  r'^```dart(?:[ \t]+title="([^"]*)")?[^\n]*\n([\s\S]*?)\n```[ \t]*$',
  multiLine: true,
);

/// Loads `content/landing/<name>.mdx`.
///
/// Throws when the file is missing or when the bundle does not know the
/// example, which means `npm run examples:generate` has not run since the
/// MDX changed — a stale page is worse than a failed build.
LandingExample loadExample(String name) {
  final file = File('$_contentDir/$name.mdx');
  if (!file.existsSync()) {
    throw StateError('No landing example at ${file.path}.');
  }
  final source = file.readAsStringSync();

  final tag = _tag.firstMatch(source);
  if (tag == null) {
    throw StateError('${file.path} has no <AdvancedFormsExample>.');
  }
  final attributes = {
    for (final m in _attribute.allMatches(tag[1]!)) m[1]!: m[2]!,
  };

  final files = [
    for (final (index, m) in _fence.allMatches(source).indexed)
      ExampleFile(
        name: m[1] ?? 'file_${index + 1}.dart',
        code: m[2]!.trimRight(),
      ),
  ];
  if (files.isEmpty) {
    throw StateError('${file.path} has no ```dart fence.');
  }

  final preview = attributes['preview'] ?? _inferPreview(files);
  final id = _idFor(preview, file.path);

  return LandingExample(
    id: id,
    preview: preview,
    title: attributes['title'] ?? '$preview · live example',
    files: files,
  );
}

String _inferPreview(List<ExampleFile> files) {
  final match = RegExp(
    r'^class\s+(\w+)\s+extends\s+(?:StatelessWidget|StatefulWidget)\b',
    multiLine: true,
  ).firstMatch(files.map((f) => f.code).join('\n'));
  if (match == null) {
    throw StateError('No widget class to mount; add preview="…".');
  }
  return match[1]!;
}

final List<Map<String, Object?>> _registry = () {
  final file = File(_examplesJson);
  if (!file.existsSync()) {
    throw StateError(
      'Missing $_examplesJson — run `npm run examples:generate` in docs_app.',
    );
  }
  return (jsonDecode(file.readAsStringSync()) as List)
      .cast<Map<String, Object?>>();
}();

String _idFor(String preview, String path) {
  final matches = _registry.where((e) => e['preview'] == preview).toList();
  if (matches.isEmpty) {
    throw StateError(
      'The Flutter bundle has no example previewing $preview ($path) — run '
      '`npm run examples:generate` in docs_app.',
    );
  }
  if (matches.length > 1) {
    throw StateError('Several compiled examples preview $preview.');
  }
  return matches.single['id']! as String;
}
