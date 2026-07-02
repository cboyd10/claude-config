---
name: deconstruct
description: Break an oversized plan or scope into smaller, self-contained pieces — each saved as a handoff document that can seed its own grill-with-docs session in a fresh Claude Code session. Use whenever a plan is too large to grill or implement well in one sitting: when it spans multiple bounded contexts, bundles several independent sub-goals, carries too many distinct decisions to resolve in one pass, or sprawls across many unrelated parts of the codebase. grill-with-docs recommends this skill when scope balloons. Reach for it any time you sense a request is "too big for one session" — even if the user hasn't used the word "deconstruct."
---

Deconstruct an oversized scope into smaller pieces that can each be grilled and built in their own Claude Code session. You are a seam-finder, not a planner: find the cut lines, save them, and stop. The deep design work happens later, per piece, in grill-with-docs.

Read any existing `.claude/context/CONTEXT.md`, `.claude/context/CONTEXT-MAP.md`, and ADRs (`docs/adr/` in work repos, `.claude/context/adr/` in personal repos) first — they tell you where the seams already are.

## 1. Gate: should this be deconstructed at all?

Decide this before anything else. Splitting is not free, and a forced split is worse than no split.

Strong signals to deconstruct:
- The scope spans more than one bounded context. If a `CONTEXT-MAP.md` exists, contexts are the cleanest seam there is — cut there first.
- The scope bundles several independent sub-goals — deliverables that don't need to share a single resolved design decision, and only happen to be requested together.

Secondary, corroborating signals:
- Too many distinct design decisions to resolve well in one sitting.
- The work touches many unrelated parts of the codebase.

If none of these hold, **do not split.** Say so plainly and hand back to grill-with-docs as a single session. A small scope grilled in one go is the correct outcome.

## 2. Grill only enough to find the seams

If the gate passes, grill — but shallowly. Your job is to map the cut lines, not to resolve what's inside any piece.

- Interview one question at a time, waiting for feedback before continuing. For each question, give your recommended answer.
- If a question can be answered by exploring the codebase, explore instead of asking.
- Grill toward sub-goals, dependencies, and boundaries — nothing deeper. The moment you find yourself resolving a decision that belongs *inside* a piece, stop: that's the per-piece grill-with-docs session's job, not yours. Pulling it forward rebuilds the oversized session you're trying to escape.
- When the user uses a term that conflicts with the glossary in `.claude/context/CONTEXT.md`, call it out immediately.

## 3. Don't force a bad split

If the seams are tangled — every candidate piece is entangled with every other, and no cut leaves clean, separately-grillable pieces — **refuse to split.** Name the coupling: say what is entangling the pieces. Then recommend either proceeding as a single grill-with-docs session, or, if the coupling looks accidental rather than essential, pointing the user at an architecture/refactor skill (e.g. `/improve-codebase-architecture`) first.

"Too small to split" and "too tangled to split" are the two ways this skill correctly produces zero pieces.

## 4. Sequence the pieces

Pieces are rarely fully independent. Once you have them:

- Record each piece's dependencies (which other pieces must be resolved first).
- Emit a recommended order from the dependency graph: pieces with no unresolved upstream go first. Mark pieces with no dependencies between them as parallelizable ("grill in any order").

The order matters because a downstream piece's grill needs its upstream pieces' resolved decisions in hand.

## 5. Write the output

All output goes under `.claude/deconstructions/<scope-name>/`:

```
.claude/deconstructions/<scope-name>/
├── manifest.md          ← the map: pieces, sequence, rationale, relationships
├── 01-<piece-slug>.md   ← handoff doc, one per piece
├── 02-<piece-slug>.md
└── ...
```

Create these lazily — only once you actually have pieces to write.

### manifest.md

The manifest is mandatory and must capture enough to drive separate future sessions with no memory of this one. Include:
- **Scope** — the original request, in a sentence or two.
- **Why split** — the rationale (which signals from the gate fired).
- **Pieces** — each with its one-line goal and a link to its handoff doc.
- **Sequence** — the recommended order, with parallelizable pieces flagged.
- **Relationships** — the dependencies between pieces (what blocks what), and which contexts each piece touches if a `CONTEXT-MAP.md` exists.
- **Progress** — a simple checklist the user can tick as each piece's session completes.

### handoff doc (per piece)

Each handoff doc seeds one fresh grill-with-docs session. Keep it lightweight by *referencing* shared docs, never duplicating them. Include:
- **Goal** — what this piece achieves on its own.
- **Boundaries** — explicitly in scope and explicitly out of scope (out-of-scope items name the sibling piece that owns them).
- **Depends on** — upstream pieces and what resolved decision this piece needs from each.
- **Context** — pointers to the relevant `CONTEXT.md` / ADRs / `CONTEXT-MAP.md` entries, not copies of them.
- **Next step** — "Open a new session and run grill-with-docs on this document."

## 6. ADRs: only for real architecture

Do **not** write an ADR for the split itself. "We divided this work into three pieces and grill them A→B→C" is a planning decision — it lives in the manifest under `.claude/deconstructions/`, not in the project's shared ADR directory.

The one exception: if the seam-finding grill surfaces a genuine architectural decision — non-obvious, with real trade-offs, about the system itself (e.g. "billing and ordering must remain separate contexts") — record that as an ADR inline, using the format in `docs-formats/ADR-FORMAT.md`. Architecture decisions earn ADRs; workflow ephemera do not.

## Done

When the manifest and handoff docs are written, stop. Tell the user the recommended first piece and remind them each piece gets its own fresh session via grill-with-docs.
