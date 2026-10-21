# Binding

`getValueSetter()` wherever the callback is a `ValueSetter<T>?` — `Switch.onChanged` takes it directly. Where the signature differs, pass `null` while read-only: `state.readOnly ? null : …`. On a text field, `readOnly: state.readOnly` blocks edits; `enabled: !state.readOnly` is what makes it look disabled.

`ErrorTranslator<E>` is `String Function(E)`. It takes a non-null `E`; `state.error` is `E?`, so promote first. One translator per enum is the start; pass a field-specific one where the wording differs ("Required" vs "Pick a country"). Wrap each binding in a widget that takes the field and an `ErrorTranslator<E>`.

```dart
String translate(MyError error) => switch (error) {
  MyError.required => 'Required',
  // …
};
```

## Dropdown

`DropdownButton` inside an `InputDecorator` is stable across supported SDKs. `DropdownButtonFormField`'s value parameter was renamed between versions.

```dart
AdvancedFieldBuilder<Country?, MyError>(
  field: form.country,
  builder: (context, state, _) {
    final error = state.error;
    return InputDecorator(
      decoration: InputDecoration(
        errorText: error == null ? null : translate(error),
      ),
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
```

## Slider, and any field that must take focus

Bind `field.focusNode` or `focus()` never lands. Whether the child paints a focus ring is the child's own behavior. `Slider` asserts `min <= value <= max` — cover the field's initial value.

```dart
AdvancedFieldBuilder<int, MyError>(
  field: form.rating,
  builder: (context, state, _) {
    final setter = form.rating.getValueSetter();
    return Focus(
      focusNode: form.rating.focusNode,
      child: InputDecorator(
        decoration: InputDecoration(
          errorText: state.error == null ? null : translate(state.error!),
        ),
        child: Slider(
          value: state.value.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: setter == null ? null : (v) => setter(v.round()),
        ),
      ),
    );
  },
)
```

## Checkbox, switch, chips

`Switch`, `CheckboxListTile`, and a `Wrap` of `FilterChip`s have no `errorText`. Render `state.error` yourself, or wrap them in an `InputDecorator` as above.

`CheckboxListTile.onChanged` is `ValueChanged<bool?>?`:

```dart
onChanged: setter == null ? null : (v) => setter(v ?? false),
```
