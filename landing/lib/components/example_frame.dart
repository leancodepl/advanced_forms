import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/highlight.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// How the frame arranges the running example and its source.
enum ExampleLayout {
  /// Only the running example — the hero.
  stage,

  /// Source on the left, one file at a time, the running example on the right.
  split,
}

/// The window around a live example: a title bar with the island's status,
/// the running Flutter view, and the source that produced it.
///
/// The stage is an empty `<div>` carrying the example id; `web/landing.js`
/// attaches a view of the shared Flutter engine to it once it scrolls near,
/// and keeps the status pill honest. File tabs are radio inputs and CSS —
/// no script needed to switch files.
class ExampleFrame extends StatelessComponent {
  const ExampleFrame({required this.example, required this.layout, super.key});

  final LandingExample example;
  final ExampleLayout layout;

  @override
  Component build(BuildContext context) {
    return figure(
      classes: 'af-example',
      attributes: {'data-layout': layout.name},
      [
        div(classes: 'af-example-bar', [
          const span(
            classes: 'af-dots',
            attributes: {'aria-hidden': 'true'},
            [span([]), span([]), span([])],
          ),
          span(classes: 'af-example-title', [.text(example.title)]),
          const span(
            classes: 'af-example-status',
            attributes: {'data-status': 'idle', 'aria-live': 'polite'},
            [.text('idle')],
          ),
        ]),
        div(classes: 'af-example-body', [
          div(
            classes: 'af-example-stage',
            attributes: {
              'data-example-id': example.id,
              'data-settled': 'false',
              'role': 'group',
              'aria-label': 'Live example: ${example.preview}',
            },
            const [],
          ),
          if (layout == ExampleLayout.split) _SourceTabs(example: example),
        ]),
        if (layout == ExampleLayout.split)
          const figcaption(classes: 'af-example-caption', [
            .text(
              'Field widgets prefixed Docs are shorthands the documentation '
              'defines, not part of the package. ',
            ),
            a(href: '$docsPath/rendering', [.text('Rendering fields')]),
            .text(' shows the widget code an app writes.'),
          ]),
      ],
    );
  }
}

class _SourceTabs extends StatelessComponent {
  const _SourceTabs({required this.example});

  final LandingExample example;

  @override
  Component build(BuildContext context) {
    final group = 'tabs-${example.id}';
    return div(
      classes: 'af-example-code',
      attributes: const {'data-tabs': 'true'},
      [
        div(classes: 'af-example-toolbar', [
          // What it is, to assistive technology: a group of radio buttons, one
          // per file, each followed by the label that is its visible tab. The
          // CSS reads the checked one to show its tab and its panel.
          div(
            classes: 'af-example-tabs',
            attributes: const {
              'role': 'radiogroup',
              'aria-label': 'Source files',
            },
            [
              for (final (index, file) in example.files.indexed) ...[
                Component.element(
                  tag: 'input',
                  attributes: {
                    'type': 'radio',
                    'name': group,
                    'id': '$group-$index',
                    'class': 'af-tab-input',
                    'aria-label': file.name,
                    if (index == 0) 'checked': '',
                  },
                ),
                label(
                  classes: 'af-example-tab',
                  attributes: {'for': '$group-$index'},
                  [.text(file.name)],
                ),
              ],
            ],
          ),
          button(
            classes: 'af-example-copy',
            attributes: const {
              'type': 'button',
              'data-copy': '',
              'aria-label': 'Copy this file',
              'title': 'Copy this file',
            },
            [
              span(classes: 'af-copy-idle', [Icon.copy.build(size: 15)]),
              span(classes: 'af-copy-done', [Icon.check.build(size: 15)]),
            ],
          ),
        ]),
        div(classes: 'af-example-panels', [
          for (final file in example.files)
            div(classes: 'af-code-panel', [
              pre(
                attributes: const {'tabindex': '0'},
                [code(highlightDart(file.code))],
              ),
            ]),
        ]),
      ],
    );
  }
}
