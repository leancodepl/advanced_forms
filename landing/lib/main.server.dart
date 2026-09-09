/// Server entrypoint: runs once during `jaspr build` to pre-render the page.
library;

import 'dart:convert';

import 'package:advanced_forms_landing/app.dart';
import 'package:advanced_forms_landing/highlight.dart';
import 'package:advanced_forms_landing/palette.generated.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

Future<void> main() async {
  // No @client components and no Dart-side styles, so no generated options.
  Jaspr.initializeApp();
  await initHighlighting();

  final version = packageVersion();
  const socialTitle = '$siteName — $tagline';
  // Rendered by the docs app, on the same domain (app/og/landing.png).
  final ogImage = '${canonicalUrl}og/landing.png';

  runApp(
    Document(
      lang: 'en',
      title: seoTitle,
      meta: {
        'description': description,
        'author': 'LeanCode',
        'robots': 'index, follow, max-image-preview:large',
        'theme-color': themeColor,
        'application-name': siteName,
        'generator': 'Jaspr',
        'twitter:card': 'summary_large_image',
        'twitter:title': socialTitle,
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
        // The colors, generated from docs_app/palette.json; then the rest.
        const link(rel: 'stylesheet', href: '/af-tokens.css'),
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
        meta(attributes: {'name': 'twitter:image', 'content': ogImage}),
        for (final MapEntry(key: property, value: content) in {
          'og:type': 'website',
          'og:site_name': siteName,
          'og:locale': 'en_US',
          'og:url': canonicalUrl,
          'og:title': socialTitle,
          'og:description': description,
          'og:image': ogImage,
          'og:image:width': '1200',
          'og:image:height': '630',
          'og:image:alt': socialTitle,
        }.entries)
          meta(attributes: {'property': property, 'content': content}),
        // Structured data: the package, its publisher and the site, so search
        // engines can show the repository, the licence and the version.
        script(
          attributes: const {'type': 'application/ld+json'},
          content: jsonEncode(_structuredData(version)),
        ),
      ],
      body: App(version: version),
    ),
  );
}

Map<String, Object> _structuredData(String version) {
  const publisher = {
    '@type': 'Organization',
    '@id': 'https://leancode.co/#organization',
    'name': 'LeanCode',
    'url': 'https://leancode.co/',
  };
  return {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'WebSite',
        '@id': '$canonicalUrl#website',
        'url': canonicalUrl,
        'name': siteName,
        'description': description,
        'inLanguage': 'en',
        'publisher': publisher,
      },
      {
        '@type': 'SoftwareSourceCode',
        '@id': '$canonicalUrl#package',
        'name': siteName,
        'alternateName': 'Advanced Forms',
        'description': description,
        'url': canonicalUrl,
        'codeRepository': repoUrl,
        'installUrl': pubUrl,
        'programmingLanguage': 'Dart',
        'runtimePlatform': 'Flutter',
        'version': version,
        'license': 'https://www.apache.org/licenses/LICENSE-2.0',
        'keywords': keywords.join(', '),
        'author': publisher,
        'publisher': publisher,
        'softwareHelp': {
          '@type': 'CreativeWork',
          'url': '$canonicalUrl${docsPath.substring(1)}',
        },
      },
      {
        '@type': 'WebPage',
        '@id': canonicalUrl,
        'url': canonicalUrl,
        'name': seoTitle,
        'description': description,
        'isPartOf': {'@id': '$canonicalUrl#website'},
        'about': {'@id': '$canonicalUrl#package'},
        'primaryImageOfPage': '${canonicalUrl}og/landing.png',
      },
    ],
  };
}
