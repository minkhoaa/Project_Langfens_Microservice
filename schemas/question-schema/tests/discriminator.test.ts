import { describe, it, expect } from 'vitest';
import {
  AnswerSchema,
  PayloadSchemaBySlug,
  QuestionPayloadSchema,
  AnswerSchemaBySlug,
  resolveDeprecatedAlias,
  isCanonicalType,
  isDeprecatedAlias,
} from '../src';
import { QUESTION_TYPES } from '../src/discriminator';
import { samples } from './samples';

describe('per-type payload schemas', () => {
  it.each(QUESTION_TYPES)('parses the %s sample', (slug) => {
    const sample = samples[slug];
    const result = PayloadSchemaBySlug[slug].safeParse(sample.payload);
    expect(result.success).toBe(true);
  });
});

describe('per-type answer schemas', () => {
  it.each(QUESTION_TYPES)('parses the %s answer sample', (slug) => {
    const sample = samples[slug];
    const result = AnswerSchemaBySlug[slug].safeParse(sample.correctAnswer);
    expect(result.success).toBe(true);
  });
});

describe('discriminated QuestionPayloadSchema union', () => {
  it.each(QUESTION_TYPES)('parses the %s payload via the discriminated union', (slug) => {
    const sample = samples[slug];
    const result = QuestionPayloadSchema.safeParse(sample.payload);
    expect(result.success).toBe(true);
  });

  it('rejects an unknown type discriminator', () => {
    const bogus = {
      ...samples.MULTIPLE_CHOICE_SINGLE.payload,
      type: 'BOGUS_TYPE',
    };
    const result = QuestionPayloadSchema.safeParse(bogus);
    expect(result.success).toBe(false);
  });
});

describe('discriminated AnswerSchema union', () => {
  it.each(QUESTION_TYPES)('parses the %s answer via the discriminated union', (slug) => {
    const sample = samples[slug];
    const result = AnswerSchema.safeParse(sample.correctAnswer);
    expect(result.success).toBe(true);
  });

  it('rejects an unknown answer type discriminator', () => {
    const bogus = { type: 'BOGUS_ANSWER', correctOptionId: 'opt_1' };
    const result = AnswerSchema.safeParse(bogus);
    expect(result.success).toBe(false);
  });
});

describe('deprecated alias resolvers', () => {
  it('resolves MCQ_SINGLE', () => {
    expect(resolveDeprecatedAlias('MCQ_SINGLE')).toBe('MULTIPLE_CHOICE_SINGLE');
  });

  it('resolves MCQ_MULTIPLE', () => {
    expect(resolveDeprecatedAlias('MCQ_MULTIPLE')).toBe('MULTIPLE_CHOICE_MULTIPLE');
  });

  it('returns null for unknown or already-canonical aliases', () => {
    expect(resolveDeprecatedAlias('MULTIPLE_CHOICE_SINGLE')).toBeNull();
    expect(resolveDeprecatedAlias('BOGUS')).toBeNull();
  });

  it('canonical guards work', () => {
    expect(isCanonicalType('MULTIPLE_CHOICE_SINGLE')).toBe(true);
    expect(isCanonicalType('MCQ_SINGLE')).toBe(false);
    expect(isDeprecatedAlias('MCQ_SINGLE')).toBe(true);
    expect(isDeprecatedAlias('MULTIPLE_CHOICE_SINGLE')).toBe(false);
  });
});
