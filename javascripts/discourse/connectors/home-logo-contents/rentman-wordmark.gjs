{{!--
  Renders the "Rentman Community" wordmark in Discourse's own header, in
  place of the site logo image.

  Done in the theme rather than via Admin → Branding on purpose: the site
  logo and title are SITE-WIDE settings that would change mcp-beta for every
  visitor immediately. This stays scoped to the theme, so it only appears for
  whoever is previewing it.

  The logo image itself is hidden in common.scss.
--}}
<span class="rm-wordmark">Rentman Community</span>
