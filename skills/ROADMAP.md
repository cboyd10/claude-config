# Skill roadmap — deferred work

Seed notes for future skill-building sessions. Each entry gets its own
grill-with-docs session. Written 2026-07-02 during the Sonnet-readiness audit.

## Seed entries

- **build-style-guide: Figma as a seed source.** Work clients receive designs
  in Figma; extend build-style-guide's seed intake (currently claude.ai/design
  export / reference app / current app) to extract tokens and element styling
  from Figma. Deferred 2026-07-04 during the build-style-guide grilling
  session.

- **Native blocked-by for dependencies.** The DEPENDS-ON LINE text convention is
  the sole dependency signal because the GitHub MCP exposes no issue-dependency
  tools (verified 2026-07-05: only sub-issues, labels, fields). When the MCP gains
  native blocked-by support: update plan-to-github to set the relationship
  alongside the text line, and sweep-issues-personal to read native first with
  text fallback. Deferred 2026-07-05 during the sweep-issues-personal grilling
  session.

- **deconstruct: vertical slices vs. horizontal layers as an explicit seam axis.**
  When deconstructing a scope that spans both backend and frontend work, ask
  whether the user wants vertical slices (each piece pairs backend logic with the
  UI needed to exercise it, so every piece is manually testable end-to-end) or
  horizontal layers (all backend pieces, then all UI pieces) — don't default to
  layers, since vertical slicing is often what a solo/personal-project builder
  actually wants. Deferred 2026-07-05 during an AstroWatch
  phase-1-domain-engine deconstruction session, where a horizontal-layer default
  had to be redirected by the user mid-session.

## Pending chore

- Decide whether the `bitbucket_pr_to_review` script (currently
  `~/.local/bin/`) should live in this repo (e.g. under `scripts/`).
