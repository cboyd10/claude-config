---
name: pickup-issue
description: Pick up a Jira issue for implementation. Accepts a Jira slug + summary/description, orients in the codebase, runs grill-with-docs to reach alignment, creates a Git worktree (sibling directory) named after the slug, then implements (using TDD for Angular/Spring Boot code changes). Use when the user says "I'm picking up [JIRA-SLUG]" or invokes /pickup-issue.
---

# pickup-issue

You are picking up a Jira issue for implementation. Input is everything after
`/pickup-issue` (or the user's natural-language description). Parse the Jira slug as
the first whitespace-delimited uppercase token (e.g. `LNES-129`); treat the rest as
the issue summary and description.

## Workflow

Run these phases strictly in order. Do not create a worktree or write any code until
Phase 3 alignment is explicitly confirmed by the user.

```
1. ORIENT  →  2. GRILL  →  3. CONFIRM ALIGNMENT  →  4. WORKTREE  →  5. IMPLEMENT  →  6. DOCS
```

### Phase 1: ORIENT

Before asking the user anything, gather context:

1. Read `.claude/context/CONTEXT.md` and `.claude/context/adr/` if they exist.
2. Check for `issues.csv` in the relevant planning directory (`.claude/jira-planning/`).
   If found, read it for context on the issue being picked up and its dependencies
   before exploring the codebase.
3. Explore the code the issue most likely touches — data model, service layer, Helm
   charts, Angular components, whatever the description points at. Delegate this
   exploration per `grill-with-docs/EXPLORATION.md` (read it now, plus
   `grill-with-docs/STACK-WORK.md`) — one Explore agent, its report format, no
   persistence. For deployment or
   infrastructure issues, also search CI/CD pipeline files (Bamboo specs, GitHub
   Actions, etc.) and deploy scripts for references to the same secrets, flags, or
   values being changed.
4. Build an internal picture: what exists, what will change, what is ambiguous.

Output a brief orientation summary (5 lines max), then move to Phase 2. Do not
dump file listings at the user.

### Phase 2: GRILL

Follow the `grill-with-docs` skill. Read its SKILL.md now if you have not already.

Goal: shared understanding of exactly what needs to change, why, what is out of
scope, and what could go wrong. Update `.claude/context/CONTEXT.md` and offer ADRs
inline as terms and decisions resolve.

The grilling is done only when the user explicitly confirms (e.g. "we're aligned",
"let's do it", "that's everything"). Never declare alignment yourself.

### Phase 3: CONFIRM ALIGNMENT

Summarize the shared understanding:

1. The problem being solved and the proposed change.
2. Which files / layers are affected.
3. Whether TDD applies: **yes** if the change includes Angular or Spring Boot
   production code; **no** if the change is config, deployment, SQL, or docs only.
4. What is explicitly out of scope.
5. The worktree path (`../<repo>-worktrees/{JIRA-SLUG}/`), branch name (always
   the exact Jira slug, e.g. `LNES-129`), and base branch (default: `master`;
   use any other branch the user specifies).

Ask the user to confirm. Iterate until explicit confirmation. Only then proceed.

### Phase 4: WORKTREE

Create the worktree and branch (sibling directory keeps the main working tree
clean and allows concurrent agents to work different issues at once):

```bash
git fetch origin
git worktree add -b {JIRA-SLUG} ../<repo>-worktrees/{JIRA-SLUG} origin/{base-branch}
```

Then work inside the worktree for all subsequent implementation. If the worktree
path already exists (e.g. a resumed pickup), reuse it instead of recreating.

Default base branch is `master`. If the user named a different base branch during
the session, substitute accordingly.

### Phase 5: IMPLEMENT

#### If TDD applies (Angular or Spring Boot production code is changing)

Follow the `tdd` skill. Read its SKILL.md now if you have not already.

Key rules:
- Vertical slices: one behavior at a time, tracer bullet first.
- Write one test → write minimal code to pass it → repeat.
- No refactoring until all behaviors are implemented and tests pass.
- Tests verify behavior through public interfaces, not implementation details.

#### If TDD does not apply (config, deployment, SQL, or docs only)

Implement directly with Edit/Write/Bash. Verify correctness with the appropriate
check (e.g. `./gradlew clean test`, Helm dry-run, static analysis).

### Phase 6: DOCS

After implementation:

1. Ensure `.claude/context/CONTEXT.md` reflects any new domain terms introduced.
2. Write any ADRs that were deferred during grilling.
3. Confirm the worktree is in a reviewable state: tests pass, static analysis
   clean, no uncommitted changes. Optionally remind the user they can remove the
   worktree after the branch is merged:
   `git worktree remove ../<repo>-worktrees/{JIRA-SLUG}`.

## General conduct

- Never start Phase 4 without explicit alignment confirmation from Phase 3.
- The branch name is always the exact Jira slug — no modification, no lowercasing.
- If the issue scope is large enough to span multiple PRs, say so in Phase 3 and
  propose splitting before creating the worktree.
- The user can jump phases backward at any time. Honor it, then resume.
