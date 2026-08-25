{{!--
  Completes the Support Center lockup in Discourse's own header:

      [ Rentman logo ] | Community

  The logo itself is Discourse's own site logo (a site-wide Branding
  setting, left untouched). This connector only adds the divider and the
  property label after it.

  Kept in the theme rather than Admin → Branding on purpose: the site logo
  and title are site-wide and would change mcp-beta for every visitor, not
  just whoever is previewing.
--}}
<span class="rm-lockup__divider" aria-hidden="true"></span>
<span class="rm-lockup__label">Community</span>
