import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/card.dart';
import 'package:advanced_forms_landing/components/example_frame.dart';
import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/pill.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/components/text.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
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
        Checklist([
          [
            strong(rich('One call to `registerFields`')),
            ...rich(
              ' and the form owns the fields: it disposes them, tracks '
              '`wasModified`, and reaches them in `validate`, `resetAll` and '
              'every other broadcast.',
            ),
          ],
          [
            strong(
              rich(
                'The field owns its `TextEditingController` and `FocusNode`.',
              ),
            ),
            ...rich(
              ' Bind the widget to `field.textController` and programmatic '
              'writes — `reset`, `prefill`, a relation — show up on screen.',
            ),
          ],
          [
            const strong([.text('Errors are your type.')]),
            ...rich(
              ' `E` is whatever you choose: a string, an enum, a sealed class. '
              'The package never formats a message.',
            ),
          ],
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

  static const _rulesList = ClassName('af-rules', owner: ValidationSection);
  static const _rule = ClassName('af-rule', owner: ValidationSection);
  static const _modesGrid = ClassName('af-modes', owner: ValidationSection);
  static const _mode = ClassName('af-mode', owner: ValidationSection);
  static const _modeHead = ClassName('af-mode-head', owner: ValidationSection);
  static const _modeWhen = ClassName('af-mode-when', owner: ValidationSection);

  /// The numbered rules, and what the mode cards add to a [Card].
  @css
  static List<StyleRule> get styles => [
    css(
      _rulesList.selector,
    ).styles(display: .grid, gap: .all(1.rem), raw: {'counter-reset': 'rule'}),
    css(_rule.selector).styles(
      position: const .relative(),
      padding: .only(left: 3.25.rem),
    ),
    css('${_rule.selector}::before').styles(
      position: .absolute(top: 0.15.rem, left: .zero),
      color: accentTextColor,
      fontFamily: fontMono,
      fontSize: 0.85.rem,
      fontWeight: .w600,
      raw: {
        'counter-increment': 'rule',
        'content': 'counter(rule, decimal-leading-zero)',
      },
    ),
    css('${_rule.selector} h3').styles(
      margin: .only(bottom: 0.35.rem),
      fontSize: 1.1.rem,
    ),
    css('${_rule.selector} p').styles(color: text2Color, fontSize: 0.98.rem),
    css(_modesGrid.selector).styles(margin: .only(top: 2.5.rem)),
    css(_mode.selector).styles(gap: .all(0.35.rem)),
    css(_modeHead.selector).styles(
      display: .flex,
      justifyContent: .spaceBetween,
      gap: .all(0.75.rem),
      raw: {'align-items': 'flex-start'},
    ),
    css('${_mode.selector} h3').styles(
      margin: .only(top: 0.25.rem, right: .zero, bottom: .zero, left: .zero),
    ),
    css(
      '${_mode.selector} h3 code',
    ).styles(fontSize: 0.95.rem, fontWeight: .w600),
    css(_modeWhen.selector).styles(
      fontWeight: .w600,
      raw: {'color': '${textColor.value} !important'},
    ),
    css.media(MediaQuery.all(minWidth: 960.px), [
      css(_rulesList.selector).styles(
        gap: .all(2.rem),
        raw: {'grid-template-columns': 'repeat(3, 1fr)'},
      ),
    ]),
  ];

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
        ol(classes: _rulesList.name, [
          for (final rule in _rules)
            li(classes: _rule.name, [
              h3([.text(rule.title)]),
              p(rich(rule.body)),
            ]),
        ]),
        CardGrid(className: _modesGrid, [
          for (final mode in _modes)
            Card(className: _mode, [
              div(classes: _modeHead.name, [
                CardIcon(mode.icon),
                Pill(mode.tag, accent: true),
              ]),
              h3([
                code([.text(mode.name)]),
              ]),
              p(classes: _modeWhen.name, [.text(mode.when)]),
              p([.text(mode.body)]),
            ]),
        ]),
        const MoreLink(
          'Every mode and every event, explained →',
          href: '$docsPath/validation/modes',
        ),
        DemoSlot(ExampleFrame(example: example, layout: ExampleLayout.split)),
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
        Checklist([
          [
            const strong([
              .text('Debounced while typing, immediate on submit.'),
            ]),
            ...rich(
              ' `await validate()` flushes a waiting check rather than '
              'reporting the field bad for being busy.',
            ),
          ],
          const [
            strong([.text('A stale answer can never land.')]),
            .text(
              ' A new value replaces the round in flight; the old result is '
              'dropped, not applied late.',
            ),
          ],
          const [
            strong([.text('Verdicts are reused.')]),
            .text(
              ' A second submit on an unchanged form makes zero network calls.',
            ),
          ],
          [
            const strong([.text('A failure is not an error.')]),
            ...rich(
              ' A validator that throws or times out puts the field on '
              '`failedValidation`: not valid, not stuck, retried by the next '
              'submit.',
            ),
          ],
        ]),
        const MoreLink(
          'How rounds, verdicts and failures fit together →',
          href: '$docsPath/validation/async',
        ),
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

/// "Everything a form needs": the feature cards.
class Features extends StatelessComponent {
  const Features({super.key});

  static const _feature = ClassName('af-feature', owner: Features);

  /// What a feature card adds to a [Card].
  @css
  static List<StyleRule> get styles => [
    css(_feature.selector).styles(gap: .all(0.6.rem)),
    css('${_feature.selector} p').styles(raw: {'flex': '1'}),
  ];

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
        CardGrid([
          for (final feature in _features)
            Card(className: _feature, [
              CardIcon(feature.icon),
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

  static const _band = ClassName('af-band', owner: SkillBand);

  @css
  static List<StyleRule> get styles => [
    css(_band.selector).styles(
      display: .grid,
      padding: .all(2.rem),
      border: hairline(borderColor),
      radius: const .circular(radius),
      alignItems: .center,
      gap: .all(2.rem),
      raw: {
        'background':
            'radial-gradient(60% 80% at 100% 0%, var(--af-accent-soft), '
            'transparent 70%), var(--af-surface)',
      },
    ),
    css('${_band.selector} > *').styles(minWidth: .zero),
    css(
      '${_band.selector} h2',
    ).styles(fontSize: const .expression('clamp(1.5rem, 2.6vw, 2rem)')),
    css.media(MediaQuery.all(minWidth: 760.px), [
      css(_band.selector).styles(
        padding: .all(2.5.rem),
        raw: {'grid-template-columns': '1.3fr 1fr'},
      ),
    ]),
  ];

  @override
  Component build(BuildContext context) {
    return Section.plain(
      labelledBy: 'skill-heading',
      children: [
        div(classes: _band.name, [
          div([
            const Eyebrow('Agent skill'),
            const h2(id: 'skill-heading', [
              .text('Your coding agent already knows this API.'),
            ]),
            Lead(
              rich(
                'The repository ships an Agent Skill that teaches Claude '
                'Code — or any agent that supports skills — the full '
                '`advanced_forms` API, so it generates fields, validation, '
                'cross-field logic and subforms idiomatically.',
              ),
            ),
          ]),
          const ButtonRow(flush: true, [
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
      ],
    );
  }
}
