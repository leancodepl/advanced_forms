/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { existsSync, readFileSync } from "node:fs"
import { join } from "node:path"

/**
 * The package version, read from the repository's own `pubspec.yaml` so the
 * site can never announce a stale number. Server-only: it touches the file
 * system.
 *
 * Looked up relative to the working directory rather than `import.meta.url`,
 * which the bundler rewrites into something `node:fs` cannot open.
 */
export function packageVersion(): string {
  for (const candidate of [join(process.cwd(), "..", "pubspec.yaml"), join(process.cwd(), "pubspec.yaml")]) {
    // The path is computed, so the bundler cannot trace it — and must not try.
    if (!existsSync(/*turbopackIgnore: true*/ candidate)) continue
    const pubspec = readFileSync(/*turbopackIgnore: true*/ candidate, "utf8")
    if (!/^name:\s*advanced_forms\s*$/m.test(pubspec)) continue
    const match = /^version:\s*(\S+)/m.exec(pubspec)
    // pub.dev shows the build number, the badge does not need to.
    if (match) return match[1].replace(/\+.*$/, "")
  }
  throw new Error("Could not find the advanced_forms pubspec.yaml above the docs app.")
}
