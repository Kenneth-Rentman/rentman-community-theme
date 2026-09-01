// Page header for a category: name, topic count, description.
//
// No icon. The reader has just clicked a card carrying that same icon, so
// repeating it here is decoration rather than information.
//
// Discourse's own .category-heading isn't rendering on this install and I
// couldn't find what suppresses it — this replaces it rather than chasing it.
//
// Shares the `discovery-list-controls-above` outlet with the category grid.
// They never both appear: the grid is scoped to the top-level lists, and this
// only renders when the route has a category.

import Component from "@glimmer/component";

export default class RentmanCategoryHeader extends Component {
  get category() {
    return this.args.outletArgs?.category;
  }

  // description_text is the plain-text field; `description` may carry HTML.
  get description() {
    return this.category?.description_text;
  }

  get countLabel() {
    const n = this.category?.topic_count ?? 0;
    return `${n} ${n === 1 ? "topic" : "topics"}`;
  }

  <template>
    {{#if this.category}}
      <header class="rm-cat-header">
        <div class="rm-cat-header__title-row">
          <h1 class="rm-cat-header__name">{{this.category.name}}</h1>
          <span class="rm-cat-header__count">{{this.countLabel}}</span>
        </div>

        {{#if this.description}}
          <p class="rm-cat-header__desc">{{this.description}}</p>
        {{/if}}
      </header>
    {{/if}}
  </template>
}
