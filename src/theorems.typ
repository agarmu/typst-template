// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Custom exercise layout and mode-aware answers built on Theoretic.

#import "@preview/theoretic:0.4.0"
#import "document-context.typ": document-context
// Mode-aware manual breaks for shared homework/course content.
#let hwbreak() = context if document-context.get().at("mode", default: "full") == "hw" { colbreak() }


// Exercise titles stay beside their numbers, point values align at the far
// right. Spacing separates exercises without decorative bars.
#let show-exercise(it) = {
  let points = it.options.at("points", default: none)
  let point-label = if points == 1 { "point" } else { "points" }
  let head = [#it.supplement]
  if it.number != none { head += [ #it.number] }
  if it.title != none { head += [ (#it.title)] }
  if it.options.at("link", default: none) != none {
    head = link(it.options.link, head)
  }
  // `it.number` is content in theoretic, so compare its rendered value.
  if str(it.number) != "1" { hwbreak() }

  block(
    width: 100%,
    above: 0.8em,
    below: 0.8em,
    inset: (y: 0.3em),
  )[
    #grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      text(weight: "bold", head),
      if points == none { [] } else { text(weight: "bold")[#points #point-label] },
    )
    #v(0.6em)
    #it.body
  ]
}

#let exercise-base = theoretic.theorem.with(
  show-theorem: show-exercise,
  supplement: "Exercise",
  kind: "exercise",
  numbering-depth: 0,
)
#let exercise(points: none, ..args) = exercise-base(
  ..args,
  options: (points: points),
)
#let reset-exercise-counter() = theoretic.thm-counter.update(0)


// Answers use Theoretic's standard proof rendering; the wrapper below adds
// document-mode-aware solution censoring.
#let answer-with-solutions = theoretic.proof.with(supplement: "Answer")

// Partial-censor documents retain homework prompts but omit their solutions.
#let answer(..args) = context {
  if document-context.get().at("mode", default: "full") != "censor-partial" {
    answer-with-solutions(..args)
  }
}
