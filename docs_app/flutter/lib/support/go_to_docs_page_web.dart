/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import 'package:web/web.dart' as web;

/// Navigates the docs page the island is embedded in to another docs page,
/// in the same tab. [path] is site-relative, like `/docs/validation/modes`.
/// An external link would need a new tab instead; this is not for those.
void goToDocsPage(String path) {
  assert(path.startsWith('/'), 'goToDocsPage takes a site-relative path');
  web.window.location.href = path;
}
