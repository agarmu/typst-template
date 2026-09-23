// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

#import "course-info.typ": plain-text

// Normalize names once for both PDF metadata and visible author details.
#let author-list(author) = {
  let entries = if author == none { () } else if type(author) == array { author } else { (author,) }
  entries.map(person => if type(person) == dictionary { person } else { (name: person,) })
}

#let author-names(author) = author-list(author).map(person => plain-text(person.name))

#let author-block(author, label: none) = {
  let people = author-list(author)
  if people.len() == 0 { return }
  set align(center)
  set par(first-line-indent: 0em, justify: false)
  let has-value(value) = value != none and value != ""
  if has-value(label) {
    text(size: 0.85em, weight: "bold", label)
    v(0.35em)
  }
  grid(
    columns: (auto,) * people.len(),
    column-gutter: 1.5em,
    align: center + top,
    ..people.map(person => {
      let role = person.at("label", default: none)
      let email = person.at("email", default: none)
      [
        #person.name#if has-value(role) and not has-value(email) { [ (#role)] }
        #if has-value(email) {
          if has-value(role) {
            linebreak()
            text(size: 0.85em, role)
          }
          linebreak()
          link("mailto:" + email, text(size: 0.8em, email))
        }
      ]
    }),
  )
}
