# Handover — Rentman Community theme

Last updated 2026-09-08. Scratch notes for picking the work back up; not part of the theme.

## Where things stand

Two themes on **mcp-beta.rentman.io**:

| Theme | Name | Branch | Auto-update |
|---|---|---|---|
| 8 | Rentman Community (default, live) | `main` | off — updated by hand |
| 12 | Rentman Community [DEV] | `develop` | on |

Workflow: push to `develop`, look at it on theme 12, and when it's approved merge to
`main` and update theme 8 from the admin.

**Unmerged:** `1c06f3d` (sprite plumbing test) and `022f6c1` (flip the tile + the
eight real icons), both on `develop` only. `main` is still at `030cd93`. Theme 8 has
not been updated from admin, so the live theme is two commits behind `develop` and
does not carry the sprite.

## What's built

- **Header** — Discourse's own, restyled toward the Support Center. Logo via the
  `home-logo__after` outlet (`home-logo-contents` is a *replacement* outlet — don't
  use it), sized with `--d-logo-height`, scoped to ≥768px so mobile keeps its
  step-down.
- **Hero** — transparent, left-aligned, CTAs from theme settings.
- **Homepage category grid** — `rentman-category-grid.gjs`, 4-up, horizontal cards,
  driven by `site.categories`. Exclusions come from the `category_grid_excluded`
  setting (slug or numeric id). The category colour fills the 32px **tile**; the 16px
  glyph sits on it in white or ink, **computed** from the tile's relative luminance
  rather than configured — see the colour note below for why.
- **Category page header** — `rentman-category-header.gjs`. Shares the
  `discovery-list-controls-above` outlet with the grid; they never both render.
- **Footer** — ported from the Zendesk Support Center, with a live fetch of
  `status.rentman.io`.
- **Leaderboard** — colour and type only. Geometry overrides were tried and reverted;
  the plugin positions the podium with transforms and it breaks if you touch sizes.
- **Right rail** — hidden on mobile.

## House rules the styling follows

- **Orange (`#ff5e1d`) is an accent, never text.** 3.06:1 on white — it clears the 3:1
  UI threshold but not 4.5:1 for text. Used for hovers, underlines, focus rings,
  active tabs. It *can* be a tile fill: as a background with an ink glyph it reaches
  5.28:1.
- **Colour fills the tile, never the glyph.** Tinting a 13px glyph made the colour a
  foreground needing 3:1 against `#f4f4f4`, which seven of the eleven brand-book
  values fail — brand orange 2.78, Crew yellow 1.54, green 2.30. As a tile fill every
  brand value passes, and it is the brand's own rule for product icons (book p.26:
  they "should always sit on an orange square background"). Do not go back to tinting.
- **A tile also has to read against the white card.** Beige is 1.21:1 there and Crew
  yellow 1.69, so every tile carries `inset 0 0 0 1px rgba(32,33,33,.1)`. Without it
  pale tiles look like a glyph floating in nothing.
- **Four sizes, three weights.** The scale is documented at the top of
  `common/common.scss`. Anything outside it is a bug.
- **No uppercase anywhere.** rentman.io only uses it for a "New" badge and language
  codes.
- Surfaces were measured off live Rentman properties, not inferred from swatch lists.
  White ground, `#eee9e1` only for deliberate bands.

## Category colours

Superseded 2026-09-10. The old table (five invented hues, orange avoided) was rejected
by Marketing. Replaced by two all-brand variants — see the review page below. Every
value now comes from the brand book; nothing is invented.

Brand-locked by the book (p.23): **Equipment = `#635BF9`**, **Crew = `#FCBD01`**. The
earlier draft gave that purple to Projects, which conflicts with the book and is the
likeliest reason the draft read as off-brand.

Note `#FCBD01` and `#2ABA67` cannot be glyph tints (1.54 and 2.30) — they only work as
tile fills. Brand orange is `#FF5E1D` (book p.21); the `rentman-slides` skill carries
`#FF5A1F`, which is stale and should be corrected at the source.

Review page (palettes, icons, contrast tables):
https://claude.ai/code/artifact/381760ab-dccd-418a-9f33-2f57aaab9da8

Mockup: https://claude.ai/code/artifact/d3a7c15b-874b-4e09-954a-5adb27fbbbcb

## Open

- Update theme 8 from the Discourse admin to pull `030cd93`.
- Announcements is still orange — see the note above about orange being the
  interaction colour.
- Category `position` values collide, so the grid order isn't quite intentional.
- Set `category_grid_excluded` to `staff`.
- **Pick a palette variant** — A (5 chromatic + 3 stepped neutrals) or B (orange family
  as the commercial spine, recommended). Both all-brand. Colours are admin config, so
  switching is minutes.
- **Judge the eight icons on theme 12.** Drawn in the p.26 product-icon language
  (rectangles and squares only) because the p.27 outline library dies at 16px. Six hold
  up; **Crew and Getting Started are weak** — Crew reads as two cards, Getting Started
  as a grid. Either redraw those two, or swap the whole set to Lucide (MIT, 24px grid,
  2px stroke — already our spec). Do not mix two drawing languages across eight
  adjacent tiles. Note the flip means the *tile* carries the brand, so a library glyph
  costs less identity than it would have before.
- **Projects on `#D44200` is provisional** — p.22 says shades should never be main
  colours, though it lists backgrounds as their use, which this is. Wants a brand nod.
- **Topic page** — never looked at.
- **Mobile** — two fixes, no systematic review. Note that Discourse's mobile view is
  user-agent based (`body.mobile-view`), so the browser pane's viewport emulation
  does *not* trigger it. Mobile bugs have to be checked on a real device.
- **Events widget** — deferred until there are real events to pull.
- **SSO** — DiscourseConnect is exclusive, OIDC is additive; existing accounts link by
  verified email. Dev meeting was the driver here.
- **Dark mode** — broken, but inert: no dark scheme is offered to members.
- **Where the 8-category IA finally lives** — mcp-beta or a fresh instance. Still open.

## Traps worth remembering

- `.gjs` files are **JS modules**. A top-level `<template>` is the default export;
  comments outside it must be JS comments, not `{{!-- --}}`.
- `a:visited` has specificity (0,1,1) and beats any single class on an anchor. This
  caused orange text twice, intermittently — only after a link had been visited.
- This site runs `uc-modernize-foundation-theme`, so some components read
  differently-named tokens via zero-specificity `:where()`. The hero reads
  `--welcome-banner-text-align`, not the documented
  `--d-welcome-banner-text-alignment`. Set both.
- Never edit `common.scss` by line arithmetic. An unbalanced brace kills the whole
  stylesheet and the theme loses all CSS. Use exact-match replacement and check
  brace balance after.
- **Custom category icons work via a theme SVG sprite.** One asset named
  `icons-sprite` in `about.json` (`SvgSprite::THEME_SPRITE_VAR_NAME`); every
  `<symbol id>` inside becomes an icon name, pickable in the category admin next
  to Font Awesome. Symbols inherit `currentColor`, so the per-category colour
  tint keeps working — which is why this beats custom emoji, whose fixed bitmaps
  throw the contrast table away and leak into the post/chat emoji pickers.
  Requires: square viewBox, no `fill` attributes, sprite under 1 MB.
- **The icon picker resolves against the ACTIVE theme, not the theme you edited.**
  `SvgSpriteController` passes `@theme_id` from `ThemeResolver.resolve_theme_id`
  (preview param > cookie > user preference > site default). A sprite pushed to
  `develop`/theme 12 is invisible in admin while you are browsing under theme 8.
  Worse, a DEV theme only appears in Preferences -> Interface if it is flagged
  **user selectable**. Confirm with, in the console,
  `[...document.scripts].map(s=>s.src).find(s=>s.includes("svg-sprite"))` — the
  URL contains the theme id it actually used. Previewing is not enough: the
  picker's XHR goes through `ajax()`, which does not append `preview_theme_id`.
- The category icon is stored as a bare string on the category and resolved
  against the *viewer's* theme. The sprite must reach theme 8 BEFORE any category
  points at a custom icon, or every member sees a blank tile.
- `svg_icon_subset` is not the mechanism — sprite symbols self-register via
  `SvgSprite.custom_icons`. It only injects extra names into `all_icons`.
- **Theme 12's auto-update is not reliable, or not quick.** `1c06f3d` appeared within
  about two minutes; `022f6c1` had still not been pulled 45 minutes later. Treat the
  fast case as the anomaly. After pushing to `develop`, click **Check for updates** on
  theme 12 in admin rather than waiting.
- **Two markers tell you whether theme 12 is current, without admin access.** Fetch
  `/?preview_theme_id=12` with a browser User-Agent (curl's own UA returns the crawler
  view, which carries no sprite or theme CSS at all) and a cache-busting query param,
  then grep the served `common_theme_12_*.css` for a string unique to the commit, and
  the `/svg-sprite/...svg-12-<hash>.js` for an expected symbol id. The sprite hash is
  derived from the bundle, so an unchanged hash means the server is still building the
  old bundle — not that a CDN cached the answer.
- Before analysing a screenshot of theme 12, confirm it actually pulled the latest
  commit — fetch the served `common_theme_12.css` and grep for a known marker.
