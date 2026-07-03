# ORIENTATION.md Format

`.claude/context/ORIENTATION.md` is the repo-level ORIENTATION BRIEF: a
machine-derived structural map of the codebase, written by `bootstrap-context`
for two readers — the ORIENT phase of a later session (via
`grill-with-docs/EXPLORATION.md`) and a junior developer on day one.

It is a **map, not truth**. It is regenerated wholesale on every
`bootstrap-context` refresh run; hand edits will be lost. Consumers must check
the `Derived:` commit hash — if HEAD has moved, re-verify any claim a decision
will rest on before relying on it.

## Structure

```markdown
# Orientation: {repo name}
Derived: {YYYY-MM-DD} at commit {short-hash}

{One paragraph: what this repo is, who uses it, and what it talks to.}

## Module map

- `{path}/` — {what lives here, one line}
- `{path}/` — ...

## Entry points

- {How the app starts / where each main flow begins} — `{file}`
- ...

## Conventions

- {The convention, one line} — copy `{exemplar file}`
- ...

## Gotchas

- {The surprising thing and why it bites} — `{file:line}`
- ...
```

## Rules

- **Junior-first voice.** Assume a competent developer who has never seen this
  repo. No undefined acronyms — link `.claude/context/CONTEXT.md` terms or
  spell them out.
- **Every claim cites a file.** A module-map line names its path; a convention
  names exactly one exemplar file to copy; a gotcha cites where the evidence
  lives. Uncited claims don't go in.
- **Structure over meaning.** Domain terms and their definitions belong in
  `CONTEXT.md`; this brief says where things are and how to move around, not
  what things mean.
- **Keep it under ~120 lines.** It is an entry ramp, not documentation — the
  layered docs (where they exist) carry the depth.
- Sections with nothing verified to say are omitted, not padded.
