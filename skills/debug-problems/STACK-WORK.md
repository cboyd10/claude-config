# Work-stack debugging guidance (Oracle / Spring Boot / Angular)

Read this when debugging in a WORK repo. Personal projects skip this file
entirely — infer their stack and runtime access from the repo itself.

## What you can run vs what routes through the user

Agent-runnable (do these yourself, filtered at the shell):

- `./gradlew test` — narrow with `--tests '<pattern>'`; prefer a targeted slice
  test (`@DataJpaTest`, `@WebMvcTest`) as a discriminating check.
- Angular unit tests (single-run, headless) and builds.
- Static analysis, `grep` over code, DDL, and Liquibase/Flyway changelogs.

User-as-instrument (one observation request at a time, with the
confirms-vs-falsifies outcome stated):

- The running application and its UI.
- Oracle queries — hand over exact SQL, schema-qualified.
- Server logs and Bamboo build/deploy logs.
- Anything environment-specific (test vs prod config, secrets, Canvas API
  responses).

## Where bugs hide on this stack

Check the cheap, high-yield mismatches before deep tracing:

- **Entity/schema drift**: JPA `@Column`/`@Table` mappings vs the actual DDL;
  a `CHECK` constraint rejecting a new status value is a classic (see
  `grill-with-docs/STACK-WORK.md` for the constraint-migration pattern).
- **Changelog state**: a Liquibase/Flyway changeset present in code but not run
  in the environment showing the bug.
- **Transaction boundaries**: `@Transactional` missing or self-invoked, lazy
  loading outside a session.
- **Scheduled jobs**: `@Scheduled` overlap, timezone assumptions, silent
  swallowed exceptions in job bodies.
- **External clients**: Canvas API error handling — non-2xx paths, pagination,
  token expiry.
- **Angular**: stale observable chains, change detection on mutated objects,
  interceptor behavior on error responses, environment file mismatches.
- **Environment mismatch**: "works locally, fails deployed" → compare Spring
  profiles, Helm values, and Bamboo variables for the differing setting before
  suspecting code.

## Exploration grounding

When delegating a trace per `grill-with-docs/EXPLORATION.md`, fold the relevant
grounding bullets from `grill-with-docs/STACK-WORK.md` (schema truth, data
model, back/front-end patterns) into the Explore agent's brief, plus the
symptom and the hypothesis under test.
