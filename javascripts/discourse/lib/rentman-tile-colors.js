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

// WCAG 1.4.11, the threshold for non-text graphical objects. These glyphs are
// icons, not text, so 3:1 applies rather than 4.5:1.
const GRAPHICS_THRESHOLD = 3;

// White where white works, ink only where it doesn't.
//
// This deliberately does NOT maximise contrast. Maximising picks ink on brand
// orange, because ink reaches 5.28:1 there against white's 3.06:1 — but the
// brand book calls dark grey on orange a misuse (p.15) and draws product icons
// white on an orange square (p.26). White is the intent; contrast is the
// constraint. So take white whenever it clears the threshold and fall back to
// ink only for the genuinely pale grounds, where white fails outright — Crew
// yellow at 1.69, beige at 1.21.
//
// A fallback is always safe: white and ink are equal at 4.09:1, so whichever
// of the two is better is never below that. There is no colour where both
// fail, which is why this needs no third option.
// Tried 2026-09-11 and rejected: an `accentGlyphColor` behind a
// `tile_glyph_accent` setting drew the glyphs in brand orange on the black
// tiles (5.28:1, perfectly legible). It read as eight "active" states rather
// than as brand presence, because orange means interactive everywhere else in
// this theme. Recoverable from c7a6408 if anyone wants to look again.
//
export function glyphColor(hex) {
  const onWhite = contrast(luminance(hex), 1);
  // #fff has a relative luminance of exactly 1.
  return onWhite >= GRAPHICS_THRESHOLD ? "#fff" : `#${INK}`;
}
