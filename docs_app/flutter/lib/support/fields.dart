/*
 * AI-Provenance:
 *   model: Claude Opus 5
 *   harness: Cursor
 *   edited-by: Claude Fable 5.1 (Claude Code)
 */
import 'package:advanced_forms/advanced_forms.dart';
import 'package:flutter/material.dart';

/// Compact field widgets for docs examples whose lesson is not widget wiring.
///
/// An example about validation should not have to re-teach
/// [AdvancedFieldBuilder] before it gets to the point. Examples that *are*
/// about binding widgets to fields should define their own field widget in the
/// snippet instead — that is what a reader has to write, so that is what the
/// page should show.
///
/// Every widget here follows the same two rules the docs teach: it binds to the
/// controller the field owns, and it nulls its callback while the field is
/// read-only.
class DocsTextField<E extends Object> extends StatelessWidget {
  const DocsTextField({
    super.key,
    required this.field,
    required this.label,
    this.hint,
    this.helper,
    this.translateError,
    this.obscureText = false,
    this.keyboardType,
    this.icon,
    this.onSubmitted,
  });

  final AdvancedTextFieldController<E> field;
  final String label;
  final String? hint;

  /// Shown under the field while there is no error.
  final String? helper;

  /// Maps the field's error to a message. Defaults to `toString()`, which is
  /// right for the common case of `AdvancedTextFieldController<String>`.
  final ErrorTranslator<E>? translateError;

  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? icon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<String, E>(
      field: field,
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: field.textController,
            focusNode: field.focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: state.readOnly,
            enabled: !state.readOnly,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              helperText: helper,
              prefixIcon: icon == null ? null : Icon(icon, size: 20),
              errorText: describeError(state.error, translateError),
              suffixIcon: switch (state) {
                AdvancedFieldState(isInProgress: true) => const _Spinner(),
                AdvancedFieldState(readOnly: true) => const Icon(
                  Icons.lock_outline,
                  size: 18,
                ),
                AdvancedFieldState(isFailedValidation: true) => const Icon(
                  Icons.cloud_off_outlined,
                  size: 18,
                ),
                _ => null,
              },
            ),
          ),
        );
      },
    );
  }
}

/// A switch bound to an [AdvancedBooleanFieldController].
class DocsSwitchField<E extends Object> extends StatelessWidget {
  const DocsSwitchField({
    super.key,
    required this.field,
    required this.label,
    this.subtitle,
    this.translateError,
  });

  final AdvancedBooleanFieldController<E> field;
  final String label;
  final String? subtitle;
  final ErrorTranslator<E>? translateError;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<bool, E>(
      field: field,
      builder: (context, state, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: state.value,
              // Null while read-only, so the switch greys itself out.
              onChanged: field.getValueSetter(),
              title: Text(label),
              subtitle: subtitle == null ? null : Text(subtitle!),
              dense: true,
            ),
            _ErrorText(describeError(state.error, translateError)),
          ],
        );
      },
    );
  }
}

/// A checkbox bound to an [AdvancedBooleanFieldController].
class DocsCheckboxField<E extends Object> extends StatelessWidget {
  const DocsCheckboxField({
    super.key,
    required this.field,
    required this.label,
    this.translateError,
  });

  final AdvancedBooleanFieldController<E> field;
  final String label;
  final ErrorTranslator<E>? translateError;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<bool, E>(
      field: field,
      builder: (context, state, _) {
        // CheckboxListTile.onChanged is ValueChanged<bool?>?, so the setter
        // has to be adapted; null while read-only disables the tile.
        final setter = field.getValueSetter();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: state.value,
              onChanged: setter == null ? null : (v) => setter(v ?? false),
              title: Text(label),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            _ErrorText(describeError(state.error, translateError)),
          ],
        );
      },
    );
  }
}

/// A dropdown bound to an [AdvancedSingleSelectFieldController].
class DocsDropdownField<V, E extends Object> extends StatelessWidget {
  const DocsDropdownField({
    super.key,
    required this.field,
    required this.label,
    this.hint,
    this.optionLabel,
    this.translateError,
  });

  final AdvancedSingleSelectFieldController<V, E> field;
  final String label;
  final String? hint;
  final String Function(V option)? optionLabel;
  final ErrorTranslator<E>? translateError;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<V?, E>(
      field: field,
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          // InputDecorator + DropdownButton always shows the field's current
          // value, including after `reset()`, which a form-field dropdown
          // seeded with an initial value would not.
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: describeError(state.error, translateError),
              contentPadding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
            ),
            isEmpty: state.value == null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<V>(
                value: state.value,
                isExpanded: true,
                isDense: true,
                focusNode: field.focusNode,
                hint: hint == null ? null : Text(hint!),
                items: [
                  for (final option in field.options)
                    DropdownMenuItem(
                      value: option,
                      child: Text(optionLabel?.call(option) ?? '$option'),
                    ),
                ],
                onChanged: state.readOnly ? null : field.select,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Multi-select chips bound to an [AdvancedMultiSelectFieldController].
class DocsChipsField<V, E extends Object> extends StatelessWidget {
  const DocsChipsField({
    super.key,
    required this.field,
    required this.label,
    this.optionLabel,
    this.translateError,
  });

  final AdvancedMultiSelectFieldController<V, E> field;
  final String label;
  final String Function(V option)? optionLabel;
  final ErrorTranslator<E>? translateError;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<Set<V>, E>(
      field: field,
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: describeError(state.error, translateError),
              contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final option in field.options)
                  FilterChip(
                    label: Text(optionLabel?.call(option) ?? '$option'),
                    selected: state.value.contains(option),
                    onSelected: state.readOnly
                        ? null
                        : (_) => field.toggleElement(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A submit button bound to a form: it runs [onPressed] once at a time and
/// shows a spinner while it, or any async validator in the tree, is busy.
class DocsSubmitButton extends StatefulWidget {
  const DocsSubmitButton({
    super.key,
    required this.form,
    required this.onPressed,
    this.label = 'Submit',
    this.icon,
    this.enabled = true,
  });

  final AdvancedFormController form;
  final Future<void> Function() onPressed;
  final String label;
  final IconData? icon;

  /// An extra condition of the caller's, e.g. `form.value.wasModified`.
  final bool enabled;

  @override
  State<DocsSubmitButton> createState() => _DocsSubmitButtonState();
}

class _DocsSubmitButtonState extends State<DocsSubmitButton> {
  var _running = false;

  Future<void> _run() async {
    setState(() => _running = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AdvancedFormState>(
      valueListenable: widget.form,
      builder: (context, state, _) {
        final busy = _running || state.validating;

        return FilledButton.icon(
          onPressed: widget.enabled && !busy ? _run : null,
          icon: busy
              ? const _Spinner(padding: EdgeInsets.zero)
              : Icon(widget.icon ?? Icons.arrow_forward, size: 18),
          label: Text(widget.label),
        );
      },
    );
  }
}

/// A live read-out of one field's [FieldStatus], for pages that teach what
/// the statuses mean.
class DocsFieldStatus<T, E extends Object> extends StatelessWidget {
  const DocsFieldStatus({super.key, required this.field, this.label});

  final AdvancedFieldController<T, E> field;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<T, E>(
      field: field,
      builder: (context, state, _) {
        final scheme = Theme.of(context).colorScheme;
        final color = switch (state.status) {
          FieldStatus.valid => scheme.tertiary,
          FieldStatus.invalid || FieldStatus.failedValidation => scheme.error,
          FieldStatus.pending || FieldStatus.validating => scheme.secondary,
        };

        return DocsPill(
          label: label == null
              ? state.status.name
              : '$label · ${state.status.name}',
          color: color,
        );
      },
    );
  }
}

/// The four derived members of [AdvancedFormState], live.
class DocsFormStatus extends StatelessWidget {
  const DocsFormStatus({super.key, required this.form});

  final AdvancedFormController form;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AdvancedFormState>(
      valueListenable: form,
      builder: (context, state, _) {
        final scheme = Theme.of(context).colorScheme;

        Widget flag({
          required String name,
          required bool value,
          bool badWhenTrue = false,
        }) {
          final color = !value
              ? scheme.onSurfaceVariant
              : badWhenTrue
              ? scheme.error
              : scheme.tertiary;
          return DocsPill(label: '$name: $value', color: color);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              flag(name: 'canSubmit', value: state.canSubmit),
              flag(name: 'wasModified', value: state.wasModified),
              flag(name: 'validating', value: state.validating),
              flag(
                name: 'hasFailedValidation',
                value: state.hasFailedValidation,
                badWhenTrue: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One banner for the whole form, shown while any async check could not run.
class DocsFailureBanner extends StatelessWidget {
  const DocsFailureBanner({
    super.key,
    required this.form,
    this.message = 'Some checks could not be completed. Submit to try again.',
  });

  final AdvancedFormController form;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AdvancedFormState>(
      valueListenable: form,
      builder: (context, state, _) {
        if (!state.hasFailedValidation) {
          return const SizedBox.shrink();
        }
        return DocsBanner(message: message, kind: DocsBannerKind.error);
      },
    );
  }
}

enum DocsBannerKind { info, success, error }

/// A short message with a coloured edge — for the reader, not the user.
class DocsBanner extends StatelessWidget {
  const DocsBanner({
    super.key,
    required this.message,
    this.kind = DocsBannerKind.info,
  });

  final String message;
  final DocsBannerKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (kind) {
      DocsBannerKind.info => scheme.secondary,
      DocsBannerKind.success => scheme.tertiary,
      DocsBannerKind.error => scheme.error,
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}

/// A one-line hint for the reader, e.g. which values trigger which outcome.
class DocsHint extends StatelessWidget {
  const DocsHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small coloured label.
class DocsPill extends StatelessWidget {
  const DocsPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Lays out a form's buttons in a row that wraps on narrow islands.
class DocsActions extends StatelessWidget {
  const DocsActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}

/// Maps an error to the text a widget shows, or null for no error.
String? describeError<E extends Object>(
  E? error,
  ErrorTranslator<E>? translateError,
) {
  if (error == null) {
    return null;
  }
  return translateError?.call(error) ?? error.toString();
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String? text;

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    if (text == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({this.padding = const EdgeInsets.all(12)});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
