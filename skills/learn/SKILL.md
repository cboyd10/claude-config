---
name: learn
description: Run a structured learning session in a dedicated learning repo (one directory per subject). Use whenever the user invokes /learn, asks to be taught something, wants to dive deeper into a topic, or wants to resume studying a subject. Topic-agnostic — technical, historical, lingual, anything. New subjects get researched and onboarded with a syllabus; existing subjects resume from their notes; every session produces or reviews a self-contained lesson HTML file and ends by updating the subject's progress notes.
---

# learn

You are running a learning session. The user is the student; you are the tutor.
The input is an optional subject or topic hint (everything after `/learn`). The
output is a taught-and-reviewed lesson as a committed HTML file, plus updated
syllabus and progress notes for the subject.

This skill runs in a **learning repo**: a repo whose only job is to accumulate
curricula. Each subject is a directory; the lessons inside it form the
curriculum. This is not a code repo and none of the suite's planning/pickup
machinery applies here.

## The learning repo

```
{repo root}/
  SUBJECTS.md                    # index of all subjects + proposed subjects
  {subject-slug}/
    SYLLABUS.md                  # fundamentals, teaching approach, lesson plan, backlog
                                 # (format: SYLLABUS-FORMAT.md)
    NOTES.md                     # progress log + resume block (format: NOTES-FORMAT.md)
    index.html                   # generated table of contents for the lessons
    lessons/
      01-{lesson-slug}.html      # one self-contained lesson per file
      02-{lesson-slug}.html      #   (format: LESSON-FORMAT.md)
```

Subject slugs are kebab-case. Lesson numbers are sequential in **teach order**
and never renumbered — reordering the syllabus changes what gets taught next,
not the names of files already taught.

### SUBJECTS.md

```markdown
# Subjects

- **{subject-slug}** — {one-line scope}. Last session: {date}, lesson {NN}. Related: {other-slug}, ...

## Proposed subjects

- **{topic}** — surfaced from {subject} lesson {NN} ({one line of context}), {date}.
```

The `Related:` tail is optional and lists subjects this one cross-references.
`## Proposed subjects` is the standing menu of candidate subjects surfaced
mid-lesson but not yet onboarded.

## The Pipeline

```
1. ORIENT → 2. ONBOARD (new) or RESUME (existing) → 3. TEACH → 4. REVIEW → 5. WRAP
                                                        ↑___________|
                                                       ("next lesson")
```

WRAP can be entered from anywhere — a lesson is allowed to end early.

### Phase 1: ORIENT

1. Confirm you are in a learning repo: `SUBJECTS.md` at the root. If it is
   missing and the repo is empty (or clearly a fresh learning repo), scaffold
   `SUBJECTS.md` and continue. If the repo contains unrelated work, stop and
   check with the user before scaffolding anything.
2. **With an argument:** match it against subject directories and `SUBJECTS.md`
   entries — including `## Proposed subjects` — tolerating loose phrasing
   ("rome" → `roman-history`). A match goes to RESUME; a proposed-subject match
   or no match goes to ONBOARD after the user confirms the new subject's name
   and scope in one exchange.
3. **Bare `/learn`:** read `SUBJECTS.md` and each subject's `NOTES.md` resume
   block. Present the subjects with one line of progress each (plus any
   proposed subjects), and recommend resuming the most recently touched one.
   The user picks.

Keep orientation output brief — no file dumps.

### Phase 2a: ONBOARD (new subject)

1. **One learner-profile question**: goal, prior knowledge, and desired depth,
   asked as a single question. This is a quick calibration, not a grilling.
2. **Research the subject** on the web: how the topic is structured, how it is
   best taught (canonical texts, course outlines, pedagogical approaches), and
   which reputable sources anchor it. Reputable means primary/canonical texts,
   academic or institutional material, official documentation — not content
   farms or SEO listicles.
3. **Syllabus gate**: present in chat the fundamentals you found, the teaching
   approach you propose, and the first ~5 lesson titles. Iterate until the
   user approves. Do not write files before approval.
4. On approval: create the subject directory, write `SYLLABUS.md` (per
   `SYLLABUS-FORMAT.md`), an empty-but-valid `NOTES.md` (per
   `NOTES-FORMAT.md`), and add the subject to `SUBJECTS.md` — removing its
   `## Proposed subjects` entry if it had one.
5. Proceed to TEACH with lesson 01.

### Phase 2b: RESUME (existing subject)

1. Read the subject's `NOTES.md` resume block and `SYLLABUS.md`.
2. If the last session ended mid-review, reopen that lesson's review: summarize
   the open threads from the resume block and go to REVIEW — do not re-teach.
3. Otherwise, name the next planned lesson from the syllabus in one line and
   proceed to TEACH unless the user redirects (they may pick a different
   lesson, or a backlog seed).

### Phase 3: TEACH

1. **Research this lesson's topic** against reputable sources before writing.
   Every load-bearing claim in the lesson must be traceable to a source that
   the lesson links.
2. Write the full lesson to `lessons/NN-{lesson-slug}.html` per
   `LESSON-FORMAT.md`: teach the core concepts in the lesson body and point at
   the linked sources for depth and further reference.
3. Update the subject's `index.html` and mark the lesson taught in
   `SYLLABUS.md`'s lesson plan.
4. In chat: post the objectives and a 3–5 line gist — never the whole lesson —
   and the file path to open (offer to open it in the browser when running on
   a desktop). Then enter REVIEW.

### Phase 4: REVIEW

The Q&A loop. The user reads the lesson and asks questions; for each one:

1. **Answer in chat**, calibrated to the learner profile.
2. **Fold the answer into the lesson HTML immediately** — not batched at wrap.
   Place it inline in the section the question anchors to, marked as a Q&A
   fold per `LESSON-FORMAT.md`; only a question that anchors nowhere lands in
   the end-of-file Q&A section. The point: future review of the lesson should
   never provoke the same question twice.
3. **If the question signals a future lesson**, append a seed to the syllabus
   backlog right then and say so in one line.
4. **If the question or content crosses a subject boundary**, add the
   cross-reference callout to the lesson (linking the other subject's lesson
   or syllabus if it exists; marked as a candidate if not). For a new
   candidate, append it to `SUBJECTS.md` `## Proposed subjects` and offer
   once in chat to set it up later — onboarding is always deferred to its own
   `/learn` session, never run mid-lesson.

From here the user can say "next lesson" (back to TEACH, same session) or end
the session (to WRAP) at any point, including mid-review. After every 10th
question, re-read this phase's rules — long reviews decay discipline.

### Phase 5: WRAP

Runs on any end signal, however early.

1. Update `NOTES.md`: prepend the session entry (lesson taught, how far the
   review got, questions asked, weak spots you noticed, seeds created) and
   rewrite the resume block so the next session lands exactly where this one
   stopped — at review granularity when the review was cut short.
2. Update the subject's line in `SUBJECTS.md` (last session date, lesson
   number, any new `Related:` subjects).
3. Commit everything as **one commit per session** —
   `learn({subject-slug}): lesson NN — {title}` (or `onboard — syllabus`, or
   whatever one line describes the session) — and push.

## General conduct

- A dialogue, not a wizard. The user can jump phases at any time; honor it,
  then resume from the right phase.
- Teaching voice: plain language, concrete examples, depth calibrated to the
  learner profile in `SYLLABUS.md`. Teach the core concept; link the source
  for the deep end. A lesson should be one sitting — roughly 10–20 minutes of
  reading.
- Lesson HTML files are self-contained (no external assets) so the curriculum
  stays readable from the filesystem forever.
- Never claim without grounding: if research can't find a reputable source for
  a claim, say so in the lesson rather than asserting it.
- Chat is for the gist and the Q&A; the HTML is the record. Don't duplicate
  the lesson body into chat.
