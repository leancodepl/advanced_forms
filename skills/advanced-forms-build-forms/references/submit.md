# Submit

## Button

```dart
ValueListenableBuilder<AdvancedFormState>(
  valueListenable: form,
  builder: (context, state, _) {
    return ElevatedButton(
      onPressed: state.validating
          ? null
          : () async {
              final ok = await form.submit();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Saved' : 'Fix the errors above')),
                );
              }
            },
      child: state.validating
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(),
            )
          : const Text('Submit'),
    );
  },
)
```

To grey out known errors and still leave retry enabled: `state.canSubmit || state.hasFailedValidation`. The next edit clears `hasFailedValidation`, and that gate can grey again. Add `wasModified` only when the task asks for disabled until modified.

## Your request

Keep the save-request flag in a `ValueNotifier<bool>` on the controller. Set it before `await validate()`, the first await in submit, or a double tap sends two requests.

Subclassing the form for that flag is fine. `notifyListeners()` is callable and `dispose()` is overridable — dispose your own objects first, then `super.dispose()`.

## Form state

The form is a `ValueListenable<AdvancedFormState>`.

| Member | Meaning |
| --- | --- |
| `wasModified` | any field differs from its value at `registerFields`, or a subform was modified |
| `canSubmit` | every counted field is `valid` right now |
| `validating` | an async round is pending or in flight somewhere in the tree |
| `hasFailedValidation` | some async check threw or timed out |
| `validationErrors` | `Map<AdvancedFieldController<dynamic, dynamic>, dynamic>` — current errors keyed by field; cast values to `E` |
| `validationEnabled` | false → this subtree validates nothing and leaves `canSubmit`, `validating`, `hasFailedValidation`, and `validationErrors`. `wasModified` still counts it |
| `validationMode` | this form's configured mode, independent of `validationEnabled` |
| `fields` / `subforms` / `allFields` | own fields / attached subforms / both, as `Iterable<AdvancedFieldController<dynamic, dynamic>>`: own fields in `registerFields` order, then each subform's, recursively |

`allFields` does not filter. Prefer the aggregates. When you walk `allFields`, skip switched-off subtrees yourself.

The form notifies for its whole tree. A parent hears every attached subform, so one `ValueListenableBuilder` on the root covers a submit button over a wizard. With provider: `context.select<SignupFormController, bool>((c) => c.value.validating)`. Outside widgets, `form.onValuesChanged` and `form.onStatusChanged` are tree-wide `Listenable`s.

## Summary and first invalid field

`name` is a machine key. Keep a label map when the summary is user-facing.

```dart
for (final entry in form.value.validationErrors.entries)
  Text('${labels[entry.key] ?? entry.key.name}: ${translate(entry.value as MyError)}'),
```

```dart
Future<void> submitAndFocus() async {
  if (await validate()) {
    return;
  }
  for (final field in value.allFields) {
    // !isValid, not isInvalid: failedValidation deserves focus too.
    if (!field.value.isValid) {
      field.focus();
      return;
    }
  }
}
```

`focus()` on a disposed controller is a no-op. Reading `focusNode` on one throws `StateError`. A widget that can outlive the form stays off `focusNode`.
