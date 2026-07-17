# Lesson Widget Patterns

CSS-only interactive patterns for lesson HTML, plus the one sanctioned way to
layer JavaScript on top. Consumed by the learn skill's TEACH phase whenever
"Interactivity & visuals" in `LESSON-FORMAT.md` calls for a widget. Every
pattern here works with scripts stripped — the iOS app's rendering mode — and
from the filesystem with no network.

## Why CSS-only

Lesson HTML is read in environments that never execute JavaScript. A widget
that needs a script to function is a broken widget on the primary reading
device. CSS state mechanisms (radio/checkbox `:checked`, `<details>`,
`:target`) plus CSS animations and inline SVG cover every pattern a lesson
has needed so far; reach for the enhancement tier only when they genuinely
can't express the interaction.

## Pattern: step-through (stepper)

For state changing across steps — algorithm runs, pipelines, processes. One
hidden radio per step; each step's panel is shown by its radio's `:checked`;
Prev/Next are `<label for>` targeting the adjacent radios. Proven in
`llms/lessons/01-tokenization-and-embeddings.html` (BPE merge walkthrough).

```html
<div class="stepper">
  <input class="step-radio" type="radio" name="{id}-step" id="{id}-s0" checked>
  <input class="step-radio" type="radio" name="{id}-step" id="{id}-s1">
  <!-- one radio per step, all BEFORE the panels (CSS ~ sibling selector) -->

  <div class="step-panel" data-step="0">
    <div class="step-head">
      <span class="step-btn step-btn-disabled">&#9664; Prev</span>
      <span class="step-label">Step 0 of N &mdash; {what this step shows}</span>
      <label class="step-btn" for="{id}-s1">Next &#9654;</label>
    </div>
    {step content}
    <p class="step-note">{one line: what changed and why}</p>
  </div>
  <!-- one panel per step; first/last use a disabled span for the dead arrow -->
</div>
```

```css
.stepper { margin: 1rem 0; padding: 1rem; border-radius: .5rem;
           border: 1px solid color-mix(in srgb, currentColor 20%, transparent); }
.step-radio { position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none; }
.step-panel { display: none; }
.step-head { display: flex; align-items: center; gap: .75rem; flex-wrap: wrap; margin-bottom: .75rem; }
.step-btn { font: inherit; padding: .3rem .8rem; border-radius: .3rem;
            border: 1px solid currentColor; cursor: pointer; display: inline-block; }
.step-btn-disabled { opacity: .35; cursor: default; }
.step-note { font-size: .85rem; opacity: .8; margin-top: .5rem; min-height: 2.4em; }
#{id}-s0:checked ~ .step-panel[data-step="0"] { display: block; }
#{id}-s1:checked ~ .step-panel[data-step="1"] { display: block; }
/* one line per step */
```

Conventions that make steppers teach well:

- **Each panel is self-sufficient**: full state visible, not a diff — the
  reader may land on any step.
- **Highlight what just changed** (a `.just-changed` class with a short CSS
  `@keyframes` pulse) and dim what's inert.
- **The step note carries the "why"** — the panel shows state, the note says
  why this transition happened ("e+s appears 9 times — most frequent pair").
- Fixed `min-height` on variable-height content areas where practical, so
  stepping doesn't make the page jump.
- Give buttons touch-sized hit areas (the padding above); never rely on
  `:hover` for anything — hover doesn't exist on touch.

## Pattern: reveal

`<details><summary>` for self-checks, optional depth, and asides the reader
opts into. Native, free, works everywhere. Don't use it for glosses (those
are always-visible parentheticals per `LESSON-FORMAT.md`) or for anything
the lesson requires the reader to have seen.

## Pattern: toggle / compare

A hidden checkbox with `<label>` to flip between two views (before/after,
naive/optimized, notation A/B):

```html
<input class="toggle-box" type="checkbox" id="{id}-toggle">
<label class="step-btn" for="{id}-toggle">Show {other view}</label>
<div class="view-a">…</div>
<div class="view-b">…</div>
```

```css
.toggle-box { position: absolute; width: 1px; height: 1px; opacity: 0; }
.view-b { display: none; }
#{id}-toggle:checked ~ .view-a { display: none; }
#{id}-toggle:checked ~ .view-b { display: block; }
```

## Pattern: inline SVG diagram

For static structure — architecture, relationships, geometry, timelines,
maps, a piano keyboard. Inline `<svg>` in the body, `currentColor` for
strokes/text so it follows light/dark, `max-width: 100%` so it fits a phone.
CSS `@keyframes` on SVG elements (dash-offset draws, pulses, fades) are fine
and often enough "animation" to carry a dense diagram. Label parts inside the
SVG rather than in a caption legend the eye has to shuttle to.

## Pattern: JS enhancement layer (the only sanctioned `<script>`)

When JS would genuinely deepen a widget — free input ("type a word, watch it
tokenize"), autoplay, keyboard navigation — layer it on top of a complete
CSS baseline. Detect-and-swap:

```html
<div class="widget" id="{id}">
  <p class="enhance-badge">&#9889; An enhanced interactive version of this
     widget exists &mdash; open this lesson on a computer to use it.</p>
  <!-- CSS-only baseline widget: fully teaches the concept on its own -->
  <!-- enhanced controls, hidden until the script activates them -->
  <script>
    document.getElementById('{id}').classList.add('js');
  </script>
</div>
```

```css
.enhance-badge { font-size: .85rem; padding: .4rem .6rem; border-radius: .3rem;
                 background: color-mix(in srgb, currentColor 8%, transparent); }
.widget.js .enhance-badge { display: none; }
.widget .enhanced { display: none; }
.widget.js .enhanced { display: block; }
/* the .js class may also hide baseline controls the enhancement replaces */
```

Rules:

- **The badge is hidden only by the script running.** No script execution →
  baseline widget + visible badge, automatically. That badge is the signal to
  revisit the lesson on a computer; never omit it.
- **The baseline must be pedagogically complete.** The enhancement deepens a
  concept; it never carries one. If removing the script loses teaching
  content (not just delight), the widget is misdesigned.
- **Per widget, opt-in, rare.** Most widgets stay pure CSS; use this tier
  only where the interaction is impossible in CSS, not as a default.
