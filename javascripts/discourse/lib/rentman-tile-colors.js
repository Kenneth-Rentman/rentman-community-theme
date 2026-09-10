// Tile colour maths, shared by the homepage grid and the sidebar mini-tiles.
//
// The category colour fills a tile and a glyph sits on it, so something has to
// decide whether that glyph is white or ink. Only those two values are ever in
// play, so it is derivable rather than configurable: compute WCAG relative
// luminance and take whichever contrasts better. Deriving it means a colour
// picked in admin can never be paired with an unreadable glyph.
//
// Lives here rather than in either consumer because two copies of this would
// eventually disagree, and a disagreement means the same category renders a
// different glyph colour on the homepage than in the sidebar.

export const INK = "202121";

export function isHex(color) {
  return !!color && /^[0-9a-f]{6}$/i.test(color);
}

function channel(v) {
  const c = v / 255;
  return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

// WCAG 2.1 relative luminance. Takes a bare six-digit hex, no leading #,
// which is the form Discourse stores category colours in.
export function luminance(hex) {
  const n = parseInt(hex, 16);
  return (
    0.2126 * channel((n >> 16) & 255) +
    0.7152 * channel((n >> 8) & 255) +
    0.0722 * channel(n & 255)
  );
}

export function contrast(a, b) {
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

const INK_LUMINANCE = luminance(INK);

// White or ink, whichever reads better on a tile of this colour.
export function glyphColor(hex) {
  const tile = luminance(hex);
  // #fff has a relative luminance of exactly 1.
  return contrast(tile, 1) >= contrast(tile, INK_LUMINANCE) ? "#fff" : `#${INK}`;
}
