# Work-stack exploration guidance (Oracle / Spring Boot / Angular)

Read this when grilling or orienting in a WORK repo. Personal projects skip this
file entirely — infer their stack from the repo itself. When exploration is
delegated (see EXPLORATION.md), fold the relevant bullets into the Explore
agent's brief.

When exploring before or during grilling, ground yourself in:

- **Schema truth**: Liquibase/Flyway changelogs or DDL scripts; Oracle-specific
  constructs (sequences, views like `*_VIEW`, synonyms, schema-qualified names).
  When a new status or category value is proposed, check Oracle DDL scripts for
  `CHECK` constraints on the relevant column — adding a new value requires a
  migration to drop and recreate the constraint (see `skipjack-banner-sql/scripts/`
  for the established pattern).
- **Data model**: JPA entities, `@Table`/`@Column` mappings, relationships, and any
  mismatch between entities and the actual schema.
- **Back end patterns**: how this repo structures controllers → services →
  repositories, DTO conventions, exception handling, scheduled jobs
  (`@Scheduled`), external API clients (e.g. Canvas API client patterns).
- **Front end patterns**: Angular module/route structure, component naming, shared
  table/filter/pagination components that already exist, HTTP service patterns.
- **Existing conventions over invention**: if the repo already has a pattern for the
  thing being planned (paginated endpoints, error display, hourly jobs), the default
  recommendation is to follow it. Deviating is a decision worth surfacing.
