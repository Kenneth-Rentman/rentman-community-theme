// Call-to-action buttons in the hero, below the headline.
//
// Uses Discourse's own `welcome-banner-below-headline` outlet — the banner
// markup itself stays Discourse's, so the headline and subheader keep coming
// from site settings and we only add the buttons.
//
// Labels and URLs are theme settings so they can change without a commit.

const PRIMARY_LABEL = settings.hero_primary_cta_label;
const PRIMARY_URL = settings.hero_primary_cta_url;
const SECONDARY_LABEL = settings.hero_secondary_cta_label;
const SECONDARY_URL = settings.hero_secondary_cta_url;

<template>
  {{#if PRIMARY_LABEL}}
    <div class="rm-hero-cta">
      <a class="rm-hero-cta__primary" href={{PRIMARY_URL}}>
        {{PRIMARY_LABEL}}
      </a>

      {{#if SECONDARY_LABEL}}
        <a class="rm-hero-cta__secondary" href={{SECONDARY_URL}}>
          {{SECONDARY_LABEL}}
        </a>
      {{/if}}
    </div>
  {{/if}}
</template>
