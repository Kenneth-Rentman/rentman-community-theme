// Mini-tiles for the sidebar's category icons.
//
// WHY THIS EXISTS AT ALL. Discourse renders a sidebar category icon as a glyph
// tinted in the category colour — a foreground. That is the model the homepage
// grid deliberately moved away from, because a foreground has to clear 3:1 and
// most of the Rentman palette cannot: Crew yellow is 1.69:1 on white and beige
// is 1.21:1. Under either proposed palette four of the eight sidebar icons
// would be effectively invisible. Filling the prefix instead turns the colour
// back into a background, and the glyph gets white or ink on top.
//
// WHY IT IS JAVASCRIPT AND NOT CSS. The tile fill could be done in pure CSS
// with `background: currentColor`, since Discourse sets the colour inline on
// the prefix span. But the glyph then needs to be white on dark tiles and ink
// on pale ones, and CSS cannot compute a contrast ratio. So the per-category
// pairs are generated here and the geometry stays in common.scss.
//
// HOW IT TARGETS. Sidebar category links carry `data-link-name="<slug>"` —
// CategorySectionLink#name returns category.slug. Discourse's own inline style
// sets `color` on the PREFIX SPAN, so setting `color` on the child
// `.prefix-icon` wins on the cascade without needing !important.

import {
  accentGlyphColor,
  glyphColor,
  isHex,
} from "../lib/rentman-tile-colors";

// Mirrors the grid, so the two surfaces never disagree about a category.
const GLYPH = () =>
  settings.tile_glyph_accent ? accentGlyphColor : glyphColor;

const STYLE_ID = "rentman-sidebar-tiles";

// CSS.escape isn't guaranteed in every browser Discourse supports, and a slug
// can legitimately contain characters that need escaping in an attribute
// selector. Slugs are [a-z0-9-] in practice, so anything else is skipped
// rather than risking a malformed rule that kills the whole stylesheet.
function isSafeSlug(slug) {
  return typeof slug === "string" && /^[a-z0-9-]+$/i.test(slug);
}

function buildCss(categories) {
  return categories
    .filter((c) => isSafeSlug(c.slug) && isHex(c.color))
    .map((c) => {
      const sel = `.sidebar-section[data-section-name="categories"] .sidebar-section-link[data-link-name="${c.slug}"] .sidebar-section-link-prefix.icon`;
      return (
        `${sel}{background:#${c.color};color:${GLYPH()(c.color)}}` +
        // Only the glyph. NOT the lock badge on restricted categories: it is
        // positioned to overhang the tile's top-right corner onto the sidebar
        // ground, so it needs to contrast with the sidebar, not with the tile.
        // Giving it the glyph colour turned it white on a black tile, i.e.
        // invisible. Discourse's own --d-sidebar-link-color is correct here.
        `${sel} .prefix-icon{color:${GLYPH()(c.color)}}`
      );
    })
    .join("");
}

export default {
  name: "rentman-sidebar-tiles",
  // No `after:` ordering. An earlier version declared `after: "message-bus"`,
  // which this needs nothing from — it only reads the site service, which is
  // built from preloaded data. An unresolvable dependency name can stop an
  // initializer running altogether, and the sibling initializer that does work
  // declares no ordering either.

  initialize(owner) {
    try {
      const site = owner.lookup("service:site");
      const categories = site?.categories;

      if (!categories?.length) {
        return;
      }

      const css = buildCss(categories);
      if (!css) {
        return;
      }

      // Categories don't change within a session, so this is written once.
      let el = document.getElementById(STYLE_ID);
      if (!el) {
        el = document.createElement("style");
        el.id = STYLE_ID;
        document.head.appendChild(el);
      }
      el.textContent = css;
    } catch (e) {
      // A sidebar without tiles is a cosmetic loss. Taking the app down with
      // it is not, so this never throws.
      // eslint-disable-next-line no-console
      console.warn("rentman-sidebar-tiles: skipped", e);
    }
  },
};
