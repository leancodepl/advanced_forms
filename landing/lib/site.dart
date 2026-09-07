/// Site-wide constants: where the site lives and where it links to.
library;

import 'dart:io';

const siteName = 'advanced_forms';
const tagline = 'Complicated forms. Simple code.';
const description =
    'Typed field controllers, composable sync and async validation, and '
    'form-level state for Flutter — built on ChangeNotifier and '
    'ValueListenable, so it fits any state-management stack.';

/// Public URL of the deployed site. Previews override it with
/// `--dart-define=SITE_URL=https://…` at build time.
const siteUrl = String.fromEnvironment(
  'SITE_URL',
  defaultValue: 'https://advanced-forms.leancode.co',
);

/// [siteUrl] with a trailing slash, for canonical and Open Graph URLs.
final canonicalUrl = siteUrl.endsWith('/') ? siteUrl : '$siteUrl/';

/// The documentation, served by the docs app under the same domain.
const docsPath = '/docs';

const repoUrl = 'https://github.com/leancodepl/advanced_forms';
const pubUrl = 'https://pub.dev/packages/advanced_forms';
const apiReferenceUrl = 'https://pub.dev/documentation/advanced_forms/latest/';
const changelogUrl = '$repoUrl/blob/main/CHANGELOG.md';
const migrationUrl = '$repoUrl/blob/main/MIGRATION.md';
const issuesUrl = '$repoUrl/issues';
const skillUrl = '$repoUrl/blob/main/skills/advanced_forms/SKILL.md';

const _utm =
    'utm_source=advanced-forms-docs&utm_medium=referral&utm_campaign=advanced-forms';
const leancodeUrl = 'https://leancode.co/?$_utm';
const leancodeEstimateUrl = 'https://leancode.co/get-estimate?$_utm';
const leancodePackagesUrl =
    'https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads';
const patrolUrl = 'https://patrol.leancode.co/?$_utm';

const installCommand = 'flutter pub add advanced_forms';

/// The package version, read from the repository's own pubspec so the site
/// can never announce a stale number. The build number is not shown.
String packageVersion() {
  for (final candidate in ['../pubspec.yaml', 'pubspec.yaml']) {
    final file = File(candidate);
    if (!file.existsSync()) {
      continue;
    }
    final source = file.readAsStringSync();
    if (!RegExp(
      r'^name:\s*advanced_forms\s*$',
      multiLine: true,
    ).hasMatch(source)) {
      continue;
    }
    final match = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(source);
    if (match != null) {
      return match[1]!.replaceAll(RegExp(r'\+.*$'), '');
    }
  }
  throw StateError('Could not find the advanced_forms pubspec.yaml.');
}
