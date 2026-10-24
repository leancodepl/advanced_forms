import 'package:meta/meta.dart';

/// What happened to a field, as its validation mode sees it.
enum ValidationEvent {
  /// The user edited the value.
  valueChanged,

  /// Focus left the field.
  unfocus,

  /// A field this one depends on changed, so only the sync validator is owed.
  dependencyChanged,
}

/// What a [ValidationStrategy] gets to see.
///
/// Deliberately no status and no errors: a debounced round overwrites the
/// status with `pending` and the write path clears both errors, so a strategy
/// reading either would disarm itself as the user started fixing the value.
@immutable
final class ValidationContext {
  /// Describes the [event] on a field the user has [hasUnfocused] or not.
  const ValidationContext({required this.event, required this.hasUnfocused});

  /// The event the field is asking about.
  final ValidationEvent event;

  /// The user has left the field after editing it. Only `reset()` clears it.
  final bool hasUnfocused;
}

/// Decides whether a field validates itself on an event, with nobody calling
/// `validate()`.
///
/// The field asks only once the user has edited it: an untouched field
/// validates nothing on its own under any strategy. `validate()` neither
/// consults nor changes the strategy.
abstract interface class ValidationStrategy {
  /// Whether the field should validate itself now.
  bool validatesOn(ValidationContext context);
}

/// The built-in strategies, plus [ValidationMode.custom] for one of your own.
///
/// Set it on the `AdvancedFormController` and it reaches every field and
/// subform.
///
/// | mode | valueChanged | unfocus | dependencyChanged |
/// |---|---|---|---|
/// | `manual` | — | — | — |
/// | `onUserInteraction` | validate | — | sync only |
/// | `onUnfocus` | — | validate | sync only |
/// | `afterFirstUnfocus`, not yet left | — | validate | sync only |
/// | `afterFirstUnfocus`, left once | validate | — | sync only |
@immutable
final class ValidationMode implements ValidationStrategy {
  const ValidationMode._(this.name, this._validatesOn);

  /// A strategy of your own. [name] is what `toString()` shows.
  ///
  /// Keep one instance per mode: `setValidationMode` with an equal mode leaves
  /// a round in flight alone, and two `custom` calls are never equal.
  factory ValidationMode.custom(
    String name,
    bool Function(ValidationContext context) validatesOn,
  ) =>
      ValidationMode._(name, validatesOn);

  /// Nothing validates until `validate()` is called. The default.
  static const manual = ValidationMode._('manual', _never);

  /// Every edit validates the field, the async check after its debounce.
  static const onUserInteraction =
      ValidationMode._('onUserInteraction', _onEdit);

  /// Leaving an edited field validates it; an unchanged value reuses its last
  /// answer. Requires a widget to bind the field's `focusNode`, or a call to
  /// `handleUnfocus()` — nothing validates in this mode otherwise.
  static const onUnfocus = ValidationMode._('onUnfocus', _onLeave);

  /// Quiet while the user types, like [onUnfocus], until the field first
  /// loses focus after an edit; from then on every edit validates it, like
  /// [onUserInteraction]. Needs the same `focusNode` binding or
  /// `handleUnfocus()` call as [onUnfocus]. `validate()` does not count as
  /// that first unfocus, and `reset()` makes the field wait for it again.
  static const afterFirstUnfocus =
      ValidationMode._('afterFirstUnfocus', _afterFirstLeave);

  /// The built-in modes, in the order above.
  static const values = <ValidationMode>[
    manual,
    onUserInteraction,
    onUnfocus,
    afterFirstUnfocus,
  ];

  /// The mode's name, as the enum member was called.
  final String name;

  final bool Function(ValidationContext context) _validatesOn;

  @override
  bool validatesOn(ValidationContext context) => _validatesOn(context);

  @override
  String toString() => 'ValidationMode.$name';

  static bool _never(ValidationContext _) => false;

  // The edit already validated, so unfocus has nothing left to run.
  static bool _onEdit(ValidationContext c) =>
      c.event != ValidationEvent.unfocus;

  // The value is still being typed, so an edit waits for the unfocus.
  static bool _onLeave(ValidationContext c) =>
      c.event != ValidationEvent.valueChanged;

  // The onUnfocus row until the field is first left, onUserInteraction after.
  static bool _afterFirstLeave(ValidationContext c) =>
      c.hasUnfocused ? _onEdit(c) : _onLeave(c);
}
