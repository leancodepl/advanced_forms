import 'package:advanced_forms_landing/components/icons.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A shell command in a box with a copy button: `flutter pub add …` in the
/// hero, `dart run skills@ get` in the skill band. The button is wired by
/// `[data-copy-text]` in web/landing.js.
///
/// Styled by `.af-install-command*` in web/landing.css.
class InstallCommand extends StatelessComponent {
  const InstallCommand(this.command, {super.key});

  final String command;

  @override
  Component build(BuildContext context) {
    return div(classes: 'af-install-command', [
      const span(
        classes: 'af-prompt',
        attributes: {'aria-hidden': 'true'},
        [.text(r'$')],
      ),
      code([.text(command)]),
      button(
        classes: 'af-copy-button',
        attributes: {
          'type': 'button',
          'data-copy-text': command,
          'aria-label': 'Copy to clipboard',
          'aria-live': 'polite',
        },
        [
          span(classes: 'af-copy-idle', [Icon.copy.build(size: 15)]),
          span(classes: 'af-copy-done', [Icon.check.build(size: 15)]),
          const span(classes: 'af-copy-label', [.text('Copy')]),
        ],
      ),
    ]);
  }
}
