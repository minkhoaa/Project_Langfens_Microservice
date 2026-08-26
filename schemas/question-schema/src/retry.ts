import type { ZodError } from 'zod';

/**
 * Convert a ZodError into an LLM-actionable prompt snippet suitable for
 * retry-with-feedback. Lists each issue with path + actionable message.
 *
 * @example
 * const result = QuestionSchema.safeParse(llmOutput);
 * if (!result.success) {
 *   const retryPrompt = formatRetryPrompt(result.error, llmOutput);
 *   // Append to next LLM call as a 'fix this' instruction
 * }
 */
export function formatRetryPrompt(error: ZodError, originalInput: unknown): string {
  const lines: string[] = [
    'Your previous output failed schema validation. Fix the following issues:',
    '',
  ];
  for (const issue of error.issues) {
    const path = issue.path.length > 0 ? issue.path.join('.') : '<root>';
    lines.push(`- ${path}: ${issue.message}`);
  }
  lines.push('');
  lines.push('Resubmit the full corrected JSON object. Do not include any commentary.');
  return lines.join('\n');
}
