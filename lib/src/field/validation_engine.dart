part of 'advanced_field_controller.dart';

// Every decision to validate the field on its own, and carrying it out. The
// mode picks the action; the rules no mode can change live here: an untouched
// field stays quiet, an edit drops errors that described the old value, and
// only finished checks reach the context the mode sees.
extension type _Engine<T, E extends Object>(
        AdvancedFieldController<T, E> _field)
    implements AdvancedFieldController<T, E> {
  void onEdit(T value) {
    _hasInteracted = true;
    _rounds.invalidate();

    switch (_decide(ValidationEvent.valueChanged)) {
      case ValidationAction.none:
        _clearTo(value);
      case ValidationAction.sync:
        _writeEdit(value, _validator(value));
      case ValidationAction.full:
        final validationError = _validator(value);
        if (validationError != null || _asyncValidation == null) {
          _writeEdit(value, validationError);
        } else {
          _rounds.begin(value, debounced: true);
        }
    }
  }

  Future<void> onUnfocus() async {
    // User left the field — finish any debounced validation now.
    _rounds.flushDebounce();

    // Decided before everUnfocused is set, so the first unfocus sees false.
    final action = _decide(ValidationEvent.unfocus);
    if (_hasInteracted) {
      _everUnfocused = true;
    }

    // Caught here, so a throwing validator cannot escape into the zone of
    // whoever moved the focus.
    try {
      await _run(action);
    } catch (err, st) {
      _report(name, 'validating after focus loss', err, st);
    }
  }

  // Caught here, like on unfocus: the caller is another field's listener,
  // so a throwing validator is reported rather than thrown at it.
  Future<void> onDependencyChanged() async {
    try {
      await _run(_decide(ValidationEvent.dependencyChanged));
    } catch (err, st) {
      _report(name, 'validating after a dependency changed', err, st);
    }
  }

  Future<bool> onValidate() {
    _everValidated = true;
    return _rounds.runValidate();
  }

  // Checked before the mode, so an untouched field stays quiet whatever the
  // mode would say. This is the one place the rule lives.
  ValidationAction _decide(ValidationEvent event) => !_hasInteracted
      ? ValidationAction.none
      : _value.validationMode.decide(
          ValidationContext(
            event: event,
            everUnfocused: _everUnfocused,
            everValidated: _everValidated,
            lastStatus: _lastStatus,
          ),
        );

  // Only a full check is async; the other two finish before this returns.
  Future<void> _run(ValidationAction action) {
    switch (action) {
      case ValidationAction.none:
        return Future.value();
      case ValidationAction.sync:
        _setSyncError(_validator(_value.value), fromCheck: true);
        return Future.value();
      case ValidationAction.full:
        return _rounds.runValidate();
    }
  }

  // The value changed, so the async error described the old one.
  void _writeEdit(T value, E? validationError) => _setState(
        _value.copyWithNullable(
          value: value,
          validationError: validationError,
          asyncError: null,
          status: _statusFromErrors(validationError, null),
        ),
        fromCheck: true,
      );
}
