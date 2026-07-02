---
name: pickup-issue-personal
description: Pick up a GitHub issue for implementation on a PERSONAL project. Accepts a GitHub issue number/URL, fetches it via the GitHub MCP, creates a Git WORKTREE (not a plain branch) so multiple agents can run concurrently, runs grill-with-docs to reach alignment, implements (TDD when testable logic changes), opens a draft PR, keeps the issue updated, and promotes the PR to ready so merging to main auto-closes the issue. Honors the issue's afk/hitl autonomy label: afk compresses to a single go/no-go, hitl runs a full grilling session. Use when the user says "pick up issue #N" on a personal/GitHub project or invokes /pickup-issue-personal. The GitHub/worktree counterpart to pickup-issue.
---

# pickup-issue-personal

You are picking up a GitHub issue for implementation on a personal project. Input is an
issue number or URL (everything after `/pickup-issue-personal`).

This is the personal counterpart to `pickup-issue`. Same phase spine, delegating
grilling to `grill-with-docs` and TDD to the `tdd` skill so improvements there benefit
both. The differences are at the platform layer: **GitHub issue** instead of Jira slug,
**Git worktree** instead of a plain branch (so concurrent agents can work different
issues at once), and a **PR + issue lifecycle** at the end. Stack-agnostic.

Read `github-formats` SKILL.md now — it defines the issue body sections you'll parse,
the afk/hitl meaning, and the worktree/branch/ADR/PR naming conventions used below.

## Preconditions

**GitHub MCP must be connected.** If not, stop and tell the user to enable it and
retry. Do not proceed without it — you need it to fetch the issue, comment, label, and
open the PR.

## Workflow

Run these phases in order. Do not create the worktree or write code until Phase 3
alignment is confirmed.

```
1. ORIENT  →  2. GRILL (depth set by afk/hitl)  →  3. CONFIRM ALIGNMENT
  →  4. WORKTREE  →  5. IMPLEMENT  →  6. PR & ISSUE LIFECYCLE  →  7. DOCS
```

### Phase 1: ORIENT

1. **Fetch the issue via MCP.** Read every section: Summary, Autonomy, Context,
   Acceptance Criteria, Implementation Notes, Out of Scope. Read the `afk`/`hitl`
   label.
2. Read `.claude/context/CONTEXT.md` and `.claude/context/adr/` if they exist.
3. Explore the code the issue most likely touches. Stack-agnostic: infer patterns from
   the repo. Verify the issue's Context claims against the actual code; surface any
   contradiction immediately. Delegate per `grill-with-docs/EXPLORATION.md` — one
   Explore agent, its report format, no persistence.
4. Build an internal picture: what exists, what changes, what is ambiguous.

Output a brief orientation summary (5 lines max), then move to Phase 2.

### Phase 2: GRILL — depth governed by the autonomy label

Read the `tdd` and `grill-with-docs` SKILL.md files as needed.

**If the issue is `hitl`:** run the full `grill-with-docs` session — one question at a
time, each with a recommended answer, until the user explicitly confirms alignment.
This is the pair-programming path.

**If the issue is `afk`:** do NOT run a multi-question grilling. Instead, ORIENT
thoroughly, then go straight to a single CONFIRM ALIGNMENT summary + work plan (Phase 3)
and wait for one go/no-go.

**The afk self-downgrade (safety valve):** while orienting an `afk` issue, if you find
real ambiguity, an unresolved decision, a contradiction between the issue and the code,
or anything requiring human judgment that the issue did not settle — **stop and
downgrade to `hitl`**: say so plainly ("this was tagged afk but X is unresolved —
switching to grilling") and run the full session. Guessing wrong autonomously costs
more than one extra question. When you downgrade, note it; it's useful retrospective
signal that the planning under-specified the issue.

Apply `grill-with-docs`'s general discipline (its stack guidance lives in
`STACK-WORK.md`, which does not apply to personal projects). Update CONTEXT.md / offer ADRs inline.
**Pull before writing any doc** to shrink the concurrent-agent collision window.

### Phase 3: CONFIRM ALIGNMENT

Summarize:

1. The problem and the proposed change.
2. Which files / layers are affected.
3. **Whether TDD applies** — yes if the change adds or modifies application/library
   logic with testable behavior; no if it's config, infra, docs, styling, or a one-off
   script. State your call; the user can override.
4. What is explicitly out of scope (carry over the issue's Out of Scope).
5. The worktree slug, directory, and branch name, per `github-formats`:
   slug `issue-<number>-<short-slug>`, directory `../<repo>-worktrees/<slug>/`, branch
   = slug. Base branch defaults to `main` (use another if the user names one).

For `hitl`: ask for confirmation and iterate until explicit.
For `afk`: present this as the single go/no-go. On "go", proceed.

### Phase 4: WORKTREE

Create the worktree and branch (sibling directory keeps concurrent agents isolated and
out of the main working tree):

```bash
git fetch origin
git worktree add -b <slug> ../<repo>-worktrees/<slug> origin/<base-branch>
```

Then `cd` into the worktree for all subsequent work. Via MCP, apply the `in-progress`
label to the issue.

If `<base-branch>` is not `main`, substitute accordingly. If the worktree path already
exists (e.g. a resumed pickup), reuse it instead of recreating.

### Phase 5: IMPLEMENT

**If TDD applies:** follow the `tdd` skill. Vertical slices, one behavior at a time,
tracer bullet first; one test → minimal code to pass → repeat; no refactoring until all
behaviors pass; tests verify behavior through public interfaces.

**If TDD does not apply:** implement directly and verify with the appropriate check for
this project (test command, build, lint, dry-run).

**UI/frontend verification:** once tests pass, if the diff touches client/UI files
(components, pages, styles, client-side routes), component tests alone don't prove the
feature works — ask the user whether to verify it in a real browser before moving on.
Recommend yes for a substantial UI feature or fix; treat it as optional/skippable for a
small or low-risk UI change. If the user declines or this is a small change and they'd
rather skip it, proceed to commit without browser verification. If they say yes:

1. Check for a project-specific run/launch skill first; otherwise invoke Claude Code's
   bundled `run` skill to start the app.
2. If the app requires interactive auth (OAuth/SSO) that blocks automated login, look
   for a lightweight local workaround before giving up — e.g. minting a dev JWT/session
   token with the same signing secret, a seeded test user, or a documented dev-bypass
   flag. Only fall back to "tests only, unverified" if no such workaround exists, and
   state that explicitly.
3. Actually drive the feature — click the control, open the sheet, apply the filter —
   and capture screenshots as evidence, not just a page load.
4. Tear down anything started for verification (dev servers, local DB, seeded data)
   before finishing.

Make the first commit early. Then open the draft PR (Phase 6) so concurrent work is
visible and CI starts, and continue implementing on the same branch.

### Phase 6: PR & ISSUE LIFECYCLE

1. **After the first commit**, push the branch and open a **draft PR** via MCP. The PR
   body MUST contain `Closes #<number>` so merging to `main` auto-closes the issue.
2. **Comment on the issue** linking the PR.
3. Continue implementing, pushing commits to the branch.
4. **When the slice is complete**, wait for CI to pass before promoting:
   - Using the GitHub MCP's workflow-run tools (discover the exact tool names from
     the connected MCP — do not guess), find the latest run for the branch and poll
     until it reaches a terminal state (`completed`, `failure`, `cancelled`).
   - On failure, diagnose and fix: push a corrective commit, then re-poll the new run.
   - Do not promote until the run concludes with `conclusion: success`.
5. **Once CI is green**, promote the PR from draft to **ready for review**. Via MCP,
   swap labels: remove `in-progress`, add `in-review`.
6. Leave merging to the user. On merge to `main`, GitHub auto-closes the issue via the
   `Closes #<number>` link — no manual close step.

### Phase 7: DOCS

1. Ensure `.claude/context/CONTEXT.md` reflects any new domain terms (pull first).
2. Write any ADRs deferred during grilling, named
   `issue-<number>-<topic-slug>.md`.
3. Confirm the worktree is reviewable: checks pass, no stray uncommitted changes.

Optionally remind the user they can remove the worktree after merge:
`git worktree remove ../<repo>-worktrees/<slug>`.

If any files were created or modified in a `skills/` directory of a `claude-config`
repo during this implementation, run the `update-ios-instructions` skill as the
final step.

## General conduct

- Never create the worktree before Phase 3 confirmation (the single go/no-go counts for
  `afk`).
- Branch name is always exactly the slug — no modification.
- The afk/hitl label sets grilling depth, but the self-downgrade always wins:
  uncertainty turns an `afk` issue into a grilled one.
- If the issue is too big for one PR, say so in Phase 3 and propose splitting before
  creating the worktree.
- The user can jump phases backward at any time. Honor it, then resume.
