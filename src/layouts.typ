// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Shared note and book document environments. Academic course notes are a
// course-specific document using the same typography as books.
#import "course-info.typ": plain-text, render-options
#import "authors.typ": author-names
#import "document-context.typ": document-context
#import "course-content.typ": course-document
#import "book-content.typ": book-document
#import "book-style.typ": compact-header, default-fonts, font-pair, prose-indent, running-footer, running-header
#import "book-style.typ": show-book-heading

// Shared rendering shell. Public document environments supply their own
// content orchestration, while typography remains consistent.
#let styled-notes(
  title: "",
  authors: (),
  keywords: (),
  fonts: default-fonts,
  font-style: "serif",
  page-height: 11in,
  margin: (x: 17.5%, y: 12.5%),
  header: none,
  footer: none,
  chapter-headings: true,
  body,
) = {
  let selected-fonts = font-pair(fonts, font-style)

  set document(
    title: title,
    author: authors,
    keywords: keywords,
  )

  set text(
    font: selected-fonts.text,
    size: 12pt,
    fill: black,
  )
  set page(
    width: 8.5in,
    height: page-height,
    margin: margin,
    header: header,
    footer: footer,
  )
  show math.equation: it => text(font: selected-fonts.math, it)
  show math.equation: set block(breakable: true)
  show raw: it => text(font: "DejaVu Sans Mono", it)
  show raw: set block(
    fill: rgb("f7f7f7"),
    inset: (left: 1em, right: 1em, y: 0.8em),
    above: 1em,
    below: 1em,
    width: 100%,
  )
  show raw.where(block: true): set text(size: 0.8em)
  // Book-like prose uses paragraph indentation and modest vertical spacing.
  set par(
    first-line-indent: (amount: prose-indent, all: false),
    justify: true,
    leading: 0.55em + 1pt,
    spacing: 0.5em + 1pt,
  )
  set list(indent: 1.25em, body-indent: 0.5em, spacing: 0.8em)
  set enum(indent: 1.25em, body-indent: 0.5em, spacing: 0.8em)
  set terms(hanging-indent: prose-indent)
  show list: set block(breakable: true)
  show enum: set block(breakable: true)
  set footnote.entry(separator: [])
  set heading(numbering: "1.1")
  set outline(indent: auto)
  set table(
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.5pt + rgb("cccccc")) },
  )
  set table.hline(stroke: 0.5pt)

  show link: it => text(fill: rgb("35566b"), it)

  // Compact notes shift their visual hierarchy down one level.
  let offset = if chapter-headings { 0 } else { 1 }
  show heading.where(level: 1): show-book-heading.with(1 + offset)
  show heading.where(level: 2): show-book-heading.with(2 + offset)
  show heading.where(level: 3): show-book-heading.with(3 + offset)
  show heading.where(level: 4): show-book-heading.with(4)
  show heading.where(outlined: false, bookmarked: true): it => []
  body
}

// General-purpose notes document for one-off notes and short exports. It has
// no cover, front matter, chapters, or course-specific configuration.
#let notes(
  title: "Notes",
  date: none,
  author: none,
  author-label: none,
  fonts: default-fonts,
  font-style: "serif",
  body,
) = {
  let document-title = plain-text(title)
  styled-notes(
    title: document-title,
    authors: author-names(author),
    keywords: (document-title,),
    fonts: fonts,
    font-style: font-style,
    footer: context align(center)[
      #counter(page).display("1") of #counter(page).final().first()
    ],
    chapter-headings: false,
  )[
    #compact-header(title, author: author, author-label: author-label, date: date)
    #body
  ]
}

// General-purpose book document. Its defaults provide a title page, optional
// front matter, a table of contents, chapter typography, and running headers.
// More specialized environments can disable the built-in orchestration and
// supply their own body while retaining the same book shell.
#let book(
  title: "Untitled",
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
  keywords: (),
  fonts: default-fonts,
  font-style: "serif",
  page-height: 11in,
  margin: (x: 17.5%, y: 12.5%),
  header: auto,
  footer: auto,
  body,
) = {
  let document-title = plain-text(title)
  let authors = author-names(author)
  let book-header = if header == auto { running-header(document-title) } else { header }
  let book-footer = if footer == auto { running-footer() } else { footer }

  styled-notes(
    title: document-title,
    authors: authors,
    keywords: keywords,
    fonts: fonts,
    font-style: font-style,
    page-height: page-height,
    margin: margin,
    header: book-header,
    footer: book-footer,
  )[
    #book-document(
      title: title,
      subtitle: subtitle,
      author: author,
      author-label: author-label,
      date: date,
      institution: institution,
      description: description,
      epigraph: epigraph,
      frontmatter: frontmatter,
      cover: cover,
      contents: contents,
    )[#body]
  ]
}

#let academic-notes(
  current: "full",
  name: "Course Notes", code: "", term: "", date: none, author: none, author-label: none, instructors: (), meetings: (), exams: (), notes: none, homework: none,
  institution: none, description: none, epigraph: none,
  fonts: default-fonts, font-style: "serif", body,
) = {
  let render = render-options(current)
  let is-homework-document = ("hws", "hw").contains(render.mode)
  let authors = if author == none {
    instructors.map(person => person.at("name", default: ""))
  } else {
    author-names(author)
  }
  let title = name + if term == "" { "" } else { " (" + term + ")" }

  document-context.update((
    name: name, code: code, term: term, author: author, author-label: author-label,
    mode: render.mode, selection: render.selection,
  ))
  styled-notes(
    title: title,
    authors: authors,
    keywords: (code, name, term),
    fonts: fonts,
    font-style: font-style,
    page-height: if render.mode == "hw" { auto } else { 11in },
    margin: if render.mode == "hw" { 1in } else { (x: 17.5%, y: 12.5%) },
    header: if is-homework-document { none } else { running-header(name) },
    footer: if is-homework-document {
      context align(center)[#counter(page).display("1") of #counter(page).final().first()]
    } else {
      running-footer()
    },
  )[
    #course-document(
      name: name, code: code, term: term, date: date, author: author, author-label: author-label,
      institution: institution, description: description, epigraph: epigraph,
      instructors: instructors, meetings: meetings, exams: exams,
      mode: render.mode,
      notes: notes, homework: homework,
    )
  ]
}
