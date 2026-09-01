// Show the excerpt on every topic row, not just pinned ones.
//
// Discourse computes `expandPinned` as false for anything unpinned, then runs
// it through a value transformer before use:
//
//   {{#if this.expandPinned}}<TopicExcerpt @topic={{@topic}} />{{/if}}
//
// There's no second pinned check at the call site, so returning true here
// renders the excerpt for any topic that has one. Same line Air uses; we
// already inherited `serialize_topic_excerpts` from Air's manifest, so the
// server has been sending this text all along with nothing displaying it.

import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.registerValueTransformer("topic-list-item-expand-pinned", () => true);
});
