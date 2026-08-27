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

function isHex(color) {
  return !!color && /^[0-9a-f]{6}$/i.test(color);
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
      .map((c) => ({
        id: c.id,
        slug: c.slug,
        name: c.name,
        icon: c.style_type === "icon" ? c.icon : null,
        countLabel: `${c.topic_count} ${
          c.topic_count === 1 ? "topic" : "topics"
        }`,
        // Only the icon carries the category's colour. The tile stays a
        // neutral grey — tinting it in the category colour turned every card
        // into a peach square and, with all categories currently the same
        // orange, told the reader nothing.
        iconStyle: isHex(c.color)
          ? htmlSafe(`color: #${c.color};`)
          : null,
      }));
  }

  // Drives the column count so cards always fill the row at equal width,
  // whatever number of categories exists.
  get columns() {
    return Math.min(this.categories.length, MAX_PER_ROW);
  }

  <template>
    {{#if this.show}}
      <section class="rm-cats">
        <h2 class="rm-cats__title">Browse categories</h2>

        <div class="rm-cats__grid" data-columns={{this.columns}}>
          {{#each this.categories as |c|}}
            <a class="rm-cat" href="/c/{{c.slug}}/{{c.id}}">
              <span class="rm-cat__tile" style={{c.iconStyle}} aria-hidden="true">
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
