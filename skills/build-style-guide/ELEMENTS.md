# Element checklist

The full inventory a style-guide page covers. New apps take the whole list;
apps with existing styling take only the elements the ORIENT exploration found
in use (the rest arrive per-client later). Suggested BEM block names are
defaults — bend to the client repo's existing naming if one exists.

**Demo rules (apply to every section):**

- Elements are **live** — hover/focus/active are experienced by interacting,
  never duplicated into demo classes.
- **Persistent states get static side-by-side demos**: disabled,
  error/invalid, loading, checked/selected, and size variants.
- Every section renders correctly at mobile (~375px) and desktop (~1440px).

## Foundations

| Element | Demo |
|---|---|
| Colors | Primitive palette swatches + semantic token swatches, each labeled with its custom-property name |
| Typography | Type scale (h1–h6, body, small), links, inline code, `--font-*` tokens labeled |
| Spacing / radii / shadows | Labeled scale specimens |
| Iconography | The chosen icon set at the standard sizes |

## Buttons — `btn`

Variants: primary, secondary, tertiary/ghost, danger, link-style, icon-only,
with-icon. Static demos: sizes, disabled, loading.

## Form elements — `field`, plus per-control blocks

| Element | Block | Static demos |
|---|---|---|
| Text input | `input` | disabled, invalid (+ error message), with help text |
| Textarea | `textarea` | disabled, invalid |
| Select | `select` | disabled, invalid |
| Checkbox | `checkbox` | checked, indeterminate, disabled |
| Radio button | `radio` | checked, disabled, group layout |
| Toggle/switch | `toggle` | on, disabled |
| Slider | `slider` | with value label, disabled |
| Field wrapper | `field` | label + control + help/error text composition; a sample form layout |

## Content & data

| Element | Block | Notes |
|---|---|---|
| List | `list` | plain, with meta/actions per item |
| Table | `table` | header, zebra, row hover, empty state; horizontal scroll on mobile |
| Card | `card` | media/header/body/actions composition |
| Chips | `chip` | selectable, removable, disabled |
| Badge | `badge` | status colors, count on an icon |
| Avatar | `avatar` | image, initials, sizes |
| Divider | `divider` | horizontal, inset |
| Accordion / expansion panel | `accordion` | expanded + collapsed |
| Tabs | `tabs` | active, disabled tab; scrollable on mobile |
| Empty state | `empty-state` | icon + message + action |

## Feedback

| Element | Block | Notes |
|---|---|---|
| Loading indicators | `spinner`, `progress`, `skeleton` | inline, block, and skeleton-screen variants |
| Errors | `alert` | inline field error (see forms), page-level banner: error/warning/success/info |
| Toast / snackbar | `toast` | with action; stacking position per viewport |
| Tooltip | `tooltip` | placement variants |

## Overlays

| Element | Block | Notes |
|---|---|---|
| Dialog | `dialog` | header/body/footer; near-full-screen on mobile; focus trap noted for the component issue |
| Popover menu | `popover` | anchored menu with items, dividers, disabled item |
| Bottom sheet | `bottom-sheet` | the mobile counterpart of dialog/popover |

## Navigation

| Element | Block | Notes |
|---|---|---|
| Navigation menu | `nav` | desktop bar + collapsed mobile drawer/hamburger; active item |
| Breadcrumbs | `breadcrumbs` | truncation on mobile |
| Pagination | `pagination` | current, disabled prev/next; compact on mobile |
