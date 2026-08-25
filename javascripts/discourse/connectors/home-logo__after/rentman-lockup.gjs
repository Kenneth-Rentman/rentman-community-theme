// Completes the Support Center lockup in Discourse's own header:
//
//     [ Rentman logo ] | Community
//
// Attached to `home-logo__after`, NOT `home-logo-contents`. The latter is a
// replacement outlet: registering a connector there overrides Discourse's
// default logo rendering, so the logo disappeared entirely. `__after` appends
// alongside it and leaves Discourse's own logo logic (dark mode, mobile, the
// small scrolled variant) intact.
//
// The logo is a site-wide Branding setting and stays untouched — this label
// is theme-scoped so it only shows for whoever is previewing.
//
// .gjs is a JavaScript module: the top-level <template> is the default
// export, and comments out here must be JS comments.

<template>
  <span class="rm-lockup__divider" aria-hidden="true"></span>
  <span class="rm-lockup__label">Community</span>
</template>
