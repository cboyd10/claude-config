# Security Checklist

> Distilled from the internal IT Dev Application and API Security Standards
> (last refreshed 2026-07-02). The source doc changes at most yearly. When the
> user provides an updated copy, propose a diff to this file.

Only diff-reviewable items are listed. Infrastructure topology, vendor product
names, and internal policy links are intentionally excluded — this file syncs to
a public repo. A security gap here is a **Blocking** finding.

## SQL and database access

- **Parameterized SQL only.** No string-concatenated SQL. Use `PreparedStatement`
  or JPA — never build a query by concatenating user input into the SQL text.
- **Least-privilege DB service accounts.** The account should have only the access
  the app needs (only the tables it touches; read-only where it never writes).

## Input validation

- **Validate and sanitize every endpoint parameter** — route params, query params,
  and request bodies (POST *and* GET). Assume every input is malicious.
- **Whitelist over blacklist.** Allow known-good parameters/values rather than
  trying to block known-bad ones.
- **XSS guards.** Do not let user-supplied content execute as code. Sanitize
  user-created submissions (e.g. form fields) before they are stored or rendered.
- **XML injection guards.** If data moves via XML, use a parser configured to
  handle XML safely; do not let users edit XML/HTML that the app later trusts.

## CSRF and session handling

- **CSRF protection** for anything using session cookies for authentication — use
  built-in framework protection or CSRF tokens.
- Prefer **API token auth via request headers** over cookie-based auth where
  possible.

## Secrets

- **No plain-text secrets** in source code, scripts, config files, or the repo.
  A secret is any password, key, API token, or sensitive identifier.
- Secrets come from **environment variables or a secret store**, mapped into the
  app securely — never committed.
- If an encrypted secret must live in the repo (non-prod env vars), the
  encryption/decryption key stays **out** of the repo.

## Logging

- **No sensitive or personally identifying data in logs.** Mask, redact, or
  tokenize it.
- **Log the minimum** needed for troubleshooting and auditing.
- **Never log request/response bodies wholesale** — that can expose PII.
- Identifying fields (username, partial email, user id) may be logged only when
  necessary, and never combined in a way that reconstructs full PII.

## Authentication and authorization for personal data

- Endpoints handling personal data require **authentication AND authorization** —
  verify the requestor's right to *that specific data*, not merely that they are
  logged in.
  - An endpoint accepting a change for a user must confirm the data belongs to a
    user the requestor is allowed to act on.
  - An endpoint returning personal data must confirm the requestor is authorized
    to read *that* data.
- **Return the minimum data** the task needs — do not return extra fields "just in
  case."
- **JWT validation via an established library** — never hand-roll token validation.
- Use the corporate SSO solution for end-user authentication rather than ad-hoc
  auth systems.

## Required security tests for a new secured endpoint

Every secured endpoint must have this test trio. **Missing these on a new secured
endpoint is a Blocking finding:**

1. Valid authentication (and authorization) → **200**.
2. No authentication → **401**.
3. Valid authentication but wrong permissions → **403**.

## Rate limiting

- Consider **rate limiting for new public endpoints that do heavy work** (large
  reports, expensive queries, high-frequency operations). Flag the absence as a
  point to weigh, especially for public-facing or load-heavy endpoints.
