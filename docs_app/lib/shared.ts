/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
export const appName = "advanced_forms"
export const tagline = "Form validation for Flutter, without a framework on top"
export const description =
  "Typed field controllers, composable sync and async validation, and form-level state for Flutter — built on " +
  "ChangeNotifier and ValueListenable, so it fits any state-management stack."

/** Where the documentation pages live. The landing page owns `/`. */
export const docsRoute = "/docs"
export const docsImageRoute = "/og"
export const docsContentRoute = "/llms.mdx"

export const gitConfig = {
  user: "leancodepl",
  repo: "advanced_forms",
  branch: "main",
}

const repo = `https://github.com/${gitConfig.user}/${gitConfig.repo}`
const utm = "utm_source=advanced-forms-docs&utm_medium=referral&utm_campaign=advanced-forms"

/** Every external destination the site links to, in one place. */
export const urls = {
  repo,
  issues: `${repo}/issues`,
  changelog: `${repo}/blob/${gitConfig.branch}/CHANGELOG.md`,
  migration: `${repo}/blob/${gitConfig.branch}/MIGRATION.md`,
  license: `${repo}/blob/${gitConfig.branch}/LICENSE`,
  skill: `${repo}/blob/${gitConfig.branch}/skills/advanced_forms/SKILL.md`,
  exampleApp: `${repo}/tree/${gitConfig.branch}/example`,
  exampleGuide: `${repo}/blob/${gitConfig.branch}/example/example.md`,
  exampleWidgets: `${repo}/tree/${gitConfig.branch}/example/lib/widgets`,
  pub: "https://pub.dev/packages/advanced_forms",
  pubScore: "https://pub.dev/packages/advanced_forms/score",
  apiReference: "https://pub.dev/documentation/advanced_forms/latest/",
  leancode: `https://leancode.co/?${utm}`,
  leancodeEstimate: `https://leancode.co/get-estimate?${utm}`,
  leancodePackages: "https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads",
  patrol: `https://patrol.leancode.co/?${utm}`,
} as const
