// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Custom exercise layout and mode-aware answers built on Theoretic.

#import "@preview/theoretic:0.4.0"
#import "document-context.typ": document-context

// Manual break for content shared between course and standalone-homework modes.
#let hwbreak() = context if document-context.get().at("mode", default: "full") == "hw" { colbreak() }

// Exercise titles stay beside their numbers, point values align at the far
// right, and a colored bar spans the full exercise.
#let show-exercise(it) = {
  let number-inside = it.options.at("number-inside", default: auto)
  set enum(numbering: number-inside) if number-inside != auto
  let c = oklch(65%, 0.15, 250deg)
  let body-color = c.mix((c, 50%), (black, 50%), space: oklab)
  let color = body-color
  let points = it.options.at("points", default: none)
  let point-label = if points == 1 { "point" } else { "points" }
  let head = [#it.supplement]
  if it.number != none { head += [ #it.number] }
  if it.title != none { head += [ (#it.title)] }
  if it.options.at("link", default: none) != none {
    head = link(it.options.link, head)
  }
  let rendered-exercise = block(
    width: 100%,
    above: 0.8em,
    below: 0.8em,
    stroke: (left: 0.2em + color),
    inset: (left: 0.8em, y: 0.3em),
  )[
    #grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      text(weight: "bold", fill: color, head),
      if points == none { [] } else { text(weight: "bold", fill: color)[#points #point-label] },
    )
    #v(0.6em)
    #text(fill: body-color)[#it.body]
  ]

  context {
    let config = document-context.get()
    if config.at("mode", default: "full") == "hw" {
      let page-size = config.at("page-size")
      let margin = config.at("page-margin")
      let page-body = if str(it.number) == "1" {
        [#config.at("homework-header", default: []) #rendered-exercise]
      } else {
        rendered-exercise
      }
      let body-height = measure(page-body, width: page-size.width - 2 * margin).height
      let fitted-height = calc.min(body-height + 2 * margin, page-size.height)
      page(
        width: page-size.width,
        height: fitted-height,
        margin: margin,
        page-body,
      )
    } else {
      rendered-exercise
    }
  }
}

#let exercise-base = theoretic.theorem.with(
  show-theorem: show-exercise,
  supplement: "Exercise",
  kind: "exercise",
  numbering-depth: 0,
)
// Set number-inside to an enum numbering pattern or function; auto inherits
// the surrounding enum style. Example: exercise.with(number-inside: "(a)").
#let exercise(points: none, number-inside: auto, ..args) = exercise-base(
  ..args,
  options: (points: points, number-inside: number-inside),
)
#let reset-exercise-counter() = theoretic.thm-counter.update(0)


// Answers use Theoretic's standard proof rendering; the wrapper below adds
// document-mode-aware solution censoring.
#let answer-with-solutions = theoretic.proof.with(
  supplement: "Answer",
  options: (
    head-font: (fill: black),
    body-font: (fill: black),
  ),
)

// Partial-censor documents retain homework prompts but omit their solutions.
#let answer(..args) = context {
  if document-context.get().at("mode", default: "full") != "censor-partial" {
    answer-with-solutions(..args)
  }
}
