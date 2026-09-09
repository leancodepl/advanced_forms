/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { swatches, themes } from "@/lib/palette.generated"

export { swatches, themes }

/** The dark theme: what the social cards are drawn in, whatever the reader's theme. */
export const dark = themes.dark

/** `#rrggbb` at an alpha, as `rgba()` — the one color form every renderer of ours understands. */
export function withAlpha(hex: string, alpha: number): string {
  const [r, g, b] = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16))
  return `rgba(${r}, ${g}, ${b}, ${alpha})`
}
