// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Homework wrapper and selection logic.
// Each homework owns its metadata through a top-level show rule.
#import "course-info.typ": format-due, normalized, present
#import "document-context.typ": document-context
#import "book-style.typ": compact-header
#import "theorems.typ": reset-exercise-counter

// A hanging, prose-style entry: “Label. Body”.
#let labeled(label, body) = block(
  width: 100%,
  inset: (left: 1.65em),
  above: 0.45em,
  below: 0.45em,
)[
  #text(weight: "bold")[#label.] #body
]

#let matches-selection(selection, id, number, title) = {
  if selection == none {
    true
  } else {
    let wanted = normalized(selection)
    let candidates = (id, number, title)
      .filter(value => value != none)
      .map(normalized)
    candidates.contains(wanted) or candidates.contains("hw" + wanted)
  }
}

#let standalone-title(config, title, due-date) = {
  let author = config.at("author", default: none)
  let code = config.at("code", default: "")
  let name = config.at("name", default: "")
  let course = if code == "" { name } else if name == "" { code } else { code + ": " + name }
  compact-header(
    title,
    author: author,
    author-label: config.at("author-label", default: none),
    kicker: if course == "" { none } else { course },
    detail: if present(due-date) { "Due: " + format-due(due-date) } else { none },
  )
}

#let homework(
  title: none,
  id: none,
  number: none,
  due-date: none,
  points: none,
  description: none,
  body,
) = {
  if title == none {
    panic("homework requires a title")
  }

  context {
    let config = document-context.get()
    let mode = config.at("mode", default: "full")
    let selected = matches-selection(config.at("selection", default: none), id, number, title)
    if ("full", "censor-partial", "hws").contains(mode) {
      heading(level: 2, numbering: none, title)
      if present(due-date) { labeled([Due], format-due(due-date)) }
      if mode == "hws" {
        if present(points) { labeled([Points], str(points)) }
        if present(description) { description }
      } else {
        reset-exercise-counter()
        body
      }
    } else if mode == "hw" and selected {
      standalone-title(config, title, due-date)
      reset-exercise-counter()
      body
    }
  }
}
