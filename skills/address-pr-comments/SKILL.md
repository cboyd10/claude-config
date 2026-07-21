---
name: address-pr-comments
description: Address open PR review comments by triaging them (fix/defer/no-change), reaching explicit alignment with the user, then implementing the agreed fixes. Use when the user wants to respond to PR review feedback or invokes /address-pr-comments.
---

# address-pr-comments

You are addressing open comments from a pull request review. Input is a path to a
PR review handoff document (e.g., `@pr-review-LDB-1234.md`) that contains an "Open
Comments" section. If the user passes a PR URL or number instead, fetch the PR to
extract its open comments first.

## Workflow

Run these phases strictly in order. Do not write any code until Phase 3 alignment
is explicitly confirmed by the user.

```
1. ORIENT  →  2. TRIAGE  →  3. CONFIRM ALIGNMENT  →  4. WORKTREE  →  5. IMPLEMENT  →  6. VERIFY
```

### Phase 1: ORIENT

**Resumed session check (first):** if a worktree for the PR's branch already exists
and contains `.claude/wrap-up/IMPLEMENTATION-HANDOFF.md` naming this skill, this is
a resumed session. Follow the resume contract in `wrap-up/IMPLEMENTATION.md`: read
the handoff (its embedded triage table is the confirmed alignment), verify it
against `git log`/`git status`, skip Phases 2–3 for rows already confirmed, resume
implementing the remaining "Fix now" items, and delete the handoff once caught up.

Otherwise, before presenting anything to the user:

1. Parse the review document to list all open comments (reviewer, file, line, text).
2. Read every file and line referenced by those comments. Build an internal picture
   of what the reviewer is asking and what the code currently does.
3. Read `.claude/context/CONTEXT.md` if it exists for domain context. In a
   work repo, resolve the shared-doc root per `WORKTREE-CONTEXT.md` first.

Output a brief orientation summary (3–5 lines: PR title, branch, comment count,
which files are touched). Do not dump file listings or raw comment text.

### Phase 2: TRIAGE

Present a triage table covering every open comment. For each, recommend one action:

| Action | When to use |
|--------|-------------|
| **Fix now** | Bounded change that clearly improves correctness, quality, or consistency |
| **Defer** | Too large for this PR; needs its own issue; or a consistent fix would span multiple unrelated files/components |
| **No change** | Thread already resolved in the conversation, approach was approved by the reviewer, or the comment is not actionable |

Format the table as:

| # | File / Line | Comment summary | Recommendation | Reasoning |
|---|-------------|-----------------|----------------|-----------|

Present the entire table in one message — this is not a one-question-at-a-time
interview. Comments are independent; batch triage is faster and easier to review.

Invite the user to push back on any row. Discuss any disagreement before the table
is finalized. Stay in Phase 2 until the user explicitly confirms the triage (e.g.
"looks good", "agreed", "proceed"). Never declare alignment yourself.

### Phase 3: CONFIRM ALIGNMENT

Summarize the agreed triage in three sections:

1. **Fix now** — one bullet per comment; state the exact change that will be made.
2. **Defer** — one bullet per comment; state the reason and note if a new Jira issue
   should be opened.
3. **No change** — one bullet per comment; state why no change is needed.

Also state:
- Whether TDD applies: **yes** if any fix touches Angular or Spring Boot production
  code; **no** if all fixes are SCSS, HTML-only, SQL, config, or docs only.
- Which branch/worktree will be used.

Ask the user to confirm. Iterate until explicit confirmation. Only then proceed.

### Phase 4: WORKTREE

Verify you are on the correct branch (should match the PR source branch).

If already in the right worktree, proceed directly to Phase 5.

If not, resolve the worktree directory per `WORKTREE-LOCATION.md` (run
`~/.claude/scripts/resolve-worktree-root.sh`; use `<bare-root>/{BRANCH}` if it
printed a path, else `../<repo>-worktrees/{BRANCH}`), then check out or create
the worktree there:

```bash
git fetch origin
git worktree add {worktree-dir} origin/{BRANCH}
```

Work inside the worktree for all subsequent implementation.

### Phase 5: IMPLEMENT

Work through each "Fix now" item from the confirmed triage list.

#### If TDD applies (Angular or Spring Boot production code is changing)

Follow the `tdd` skill. Read its SKILL.md now if you have not already.

Key rules:
- Write one failing test first, then write the minimal code to pass it.
- Tests verify behavior through public interfaces, not implementation details.
- No refactoring until all behaviors are green.

#### If TDD does not apply (SCSS, HTML-only, config, SQL, docs)

Implement directly with Edit/Write/Bash. Verify with the appropriate check
(build, lint, or dry-run).

### Phase 6: VERIFY

After all fixes are applied:

1. Run the relevant test suite and confirm it passes.
2. Report which "Defer" items may need a new Jira issue, so the user can create
   them before resolving the PR comments.
3. If this session produced retro signal — corrections to your assumptions or
   context the user had to re-explain — offer `/skill-retro` before closing.
   Skip the offer if there was no signal.

## General conduct

- Never start Phase 5 without explicit alignment confirmation from Phase 3.
- The user can jump phases backward at any time. Honor it, then resume.
- Do not resolve or mark PR comments as done — that is the user's job in the PR tool.
- If a deferred item is substantial, offer to plan it with `/plan-with-me` after Phase 6.
