/// Server entrypoint: runs once during `jaspr build` to pre-render the page.
library;

import 'package:advanced_forms_landing/app.dart';
import 'package:advanced_forms_landing/highlight.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

Future<void> main() async {
  // No @client components and no Dart-side styles, so no generated options.
  Jaspr.initializeApp();
  await initHighlighting();

  final version = packageVersion();

  runApp(
    Document(
      lang: 'en',
      title: '$siteName — $tagline',
      meta: const {
        'description': description,
        'author': 'LeanCode',
        'robots': 'index, follow, max-image-preview:large',
        'theme-color': '#050505',
        'application-name': siteName,
        'generator': 'Jaspr',
        'twitter:card': 'summary_large_image',
        'twitter:title': '$siteName — $tagline',
        'twitter:description': description,
      },
      head: [
        // Dark is the design and the default; the script below restores the
        // theme a visitor picked — here or in the docs, which share the
        // `theme` key — before the first paint.
        const Document.html(attributes: {'class': 'dark'}),
        const link(
          rel: 'icon',
          href: '/landing-icon.svg',
          type: 'image/svg+xml',
        ),
        link(rel: 'canonical', href: canonicalUrl),
        const link(rel: 'preconnect', href: 'https://fonts.googleapis.com'),
        const link(
          rel: 'preconnect',
          href: 'https://fonts.gstatic.com',
          attributes: {'crossorigin': ''},
        ),
        const link(
          rel: 'stylesheet',
          href:
              'https://fonts.googleapis.com/css2'
              '?family=Space+Grotesk:wght@400;500;600;700'
              '&family=JetBrains+Mono:wght@400;600&display=swap',
        ),
        const link(rel: 'stylesheet', href: '/landing.css'),
        // Applied before paint so a light-theme visitor never sees a dark flash.
        const script(
          content:
              "(()=>{try{var t=localStorage.getItem('theme');"
              "var d=t==null||t==='dark'||(t==='system'&&"
              "matchMedia('(prefers-color-scheme: dark)').matches);"
              "document.documentElement.classList.toggle('dark',d);"
              "document.documentElement.style.colorScheme=d?'dark':'light'}"
              'catch(e){}})();',
        ),
        const script(src: '/landing.js', attributes: {'defer': ''}),
        for (final MapEntry(key: property, value: content) in {
          'og:type': 'website',
          'og:site_name': siteName,
          'og:locale': 'en_US',
          'og:url': canonicalUrl,
          'og:title': '$siteName — $tagline',
          'og:description': description,
        }.entries)
          meta(attributes: {'property': property, 'content': content}),
      ],
      body: App(version: version),
    ),
  );
}
