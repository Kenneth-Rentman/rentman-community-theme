// Completes the Support Center lockup in Discourse's own header:
//
//     [ Rentman logo ] | Community
//
// The logo is Discourse's own site logo (a site-wide Branding setting, left
// untouched). This connector only adds the divider and the property label.
//
// Kept in the theme rather than Admin → Branding on purpose: the site logo
// and title are site-wide and would change mcp-beta for every visitor, not
// just whoever is previewing.
//
// NOTE: .gjs is a JavaScript module, so a top-level <template> tag is the
// default-exported template-only component. Comments outside it must be JS
// comments — a stray {{!-- --}} out here is a syntax error that takes down
// the whole theme bundle.

<template>
  <span class="rm-lockup__divider" aria-hidden="true"></span>
  <span class="rm-lockup__label">Community</span>
</template>
