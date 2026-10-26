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

/// How the last finished check on a field ended.
enum FieldVerdict {
  /// Every validator that ran passed.
  valid,

  /// A validator returned an error.
  invalid,

  /// The async validator threw or timed out.
  failed,
}

/// What a field remembers about the user and about finished checks, since
/// its last `reset()`.
///
/// Only settled facts get here. The `pending` status of a debounced round and
/// the errors an edit clears never do, so a mode that reads this cannot disarm
/// itself while the user fixes the value.
@immutable
final class FieldHistory {
  /// A history with the given counts and verdict.
  const FieldHistory({
    this.edits = 0,
    this.unfocuses = 0,
    this.validateCalls = 0,
    this.lastVerdict,
  });

  /// How many times the user edited the value.
  final int edits;

  /// How many times the user left the field after editing it.
  final int unfocuses;

  /// How many times `validate()` ran on the field. A form's `validate()`
  /// counts once for each of its fields.
  final int validateCalls;

  /// How the last finished check ended, or null when none has finished. An
  /// edit keeps it; `clearErrors()` and `prefill()` drop it.
  final FieldVerdict? lastVerdict;

  /// The user edited the field once more.
  @internal
  FieldHistory edited() => _copy(edits: edits + 1);

  /// The user left the field once more after editing it.
  @internal
  FieldHistory left() => _copy(unfocuses: unfocuses + 1);

  /// `validate()` ran once more.
  @internal
  FieldHistory validated() => _copy(validateCalls: validateCalls + 1);

  /// A check finished with [verdict], or a null [verdict] forgets the last one.
  @internal
  FieldHistory withVerdict(FieldVerdict? verdict) => FieldHistory(
        edits: edits,
        unfocuses: unfocuses,
        validateCalls: validateCalls,
        lastVerdict: verdict,
      );

  FieldHistory _copy({int? edits, int? unfocuses, int? validateCalls}) =>
      FieldHistory(
        edits: edits ?? this.edits,
        unfocuses: unfocuses ?? this.unfocuses,
        validateCalls: validateCalls ?? this.validateCalls,
        lastVerdict: lastVerdict,
      );
}

/// What a mode gets to see when it decides.
@immutable
final class ValidationContext {
  /// Describes [event] on a field with [history].
  const ValidationContext({
    required this.event,
    this.history = const FieldHistory(),
  });

  /// What is happening now.
  final ValidationEvent event;

  /// What happened to the field before [event].
  final FieldHistory history;
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
sealed class ValidationMode with Equatable {
  const ValidationMode();

  /// Nothing validates until `validate()` is called. The default.
  static const manual = ManualValidationMode();

  /// Every edit validates the field, the async check after its debounce.
  static const onUserInteraction = OnUserInteractionValidationMode();

  /// Leaving an edited field validates it.
  static const onUnfocus = OnUnfocusValidationMode();

  /// Like [onUnfocus] until the field is first left after an edit, like
  /// [onUserInteraction] from then on.
  static const afterFirstUnfocus = AfterFirstUnfocusValidationMode();

  /// What the field runs on [context].
  ValidationAction decide(ValidationContext context);

  /// Two modes of the same type are the same mode. A mode with fields lists
  /// them here, so two instances with different settings are not.
  @override
  List<Object?> get props => const [];
}

/// See [ValidationMode.manual].
final class ManualValidationMode extends ValidationMode {
  /// See [ValidationMode.manual].
  const ManualValidationMode();

  @override
  ValidationAction decide(ValidationContext context) => ValidationAction.none;
}

/// See [ValidationMode.onUserInteraction].
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
}

/// See [ValidationMode.onUnfocus].
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
}

/// See [ValidationMode.afterFirstUnfocus].
final class AfterFirstUnfocusValidationMode extends ValidationMode {
  /// See [ValidationMode.afterFirstUnfocus].
  const AfterFirstUnfocusValidationMode();

  @override
  ValidationAction decide(ValidationContext context) =>
      context.history.unfocuses > 0
          ? ValidationMode.onUserInteraction.decide(context)
          : ValidationMode.onUnfocus.decide(context);
}

/// Extend this for a mode of your own.
abstract class CustomValidationMode extends ValidationMode {
  /// Lets a subclass be `const`.
  const CustomValidationMode();
}
