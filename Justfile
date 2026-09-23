# SPDX-FileCopyrightText: 2026 Mukul Agarwal
# SPDX-License-Identifier: AGPL-3.0-only

test *cases:
    python3 tests/run.py {{cases}}

update-tests *cases:
    python3 tests/run.py --update {{cases}}

prep:
    mkdir -p build/examples build/docs

clean:
    rm -rf build

example name: prep
    typst compile --root . --pdf-standard a-1b {{quote("examples/" + name + ".typ")}} {{quote("build/examples/" + name + ".pdf")}}

manual: prep
    typst compile --root . --pdf-standard a-1b docs/manual.typ build/docs/manual.pdf

[parallel]
examples: (example "academic-notes") (example "book") (example "compact-notes") (example "standalone-homework")

[parallel]
build: examples manual
