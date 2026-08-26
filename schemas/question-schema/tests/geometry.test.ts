import { describe, it, expect } from 'vitest';
import { findOverlappingPairs, type Region } from '../src/geometry';

describe('findOverlappingPairs', () => {
  it('returns no pairs for two non-overlapping regions', () => {
    const regions: Region[] = [
      { x: 0.1, y: 0.1, w: 0.2, h: 0.2 },
      { x: 0.6, y: 0.6, w: 0.2, h: 0.2 },
    ];
    expect(findOverlappingPairs(regions)).toEqual([]);
  });

  it('returns the [i, j] pair for two overlapping regions', () => {
    const regions: Region[] = [
      { x: 0.1, y: 0.1, w: 0.3, h: 0.3 },
      { x: 0.3, y: 0.3, w: 0.3, h: 0.3 },
    ];
    expect(findOverlappingPairs(regions)).toEqual([[0, 1]]);
  });

  it('returns no pairs for edge-touching regions (right edge of A == left edge of B)', () => {
    // A: [0.1, 0.3] × [0.1, 0.3]; B: [0.3, 0.5] × [0.1, 0.3]
    // In exact math A.right === B.left; edge-touching is allowed (not overlap).
    // FP note: `0.1 + 0.2` lands at 0.30000000000000004, ~5e-17 past 0.3 — well below EPS.
    const regions: Region[] = [
      { x: 0.1, y: 0.1, w: 0.2, h: 0.2 },
      { x: 0.3, y: 0.1, w: 0.2, h: 0.2 },
    ];
    expect(findOverlappingPairs(regions)).toEqual([]);
  });

  it('lists every overlapping pair across multiple regions (3 labels, 2 overlapping pairs)', () => {
    // Three labels in a chain: A overlaps B, B overlaps C, A and C do NOT overlap.
    //   idx 0: top-left   [0.00, 0.00, 0.30, 0.30]   right=0.30, bottom=0.30
    //   idx 1: middle     [0.20, 0.10, 0.31, 0.31]   overlaps idx 0 and idx 2
    //   idx 2: bot-right  [0.50, 0.30, 0.30, 0.30]   left=0.50, top=0.30
    // A vs C: A.right - C.left = -0.20 (NOT > EPS), so disjoint on X.
    // Expected pairs: (0,1), (1,2) — exactly two.
    const regions: Region[] = [
      { x: 0.0, y: 0.0, w: 0.3, h: 0.3 },
      { x: 0.2, y: 0.1, w: 0.31, h: 0.31 },
      { x: 0.5, y: 0.3, w: 0.3, h: 0.3 },
    ];
    const pairs = findOverlappingPairs(regions);
    expect(pairs).toHaveLength(2);
    expect(pairs).toContainEqual([0, 1]);
    expect(pairs).toContainEqual([1, 2]);
    // Pairs must always have i < j
    for (const [i, j] of pairs) {
      expect(i).toBeLessThan(j);
    }
  });
});
