// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Generic title page and front-matter orchestration for book documents.
#import "course-info.typ": present
#import "authors.typ": author-block

// A logical heading that appears only in the exported PDF's bookmark tree.
// The surrounding layout suppresses its visual rendering, and `outlined:
// false` keeps it out of the printed table of contents.
#let bookmark(title) = heading(
  level: 1,
  numbering: none,
  outlined: false,
  bookmarked: true,
  supplement: "bookmark-only",
  title,
)

#let book-cover(
  title: none,
  subtitle: none,
  author: none,
  author-label: none,
  date: none,
  institution: none,
  description: none,
  epigraph: none,
) = {
  bookmark([Title Page])
  align(center, {
    v(0.3fr)
    text(size: 2em, title)
    if subtitle != none { v(0.65em); text(size: 1.25em, subtitle) }
    if present(author) {
      v(1em)
      text(size: 1.1em, author-block(author, label: author-label))
    }
    v(0.8fr)
    if present(institution) { text(size: 1.1em, institution); v(0.12fr) }
    if present(date) { text(size: 1.1em, date) }
    v(0.55fr)
    if epigraph != none {
      block(
        width: 80%,
        inset: (x: 0.5em, y: 0.8em),
      )[
        #set par(justify: false, first-line-indent: 0em)
        #emph(epigraph)
      ]
      v(0.35fr)
    }
    if present(description) {
      block(width: 82%)[
        #set text(size: 0.833em)
        #set par(justify: true)
        #description
      ]
    }
    v(0.3fr)
  })
  pagebreak(weak: true)
}

#let book-document(
  title: none,
  subtitle: none,
  author: none,
  author-label: none,
  date: none,
  institution: none,
  description: none,
  epigraph: none,
  frontmatter: none,
  cover: true,
  contents: true,
  body,
) = {
  if cover {
    book-cover(
      title: title,
      subtitle: subtitle,
      author: author,
      author-label: author-label,
      date: date,
      institution: institution,
      description: description,
      epigraph: epigraph,
    )
  }
  if frontmatter != none {
    bookmark([Front Matter])
    {
      set heading(numbering: none)
      frontmatter
    }
    counter(heading).update(0)
    pagebreak(weak: true)
  }
  if contents {
    outline(title: [Table of Contents])
    pagebreak(weak: true)
  }
  body
}
