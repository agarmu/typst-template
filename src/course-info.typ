// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Generic data and formatting helpers. This module contains no course data.
#let items(data, key) = {
  let value = data.at(key, default: none)
  if value == none { () } else { value }
}
#let present(value) = value != none and value != ""
#let shown(value, fallback: "to be announced") = if present(value) { str(value) } else { fallback }
#let time-range(entry) = shown(entry.at("start", default: none)) + "–" + shown(entry.at("end", default: none))

#let render-options(selector) = {
  let parts = selector.trim().split(":").map(part => part.trim())
  let mode = parts.first()
  let selection = if parts.len() > 1 { parts.slice(1).join(":").trim() } else { none }
  if not ("full", "censor", "notes", "hws", "hw", "censor-partial").contains(mode) {
    panic("unknown render selector `" + mode + "` in .current")
  }
  (mode: mode, selection: selection)
}

#let parse-zoned-datetime(value) = {
  let value = str(value)
  datetime(
    year: int(value.slice(0, 4)), month: int(value.slice(5, 7)),
    day: int(value.slice(8, 10)), hour: int(value.slice(11, 13)),
    minute: int(value.slice(14, 16)), second: int(value.slice(17, 19)),
  )
}
#let format-due(value) = parse-zoned-datetime(value).display(
  "[weekday repr:short], [month repr:long] [day padding:zero], [year] at [hour repr:12]:[minute] [period case:upper]"
)

// Extract readable text for metadata and title-based selection.
#let plain-text(value) = {
  if type(value) != content { return str(value) }
  let fields = value.fields()
  if "text" in fields { fields.text }
  else if "children" in fields { fields.children.map(plain-text).join() }
  else if "body" in fields { plain-text(fields.body) }
  else if value.func() == [ ].func() or value.func() == linebreak { " " }
  else { repr(value) }
}

#let normalized(value) = lower(plain-text(value))
