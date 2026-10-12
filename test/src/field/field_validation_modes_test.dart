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

  group('validation modes', () {
    /// Drives [event] on a field the user has already edited, and reports
    /// whether the field validated itself. With [leftOnce] the user has also
    /// left the field once before.
    bool validates(ValidationMode mode, String event, {bool leftOnce = false}) {
      var calls = 0;
      final subject = AdvancedFieldController<int, TestError>(
        initialValue: 0,
        validator: (_) {
          calls++;
          return null;
        },
      )
        ..setValidationMode(mode)
        // Every row assumes the guarantee is already satisfied; the guarantee
        // itself is pinned by its own group.
        ..setValue(1);
      addTearDown(subject.dispose);
      if (leftOnce) {
        subject.handleUnfocus();
      }
      calls = 0;

      switch (event) {
        case 'a value change':
          subject.setValue(2);
        case 'an unfocus':
          subject.handleUnfocus();
        case 'a dependency change':
          subject.revalidateSync();
      }

      return calls > 0;
    }

    // One cell of the gate table per line, so a regression names the cell.
    const table = <(ValidationMode, String, bool)>[
      (ValidationMode.manual, 'a value change', false),
      (ValidationMode.manual, 'an unfocus', false),
      (ValidationMode.manual, 'a dependency change', false),
      (ValidationMode.onUserInteraction, 'a value change', true),
      (ValidationMode.onUserInteraction, 'an unfocus', false),
      (ValidationMode.onUserInteraction, 'a dependency change', true),
      (ValidationMode.onUnfocus, 'a value change', false),
      (ValidationMode.onUnfocus, 'an unfocus', true),
      (ValidationMode.onUnfocus, 'a dependency change', true),
      (ValidationMode.afterFirstUnfocus, 'a value change', false),
      (ValidationMode.afterFirstUnfocus, 'an unfocus', true),
      (ValidationMode.afterFirstUnfocus, 'a dependency change', true),
    ];

    for (final (mode, event, expected) in table) {
      test(
        '${mode.name}: $event ${expected ? 'validates' : 'validates nothing'}',
        () => expect(validates(mode, event), expected),
      );
    }

    // The same cells once the user has left the field.
    const leftOnceTable = <(ValidationMode, String, bool)>[
      (ValidationMode.afterFirstUnfocus, 'a value change', true),
      (ValidationMode.afterFirstUnfocus, 'an unfocus', false),
      (ValidationMode.afterFirstUnfocus, 'a dependency change', true),
      (ValidationMode.onUnfocus, 'a value change', false),
      (ValidationMode.onUserInteraction, 'an unfocus', false),
    ];

    for (final (mode, event, expected) in leftOnceTable) {
      test(
        '${mode.name}, left once: $event '
        '${expected ? 'validates' : 'validates nothing'}',
        () => expect(validates(mode, event, leftOnce: true), expected),
      );
    }

    test('manual still clears the error an edit made stale', () {
      field
        ..setValidationMode(ValidationMode.manual)
        ..setError(TestError.valueRequired);
      validator.validationResult = TestError.malformed;

      field.setValue(10);

      expect(field.value.error, isNull);
      expect(field.value.isValid, isTrue);
    });

    test('changing the mode validates nothing by itself', () {
      validator.validationResult = TestError.malformed;
      field.setValue(10);
      final emissions = recordStates(field);

      field.setValidationMode(ValidationMode.onUserInteraction);

      expect(emissions, const [
        TestState(value: 10, validationMode: ValidationMode.onUserInteraction),
      ]);
    });

    test('changing the mode drops a round the old mode started', () async {
      final (:field, :validated) = makeAsyncField();
      addTearDown(field.dispose);

      field
        ..setValue(10)
        ..setValidationMode(ValidationMode.manual);

      expect(field.value.isPending, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(validated, isEmpty);
    });

    test('re-applying the same mode leaves a round in flight alone', () async {
      final (:field, :validated) = makeAsyncField();
      addTearDown(field.dispose);

      field
        ..setValue(10)
        ..setValidationMode(ValidationMode.onUserInteraction);

      expect(field.value.isPending, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(validated, [10]);
    });

    test('validate ignores the mode and leaves it alone', () async {
      validator.validationResult = TestError.malformed;
      field.setValidationMode(ValidationMode.manual);

      expect(await field.validate(), isFalse);
      expect(field.value.error, TestError.malformed);
      expect(field.value.validationMode, ValidationMode.manual);
    });
  });

  group('afterFirstUnfocus', () {
    setUp(() => field.setValidationMode(ValidationMode.afterFirstUnfocus));

    test('typing stays quiet until the field is left, then every edit shows',
        () async {
      validator.validationResult = TestError.malformed;

      field.setValue(10);
      expect(field.value.error, isNull);

      await field.handleUnfocus();
      expect(field.value.error, TestError.malformed);

      validator.validationResult = null;
      field.setValue(11);
      expect(field.value.error, isNull);

      validator.validationResult = TestError.malformed;
      field.setValue(12);
      expect(field.value.error, TestError.malformed);
    });

    test('validate() does not stand in for the first unfocus', () async {
      validator.validationResult = TestError.malformed;
      field.setValue(10);

      expect(await field.validate(), isFalse);
      field.setValue(11);

      expect(field.value.error, isNull);
    });

    test('leaving the field untouched does not count', () async {
      validator.validationResult = TestError.malformed;

      await field.handleUnfocus();
      field.setValue(10);

      expect(field.value.error, isNull);
    });

    test('reset() makes the field wait for its first unfocus again', () async {
      validator.validationResult = TestError.malformed;
      field.setValue(10);
      await field.handleUnfocus();

      field
        ..reset()
        ..setValue(11);

      expect(field.value.error, isNull);
    });

    test('a field left under another mode is already past its first unfocus',
        () async {
      validator.validationResult = TestError.malformed;
      field
        ..setValidationMode(ValidationMode.manual)
        ..setValue(10);
      await field.handleUnfocus();
      expect(field.value.error, isNull);

      field
        ..setValidationMode(ValidationMode.afterFirstUnfocus)
        ..setValue(11);

      expect(field.value.error, TestError.malformed);
    });

    test('an edit after the first unfocus debounces the async check', () async {
      final (:field, :validated) = makeAsyncField();
      addTearDown(field.dispose);
      field
        ..setValidationMode(ValidationMode.afterFirstUnfocus)
        ..setValue(10);
      await field.handleUnfocus();
      await pumpEventQueue();

      field.setValue(11);
      expect(field.value.isPending, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(validated, [10, 11]);
    });
  });

  group('the interaction guarantee', () {
    for (final mode in ValidationMode.values) {
      test(
          '${mode.name}: an untouched field validates nothing on a dependency '
          'change', () {
        validator.validationResult = TestError.malformed;
        field
          ..setValidationMode(mode)
          ..revalidateSync();

        expect(field.value.error, isNull);
      });

      test('${mode.name}: an untouched field validates nothing on an unfocus',
          () async {
        validator.validationResult = TestError.malformed;
        field.setValidationMode(mode);
        await field.handleUnfocus();
        await pumpEventQueue();

        expect(field.value.error, isNull);
      });

      test('${mode.name}: validate still checks an untouched field', () async {
        validator.validationResult = TestError.malformed;
        field.setValidationMode(mode);

        expect(await field.validate(), isFalse);
        expect(field.value.error, TestError.malformed);
      });
    }

    test('a reset field counts as untouched again', () {
      validator.validationResult = TestError.malformed;
      field
        ..setValidationMode(ValidationMode.onUserInteraction)
        ..setValue(10);
      expect(field.value.error, TestError.malformed);

      field
        ..reset()
        ..revalidateSync();

      expect(field.value.error, isNull);
    });
  });

  group('setValidationMode on a field', () {
    test('the field keeps its own mode when the form broadcasts another', () {
      final form = AdvancedFormController();
      addTearDown(form.dispose);
      final own = AdvancedFieldController<int, TestError>(initialValue: 0);
      final other = AdvancedFieldController<int, TestError>(initialValue: 0);
      form.registerFields([own, other]);

      own.setValidationMode(ValidationMode.onUnfocus);
      form.setValidationMode(ValidationMode.onUserInteraction);

      expect(own.value.validationMode, ValidationMode.onUnfocus);
      expect(other.value.validationMode, ValidationMode.onUserInteraction);
    });

    test('a form with validation off still silences a field of its own', () {
      final form = AdvancedFormController();
      addTearDown(form.dispose);
      final own = AdvancedFieldController<int, TestError>(initialValue: 0);
      form.registerFields([own]);

      own.setValidationMode(ValidationMode.onUnfocus);
      form.setValidationEnabled(false);
      expect(own.value.validationMode, ValidationMode.manual);

      form.setValidationEnabled(true);
      expect(own.value.validationMode, ValidationMode.onUnfocus);
    });
  });
}
