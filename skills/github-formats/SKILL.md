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
`hitl` — <one line naming the step Claude Code can't or shouldn't perform itself,
or the pickup downgrade that relabeled this issue>

## Context
Relevant files, modules, and prior issues. Hard blockers go on DEPENDS-ON LINEs
(`Depends on #<number>`, one per line — see Dependencies below); link merely
related issues as plain `Related: #<number>` prose.
Point at domain terms in `.claude/context/CONTEXT.md` where they apply. This is the
orientation an agent needs before touching code — give it the map, not the territory.

## Acceptance Criteria
- [ ] Concrete, individually verifiable outcomes.
- [ ] For `afk` issues: precise enough to verify mechanically, with no open judgment.
- [ ] Phrased as observable behavior or state, not implementation steps.

## Implementation Notes
Suggested approach, existing patterns to follow, known gotchas. Every issue gets the
same prescriptive depth (file paths, function names, example payloads) — no pickup
grilling will fill gaps. A `hitl` issue is just as fully specified as an `afk` one;
it differs only by naming its human-performed step.

## Out of Scope
What this issue explicitly does not cover. Write "None." if nothing applies.
```

## Autonomy classification (afk / hitl)

The single highest-leverage field. It tells `pickup-issue-personal` how much human
involvement an issue needs, so it must be trustworthy enough that a pickup agent can
act on it without re-deriving the reasoning.

- **`afk`** — "away from keyboard." **The default.** Every issue leaves planning
  fully specified — all design decisions pre-made, acceptance criteria mechanically
  verifiable, no external decision or domain judgment remaining — so a Claude Code
  agent can complete it end to end unattended.
- **`hitl`** — "human in the loop." Reserved for issues containing a step Claude Code
  **can't or genuinely shouldn't perform itself, even though the design is fully
  aligned**. The `## Autonomy` line names that step. `hitl` is never a parking spot
  for unfinished design work.

The governing principle: **if Claude Code can do it inside the codebase and tooling
it has access to, and it isn't a security concern, it is `afk`.** Illustrative (not
exhaustive) `hitl` categories:

- **Secrets & encrypted material** — work requiring plaintext secrets the agent
  can't or shouldn't touch: SOPS-encrypted values, production `.env` contents,
  credential rotation.
- **Human-only auth ceremonies** — steps gated on a human identity: 2FA prompts,
  OAuth consent screens, app-store/registrar/cloud-console actions on accounts the
  agent can't hold.
- **Irreversible external actions** — one-way operations outside the repo:
  destructive production data migrations, sending real emails/notifications to
  users, deleting cloud resources.
- **Spending money** — purchases, plan upgrades, paid API tier changes.
- **External service provisioning** — account creation, identity verification, and
  token generation on third-party services (e.g. setting up a Plaid account).

A second, pickup-time cause of `hitl` exists: the **afk self-downgrade**, when
`pickup-issue-personal` finds ambiguity planning missed and relabels the issue. The
`## Autonomy` section must say which cause applies — pickup reads it to choose
between a single go/no-go with a planned pause at the human step (planning-time
`hitl`) and a full grilling session (downgrade `hitl`).

Two parallel signals carry the classification, and they must agree:

1. **A GitHub label**, `afk` or `hitl` — the machine-readable signal pickup keys on.
2. **The `## Autonomy` section** in the body — the human-readable justification, so a
   reviewer (and a pickup agent) understands *why* the call was made without guessing.

Doubt about a classification means the grilling isn't finished: resolve the doubt and
tag `afk` — do not park it under `hitl`. A design decision that can't be made yet
means the work isn't needed yet; that issue simply isn't created in this batch. An
`afk` tag is still a claim that the issue is airtight — the way to keep that claim
true is to grill until it is, not to downgrade the label.

## Dependencies — the DEPENDS-ON LINE

The canonical, machine-readable dependency signal, read by `sweep-issues-personal`
to build its dispatch graph and written by `plan-to-github`:

- Exactly the phrase `Depends on #<number>` on its own line inside the issue's
  `## Context` section. One blocker per line; nothing else on the line.
- A DEPENDS-ON LINE asserts a **true build-order constraint** — this issue cannot be
  implemented until that one is. Mere relatedness is linked as plain prose
  (`Related: #<number>`), which the sweep ignores.
- This text convention is the sole signal: the GitHub MCP does not expose native
  blocked-by relationships (adopting them when it does is a ROADMAP seed).

## Labels

Apply these labels via the GitHub MCP. Create them in the repo if they don't exist.

- `afk` / `hitl` — autonomy classification (exactly one per issue).
- `in-progress` — applied by pickup when a worktree is created.
- `in-review` — applied by pickup when the PR is promoted from draft to ready;
  remove `in-progress` at the same time.
- `sweep-blocked` — applied (alongside `in-progress`) when an UNATTENDED MODE pickup
  hits a hard failure; the failure detail lives in an issue comment. Removed by the
  next dispatch of that issue.

## Naming conventions

Shared so concurrent agents never collide and humans can read directories at a glance.

- **Slug**: `issue-<number>-<short-kebab-slug>`, e.g. `issue-42-add-oauth-login`.
  Derive the slug from the issue title; keep it short (3–5 words).
- **Worktree directory**: resolved per `WORKTREE-LOCATION.md` (in
  `~/.claude/skills/`) — a sibling of the repo, `../<repo>-worktrees/<slug>/`,
  by default; inside the bare repo directory itself, `<bare-root>/<slug>/`,
  when the repo is a bare-repo-and-worktrees setup.
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

### Stacked PRs

A STACKED PR implements an issue whose blocker is PR-ready but unmerged: its branch
is created from the blocker's branch, and the PR **targets the blocker's branch**,
not `main`.

- The body still contains `Closes #<number>`, plus the note:
  `Stacked on #<blocker-PR> — merge that first.`
- **Merge bottom-up, by the user, never by an agent**: merge the blocker's PR to
  `main` and delete its branch (enable branch auto-delete) — GitHub then retargets
  the still-open children onto `main`, so every `Closes #<number>` fires when its
  own PR merges.
- **Octopus (exactly two unmerged blockers)**: the branch bases on the
  lowest-numbered blocker's branch and merges the other blocker's branch in
  immediately; the PR targets the base blocker's branch and its body notes that the
  diff includes the second blocker's commits until that blocker merges. Three or
  more unmerged blockers are never stacked — the issue waits.
