import 'package:meta/meta.dart';

/// When a field validates itself, with nobody calling `validate()`.
///
/// Set it on the `AdvancedFormController` and it reaches every field and
/// subform. `validate()` neither consults nor changes it, and in every mode a
/// field the user has never edited validates nothing on its own.
enum ValidationMode {
  /// Nothing validates until `validate()` is called. The default.
  manual,

  /// Every edit validates the field, the async check after its debounce.
  onUserInteraction,

  /// Leaving an edited field validates it; an unchanged value reuses its last
  /// answer. Requires a widget to bind the field's `focusNode`, or a call to
  /// `handleUnfocus()` — nothing validates in this mode otherwise.
  onUnfocus,

  /// Quiet while the user types, like [onUnfocus], until the field first
  /// loses focus after an edit; from then on every edit validates it, like
  /// [onUserInteraction]. Needs the same `focusNode` binding or
  /// `handleUnfocus()` call as [onUnfocus]. `validate()` does not count as
  /// that first unfocus, and `reset()` makes the field wait for it again.
  afterFirstUnfocus,
}

@internal
enum ValidationEvent {
  valueChanged,
  unfocus,

  /// A field this one depends on changed, so only the sync validator is owed.
  dependencyChanged,
}

/// The one place that decides whether a field validates itself.
///
/// | mode | valueChanged | unfocus | dependencyChanged |
/// |---|---|---|---|
/// | `manual` | — | — | — |
/// | `onUserInteraction` | validate | — | sync only |
/// | `onUnfocus` | — | validate | sync only |
/// | `afterFirstUnfocus`, not yet left | — | validate | sync only |
/// | `afterFirstUnfocus`, left once | validate | — | sync only |
///
/// Reads no field status on purpose: a debounced round overwrites the status
/// with `pending` and the write path clears both errors, so a status check
/// would disarm itself as the user started fixing the value. `hasUnfocused`
/// is not a status: it is set by an event and only `reset()` clears it.
@internal
bool validatesOn(
  ValidationEvent event, {
  required ValidationMode mode,
  required bool hasInteracted,
  required bool hasUnfocused,
}) =>
    // Checked before the mode, so an untouched field stays quiet in all four.
    hasInteracted &&
    switch (mode) {
      ValidationMode.manual => false,
      // The edit already validated, so unfocus has nothing left to run.
      ValidationMode.onUserInteraction => event != ValidationEvent.unfocus,
      // The value is still being typed, so an edit waits for the unfocus.
      ValidationMode.onUnfocus => event != ValidationEvent.valueChanged,
      // The onUnfocus row until the field is first left, the
      // onUserInteraction row after that.
      ValidationMode.afterFirstUnfocus => hasUnfocused
          ? event != ValidationEvent.unfocus
          : event != ValidationEvent.valueChanged,
    };
