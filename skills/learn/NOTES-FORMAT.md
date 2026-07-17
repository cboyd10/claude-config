# NOTES.md Format

`{subject-slug}/NOTES.md` is the subject's progress log and resume mechanism —
the learning counterpart of an IMPLEMENTATION HANDOFF, except it is permanent
and committed: it accumulates one entry per session for the life of the
subject. Written by the learn skill's WRAP phase; read by RESUME to land the
next session exactly where the last one stopped.

## Structure

```markdown
# Notes: {Subject}

## Resume

- Next up: {teach lesson NN ({title}) | resume review of lesson NN at {section/thread}}
- Open threads: {unanswered or half-answered review questions, if any; else omit}

## Sessions

### {YYYY-MM-DD} — lesson {NN}: {title}

- Review: {completed | reached {section}, ended early}
- Questions asked: {the questions from the review, compressed to one line each}
- Weak spots: {concepts the questions suggest didn't land; what to reinforce}
- Seeds: {backlog entries created this session, if any}

### {YYYY-MM-DD} — onboarding

- {One line: syllabus created, N lessons planned, teaching approach in a phrase}
```

## Rules

- **The resume block is the contract.** RESUME reads only it to decide where
  to land; everything it needs must be there. Rewrite it wholesale at every
  WRAP — it describes the next session, not this one.
- **Resume at review granularity.** A session that ended mid-review names the
  lesson, the section reached, and the open threads, so the next session
  reopens the review instead of re-teaching.
- **Sessions are prepended** — newest first, one `###` entry per session,
  including sessions that only reviewed or only onboarded.
- **Weak spots are for the tutor.** They tell a future session what to weave
  back into upcoming lessons or self-checks; be honest, not polite.
- Keep entries compressed — one line per item. The lesson HTML carries the
  content; NOTES.md carries only the trajectory.
