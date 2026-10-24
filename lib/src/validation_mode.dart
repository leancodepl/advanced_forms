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

/// What a custom mode gets to see.
///
/// No status and no errors, on purpose: every edit clears the errors and a
/// debounced round sets the status to `pending`, so a mode reading either
/// would disarm itself as the user started fixing the value.
@immutable
final class ValidationContext {
  /// Describes [event] on a field the user has left before, or not.
  const ValidationContext({required this.event, required this.everUnfocused});

  /// What is happening now.
  final ValidationEvent event;

  /// The user has left the field after editing it, at least once. Only
  /// `reset()` clears it.
  final bool everUnfocused;
}

/// When a field validates itself, with nobody calling `validate()`.
///
/// Set it on the `AdvancedFormController` and it reaches every field and
/// subform. In every mode, your own included, a field the user has never
/// edited validates nothing on its own, and `validate()` neither consults nor
/// changes the mode.
///
/// | mode | valueChanged | unfocus | dependencyChanged |
/// |---|---|---|---|
/// | `manual` | — | — | — |
/// | `onUserInteraction` | validate | — | sync only |
/// | `onUnfocus` | — | validate | sync only |
/// | `afterFirstUnfocus`, not yet left | — | validate | sync only |
/// | `afterFirstUnfocus`, left once | validate | — | sync only |
@immutable
final class ValidationMode {
  const ValidationMode._(this.name, this._shouldValidate);

  /// A mode of your own. A built-in [name] throws.
  factory ValidationMode.custom(
    String name,
    bool Function(ValidationContext context) shouldValidate,
  ) {
    if (_builtIn.any((mode) => mode.name == name)) {
      throw ArgumentError.value(name, 'name', 'is a built-in mode');
    }
    return ValidationMode._(name, shouldValidate);
  }

  /// Nothing validates until `validate()` is called. The default.
  static const manual = ValidationMode._('manual', _manual);

  /// Every edit validates the field, the async check after its debounce.
  static const onUserInteraction =
      ValidationMode._('onUserInteraction', _onUserInteraction);

  /// Leaving an edited field validates it; an unchanged value reuses its last
  /// answer. Requires a widget to bind the field's `focusNode`, or a call to
  /// `handleUnfocus()` — nothing validates in this mode otherwise.
  static const onUnfocus = ValidationMode._('onUnfocus', _onUnfocus);

  /// Quiet while the user types, like [onUnfocus], until the field first
  /// loses focus after an edit; from then on every edit validates it, like
  /// [onUserInteraction]. Needs the same `focusNode` binding or
  /// `handleUnfocus()` call as [onUnfocus]. `validate()` does not count as
  /// that first unfocus, and `reset()` makes the field wait for it again.
  static const afterFirstUnfocus =
      ValidationMode._('afterFirstUnfocus', _afterFirstUnfocus);

  static const _builtIn = [
    manual,
    onUserInteraction,
    onUnfocus,
    afterFirstUnfocus,
  ];

  /// Identifies the mode: two modes are equal when their names are equal, so
  /// a name must be unique across your app. The built-in names are `manual`,
  /// `onUserInteraction`, `onUnfocus` and `afterFirstUnfocus`.
  final String name;

  final bool Function(ValidationContext context) _shouldValidate;

  /// Whether the field should validate itself on [context].
  bool shouldValidate(ValidationContext context) => _shouldValidate(context);

  @override
  bool operator ==(Object other) =>
      other is ValidationMode && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ValidationMode.$name';

  static bool _manual(ValidationContext _) => false;

  // The edit already validated, so unfocus has nothing left to run.
  static bool _onUserInteraction(ValidationContext c) =>
      c.event != ValidationEvent.unfocus;

  // The value is still being typed, so an edit waits for the unfocus.
  static bool _onUnfocus(ValidationContext c) =>
      c.event != ValidationEvent.valueChanged;

  // The onUnfocus row until the field is first left, onUserInteraction after.
  static bool _afterFirstUnfocus(ValidationContext c) =>
      c.everUnfocused ? _onUserInteraction(c) : _onUnfocus(c);
}
