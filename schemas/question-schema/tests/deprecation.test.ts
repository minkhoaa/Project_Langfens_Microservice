import { describe, it, expect } from 'vitest';
import { DEPRECATION_NOTICES, detectDeprecatedUsage } from '../src/deprecation';

describe('DEPRECATION_NOTICES', () => {
  it('contains exactly 2 entries (MCQ_SINGLE, MCQ_MULTIPLE)', () => {
    expect(DEPRECATION_NOTICES.length).toBe(2);
    const aliases = DEPRECATION_NOTICES.map((n) => n.alias).sort();
    expect(aliases).toEqual(['MCQ_MULTIPLE', 'MCQ_SINGLE']);
  });

  it('every entry has a non-empty replacementGuide and a removeIn semver string', () => {
    for (const n of DEPRECATION_NOTICES) {
      expect(n.replacementGuide.length).toBeGreaterThan(0);
      expect(typeof n.deprecatedSince).toBe('string');
      expect(typeof n.removeIn).toBe('string');
      // Light semver-shape check: MAJOR.MINOR.PATCH
      expect(n.removeIn).toMatch(/^\d+\.\d+\.\d+$/);
      expect(n.deprecatedSince).toMatch(/^\d+\.\d+\.\d+$/);
    }
  });

  it('aliases map to their canonical slugs', () => {
    const byAlias = new Map(DEPRECATION_NOTICES.map((n) => [n.alias, n.canonical]));
    expect(byAlias.get('MCQ_SINGLE')).toBe('MULTIPLE_CHOICE_SINGLE');
    expect(byAlias.get('MCQ_MULTIPLE')).toBe('MULTIPLE_CHOICE_MULTIPLE');
  });
});

describe('detectDeprecatedUsage', () => {
  it('resolves a deprecated alias to its canonical slug with a matching notice', () => {
    const r = detectDeprecatedUsage('MCQ_SINGLE');
    expect(r.canonical).toBe('MULTIPLE_CHOICE_SINGLE');
    expect(r.notices.length).toBe(1);
    expect(r.notices[0]?.alias).toBe('MCQ_SINGLE');
    expect(r.notices[0]?.canonical).toBe('MULTIPLE_CHOICE_SINGLE');
    expect(r.notices[0]?.removeIn).toBe('2.0.0');
  });

  it('returns canonical: null and empty notices for an already-canonical slug', () => {
    const r = detectDeprecatedUsage('MULTIPLE_CHOICE_SINGLE');
    expect(r).toEqual({ canonical: null, notices: [] });
  });

  it('returns canonical: null and empty notices for an unknown input', () => {
    const r = detectDeprecatedUsage('BOGUS_TYPE');
    expect(r).toEqual({ canonical: null, notices: [] });
  });

  it('resolves MCQ_MULTIPLE to MULTIPLE_CHOICE_MULTIPLE with its notice', () => {
    const r = detectDeprecatedUsage('MCQ_MULTIPLE');
    expect(r.canonical).toBe('MULTIPLE_CHOICE_MULTIPLE');
    expect(r.notices.length).toBe(1);
    expect(r.notices[0]?.alias).toBe('MCQ_MULTIPLE');
  });
});