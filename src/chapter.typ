// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Chapter wrapper and selection logic.
// Each chapter owns its metadata through a top-level show rule.
#import "document-context.typ": document-context

#import "course-info.typ": normalized

#let chapter(title: none, id: none, body) = {
  if title == none {
    panic("chapter requires a title")
  }

  context {
    let selection = document-context.get().at("selection", default: none)
    let wanted = if selection == none { none } else { normalized(selection) }
    let selected = wanted == none or normalized(title) == wanted or (
      id != none and normalized(id) == wanted
    )
    if selected {
      pagebreak(weak: true)
      heading(level: 1, title)
      body
    }
  }
}

// Part-title page in the style of traditional lecture notes.
#let part(title, number: none) = {
  set par(first-line-indent: 0em, justify: false)
  pagebreak(weak: true)
  v(2.1em)
  if number != none {
    text(size: 1.25em)[Part #number]
    v(0.35em)
  }
  text(size: 2em, weight: "regular")[#title]
  v(1fr)
  pagebreak()
}
