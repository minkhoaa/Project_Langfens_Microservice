import { describe, it, expect } from 'vitest';
import { z } from 'zod';
import { formatRetryPrompt } from '../src/retry';
import { multipleChoiceMultipleEnvelopeSchema } from '../src/envelopes';

describe('formatRetryPrompt', () => {
  it('formats a known Zod error with path and message', () => {
    const schema = z.object({
      type: z.literal('EXPECTED'),
      payload: z.object({ value: z.number() }),
    });
    const bogus = { type: 'WRONG', payload: { value: 'not-a-number' } };
    const result = schema.safeParse(bogus);
    expect(result.success).toBe(false);
    if (result.success) return;

    const prompt = formatRetryPrompt(result.error, bogus);

    // Header + actionable + closing lines
    expect(prompt).toContain('Your previous output failed schema validation');
    expect(prompt).toContain('Fix the following issues:');
    expect(prompt).toContain('Resubmit the full corrected JSON object');

    // Each issue gets a `- <path>: <message>` line
    const issueLines = prompt.split('\n').filter((l) => l.startsWith('- '));
    expect(issueLines.length).toBeGreaterThan(0);
    for (const line of issueLines) {
      expect(line).toMatch(/^- ([\w.<>\[\]]+|\<root\>): .+/);
    }
    // At least one issue should mention the bad discriminator.
    expect(prompt.toLowerCase()).toContain('expected');
  });

  it('surfaces cross-reference errors from envelopes (lists bad id + available ids)', () => {
    const bogus = {
      payload: {
        type: 'MULTIPLE_CHOICE_MULTIPLE',
        id: '00000000-0000-4000-8000-000000000001',
        skill: 'READING',
        difficulty: 1,
        promptMd: 'Pick one.',
        schemaVersion: '1.0.0',
        options: [
          { id: 'opt_1', idx: 0, contentMd: 'option A' },
          { id: 'opt_2', idx: 1, contentMd: 'option B' },
        ],
        minSelections: 1,
        maxSelections: 1,
      },
      correctAnswer: {
        type: 'MULTIPLE_CHOICE_MULTIPLE',
        correctOptionIds: ['opt_bogus'],
        scoring: 'all-or-nothing',
      },
    };
    const result = multipleChoiceMultipleEnvelopeSchema.safeParse(bogus);
    expect(result.success).toBe(false);
    if (result.success) return;

    const prompt = formatRetryPrompt(result.error, bogus);

    // Cross-ref issue path = ['correctAnswer', 'correctOptionIds']
    expect(prompt).toContain('correctAnswer.correctOptionIds');
    // Message mentions the bad id and lists available ids
    expect(prompt).toContain("'opt_bogus'");
    expect(prompt).toContain("'opt_1'");
    expect(prompt).toContain("'opt_2'");
    expect(prompt).toMatch(/Available options/i);
  });

  it('lists every issue when there are multiple', () => {
    // Build a schema that always emits at least 3 distinct errors.
    const schema = z.object({
      a: z.string().min(5),
      b: z.number().int(),
      c: z.array(z.string()).min(2),
    });
    const bogus = { a: 'no', b: 'not-a-number', c: ['only-one'] };
    const result = schema.safeParse(bogus);
    expect(result.success).toBe(false);
    if (result.success) return;

    const prompt = formatRetryPrompt(result.error, bogus);

    const issueLines = prompt.split('\n').filter((l) => l.startsWith('- '));
    expect(issueLines.length).toBe(3);

    // Each per-property path is mentioned exactly once
    expect(issueLines.some((l) => l.startsWith('- a:'))).toBe(true);
    expect(issueLines.some((l) => l.startsWith('- b:'))).toBe(true);
    expect(issueLines.some((l) => l.startsWith('- c:'))).toBe(true);
  });
});
