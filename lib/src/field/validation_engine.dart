part of 'advanced_field_controller.dart';

// Every decision to validate the field on its own, and carrying it out. The
// mode picks the action; the rules no mode can change live here: an untouched
// field stays quiet, an edit drops errors that described the old value, and
// only settled checks reach the history.
extension type _Engine<T, E extends Object>(
        AdvancedFieldController<T, E> _field)
    implements AdvancedFieldController<T, E> {
  void onEdit(T value) {
    _history = _history.edited();
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

    // Decided before the history moves, so the first unfocus still sees none.
    final action = _decide(ValidationEvent.unfocus);
    if (_history.edits > 0) {
      _history = _history.left();
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
    _history = _history.validated();
    return _rounds.runValidate();
  }

  // Records how the check that just wrote the state ended, unless a round is
  // still on its way.
  void settle() {
    if (_value.isInProgress) {
      return;
    }
    _history = _history.withVerdict(
      _value.validationError != null
          ? FieldVerdict.invalid
          : _value.isFailedValidation
              ? FieldVerdict.failed
              : _value.asyncError != null
                  ? FieldVerdict.invalid
                  : FieldVerdict.valid,
    );
  }

  ValidationAction _decide(ValidationEvent event) => _history.edits == 0
      ? ValidationAction.none
      : _value.validationMode.decide(
          ValidationContext(event: event, history: _history),
        );

  // Only a full check is async; the other two finish before this returns.
  Future<void> _run(ValidationAction action) {
    switch (action) {
      case ValidationAction.none:
        return Future.value();
      case ValidationAction.sync:
        _setSyncError(_validator(_value.value));
        settle();
        return Future.value();
      case ValidationAction.full:
        return _rounds.runValidate();
    }
  }

  // The value changed, so the async error described the old one.
  void _writeEdit(T value, E? validationError) {
    _setState(
      _value.copyWithNullable(
        value: value,
        validationError: validationError,
        asyncError: null,
        status: _statusFromErrors(validationError, null),
      ),
    );
    settle();
  }
}
