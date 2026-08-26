/**
 * Geometry helpers for region-based layouts (DIAGRAM_LABEL, MAP_LABEL).
 *
 * All coordinates are 0-1 normalized. A region's {x, y, w, h} is the
 * top-left corner + width/height; the region occupies the half-open
 * rectangle [x, x+w] × [y, y+h].
 */

/** A normalized axis-aligned bounding box in the unit square [0, 1] × [0, 1]. */
export interface Region {
  /** Top-left X in normalized coordinates. */
  x: number;
  /** Top-left Y in normalized coordinates. */
  y: number;
  /** Width in normalized coordinates. */
  w: number;
  /** Height in normalized coordinates. */
  h: number;
}

/**
 * Two regions overlap iff their projections on both axes overlap
 * with positive measure. Edge-touching (e.g. one region's right edge
 * equals another's left edge) is NOT overlap.
 *
 * Floating-point arithmetic can make exact edge-equality slightly fuzzy
 * (e.g. `0.1 + 0.2 === 0.30000000000000004`), so we use a small epsilon
 * when comparing boundary coordinates. The epsilon is well below the
 * sub-pixel scale for any realistic 0–1 coordinate space.
 */
export function regionsOverlap(a: Region, b: Region): boolean {
  const EPS = 1e-9;
  // Overlap iff each axis has a gap strictly greater than EPS on both sides.
  // Equivalently: |a.right - b.left| > EPS AND |b.right - a.left| > EPS (and same for Y).
  // Comparing differences against EPS absorbs IEEE-754 rounding on edges
  // (e.g. `0.1 + 0.2` lands at 0.30000000000000004, ~5e-17 past 0.3, well below EPS).
  return (
    a.x + a.w - b.x > EPS &&
    b.x + b.w - a.x > EPS &&
    a.y + a.h - b.y > EPS &&
    b.y + b.h - a.y > EPS
  );
}

/**
 * Find all pairs of regions that overlap. Pure function, no side effects.
 * Returns Array<[i, j]> where i < j, both indices into the input array.
 * Edge-touching regions are not considered overlapping.
 */
export function findOverlappingPairs(regions: Region[]): Array<[number, number]> {
  const overlaps: Array<[number, number]> = [];
  for (let i = 0; i < regions.length; i++) {
    for (let j = i + 1; j < regions.length; j++) {
      if (regionsOverlap(regions[i], regions[j])) {
        overlaps.push([i, j]);
      }
    }
  }
  return overlaps;
}
