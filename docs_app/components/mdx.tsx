/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import defaultMdxComponents from "fumadocs-ui/mdx"
import { Accordion, Accordions } from "fumadocs-ui/components/accordion"
import { Step, Steps } from "fumadocs-ui/components/steps"
import { Tab, Tabs } from "fumadocs-ui/components/tabs"
import { TypeTable } from "fumadocs-ui/components/type-table"
import type { MDXComponents } from "mdx/types"
import type { ImgHTMLAttributes } from "react"
import { AdvancedFormsExample } from "./advanced-forms-example"
import { cn } from "@/lib/cn"

function toPixel(value: ImgHTMLAttributes<HTMLImageElement>["width"]): number | undefined {
  if (value == null || value === "") return undefined
  const n = typeof value === "number" ? value : Number(value)
  if (!Number.isFinite(n)) return undefined
  return Math.max(1, Math.round(n))
}

function DocsImage({ className, width, height, ...props }: ImgHTMLAttributes<HTMLImageElement>) {
  return <img {...props} width={toPixel(width)} height={toPixel(height)} className={cn("rounded-lg", className)} />
}

export function getMDXComponents(components?: MDXComponents) {
  return {
    ...defaultMdxComponents,
    img: DocsImage,
    Accordion,
    Accordions,
    Step,
    Steps,
    Tab,
    Tabs,
    TypeTable,
    AdvancedFormsExample,
    ...components,
  } satisfies MDXComponents
}

export const useMDXComponents = getMDXComponents

declare global {
  type MDXProvidedComponents = ReturnType<typeof getMDXComponents>
}
