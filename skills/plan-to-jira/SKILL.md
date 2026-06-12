---
name: plan-to-jira
description: Converts a confirmed shared understanding from a grilling session into ready-to-paste Jira issue documentation files (user stories, technical stories, sub-tasks, diagrams) in the jira-planning/ directory. Use during the WRITE ISSUES phase of plan-with-me, or whenever the user asks to "write the issues", "write the stories", or produce Jira documentation after planning. Never use before alignment has been explicitly confirmed.
---

# plan-to-jira

Turn the aligned understanding from a grilling session into Jira-ready files.

## The gate

Do NOT write any issue files until BOTH of these have happened in the conversation:

1. The user explicitly signaled the grilling is done.
2. You summarized the shared understanding + proposed issue breakdown, and the user
   explicitly confirmed it.

If invoked before the gate is passed, run the confirmation step first.

## Output location and naming

Write to the repo's `.claude/` directory:

```
.claude/jira-planning/
└── {YYYY-MM-DD}_{feature-slug}/
    ├── 00-overview.md
    ├── 01-{issue-slug}.md
    ├── 02-{issue-slug}.md
    ├── ...
    └── attachments/
        ├── {issue-slug}-sequence-diagram.mermaid
        └── ...
```

- One file per Jira issue (story or technical story). Sub-tasks live INSIDE their
  parent issue's file — they are pasted into Jira as sub-tasks of that issue.
- Number files in recommended creation/dependency order: if story B depends on
  story A, A gets the lower number.
- Mermaid diagrams and other attachments go in `attachments/`, named
  `{issue-slug}-{diagram-type}.mermaid`, and are referenced from the issue file by
  relative link. (Jira issue keys aren't known until creation, so use the slug;
  the user renames after creating the issue in Jira if they want key-based names.)
- `.claude/jira-planning/` lives under `.claude/` and should remain out of commits. No need to ask the user about gitignoring.

## File contents

Every issue file follows the templates in the `jira-formats` skill — read its
SKILL.md before writing. Calibrate detail per likely assignee tier (the overview
file records the suggested tier per issue; the issue text itself should be
self-sufficient for that tier).

### 00-overview.md

Not pasted into Jira — it's the session record and the map. Contains:

```markdown
# {Feature name} — planning summary

Date: {YYYY-MM-DD}
Repo: {repo name}

## Shared understanding
{The confirmed bullet summary from the alignment phase, verbatim.}

## Out of scope
{Explicit exclusions agreed during grilling.}

## Issue map
| # | File | Title | Type | Suggested tier | Depends on |
|---|------|-------|------|----------------|------------|

## Decisions made this session
{One line each, with links to any ADRs created.}

## Open questions / risks
{Anything consciously deferred.}
```

## Writing principles

- **The reader is the assignee, not the planner.** A junior developer should be able
  to implement from the issue text plus the repo. Include concrete anchors: real
  table names, real class names, real routes, naming conventions with placeholders
  (`_LUO_MASTER_{term}`), sample payloads.
- **Reference real code.** When the work extends an existing pattern, name the file
  that demonstrates the pattern ("follow the pagination approach in
  `MasterController`").
- **Encode dependency strategy in the text.** If an issue depends on unfinished
  work, say so by slug/key and prescribe the interim approach (mock data, feature
  flag, stub service) exactly as the LDB-1246 example does — including a sample SQL
  query or fixture where helpful.
- **Diagrams when they pay rent.** Produce a Mermaid sequence diagram for
  multi-system flows (scheduled jobs hitting external APIs, multi-step workflows).
  Skip diagrams for simple CRUD.
- After writing, list every file created with a one-line description, then proceed
  to the plan-with-me retrospective phase.

## Iteration

The user will review and request changes ("split the Angular work", "make the DB
sub-task more detailed"). Apply edits to the files directly and re-list what
changed. The files are the artifact of record, not the chat.
