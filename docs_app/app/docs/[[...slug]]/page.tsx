/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { getPageImageUrl, source } from "@/lib/source"
import { Card } from "fumadocs-ui/components/card"
import { DocsBody, DocsDescription, DocsPage, DocsTitle, EditOnGitHub } from "fumadocs-ui/layouts/notebook/page"
import { notFound } from "next/navigation"
import { getMDXComponents } from "@/components/mdx"
import type { Metadata } from "next"
import type { ComponentProps } from "react"
import { createRelativeLink } from "fumadocs-ui/mdx"
import { gitConfig } from "@/lib/shared"

export default async function Page(props: PageProps<"/docs/[[...slug]]">) {
  const params = await props.params
  const page = source.getPage(params.slug)
  if (!page) notFound()

  const MDX = page.data.body
  const editUrl = `https://github.com/${gitConfig.user}/${gitConfig.repo}/blob/${gitConfig.branch}/docs/${page.path}`

  return (
    <>
      {/*
        On a route change Next scrolls to the top only if the new segment's
        first DOM node has a box: `DocsPage` renders a `display: contents`
        <main>, which has none and no sibling to fall back to, so a page opened
        from the prev/next footer kept the old scroll position. This anchor is
        the box Next checks; it sits at the top and takes no room in the grid.
      */}
      <span aria-hidden className="pointer-events-none absolute top-0 left-0 size-px" />
      <DocsPage toc={page.data.toc} full={page.data.full} tableOfContent={{ style: "clerk" }}>
        <DocsTitle>{page.data.title}</DocsTitle>
        <DocsDescription>{page.data.description}</DocsDescription>
        <DocsBody>
          <MDX
            components={getMDXComponents({
              a: createRelativeLink(source, page),
              // `createRelativeLink` only covers `<a>`; a <Card href="./x.mdx">
              // renders its own link, so its path is resolved the same way here.
              Card: ({ href, ...props }: ComponentProps<typeof Card>) => (
                <Card href={href ? source.resolveHref(href, page) : href} {...props} />
              ),
            })}
          />
          <div className="not-prose mt-12 flex justify-end">
            <EditOnGitHub href={editUrl} />
          </div>
        </DocsBody>
      </DocsPage>
    </>
  )
}

export async function generateStaticParams() {
  return source.generateParams()
}

export async function generateMetadata(props: PageProps<"/docs/[[...slug]]">): Promise<Metadata> {
  const params = await props.params
  const page = source.getPage(params.slug)
  if (!page) notFound()

  const image = getPageImageUrl(page).url

  return {
    title: page.data.title,
    description: page.data.description,
    alternates: {
      canonical: page.url,
    },
    openGraph: {
      type: "article",
      url: page.url,
      title: page.data.title,
      description: page.data.description,
      images: image,
    },
    twitter: {
      card: "summary_large_image",
      title: page.data.title,
      description: page.data.description,
      images: image,
    },
  }
}
