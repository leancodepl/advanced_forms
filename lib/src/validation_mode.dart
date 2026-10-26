import 'package:advanced_forms/src/field/advanced_field_state.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// What happened to a field, as its validation mode sees it.
enum ValidationEvent {
  /// The user edited the value.
  valueChanged,

  /// Focus left the field.
  unfocus,

  /// A field this one depends on changed.
  dependencyChanged,
}

/// What a mode gets to see when it decides.
///
/// Only settled facts get here. The `pending` status of a debounced round and
/// the errors an edit clears never do, so a mode that reads this cannot disarm
/// itself while the user fixes the value.
@immutable
final class ValidationContext {
  /// Describes [event] on a field with the given past.
  const ValidationContext({
    required this.event,
    this.everUnfocused = false,
    this.everValidated = false,
    this.lastStatus,
  });

  /// What is happening now.
  final ValidationEvent event;

  /// The user has left the field after editing it, at least once since
  /// `reset()`.
  final bool everUnfocused;

  /// `validate()` ran on the field at least once since `reset()`. A form's
  /// `validate()` counts for each of its fields.
  final bool everValidated;

  /// How the last finished check ended: [FieldStatus.valid],
  /// [FieldStatus.invalid] or [FieldStatus.failedValidation]. Never
  /// [FieldStatus.pending] or [FieldStatus.validating], and null when no check
  /// has finished. An edit keeps it; `clearErrors()`, `prefill()` and
  /// `reset()` drop it.
  final FieldStatus? lastStatus;
}

/// What a field runs on an event.
enum ValidationAction {
  /// Nothing. An edit still clears the errors: they described the old value.
  none,

  /// The sync validator only.
  sync,

  /// The sync validator, then the async one if sync passed. After an edit
  /// the async check waits out its debounce.
  full,
}

/// When a field validates itself, with nobody calling `validate()`.
///
/// Set it on the `AdvancedFormController` and it reaches every field and
/// subform. A field the user has never edited validates nothing on its own,
/// whatever the mode says, and `validate()` neither consults nor changes the
/// mode. One instance is shared by every field it reaches, so a mode keeps no
/// state of its own: what it knows about a field is in [ValidationContext].
///
/// Extend [CustomValidationMode] for a mode of your own.
sealed class ValidationMode with Equatable {
  const ValidationMode();

  /// Nothing validates until `validate()` is called. The default.
  static const manual = ManualValidationMode();

  /// Every edit validates the field, the async check after its debounce.
  static const onUserInteraction = OnUserInteractionValidationMode();

  /// Leaving an edited field validates it. Requires a widget to bind the
  /// field's `focusNode`, or a call to `handleUnfocus()` — nothing validates
  /// in this mode otherwise.
  static const onUnfocus = OnUnfocusValidationMode();

  /// Like [onUnfocus] until the field is first left after an edit, like
  /// [onUserInteraction] from then on. `validate()` does not count as that
  /// first unfocus, and `reset()` makes the field wait for it again.
  static const afterFirstUnfocus = AfterFirstUnfocusValidationMode();

  /// What the field runs on [context].
  ValidationAction decide(ValidationContext context);

  /// Two modes of the same type are the same mode. A mode with fields lists
  /// them here, so two instances with different settings are not.
  @override
  List<Object?> get props => const [];
}

/// The class behind [ValidationMode.manual].
final class ManualValidationMode extends ValidationMode {
  /// See [ValidationMode.manual].
  const ManualValidationMode();

  @override
  ValidationAction decide(ValidationContext context) => ValidationAction.none;

  @override
  String toString() => 'ValidationMode.manual';
}

/// The class behind [ValidationMode.onUserInteraction].
final class OnUserInteractionValidationMode extends ValidationMode {
  /// See [ValidationMode.onUserInteraction].
  const OnUserInteractionValidationMode();

  @override
  ValidationAction decide(ValidationContext context) => switch (context.event) {
        ValidationEvent.valueChanged => ValidationAction.full,
        // The edit already validated, so unfocus has nothing left to run.
        ValidationEvent.unfocus => ValidationAction.none,
        ValidationEvent.dependencyChanged => ValidationAction.sync,
      };

  @override
  String toString() => 'ValidationMode.onUserInteraction';
}

/// The class behind [ValidationMode.onUnfocus].
final class OnUnfocusValidationMode extends ValidationMode {
  /// See [ValidationMode.onUnfocus].
  const OnUnfocusValidationMode();

  @override
  ValidationAction decide(ValidationContext context) => switch (context.event) {
        // The value is still being typed, so an edit waits for the unfocus.
        ValidationEvent.valueChanged => ValidationAction.none,
        ValidationEvent.unfocus => ValidationAction.full,
        ValidationEvent.dependencyChanged => ValidationAction.sync,
      };

  @override
  String toString() => 'ValidationMode.onUnfocus';
}

/// The class behind [ValidationMode.afterFirstUnfocus].
final class AfterFirstUnfocusValidationMode extends ValidationMode {
  /// See [ValidationMode.afterFirstUnfocus].
  const AfterFirstUnfocusValidationMode();

  @override
  ValidationAction decide(ValidationContext context) => context.everUnfocused
      ? ValidationMode.onUserInteraction.decide(context)
      : ValidationMode.onUnfocus.decide(context);

  @override
  String toString() => 'ValidationMode.afterFirstUnfocus';
}

/// Extend this for a mode of your own.
///
/// Override [decide]. A mode with settings lists them in [props], so two
/// instances with different settings count as different modes.
abstract class CustomValidationMode extends ValidationMode {
  /// Lets a subclass be `const`.
  const CustomValidationMode();
}
