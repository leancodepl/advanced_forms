# Migrating from 0.1.x to 0.2.0

0.2.0 keeps the form-building model of 0.1.x — fields, form groups, validators, subforms — and replaces the state-management machinery underneath it:

- `flutter_bloc` and `rxdart` are no longer dependencies. Fields and forms mix in `ChangeNotifier` and implement `ValueListenable`, both from the Flutter SDK, so the library no longer constrains the app's state-management stack.
- Every `*Cubit` class is now an `Advanced*Controller` (`FieldCubit` → `AdvancedFieldController`). Most members carry over unchanged; [section 3](#3-behavior-changes-that-are-not-renames) covers the ones that don't.
- Lifecycle is synchronous: `void dispose()` replaces `Future<void> close()`.
- `AdvancedTextFieldController` owns its `TextEditingController` and `FocusNode`.

## 1. Migration checklist

1. Update `pubspec.yaml`: confirm the app is on Flutter 3.19 or newer, remove `flutter_bloc` and `rxdart`, plus `bloc_test`, `bloc_presentation`, and `flutter_hooks` if forms were the only reason for them. Add `provider` if you used `BlocProvider` ([section 8](#8-dropping-flutter_bloc-and-friends)).
2. Rename the classes ([section 2](#2-rename-reference)).
3. Replace `.state` reads with `.value` / `fieldValue` ([section 4](#4-form-classes-and-state-reads)).
4. Move `asyncValidator:` and `asyncValidationDebounce:` into `asyncValidation:` ([section 4](#4-form-classes-and-state-reads)).
5. Replace `clear()` with `reset()` ([section 2](#2-rename-reference)).
6. Migrate widgets: a third builder parameter, and delete `TextEditingController` plumbing ([section 5](#5-migrating-your-widgets)).
7. Convert `close()` overrides to `dispose()`, and `addDisposable(...)` registrations to explicit cleanup ([section 7](#7-lifecycle-close--dispose)).
8. Replace form-level stream subscriptions with listeners ([section 6](#6-form-listenables-instead-of-streams)).
9. Rewire custom cubit-stream patterns ([section 9](#9-migrating-a-custom-field)).
10. Check the behavior changes in [section 3](#3-behavior-changes-that-are-not-renames) against your code — they compile but behave differently.
11. On edit screens, review every `subscribeToFields` on a field filled from the server: it no longer reaches a field the user has not edited ([details](#subscribetofields-no-longer-reaches-a-field-the-user-has-not-edited)).
12. Wherever you `resetAll()`, remember it keeps `readOnly` and the validation mode: unlock and switch the mode yourself ([details](#reset-keeps-the-validation-mode-and-readonly)).
13. Guard writes that land after a screen closed — `await api(); field.setValue(result);` — with `isDisposed`, because a disposed controller now throws ([details](#a-disposed-controller-throws-from-every-mutator)).

---

## 2. Rename reference

| 0.1.x | 0.2.0 |
| --- | --- |
| `FieldCubit<T, E>` | `AdvancedFieldController<T, E>` |
| `TextFieldCubit<E>` | `AdvancedTextFieldController<E>` |
| `BooleanFieldCubit<E>` | `AdvancedBooleanFieldController<E>` |
| `SingleSelectFieldCubit<V, E>` | `AdvancedSingleSelectFieldController<V, E>` |
| `MultiSelectFieldCubit<V, E>` | `AdvancedMultiSelectFieldController<V, E>` |
| `FormGroupCubit` | `AdvancedFormController` |
| `FieldState<T, E>` | `AdvancedFieldState<T, E>` |
| `FormGroupState` | `AdvancedFormState` — `validating` is now a getter, so `AdvancedFormState(validating: …)` no longer compiles |
| `FieldBuilder<T, E>` | `AdvancedFieldBuilder<T, E>` — wraps `ValueListenableBuilder`; `builder` gains a third `child` param |
| `cubit.state` | `controller.value` (plus the `fieldValue` and `error` shortcuts) |
| `cubit.isClosed` (from `Cubit`) | `controller.isDisposed` |
| `field.clear()` | **Removed** — call `field.reset()` |
| `asyncValidator:`, `asyncValidationDebounce:` | `asyncValidation: AsyncValidation(validator:, debounce:, timeout:, onFailure:, failureToError:)` — `timeout`, `onFailure` and `failureToError` are new, not renames ([details](#a-throwing-async-validator-no-longer-hangs-the-field)) |
| `bool field.validate()`, `bool form.validate()` | `Future<bool> validate()` — **await it** ([details](#validate-is-asynchronous)) |
| `field.setAutovalidate(bool)`, `form.setAutovalidate(bool)` | `setValidationMode(ValidationMode)` ([details](#autovalidate-is-replaced-by-validationmode)) |
| `AdvancedFieldState.autovalidate` (`bool`) | `AdvancedFieldState.validationMode` (`ValidationMode`) ([details](#autovalidate-is-replaced-by-validationmode)) |
| `form.validateWithAutovalidate()` | `form.revalidateSync()` |
| `form.onValuesChangedStream` (`Stream<void>`) | `form.onValuesChanged` (`Listenable`) |
| `form.onStatusChangedStream` (`Stream<FieldStatus>`) | `form.onStatusChanged` (`Listenable`, no payload) |
| `BlocBuilder<FormGroupCubit, FormGroupState>` | `ValueListenableBuilder<AdvancedFormState>` — there is no `AdvancedFormBuilder` |
| `FieldCubit.stream` (inherited from `Cubit`) | `AdvancedFieldController.stream` — deprecated extension, removed in 0.3.0 ([section 9](#9-migrating-a-custom-field)) |
| `Future<void> close()` | `void dispose()` |
| `addDisposable(...)`, the `Disposable` mixin | **Removed** — override `dispose()` ([section 7](#7-lifecycle-close--dispose)) |

---

## 3. Behavior changes that are not renames

These compile after the renames and behave differently, so nothing points you at them. Two are marked *the compiler catches this* and can be left to the analyzer.

### `validate()` is asynchronous

*The compiler catches most call sites — but a bare `validate();` statement still compiles.*

On both the field and the form. It now runs the async validators too, so its result is the only thing that says the values were actually checked. Every call site needs `await`, and every enclosing method becomes `async`:

```dart
void submit() {                     // 0.1.x
  if (validate()) { ... }
}

Future<void> submit() async {       // 0.2.0
  if (await validate()) { ... }
}
```

Calling it again before the first call finishes gives you the same result, so a double-tapped submit button runs one pass. For a synchronous "can I enable the button?" read, use `form.value.canSubmit` — a snapshot of *known* errors, true on a form nobody has checked yet.

### `autovalidate` is replaced by `ValidationMode`

In 0.1.x `setValue` ran the async validator whether or not autovalidate was on, so a form nobody had submitted still ran async validators, and `validate()` never reached an async validator. Now one named mode on the form covers both: `ValidationMode.onUserInteraction` reproduces `autovalidate: true`, `ValidationMode.manual` — the default — reproduces `autovalidate: false`, and `ValidationMode.onUnfocus` is new. Within a mode the sync validator runs first, with the async one only if sync passed.

### `validate()` no longer turns validation on

`validate({bool enableAutovalidate})` lost its parameter on both controllers. The mode you set is the mode the form keeps, before and after the first submit — which is also what makes a subform attached late behave exactly like one attached at build time. If you relied on "quiet until the first submit, live afterwards", set `ValidationMode.onUserInteraction` up front.

### Only a field the user has edited validates itself

In every mode, a field nobody has typed into stays quiet until `validate()` reaches it — including when a sibling changes and including when it was prefilled with a bad value. Write programmatic values with the new `prefill(value)` rather than `setValue`, so a profile fetch does not arm the field. For the sibling case on an edit screen, see [`subscribeToFields` no longer reaches a field the user has not edited](#subscribetofields-no-longer-reaches-a-field-the-user-has-not-edited).

### A throwing async validator no longer hangs the field

In 0.1.x an exception from `asyncValidator` left the internal `Completer` uncompleted, so the field stayed in `FieldStatus.validating` indefinitely and the exception surfaced as an uncaught async error. In 0.2.0 the field moves to `FieldStatus.failedValidation` and the exception is reported through `FlutterError.reportError`, or through `AsyncValidation.onFailure` if you supply a handler. A failed field is not valid — `validate()` returns `false` — and it is not sticky: the next `validate()` re-runs the pass. 0.1.x had no failure hook, so `onFailure` and `failureToError` are new parameters, not renames:

```dart
asyncValidator: _check,                                        // 0.1.x
asyncValidationDebounce: const Duration(milliseconds: 500),

asyncValidation: AsyncValidation(                              // 0.2.0
  validator: _check,
  debounce: const Duration(milliseconds: 500),
  onFailure: _report,                                          // new; stackTrace is non-nullable
  failureToError: (e, s) => MyError.checkFailed,               // new; optional, gives it something to show
);
```

### `FieldStatus` gained a `failedValidation` value

*The compiler catches this.*

Previously exhaustive `switch`es over `FieldStatus` stop compiling until you add a `failedValidation` arm. Map it alongside `invalid` unless you want to distinguish "the check could not run" from "the check returned an error".

### `setError(null)` clears instead of marking the field invalid

0.1.x pinned the status to `invalid` whatever it was handed, so applying a server response field-by-field marked every accepted field invalid with nothing to show. The status now follows what the field actually holds:

```dart
field.setError(null);        // 0.1.x: status invalid, nothing to show
field.setError(null);        // 0.2.0: clears validationError, status follows
```

`setError` writes `validationError` only. If an async check recorded a code, `setError(null)` leaves it and the field stays `invalid` — call `clearErrors()` to clear both. 0.1.x wiped `asyncError` on every `setError`, so an async code could not survive a server-response pass.

### `reset()` keeps the validation mode and `readOnly`

0.1.x rebuilt a default state, so `form.resetAll()` unlocked fields business logic had locked. Call `setValidationMode` / `unmarkReadOnly` explicitly if you relied on that. It does make the field count as untouched again:

```dart
field.reset();               // 0.1.x: also cleared the mode and readOnly
field.reset();               // 0.2.0: value and errors only; flags survive
```

### `subscribeToFields` re-runs the sync validator only

The dependent field's own value did not change, so its last async answer still stands and no async check is owed. It does nothing while that field is in `ValidationMode.manual`. Otherwise `validationError` is rewritten, so a code you pushed there with `setError` gives way to whatever the validator now returns — as in 0.1.x. The same goes for `revalidateSync()` (renamed from `validateWithAutovalidate()`) and `validateAll: true`, which reach every field in the tree rather than the dependencies you named.

### `subscribeToFields` no longer reaches a field the user has not edited

*This is the one change that breaks an edit screen quietly: no exception, no analyzer hint, the field just stops going red.*

0.1.x revalidated the dependent field whenever a watched field changed, as long as autovalidate was on — prefilled or not. 0.2.x keeps every untouched field quiet, and that includes a field loaded from the server whose dependency the user just changed:

```dart
// An edit screen: instructor and aircraft both come from the server.
instructor.subscribeToFields([aircraft]);

aircraft.select(pa28);   // 0.1.x: instructor revalidates, "not rated on PA-28"
                         // 0.2.x: nothing — nobody has edited the instructor field
```

Where the dependent field must react anyway, call `validate()` on it from a listener on the watched field. `validate()` ignores the gate and the mode, so it reaches an untouched field, and its sync result lands before it returns. Compare the value yourself, because a listener also fires on status changes:

```dart
var lastAircraft = aircraft.fieldValue;
aircraft.addListener(() {
  if (aircraft.fieldValue == lastAircraft) return;
  lastAircraft = aircraft.fieldValue;
  instructor.validate();
});
```

Three things to know: the whole validator runs, so an empty prefilled field with a `notNull` rule shows "required" the moment its dependency moves — on a create screen, after a `prefill`, and after `resetAll()`; `validate()` runs the async validator once per value of the dependent field, then reuses the verdict; and `validate()` on submit checks every field regardless, so a form that only needs the error at submit time needs nothing at all.

### `subscribeToFields` fires more eagerly

0.1.x combined the observed fields with `Rx.combineLatest`, so nothing fired until *every* observed field had emitted at least once, and the first emission always passed `.distinct()` even for a status-only change. 0.2.0 compares each observed field's value against a cached baseline: it fires on the first value change to any one field, and never on a status-only change. Dependent fields that appeared not to revalidate in 0.1.x now will.

### `markReadOnly()` stops a running check

A frozen field no longer changes status by itself, and it drops `lastFailure` while keeping a `failedValidation` status.

### `validationErrors` now reports `error`, not `validationError`

The keys are unchanged — the map is still keyed by field controller. Each entry's value now comes from `AdvancedFieldState.error`, so a field invalid from an async check appears in an error summary, as the docs always claimed.

### `addSubform` throws instead of failing quietly

It raises a `StateError` if either the parent or the subform has already been disposed.

### A disposed controller throws from every mutator

*0.1.x ignored a write to a closed cubit. Now it is a `StateError`, and the usual place to meet one is an `await` that lands after the screen closed.*

On a field: `setValue` and `subscribeToFields`. On a form: `registerFields`, `addSubform`, `removeSubform`, `setValidationEnabled` and `addRelation`. `registerFields` and `subscribeToFields` also throw when handed a *disposed field*, where 0.1.x accepted it and failed later inside the form's own wiring. `prefill`, `setError`, `clearErrors`, `markReadOnly`, `reset` and `setValidationMode` stay silent no-ops, and `validate()` completes `false`.

Code that tore a form down and then called one of them was already broken; it now says so at the call site. The one legitimate case is a result arriving late:

```dart
final result = await api.load();
if (field.isDisposed) return;      // the screen is gone; nobody is looking
field.setValue(result);
```

### `removeSubform` only detaches, and returns `void`

*The compiler catches both — `await` on a `void` expression is an error, and so is the `close` argument.*

`removeSubform` no longer disposes the subform, and the `close` flag is gone. A detached subform is still owned by the parent and is disposed with it, exactly like a field dropped from a later `registerFields(...)` call. So there is nothing left to await, and nothing to opt out of:

```dart
await removeSubform(subform);            // 0.1.x
removeSubform(subform);                  // 0.2.0
```

Detach a subform to take it out of `validate()`, `canSubmit` and the parent's state; re-attach it later with `addSubform`. To take a subtree out of validation while keeping it visible, prefer `setValidationEnabled(false)`.

A dynamic list — questions the user deletes, sections rebuilt per type — would otherwise pile up detached controllers until the parent dies. Dispose the one that is gone for good yourself; the parent skips it later rather than disposing it twice:

```dart
removeSubform(question);
question.dispose();
```

### `validate()` on a form with `validationEnabled: false` leaves the gates alone

0.1.x turned autovalidate on for every field in the tree before noticing that validation was disabled, so the next keystroke ran the async validators the caller had just switched off, and the form could not be submitted afterwards. 0.2.0 returns `true` without validating and leaves each field's validation mode as it found it. If your code relied on the side effect to turn validation on, call `form.setValidationMode(ValidationMode.onUserInteraction)` explicitly:

```dart
form.setValidationEnabled(false);
await form.validate();          // 0.1.x: true, and every gate now open
await form.validate();          // 0.2.0: true, gates untouched
```

### Form state settles synchronously

0.1.x routed field changes through a `.distinct()` subscription, so `wasModified` and `validating` updated a microtask later. They now update in the same call stack as the field change.

### Debounce timers and in-flight async validations are cancelled on dispose

0.1.x `close()` cancelled only the field subscription, so a timer could fire after close.

### `setValue` clears both errors in `ValidationMode.manual`

0.1.x carried the stored error over, so an error outlived the value that produced it and suppressed the async validator for every later edit. If you push a server error onto such a field and expect it to survive typing, re-push it after the change.

### The error goes blank while a check runs

Both errors are cleared when a check starts, because they described the previous value, so the message is absent for the debounce plus the request and returns if the answer is still bad. 0.1.x kept the stale message up throughout. To hold the old text, render `state.error` only when `!state.isInProgress`.

### The select controllers assert that the value is one of `options`

`select` and `addValue` throw in debug builds if handed a value outside the list, and so does `toggleElement` when it adds; removing an off-list value stays silent. Release builds keep 0.1.x behavior. `select(null)` clears the selection and is always allowed, and `initialValue` is never checked — an off-list initial value is accepted silently, which is the way out if you cannot reorder.

### `addSubform` and `removeSubform` recompute `wasModified`

Attaching an already-modified subform marks the parent modified at once, and removing the only modified child clears the flag; in 0.1.x neither happened until the next field change. An unsaved-changes guard will trip and clear at different moments.

---

## 4. Form classes and state reads

Form classes — those declaring fields and calling `registerFields` — need the renames and the async-validation change:

```dart
class SimpleFormController extends AdvancedFormController {   // was: extends FormGroupCubit
  SimpleFormController() {
    registerFields([firstName, email]);                       // unchanged
  }

  final firstName = AdvancedTextFieldController(              // was: TextFieldCubit(
    initialValue: 'John',
    validator: filled(ValidationError.empty),                 // unchanged
  );

  final email = AdvancedTextFieldController(
    validator: filled(ValidationError.empty),
    asyncValidation: AsyncValidation(                          // was: asyncValidator: _check,
      validator: _check,                                       //      asyncValidationDebounce: …,
      debounce: Duration(milliseconds: 500),                   // omit it: 300 ms, as before
    ),
  );
}
```

State reads change as follows:

| 0.1.x | 0.2.0 |
| --- | --- |
| `field.state` | `field.value` |
| `field.state.value` | `field.fieldValue` (or `field.value.value`) |
| `field.state.error` | `field.error` (or `field.value.error`) |
| `field.state.validationError` | `field.value.validationError` |
| `form.state.wasModified` | `form.value.wasModified` |

Notification is synchronous for `setValue`, `setError`, `reset`, and the other setters — no broadcast stream and no microtask hop, so tests can assert immediately after the call. Async validation is unchanged: you still have to wait out the debounce plus the validator.

---

## 5. Migrating your widgets

### Builders

`AdvancedFieldBuilder` replaces `FieldBuilder`. Its `builder` is a `ValueWidgetBuilder`, so it takes a third `child` parameter:

```dart
builder: (context, state) => Text(state.value)      // 0.1.x
builder: (context, state, _) => Text(state.value)   // 0.2.0
```

If your widgets **subclassed** `FieldBuilder` — `class FormTextField<E> extends FieldBuilder<String, E>` — that pattern no longer carries its weight, because fields are `ValueListenable`s. Rewrite them as plain `StatelessWidget`s over `ValueListenableBuilder<AdvancedFieldState<T, E>>`, which is what every widget in `example/lib/widgets/` does.

### Text fields

In 0.1.x each text widget allocated its own `TextEditingController` and seeded it from `field.state.value`, so programmatic changes — `reset()`, `setValue('foo')`, one field updating another — never reached the screen. The field owns the controller now, and disposes it and the focus node itself:

```dart
TextField(controller: field.textController);
```

To migrate a custom text widget:

1. Delete the `useTextEditingController` call or the manually allocated `TextEditingController`, and do not dispose `field.textController` externally.
2. Delete the `initialValue: state.value` and `onChanged: field.setValue` plumbing.
3. Pass `controller: field.textController` to the underlying `TextField` or `TextFormField`.
4. Delete any `FocusNode`-adding field subclass — every `AdvancedFieldController` owns a `focusNode` and a `focus()` shortcut, so a separate "focusable" variant of the widget is no longer needed. Binding it is also what makes `ValidationMode.onUnfocus` work.

---

## 6. Form listenables instead of streams

| 0.1.x | 0.2.0 |
| --- | --- |
| `form.onValuesChangedStream.listen(f)` | `form.onValuesChanged.addListener(f)` |
| `form.onStatusChangedStream.listen(f)` | `form.onStatusChanged.addListener(f)` |
| `await subscription.cancel()` | `form.onValuesChanged.removeListener(f)` |

Two consequences:

- `removeListener` needs the same callback instance that was passed to `addListener`, so a listener you intend to remove has to be a named function or a stored closure, not an inline one.
- `onStatusChanged` carries no payload, where `onStatusChangedStream` emitted the changed `FieldStatus`. Read the status off the field, or `form.value.validating` for the aggregate (now derived on read).

A *field* stream is a different story. `field.stream.distinct().listen(...)` compared whole states, so it also fired on a `markReadOnly()` or a validation change — a common source of bugs, like a dependent selection wiped on the first `validate()`. The port that keeps the intent is `addRelation`, which compares the value you pick and fires on nothing else; a raw `addListener` fires on every state change, so keep it for listeners outside a form and do the comparison yourself:

```dart
countryField.stream.distinct().listen((state) => city.reset());       // 0.1.x
addRelation(countryField, (value) => value, (_) => city.reset());     // 0.2.0
```

To rebuild on form state, `AdvancedFormController` is itself a `ValueListenable<AdvancedFormState>`:

```dart
ValueListenableBuilder<AdvancedFormState>(
  valueListenable: form,
  builder: (context, state, _) => SubmitButton(enabled: state.wasModified),
)
```

---

## 7. Lifecycle: `close()` → `dispose()`

```dart
@override
Future<void> close() async {   // 0.1.x
  await field.close();
  return super.close();
}

@override
void dispose() {               // 0.2.0
  field.dispose();
  super.dispose();
}
```

The `Disposable` mixin is gone with it, so `addDisposable(subscription.cancel)` registrations become explicit cleanup in `dispose()`. Note that 0.1.x `FormGroupCubit` also exposed a public `Future<void> dispose()` through that mixin; `await form.dispose()` no longer compiles.

### Disposing twice

`dispose()` is not idempotent: a second call throws in debug mode (`'A AdvancedBooleanFieldController<…> was used after being disposed.'`). On `AdvancedTextFieldController` the message names its `TextEditingController` instead, because the field disposes it first. `Cubit.close()` tolerated it, so 0.1.x code that disposed a field by hand *and* let `FormGroupCubit.close()` dispose it again worked by accident. Give every field and subform a single owner, and let the form be it:

- Fields registered with `registerFields(...)` are disposed by `AdvancedFormController`. Ownership is tracked in a `Set`, so registering the same field twice is safe.
- Subforms attached with `addSubform(...)` are disposed by the parent too, and stay owned by it after `removeSubform(...)`. Do not also dispose them in your own `dispose()` override. If you do dispose one yourself, the parent skips it rather than disposing it twice.

---

## 8. Dropping `flutter_bloc` and friends

**`BlocProvider` → `ChangeNotifierProvider`.** `context.read` / `context.watch` / `context.select` behave as before:

```dart
BlocProvider<SimpleFormCubit>(create: (context) => SimpleFormCubit(), …)              // 0.1.x
ChangeNotifierProvider<SimpleFormController>(create: (context) => SimpleFormController(), …)
```

Two things to watch while converting screens:

- Prefer hoisting one `final controller = context.watch<SimpleFormController>();` at the top of `build` over repeated `context.read` calls.
- State your controller holds *outside* `AdvancedFormState` — a selected tab, a list of dynamically added rows — needs an explicit `notifyListeners()` now. In 0.1.x, `emit(FormGroupState(...))` rebuilt watchers as a side effect.
- Or drop the DI dependency entirely: controllers are `ChangeNotifier`s, so a `StatefulWidget` can own one and dispose it in `dispose()`.

**`bloc_test`.** State setters are synchronous, so a form test is a plain `test(...)` block with no `blocTest` DSL. To assert a sequence of states, collect them with a listener:

```dart
final emissions = <AdvancedFieldState<int, MyError>>[];
field.addListener(() => emissions.add(field.value));
field.setValue(10);
expect(emissions, [const AdvancedFieldState<int, MyError>(value: 10)]);
```

Spell out both type arguments in the expectation: field state is value-equal only within the same `<T, E>`, and `E` cannot be inferred from the constructor arguments. Async validation still needs a wait, since the debounce timer is unchanged.

**`bloc_presentation`.** The "submit failed → fire a one-off UI event" pattern has no direct equivalent; expose a plain `Stream` from the controller instead, as `example/lib/screens/scroll_form.dart` does.

**`flutter_hooks`.** If `useTextEditingController` and `useFocusNode` were the only reason for it, it can go — `AdvancedTextFieldController` owns both.

---

## 9. Migrating a custom field

Custom fields — subclasses with a domain-typed value, their own error type, and domain methods — migrate with two edits. Validators, error hierarchies, and domain methods carry over unchanged.

```dart
class QuantityFieldController                                    // was: QuantityFieldCubit
    extends AdvancedFieldController<QuantityValue, QuantityError> {   // was: extends FieldCubit<…>
  QuantityFieldController({QuantityBounds? Function()? bounds})
      : super(
          initialValue: (unit: 'kg', amount: null),              // unchanged
          validator: (value) => _validate(value, bounds?.call()),
        );

  void setAmount(num? amount) =>
      setValue((unit: fieldValue.unit, amount: amount));         // was: state.value.unit

  void clearBackendError() {
    if (value.validationError is QuantityBackendError) {         // was: state.validationError
      validate();
    }
  }
}
```

If the field holds a `String` and its widget binds a text controller, extend `AdvancedTextFieldController<E>` rather than `AdvancedFieldController<String, E>` — you get `textController` with it; `focusNode` is on the base controller.

### The protected `emit` is gone

`FieldCubit` subclasses wrote state with the `emit` they inherited from `Cubit`, usually to set a value and an error in one go:

```dart
emit(state.copyWith(value: newValue, validationError: MyError.rejected));   // 0.1.x
```

There is no replacement, protected or public. Write the two parts through the public methods instead:

```dart
setValue(newValue);              // clears both errors, then validates if the gate is open
setError(MyError.rejected);      // pushes the error back on
```

Two differences to plan for. Each call notifies, so listeners see an intermediate state — bind widgets to `state.error` and they render blank for one frame in between. And `setValue` runs the validators in a live mode, so a validator that disagrees overwrites the error you push next; `setError` aborts a running async check, so the order above is the one that holds.

`onChange` and the `Change` class are gone as well — a `ChangeNotifier` reports that something changed, not what. Diff it yourself in a listener, as in [section 6](#6-form-listenables-instead-of-streams).

### Replacing cubit-stream patterns

`FieldCubit` inherited `stream` from `Cubit`; notifiers have no stream.

**Field B revalidates when field A changes** — `subscribeToFields([fieldA])`, as in 0.1.x, but note the timing change in [`subscribeToFields` fires more eagerly](#subscribetofields-fires-more-eagerly).

**React to part of a field's value changing** — `subscribeToFields` fires on any value change, so pick the part with the form's `addRelation`, which fires only when that part changes and is cleaned up with the form:

```dart
addRelation(
  productField,
  (product) => product.productId,
  (_) => priceField.revalidateSync(),   // the price rule reads the selected product
);
```

Outside a form, a raw listener works the same way with the comparison written by hand and a `removeListener` in `dispose()`.

**Code that composes streams** — rxdart operators, `await for`, merging fields into a pipeline. The deprecated `stream` extension bridges a field to a broadcast stream so helpers written against `FieldCubit.stream` keep compiling:

```dart
final subscription = quantityField.stream
    .map((state) => state.value.amount)
    .listen(recalculateTotals);
```

Three caveats: every read allocates a new `StreamController`, so store it rather than re-reading the getter; the controller is never closed, so unlike `Cubit.stream` it does not terminate an `await for` loop; and it goes away in 0.3.0.

---

## 10. What didn't change

- Every validator and the `Validator` / `AsyncValidator` / `ErrorTranslator` typedefs, so custom validators compile as-is.
- Every field and form method name not listed in [section 2](#2-rename-reference) — `setValue`, `markReadOnly`, `setError`, `getValueSetter`, `registerFields`, `addSubform`, `resetAll`, `setValidationEnabled`. [Section 3](#3-behavior-changes-that-are-not-renames) lists the ones whose behavior moved.
- The `pending` → `validating` → `valid`/`invalid` sequence, the debounce, and cancel-on-new-value.
- `wasModified`, still computed with `DeepCollectionEquality` against the baseline values.

---

## 11. Reference

- [`README.md`](./README.md) documents the 0.2.0 architecture from scratch.
- [`CHANGELOG.md`](./CHANGELOG.md) has the terse breaking-change list under the 0.2.0 entry.
- The `example/` app is fully migrated and is the best reference for what a real conversion looks like.
