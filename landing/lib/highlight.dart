/// Build-time syntax highlighting for the Dart snippets.
///
/// Tokenizing is done by `syntax_highlight_lite`, the pure-Dart TextMate engine
/// behind `jaspr_content`, while the site is pre-rendered. Its scopes are
/// mapped to CSS classes here, so the browser receives finished `<span>`
/// markup and never downloads a highlighting library. The classes are coloured
/// in `web/styles.css`, with one palette per theme.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart' as sh;

/// Registers the Dart grammar, which ships with the engine. Call once before
/// rendering.
Future<void> initHighlighting() => sh.Highlighter.initialize(['dart']);

/// Colours come from CSS classes, not from the engine's theme, so the theme is
/// empty. Its text style is required but never rendered.
final _theme = sh.HighlighterTheme.fromConfiguration(
  '{"settings": []}',
  sh.TextStyle(foreground: const sh.Color(0)),
);

final _highlighter = sh.Highlighter(language: 'dart', theme: _theme);

/// TextMate scope prefixes to CSS classes (`tk-<class>`). For each token the
/// innermost scope is tried first, longest prefix first; a scope with no entry
/// falls through to its parent, so punctuation inside a string stays a string.
const _scopeClasses = <String, String>{
  'comment.block.documentation': 'doc',
  'comment': 'comment',
  'string': 'string',
  'constant.character.escape': 'string',
  'constant.numeric': 'number',
  'constant.language': 'keyword',
  'keyword.operator': 'operator',
  'keyword': 'keyword',
  'storage.type.annotation': 'annotation',
  'storage': 'keyword',
  'variable.language': 'keyword',
  'support.class': 'type',
  'entity.name.function': 'function',
  'entity.name.type': 'type',
  'meta.embedded.expression': 'annotation',
};

/// Highlights Dart [source] and wraps each line in a `span.line`.
List<Component> highlightDart(String source) {
  return [
    for (final (index, line) in _lines(source).indexed) ...[
      if (index > 0) const .text('\n'),
      span(classes: 'line', line),
    ],
  ];
}

List<List<Component>> _lines(String source) {
  final lines = <List<Component>>[<Component>[]];
  for (final (text, className) in _flatten(_highlighter.highlight(source))) {
    for (final (index, part) in text.split('\n').indexed) {
      if (index > 0) {
        lines.add(<Component>[]);
      }
      if (part.isEmpty) {
        continue;
      }
      lines.last.add(
        className == null
            ? .text(part)
            : span(classes: 'tk-$className', [.text(part)]),
      );
    }
  }
  return lines;
}

/// Walks the span tree into `(text, class)` runs, in document order.
Iterable<(String, String?)> _flatten(sh.TextSpan node) sync* {
  if (node.text case final text?) {
    yield (text, _classFor(node.scopes));
  }
  for (final child in node.children) {
    yield* _flatten(child);
  }
}

String? _classFor(List<String> scopes) {
  for (final scope in scopes.reversed) {
    final parts = scope.split('.');
    for (var length = parts.length; length > 0; length--) {
      final className = _scopeClasses[parts.take(length).join('.')];
      if (className != null) {
        return className;
      }
    }
  }
  return null;
}
