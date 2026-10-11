# Cross-field

## A rule that reads another field

`subscribeToFields` re-runs **this** field's sync validator when the listed fields' values change. Nothing else. Async validators are not re-run — this field's own value did not change. Nothing happens while this field is `manual` or untouched. A second call replaces the subscription. Use `late final` when the closure reads a sibling:

```dart
final password = AdvancedTextFieldController(
  validator: atLeastLength(8, MyError.tooShort),
);

late final repeatPassword = AdvancedTextFieldController<MyError>(
  validator: (value) =>
      value == password.fieldValue ? null : MyError.doesNotMatch,
)..subscribeToFields([password]);
```

## A pair

One rule over two fields, either side able to break or fix it (`adults` + `children`, "book at least one person"). Wire both in the constructor body after `registerFields`:

```dart
adults.subscribeToFields([children]);
children.subscribeToFields([adults]);
```

A cascade `..subscribeToFields([sibling])` on a `late final` initializer reads the sibling eagerly, so a mutual pair overflows the stack at construction. A mutually-referencing `late final` pair also needs an explicit type, or the analyzer reports `top_level_cycle`.

The subscription re-runs only when a watched **value** changes, not when the sibling's error or status changes, so the pair cannot loop. The error appears only on a field whose own validator returns it — put the pair's rule in both validators. The subscriptions only re-run them.

The sibling still has to be edited and in an open mode. Touch `adults` and never `children`, and only `adults` lights up live. `children` shows its half at the first `validate()`. The modes will not show both halves before submit. Render the pair's message once, from the form, when the design needs that.

## An untouched field that must react

`subscribeToFields` follows the untouched rule, so it will not light up a prefilled instructor when the user changes the aircraft. Keep the rule in the instructor's validator. Call `validate()` on the dependent from a listener on the watched field. `validate()` ignores the untouched gate and the mode, and the sync result lands synchronously.

Compare the value yourself. A listener also fires on status changes:

```dart
var lastAircraft = aircraft.fieldValue;
aircraft.addListener(() {
  if (aircraft.fieldValue == lastAircraft) return;
  lastAircraft = aircraft.fieldValue;
  instructor.validate();
});
```

Place that after `registerFields`. Every call re-runs the sync validator against the current values, including when an earlier `validate()` is still in flight (a constructor that calls `validate()` so a fresh form shows its errors, then the first listener call).

`validate()` also runs `asyncValidation`. A field with a server check hits the server the first time the watched field changes; the verdict for its unchanged value is then reused. The whole validator runs, so an empty dependent with `notNull` shows "required" the moment its dependency moves — on a create screen, after a program write of the dependency, and after `resetAll()` when the dependent is registered before its dependency. It runs under `manual` too. Guard the listener when the screen wants something narrower.

## A value set from another field

Totals, mirroring, clearing a dependent selection: `addRelation(source, select, onChange)` in the constructor body after `registerFields`.

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

- `select` picks what to watch. `onChange` fires when that part changes, `==`-compared with the last seen value. A status-only change never fires it. A mutual pair of relations cannot loop.
- It does not fire at registration. Seed the initial state yourself immediately after, and give the target that derived value as its `initialValue:`. A value seeded after `registerFields` reports `wasModified: true` before any edit.
- A derived field is usually `markReadOnly()`, so `setValue` needs `force: true`.
- `source` may be any field controller, including one a subform owns. Two sources feeding one target are two `addRelation` calls.
- The form removes the listener in `dispose()`. Either side already disposed throws `StateError`.
- A destructive relation — `city.reset()` when `country` changes — is safe. `validate()` changes no values, so it cannot wipe the user's choice. Calling `addSubform` / `removeSubform` or `setValidationEnabled` from `onChange` is supported. A section that comes and goes with a switch is `addSubform(…, enabled:)` instead ([subforms](subforms.md)).

`addListener` plus `setValue` is for a target that is not a form field — a `ValueNotifier`, a service callback. Compare with `==` yourself, because `addListener` fires on any state change.

## Every field

`MyForm() : super(validateAll: true)` re-runs the sync validator on every field in the tree whose mode allows it, on any value change. Use it when most fields cross-validate. It is `revalidateSync()`, public on both the form and the field. Call it when something other than a field value must force a tree-wide sync pass — a locale switch, a feature-flag flip. No async check starts.
