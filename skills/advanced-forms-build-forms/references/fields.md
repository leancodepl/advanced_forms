# Fields

## Controllers

Shared constructor arguments: `validator`, `asyncValidation`, `focusNode`, `name`.

Also on every controller: `reset`, `prefill`, `markReadOnly` / `unmarkReadOnly`, `setError`, `clearErrors`, `setValidationMode`, `validate`, `subscribeToFields`, `revalidateSync`, `focus`, `handleUnfocus`, `getValueSetter`. Getters: `fieldValue`, `error`, `name`, `lastFailure`, `isDisposed`.

`getValueSetter()` returns `ValueSetter<T>?`, `null` while read-only, so a widget with a nullable `onChanged` disables itself.

`name` is a `String?`. It labels the field in package error reports and on the `FocusNode`, and it keys error summaries and server-error maps.

`focusNode` exists on every controller. Omit it and the field creates and owns the node. Pass `focusNode:` to keep one you own; the field never disposes that one. `focus()` moves focus only when some widget binds `field.focusNode` — a `TextField`, or a `Focus` / `FocusableActionDetector` around a slider, chip group, or dropdown. With nothing bound, `focus()` is a no-op, which is why "focus the first invalid field" seems to do nothing on non-text fields. Widget patterns: [binding](binding.md).

### Text

`AdvancedTextFieldController<E>({String initialValue = '', ...})` owns `textController`.

Transform-as-you-type (normalize, mask, uppercase): subclass and override `setValue`. Every write through `textController` — keystroke, paste, programmatic `.text =` — calls `setValue`, and the transformed value is written back with the caret kept on the same characters.

Three writes bypass `setValue` and need the same transform: the constructor's `initialValue`, `reset()` (it returns to that normalized value), and `prefill()`. Forward everything you do not transform as a super-parameter. `initialValue` cannot, because it goes through the transform first, so it is an explicit `super(...)` argument.

```dart
class PhoneFieldController<E extends Object>
    extends AdvancedTextFieldController<E> {
  PhoneFieldController({
    String initialValue = '',
    super.validator,
    super.asyncValidation,
    super.focusNode,
    super.name,
  }) : super(initialValue: _digits(initialValue));

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  void setValue(String newValue, {bool force = false}) =>
      super.setValue(_digits(newValue), force: force);
}
```

Override signatures: `void setValue(T newValue, {bool force = false})`, `void prefill(T newValue, {bool force = false})`.

### Selects

`V` is unbounded. `options` is a non-nullable `List<V>`. Only the single select's `initialValue` is nullable. A required dropdown is `initialValue: null` plus `validator: notNull(MyError.required)`.

- `AdvancedSingleSelectFieldController<V, E>({required V? initialValue, required List<V> options, ...})` — `select(V?)`; `null` clears.
- `AdvancedMultiSelectFieldController<V, E>({required Set<V> initialValue, required List<V> options, ...})`.

`select`, `addValue`, and `toggleElement` (when it adds) assert the value is in `options`. `prefill` does not — check server-supplied values before writing them.

Both copy `options`, and the multi-select copies the set. Later mutations of those collections never reach the field. `const {}` is a `Map`. An empty selection is `const <Topping>{}`.

`setOptions(newList)` swaps the list. A selected value missing from the new list is cleared (dropped, on the multi-select) as a program write: an untouched field stays untouched, an edited field shows its `notNull` error at once, and a read-only field is cleared too. Widgets rebuild even when the value stayed. Membership is `==`. A server copy of an option is not the instance on the list — use a value type, or resolve by id.

Options that follow another field or a request:

```dart
aircraft.addListener(
  () => instructor.setOptions(instructorsFor(aircraft.fieldValue)),
);
```

### Any other value

`AdvancedFieldController<T, E>` is concrete. Use it for a slider, stepper, rating, or derived total:

```dart
AdvancedFieldController<int, MyError>(initialValue: 0, name: 'total');
```

Full constructor: `{required T initialValue, Validator<T, E>? validator, AsyncValidation<T, E>? asyncValidation, FocusNode? focusNode, String? name}`. Ordinary writes omit `force:`. `force: true` writes through `markReadOnly()`.

## Field state

`AdvancedFieldBuilder` hands you `AdvancedFieldState<T, E>`. `field.value` is that object. State is value-equal, so a no-op write notifies nobody.

| Member | Meaning |
| --- | --- |
| `value` | current value — `field.fieldValue` is the shortcut |
| `error` | `validationError ?? asyncError` — `field.error` is the shortcut |
| `validationError` / `asyncError` | sync path (validator or `setError`) / async round |
| `status` | `FieldStatus.valid`, `invalid`, `pending`, `validating`, `failedValidation` |
| `isValid` / `isInvalid` | status is `valid` / `invalid`. `valid` means no error is recorded, including before any check |
| `isPending` / `isValidating` / `isInProgress` | waiting out the debounce / request in flight / either |
| `isFailedValidation` | the async validator threw or timed out |
| `readOnly` | `setValue` is a no-op unless `force: true` |
| `validationMode` | the **effective** mode — a field whose form has validation switched off reports `manual` |
