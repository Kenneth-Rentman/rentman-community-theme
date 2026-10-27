// Category grid above the topic list, per the IA doc's eight flat categories.
//
// Renders from site.categories — real names, real counts, and the icon each
// category carries. Discourse has native `icon`, `emoji` and `style_type`
// fields per category; nothing here needs a theme setting mapping slugs to
// icons.
//
// The category COLOUR is deliberately ignored. The tile is always the inverse
// of the page — ink on light, beige on dark — which is handled entirely in
// CSS. This replaced a system that read each category's colour and computed a
// readable glyph for it; that machinery existed to make arbitrary colours
// legible, and every category is now the same colour. It also could not
// survive dark mode: the admin colour is a single value shared by both
// schemes, and #202121 is the dark page background, so tiles rendered
// invisible. See common.scss at .rm-cat__tile.
//
// Rendered into `discovery-list-controls-above`, i.e. ABOVE the Latest /
// Categories tab bar — not `discovery-above`, which sits between the tabs and
// the list they filter. Categories are a way INTO content; putting them
// between a tab bar and its own list breaks that relationship.
//
// Topic lists only. Not discovery.categories — that page IS a category list.

import Component from "@glimmer/component";
import { service } from "@ember/service";
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
              <span class="rm-cat__tile" aria-hidden="true">
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
