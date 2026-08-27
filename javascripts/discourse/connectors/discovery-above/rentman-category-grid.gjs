// Category grid above the topic list, per the IA doc's eight flat categories.
//
// Renders from site.categories — real names, real counts. Nothing invented,
// so it tells the truth about how much is actually in each room.
//
// Only on the top-level discovery lists: inside a category the grid would be
// repeating context the reader already has.

import Component from "@glimmer/component";
import { service } from "@ember/service";

const SHOW_ON = [
  "discovery.latest",
  "discovery.top",
  "discovery.hot",
  "discovery.categories",
];

export default class RentmanCategoryGrid extends Component {
  @service site;
  @service router;

  get show() {
    return SHOW_ON.includes(this.router.currentRouteName);
  }

  get categories() {
    const uncategorized = this.site.uncategorized_category_id;

    return (this.site.categories ?? [])
      .filter((c) => !c.parent_category_id && c.id !== uncategorized)
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0));
  }

  <template>
    {{#if this.show}}
      <section class="rm-cats">
        <div class="rm-cats__head">
          <h2 class="rm-cats__title">Browse categories</h2>
          <a class="rm-cats__all" href="/categories">All categories</a>
        </div>

        <div class="rm-cats__grid">
          {{#each this.categories as |c|}}
            <a class="rm-cat" href="/c/{{c.slug}}/{{c.id}}">
              <span
                class="rm-cat__swatch"
                style="background: #{{c.color}}"
                aria-hidden="true"
              ></span>
              <span class="rm-cat__name">{{c.name}}</span>
              <span class="rm-cat__count">{{c.topic_count}} topics</span>
            </a>
          {{/each}}
        </div>
      </section>
    {{/if}}
  </template>
}
