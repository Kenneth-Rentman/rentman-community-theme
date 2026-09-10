// Category grid above the topic list, per the IA doc's eight flat categories.
//
// Renders from site.categories — real names, real counts, and the icon and
// colour each category already carries. Discourse has native `icon`, `emoji`
// and `style_type` fields per category; nothing here needs a theme setting
// mapping slugs to icons.
//
// Rendered into `discovery-list-controls-above`, i.e. ABOVE the Latest /
// Categories tab bar — not `discovery-above`, which sits between the tabs and
// the list they filter. Categories are a way INTO content; putting them
// between a tab bar and its own list breaks that relationship.
//
// Topic lists only. Not discovery.categories — that page IS a category list.

import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import dIcon from "discourse/helpers/d-icon";

const SHOW_ON = ["discovery.latest", "discovery.top", "discovery.hot"];
// Back to four, but keeping the horizontal card. Eight in one row fits, and
// costs only ~55px, but at ~195px per card the text is cramped and the longer
// names clip. The saving was always in the card layout rather than the column
// count: horizontal 4x2 is ~128px against ~230px for the old stacked 4x2,
// with room for every name on one line.
const MAX_PER_ROW = 4;

// Categories to keep out of the grid, from the theme setting. Discourse hands
// list settings back as a pipe-delimited string on some versions and an array
// on others, so both are handled. Matched against slug OR id, since a slug is
// readable in admin but changes if the category is renamed.
const EXCLUDED = (() => {
  const raw = settings.category_grid_excluded;
  const parts = Array.isArray(raw) ? raw : String(raw ?? "").split("|");
  return parts.map((v) => String(v).trim().toLowerCase()).filter(Boolean);
})();

function isHex(color) {
  return !!color && /^[0-9a-f]{6}$/i.test(color);
}

// The tile carries the category colour and the glyph sits on top of it, so the
// glyph needs to be white on dark tiles and ink on pale ones. That could be a
// second setting to maintain alongside the colour, but it is derivable: only
// two glyph colours are ever in play, so take whichever contrasts better.
// Deriving it means the pair can never drift out of sync in admin.
const INK = "202121";

function channel(v) {
  const c = v / 255;
  return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

// WCAG 2.1 relative luminance.
function luminance(hex) {
  const n = parseInt(hex, 16);
  return (
    0.2126 * channel((n >> 16) & 255) +
    0.7152 * channel((n >> 8) & 255) +
    0.0722 * channel(n & 255)
  );
}

function contrast(a, b) {
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

const INK_LUMINANCE = luminance(INK);

function glyphColor(hex) {
  const tile = luminance(hex);
  // #fff has a relative luminance of exactly 1.
  return contrast(tile, 1) >= contrast(tile, INK_LUMINANCE) ? "#fff" : `#${INK}`;
}

export default class RentmanCategoryGrid extends Component {
  @service site;
  @service router;

  get show() {
    return (
      SHOW_ON.includes(this.router.currentRouteName) &&
      this.categories.length > 0
    );
  }

  get categories() {
    const uncategorized = this.site.uncategorized_category_id;

    return (this.site.categories ?? [])
      // No read_restricted filter. site.categories already contains only what
      // the current user can see, so a restricted category in this list is
      // one they have access to — and hiding it from the grid while the
      // sidebar lists it is just confusing. Private categories now appear for
      // the people who can read them, and for nobody else.
      .filter(
        (c) =>
          !c.parent_category_id &&
          c.id !== uncategorized &&
          !EXCLUDED.includes(String(c.slug).toLowerCase()) &&
          !EXCLUDED.includes(String(c.id))
      )
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0))
      .map((c) => ({
        id: c.id,
        slug: c.slug,
        name: c.name,
        icon: c.style_type === "icon" ? c.icon : null,
        countLabel: `${c.topic_count} ${
          c.topic_count === 1 ? "topic" : "topics"
        }`,
        // The category colour fills the TILE, not the glyph. Tinting a 13px
        // glyph made the colour a foreground needing 3:1 against the grey
        // tile, which most of the brand palette fails — brand orange at 2.78,
        // Crew yellow at 1.54. As a tile fill it is a background, the contrast
        // test moves to glyph-against-tile, and every brand value passes. It
        // is also what the brand book asks for: product icons sit on a filled
        // square (p.26).
        //
        // A category with no icon still gets the colour chip, since an empty
        // tile reads as a failed load.
        iconStyle: !isHex(c.color)
          ? null
          : htmlSafe(
              `background: #${c.color}; color: ${glyphColor(c.color)};`
            ),
      }));
  }

  // Drives the column count so cards always fill the row at equal width,
  // whatever number of categories exists.
  get columns() {
    return Math.min(this.categories.length, MAX_PER_ROW);
  }

  <template>
    {{#if this.show}}
      {{! No heading — four labelled cards don't need a label above them. }}
      <section class="rm-cats">
        <div class="rm-cats__grid" data-columns={{this.columns}}>
          {{#each this.categories as |c|}}
            <a class="rm-cat" href="/c/{{c.slug}}/{{c.id}}">
              <span class="rm-cat__tile" style={{c.iconStyle}} aria-hidden="true">
                {{#if c.icon}}{{dIcon c.icon}}{{/if}}
              </span>
              <span class="rm-cat__text">
                <span class="rm-cat__name">{{c.name}}</span>
                <span class="rm-cat__count">{{c.countLabel}}</span>
              </span>
            </a>
          {{/each}}
        </div>
      </section>
    {{/if}}
  </template>
}
