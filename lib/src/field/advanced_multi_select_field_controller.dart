import 'package:advanced_forms/src/field/advanced_field_controller.dart';

/// A specialization of [AdvancedFieldController] for a multiple choice of [V] values.
class AdvancedMultiSelectFieldController<V, E extends Object>
    extends AdvancedFieldController<Set<V>, E> {
  /// Creates a new [AdvancedMultiSelectFieldController].
  AdvancedMultiSelectFieldController({
    required Set<V> initialValue,
    super.validator,
    super.asyncValidation,
    super.focusNode,
    required List<V> options,
    super.name,
  })  : _options = List.unmodifiable(options),
        super(initialValue: Set.of(initialValue));

  List<V> _options;

  /// The options to select from. The field keeps its own copy; replace it
  /// with [setOptions].
  List<V> get options => _options;

  /// Replaces [options], for a list that depends on another field or arrives
  /// from the server after the field was created.
  ///
  /// Selected values that are not on the new list are dropped, on behalf of
  /// the program: like [prefill], this does not count as the user having
  /// edited the field, so an untouched field stays untouched and shows no
  /// error until [validate]. A read-only field is pruned too, because a
  /// value that is not on the list cannot be shown. On a field the user has
  /// edited, the sync validator runs again under the field's mode.
  ///
  /// Listeners are notified even when the value did not change, so a widget
  /// listing [options] rebuilds.
  ///
  /// Throws a [StateError] if this field has already been disposed.
  void setOptions(List<V> options) {
    if (isDisposed) {
      throw StateError(
        'Cannot set options on a disposed AdvancedMultiSelectFieldController.',
      );
    }
    _options = List.unmodifiable(options);
    final kept = fieldValue.where(_options.contains).toSet();
    if (kept.length != fieldValue.length) {
      prefill(kept, force: true);
    }
    revalidateSync();
    notifyListeners();
  }

  /// Toggles the given [value].
  void toggleElement(V value) {
    if (fieldValue.contains(value)) {
      removeValue(value);
    } else {
      addValue(value);
    }
  }

  /// Adds the given [value].
  ///
  /// The [value] must be one of [options].
  void addValue(V value) {
    assert(
      options.contains(value),
      'Cannot add $value because it is not one of the available options.',
    );
    setValue({...fieldValue}..add(value));
  }

  /// Removes the given [value].
  void removeValue(V value) {
    setValue({...fieldValue}..remove(value));
  }
}
