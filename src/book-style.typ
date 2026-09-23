// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

#import "authors.typ": author-block

// Book-like typography and small composition helpers inspired by mousse-notes.
// Course orchestration stays in layouts.typ; this module is deliberately
// reusable by notes, homework, and standalone components.

#let prose-indent = 1.4em

#let default-fonts = (
  serif: (
    text: "New Computer Modern",
    math: "New Computer Modern Math",
  ),
  sans: (
    text: "TeX Gyre Heros",
    // Typst does not ship a matching sans-serif math face; keep a complete,
    // metrics-compatible math font as the dependable default.
    math: "New Computer Modern Math",
  ),
)

#let font-pair(fonts, style) = {
  assert(
    fonts.keys().contains(style),
    message: "unknown font style `" + style + "`; expected one of " + fonts.keys().join(", "),
  )
  let pair = fonts.at(style)
  assert(pair.keys().contains("text") and pair.keys().contains("math"),
    message: "font style `" + style + "` requires `text` and `math` entries")
  pair
}

// Shared first-page header for compact document types such as short notes and
// standalone homework. Optional context sits above/below the stacked title and author.
#let compact-header(
  title,
  author: none,
  author-label: none,
  kicker: none,
  detail: none,
) = block(
  width: 100%,
  below: 2em,
)[
  #set align(center)
  #set par(first-line-indent: 0em, justify: false)
  #if kicker != none {
    text(size: 0.85em, weight: "bold", kicker)
    v(0.25em)
  }
  #text(size: 1.65em, weight: "bold", title)
  #if author != none {
    v(0.45em)
    text(size: 0.95em, author-block(author, label: author-label))
  }
  #if detail != none {
    v(0.3em)
    text(size: 0.9em, detail)
  }
]

#let running-header(title) = context {
  let page-number = counter(page).get().first()
  let next-chapter = query(selector(heading.where(level: 1)).after(here()))
    .filter(it => it.supplement != [bookmark-only])
    .at(0, default: none)
  let is-chapter-page = next-chapter != none and next-chapter.location().page() == here().page()
  if page-number == 1 or is-chapter-page { return }

  let current-chapter = query(selector(heading.where(level: 1)).before(here()))
    .filter(it => it.supplement != [bookmark-only])
    .at(-1, default: none)
  if current-chapter == none { return }

  let section-after = query(selector(heading.where(level: 2)).after(here())).at(0, default: none)
  let section-before = query(selector(heading.where(level: 2)).before(here())).at(-1, default: none)
  let current-section = if section-after != none and section-after.location().page() == here().page() {
    section-after
  } else {
    section-before
  }

  let chapter-number = if current-chapter.numbering == none { [] } else {
    [chap. #numbering(current-chapter.numbering, ..counter(heading).at(current-chapter.location()))]
  }
  let section-number = if current-section == none or current-section.numbering == none { [] } else {
    [sec. #numbering(current-section.numbering, ..counter(heading).at(current-section.location()))]
  }

  set text(size: 9pt)
  if calc.even(page-number) {
    grid(
      columns: (1fr, 2fr, 1fr),
      align: (left, center, right),
      counter(page).display("1"), smallcaps(title), smallcaps(chapter-number),
    )
  } else {
    grid(
      columns: (1fr, 2fr, 1fr),
      align: (left, center, right),
      smallcaps(section-number), smallcaps(current-chapter.body), counter(page).display("1"),
    )
  }
}

#let running-footer() = context {
  let current-chapter = query(selector(heading.where(level: 1)).before(here()))
    .filter(it => it.supplement != [bookmark-only])
    .at(-1, default: none)
  let is-chapter-page = current-chapter != none and current-chapter.location().page() == here().page()
  if is-chapter-page {
    align(center, text(size: 9pt, counter(page).display("1")))
  }
}

// The four visual levels share one renderer; notes shift the level by one.
#let show-book-heading(level, it) = {
  let style = (
    (size: 1.5em, above: 0em, below: 1.5em),
    (size: 1.2em, above: 2em, below: 1em),
    (size: 1em, above: 1.25em, below: 0.75em),
    (size: 1em, above: 0.9em, below: 0.5em),
  ).at(level - 1)
  block(sticky: true, breakable: false, above: style.above, below: style.below)[
    #set par(first-line-indent: 0em, justify: false)
    #set text(size: style.size, weight: if level == 4 { "regular" } else { "bold" },
      style: if level == 4 { "italic" } else { "normal" }, hyphenate: false)
    #if it.numbering != none {
      context counter(heading).display(it.numbering)
      if level <= 2 { h(0.5em) } else { [. ] }
    }
    #it.body
  ]
}
