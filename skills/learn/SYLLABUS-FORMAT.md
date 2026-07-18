# SYLLABUS.md Format

`{subject-slug}/SYLLABUS.md` is the subject's curriculum plan: what the
fundamentals are, how this subject is best taught, and what gets taught next.
Written by the learn skill's ONBOARD phase after the syllabus gate; maintained
**incrementally** ever after — lessons get marked taught, the plan gets
reordered and extended, seeds accumulate. It is never regenerated wholesale,
so no staleness header; `Started:` records when the subject began.

## Structure

```markdown
# Syllabus: {Subject}
Started: {YYYY-MM-DD}

## Learner profile

{Goal, prior knowledge, and desired depth, as captured at the syllabus gate.
2–4 lines. Every lesson calibrates against this.}

## The territory

{Short overview of the domain and its fundamental concepts/skills — the map
the lesson plan walks. 5–10 lines.}

## Teaching approach

{How this subject is best taught and what that means for lesson shape —
e.g. chronological narrative for history, drill-plus-immersion for language,
build-things for technical. 3–6 lines, grounded in the onboarding research.}

Modality: {interactive-first | worked-example-driven | text-forward} —
{the subject's native widget types, e.g. "keyboard diagrams, chord/fingering
steppers" or "state-trace steppers for every worked algorithm" or "narrative
prose; maps/timelines where geography or chronology is load-bearing"}

## Lesson plan

1. [x] {Lesson title} — {one line of scope} (taught {YYYY-MM-DD})
2. [x] {Lesson title} — {one line of scope} (taught {YYYY-MM-DD})
3. [ ] {Lesson title} — {one line of scope}
4. [ ] {Lesson title} — {one line of scope}
...

## Backlog

- {Future-lesson seed} — from lesson {NN} review, {YYYY-MM-DD}
- {Cross-subject candidate relevant to this subject} — ...

## Sources

- [{Source name}]({url}) — {what it anchors, one line}
- ...
```

## Rules

- **Plan numbers are teach order.** The number a lesson is taught under is the
  number its HTML file gets. Reordering the plan is allowed only among
  untaught lessons; taught entries are history and never renumber.
- **First ~5 lessons concrete, the rest coarse.** Detail crystallizes as the
  subject progresses; don't fake precision about lesson 12 at onboarding time.
- **The `Modality:` line is required and set at onboarding.** ONBOARD's
  research must explicitly determine how visual/interactive this subject is
  when taught well and what its native widget types are; TEACH reads this
  line before writing every lesson (see `LESSON-FORMAT.md` "Interactivity &
  visuals"). Revise it if experience shows the subject teaches differently
  than the research suggested.
- **The backlog is where review questions grow into lessons.** A seed promoted
  into the plan is removed from the backlog. Seeds carry their provenance
  (which lesson's review, when) so a future session knows the context.
- **Sources are subject-level anchors** — the canonical texts and references
  the onboarding research surfaced. Per-lesson sources live in the lesson
  files; a per-lesson source worth returning to across the whole subject gets
  promoted here.
- Update inline as things resolve (a taught lesson is marked taught in the
  same session that taught it; a seed lands during the review that surfaced
  it) — don't batch beyond the session's single commit.
