// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

#import "course-info.typ": plain-text

// A block-style cover letter with 1-inch margins and 12-point text.
// Address, recipient, and date accept content; contacts are usually links.
// Pass image("signature.svg", height: 0.5in) as signature, or leave it empty
// to reserve signature-height for signing by hand.
#let cover-letter(
  name: "",
  contacts: (),
  address: none,
  date: none,
  recipient: none,
  salutation: [Dear Hiring Manager,],
  closing: [Sincerely,],
  signature: none,
  signature-height: 0.75in,
  title: none,
  font: "New Computer Modern",
  mono-font: "Inconsolata",
  link-color: rgb("#006800"),
  text-size: 12pt,
  paper: "us-letter",
  margin: 1in,
  body,
) = {
  let author = plain-text(name)
  set document(
    title: if title == none { "Cover Letter - " + author } else { plain-text(title) },
    author: author,
  )
  set page(paper: paper, margin: margin, numbering: none)
  set text(font: font, size: text-size)
  set align(left)
  // Keep text compact within each block, with generous gaps between blocks.
  set par(justify: true, first-line-indent: 0pt, leading: 0.5em, spacing: 2em)
  set block(above: 2em, below: 2em)
  show link: set text(fill: link-color)

  block(breakable: false)[
    #show link: set text(font: mono-font)
    #strong(name)
    #if address != none {
      linebreak()
      address
    }
    #if contacts.len() > 0 {
      linebreak()
      contacts.join([ #h(0.25em) | #h(0.25em) ])
    }
  ]
  if date != none { block(date) }
  if recipient != none { block(breakable: false, recipient) }
  if salutation != none { block(salutation) }

  body

  block(breakable: false)[
    #set block(above: 0pt, below: 0pt)
    #if closing != none { block(closing) }
    #block(height: signature-height, width: 100%)[
      #if signature != none { align(left + horizon, signature) }
    ]
    #block(name)
  ]
}
