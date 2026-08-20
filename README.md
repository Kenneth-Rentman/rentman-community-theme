# Rentman Community — Discourse theme

Discourse theme for the Rentman Community, currently piloted at
[mcp-beta.rentman.io](https://mcp-beta.rentman.io).

Sibling to [`support-center-theme`](https://github.com/rentmanpublic/support-center-theme)
(Zendesk Guide), which remains the reference for the shared top strip, logo
lockup and language switcher.

## Status

**v0.1 — token layer only.** Colour, typography and radii. No layout changes
yet; those follow once the direction is agreed.

Living at [`Kenneth-Rentman/rentman-community-theme`](https://github.com/Kenneth-Rentman/rentman-community-theme)
during the exploration phase. To be transferred to the `rentmanpublic` org
before it goes anywhere real — Discourse then needs its repo URL updated to
match.

No licence yet. `support-center-theme` uses Apache 2.0 if we want to match.

## Installing on a site

Admin → Customize → Themes → **Install** → *From a git repository*, using this
repo's clone URL. Discourse pulls `main`.

To preview without affecting anyone, install it but leave it unselected as
default, then append `?preview_theme_id=<id>` to any URL.

To pick up new commits: Admin → Customize → Themes → *Rentman Community* →
**Check for updates**.

## Palette

Taken from the swatch variables on rentman.io.

| Token | Hex | Role |
| --- | --- | --- |
| orange | `#ff5e1d` | brand, links, primary actions |
| orange-soft | `#ffbfa5` | |
| orange-muted | `#ffdfd2` | selected rows |
| ink | `#202121` | body text |
| black | `#080808` | dark header |
| beige | `#eee9e1` | |
| beige-soft | `#f3efea` | |
| beige-muted | `#f8f6f3` | hover |
| beige-dark | `#d9d4cd` | |
| green | `#2aba67` | success |
| yellow | `#fcbd01` | highlight |
| red | `#d40000` | danger |
| purple | `#635bf9` | unused so far |

Note: this is the **marketing site** palette (warm, orange and beige). The
Rentman product app uses a different, blue-led palette. Which one the community
should follow is an open decision.

## Fonts

- **Manrope** — body. Free, loaded from Google Fonts.
- **Gilroy** — headings on rentman.io. Commercial licence; not loaded. Headings
  currently fall back to Manrope.

## Layout

```
about.json                 theme metadata + Rentman colour schemes
settings.yml               admin-editable settings
locales/en.yml             setting labels and descriptions
common/common.scss         token layer
javascripts/discourse/     api-initializers (empty for now)
```
