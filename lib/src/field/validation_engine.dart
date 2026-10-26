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

    // Decided before the bit flips, so the first unfocus still sees none.
    final action = _decide(ValidationEvent.unfocus);
    if (_hasInteracted) {
      _everUnfocused = true;
    }

    // Caught here, so a throwing validator cannot escape into the zone of
    // whoever moved the focus.
    try {
      await _run(action);
    } catch (error, stackTrace) {
      _report(name, 'validating after focus loss', error, stackTrace);
    }
  }

  // A throwing sync validator reaches the caller, as before; a full check
  // reports its own failures.
  void onDependencyChanged() {
    final done = _run(_decide(ValidationEvent.dependencyChanged));
    unawaited(
      done.catchError((Object error, StackTrace stackTrace) {
        _report(
          name,
          'validating after a dependency changed',
          error,
          stackTrace,
        );
      }),
    );
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
