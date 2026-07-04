# Angular specifics

Read when build-style-guide runs in an Angular client. Follow the repo's
existing conventions (standalone vs NgModule, naming) over anything here.

## The local-only /style-guide route

The route exists only when running locally, via Angular's file-replacement
feature — production builds never contain it.

**Files** (match the repo's route-file naming, e.g. `app.routes.ts`):

- `src/app/app.routes.base.ts` — the actual normal-routes array, exported.
- `src/app/app.routes.ts` — what `appConfig`/the router module imports;
  re-exports the base array unchanged.
- `src/app/app.routes.local.ts` — imports the base array and splices in the
  style-guide route **before any `**` wildcard**:

```ts
import { Routes } from '@angular/router';
import { baseRoutes } from './app.routes.base';

const styleGuideRoute = {
  path: 'style-guide',
  loadComponent: () =>
    import('./style-guide/style-guide-page.component')
      .then(m => m.StyleGuidePageComponent),
};

const wildcard = baseRoutes.filter(r => r.path === '**');
export const routes: Routes = [
  ...baseRoutes.filter(r => r.path !== '**'),
  styleGuideRoute,
  ...wildcard,
];
```

**Why three files, not two:** `fileReplacements` substitutes every import that
resolves to the replaced path — if `app.routes.local.ts` imported
`./app.routes` directly, the replacement would make it import itself. The
base file breaks the cycle. If you verify the client's bundler tolerates the
replacement file importing the replaced file, the third file can be dropped.

**angular.json** — add the replacement to the configuration `ng serve` uses
locally (`development` is the serve default on modern Angular; older repos may
need it added to whatever configuration local serve targets):

```json
"fileReplacements": [
  {
    "replace": "src/app/app.routes.ts",
    "with": "src/app/app.routes.local.ts"
  }
]
```

Verify both ways before the approval gate: the route serves under local
config, and a production build (`ng build`) neither routes `/style-guide` nor
bundles the page component.

For NgModule-era repos: same mechanic — keep the routes array in the replaced
file and let the routing module import it; lazy-load via `loadChildren` if the
repo predates standalone components.

## The style-guide page

- One lazy standalone component (or module, per repo era) under
  `src/app/style-guide/`, template organized by `ELEMENTS.md` sections with an
  in-page nav.
- Sections are raw BEM markup consuming the partials — no components exist
  yet. Interactive demos (dialog open/close, popover, bottom sheet, toast) may
  use minimal throwaway logic in the page component; it is replaced when the
  real components land.

## Styles wiring

`src/styles/` per the 7-1-lite layout (`abstracts/`, `base/`, `components/`),
`@use`d from the root `styles.scss` registered in `angular.json`. If the repo
already has a global-styles structure, integrate rather than duplicate — but
tokens and BEM partials stay the single source of truth.

## Component library (Phase 8 material — not built by this skill)

- Target home: `src/app/shared/ui/<component>/`, or the repo's existing shared
  component location if one exists.
- Components are thin: template = the BEM markup from the style guide, styling
  = the partials/tokens (no per-component style forks), API per the COMPONENT
  BRIEF sketch.
- **Angular CDK:** styled frameworks get replaced, but CDK is unstyled
  behavior primitives and is compatible with the BEM system. For dialog,
  popover, bottom sheet, tooltip, and select, recommend CDK (overlay,
  focus-trap, a11y) in the brief with plain pros/cons — e.g. *pro:*
  battle-tested focus trapping, positioning, and scroll blocking you'd
  otherwise hand-roll; *con:* a dependency to version-manage and a small
  learning curve. The user decides per client.
- Every component entry in the brief carries a11y acceptance criteria
  (keyboard operation, ARIA roles/states, focus management) — hand-rolled
  overlays and selects are where accessibility is usually lost.
