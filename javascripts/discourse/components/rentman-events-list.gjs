// Upcoming events. Rendered in two places by two thin connectors:
//
//   above-right-sidebar-blocks  -> desktop, top of the right rail
//   before-list-area            -> mobile, above the topic list
//
// Two mounts rather than one because the rail cannot carry this on a phone:
// discourse-right-sidebar-blocks returns early when `site.mobileView` is true,
// so on a real phone the rail is not in the DOM at all and its outlets never
// render. That is a JS decision, not CSS, so no stylesheet can bring it back.
//
// Only one mount is ever live at a time — the rail does not exist on mobile,
// and the mobile connector renders nothing off it — so this never fetches
// twice.
//
// WHY THE RAIL IS HIDDEN ON MOBILE AT ALL. It stacks above the topic list when
// the layout collapses, and a phone user would scroll past the whole
// leaderboard before reaching a single topic. That reasoning holds for a
// ten-row podium and not for three dated lines, which is why events come back
// and the leaderboard stays hidden.
//
// WHERE THE DATA COMES FROM. discourse-events, via
// GET /discourse-post-event/events.json. That path keeps the old
// `discourse-post-event` spelling deliberately — the plugin's routes file
// calls it "a public API surface, unlike the Ruby namespaces" — so it is safe
// to depend on even though the Ruby module is now DiscourseEvents.
//
// Events are scoped to what the current user can see, so a member who cannot
// read a restricted category will not see its events. That is why this renders
// nothing rather than an empty shell.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";

const ENDPOINT = "/discourse-post-event/events.json";

function formatter() {
  return new Intl.DateTimeFormat(undefined, {
    weekday: "short",
    day: "numeric",
    month: "short",
  });
}

// An all-day event serialises starts_at as "2026-10-02" — no time, no zone.
// `new Date("2026-10-02")` parses that as UTC midnight, which renders as the
// PREVIOUS day anywhere west of Greenwich. Build those from the parts so an
// all-day event shows the date it was actually set to.
function parseStart(value, allDay) {
  if (!value) {
    return null;
  }

  if (allDay) {
    const [y, m, d] = String(value).split("-").map(Number);
    return y && m && d ? new Date(y, m - 1, d) : null;
  }

  const parsed = new Date(value);
  return isNaN(parsed.getTime()) ? null : parsed;
}

function toItem(event, format) {
  const url = event?.post?.url;
  // `name` is optional — an event created on a topic without its own title
  // falls back to the topic's.
  const title = event?.name?.trim() || event?.post?.topic?.title?.trim();
  const start = parseStart(event?.starts_at, event?.all_day);

  if (!url || !title || !start) {
    return null;
  }

  return {
    id: event.id,
    url,
    title,
    when: format.format(start),
    // Machine-readable for assistive tech and for anyone inspecting the DOM;
    // the visible label is deliberately terse for a narrow rail.
    datetime: start.toISOString(),
  };
}

export default class RentmanEventsList extends Component {
  // null until loaded, and again on failure. Distinguishing "not yet" from
  // "none" is not worth a loading state in a rail block — it would flash.
  @tracked events = null;

  constructor() {
    super(...arguments);
    this.load();
  }

  async load() {
    try {
      const data = await ajax(ENDPOINT, {
        data: {
          // Upcoming only. `after` takes an ISO timestamp.
          after: new Date().toISOString(),
          order: "asc",
          limit: settings.events_block_limit,
          // An event happening right now is still worth showing.
          include_ongoing: true,
        },
      });

      const format = formatter();
      this.events = (data?.events ?? [])
        .map((event) => toItem(event, format))
        .filter(Boolean);
    } catch {
      // Same policy as the footer's status fetch: show nothing rather than a
      // stale or misleading block.
      this.events = null;
    }
  }

  get show() {
    return this.events?.length > 0;
  }

  <template>
    {{#if this.show}}
      <section class="rm-events">
        {{! Matches the "Leaderboard." motif below it — the orange full stop
            comes from CSS, since this is a plain heading. }}
        <h3 class="rm-events__title">Events</h3>

        <ul class="rm-events__list">
          {{#each this.events key="id" as |event|}}
            <li class="rm-events__item">
              <a class="rm-events__link" href={{event.url}}>
                <time class="rm-events__when" datetime={{event.datetime}}>
                  {{event.when}}
                </time>
                <span class="rm-events__name">{{event.title}}</span>
              </a>
            </li>
          {{/each}}
        </ul>
      </section>
    {{/if}}
  </template>
}
