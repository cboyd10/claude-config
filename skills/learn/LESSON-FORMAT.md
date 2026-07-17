# Lesson HTML Format

`{subject-slug}/lessons/NN-{lesson-slug}.html` is one lesson: a complete,
self-contained HTML document. The numbered files together are the curriculum,
readable from the filesystem with no server, no build step, and no network —
which is why everything (CSS included) is inline and no external assets are
ever referenced. Lessons are also read in environments that **never execute
JavaScript** (the iOS app renders lesson HTML with scripts stripped), so the
lesson must be complete without any script — see "Interactivity & visuals"
below. Written by the learn skill's TEACH phase; amended in place by REVIEW's
Q&A folding.

## Document structure

In order:

1. **Header** — lesson number and title, subject, taught date, and
   prerequisite links (relative links to earlier lesson files).
2. **Objectives** — 2–4 bullets: what the learner should be able to explain or
   do afterward.
3. **Core content** — the teaching, in `<h2>` sections with concrete examples,
   calibrated to the syllabus's learner profile and teaching approach. Teach
   the core concept in the body; where a source carries the depth, say so and
   link it inline. Visuals and widgets follow "Interactivity & visuals" below
   and the subject's modality line in `SYLLABUS.md`. Cross-reference callouts
   and Q&A folds live inline here, inside the section they belong to.
4. **Self-check** — 3–5 recall/comprehension questions, each answer inside a
   `<details>` so future review is active, not passive.
5. **Sources & further reading** — the reputable sources this lesson is
   grounded in, each with one line on what to read it for. Every load-bearing
   claim in the content must be traceable to something in this list (or to an
   inline-linked source).
6. **Q&A** — fallback section for review answers that anchor to no single
   content section. Omit until needed.

## Interactivity & visuals

How much of the lesson is widgets vs. prose is a **subject-level decision**:
the `Modality:` line in the syllabus's Teaching approach section (set from
ONBOARD's pedagogy research) says whether this subject teaches
interactive-first (piano: keyboard diagrams and drills, text as connective
tissue), worked-example-driven (LLMs: visualize every state trace), or
text-forward (history: narrative prose, maps/timelines where load-bearing).
Read it before writing; don't re-improvise the decision per lesson.

Underneath the modality, two **section-level floors** apply to every subject:

- **State changing across steps** — an algorithm run, a pipeline, a process
  unfolding — is taught with a step-through widget (stepper pattern in
  `WIDGETS.md`), and the widget **replaces** the prose/`<pre>` trace of the
  same steps. Never both: a visual and a static trace of the same walk-through
  re-teach the material twice and read as two different things.
- **Static structure** — architecture, relationships, geometry, anything you'd
  sketch on a whiteboard — gets an inline SVG diagram. Tables stay for short
  enumerable facts.

**JavaScript is banned in the baseline.** Every widget must fully work with
zero JS — CSS-only mechanisms (radio/checkbox state, `<details>`, `:target`),
CSS animations, and inline SVG cover the patterns in `WIDGETS.md`. A lesson
that needs a script to teach is broken on the primary reading environment.

**Optional enhancement tier, per widget:** when JS would genuinely deepen a
widget (free input, autoplay, keyboard navigation), it may be layered on top
of a pedagogically complete CSS baseline using the detect-and-swap pattern in
`WIDGETS.md`: the markup ships with the baseline active plus a visible
"enhanced version — open on a computer" badge, and the inline script — when it
runs — hides the badge and activates the enhancement. Where scripts don't
execute, the reader gets the full lesson plus the signal to revisit on
desktop. The enhancement may deepen a concept, never carry one; most widgets
should stay pure CSS.

## Writing rules (clarity)

These exist because review questions cluster around the same failure shapes;
each rule kills one shape at writing time.

- **Worked examples state their setup before their mechanics.** Open with
  what the example is establishing and what the toy setup stands in for
  ("these four words are a miniature corpus; watch which pair merges first") —
  then run the mechanics. A frequency table or toy artifact dropped in cold is
  a review question waiting to happen.
- **No unexplained leaps.** Never *use* a value, artifact, or mapping before
  showing where it comes from — or explicitly defer it with a pointer ("IDs
  are just indices into the vocabulary; the mapping is shown in the next
  section" / "…covered in lesson 04"). Each step of a pipeline is shown or
  visibly deferred, never silently assumed.
- **Mechanism before assertion.** For a learner profile that wants
  under-the-hood rigor, a claim like "the table is learned" needs at least a
  conceptual mechanism sketch (or an explicit forward-pointer to the lesson
  that covers it) at the point of first assertion.
- **Gloss terms of art inline on first use.** Keep the elevated term — the
  gloss teaches the vocabulary rather than avoiding it. Mark the term with
  `<dfn>` and follow it with a brief, **always-visible** parenthetical:
  `a <dfn>corpus</dfn> (the body of text a model learns from)`. Never hide a
  gloss behind hover or tap — hover doesn't exist on touch. What needs
  glossing is judged against the learner profile; subsequent uses are bare.

## Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{NN}. {Lesson title} — {Subject}</title>
<style>
  :root { color-scheme: light dark; }
  body { max-width: 46rem; margin: 2rem auto; padding: 0 1rem;
         font: 1.05rem/1.6 system-ui, sans-serif; }
  header { border-bottom: 1px solid color-mix(in srgb, currentColor 25%, transparent);
           padding-bottom: .75rem; margin-bottom: 1.5rem; }
  header .meta { font-size: .85rem; opacity: .7; }
  aside { border-left: 3px solid; padding: .5rem .75rem; margin: 1rem 0;
          border-radius: 0 .25rem .25rem 0;
          background: color-mix(in srgb, currentColor 6%, transparent); }
  aside.crossref { border-color: #3b82f6; }
  aside.qa       { border-color: #10b981; }
  aside .tag { font-size: .75rem; font-weight: 600; text-transform: uppercase;
               letter-spacing: .05em; opacity: .7; display: block; }
  details { margin: .5rem 0; }
  dfn { font-style: normal; text-decoration: underline dotted; text-underline-offset: .2em; }
  code, pre { font-family: ui-monospace, monospace; }
  pre { overflow-x: auto; padding: .75rem;
        background: color-mix(in srgb, currentColor 8%, transparent); }
</style>
</head>
<body>
<header>
  <h1>{NN}. {Lesson title}</h1>
  <p class="meta">{Subject} · taught {YYYY-MM-DD} ·
     prerequisites: <a href="{MM}-{slug}.html">{MM}. {title}</a></p>
</header>

<section>
  <h2>Objectives</h2>
  <ul>
    <li>{Explain/do X}</li>
  </ul>
</section>

<section>
  <h2>{Content section}</h2>
  <p>{Teaching, with concrete examples. Load-bearing claims link their source
     inline: ... as <a href="{url}">{source}</a> lays out in depth.}</p>

  <aside class="crossref">
    <span class="tag">Crosses into: {subject}</span>
    {One line on the overlap.} See <a href="../../{subject-slug}/lessons/{NN}-{slug}.html">{subject} lesson {NN}</a>.
    <!-- or, when the subject doesn't exist yet: -->
    {One line on the overlap.} <em>Candidate subject — proposed in SUBJECTS.md.</em>
  </aside>

  <aside class="qa">
    <span class="tag">From review Q&amp;A · {YYYY-MM-DD}</span>
    <p><strong>{The question, compressed.}</strong> {The answer, folded in so
    this lesson never provokes the question again.}</p>
  </aside>
</section>

<section>
  <h2>Self-check</h2>
  <details><summary>{Question 1}</summary><p>{Answer}</p></details>
</section>

<section>
  <h2>Sources &amp; further reading</h2>
  <ul>
    <li><a href="{url}">{Source}</a> — {what to read it for, one line}</li>
  </ul>
</section>

<!-- Only when a review answer anchors to no single section:
<section>
  <h2>Q&amp;A</h2>
  <aside class="qa">...</aside>
</section>
-->
</body>
</html>
```

## index.html (per subject)

A minimal generated table of contents, same self-contained styling: the
subject as `<h1>`, then an ordered list linking each taught lesson —
`{NN}. {title} — taught {date}` — with untaught planned lessons listed
unlinked and dimmed below. Regenerated by TEACH after each new lesson; it is
derived from the syllabus and never hand-edited.

## Rules

- **Self-contained, forever.** Inline CSS only; no external scripts, fonts,
  images, or stylesheets. Relative links between lesson files and subjects
  are the only references to anything local.
- **No `<script>` in the baseline.** The lesson must be complete and every
  widget fully usable with scripts stripped (that is what the iOS app
  renders). Inline scripts appear only inside the per-widget enhancement
  pattern from `WIDGETS.md`, layered on a complete CSS-only baseline with the
  visible fallback badge.
- **A widget replaces the prose trace it visualizes** — never ship both a
  stepper and a static walk-through of the same steps.
- **Q&A folds are placed, not appended.** The default home for a folded
  answer is inside the content section it anchors to; the end-of-file Q&A
  section is the fallback, not the habit. Every fold carries its date tag.
- **Cross-reference callouts appear whether or not the other subject
  exists** — existing subjects get a relative link; missing ones get the
  candidate marker.
- **Sources must be reputable**: primary/canonical texts, academic or
  institutional material, official documentation. If nothing reputable
  grounds a claim, the lesson says the claim is uncertain instead of
  asserting it.
- Keep a lesson to one sitting — roughly 10–20 minutes of reading. A topic
  that wants more is two lessons.
