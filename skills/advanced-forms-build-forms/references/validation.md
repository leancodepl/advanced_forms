# Validation

```dart
typedef Validator<T, E extends Object> = E? Function(T);
```

`AdvancedFormController`'s other constructor arguments: `debugName` (your log label; the package never reads it) and `validateAll` ([cross-field](cross-field.md)).

## One field, another mode

`setValidationMode` on a field is a one-way opt-out. The field stops following the form's mode for good.

```dart
class SignupFormController extends AdvancedFormController {
  SignupFormController() : super(validationMode: ValidationMode.onUserInteraction) {
    registerFields([email, username]);
  }

  final username = AdvancedTextFieldController(
    validator: filled(MyError.required),
  )..setValidationMode(ValidationMode.onUnfocus);
}
```

## A mode of your own

Reach for one of the four modes first. `ValidationMode.custom(name, fn)` is for a rule none of them states. `fn` gets a `ValidationContext` with `event` (`valueChanged`, `unfocus`, `dependencyChanged`) and `everUnfocused` (the user has left the field after editing it, at least once). It never sees the status or the errors, and it is never asked about a field the user has not edited. Modes are compared by `name`, so the name must be unique; a built-in name throws.

```dart
// Live after the first unfocus, but a dependency change never re-checks it.
final quietDependencies = ValidationMode.custom(
  'quietDependencies',
  (c) => c.everUnfocused && c.event == ValidationEvent.valueChanged,
);
form.setValidationMode(quietDependencies);
```

## Unfocus the widget owns

`onUnfocus` and `afterFirstUnfocus` listen to the field's `focusNode`, so the widget binds it ([binding](binding.md)). A picker, date dialog, or custom dropdown that owns focus calls `field.handleUnfocus()` — otherwise nothing validates in those modes. It returns `Future<void>`. In any mode it flushes a pending debounce.

`afterFirstUnfocus` is the "quiet at first, live once left" pattern: no error while the user types, the first unfocus after an edit validates, and from then on every edit does. Only an unfocus flips it; `validate()` from submit does not, and `reset()` flips it back.

## Built-in validators

Every string validator is `Validator<String?, E>`. `AdvancedTextFieldController` holds a non-nullable `String`. Assigning one built-in to `validator:` is fine; combining is where the `String?` shows up.

| Validator | `T` | Rejects |
| --- | --- | --- |
| `filled(e)` | `String?` | null, empty, whitespace-only |
| `notLongerThan(max, e)` | `String?` | `length > max` — `max` itself passes, null passes |
| `atLeastLength(min, e)` | `String?` | null, `length < min` — `min` itself passes |
| `exactly(s, e)` | `String?` | anything other than `s` |
| `nothing(e)` | `String?` | any non-empty string |
| `positiveInteger(e)` / `nonNegativeInteger(e)` | `String?` | null, non-numeric, and `<= 0` / `< 0` after `int.tryParse` |
| `positiveDecimal(e)` / `nonNegativeDecimal(e)` | `String?` | the same, with `double.tryParse` |
| `boundedNonNegativeInteger(max, e)` | `String?` | anything other than `0..max` or the literal string `>max` |
| `notNull(e)` | `T?` | null |
| `notEmpty(e)` | `List<T>?` | null or an empty list |
| `mustBeTrue(e)` | `bool?` | null or false |

`notEmpty` takes a `List`, so a `Set` gets a closure:

```dart
validator: mustBeTrue(MyError.mustAccept),
validator: (value) => value.isEmpty ? MyError.pickOne : null,
```

`conditionalValidator(v, () => enabled)` runs `v` only while the getter is true. `dynamicValidator(() => buildValidator())` rebuilds the validator on each call. Both keep `T`.

## Combining

`&` (all must pass) and `|` (one must pass) short-circuit; the left-most error wins. `and([...])` and `or([...])` take an optional shared error as their second argument.

Both sides share `T` and `E`. Built-ins are `String?`, so a custom string closure is annotated `String?` and then matches either side:

```dart
validator: filled(MyError.required) &
    ((String? value) =>
        (value?.contains('@') ?? false) ? null : MyError.invalidEmail),
```

`E` is inferred from the error value you pass. An enum infers the shared type. A sealed class does not: `filled(RequiredError())` infers `E = RequiredError`, and combining it with `notLongerThan(20, TooLongError())` fails. Pass the type argument:

```dart
validator: filled<MyError>(RequiredError()) &
    notLongerThan<MyError>(20, TooLongError()),
```

## Async validation

For a check that lives on the server, on any field controller, selects included. A verdict your own save call returns is a [server error](server.md) via `setError`, not `asyncValidation`.

```dart
final username = AdvancedTextFieldController(
  validator: filled(MyError.required),
  asyncValidation: AsyncValidation<String, MyError>(
    validator: (value) async =>
        await api.isTaken(value) ? MyError.taken : null,
    debounce: const Duration(milliseconds: 500), // default 300ms
    timeout: const Duration(seconds: 5), // default unbounded; bounds the run, not the debounce
    failureToError: (e, s) => MyError.checkFailed, // E? Function(Object, StackTrace)
    onFailure: (e, s) async => log(e), // omit it and failures go to
                                       // FlutterError.reportError. A throw from either
                                       // callback is reported there too, never rethrown.
  ),
);
```

- **Debounce** delays a round a keystroke started. It applies in `onUserInteraction`, and in `afterFirstUnfocus` once the field was first left. In `manual` and `onUnfocus` the check starts from `validate()` or from leaving the field, so `debounce` changes nothing.
- A value change cancels the in-flight round. A stale answer never lands.
- A settled answer is reused while the value is unchanged, so a second submit on an untouched form makes no network call. Any `setValue` drops the cached answer. When the check depends on state outside the value, invalidate with `field.clearErrors()`.
- `state.isPending` / `isValidating` / `isInProgress` — a spinner is `isInProgress`.
- `await form.validate()` waits for the answer instead of failing a busy field.

`conditionalValidator` is sync-only, and `AsyncValidation` has no skip flag. Guard inside the async validator: empty input returns `null` without calling the API. The round still starts (the field shows `validating` for a tick) and makes no request.

A validator that throws or times out is a fault. The field lands on `FieldStatus.failedValidation`, counts as not valid, and `validate()` returns `false`. `form.value.hasFailedValidation` drives one "could not verify, try again" banner. `failureToError` maps the fault to an error code and keeps `failedValidation`, so the field text and the banner show together. Omit it when the banner is enough. The next `validate()` retries, so submit is the retry — the button stays enabled through the failure ([submit](submit.md)). `field.lastFailure` is an `AsyncValidationFailure?` (`error`, `stackTrace`, `timedOut`), non-null only while the field is on `failedValidation`.
