#!/usr/bin/env node
/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */

/**
 * Runs `dart format` over every ```dart fence in the docs and rewrites the MDX
 * in place, so the code a page shows is canonically formatted without anyone
 * formatting it by hand.
 *
 *   node scripts/format-snippets.mjs          # rewrite
 *   node scripts/format-snippets.mjs --check  # exit 1 if anything would change
 *
 * CI checks the *generated* Dart with `dart format --set-exit-if-changed`; this
 * is the authoring-side counterpart that fixes the MDX the generated files come
 * from. Only fences inside `<AdvancedFormsExample>` are touched: those are the
 * ones that have to be whole compilation units. A fence elsewhere may be a
 * fragment — a statement, an expression — that the formatter cannot parse.
 * Fences are formatted one at a time, so an indented fence inside a JSX element
 * is dedented first and re-indented afterwards.
 *
 * The fences are written to a scratch directory *inside* the Flutter package
 * before formatting, because `dart format` chooses its style from the language
 * version of the package a file belongs to — formatting through stdin would
 * use the newest style and disagree with CI's check of the generated files.
 */
import { spawnSync } from "node:child_process"
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { readdir, readFile, writeFile } from "node:fs/promises"
import { join, relative, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const docsApp = resolve(fileURLToPath(new URL(".", import.meta.url)), "..")
const repoRoot = resolve(docsApp, "..")
const roots = [join(repoRoot, "docs"), join(docsApp, "content")]
const scratchDir = join(docsApp, "flutter", ".dart_tool", "snippet_format")

const check = process.argv.includes("--check")

async function mdxFiles(dir) {
  if (!existsSync(dir)) return []
  const entries = await readdir(dir, { withFileTypes: true, recursive: true })
  return entries
    .filter(entry => entry.isFile() && entry.name.endsWith(".mdx"))
    .map(entry => join(entry.parentPath ?? entry.path, entry.name))
    .toSorted()
}

let counter = 0

function dartFormat(source) {
  mkdirSync(scratchDir, { recursive: true })
  const file = join(scratchDir, `snippet_${counter++}.dart`)
  writeFileSync(file, source)
  try {
    const result = spawnSync("dart", ["format", file], { encoding: "utf8" })
    if (result.status !== 0) {
      throw new Error(result.stderr || result.stdout || `dart format exited with ${result.status}`)
    }
    return readFileSync(file, "utf8")
  } finally {
    rmSync(file, { force: true })
  }
}

/** Formats one fence body, keeping the indentation the fence had in the MDX. */
function formatFence(body, indent) {
  const dedented = body
    .split("\n")
    .map(line => (line.startsWith(indent) ? line.slice(indent.length) : line))
    .join("\n")
  const formatted = dartFormat(dedented.trimEnd() + "\n")
  return formatted
    .trimEnd()
    .split("\n")
    .map(line => (line === "" ? "" : indent + line))
    .join("\n")
}

// A fenced block: the opening line's indentation, its info string, the body,
// and a closing fence with the same indentation.
const fence = /^([ \t]*)```dart([^\n]*)\n([\s\S]*?)\n\1```[ \t]*$/gm

// The element whose fences get compiled. Not nested, so a lazy match is exact.
const example = /<AdvancedFormsExample\b[\s\S]*?<\/AdvancedFormsExample>/g

function formatExamples(source) {
  return source.replaceAll(example, block =>
    block.replaceAll(
      fence,
      (_, indent, meta, body) => `${indent}\`\`\`dart${meta}\n${formatFence(body, indent)}\n${indent}\`\`\``,
    ),
  )
}

let changed = 0
let failed = 0

for (const root of roots) {
  for (const file of await mdxFiles(root)) {
    const source = await readFile(file, "utf8")
    let output
    try {
      output = formatExamples(source)
    } catch (error) {
      failed++
      console.error(`${relative(repoRoot, file)}: ${String(error.message ?? error).trim()}`)
      continue
    }
    if (output === source) continue

    changed++
    if (check) {
      console.error(`${relative(repoRoot, file)}: snippets are not formatted`)
    } else {
      await writeFile(file, output)
      console.log(`formatted ${relative(repoRoot, file)}`)
    }
  }
}

if (failed > 0) process.exit(1)
if (check && changed > 0) {
  console.error("run `npm run examples:format` to fix")
  process.exit(1)
}
if (changed === 0) console.log("all snippets are formatted")
