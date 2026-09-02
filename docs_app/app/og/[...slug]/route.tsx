/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { getPageImageUrl, source } from "@/lib/source"
import { notFound } from "next/navigation"
import { ImageResponse } from "next/og"
import { LogoMark } from "@/components/logo"
import { appName } from "@/lib/shared"

export const revalidate = false

const ink = "#050505"
const surface = "#101013"
const border = "#23232b"
const text = "#f4f4f1"
const muted = "#b7b7b3"
const accent = "#edff2f"

export async function GET(_req: Request, { params }: RouteContext<"/og/[...slug]">) {
  const { slug } = await params
  const page = source.getPage(slug.slice(0, -1))
  if (!page) notFound()

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
          Flutter · docs
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 14, color: accent, fontSize: 22, fontWeight: 600 }}>
          <div style={{ width: 28, height: 3, background: accent }} />
          DOCUMENTATION
        </div>
        <div style={{ fontSize: 68, fontWeight: 700, lineHeight: 1.05, letterSpacing: -2 }}>{page.data.title}</div>
        {page.data.description && (
          <div style={{ fontSize: 28, color: muted, lineHeight: 1.35, maxWidth: 980 }}>{page.data.description}</div>
        )}
      </div>
    </div>,
    {
      width: 1200,
      height: 630,
    },
  )
}

export function generateStaticParams() {
  return source.getPages().map(page => ({
    lang: page.locale,
    slug: getPageImageUrl(page).segments,
  }))
}
