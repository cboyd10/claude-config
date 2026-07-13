---
name: build-style-guide
description: Build a client app's style-guide page (/style-guide) from design tokens and BEM SCSS partials, seeded from a claude.ai/design export, a reference app, or the app's current styles; after user approval, derive a COMPONENT BRIEF that planning skills turn into component-library conversion issues. Use when the user wants a style guide, theme, design tokens, or a component-library foundation for a client app, or invokes /build-style-guide.
---

# build-style-guide

Build the styling foundation for a client app: a two-layer design-token system,
BEM SCSS partials, and a `/style-guide` page that demos every themed element —
then, once the user approves the look, derive the COMPONENT BRIEF that the
planning flows turn into component-library conversion issues.

This skill never builds the component library itself. Components are built
through the normal planning → pickup pipeline, fed by the COMPONENT BRIEF.

## Workflow

Run these phases strictly in order. Do not create a worktree or write any code
until Phase 3 alignment is explicitly confirmed by the user.

```
1. INTAKE  →  2. ORIENT  →  3. CONFIRM ALIGNMENT  →  4. WORKTREE  →  5. BUILD
  →  6. VERIFY & APPROVAL GATE  →  7. PUSH  →  8. COMPONENT BRIEF
```

### Phase 1: INTAKE

**Resume check (first):** if the worktree `../<repo>-worktrees/style-guide/`
already exists and contains `.claude/style-guide/STATE.md`, this is a resumed
run. Read the state file, verify its claims against `git log`/`git status`,
and land in the phase it implies: page built but not approved → Phase 6;
approved but no brief → Phase 8. Do not redo phases the state file records
as done.

Otherwise, ask the intake questions one at a time, grill-with-docs style
(recommendation included with each):

1. **Seed source** — where does the theme come from?
   - A **claude.ai/design export** — provided as files at a path the user
     names, or a URL to fetch.
   - A **reference app** — same: local files/path or a URL.
   - The **current app's styles** — explored in Phase 2.
   Figma is not yet a seed source (see `skills/ROADMAP.md`). From an export or
   reference, distill token VALUES only — palette, type scale, spacing, radii,
   shadows. Never copy markup.
2. **Icon approach** — reuse the app's existing icon set if it has one;
   otherwise recommend an inline SVG sprite (no icon-font dependency).

### Phase 2: ORIENT

1. Read `.claude/context/CONTEXT.md` and any repo `ORIENTATION.md` if present.
   In a work repo, resolve the shared-doc root per `../WORKTREE-CONTEXT.md`
   first.
2. Detect the stack. For Angular, read `STACK-ANGULAR.md` in this skill
   directory now. For other stacks, apply the stack-agnostic rules below and
   mirror the Angular file's intent using that stack's conventions (dev-only
   route or static page, its styling pipeline).
3. **Apps with existing styling:** delegate ONE Explore agent per
   `grill-with-docs/EXPLORATION.md` to (a) inventory which checklist elements
   (`ELEMENTS.md`) the app actually uses, with file citations, (b) harvest
   current values (colors, fonts, spacing, radii) as token seeds, and
   (c) identify any styled UI framework (Angular Material, PrimeNG, Bootstrap)
   and where it's used.
4. **Scope rule:** new apps (no meaningful existing styling) get the full
   `ELEMENTS.md` checklist. Apps with existing styling get only the elements
   the exploration found in use — the rest are added per-client later.

### Phase 3: CONFIRM ALIGNMENT

Summarize and ask the user to confirm: seed source, element scope (full
checklist or the in-use subset, listed), the framework-replacement consequence
if a styled UI framework was found (see General conduct), worktree path
`../<repo>-worktrees/style-guide/`, branch `style-guide`, and base branch
(default `master`/`main` per repo). Iterate until explicitly confirmed.

### Phase 4: WORKTREE

```bash
git fetch origin
git worktree add -b style-guide ../<repo>-worktrees/style-guide origin/{base-branch}
```

Work inside the worktree from here on. Create `.claude/style-guide/STATE.md`
(committed with the branch) recording: seed source, scope, and
`Phase 1 approved: no`. Keep it current as phases complete.

### Phase 5: BUILD

Commit incrementally as each layer lands.

1. **Tokens** — two-layer CSS custom properties in `_tokens.scss`:
   primitives (`--color-blue-500`, `--space-4`) plus semantic aliases
   (`--color-surface`, `--color-text-primary`, `--color-focus-ring`) that
   every partial consumes. One theme per client, but the two layers make a
   later dark theme a token-file change, not a rework. Breakpoints live as
   SCSS variables + mixins (custom properties don't work in media queries).
2. **Partials** — 7-1-lite layout wired into the app's root stylesheet via
   `@use`: `abstracts/` (`_tokens.scss`, `_mixins.scss`), `base/`
   (`_reset.scss`, `_typography.scss`), `components/` — one partial per BEM
   block (`_button.scss`, `_dialog.scss`, …). Strict BEM
   (`block__element--modifier`); prefer native states (`:disabled`,
   `:focus-visible`, `[aria-invalid]`) over state classes.
3. **The page** — a `/style-guide` route reachable only in local runs
   (Angular: routes file replacement per `STACK-ANGULAR.md`), one section per
   in-scope `ELEMENTS.md` entry, with an in-page section nav. Demo rules:
   elements are live (hover/focus/active by interacting); persistent states —
   disabled, error, loading, checked/selected, sizes — get static side-by-side
   demos. Interactive demos (dialog, popover, bottom sheet) may use throwaway
   inline page behavior; real behavior arrives with the components.
4. **Responsive** — every section must work at mobile and desktop widths:
   nav collapses, tables scroll horizontally, dialogs go near-full-screen on
   mobile, the bottom sheet is the mobile overlay counterpart.
5. **Accessibility** — visible `:focus-visible` rings from the focus token,
   AA contrast for text tokens, keyboard-reachable interactive demos.

### Phase 6: VERIFY & APPROVAL GATE

Self-verify before presenting: run the app locally and capture style-guide
screenshots at ~375px and ~1440px viewports when the session has browser
tooling (Playwright etc.); share them with the user. Without tooling, verify
the build compiles and the route serves, and hand the user the local URL.

Then stop at the gate: the user judges whether the page meets expectations.
Iterate on the page until they explicitly approve. Never declare approval
yourself.

### Phase 7: PUSH

On approval: record it in `STATE.md` (`Phase 1 approved: {date} at {commit}`),
commit, and push the branch. Raising the PR is the user's call — offer to open
it via the GitHub MCP in personal repos; for work (Bitbucket, no API) just say
the branch is ready. Then offer to continue into Phase 8 in this session; if
declined or the session is long, end — a later invocation resumes at Phase 8
via the state file.

### Phase 8: COMPONENT BRIEF

Derive the COMPONENT BRIEF from the approved page per `BRIEF-FORMAT.md` in
this skill directory, write it to `.claude/style-guide/COMPONENT-BRIEF.md`,
commit, push, and update `STATE.md`. Then hand off: work repos → feed it to
`plan-with-me`; personal repos → `plan-with-me-personal`. The brief is an
inventory only — planning owns issue slicing, estimates, and AFK/HITL labels.

## General conduct

- **Styled UI frameworks get replaced.** If the app uses Angular Material,
  PrimeNG, Bootstrap, or similar, the custom BEM system replaces it — the
  COMPONENT BRIEF includes the migration. Surface this consequence plainly in
  Phase 3.
- **Angular CDK is exempt.** CDK is unstyled behavior primitives (overlay,
  focus-trap, a11y) and doesn't conflict with the BEM system. For
  behavior-heavy components, recommend keeping/using it with plain pros/cons;
  the user decides (details in `STACK-ANGULAR.md`).
- The style-guide page starts as raw BEM markup and later becomes the living
  component showcase: each component's conversion issue includes swapping its
  section to render the real component (encoded in the brief).
- Never build components in this session; never migrate app screens. Both go
  through planning → pickup.
- The user can jump phases backward at any time. Honor it, then resume.
- After creating or editing this skill's files in claude-config, finish with
  `update-ios-instructions`.
