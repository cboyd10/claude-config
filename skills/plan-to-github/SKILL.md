---
name: plan-to-github
description: Turn a confirmed issue breakdown into real GitHub issues, pushed via the GitHub MCP. Formats each issue using github-formats templates, applies the afk/hitl autonomy label plus justification, and creates the issues in the target repository. Use during the WRITE ISSUES phase of plan-with-me-personal — do not invoke directly unless the user has already confirmed an issue breakdown. The GitHub equivalent of plan-to-jira.
---

# plan-to-github

You are converting an agreed issue breakdown into live GitHub issues. Input is the
confirmed breakdown from `plan-with-me-personal` Phase 3 (titles, descriptions,
acceptance criteria, dependencies, and the afk/hitl call per issue).

Read `github-formats` SKILL.md now if you have not already — it defines the issue body
template, the autonomy classification, the labels, and the naming conventions. This
skill is the mechanics of pushing; `github-formats` is the format of record.

## Preconditions

1. **GitHub MCP must be connected.** If it is not, stop and tell the user:
   "GitHub MCP is not connected — enable it in your connectors and retry." Do not fall
   back to writing files. GitHub is the source of truth for personal projects.
2. **The breakdown must be confirmed.** Never reach this skill without explicit Phase 3
   confirmation from `plan-with-me-personal`.
3. **Know the target repo.** If the working directory's `origin` remote makes it
   obvious, use that. Otherwise ask which repo before creating anything.

## Workflow

1. **Ensure labels exist.** Via MCP, check for `afk`, `hitl`, `in-progress`,
   `in-review`. Create any that are missing.

2. **Format each issue** per the `github-formats` body template: Summary, Autonomy,
   Context, Acceptance Criteria, Implementation Notes, Out of Scope. Acceptance
   criteria as `- [ ]` checkboxes. For `afk` issues, make Implementation Notes
   prescriptive and acceptance criteria mechanically verifiable; for `hitl`, lighter
   notes since pickup will grill.

3. **Express dependencies.** When issue B depends on issue A, note it in B's Context
   section ("Depends on #<A>"). Create independent issues first so dependent issues can
   reference real numbers.

4. **Create the issues** via MCP, one at a time. For each: set title, body, and the
   single autonomy label (`afk` or `hitl`). Capture the returned issue number.

5. **Report.** List every created issue: `#<number> <title> — <afk|hitl>`, with the
   dependency edges. This list is what the user reviews and what feeds future
   `pickup-issue-personal` sessions.

## Conduct

- Do not edit existing issues unless the user asks — this skill creates from a fresh
  breakdown.
- If a proposed issue is tagged `afk` but its acceptance criteria are not actually
  verifiable without judgment, flag it and propose either tightening the criteria or
  reclassifying to `hitl` before creating. An `afk` tag is a promise.
- One issue per coherent unit of work. If the breakdown bundled two unrelated changes
  into one issue, surface it rather than creating a muddy issue.
