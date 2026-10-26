/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import 'package:web/web.dart' as web;

/// The islands share the docs page's window, so a link is a plain navigation.
void openUrl(String url) {
  web.window.location.href = url;
}
