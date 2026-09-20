import 'package:advanced_forms/advanced_forms.dart';
import 'package:flutter_test/flutter_test.dart';

import 'field_test_helpers.dart';

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

  group('subscribeToFields', () {
    test('throws StateError when this field has been disposed', () {
      final observed = AdvancedFieldController<int, TestError>(initialValue: 0);
      addTearDown(observed.dispose);
      var validatorCalls = 0;
      final field = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: (_) {
          validatorCalls++;
          return null;
        },
      )
        ..setValidationMode(ValidationMode.onUserInteraction)
        ..dispose();

      expect(() => field.subscribeToFields([observed]), throwsStateError);

      // The guard is what keeps the listener off the live field.
      observed.setValue(10);

      expect(validatorCalls, 0);
    });

    test('drops the subscription on dispose', () {
      final observed = AdvancedFieldController<int, TestError>(initialValue: 0);
      addTearDown(observed.dispose);
      var validatorCalls = 0;
      final field = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: (_) {
          validatorCalls++;
          return null;
        },
      )
        ..setValidationMode(ValidationMode.onUserInteraction)
        // The guarantee: only a field the user has edited revalidates.
        ..setValue(0)
        ..subscribeToFields([observed]);
      validatorCalls = 0;

      observed.setValue(10);

      expect(validatorCalls, 1);

      field.dispose();
      observed.setValue(20);

      expect(validatorCalls, 1);
    });

    test('re-runs the sync validator when a subscribed field changes',
        () async {
      final field2 = AdvancedFieldController<int, TestError>(initialValue: 0);
      final field1 = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: validator,
      )
        ..setValidationMode(ValidationMode.onUserInteraction)
        // The guarantee: only a field the user has edited revalidates.
        ..setValue(0)
        ..subscribeToFields([field2]);
      addTearDown(field1.dispose);
      addTearDown(field2.dispose);
      validator.validationResult = TestError.malformed;

      field2.setValue(10);
      await pumpEventQueue();

      expect(field1.value.error, TestError.malformed);
    });

    test('does not re-run the async validator: this field did not change',
        () async {
      final field2 = AdvancedFieldController<int, TestError>(initialValue: 0);
      addTearDown(field2.dispose);
      final (:field, :validated) = makeAsyncField();
      addTearDown(field.dispose);
      field.subscribeToFields([field2]);

      field2.setValue(10);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(validated, isEmpty);
      expect(field.value.isValid, isTrue);
    });

    test('does nothing in manual mode, including clearing errors', () async {
      final field2 = AdvancedFieldController<int, TestError>(initialValue: 0);
      final field1 = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: validator,
      )..subscribeToFields([field2]);
      addTearDown(field1.dispose);
      addTearDown(field2.dispose);

      field1.setError(TestError.valueRequired);

      field2.setValue(10);
      await pumpEventQueue();

      expect(field1.value.error, TestError.valueRequired);
    });

    test('changing the mode does not validate immediately', () async {
      validator.validationResult = TestError.malformed;
      final field2 = AdvancedFieldController<int, TestError>(initialValue: 0);
      final field1 = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: validator,
      )..subscribeToFields([field2]);
      addTearDown(field1.dispose);
      addTearDown(field2.dispose);

      field1.setValidationMode(ValidationMode.onUserInteraction);
      await pumpEventQueue();

      expect(field1.value.error, isNull);
      expect(field1.value.isValid, isTrue);
    });
  });

  group('markInteracted', () {
    late TestField dependency;
    late TestField dependent;

    setUp(() {
      dependency = AdvancedFieldController<int, TestError>(initialValue: 0);
      dependent = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: validator,
      )
        ..setValidationMode(ValidationMode.onUserInteraction)
        ..subscribeToFields([dependency]);
      validator.validationResult = TestError.malformed;
    });

    tearDown(() {
      dependent.dispose();
      dependency.dispose();
    });

    test('a dependency change never reaches an untouched field', () async {
      dependency.setValue(10);
      await pumpEventQueue();

      expect(dependent.hasInteracted, isFalse);
      expect(dependent.value.error, isNull);
    });

    test('after it, a dependency change reaches the field', () async {
      dependent.markInteracted();
      validator.validationResult = TestError.valueRequired;

      dependency.setValue(10);
      await pumpEventQueue();

      expect(dependent.value.error, TestError.valueRequired);
    });

    test('runs the sync validator at once, keeping the value', () {
      dependent
        ..prefill(7)
        ..markInteracted();

      expect(dependent.hasInteracted, isTrue);
      expect(dependent.fieldValue, 7);
      expect(dependent.value.error, TestError.malformed);
    });

    test('does not start an async round: the value did not change', () async {
      final (:field, :validated) = makeAsyncField();
      addTearDown(field.dispose);

      field.markInteracted();
      await pumpEventQueue();

      expect(field.hasInteracted, isTrue);
      expect(validated, isEmpty);
    });

    test('marks the field but validates nothing in manual mode', () async {
      dependent
        ..setValidationMode(ValidationMode.manual)
        ..markInteracted();
      dependency.setValue(10);
      await pumpEventQueue();

      expect(dependent.hasInteracted, isTrue);
      expect(dependent.value.error, isNull);
    });

    test('reset makes the field untouched again', () async {
      dependent
        ..markInteracted()
        ..reset();

      dependency.setValue(10);
      await pumpEventQueue();

      expect(dependent.hasInteracted, isFalse);
      expect(dependent.value.error, isNull);
    });

    test('throws StateError when the field has been disposed', () {
      final disposed = AdvancedFieldController<int, TestError>(initialValue: 0)
        ..dispose();

      expect(disposed.markInteracted, throwsStateError);
    });
  });

  group('hasInteracted', () {
    test('follows setValue and reset, and ignores prefill', () {
      expect(field.hasInteracted, isFalse);

      field.prefill(1);
      expect(field.hasInteracted, isFalse);

      field.setValue(2);
      expect(field.hasInteracted, isTrue);

      field.reset();
      expect(field.hasInteracted, isFalse);
    });
  });
}
