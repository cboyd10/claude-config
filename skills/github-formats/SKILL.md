---
name: github-formats
description: Canonical templates for GitHub issues created from personal-project planning sessions. Defines the issue body structure (Summary, Autonomy, Context, Acceptance Criteria, Implementation Notes, Out of Scope), the afk/hitl autonomy classification and its labels, and the worktree/branch/ADR naming conventions shared across the personal skills. Use when plan-to-github needs to format an issue, when pickup-issue-personal needs to parse one, or whenever you need the agreed personal-project conventions. Consumed by plan-to-github and plan-with-me-personal; read by pickup-issue-personal. The GitHub equivalent of jira-formats.
---

# github-formats

The shared format and convention layer for personal-project planning. Both
`plan-with-me-personal` (via `plan-to-github`) and `pickup-issue-personal` rely on
these definitions so that what one skill writes, the other can read.

These are designed first for a **Claude Code agent** to parse and act on reliably,
and second to stay scannable for a human reviewing in the GitHub UI. The structure is
predictable on purpose: every issue has the same sections in the same order.

## Issue body template

Every issue uses exactly these sections, in this order. Omit a section only if it is
genuinely empty (e.g. nothing is out of scope) — and prefer writing "None." over
deleting the heading, so the shape stays uniform.

```markdown
## Summary
One short paragraph: what the change is and why it matters. No implementation here.

## Autonomy
`afk` — <one-line justification of why an agent can complete this unattended>
<!-- or -->
`hitl` — <one line naming the human judgment / decision this issue still needs>

## Context
Relevant files, modules, and prior issues. Link related issues with #<number>.
Point at domain terms in `.claude/context/CONTEXT.md` where they apply. This is the
orientation an agent needs before touching code — give it the map, not the territory.

## Acceptance Criteria
- [ ] Concrete, individually verifiable outcomes.
- [ ] For `afk` issues: precise enough to verify mechanically, with no open judgment.
- [ ] Phrased as observable behavior or state, not implementation steps.

## Implementation Notes
Suggested approach, existing patterns to follow, known gotchas. Be MORE prescriptive
for `afk` issues (file paths, function names, example payloads) because no grilling
will fill the gaps. Be LIGHTER for `hitl` issues — the agent will grill before
building, so over-specifying here is wasted.

## Out of Scope
What this issue explicitly does not cover. Write "None." if nothing applies.
```

## Autonomy classification (afk / hitl)

The single highest-leverage field. It tells `pickup-issue-personal` how much human
involvement an issue needs, so it must be trustworthy enough that a pickup agent can
act on it without re-deriving the reasoning.

- **`afk`** — "away from keyboard." High confidence a Claude Code agent can complete
  this end to end unattended. The issue is fully specified, the acceptance criteria
  are mechanically verifiable, and no external decision or domain judgment remains.
- **`hitl`** — "human in the loop." The issue needs human judgment somewhere:
  an unresolved design decision, fuzzy requirements, a risky/irreversible change, or
  domain knowledge not captured in the repo. Pickup will run a full grilling session.

Two parallel signals carry the classification, and they must agree:

1. **A GitHub label**, `afk` or `hitl` — the machine-readable signal pickup keys on.
2. **The `## Autonomy` section** in the body — the human-readable justification, so a
   reviewer (and a pickup agent) understands *why* the call was made without guessing.

When in doubt, classify `hitl`. The cost of one unnecessary grilling is far lower than
the cost of an agent guessing wrong on an under-specified `afk` issue. An `afk` tag is
a claim that the issue is airtight; only make it when that is true.

## Labels

Apply these labels via the GitHub MCP. Create them in the repo if they don't exist.

- `afk` / `hitl` — autonomy classification (exactly one per issue).
- `in-progress` — applied by pickup when a worktree is created.
- `in-review` — applied by pickup when the PR is promoted from draft to ready;
  remove `in-progress` at the same time.

## Naming conventions

Shared so concurrent agents never collide and humans can read directories at a glance.

- **Slug**: `issue-<number>-<short-kebab-slug>`, e.g. `issue-42-add-oauth-login`.
  Derive the slug from the issue title; keep it short (3–5 words).
- **Worktree directory**: a sibling of the repo, `../<repo>-worktrees/<slug>/`.
  Outside the repo so worktrees never pollute the working tree or get scanned
  recursively.
- **Branch name**: exactly the slug — `issue-<number>-<short-kebab-slug>`. No
  lowercasing changes, no modification once chosen.
- **ADR filename**: `.claude/context/adr/issue-<number>-<topic-slug>.md`. The issue
  number guarantees no cross-agent collision; the topic slug allows multiple ADRs for
  one issue (e.g. `issue-42-oauth-token-storage.md`,
  `issue-42-session-expiry.md`). There is NO global sequential ADR number in the
  personal flow — it can't survive concurrent agents.

## PR conventions

- The PR body MUST contain `Closes #<number>` so merging to `main` auto-closes the
  issue. No separate close step.
- Open the PR as a **draft** after the first commit; promote to **ready for review**
  when the implementation slice is complete and tests pass.
- When the PR opens, post one comment on the issue linking the PR.
