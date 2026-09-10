// Every CSS class on the landing page is declared once, as a `ClassName`
// constant on the component that owns it (see `lib/styles.dart`). Jaspr
// collects all the `@css` getters into one global stylesheet and scopes
// nothing, so two components declaring the same name would silently style each
// other. This check reads `lib/` and fails when
//
// - the same `ClassName('…')` literal is declared in more than one place, or
// - a class is written as a raw string (`'af-…'`, `'.af-…'`) outside a
//   `ClassName(…)` declaration.
//
//     dart run tool/check_class_names.dart
import 'dart:io';

final _declaration = RegExp(r"ClassName\('([^']+)'\)");

/// A string literal that is a class name or a selector: `'af-x'`,
/// `'af-x af-y'`, `'.af-x …'`. `--af-*` custom properties and `af-pulse` in
/// an `animation` shorthand do not match.
final _rawClass = RegExp(r"'(?:\.af-[^']*|af-[a-z0-9-]+(?: af-[a-z0-9-]+)*)'");

void main() {
  final files =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('.generated.dart'))
          .where((f) => !f.path.endsWith('.options.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final owners = <String, List<String>>{};
  final problems = <String>[];

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (final (index, line) in lines.indexed) {
      final where = '${file.path}:${index + 1}';
      for (final match in _declaration.allMatches(line)) {
        owners.putIfAbsent(match[1]!, () => []).add(where);
      }
      final stripped = line.replaceAll(_declaration, '');
      for (final match in _rawClass.allMatches(stripped)) {
        // The one keyframes name is not a class.
        if (stripped.contains('keyframes(${match[0]}')) {
          continue;
        }
        problems.add(
          '$where: ${match[0]} is a raw class name; declare a ClassName on '
          'the component that owns it and use its `.name` or `.selector`.',
        );
      }
    }
  }

  for (final MapEntry(key: name, value: places) in owners.entries) {
    if (places.length > 1) {
      problems.add(
        "'$name' is declared ${places.length} times; a class has one owner: "
        '${places.join(', ')}',
      );
    }
  }

  if (problems.isNotEmpty) {
    stderr.writeln(problems.join('\n'));
    exit(1);
  }
  stdout.writeln(
    '${owners.length} class names, each declared once, in ${files.length} '
    'files.',
  );
}
