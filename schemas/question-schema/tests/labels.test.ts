import { describe, it, expect } from 'vitest';
import { DEPRECATED_TYPE_ALIASES, QUESTION_TYPES } from '../src/discriminator';
import { QUESTION_TYPE_LABELS } from '../src/labels';
import { QUESTION_TYPE_METADATA } from '../src/metadata';

describe('QUESTION_TYPE_LABELS ↔ QUESTION_TYPES', () => {
  it('every label key is either canonical or a deprecated alias', () => {
    const allowed: string[] = [...QUESTION_TYPES, ...DEPRECATED_TYPE_ALIASES];
    for (const key of Object.keys(QUESTION_TYPE_LABELS)) {
      expect(allowed).toContain(key);
    }
  });

  it('every canonical slug has a label', () => {
    for (const slug of QUESTION_TYPES) {
      expect(QUESTION_TYPE_LABELS[slug]).toBeTruthy();
    }
  });

  it('every deprecated alias has a label', () => {
    for (const alias of DEPRECATED_TYPE_ALIASES) {
      expect(QUESTION_TYPE_LABELS[alias]).toBeTruthy();
    }
  });

  it('the label table has 23 entries (21 canonical + 2 deprecated)', () => {
    expect(Object.keys(QUESTION_TYPE_LABELS).length).toBe(23);
  });
});

describe('QUESTION_TYPE_METADATA ↔ QUESTION_TYPES', () => {
  it('metadata keys are exactly the canonical slugs', () => {
    const keys = Object.keys(QUESTION_TYPE_METADATA);
    expect(keys.length).toBe(QUESTION_TYPES.length);
    for (const slug of QUESTION_TYPES) {
      expect(keys).toContain(slug);
    }
  });

  it('every canonical slug has well-formed metadata', () => {
    for (const slug of QUESTION_TYPES) {
      const m = QUESTION_TYPE_METADATA[slug];
      expect(m.slug).toBe(slug);
      expect(m.label).toBeTruthy();
      expect(typeof m.autoGradable).toBe('boolean');
      expect(Array.isArray(m.skill)).toBe(true);
      expect(m.skill.length).toBeGreaterThan(0);
      expect(typeof m.group).toBe('string');
    }
  });

  it('autoGradable is false only for AUDIO_RESPONSE', () => {
    for (const slug of QUESTION_TYPES) {
      const m = QUESTION_TYPE_METADATA[slug];
      if (slug === 'AUDIO_RESPONSE') {
        expect(m.autoGradable).toBe(false);
      } else {
        expect(m.autoGradable).toBe(true);
      }
    }
  });
});

describe('registry ↔ JSON source-of-truth', () => {
  it('registry labels count matches canonical slug count', () => {
    expect(QUESTION_TYPES.length).toBe(21);
  });

  it('metadata has exactly 21 entries', () => {
    expect(Object.keys(QUESTION_TYPE_METADATA).length).toBe(21);
  });
});
