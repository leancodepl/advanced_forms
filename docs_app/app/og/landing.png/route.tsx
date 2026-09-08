/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { ImageResponse } from "next/og"
import { LogoMark } from "@/components/logo"
import { appName, description } from "@/lib/shared"

/**
 * The social card of the landing page. The page itself is static HTML built
 * by Jaspr (see ../../../landing), so its Open Graph image is rendered here,
 * on the same domain, in the same style as the docs pages' cards.
 */
export const dynamic = "force-static"

const ink = "#050505"
const surface = "#101013"
const border = "#23232b"
const text = "#f4f4f1"
const muted = "#b7b7b3"
const accent = "#edff2f"

export function GET() {
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        padding: 64,
        background: `radial-gradient(60% 50% at 85% 10%, rgba(237, 255, 47, 0.18), transparent 65%), ${ink}`,
        color: text,
        fontFamily: "sans-serif",
      }}>
      <div style={{ display: "flex", alignItems: "center", gap: 18 }}>
        <LogoMark size={56} />
        <div style={{ fontSize: 34, fontWeight: 700, letterSpacing: -1 }}>{appName}</div>
        <div
          style={{
            marginLeft: "auto",
            padding: "8px 18px",
            borderRadius: 999,
            border: `1px solid ${border}`,
            background: surface,
            color: muted,
            fontSize: 22,
          }}>
          Flutter · Apache-2.0
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 14, color: accent, fontSize: 22, fontWeight: 600 }}>
          <div style={{ width: 28, height: 3, background: accent }} />
          FORM VALIDATION AND STATE FOR FLUTTER
        </div>
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            fontSize: 76,
            fontWeight: 700,
            lineHeight: 1.05,
            letterSpacing: -2,
          }}>
          <span>Complicated forms.</span>
          <span style={{ color: accent }}>Simple code.</span>
        </div>
        <div style={{ fontSize: 28, color: muted, lineHeight: 1.35, maxWidth: 980 }}>{description}</div>
      </div>
    </div>,
    { width: 1200, height: 630 },
  )
}
