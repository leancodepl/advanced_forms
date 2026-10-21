# Subforms

Subform fields join the parent's `validate`, `markReadOnly`, `resetAll`, `wasModified`, and the rest while attached.

Leave disposal to the parent. A detached subform stays owned, so the same controller can be re-attached; disposing it yourself makes the parent skip it. Ownership starts at `addSubform` — a subform constructed and never attached is never disposed. A section that starts hidden is still attached once at construction (then switched off, or detached immediately), or you dispose it.

## Attached while a field says so

```dart
class CheckoutFormController extends AdvancedFormController {
  CheckoutFormController() {
    registerFields([email, sameAsBilling]);
    addSubform(shipping, enabled: () => !sameAsBilling.fieldValue);
  }

  final email = AdvancedTextFieldController(validator: filled(MyError.required));
  final sameAsBilling = AdvancedBooleanFieldController<MyError>();
  final shipping = ShippingFormController();
}
```

The closure runs at `addSubform` and again after every value change in this form's tree. True attaches the section. False detaches it, same as `removeSubform`: out of `validate`, `canSubmit`, `getFieldValues`, `allFields`, and every broadcast. The form owns it either way. Values stay in its fields and return when the switch flips; errors are cleared on the way out. It is disposed with the form.

The closure is any boolean over the fields' values. `resetAll()` re-runs it, so a reset switch takes the section with it. The switch is this closure. A condition outside the form (a service, a route argument) is not re-evaluated — attach and detach by hand.

`enabled:` when the decision is a function of the form's own values. The two calls by hand when it comes from outside. The last hand call wins: `removeSubform` detaches and drops the condition (the section stays out until the next `addSubform`); a plain `addSubform` attaches it for good; `addSubform` with a new `enabled:` replaces the condition.

## Attached, validation off

Detached, a section is out of reach of `resetAll`, `markReadOnly`, `clearErrors`, and `setValidationMode`, and its values are absent from `getFieldValues()`. When those must still reach a section that merely does not apply, keep it attached and switch validation off:

```dart
addSubform(invoice);
addRelation(needsInvoice, (on) => on, invoice.setValidationEnabled);
invoice.setValidationEnabled(needsInvoice.fieldValue);
```

`addRelation` fires on change only, so the line after it seeds the initial state.

A switched-off subtree stops counting. It validates nothing, its `validate()` returns `true` without running, and its fields leave `canSubmit`, `validating`, `hasFailedValidation`, and `validationErrors`. Switching off clears the subtree's errors and leaves every value. Switching back on re-runs the sync validators, still subject to the mode and the untouched rule, so a field the user never edited stays quiet.

`validationEnabled` starts `true`. Only `setValidationEnabled` writes it — `resetAll()` leaves it alone — so seed it at construction and again in whatever method calls `resetAll()`. It composes with a parent switch by AND, so a section that opted out stays out. `wasModified` still reports a switched-off subform's modifications.

## Attach and detach by hand

```dart
void enableGift() => addSubform(gift);
void disableGift() => removeSubform(gift); // detaches only — gift is not disposed
```

- A detached subform is out of `validate`, `resetAll`, `markReadOnly`, `clearErrors`, `setValidationMode`, and the parent's aggregates.
- A subform attached after the first `validate()` matches one attached at build. The mode is broadcast on attach. `validate()` changes nothing about that.
- A subform with its own `validationMode:` keeps it and stops following the parent.
- `addSubform` is a no-op when already attached, `removeSubform` when not.

## Wizard

One subform per step. `await step.validate()` reaches that step and nothing later, so a later step is never flagged early. The final submit calls the parent's `validate()`, which walks every attached subform.

```dart
Future<bool> next() async {
  final step = currentStep;
  if (!await step.validate()) {
    step.setValidationMode(ValidationMode.onUserInteraction);
    return false;
  }
  _goTo(currentIndex + 1);
  return true;
}
```

After a failed `next()`, the step's own mode wins over the parent's, so later steps stay quiet while this step corrects itself as the user types.

Which step is on screen is navigation, kept on a controller created above the pages. A wizard controller built inside a step page dies with that page and takes the step's values and errors with it. A conditional step is the switched subform above.
