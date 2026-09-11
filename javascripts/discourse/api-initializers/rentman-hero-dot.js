// The orange full stop on the hero headline.
//
// This is the brand's signature move — book p.18, "ending them with an orange
// period whenever possible to add a bold signature touch" — and the theme
// already runs the motif on section headings ("Leaderboard.").
//
// WHY THIS NEEDS JAVASCRIPT. Discourse renders the banner as:
//
//   <div class="welcome-banner__title">
//     Welcome to the Rentman Community          <- bare text node
//     <p class="welcome-banner__subheader">…</p> <- block sibling
//   </div>
//
// so `::after` on the title lands below the subtitle, and the headline itself
// is an anonymous block CSS cannot attach to. An earlier session hit this and
// left a note in common.scss saying the motif could not run here; this is that
// note being answered rather than contradicted.
//
// WHY IT INSERTS A SPAN RATHER THAN REWRITING THE TEXT NODE. The headline goes
// through `trustHTML`, so a text customization could legitimately put markup in
// it. Splitting the first text node would then drop the period in the middle of
// the heading. Inserting an inline span immediately before the block subheader
// puts it after whatever the headline turns out to be, and because it is inline
// it follows the last word when the heading wraps rather than sitting at the
// edge of the box.

import { schedule } from "@ember/runloop";
import { apiInitializer } from "discourse/lib/api";

const DOT_CLASS = "rm-hero-dot";
const TITLE = ".welcome-banner__title";
const SUBHEADER = ".welcome-banner__subheader";

function addDot() {
  const title = document.querySelector(TITLE);

  // Idempotent: the banner survives some route changes, so this runs again
  // against a title that already has its period.
  if (!title || title.querySelector(`.${DOT_CLASS}`)) {
    return;
  }

  // Nothing to punctuate.
  if (!title.textContent.trim()) {
    return;
  }

  const dot = document.createElement("span");
  dot.className = DOT_CLASS;
  dot.textContent = ".";
  // Decoration, not content — it should not reach a screen reader as a stray
  // full stop detached from the sentence it belongs to.
  dot.setAttribute("aria-hidden", "true");

  const subheader = title.querySelector(SUBHEADER);
  if (subheader) {
    title.insertBefore(dot, subheader);
  } else {
    title.appendChild(dot);
  }
}

export default apiInitializer((api) => {
  api.onPageChange(() => {
    // The banner renders as part of the route's own render pass, so wait for
    // it rather than racing it.
    schedule("afterRender", addDot);
  });
});
