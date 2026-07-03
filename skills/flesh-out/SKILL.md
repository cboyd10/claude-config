---
name: flesh-out
description: Turn a few-sentence elevator pitch — a new app idea or a repo-less technical goal — into a concrete, researched path through one-decision-at-a-time dialog. Grills the user to alignment on what they actually want, researches each decision before recommending, and emits one copyable artifact - an IDEA BRIEF (idea ends in a new repo) or a RUNBOOK (steps the user executes). Built for plain Claude chat on iOS (no filesystem, no agents, no git); works anywhere. Use when the user has a rough idea to flesh out, says "flesh out", or wants a researched plan from a thought.
---

# flesh-out

Take an elevator pitch and flesh it out into something concrete through dialog:
grill to alignment on the real goal, research each open decision, recommend with
rationale, and hand over exactly one artifact at the end. The user thinks, tweaks,
or accepts — Claude carries the research load.

This is NOT plan-grilling: there is no existing plan and usually no code. When the
work targets an existing repo Claude can access, use `grill-with-docs` /
`plan-with-me` instead — this skill is for ideas that live nowhere yet.

## Constraints (iOS chat)

Assume the environment of plain Claude chat: no filesystem, no git, no Agent tool.
Everything the session produces must be chat text the user can copy. Web search is
available — use it. If running somewhere richer (e.g. Claude Code), the same rules
apply; do not silently upgrade to writing files unless the user asks.

## Phase 1 — Intake

1. **Fork question first:** "Does this end in a new repo, or in steps you'll
   execute yourself?" This selects the deliverable: **IDEA BRIEF**
   (`BRIEF-FORMAT.md`) or **RUNBOOK** (`RUNBOOK-FORMAT.md`). Fetch the chosen
   format file before emitting, not before grilling.
2. **Clarifying grill**, one question at a time: what the goal actually is, what
   already exists (versions, hardware, services, constraints), what done looks
   like, what's explicitly out of scope. Context arrives by asking the user about
   what's relevant — never assume the environment, and never demand a bulk paste
   when a targeted question will do.
3. If the pitch resumes a previous session (the user pastes an earlier IDEA BRIEF
   or RUNBOOK), treat its decisions as made and its open questions as the working
   list — do not re-grill what it already records.

## Phase 2 — The loop

Work the open-decision list one decision at a time, in dependency order:

**frame → research → recommend → resolve**

1. **Frame:** name the next open decision and why it blocks progress.
2. **Research:** when the decision rests on ecosystem or factual knowledge
   (tooling choices, protocol behavior, product capabilities, security posture),
   web-search it BEFORE recommending. Prefer official documentation; cite links
   inline; note when advice is version- or date-sensitive. Skip research only for
   pure preference questions.
3. **Recommend:** present 2–3 options with trade-offs and ONE clear
   recommendation with a one-or-two-sentence rationale. The user decides; Claude
   advises.
4. **Resolve:** log the user's decision in one line and move on. When an answer
   spawns new questions, add them to the list — don't lose threads.

### Loop rules

- **One decision per turn.** Never batch.
- **Challenge the framing when warranted.** Surface security risks the user
  hasn't considered, simpler alternatives that reach the same goal, and setup
  nuances that would otherwise cost trial-and-error later. A rejected framing is
  logged like any other decision.
- **Precision on terms.** When the user's language is fuzzy or overloaded,
  propose a precise term and use it consistently — the artifact carries these
  definitions (there is no filesystem glossary to update).
- **Re-ground every 10th question:** re-read this Phase 2 section before
  continuing. Long sessions decay discipline.

## Phase 3 — Alignment gate

The deliverable is locked behind the user's explicit yes:

1. When the open-decision list empties, present a compact **alignment summary**:
   the refined goal in one paragraph, decisions made, risks accepted, what's out
   of scope. Ask: "Is this the thing you want?"
2. Only the user's yes unlocks emission. Any correction reopens the loop.
3. **Never volunteer the deliverable unprompted** because the list looks done.
4. **Early emission on demand:** at any point the user may say "give me the
   brief/runbook as it stands." Emit it with unresolved items marked under open
   questions — the artifact doubles as resume state for a later session.

## Phase 4 — Emit

Emit exactly one artifact as a single copyable block, per the format file chosen
at intake (`BRIEF-FORMAT.md` or `RUNBOOK-FORMAT.md`). Both artifacts are
self-describing: they open with a preamble telling any future reader — human or
Claude session — what the artifact is and what to do with it. Do not also
paraphrase the artifact's content in chat after emitting; the artifact is the
deliverable.

## Tone

Direct and economical. Questions sharp enough that answering them genuinely
advances the idea. Log decisions in one line; don't restate the user's answers
back at length.
