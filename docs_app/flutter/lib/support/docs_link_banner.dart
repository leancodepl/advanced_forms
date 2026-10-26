/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import 'package:flutter/material.dart';

import 'open_url_stub.dart' if (dart.library.js_interop) 'open_url_web.dart';

/// A one-line accent banner with a link, for pointing the reader at the page
/// that goes further than the demo.
class DocsLinkBanner extends StatelessWidget {
  const DocsLinkBanner({
    super.key,
    required this.message,
    required this.linkText,
    required this.url,
  });

  final String message;
  final String linkText;
  final String url;

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
            onTap: () => openUrl(url),
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
