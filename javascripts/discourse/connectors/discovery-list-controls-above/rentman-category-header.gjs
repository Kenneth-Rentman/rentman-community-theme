// Page header for a category: icon, name, description, topic count.
//
// Discourse's own .category-heading isn't rendering on this install and I
// couldn't find what suppresses it — this replaces it rather than chasing it,
// and reuses the tile treatment from the homepage cards so a category page
// reads as the same system.
//
// Shares the `discovery-list-controls-above` outlet with the category grid.
// They never both appear: the grid is scoped to the top-level lists, and this
// only renders when the route has a category.

import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import dIcon from "discourse/helpers/d-icon";

function isHex(color) {
  return !!color && /^[0-9a-f]{6}$/i.test(color);
}

export default class RentmanCategoryHeader extends Component {
  get category() {
    return this.args.outletArgs?.category;
  }

  get icon() {
    const c = this.category;
    return c?.style_type === "icon" ? c.icon : null;
  }

  // Only the icon carries the category colour, as on the homepage cards.
  get iconStyle() {
    const color = this.category?.color;
    return isHex(color) ? htmlSafe(`color: #${color};`) : null;
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
        <span
          class="rm-cat-header__tile"
          style={{this.iconStyle}}
          aria-hidden="true"
        >
          {{#if this.icon}}{{dIcon this.icon}}{{/if}}
        </span>

        <div class="rm-cat-header__text">
          {{! Name and count share a line — the count is metadata, not a
              paragraph, and on its own row it read as orphaned. }}
          <div class="rm-cat-header__title-row">
            <h1 class="rm-cat-header__name">{{this.category.name}}</h1>
            <span class="rm-cat-header__count">{{this.countLabel}}</span>
          </div>

          {{#if this.description}}
            <p class="rm-cat-header__desc">{{this.description}}</p>
          {{/if}}
        </div>
      </header>
    {{/if}}
  </template>
}
