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
// Eight again, but only because the card is now horizontal. Stacked
// icon-over-name-over-count made each card ~110px tall, so 4x2 cost ~230px of
// vertical space before any content. Side-by-side brings a card to ~55px, and
// eight of those in one row take less height than one row of the old ones.
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
      // No read_restricted filter. site.categories already contains only what
      // the current user can see, so a restricted category in this list is
      // one they have access to — and hiding it from the grid while the
      // sidebar lists it is just confusing. Private categories now appear for
      // the people who can read them, and for nobody else.
      .filter((c) => !c.parent_category_id && c.id !== uncategorized)
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
