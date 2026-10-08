// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

#import "course-info.typ": plain-text

// A compact résumé with a centered name/contact header and ruled sections.
// Contacts are content values, usually links, separated by vertical bars.
#let resume(
  name: "",
  contacts: (),
  title: none,
  font: "Times New Roman",
  mono-font: "Inconsolata",
  text-size: 11pt,
  name-size: 22pt,
  link-color: rgb("#006800"),
  paper: "us-letter",
  margin: 0.75in,
  body,
) = {
  let author = plain-text(name)
  set document(
    title: if title == none { "Résumé - " + author } else { plain-text(title) },
    author: author,
  )
  set page(paper: paper, margin: margin, numbering: none)
  set text(font: font, size: text-size)
  show raw: set text(font: mono-font, size: text-size)
  set par(justify: true)
  set block(above: 0.4em, below: 0.4em)
  set enum(spacing: 0.25em)

  show heading.where(level: 1): it => block(
    above: 0.75em,
    width: 100%,
    inset: (bottom: 0.25em),
    stroke: (bottom: 0.5pt),
  )[
    #text(size: text-size, it.body)
  ]
  show link: it => text(font: mono-font, fill: link-color, it)

  align(center, stack(
    dir: ttb,
    spacing: 0.9em,
    text(size: name-size, weight: "bold", name),
    ..if contacts.len() == 0 { () } else {
      (contacts.join([ #h(0.25em) | #h(0.25em) ]),)
    },
  ))
  body
}

// Keep each entry together. Compile with --input visibility=public to omit
// GPAs, matching the source résumé's private-by-default behavior.
#let resume-entry(
  title,
  date,
  organization: none,
  location: none,
  gpa: none,
  visibility: sys.inputs.at("visibility", default: none),
  body,
) = block(
  breakable: false,
  above: 0.6em,
  below: 0pt,
)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    strong(title), align(right, date),
  )
  #if organization != none or location != none or gpa != none {
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      emph(if organization == none { [] } else { organization }),
      {
        align(right, emph(if location == none { [] } else { location }))
        align(right, strong(if gpa == none or visibility == "public" { [] } else { [*GPA*: #gpa] }))
      },
    )
  }
  #body
]
