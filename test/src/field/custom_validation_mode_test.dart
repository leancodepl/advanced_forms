// Several tests build the same mode twice on purpose, as a build() method would.
// ignore_for_file: prefer_const_constructors

import 'package:advanced_forms/advanced_forms.dart';
import 'package:flutter_test/flutter_test.dart';

import 'field_test_helpers.dart';

// Quiet while typing until a check finds an error, then live until one passes.
final class LiveWhileInvalid extends CustomValidationMode {
  const LiveWhileInvalid();

  @override
  ValidationAction decide(ValidationContext context) => switch (context.event) {
        ValidationEvent.valueChanged =>
          context.lastStatus == FieldStatus.invalid
              ? ValidationAction.full
              : ValidationAction.none,
        ValidationEvent.unfocus => ValidationAction.full,
        ValidationEvent.dependencyChanged => ValidationAction.sync,
      };
}

// The format on every keystroke, the server only when the field is left.
final class SyncLiveAsyncOnLeave extends CustomValidationMode {
  const SyncLiveAsyncOnLeave();

  @override
  ValidationAction decide(ValidationContext context) => switch (context.event) {
        ValidationEvent.unfocus => ValidationAction.full,
        _ => ValidationAction.sync,
      };
}

// Quiet until the first submit, live after it.
final class LiveAfterSubmit extends CustomValidationMode {
  const LiveAfterSubmit();

  @override
  ValidationAction decide(ValidationContext context) => context.everValidated
      ? ValidationMode.onUserInteraction.decide(context)
      : ValidationAction.none;
}

final class _Spy extends CustomValidationMode {
  _Spy(this.seen);

  final List<(ValidationEvent, bool, bool, FieldStatus?)> seen;

  @override
  ValidationAction decide(ValidationContext context) {
    seen.add(
      (
        context.event,
        context.everUnfocused,
        context.everValidated,
        context.lastStatus,
      ),
    );
    return ValidationAction.sync;
  }
}

final class _OnEvents extends CustomValidationMode {
  const _OnEvents(this.events);

  final Set<ValidationEvent> events;

  @override
  ValidationAction decide(ValidationContext context) =>
      events.contains(context.event)
          ? ValidationAction.full
          : ValidationAction.none;

  @override
  List<Object?> get props => [events];
}

void main() {
  late TestField field;
  late ValidatorMock validator;

  setUp(() {
    validator = ValidatorMock();
    field = AdvancedFieldController<int, TestError>(
      initialValue: initialValue,
      validator: validator,
    );
  });

  tearDown(() => field.dispose());

  test('a mode sees the event and what happened before it', () async {
    final seen = <(ValidationEvent, bool, bool, FieldStatus?)>[];
    validator.validationResult = TestError.malformed;
    field
      ..setValidationMode(_Spy(seen))
      ..setValue(10);
    await field.validate();
    field.revalidateSync();
    await field.handleUnfocus();
    validator.validationResult = null;
    field.setValue(11);

    expect(seen, const [
      (ValidationEvent.valueChanged, false, false, null),
      (ValidationEvent.dependencyChanged, false, true, FieldStatus.invalid),
      (ValidationEvent.unfocus, false, true, FieldStatus.invalid),
      (ValidationEvent.valueChanged, true, true, FieldStatus.invalid),
    ]);
  });

  group('LiveWhileInvalid', () {
    setUp(() => field.setValidationMode(const LiveWhileInvalid()));

    test('typing is quiet until an error, live while fixing, quiet once fixed',
        () async {
      validator.validationResult = TestError.malformed;
      field.setValue(10);
      expect(field.value.error, isNull);

      await field.handleUnfocus();
      expect(field.value.error, TestError.malformed);

      field.setValue(11);
      expect(field.value.error, TestError.malformed);

      validator.validationResult = null;
      field.setValue(12);
      expect(field.value.error, isNull);

      validator.validationResult = TestError.malformed;
      field.setValue(13);
      expect(field.value.error, isNull);
    });

    test('a pending round does not disarm it', () async {
      var answer = TestError.unavailable as TestError?;
      final (:field, :validated) = makeAsyncField(
        mode: const LiveWhileInvalid(),
        result: () => answer,
      );
      addTearDown(field.dispose);

      field.setValue(10);
      await field.handleUnfocus();
      await pumpEventQueue();
      expect(field.value.error, TestError.unavailable);

      answer = null;
      field.setValue(11);
      expect(field.value.isPending, isTrue);
      field.setValue(12);
      expect(field.value.isPending, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(validated, [10, 12]);
      expect(field.value.isValid, isTrue);
    });
  });

  test('SyncLiveAsyncOnLeave: edits run the sync check only', () async {
    final syncErrors = <int>[];
    final (:field, :validated) = makeAsyncField(
      mode: const SyncLiveAsyncOnLeave(),
      validator: (value) {
        syncErrors.add(value);
        return null;
      },
    );
    addTearDown(field.dispose);

    field.setValue(10);
    expect(field.value.isPending, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(syncErrors, [10]);
    expect(validated, isEmpty);

    await field.handleUnfocus();
    await pumpEventQueue();
    expect(validated, [10]);
  });

  group('LiveAfterSubmit', () {
    setUp(() => field.setValidationMode(const LiveAfterSubmit()));

    test('edits are quiet until validate(), live after it', () async {
      validator.validationResult = TestError.malformed;
      field.setValue(10);
      expect(field.value.error, isNull);

      expect(await field.validate(), isFalse);
      validator.validationResult = null;
      field.setValue(11);
      expect(field.value.error, isNull);
      validator.validationResult = TestError.malformed;
      field.setValue(12);

      expect(field.value.error, TestError.malformed);
    });

    test('reset() makes it wait for a new submit', () async {
      validator.validationResult = TestError.malformed;
      field.setValue(10);
      await field.validate();

      field
        ..reset()
        ..setValue(11);

      expect(field.value.error, isNull);
    });

    test('a form submit counts for every field', () async {
      final inner = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: (_) => TestError.malformed,
      );
      final form = AdvancedFormController(
        validationMode: const LiveAfterSubmit(),
      )..registerFields([inner]);
      addTearDown(form.dispose);

      await form.validate();
      inner
        ..clearErrors()
        ..setValue(10);

      expect(inner.value.error, TestError.malformed);
    });
  });

  test('an untouched field stays quiet whatever the mode says', () {
    validator.validationResult = TestError.malformed;
    field
      ..setValidationMode(const _OnEvents({ValidationEvent.dependencyChanged}))
      ..revalidateSync();

    expect(field.value.error, isNull);
  });

  test('the type and the props identify a mode', () {
    expect(LiveAfterSubmit(), LiveAfterSubmit());
    expect(LiveAfterSubmit(), isNot(LiveWhileInvalid()));
    expect(LiveAfterSubmit(), isNot(ValidationMode.manual));
    expect(
      _OnEvents({ValidationEvent.unfocus}),
      _OnEvents({ValidationEvent.unfocus}),
    );
    expect(
      _OnEvents({ValidationEvent.unfocus}),
      isNot(_OnEvents({ValidationEvent.valueChanged})),
    );
  });

  test('a new instance of the same mode leaves a round in flight alone',
      () async {
    final (:field, :validated) = makeAsyncField(mode: LiveAfterSubmit());
    addTearDown(field.dispose);
    await field.validate();
    await pumpEventQueue();

    field
      ..setValue(10)
      ..setValidationMode(LiveAfterSubmit());

    expect(field.value.isPending, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(validated, [initialValue, 10]);
  });

  test('a switch over the modes is exhaustive with one custom case', () {
    String label(ValidationMode mode) => switch (mode) {
          ManualValidationMode() => 'on submit',
          OnUserInteractionValidationMode() => 'live',
          OnUnfocusValidationMode() => 'on leave',
          AfterFirstUnfocusValidationMode() => 'live after leave',
          CustomValidationMode() => 'custom',
        };

    expect(label(ValidationMode.onUnfocus), 'on leave');
    expect(label(const LiveAfterSubmit()), 'custom');
  });
}
