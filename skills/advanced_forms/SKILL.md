---
name: advanced_forms
description: Build Flutter forms with the advanced_forms package (AdvancedFormController, AdvancedTextFieldController, AdvancedFieldBuilder). Use whenever the user creates a form, adds or edits form fields, wires validation (sync, async, or cross-field), chooses when errors appear (ValidationMode), builds dropdowns/checkboxes/multi-selects/sliders bound to field controllers, handles submit buttons or server-side errors, or works with subforms in a project that depends on advanced_forms — even if they never say the word "form".
---

# advanced_forms

Typed form controllers for Flutter, no framework on top. Everything is `ChangeNotifier` +
`ValueListenable` from the SDK. One import: `package:advanced_forms/advanced_forms.dart`.
Requires Flutter >= 3.19.0 (Dart 3.3).

A **form controller** (`AdvancedFormController`) owns **field controllers**
(`AdvancedFieldController<T, E>`). `T` is the value type, `E` is *your* error type
(`E extends Object`, never nullable — `null` means "no error"). Plain `String` errors are
fine; an enum or sealed class scales better. Widgets subscribe to one field each via
`AdvancedFieldBuilder`; the form aggregates tree-wide state.

Snippets assume in scope: `MyError`, your error enum; `form`, a form controller; `translate`,
an `ErrorTranslator<MyError>`.

## Quick start

```dart
import 'package:advanced_forms/advanced_forms.dart';

enum SignupError { required, tooShort }

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
    // values were checked — safe to send: email.fieldValue, password.fieldValue
    return true;
  }
}
```

```dart
// Inside SignupScreen.build:
final form = context.read<SignupFormController>();
return Column(
  children: [
    _SignupField(field: form.email, label: 'Email'),
    _SignupField(field: form.password, label: 'Password'),
    ElevatedButton(
      // A block body that awaits. `onPressed: form.submit` compiles but drops the
      // future, losing the result and turning any throw into an unhandled error.
      onPressed: () async {
        await form.submit();
      },
      child: const Text('Sign up'),
    ),
  ],
);
```

```dart
// One reusable field widget, at top level.
class _SignupField extends StatelessWidget {
  const _SignupField({required this.field, required this.label});

  final AdvancedTextFieldController<SignupError> field;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AdvancedFieldBuilder<String, SignupError>(
      field: field,
      builder: (context, state, _) => TextFormField(
        controller: field.textController, // NEVER your own TextEditingController
        focusNode: field.focusNode,
        readOnly: state.readOnly, // add enabled: !state.readOnly to also look disabled
        decoration: InputDecoration(
          labelText: label,
          errorText: state.error == null ? null : translate(state.error!),
        ),
      ),
    );
  }
}
```

Default UX: **nothing validates until `submit`.** Errors appear on the first `validate()`,
and editing a field clears its error — but the error only returns on the next `validate()`.
For live feedback, set a `ValidationMode`; see *Validation*.

Two rules prevent most bugs:

- **Call `registerFields()` once, in the constructor, with every field.** The parameter is
  `List<AdvancedFieldController<dynamic, dynamic>>`, so mixed value types go in one list —
  let the literal infer its type rather than annotating it. The
  form then owns their lifecycle — disposal, `wasModified` tracking, `validate()`,
  `resetAll()`. A second call *replaces* the list: earlier fields stop participating but are
  still disposed with the form. (Deliberately re-registering the *same* list to re-baseline an
  edit form is the one exception — see *Prefilling an edit form*.) A field never registered at
  all belongs to nobody and is never disposed.
- **Bind text widgets to `field.textController`.** The field owns a `TextEditingController`
  and keeps it in two-way sync, so do not allocate your own and do not wire `onChanged` +
  `initialValue` for text fields.

## Field controllers

| Controller | Value type | Constructor |
| --- | --- | --- |
| `AdvancedTextFieldController<E>` | `String` | `{initialValue = '', validator, asyncValidation, focusNode, name}`; owns `textController` |
| `AdvancedBooleanFieldController<E>` | `bool` | `{initialValue = false, validator, asyncValidation, focusNode, name}` |
| `AdvancedSingleSelectFieldController<V, E>` | `V?` | `{required V? initialValue, required List<V> options, validator, asyncValidation, focusNode, name}`; set with `select(V?)`, `null` clears |
| `AdvancedMultiSelectFieldController<V, E>` | `Set<V>` | `{required Set<V> initialValue, required List<V> options, validator, asyncValidation, focusNode, name}`; set with `toggleElement` / `addValue` / `removeValue` |

All support `reset()`, `prefill()`, `markReadOnly()` / `unmarkReadOnly()`, `setError()`,
`clearErrors()`, `setValidationMode()`, `validate()`, `subscribeToFields()`,
`revalidateSync()`, `focus()`, `handleUnfocus()`, `getValueSetter()` (a `ValueSetter<T>?`,
`null` while read-only, so a widget with a nullable `onChanged` disables itself), and the
getters `fieldValue`, `error`, `name`, `lastFailure`, `isDisposed`.

- **`focusNode` is on every controller**, not just the text one — the field makes and owns it;
  pass `focusNode:` to bind one you own and the field never disposes it. `focus()` only moves
  focus if **some widget actually binds `field.focusNode`**: a `TextField`, or a `Focus` /
  `FocusableActionDetector` around a slider, chip group or dropdown. A field nobody bound is a
  silent no-op — that is why "focus the first invalid field" seems to do nothing on non-text
  fields.
- `name` is a readable `String?`. It labels the field in package error reports and as the
  `FocusNode` debug label, and is the natural key for error summaries and server-error maps.
- `V` is unbounded on both selects. `options` is a **non-nullable** `List<V>`; only
  `initialValue` is nullable, on the single select. A required dropdown is
  `initialValue: null` plus `validator: notNull(MyError.required)`.
- `select` and `addValue` **assert** the argument is one of `options` — and so does
  `toggleElement` when it adds. `prefill` does not assert, so check server-supplied values.
- The multi-select copies the set and list you pass, so mutating them later never reaches the
  field. `const {}` is a **Map**: an empty initial selection is `const <Topping>{}`.
- With no `validator`, `E` infers to its bound `Object`. That compiles and then breaks every
  `switch` on your error enum, so spell it out: `AdvancedTextFieldController<MyError>()`.
- `AdvancedFieldController<T, E>` is **concrete** — construct it directly for any value with no
  controller of its own (a slider, stepper, rating, derived total):
  `AdvancedFieldController<int, MyError>(initialValue: 0, name: 'total')`. Full constructor:
  `{required T initialValue, Validator<T, E>? validator, AsyncValidation<T, E>? asyncValidation,
  FocusNode? focusNode, String? name}`. Ordinary writes need no `force:` — that is only for
  writing to a field you marked read-only.

To transform text as the user types (normalize, mask, uppercase), extend
`AdvancedTextFieldController<E>` and override `setValue`:

```dart
class PhoneFieldController<E extends Object>
    extends AdvancedTextFieldController<E> {
  PhoneFieldController({
    String initialValue = '',
    Validator<String, E>? validator,
    AsyncValidation<String, E>? asyncValidation,
    FocusNode? focusNode,
    String? name,
  }) : super(
          initialValue: _digits(initialValue), // normalize before it reaches super
          validator: validator,
          asyncValidation: asyncValidation,
          focusNode: focusNode,
          name: name,
        );

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  void setValue(String newValue, {bool force = false}) =>
      super.setValue(_digits(newValue), force: force);
}
```

Every write to `textController` — keystroke, paste, programmatic `.text =` — goes through the
public `setValue`, so the override always runs and the transformed value is written back with
the caret kept on the same characters. Three writes **bypass** `setValue` and need the same
treatment: the constructor's `initialValue` (done above), `reset()` (returns to that same
normalized value), and `prefill()`. Forward constructor parameters explicitly rather than
mixing `super.x` parameters with an explicit `super(...)`. Signatures for overriding:
`void setValue(T newValue, {bool force = false})`, `void prefill(T newValue, {bool force = false})`.

### Field state — `AdvancedFieldState<T, E>`

`AdvancedFieldBuilder` hands you this; `field.value` **is** this state object. State is
value-equal, so a no-op write notifies nobody.

| Member | Meaning |
| --- | --- |
| `value` | the current value — `field.fieldValue` is the shortcut |
| `error` | `validationError ?? asyncError` — `field.error` is the shortcut |
| `validationError` / `asyncError` | what the sync path (validator or `setError`) / the async round recorded |
| `status` | `FieldStatus.valid` \| `invalid` \| `pending` \| `validating` \| `failedValidation` |
| `isValid` / `isInvalid` | status is `valid` / `invalid` |
| `isPending` / `isValidating` / `isInProgress` | waiting out the debounce / request in flight / either |
| `isFailedValidation` | the async validator threw or timed out |
| `readOnly` | `setValue` is a no-op (pass `force: true` to override) |
| `validationMode` | the **effective** mode — a field whose form has validation switched off reports `manual` |

`valid` means *no error recorded*, not *checked and passed*: a field nobody validated yet is
`valid`. There is **no** "has this been checked" or "was this submitted" flag — `await
validate()` is the guarantee; keep your own bool if the UI needs one.

## Binding widgets

`AdvancedFieldBuilder<T, E>` wraps `ValueListenableBuilder` and rebuilds only when its own
field notifies, so a keystroke rebuilds one subtree. Its third builder parameter is a `child:`
passthrough for a subtree that does not depend on field state.

Type arguments match the controller: `<String, E>` text, `<bool, E>` boolean, `<V?, E>` single
select (over an `AdvancedSingleSelectFieldController<V, E>`), `<Set<V>, E>` multi select.

Disable the widget while `state.readOnly`: pass `getValueSetter()` wherever the callback is a
`ValueSetter<T>?` (`Switch.onChanged` takes it directly), and `state.readOnly ? null : …`
where it is not.

```dart
// Dropdown — DropdownButton in an InputDecorator compiles on every supported SDK.
// Prefer it over DropdownButtonFormField, whose value parameter was renamed across versions.
AdvancedFieldBuilder<Country?, MyError>(
  field: form.country,
  builder: (context, state, _) {
    final error = state.error; // promote E? to E: ErrorTranslator takes a non-null E
    return InputDecorator(
      decoration: InputDecoration(errorText: error == null ? null : translate(error)),
      child: DropdownButton<Country>(
        value: state.value,
        isExpanded: true,
        items: [
          for (final option in form.country.options)
            DropdownMenuItem(value: option, child: Text(option.name)),
        ],
        onChanged: state.readOnly ? null : form.country.select,
      ),
    );
  },
)

// A scalar field, wrapped in Focus so focus() can reach it.
AdvancedFieldBuilder<int, MyError>(
  field: form.rating,
  builder: (context, state, _) {
    final setter = form.rating.getValueSetter();
    return Focus(
      focusNode: form.rating.focusNode, // without this, form.rating.focus() does nothing
      child: InputDecorator(
        decoration: InputDecoration(
          errorText: state.error == null ? null : translate(state.error!),
        ),
        child: Slider(
          value: state.value.toDouble(),
          min: 0, // Slider asserts min <= value <= max — cover the field's initial value
          max: 5,
          divisions: 5,
          onChanged: setter == null ? null : (v) => setter(v.round()),
        ),
      ),
    );
  },
)
```

A `Focus` wrapper makes the node reachable so `focus()` lands there; whether the widget inside
paints a focus ring is its own business.

Widgets with no `errorText` slot — `Switch`, `CheckboxListTile`, a `Wrap` of `FilterChip`s for
a multi-select — render `state.error` yourself or wrap them in an `InputDecorator` as above.
Adapt the setter where the signature differs: `CheckboxListTile.onChanged` is
`ValueChanged<bool?>?`, so `onChanged: setter == null ? null : (v) => setter(v ?? false)`.

`ErrorTranslator<E>` is `String Function(E)` — a plain function, so write it wherever the
labels belong: `String translate(MyError e) => switch (e) { MyError.required => 'Required', … };`.
It takes a **non-null** `E` while `state.error` is `E?`, so promote before calling. One shared
translator per enum is the cheapest start; pass a field-specific one where the wording differs
("Required" vs "Pick a country"). In a real app wrap each binding once in a reusable widget
taking `field` + `ErrorTranslator<E>`.

Do not wrap fields in Flutter's `Form` — no `Form`, no `GlobalKey<FormState>`, no
`autovalidateMode`. This package *is* the validation system and a second one fights it. (A
`TextFormField` outside a `Form` is fine — unregistered, it is a `TextField` with a decoration.)

## Validation

```dart
typedef Validator<T, E extends Object> = E? Function(T);
```

### When validation runs — three rules

1. **`ValidationMode` decides which events make a field validate itself.** Set it once on the
   form; it reaches every field and subform, including ones registered or attached later.
2. **A field the user has never edited validates nothing on its own** — in every mode. Only
   `setValue` (a user edit) marks a field as edited; `prefill` does not, and `reset()` makes it
   count as untouched again.
3. **A round runs the sync validator first, and the async validator only if sync passed.**

| `ValidationMode` | on user edit | on unfocus | when a dependency changes |
| --- | --- | --- | --- |
| `manual` (the default) | — | — | — |
| `onUserInteraction` | validate (async debounced) | — (the edit already did) | sync only |
| `onUnfocus` | — (still typing) | validate | sync only |

```dart
class SignupFormController extends AdvancedFormController {
  SignupFormController() : super(validationMode: ValidationMode.onUserInteraction) {
    registerFields([email, username]);
  }

  // One field opting out: checked when the user leaves it, not on every keystroke.
  // This is a ONE-WAY opt-out — the field stops following the form's mode for good.
  final username = AdvancedTextFieldController(
    validator: filled(MyError.required),
  )..setValidationMode(ValidationMode.onUnfocus);
}
```

`onUnfocus` fires from the field's `focusNode`, so bind it in the widget. A widget that manages
focus itself — a picker, a date dialog, a custom dropdown — calls `field.handleUnfocus()`
instead; nothing validates in that mode otherwise. It returns a `Future<void>` you may await,
and it flushes a pending debounce in *any* mode.

`AdvancedFormController`'s other constructor arguments are `debugName` (a label for your own
logging, never read by the package) and `validateAll` (below).

**`validate()` ignores all of it.** `await form.validate()` validates every field and subform
— including ones the user never touched — and returns `false` if anything is invalid. It
neither consults nor changes the mode, so there is no escalation and no "live after the first
submit" for free. Double-tapping submit is safe: a second call joins the first. **Always
`await validate()` before using the values** — `state.isValid` and `form.value.canSubmit` mean
"no error recorded right now", and a passing `validate()` is what licenses a `!` on a nullable
field value.

### Built-in validators

Every string validator is typed `Validator<String?, E>`, even though
`AdvancedTextFieldController` holds a non-nullable `String`. Assigning one to `validator:` is
fine; **combining** is where it bites.

| Validator | `T` | Rejects |
| --- | --- | --- |
| `filled(e)` | `String?` | null, empty, whitespace-only |
| `notLongerThan(max, e)` | `String?` | `length > max` — `max` itself passes, null passes |
| `atLeastLength(min, e)` | `String?` | null, `length < min` — `min` itself passes |
| `exactly(s, e)` | `String?` | anything not equal to `s` |
| `nothing(e)` | `String?` | any non-empty string |
| `positiveInteger(e)` / `nonNegativeInteger(e)` | `String?` | null, non-numeric, and `<= 0` / `< 0` after `int.tryParse` |
| `positiveDecimal(e)` / `nonNegativeDecimal(e)` | `String?` | the same with `double.tryParse` |
| `boundedNonNegativeInteger(max, e)` | `String?` | anything but `0..max` or the literal string `>max` |
| `notNull(e)` | `T?` (any) | null |
| `notEmpty(e)` | `List<T>?` | null, empty list |
| `mustBeTrue(e)` | `bool?` | null, false |

`conditionalValidator(v, () => enabled)` runs `v` only while the getter returns true;
`dynamicValidator(() => buildValidator())` rebuilds the validator on each call. Both keep `T`.

**`notEmpty` does not fit a `Set`.** Write a closure:

```dart
validator: mustBeTrue(MyError.mustAccept),                      // bool field
validator: (value) => value.isEmpty ? MyError.pickOne : null,   // Set<V> field
```

Combine with `&` (all must pass) and `|` (one must pass), or `and([...])` / `or([...])`, which
take an optional shared error code as their second argument. `&` short-circuits and the
left-most error wins, in both operators.

Both sides need the same **`T`**. The built-ins are all `String?`, so annotate a custom string
closure as `String?` too, and it matches whichever side of the operator it lands on:

```dart
validator: filled(MyError.required) &
    ((String? value) =>
        (value?.contains('@') ?? false) ? null : MyError.invalidEmail),
```

Both sides also need the same **`E`**, which is inferred from the error you hand the validator.
With an enum that is automatic. With a **sealed class** it is not: `filled(RequiredError())`
infers `E = RequiredError`, so combining it with `notLongerThan(20, TooLongError())` fails to
type-check. Pass the type argument explicitly:

```dart
validator: filled<MyError>(RequiredError()) & notLongerThan<MyError>(20, TooLongError()),
```

## Async validation

For checks that live on the server. Every field controller takes `asyncValidation`, selects
included. A verdict your own save call returns is not this — push it with `setError`.

```dart
final username = AdvancedTextFieldController(
  validator: filled(MyError.required),
  asyncValidation: AsyncValidation<String, MyError>( // arity is <T, E>
    validator: (value) async =>          // Future<MyError?> Function(String)
        await api.isTaken(value) ? MyError.taken : null,
    debounce: const Duration(milliseconds: 500), // default 300ms
    timeout: const Duration(seconds: 5), // default unbounded; bounds the run, not the debounce
    failureToError: (e, s) => MyError.checkFailed, // E? Function(Object, StackTrace)
    onFailure: (e, s) async => log(e), // Future<void> Function(Object, StackTrace); omit it and
                                       // failures go to FlutterError.reportError, where a throw
                                       // from either callback is also reported, never rethrown
  ),
);
```

What you get for free:

- **Debounced while typing**, immediate on `validate()`. `debounce` only delays a round a
  **keystroke** started, so it matters in `onUserInteraction` and is dead configuration in
  `manual` and `onUnfocus`, where the check is started by `validate()` or by leaving the field.
- **Cancellation**: a value change kills the in-flight round; a stale answer can never land.
- **No wasted calls**: a settled answer is reused while the value is unchanged, so a second
  submit on an untouched form makes no network calls. Any `setValue` drops it. If the check
  depends on state *outside* the value, invalidate with `field.clearErrors()`.
- **Renderable status**: `state.isPending` / `isValidating` / `isInProgress` — a spinner is one
  check on `isInProgress`.
- **Submit waits**: `await form.validate()` waits for the answer instead of failing a busy field.

**Optional async check.** `conditionalValidator` is sync-only and `AsyncValidation` has no skip
flag, so guard inside the async validator itself — `validator: (value) async =>
value.trim().isEmpty ? null : await api.isTaken(value) ? MyError.taken : null`. The round still
starts (the field shows `validating` for a tick) but makes no network call.

**Failure ≠ error.** A validator that *throws* or times out is a technical fault, not a verdict:
the field lands on `FieldStatus.failedValidation`, does not count as valid, and `validate()`
returns `false`. `form.value.hasFailedValidation` drives one "could not verify, try again"
banner. `failureToError` maps the fault to an error code **and keeps** the field on
`failedValidation`, so per-field text and banner show together; omit it when the banner is all
you want. Failure is not sticky — the next `validate()` retries, so submit is the retry button,
**provided the button is still enabled** (see below). `field.lastFailure` is the diagnostic
detail: an `AsyncValidationFailure?` (`error`, `stackTrace`, `timedOut`), non-null only while
the field is on `failedValidation`.

## Cross-field logic

**Rule depends on another field** (repeat-password). `subscribeToFields` re-runs *this* field's
**sync** validator when the listed fields' values change — that and nothing else. Use `late
final` because the closure references a sibling:

```dart
final password = AdvancedTextFieldController(
  validator: atLeastLength(8, MyError.tooShort),
);

late final repeatPassword = AdvancedTextFieldController<MyError>(
  validator: (value) =>
      value == password.fieldValue ? null : MyError.doesNotMatch,
)..subscribeToFields([password]);
```

Async validators are not re-run (this field's own value did not change, so no network call is
owed), and nothing happens while this field is in `manual` mode or the user has never edited
it. A second `subscribeToFields` call **replaces** the previous subscription.

**Two fields watching each other** — one rule spanning a pair, either side able to break or fix
it (`adults` + `children`, "book at least one person"). Wire them in the **constructor body**
after `registerFields`, never in a cascade:

```dart
adults.subscribeToFields([children]);
children.subscribeToFields([adults]);
```

- A cascade `..subscribeToFields([sibling])` in a `late final` initializer evaluates the sibling
  **eagerly**, so a mutual pair **stack-overflows at construction**. A mutually-referencing
  `late final` pair also needs an **explicit type** or the analyzer reports `top_level_cycle`.
- No loop results: the subscription re-runs only when a watched **value** changes, not on a
  sibling's error or status change.
- An error only appears on a field whose **own** validator returns it, so the pair's rule goes
  in **both** validators. The subscriptions only re-run them.
- **Rule 2 still applies to the sibling.** The other field revalidates only if it is itself in
  an open mode *and the user has already edited it*. Touch `adults` and never `children`, and
  only `adults` lights up live — `children` shows its half at the first `validate()`. Both
  showing simultaneously before submit is not something the modes can give you; render the
  pair's message once, from the form, if the design needs it.

**Value depends on another field** ("when B changes, set A" — totals, mirroring, clearing a
dependent selection). Use the form's `addRelation(source, select, onChange)`, in the
constructor body after `registerFields`:

```dart
MyForm() {
  registerFields([quantity, total]);
  addRelation(
    quantity,
    (value) => int.tryParse(value) ?? 0,
    (count) => total.setValue(count * unitPrice, force: true),
  );
}
```

- `select` picks the part of `source`'s value to watch; `onChange` fires only when that part
  changes, `==`-compared against the last-seen value. A status-only change never fires it, and
  unlike a raw `addListener` pair a mutual relation pair cannot loop.
- It does **not** fire at registration — seed the initial state yourself right after, and give
  the target the derived value as its own `initialValue:` (a value seeded after
  `registerFields` reports `wasModified: true` before the user touches anything).
- A derived field is usually one you `markReadOnly()`, where `setValue` is a no-op, hence
  `force: true`.
- `source` may be **any** field controller, including one owned by a subform — it is a plain
  listener, not a membership check. One target fed by two sources is two `addRelation` calls
  into the same method.
- The form removes the listener in its own `dispose()`. Throws a `StateError` if the form or
  `source` is already disposed.
- A *destructive* relation — `city.reset()` when `country` changes — is safe: `validate()`
  changes no values, so it cannot wipe the user's choice. Attaching or detaching subforms and
  calling `setValidationEnabled` from `onChange` is supported.
- Raw `addListener` + `setValue` is right only when the target is not a form field at all — a
  plain `ValueNotifier`, a service callback — and there you do the `==` comparison yourself,
  because `addListener` fires on **any** state change.

**Everything depends on everything**: `MyForm() : super(validateAll: true)` re-runs the sync
validator on every field in the tree that its mode allows, on any value change. Blunt but
correct when most fields cross-validate. It is implemented with `revalidateSync()`, which is
public on both controllers — call it by hand when something *other* than a field's own value
must force a tree-wide sync revalidation (a locale switch changing what "too long" means, a
feature-flag flip). No network call is owed, so no async check starts.

## Form-level state and the submit button

The form is a `ValueListenable<AdvancedFormState>`:

```dart
ValueListenableBuilder<AdvancedFormState>(
  valueListenable: form,
  builder: (context, state, _) {
    // Gate on !validating. Gating on canSubmit alone is a trap: it is false while any
    // round is in flight AND while any field sits in failedValidation, so a form whose
    // check just fell over disables the very button its "try again" banner points at.
    // If you want canSubmit to grey out known errors, keep the retry path open with
    // `state.canSubmit || state.hasFailedValidation` — but note hasFailedValidation
    // clears on the next edit, so that gate can re-grey. Add wasModified only when the
    // task asks for "disabled until modified".
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
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator())
          : const Text('Submit'),
    );
  },
)
```

`submit()` is **your** method, not package API — the package gives you `validate()` and you
wrap it. Never pass it bare (`onPressed: form.submit`) or through an arrow closure
(`() async => form.submit()`): both hand the future to a caller that drops it, so you lose the
result and a throw becomes an unhandled async error. Use a block body that awaits.

**A submit request in flight is yours to track.** `validating` covers async *validators* only;
the package knows nothing about your network call. Keep your own flag (a `ValueNotifier<bool>`
on the controller) and set it **before** `await validate()`, the first await in a submit, or a
double tap sends two requests. Subclassing the form controller for this is fine:
`notifyListeners()` is callable and `dispose()` is overridable — dispose your own objects
first, then `super.dispose()` last.

| Member | Meaning |
| --- | --- |
| `wasModified` | any field differs from its value at `registerFields` time, or a subform was modified |
| `canSubmit` | every counted field is `valid` *right now* — a snapshot of known errors, never a replacement for `await validate()` |
| `validating` | an async round is pending or in flight somewhere in the tree |
| `hasFailedValidation` | some async check threw or timed out — drive one form-level banner |
| `validationErrors` | `Map<AdvancedFieldController<dynamic, dynamic>, dynamic>` — every current error keyed by field; cast the values to `E` |
| `validationEnabled` | false → this subtree validates nothing and drops out of the four members above — but **not** out of `wasModified` |
| `validationMode` | this form's configured mode, not reduced by `validationEnabled` |
| `fields` / `subforms` / `allFields` | own fields / attached subforms / both, as an `Iterable<AdvancedFieldController<dynamic, dynamic>>`: own fields in `registerFields` order, then each subform's, recursively |

The four aggregates count only subtrees with `validationEnabled`. **`allFields` does not
filter**, so prefer the aggregates over folding `allFields` yourself, and skip switched-off
subtrees by hand when you do walk it.

**The form notifies for its whole tree.** A parent listens to every attached subform, so a
field changing three levels down notifies the root — one `ValueListenableBuilder` on the root
form covers a submit button over a wizard, with no merging of the steps' listenables. With
provider, subscribe to one slice: `context.select<SignupFormController, bool>((c) =>
c.value.validating)`. Outside widgets, `form.onValuesChanged` / `form.onStatusChanged` are
tree-wide `Listenable`s.

Two things you build on top of that state — an error summary, and focusing the first broken
field. `name` is a machine key, so keep a label map when the summary is user-facing:

```dart
// Error summary
for (final entry in form.value.validationErrors.entries)
  Text('${labels[entry.key] ?? entry.key.name}: ${translate(entry.value as MyError)}'),

// On the form controller
Future<void> submitAndFocus() async {
  if (await validate()) {
    return;
  }
  for (final field in value.allFields) {
    // !isValid, not isInvalid: after validate() a field may sit in failedValidation,
    // and that one deserves the focus too.
    if (!field.value.isValid) {
      field.focus();
      return;
    }
  }
}
```

`focus()` is a safe no-op on a disposed controller, but reading `focusNode` on one **throws** a
`StateError` — never touch `focusNode` from a widget that can outlive its form.

## Server errors, read-only, reset

```dart
field.setError(MyError.emailTaken); // push an error in (e.g. from a 422 response)
field.setError(null);               // clear it — status follows
field.clearErrors();                // forget everything, incl. the async verdict
field.markReadOnly();               // setValue becomes a no-op; validate() still works
field.prefill(value);               // programmatic write: no validation, does not count as an edit
field.reset();                      // back to initialValue; clears both errors, the async verdict
                                    // and lastFailure, and makes the field untouched again.
                                    // Works read-only (that guard is in setValue); keeps
                                    // readOnly + validationMode — those are configuration
form.markReadOnly(); form.clearErrors(); form.resetAll(); // whole tree
form.setValidationEnabled(false);   // this subtree stops validating and stops counting
```

Push server errors **after** the `await`, never before: `validate()` and anything else that
re-runs the sync validator overwrites a pushed code — which is also why a rejection clears
itself on the next submit or edit, with no bookkeeping. `setError` writes the **sync slot
only**; a code an async round recorded survives it, so use `clearErrors()` to wipe both.
`hasFailedValidation` clears on any `setValue`, `prefill`, `clearErrors()`, `reset()`,
`setError(null)`, or the next `validate()`; `markReadOnly()` is the exception, keeping the
`failedValidation` status (though dropping `lastFailure`) so a frozen field still blocks submit.

**Server errors that carry text.** An enum cannot hold a message the server wrote, so make `E`
a sealed class — `E` only has to be non-nullable:

```dart
sealed class SignupError {}
class RequiredError implements SignupError {}
class ServerMessage implements SignupError {
  ServerMessage(this.message);
  final String message;
}

String translate(SignupError e) => switch (e) {
  RequiredError() => 'This field is required',
  ServerMessage(:final message) => message,
};

// on your AdvancedFormController subclass
void applyServerErrors(Map<String, String> byFieldName) {
  // whereType, not cast: cast is an unchecked view that throws later on any field
  // whose E widened to Object.
  final fields =
      value.allFields.whereType<AdvancedFieldController<dynamic, SignupError>>();
  for (final field in fields) {
    final message = byFieldName[field.name];
    field.setError(message == null ? null : ServerMessage(message));
  }
}
```

Give every field a `name:` when the server addresses fields by name. That loop clears every
field the server did *not* name, which is right **after a passing `validate()`** — no rule
errors are left to destroy and the server is the only authority. If you push server errors while
the validators' own codes may still be on the fields, write only the named fields: a blanket
`setError(null)` erases rule errors too.

**Prefilling an edit form.** `prefill(value)` is the write for data the user did not type: it
stores the value, clears both errors, validates nothing in any mode, and — unlike `setValue` —
does **not** mark the field as edited, so the form stays quiet until the user touches it. It
takes exactly what the field holds: `V?` on a single select (pass `null` to clear), a `Set<V>`
on a multi select.

`wasModified` is baselined at `registerFields` time, so a controller that registers fields and
*then* prefills from a fetch reports `wasModified: true` forever. Either build the controllers
with the loaded data as `initialValue:`, or re-call `registerFields(sameList)` once the data
arrives. Re-registering the very same controllers is safe — the form drops its old listeners
first and owns each field once — but it re-baselines **this** form only: every subform keeps its
own baseline and needs its own re-registration. Re-baselining also does not move `reset()`,
which always returns to the constructor's `initialValue`, so afterwards `resetAll()` lands off
the baseline and flips `wasModified` back to true. Prefer the `initialValue:` route whenever the
data is there before construction, or the form has a discard button.

## Subforms

Split big forms, or attach sections that appear dynamically. Subform fields join the parent's
`validate`, `markReadOnly`, `resetAll`, `wasModified` and the rest — but **only while attached**.

### A section that is toggled — keep it attached, switch validation off

Prefer this. The subform stays in the tree, so `resetAll`, `markReadOnly`, `clearErrors`,
`setValidationMode` and `dispose()` all still reach it, and no ownership changes hands.

```dart
class CheckoutFormController extends AdvancedFormController {
  CheckoutFormController() {
    registerFields([email, sameAsBilling]);
    addSubform(shipping);
    // addRelation fires on change only, so seed the initial state right after.
    addRelation(sameAsBilling, (value) => value,
        (same) => shipping.setValidationEnabled(!same));
    shipping.setValidationEnabled(!sameAsBilling.fieldValue);
  }

  final email = AdvancedTextFieldController(validator: filled(MyError.required));
  final sameAsBilling = AdvancedBooleanFieldController<MyError>();
  final shipping = ShippingFormController(); // another AdvancedFormController
}
```

A switched-off subtree **stops counting entirely**: it validates nothing, its `validate()`
returns `true` unrun, and its fields leave `canSubmit`, `validating`, `hasFailedValidation` and
`validationErrors`. That one flag is the whole condition — no mode to reset, no error to clear
by hand. Switching off clears the subtree's **errors** and leaves every **value** untouched,
which is exactly why this beats detaching for a section the user may toggle back on. Switching
back on re-runs the sync validators, still subject to the three rules — so a field the user
never edited stays quiet and a re-appearing section does not paint itself red.

`validationEnabled` starts `true` and only `setValidationEnabled` writes it — `resetAll()`
leaves it alone, so seed it at construction and again in whatever method calls `resetAll()`.
It composes with a parent's switch by AND, so a section that opted out stays out.
(`wasModified` is the exception: a switched-off subform still reports its modifications.)

### A section that genuinely appears and disappears — attach and detach

```dart
void enableGift() => addSubform(gift);
void disableGift() => removeSubform(gift); // detaches only — `gift` is NOT disposed
```

- **The parent owns every subform it was ever given** and disposes them all in its own
  `dispose()`, detached ones included, so the same controller can be re-attached later. **Do
  not dispose subforms yourself** — if you do, the parent skips them rather than double-disposing.
- Ownership starts at `addSubform`, so a subform **constructed but never attached** belongs to
  nobody and is never disposed. A section that starts hidden should still be attached once at
  construction (and switched off, or immediately detached) — or disposed by you.
- A detached subform is out of reach of `validate`, `resetAll`, `markReadOnly`, `clearErrors`
  and `setValidationMode`, and out of the parent's aggregates.
- A subform attached *after* the first `validate()` behaves exactly like one attached at build
  time — the mode is broadcast on attach and `validate()` changes nothing. No fix-up needed.
- A subform with its own `validationMode:` keeps it and stops following the parent's.
- `addSubform` is a no-op when already attached, `removeSubform` when not — a toggle needs no
  bookkeeping flag.

### A wizard, validated step by step

One subform per step makes per-step validation one line: `await step.validate()` reaches that
step's fields and nothing else, so a field on a later step is never flagged early. The final
submit calls the parent's `validate()`, which walks every attached subform.

```dart
Future<bool> next() async {
  final step = currentStep;
  if (!await step.validate()) {
    // The step has shown its errors once — let it correct itself as the user types.
    // A subform's own mode wins over the parent's, so the steps ahead stay quiet.
    step.setValidationMode(ValidationMode.onUserInteraction);
    return false;
  }
  _goTo(currentIndex + 1);
  return true;
}
```

Which step is on screen is navigation, not form state: keep it on your own controller, created
*above* the pages — a wizard controller built inside a step page dies with it, taking that
step's values and errors along. A conditional step is the toggled subform above.

## Lifecycle and ownership

- The form disposes every field passed to `registerFields` and every subform ever passed to
  `addSubform`. **Never dispose those yourself.** You dispose only the form.
- Any ownership works because the controller is a `ChangeNotifier`:
  `ChangeNotifierProvider(create: (_) => MyFormController())` disposes it for you; in a
  `StatefulWidget`, dispose it in `State.dispose`.
- Get the controller with `context.read` (actions, stable references); subscribe with
  `AdvancedFieldBuilder` / `ValueListenableBuilder` / `context.select` (rebuilds).
- `registerFields`, `addSubform`, `removeSubform`, `setValidationEnabled`, `subscribeToFields`
  and `setValue` throw a `StateError` on a disposed controller — `registerFields` and
  `addSubform` also when what they are *given* is disposed. `validate()` does not: it returns
  `false`, so a submit after teardown fails quietly.

**Migrating a 0.1.x form.** This skill describes building against the current API. Porting
existing `FieldCubit`/`FormGroupCubit` code is a one-time rewrite, not that task: follow
`MIGRATION.md` in the package root (with `CHANGELOG.md` for the version history) and use this
file only as the reference for what the ported code should look like.
