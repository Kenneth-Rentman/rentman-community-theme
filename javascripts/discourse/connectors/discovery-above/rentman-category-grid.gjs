// Category grid above the topic list, per the IA doc's eight flat categories.
//
// Renders from site.categories — real names, real counts, and the icon and
// colour each category already carries. Discourse has native `icon`, `emoji`
// and `style_type` fields per category; nothing here needs a theme setting
// mapping slugs to icons.
//
// Topic lists only. Not discovery.categories — that page IS a category list.

import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import dIcon from "discourse/helpers/d-icon";

const SHOW_ON = ["discovery.latest", "discovery.top", "discovery.hot"];
const MAX_PER_ROW = 8;

// "FF5E1D" -> "255, 94, 29", or null if it isn't a plain six-digit hex.
function toRgb(hex) {
  if (!hex || !/^[0-9a-f]{6}$/i.test(hex)) {
    return null;
  }
  const n = parseInt(hex, 16);
  return `${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}`;
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
      .filter(
        (c) =>
          !c.parent_category_id &&
          c.id !== uncategorized &&
          // Staff-only rooms shouldn't sit in a public browse grid, even for
          // the staff who can see them — the sidebar already lists those.
          !c.read_restricted
      )
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0))
      .map((c) => {
        const rgb = toRgb(c.color);

        return {
          id: c.id,
          slug: c.slug,
          name: c.name,
          icon: c.style_type === "icon" ? c.icon : null,
          countLabel: `${c.topic_count} ${
            c.topic_count === 1 ? "topic" : "topics"
          }`,
          // Tinted tile in the category's own colour, with the icon at full
          // strength on top.
          tileStyle: htmlSafe(
            rgb
              ? `background: rgba(${rgb}, 0.14); color: #${c.color};`
              : `background: var(--rentman-beige); color: var(--rentman-ink);`
          ),
        };
      });
  }

  // Drives the column count so cards always fill the row at equal width,
  // whatever number of categories exists.
  get columns() {
    return Math.min(this.categories.length, MAX_PER_ROW);
  }

  <template>
    {{#if this.show}}
      <section class="rm-cats">
        <div class="rm-cats__head">
          <h2 class="rm-cats__title">Browse categories</h2>
          <a class="rm-cats__all" href="/categories">All categories</a>
        </div>

        <div class="rm-cats__grid" data-columns={{this.columns}}>
          {{#each this.categories as |c|}}
            <a class="rm-cat" href="/c/{{c.slug}}/{{c.id}}">
              <span class="rm-cat__tile" style={{c.tileStyle}} aria-hidden="true">
                {{#if c.icon}}{{dIcon c.icon}}{{/if}}
              </span>
              <span class="rm-cat__name">{{c.name}}</span>
              <span class="rm-cat__count">{{c.countLabel}}</span>
            </a>
          {{/each}}
        </div>
      </section>
    {{/if}}
  </template>
}
