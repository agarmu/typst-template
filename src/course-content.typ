// SPDX-FileCopyrightText: 2026 Mukul Agarwal
// SPDX-License-Identifier: AGPL-3.0-only

// Reusable front-matter and document orchestration functions. Every value
// needed for rendering is supplied explicitly by the caller.
#import "course-info.typ": items, present, shown, time-range
#import "book-content.typ": bookmark
#import "authors.typ": author-block

#let instructor-names(instructors) = instructors.filter(
  person => person.at("role", default: "") == "Instructor",
).map(person => person.at("name", default: ""))

#let meeting-description(meetings) = if meetings.len() == 0 {
  "To be announced."
} else {
  meetings.map(meeting => {
    let location = meeting.at("location", default: none)
    meeting.at("day", default: "") + " from " + time-range(meeting) + (if present(location) { " in " + str(location) } else { "" })
  }).join("; ") + "."
}

#let exam-description(exams) = if exams.len() == 0 {
  "To be announced."
} else {
  exams.map(exam => {
    let name = exam.at("name", default: exam.at("id", default: "Exam"))
    let date = exam.at("date", default: none)
    let time = exam.at("time", default: none)
    let location = exam.at("location", default: none)
    if not present(date) { name + " is to be announced." } else {
      name + " is on " + str(date) + (if present(time) { " " + str(time) } else { "" }) + (if present(location) { " in " + str(location) } else { "" }) + "."
    }
  }).join(" ")
}

#let document-title(name: none, code: none, term: none, author: none, author-label: none, subtitle: none) = align(center)[
  #v(2.7em, weak: false)
  #text(size: 1.667em)[#name]
  #if present(author) { v(0.65em); text(size: 1em, author-block(author, label: author-label)) }
  #if subtitle != none { v(0.65em); text(size: 1.25em)[#subtitle] }
  #v(1.15em)
  #code
  #v(1.1em)
  #term
]

#let course-cover(name: none, code: none, term: none, author: none, author-label: none, institution: none, description: none, instructors: (), epigraph: none) = {
  bookmark([Title Page])
  let names = instructor-names(instructors)
  let professor = if names.len() > 0 { names.first() } else { none }
  let has-description = present(description) and description != "todo"
  align(center, {
    v(0.3fr); text(size: 1.2em, code); v(0.1fr)
    text(size: 2em, name)
    if present(author) { v(1em); text(size: 1.1em, author-block(author, label: author-label)) }
    v(0.6fr)
    let terminfo = if present(institution) { [#institution, #term] } else { term }
    text(size: 1.25em, terminfo); v(.1fr)
    if professor != none { text(size: 1.25em)[Prof. #professor] }
    v(0.65fr)
    if epigraph != none {
      block(
        width: 80%,
        inset: (x: 0.5em, y: 0.8em),
      )[
        #set par(justify: false, first-line-indent: 0em)
        #emph(epigraph)
      ]
      v(0.35fr)
    }
    if has-description {
      block(width: 82%)[
        #set text(size: 0.833em)
        #set par(justify: true)
        #align(left)[*Course Description:* #description]
      ]
    }
    v(.3fr)
  })
  pagebreak()
}

#let staff-details(person) = {
  let role = person.at("role", default: "Course staff")
  let name = person.at("name", default: "")
  let email = person.at("email", default: none)
  let office = person.at("office", default: none)
  let hours-text = items(person, "office-hours").map(hour =>
    hour.at("day", default: "") + ", " + time-range(hour) + (if present(hour.at("location", default: none)) and hour.at("location") != "office" {
        " in " + str(hour.at("location"))
      } else { "" })
  ).join("; ")
  [
    #if role == "Instructor" { [Prof. ] }#name
    #if present(email) { linebreak(); link("mailto:" + email, text(size: 0.85em, email)) }
    #linebreak()
    #if office != none { [Office: #shown(office) #linebreak()] }
    Office Hours: #shown(if hours-text == "" { none } else { hours-text })
  ]
}

#let front-matter(name: none, code: none, term: none, author: none, author-label: none, institution: none, description: none, instructors: (), meetings: (), exams: (), epigraph: none) = {
  course-cover(name: name, code: code, term: term, author: author, author-label: author-label, institution: institution,
    description: description, instructors: instructors, epigraph: epigraph)
  bookmark([Front Matter])
  set par(first-line-indent: 0em, justify: false)
  block(above: 0em, below: 0.65em)[#text(weight: "bold")[Course Meetings:] #meeting-description(meetings)]
  if exams.len() > 0 {
    block(above: 0em, below: 0.65em)[#text(weight: "bold")[Exams:] #exam-description(exams)]
  }
  if instructors.len() > 0 {
    v(1.35em)
    let ta-count = instructors.filter(person => person.at("role", default: "") == "TA").len()
    let rows = instructors.enumerate().map(entry => {
      let (index, person) = entry
      let is-ta = person.at("role", default: "") == "TA"
      let earlier = instructors.slice(0, index).filter(prior => prior.at("role", default: "") == "TA").len()
      let label = if is-ta and earlier > 0 { [] } else if is-ta and ta-count > 1 { [Teaching Assistants] }
        else if is-ta { [Teaching Assistant] } else { person.at("role", default: "Course Staff") }
      (if label == [] { [] } else { text(weight: "bold")[#label:] }, staff-details(person))
    }).flatten()
    grid(columns: (auto, 1fr), column-gutter: 1em, row-gutter: 1.35em,
      align: (left, left), ..rows)
  }
}

#let course-document(name: none, code: none, term: none, author: none, author-label: none, institution: none, description: none, instructors: (),
  meetings: (), exams: (), mode: "full", notes: none, homework: none, epigraph: none) = {
  let title(subtitle: none) = document-title(name: name, code: code, term: term,
    author: author, author-label: author-label, subtitle: subtitle)
  let front() = front-matter(name: name, code: code, term: term, author: author, author-label: author-label,
    institution: institution, description: description, instructors: instructors,
    meetings: meetings, exams: exams, epigraph: epigraph)
  let contents() = { pagebreak(); outline(title: [Table of Contents]); pagebreak() }
  let appendix() = {
    pagebreak()
    set heading(numbering: "A.1")
    counter(heading).update(0)
    heading(level: 1, outlined: true)[Homework Assignments]
    homework
  }
  if mode == "full" or mode == "censor-partial" { front(); contents(); notes; appendix() }
  else if mode == "censor" { front(); contents(); notes }
  else if mode == "notes" { title(subtitle: [Lecture Notes]); contents(); notes }
  else if mode == "hws" { title(subtitle: [Homework]); v(1.5em); homework }
  else if mode == "hw" { homework }
}
