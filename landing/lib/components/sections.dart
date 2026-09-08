import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/example_frame.dart';
import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/pill.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// "The model": the whole form next to the code that is the whole form.
class ModelSection extends StatelessComponent {
  const ModelSection({required this.example, super.key});

  final LandingExample example;

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'model',
      eyebrow: 'The model',
      heading: const [
        .text('A controller holds the fields. A widget binds to each one.'),
      ],
      lead: rich(
        'No `Form` widget, no `GlobalKey`, no `TextEditingController` '
        'plumbing. The controller below is the whole form; the widgets only '
        'render it. It is running on the right — submit it empty.',
      ),
      children: [
        ExampleFrame(example: example, layout: ExampleLayout.split),
        ul(classes: 'af-checklist', [
          li([
            strong(rich('One call to `registerFields`')),
            ...rich(
              ' and the form owns the fields: it disposes them, tracks '
              '`wasModified`, and reaches them in `validate`, `resetAll` and '
              'every other broadcast.',
            ),
          ]),
          li([
            strong(
              rich(
                'The field owns its `TextEditingController` and `FocusNode`.',
              ),
            ),
            ...rich(
              ' Bind the widget to `field.textController` and programmatic '
              'writes — `reset`, `prefill`, a relation — show up on screen.',
            ),
          ]),
          li([
            const strong([.text('Errors are your type.')]),
            ...rich(
              ' `E` is whatever you choose: a string, an enum, a sealed class. '
              'The package never formats a message.',
            ),
          ]),
        ]),
      ],
    );
  }
}

class _Rule {
  const _Rule(this.title, this.body);

  final String title;
  final String body;
}

const _rules = [
  _Rule(
    'The mode decides what triggers a field.',
    'Set `ValidationMode` once on the form and it reaches every field and '
        'subform. A field or a subform can opt out with a mode of its own.',
  ),
  _Rule(
    'Sync first, async only if sync passed.',
    'A round never asks the server about a value the sync validator already '
        'rejected. One round per field at a time; a newer value replaces the '
        'round in flight.',
  ),
  _Rule(
    'Untouched fields stay quiet.',
    'A field the user has never edited validates nothing on its own, in every '
        'mode. `validate()` is what checks those — so a prefilled form never '
        'greets the user with errors.',
  ),
];

class _Mode {
  const _Mode(this.icon, this.name, this.tag, this.when, this.body);

  final Icon icon;
  final String name;
  final String tag;
  final String when;
  final String body;
}

const _modes = [
  _Mode(
    Icon.hand,
    'manual',
    'default',
    'Validates on submit.',
    'Nothing shouts while the user fills the form in. After the first submit, '
        'an edit clears the error that described the old value.',
  ),
  _Mode(
    Icon.keyboard,
    'onUserInteraction',
    'live',
    'Validates on every keystroke.',
    'Immediate feedback on the field being edited. Async checks wait out their '
        'debounce, so typing runs one request, not ten.',
  ),
  _Mode(
    Icon.squareDashed,
    'onUnfocus',
    'on leave',
    'Validates when a field loses focus.',
    'The user finishes a field, moves on, and sees the verdict. Tabbing through '
        'a field they never touched costs nothing.',
  ),
];

/// "Three rules": the trigger behaviour, the three modes, and a demo that
/// switches between them.
class ValidationSection extends StatelessComponent {
  const ValidationSection({required this.example, super.key});

  final LandingExample example;

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'validation',
      eyebrow: 'Three rules',
      heading: const [.text('Validation you can predict.')],
      lead: const [
        .text(
          'The whole trigger behaviour is twenty lines of Dart. Pick a mode, '
          'then switch it below while you type to feel the difference.',
        ),
      ],
      children: [
        ol(classes: 'af-rules', [
          for (final rule in _rules)
            li(classes: 'af-rule', [
              h3([.text(rule.title)]),
              p(rich(rule.body)),
            ]),
        ]),
        ul(classes: 'af-feature-grid af-modes', [
          for (final mode in _modes)
            li(classes: 'af-card af-mode', [
              div(classes: 'af-mode-head', [
                span(classes: 'af-feature-icon', [mode.icon.build(size: 22)]),
                Pill(mode.tag, accent: true),
              ]),
              h3([
                code([.text(mode.name)]),
              ]),
              p(classes: 'af-mode-when', [.text(mode.when)]),
              p([.text(mode.body)]),
            ]),
        ]),
        const p(classes: 'af-section-more', [
          a(href: '$docsPath/validation/modes', [
            .text('Every mode and every event, explained →'),
          ]),
        ]),
        div(classes: 'af-section-demo', [
          ExampleFrame(example: example, layout: ExampleLayout.split),
        ]),
      ],
    );
  }
}

/// "Server-side checks": one AsyncValidation and what comes with it.
class AsyncSection extends StatelessComponent {
  const AsyncSection({required this.example, super.key});

  final LandingExample example;

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'async',
      eyebrow: 'Server-side checks',
      heading: const [.text('Async validation without the races.')],
      lead: rich(
        '“Is this username taken?” is one `AsyncValidation`. Debounce, '
        'cancellation, timeout and failure handling come with it — try '
        '`alice`, then `boom`.',
      ),
      children: [
        ExampleFrame(example: example, layout: ExampleLayout.split),
        ul(classes: 'af-checklist', [
          li([
            const strong([
              .text('Debounced while typing, immediate on submit.'),
            ]),
            ...rich(
              ' `await validate()` flushes a waiting check rather than '
              'reporting the field bad for being busy.',
            ),
          ]),
          const li([
            strong([.text('A stale answer can never land.')]),
            .text(
              ' A new value replaces the round in flight; the old result is '
              'dropped, not applied late.',
            ),
          ]),
          const li([
            strong([.text('Verdicts are reused.')]),
            .text(
              ' A second submit on an unchanged form makes zero network calls.',
            ),
          ]),
          li([
            const strong([.text('A failure is not an error.')]),
            ...rich(
              ' A validator that throws or times out puts the field on '
              '`failedValidation`: not valid, not stuck, retried by the next '
              'submit.',
            ),
          ]),
        ]),
        const p(classes: 'af-section-more', [
          a(href: '$docsPath/validation/async', [
            .text('How rounds, verdicts and failures fit together →'),
          ]),
        ]),
      ],
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.body);

  final Icon icon;
  final String title;
  final String body;
}

const _features = [
  _Feature(
    Icon.braces,
    'Typed field controllers',
    'Text, boolean, single-select and multi-select fields, each with its own '
        'value type and its own error type. Plain strings to start, an enum or '
        'a sealed class when the form grows.',
  ),
  _Feature(
    Icon.combine,
    'Validators that compose',
    '`filled`, `atLeastLength`, `notNull`, `mustBeTrue` and the numeric checks, '
        'combined with `&` and `|` — or any `E? Function(T)` you write yourself.',
  ),
  _Feature(
    Icon.server,
    'Async validation done right',
    'Debounced server checks with a timeout, cancellation of stale rounds, a '
        'cached verdict while the value stands, and a failure model that never '
        'leaves a field stuck on “validating”.',
  ),
  _Feature(
    Icon.mousePointerClick,
    'Three validation modes',
    'Validate on submit, on every keystroke, or when a field loses focus. Set '
        'once on the form; a field or a subform can opt out with its own mode.',
  ),
  _Feature(
    Icon.gitFork,
    'Cross-field logic',
    '`subscribeToFields` re-runs a rule when its dependencies change; '
        '`addRelation` derives one field’s value from another. Repeat-password '
        'and running totals in two lines each.',
  ),
  _Feature(
    Icon.layers,
    'Subforms',
    'Attach and detach nested controllers. Their fields join the parent’s '
        '`validate`, reset, read-only and error handling — one subform per '
        'wizard step, or one per row of a dynamic list.',
  ),
  _Feature(
    Icon.listChecks,
    'Form-level state',
    '`canSubmit`, `wasModified`, `validating` and `validationErrors`, derived '
        'from the live tree on every read and ready to bind to a submit button.',
  ),
  _Feature(
    Icon.lock,
    'Read-only fields and server errors',
    'Freeze a value with `markReadOnly`, push a 422 response in with '
        '`setError`, and let the next edit clear it — no bookkeeping.',
  ),
  _Feature(
    Icon.gauge,
    'Granular rebuilds',
    'One builder per field. A keystroke rebuilds that field’s subtree and '
        'nothing else, and a no-op write notifies nobody because state is '
        'value-equal.',
  ),
];

class Features extends StatelessComponent {
  const Features({super.key});

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'features',
      eyebrow: 'Everything a form needs',
      heading: const [.text('Small enough to read. Complete enough to ship.')],
      lead: const [
        .text(
          'About two thousand lines of Dart, three runtime dependencies, and '
          'no build step. Every behaviour below is pinned by the package’s '
          'test suite and shown running in the docs.',
        ),
      ],
      children: [
        ul(classes: 'af-feature-grid', [
          for (final feature in _features)
            li(classes: 'af-card af-feature', [
              span(classes: 'af-feature-icon', [feature.icon.build(size: 22)]),
              h3([.text(feature.title)]),
              p(rich(feature.body)),
            ]),
        ]),
      ],
    );
  }
}

/// The Agent Skill band.
class SkillBand extends StatelessComponent {
  const SkillBand({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'af-section',
      attributes: const {'aria-labelledby': 'skill-heading'},
      [
        div(classes: 'af-container', [
          div(classes: 'af-band', [
            div([
              const p(classes: 'af-eyebrow', [.text('Agent skill')]),
              const h2(id: 'skill-heading', [
                .text('Your coding agent already knows this API.'),
              ]),
              p(
                classes: 'af-lead',
                rich(
                  'The repository ships an Agent Skill that teaches Claude '
                  'Code — or any agent that supports skills — the full '
                  '`advanced_forms` API, so it generates fields, validation, '
                  'cross-field logic and subforms idiomatically.',
                ),
              ),
            ]),
            const div(classes: 'af-hero-actions', [
              Button(
                'Install the skill',
                href: '$docsPath/agent-skill',
                leading: .bot,
              ),
              Button(
                'Read SKILL.md',
                href: skillUrl,
                variant: .secondary,
                external: true,
                trailing: .arrowRight,
              ),
            ]),
          ]),
        ]),
      ],
    );
  }
}
