# Orientation: claude-config

Derived: 2026-07-03 at commit ef8c16f

A personal, version-controlled Claude Code configuration: ~20 interlocking
skills plus a statusline script, symlinked into `~/.claude/` (README.md).
Used by one developer in two modes: as a lead planning Jira work for a
4-person team on an Oracle/Spring Boot/Angular stack (no Jira API — output
is copy-pasted), and for stack-agnostic personal projects tracked as GitHub
issues via the GitHub MCP. The Claude iOS app consumes the skills over raw
GitHub URLs listed in `ios-instructions.md`.

## Module map

- `README.md` — setup and symlink instructions
- `ios-instructions.md` — generated raw-URL manifest injected into the iOS system prompt
- `scripts/statusline-command.sh` — terminal statusline renderer
- `.claude/context/CONTEXT.md` — this repo's own domain glossary
- `skills/ROADMAP.md` — seed notes for future skill-building sessions
- `skills/grill-with-docs/` — shared one-question-at-a-time interview engine; owns CONTEXT.md and the EXPLORATION.md delegation contract
- `skills/plan-with-me/`, `plan-to-jira/`, `jira-formats/` — work planning → Jira issue files
- `skills/plan-with-me-personal/`, `plan-to-github/`, `github-formats/` — personal planning → GitHub issues
- `skills/pickup-issue/`, `pickup-issue-personal/` — implement a Jira slug / GitHub issue in a worktree
- `skills/tdd/` — vertical-slice TDD engine delegated by all implement flows
- `skills/address-pr-comments/` — triage and fix comments on your own PR
- `skills/review-pr/` — review a coworker's Bitbucket PR into paste-ready comments
- `skills/wrap-up/` — emit a PLANNING or IMPLEMENTATION HANDOFF to end a long session
- `skills/deconstruct/` — split an oversized scope into per-piece handoffs
- `skills/flesh-out/` — iOS-chat ideation → IDEA BRIEF or RUNBOOK
- `skills/bootstrap-context/` — draft a repo's first CONTEXT.md + ORIENTATION.md
- `skills/update-docs/`, `docs-formats/` — junior-first work-repo docs + ADR lifecycle
- `skills/improve-codebase-architecture/` — deepening-refactor reports
- `skills/update-ios-instructions/` — regenerate ios-instructions.md

## Entry points

- Skills are invoked as slash commands; on iOS they are fetched by raw URL — `ios-instructions.md`
- The interview engine every planning/pickup/docs flow delegates to — `skills/grill-with-docs/SKILL.md`
- The delegation contract read by 6+ skills before any exploration — `skills/grill-with-docs/EXPLORATION.md`
- Orchestrators: plan-with-me(-personal) → plan-to-jira/plan-to-github → formats layers; pickup flows → tdd; wrap-up ↔ the pickup flows' resume paths

## Conventions

- Phase pipeline: ASCII arrow diagram + numbered `### Phase N:` blocks + "General conduct" — copy `skills/pickup-issue/SKILL.md`
- Mechanics skill + formats skill split for anything with templates — copy `skills/plan-to-jira/` + `skills/jira-formats/`
- Explore inline only when you can name the file; otherwise ONE Explore agent, fixed report format — copy `skills/grill-with-docs/EXPLORATION.md`
- Alignment gate: read-only until the user explicitly confirms; never declare alignment yourself — copy `skills/plan-with-me/SKILL.md`
- Re-grounding: re-read the governing rules every 10th question — copy `skills/grill-with-docs/SKILL.md`
- After editing any skill, finish by running update-ios-instructions — `skills/pickup-issue-personal/SKILL.md`

## Gotchas

- Two artifacts share the filename `ORIENTATION.md`: the repo-level brief (this file) and plan-with-me's per-feature planning brief in `.claude/jira-planning/{folder}/` — `skills/grill-with-docs/EXPLORATION.md`
- `review-pr` (their PR, outputs `review-comments-*.md`) vs `address-pr-comments` (your PR, consumes `pr-review-*.md`) are mirror images — `skills/review-pr/SKILL.md`
- ADR homes differ by flow: work repos use globally numbered `docs/adr/0001-slug.md`; personal repos use `issue-<n>-<topic>.md` in `.claude/context/adr/`. The latter path is *legacy* in work repos but *canonical* in personal ones — `skills/docs-formats/ADR-FORMAT.md`
- ADRs are never written during planning — post-implementation only, by update-docs (personal/deconstruct exceptions aside) — `skills/grill-with-docs/SKILL.md`
- Personal flows hard-require the GitHub MCP and refuse to fall back to files — `skills/plan-to-github/SKILL.md`
