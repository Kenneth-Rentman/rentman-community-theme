// Mobile mount: above the topic list.
//
// `before-list-area` is declared in core's discovery/layout.gjs with no mobile
// gate, so unlike the rail it renders on a phone. Guarded on `site.mobileView`
// so this does not double up with the rail mount on desktop — including at
// narrow desktop widths, where the rail is still in the DOM.
//
// mobileView is user-agent based, so a narrow desktop window does NOT get this
// branch. That case is handled in CSS instead: the rail stays, and only the
// leaderboard inside it is hidden.

import Component from "@glimmer/component";
import { service } from "@ember/service";
import RentmanEventsList from "../../components/rentman-events-list";

export default class RentmanEventsMobile extends Component {
  @service site;

  <template>
    {{#if this.site.mobileView}}
      <div class="rm-events-mobile">
        <RentmanEventsList />
      </div>
    {{/if}}
  </template>
}
