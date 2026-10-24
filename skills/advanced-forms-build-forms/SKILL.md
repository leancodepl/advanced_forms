---
name: advanced-forms-build-forms
description: Build Flutter forms on advanced_forms. Use when building or changing a form; when wiring validation, cross-field rules, server field errors, or an edit-form prefill; when a section or wizard step joins the form; when UI collects structured input without being called a form; or when the Flutter project does not depend on advanced_forms yet.
---

# advanced_forms

Typed form controllers. One import: `package:advanced_forms/advanced_forms.dart`. Flutter >= 3.19.0 (Dart 3.3). Controllers are `ChangeNotifier` and `ValueListenable` from the SDK.

A **form** (`AdvancedFormController`) owns **fields** (`AdvancedFieldController<T, E>`). `T` is the value. `E extends Object` is your error — `null` means no error. Each widget subscribes to one field through `AdvancedFieldBuilder`. Reference files use `MyError`, `form`, and `translate` (`String Function(MyError)`).

Porting `leancode_forms` or advanced_forms 0.1.x is a rewrite onto this shape: `AdvancedFormController` replaces `FormGroupCubit`, and `Advanced*Controller` replaces the `*Cubit`s. Follow `MIGRATION.md` in the package root, and `CHANGELOG.md` for version history.

## 1. Depend

`advanced_forms` is under `dependencies`. When it is missing, add it from the project root:

```sh
flutter pub add advanced_forms
```

**Done when** `package:advanced_forms/advanced_forms.dart` resolves.

## 2. Own the fields

Subclass `AdvancedFormController`. Call `registerFields` once, in the constructor, with every field. The parameter is `List<AdvancedFieldController<dynamic, dynamic>>` — let the literal infer. The form then owns disposal, `validate()`, `resetAll()`, and the `wasModified` baseline — each field's value at this call.

A later `registerFields` replaces the list. Dropped fields stop participating and are still disposed with the form. Re-registering the **same** list sets a new baseline — [server errors and prefilling](references/server.md). A field left out of `registerFields` is never disposed.

Spell `E`. With no `validator` it infers to `Object`, and every `switch` on your error enum breaks: `AdvancedTextFieldController<MyError>()`.

| Controller | `T` | Write |
| --- | --- | --- |
| `AdvancedTextFieldController<E>` | `String` | `textController` |
| `AdvancedBooleanFieldController<E>` | `bool` | `getValueSetter()` |
| `AdvancedSingleSelectFieldController<V, E>` | `V?` | `select(V?)` |
| `AdvancedMultiSelectFieldController<V, E>` | `Set<V>` | `toggleElement` / `addValue` / `removeValue` |
| `AdvancedFieldController<T, E>` | any | `setValue` — slider, stepper, rating, derived total |

Dispose only the form. It disposes every field from `registerFields` and every subform ever passed to `addSubform`, attached or not. `ChangeNotifierProvider(create: (_) => MyForm())` disposes it; a `StatefulWidget` disposes it in `State.dispose`. `context.read` for actions. `AdvancedFieldBuilder`, `ValueListenableBuilder`, or `context.select` for rebuilds.

`registerFields`, `addSubform`, `removeSubform`, `setValidationEnabled`, `subscribeToFields`, and `setValue` throw `StateError` on a disposed controller. `validate()` returns `false`.

**Done when** every field is in that one `registerFields` call and each `E` is your error type.

Select options, field state, or a text transform: [fields](references/fields.md).

## 3. Bind

One `AdvancedFieldBuilder<T, E>` per field. Type arguments match the controller: `String`, `bool`, `V?`, `Set<V>`. Its third builder argument is a `child` that does not depend on field state.

Text inputs take `controller: field.textController` and `focusNode: field.focusNode`. The field owns both and keeps the text in two-way sync. Pass `readOnly: state.readOnly`. Map `state.error` through `translate` after promoting `E?` to `E`.

Validate through these controllers. Flutter's `Form`, `GlobalKey<FormState>`, and `autovalidateMode` are a second system. A `TextFormField` with no `Form` ancestor is a `TextField` plus a decoration.

**Done when** each field rebuilds from its own builder and every text input uses `field.textController`.

Dropdown, checkbox, multi-select, slider, or focus: [binding](references/binding.md).

## 4. Validate, then submit

`ValidationMode` on the form decides which events validate a field. It reaches every field and subform, including ones added later. The mode stays what you set — the first submit does not turn on live validation.

An **untouched** field validates nothing on its own, in every mode. Only `setValue` marks a field edited. A **program write** (`prefill`, or `setOptions` dropping a selection that is no longer listed) stores the value and leaves the field untouched. `reset()` makes it untouched again.

A round runs the sync validator first, then the async validator only if sync passed.

| `ValidationMode` | on edit | on unfocus | when a dependency changes |
| --- | --- | --- | --- |
| `manual` (default) | — | — | — |
| `onUserInteraction` | validate (async debounced) | — | sync only |
| `onUnfocus` | — | validate | sync only |
| `afterFirstUnfocus` | — until the field was first left after an edit, validate after | validate, the first time | sync only |
| `ValidationMode.custom(name, fn)` | whatever `fn` says, given the event and whether the field was ever left; never for an untouched field | | |

A rule none of the four modes states is a custom mode: [validation](references/validation.md#a-mode-of-your-own). Reach for the built-in modes first.

`await form.validate()` checks every field and subform, untouched included, and returns `false` when anything is invalid. It neither reads nor changes the mode. `state.isValid` and `form.value.canSubmit` mean no error is recorded, including on a field nobody has checked. Read values only after `validate()` returns `true` — that is what licenses a `!` on a nullable value. A second call re-runs the sync validators and awaits async checks already in flight.

`submit()` is your method: `validate()`, then send. `onPressed` is a block body that awaits it. A tear-off (`onPressed: form.submit`) or an arrow (`() async => form.submit()`) drops the future, so the result is lost and a throw becomes an unhandled error.

Gate the button on `state.validating`, which is true while an async validator round is in flight. `canSubmit` is false in that window and while any field is in `failedValidation`, which also disables the retry. A save request is your own flag, set before `await validate()` — `validating` covers validators only.

**Done when** submit awaits `validate()` and field values are read only after `true`.

A built-in validator, a combined validator, or an async check: [validation](references/validation.md).
A rule or a value that follows another field: [cross-field](references/cross-field.md).
Failure and retry on the button, an error summary, or focus on the first invalid field: [submit](references/submit.md).

## 5. Open the branch this screen needs

- Server errors, read-only, reset, or prefilling an edit form: [server](references/server.md).
- A section, a switch, or a wizard step: [subforms](references/subforms.md).

**Done when** server errors, prefill, read-only, and subform behavior match that file, or the screen has none of them.

## Shape

Steps 2–4, in code.

```dart
import 'package:advanced_forms/advanced_forms.dart';

enum SignupError { required, tooShort }

String translate(SignupError error) => switch (error) {
  SignupError.required => 'Required',
  SignupError.tooShort => 'Too short',
};

class SignupFormController extends AdvancedFormController {
  SignupFormController() {
    registerFields([email, password]);
  }

  final email = AdvancedTextFieldController(
    validator: filled(SignupError.required),
  );

  final password = AdvancedTextFieldController(
    validator: filled(SignupError.required) &
        atLeastLength(8, SignupError.tooShort),
  );

  Future<bool> submit() async {
    if (!await validate()) {
      return false;
    }
    // email.fieldValue, password.fieldValue
    return true;
  }
}
```

```dart
final form = context.read<SignupFormController>();
return Column(
  children: [
    _SignupField(field: form.email, label: 'Email'),
    _SignupField(field: form.password, label: 'Password'),
    ValueListenableBuilder<AdvancedFormState>(
      valueListenable: form,
      builder: (context, state, _) => ElevatedButton(
        onPressed: state.validating
            ? null
            : () async {
                await form.submit();
              },
        child: const Text('Sign up'),
      ),
    ),
  ],
);
```

```dart
class _SignupField extends StatelessWidget {
  const _SignupField({required this.field, required this.label});

  final AdvancedTextFieldController<SignupError> field;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<String, SignupError>(
      field: field,
      builder: (context, state, _) => TextFormField(
        controller: field.textController,
        focusNode: field.focusNode,
        readOnly: state.readOnly,
        decoration: InputDecoration(
          labelText: label,
          errorText: state.error == null ? null : translate(state.error!),
        ),
      ),
    );
  }
}
```
