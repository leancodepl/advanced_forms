import 'package:advanced_forms/src/field/advanced_field_controller.dart';

/// A specialization of [AdvancedFieldController] for a single choice of [V] from a
/// list of [options].
class AdvancedSingleSelectFieldController<V, E extends Object>
    extends AdvancedFieldController<V?, E> {
  /// Creates a new [AdvancedSingleSelectFieldController].
  AdvancedSingleSelectFieldController({
    required super.initialValue,
    super.validator,
    super.asyncValidation,
    super.focusNode,
    required List<V> options,
    super.name,
  }) : _options = List.unmodifiable(options);

  List<V> _options;

  /// The options to select from. The field keeps its own copy; replace it
  /// with [setOptions].
  List<V> get options => _options;

  /// Replaces [options], for a list that depends on another field or arrives
  /// from the server after the field was created.
  ///
  /// A selected value that is not on the new list is cleared, on behalf of
  /// the program: like [prefill], this does not count as the user having
  /// edited the field, so an untouched field stays untouched and shows no
  /// error until [validate]. A read-only field is cleared too, because a
  /// value that is not on the list cannot be shown. On a field the user has
  /// edited, the sync validator runs again under the field's mode, so a
  /// `notNull` rule reports the vanished choice at once.
  ///
  /// Listeners are notified even when the value did not change, so a widget
  /// listing [options] rebuilds.
  ///
  /// Throws a [StateError] if this field has already been disposed.
  void setOptions(List<V> options) {
    if (isDisposed) {
      throw StateError(
        'Cannot set options on a disposed AdvancedSingleSelectFieldController.',
      );
    }
    _options = List.unmodifiable(options);
    final current = fieldValue;
    if (current != null && !_options.contains(current)) {
      prefill(null, force: true);
    }
    revalidateSync();
    notifyListeners();
  }

  /// Sets the value of the field to the [option].
  ///
  /// The [option] must be `null` (to clear the selection) or one of [options].
  void select(V? option) {
    assert(
      option == null || options.contains(option),
      'Cannot select $option because it is not one of the available options.',
    );
    setValue(option);
  }
}
