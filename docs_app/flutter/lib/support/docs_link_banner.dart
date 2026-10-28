/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import 'package:advanced_forms_docs_islands/support/go_to_docs_page_stub.dart'
    if (dart.library.js_interop) 'package:advanced_forms_docs_islands/support/go_to_docs_page_web.dart';
import 'package:flutter/material.dart';

/// A one-line accent banner with a link to another docs page (same tab), for
/// pointing the reader at the page that goes further than the demo.
class DocsLinkBanner extends StatelessWidget {
  const DocsLinkBanner({
    super.key,
    required this.message,
    required this.linkText,
    required this.path,
  });

  final String message;
  final String linkText;

  /// Site-relative, like `/docs/validation/custom-modes`.
  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final small = theme.textTheme.bodySmall;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(
            message,
            style: small?.copyWith(color: theme.colorScheme.onSurface),
          ),
          InkWell(
            onTap: () => goToDocsPage(path),
            borderRadius: BorderRadius.circular(4),
            child: Text(
              '$linkText →',
              style: small?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
