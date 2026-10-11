# Server errors, read-only, reset, prefill

```dart
field.setError(MyError.emailTaken); // status follows the code
field.setError(null);               // clears the sync slot
field.clearErrors();                // sync slot, async verdict, and lastFailure
field.markReadOnly();               // setValue is a no-op; validate() still runs
field.prefill(value);               // program write
field.reset();                      // back to initialValue; clears both errors,
                                    // the async verdict, and lastFailure; untouched
                                    // again. Works while read-only. Keeps readOnly
                                    // and validationMode — those are configuration.
form.markReadOnly();
form.clearErrors();
form.resetAll();
form.setValidationEnabled(false);   // this subtree stops validating and stops counting
```

Push server errors **after** the `await`. `validate()`, and anything else that re-runs the sync validator, overwrites a pushed code — which is also why a rejection clears itself on the next submit or edit. `setError` writes the sync slot only. A code an async round recorded survives it; `clearErrors()` wipes both.

`hasFailedValidation` clears on `setValue`, `prefill`, `clearErrors()`, `reset()`, `setError(null)`, or the next `validate()`. `markReadOnly()` keeps `failedValidation` (and drops `lastFailure`) so a frozen field still blocks submit.

## Errors that carry text

An enum cannot hold a message the server wrote. `E` only has to be non-nullable, so a sealed class works:

```dart
sealed class SignupError {}

class RequiredError implements SignupError {}

class ServerMessage implements SignupError {
  ServerMessage(this.message);
  final String message;
}

String translate(SignupError error) => switch (error) {
  RequiredError() => 'This field is required',
  ServerMessage(:final message) => message,
};

void applyServerErrors(Map<String, String> byFieldName) {
  // whereType, not cast: cast throws later on a field whose E widened to Object.
  final fields = value.allFields
      .whereType<AdvancedFieldController<dynamic, SignupError>>();
  for (final field in fields) {
    final message = byFieldName[field.name];
    field.setError(message == null ? null : ServerMessage(message));
  }
}
```

Give every field a `name:` when the server addresses fields by name. That loop clears every field the server omitted. That is right after a passing `validate()`: no rule errors remain, and the server is the authority. While the validators' own codes may still be on the fields, write only the named fields — a blanket `setError(null)` erases rule errors too.

## Prefilling an edit form

`prefill(value)` stores the value, clears both errors, validates nothing, and leaves the field untouched. It takes what the field holds: `V?` on a single select (`null` clears), a `Set<V>` on a multi-select.

`wasModified` is baselined at `registerFields`. A controller that registers and *then* prefills from a fetch reports `wasModified: true` forever. Either construct the fields with the loaded data as `initialValue:`, or call `registerFields` again with the **same** list once the data arrives.

Re-registering those same controllers is safe — the form drops its old listeners first and owns each field once — and it re-baselines **this** form only. Each subform keeps its own baseline and needs its own re-registration. `reset()` still returns to the constructor's `initialValue`, so a later `resetAll()` lands off the new baseline and `wasModified` flips back to true. Prefer `initialValue:` when the data exists before construction, or the form has a discard button.
