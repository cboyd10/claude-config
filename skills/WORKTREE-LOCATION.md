# Worktree location: bare repos keep worktrees inside the bare directory

Every skill that creates a Git worktree (`pickup-issue`, `pickup-issue-personal`,
`address-pr-comments`, `review-pr`, `update-docs`, `update-docs-personal`,
`build-style-guide`, `sweep-issues-personal`) follows this convention for where
the worktree directory lives.

## The default: sibling directory

For a normal single-checkout repo, new worktrees go in a sibling directory:
`../<repo>-worktrees/<slug>/`. Outside the repo so worktrees never pollute the
working tree or get scanned recursively — see the `github-formats`/`jira-formats`
naming conventions.

## The override: bare-repo-and-worktrees setups

A repo whose primary checkout is itself a bare repo (no working tree at the top
level — only git internals: `objects/`, `refs/`, `hooks/`, etc.) has nothing for
a sibling directory to protect: the pollution/recursive-scan problem the sibling
convention solves doesn't exist there. For these repos, create new worktrees
directly inside the bare repo directory instead: `<bare-root>/<slug>/` — the same
place the repo's own `main`/`master` worktrees already live.

## How to resolve

Once per session, before the first worktree check (resume check, creation, or
removal reminder):

1. Run `~/.claude/scripts/resolve-worktree-root.sh`. It prints the absolute path
   of the repo's bare root if this is a bare-repo-and-worktrees setup, or nothing
   otherwise.
2. If it printed a path: the worktree directory for this session is
   `<that path>/<slug>`.
3. If it printed nothing: fall back to `../<repo>-worktrees/<slug>/`, unchanged.

Resolve once and reuse the result for every worktree-path reference in the
session (resume check, `git worktree add`, removal reminder) — don't re-run the
script per reference.

## Naming collision note

Never place new worktrees under a subfolder literally named `worktrees` inside
the bare repo directory — that name is reserved by git's own internal metadata
directory (`<bare-root>/worktrees/`), and colliding with it will corrupt worktree
tracking. Slug directories go directly at the bare root's top level.

## Why this design

- **Gated on actual bare-repo detection (`git worktree list --porcelain`), not a
  path or branch-name heuristic** — same reasoning as `WORKTREE-CONTEXT.md`:
  asking git directly works regardless of layout and doesn't silently misbehave
  on an exception.
- **Prospective only** — this resolves where *new* worktrees are created. It does
  not add dual-location fallback logic to find worktrees created under the old
  sibling-only convention before this doc existed; those are handled manually as
  their work finishes.
