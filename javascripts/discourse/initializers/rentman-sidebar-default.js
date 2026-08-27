// Default the navigation sidebar to collapsed, once per browser.
//
// There is no site setting for this. Discourse's `navigation_menu` setting
// only chooses sidebar vs. header dropdown; the collapsed state is a
// per-browser value in keyValueStore under `sidebar-hidden`, written only
// when a user clicks the toggle:
//
//   calculateShowSidebar() {
//     return this.canDisplaySidebar
//       && !this.keyValueStore.getItem("sidebar-hidden")
//       && !this.site.narrowDesktopView;
//   }
//
// So we seed that value once, on a visitor's first load. After that our
// marker is set and we never touch it again — whatever the person chooses
// with the toggle is theirs to keep. Without the marker we'd re-collapse
// the sidebar on every page load and they could never keep it open.
//
// Runs as a classic initializer so it executes before the application
// template reads `showSidebar`, which is what makes it apply on the first
// render rather than the second.

const SIDEBAR_HIDDEN = "sidebar-hidden";
const DEFAULT_APPLIED = "rentman-sidebar-default-applied";

export default {
  name: "rentman-sidebar-default",

  initialize(owner) {
    try {
      const store = owner.lookup("service:key-value-store");
      if (!store || store.getItem(DEFAULT_APPLIED)) {
        return;
      }

      store.setItem(DEFAULT_APPLIED, "true");

      // Don't clobber a preference someone already expressed.
      if (!store.getItem(SIDEBAR_HIDDEN)) {
        store.setItem(SIDEBAR_HIDDEN, "true");
      }
    } catch (e) {
      // Private browsing and blocked storage both throw here. Failing to
      // set a cosmetic default must never take the site down.
    }
  },
};
