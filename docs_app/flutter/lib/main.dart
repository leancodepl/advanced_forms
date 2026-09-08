/*
 * AI-Provenance:
 *   model: Claude Opus 5
 *   harness: Cursor
 *   edited-by: Claude Fable 5.1 (Claude Code)
 */
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:advanced_forms_docs_islands/generated/registry.dart';
import 'package:advanced_forms_docs_islands/support/island_shell.dart';
import 'package:advanced_forms_docs_islands/support/multi_view_app.dart';
import 'package:flutter/widgets.dart';

/// What the host page passes to `app.addView({initialData: ...})`.
extension type _IslandOptions._(JSObject _) implements JSObject {
  external String? get exampleId;
}

/// `window.__advancedFormsIslandsSetExample(viewId, exampleId)`: the host
/// page's way to point an existing view at another example.
///
/// The page keeps a small pool of views and never removes one — the engine
/// does not give a removed view's WebGL contexts back, and browsers revoke
/// the oldest live context once about sixteen exist. A view that scrolls out
/// of use is parked and later re-aimed at whatever example needs a view next.
@JS('__advancedFormsIslandsSetExample')
external set _setExample(JSFunction function);

/// The example each view shows, by view id. Created on first build with the
/// example the host passed to `addView`; changed by [_setExample].
final _examples = <int, ValueNotifier<String?>>{};

void main() {
  // The docs page owns the address bar. Without this a Navigator inside an
  // island can rewrite the URL of the page hosting it, and multi-view routing
  // is not supported anyway (flutter/flutter#139174).
  ui_web.urlStrategy = null;

  _setExample = (JSNumber viewId, JSString? exampleId) {
    _examples
            .putIfAbsent(viewId.toDartInt, () => ValueNotifier<String?>(null))
            .value =
        exampleId?.toDart;
  }.toJS;

  // `runApp` needs an implicit view, which does not exist in multi-view mode.
  // `runWidget` renders only into views the host has explicitly added.
  runWidget(
    MultiViewApp(
      viewBuilder: (context) {
        final viewId = View.of(context).viewId;
        final example = _examples.putIfAbsent(viewId, () {
          final options =
              ui_web.views.getInitialData(viewId) as _IslandOptions?;
          return ValueNotifier(options?.exampleId);
        });

        return ValueListenableBuilder(
          valueListenable: example,
          builder: (context, exampleId, _) => IslandShell(
            // A new key per example: switching resets the example's state.
            key: ValueKey(exampleId),
            exampleId: exampleId,
            builder: exampleId == null ? null : examples[exampleId],
          ),
        );
      },
    ),
  );
}
