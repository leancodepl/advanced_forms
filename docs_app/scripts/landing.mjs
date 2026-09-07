/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 *
 * Builds the landing page (../landing, a Jaspr static site) and copies the
 * result into public/, where Next serves it: `/` is rewritten to `/index.html`
 * in next.config.mjs, so the homepage and the docs under /docs ship as one
 * deployment on one domain.
 *
 *   node scripts/landing.mjs           build and copy
 *   node scripts/landing.mjs --check   only verify that the copy is present
 *
 * Needs the Dart SDK (see ../landing/pubspec.yaml for the version) with the
 * Jaspr CLI activated: `dart pub global activate jaspr_cli 0.23.4`. It is run
 * through `dart pub global run`, so the `dart` on PATH is the one that builds.
 * `SITE_URL` overrides the canonical URL baked into the page, for previews.
 */
import { spawnSync } from "node:child_process"
import { cpSync, existsSync, mkdirSync, readdirSync, rmSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const docsApp = path.dirname(path.dirname(fileURLToPath(import.meta.url)))
const landing = path.resolve(docsApp, "..", "landing")
const output = path.join(landing, "build", "jaspr")
const publicDir = path.join(docsApp, "public")

/** What ends up in public/. Everything else in build/jaspr is build tooling. */
const artifacts = ["index.html", "landing.css", "landing.js", "landing-icon.svg"]

function run(command, args, options = {}) {
  const result = spawnSync(command, args, { stdio: "inherit", cwd: landing, ...options })
  if (result.error) throw result.error
  if (result.status !== 0) {
    process.exit(result.status ?? 1)
  }
}

function check() {
  const missing = artifacts.filter(file => !existsSync(path.join(publicDir, file)))
  if (missing.length > 0) {
    console.error(`Landing page not built: public/ is missing ${missing.join(", ")}. Run \`npm run landing:build\`.`)
    process.exit(1)
  }
}

function build() {
  run("dart", ["pub", "get"])

  const args = ["pub", "global", "run", "jaspr_cli:jaspr", "build"]
  if (process.env.SITE_URL) {
    args.push(`--dart-define=SITE_URL=${process.env.SITE_URL}`)
  }
  run("dart", args)

  const built = readdirSync(output)
  const missing = artifacts.filter(file => !built.includes(file))
  if (missing.length > 0) {
    console.error(`jaspr build did not produce ${missing.join(", ")} in ${output}`)
    process.exit(1)
  }

  mkdirSync(publicDir, { recursive: true })
  for (const file of artifacts) {
    const target = path.join(publicDir, file)
    rmSync(target, { force: true })
    cpSync(path.join(output, file), target)
  }
  console.log(`Landing page copied to public/ (${artifacts.join(", ")})`)
}

if (process.argv.includes("--check")) check()
else build()
