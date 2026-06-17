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

## Collect Jira keys for new issues

Jira key collection happens through the `00-overview.md` issue map table — not via
a chat prompt.

**Step 1: Write `00-overview.md` first.** Before writing any issue files, write the
overview file with the full issue map table. Include every parent issue and sub-task
(sub-tasks as `N.M` numbered rows). Leave the `Jira Slug` column blank for new issues.
Already-known keys go in immediately.

Issue map table format:

```
| #   | Jira Slug | Title                               | Type            | Suggested tier | Depends on |
|-----|-----------|-------------------------------------|-----------------|----------------|------------|
| 1   |           | Implement HierarchyAccessRepository | Technical Story | Junior         | —          |
| 1.1 |           | Sub-task: DB layer                  | Sub-task        | Junior         | —          |
| 1.2 |           | Sub-task: Service layer             | Sub-task        | Junior         | 1.1        |
| 2   |           | Create enriched security principal  | Technical Story | Junior         | 1          |
```

**Step 2: Ask the user to fill in slugs.** Prompt: "I've written `00-overview.md`
with the full issue map. Please create any new issues in Jira and fill in the
`Jira Slug` column — including sub-tasks — then let me know and I'll write the
issue files."

**Step 3: Read the table and write files.** Once the user signals the slugs are in,
read the `00-overview.md` table. Use the slugs for file names (`LDB-1302.md`) and
all cross-references (Depends on / Is Blocked By) across every file. Never write
a file with a placeholder slug when the real key is obtainable from the table.

## Output location and naming

Write to the repo's `.claude/` directory:

```
.claude/jira-planning/
└── {epic-slug}/                         ← if an epic slug was provided
    or {YYYY-MM-DD}_{feature-slug}/      ← if no epic
    ├── 00-overview.md
    ├── PLANNING-HANDOFF.md              ← written by /wrap-up; may exist on resume
    ├── {ISSUE-SLUG}.md
    ├── {ISSUE-SLUG}.md
    ├── ...
    ├── attachments/                     ← Mermaid diagrams, sequence diagrams referenced from issue files
    │   ├── {issue-slug}-sequence-diagram.mermaid
    │   └── ...
    └── docs/                            ← Planning-support reference documents (UI specs, API references, etc.)
        ├── {feature}-ui-design.md
        └── ...
```

- Move any planning-support reference documents created during the session (UI specs,
  API option class references, data dictionaries, etc.) into `docs/`. Do not mix them
  with issue files or mermaid diagrams.

- One file per Jira issue (story or technical story). Sub-tasks live INSIDE their
  parent issue's file — they are pasted into Jira as sub-tasks of that issue.
- File name is the Jira issue slug only: `LDB-1302.md`. No numbering prefix.
- Mermaid diagrams and other attachments go in `attachments/`, named
  `{issue-slug}-{diagram-type}.mermaid`, and are referenced from the issue file by
  relative link. (Jira issue keys are collected before writing — see "Collect Jira
  keys for new issues" above — so the slug is always known at write time.
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
| #   | Jira Slug | Title | Type | Suggested tier | Depends on |
|-----|-----------|-------|------|----------------|------------|

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
