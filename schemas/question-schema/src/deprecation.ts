/**
 * Deprecation timeline + warning helper for legacy question-type aliases.
 *
 * `MCQ_SINGLE` and `MCQ_MULTIPLE` are kept as deprecated aliases so existing
 * seed data and admin imports still validate. Consumers SHOULD detect usage at
 * every boundary (admin endpoint, seed parser, FE loader) via
 * `detectDeprecatedUsage` and surface the `replacementGuide` to the caller.
 *
 * Removal of these aliases is scheduled for `2.0.0`; until then, both aliases
 * resolve via `resolveDeprecatedAlias` and the per-type payload/answer schemas
 * continue to be re-exported from `./deprecated-aliases`.
 */
import type { DeprecatedTypeAlias, QuestionTypeSlug } from './discriminator';
import { resolveDeprecatedAlias } from './discriminator';

/** Structured notice describing a deprecated alias and its removal target. */
export interface DeprecationNotice {
  alias: DeprecatedTypeAlias;
  canonical: QuestionTypeSlug;
  deprecatedSince: string;
  removeIn: string;
  replacementGuide: string;
}

/**
 * Authoritative list of deprecation timelines. Source of truth for the
 * removal version. Add a new entry when introducing a fresh alias; bump the
 * `removeIn` field when re-confirming a target.
 */
export const DEPRECATION_NOTICES: readonly DeprecationNotice[] = [
  {
    alias: 'MCQ_SINGLE',
    canonical: 'MULTIPLE_CHOICE_SINGLE',
    deprecatedSince: '1.0.0',
    removeIn: '2.0.0',
    replacementGuide:
      'Use MULTIPLE_CHOICE_SINGLE. The MCQ_SINGLE slug is a legacy alias preserved for backward compatibility with seed data and admin imports. New generations should use the canonical slug.',
  },
  {
    alias: 'MCQ_MULTIPLE',
    canonical: 'MULTIPLE_CHOICE_MULTIPLE',
    deprecatedSince: '1.0.0',
    removeIn: '2.0.0',
    replacementGuide:
      'Use MULTIPLE_CHOICE_MULTIPLE. The MCQ_MULTIPLE slug is a legacy alias preserved for backward compatibility with seed data and admin imports. New generations should use the canonical slug.',
  },
];

/**
 * Detect deprecated type aliases in input and return the canonical slug plus
 * any matching deprecation notices. Use this at every consumer boundary
 * (admin endpoint, seed parser, FE loader) so the call site can surface the
 * `replacementGuide` to the caller.
 *
 * Returns `{ canonical: null, notices: [] }` for unknown or already-canonical
 * input — callers MUST treat `null` as "no action required".
 */
export function detectDeprecatedUsage(input: string): {
  canonical: QuestionTypeSlug | null;
  notices: readonly DeprecationNotice[];
} {
  const canonical = resolveDeprecatedAlias(input);
  if (canonical === null) return { canonical: null, notices: [] };
  const notice = DEPRECATION_NOTICES.find((n) => n.alias === input);
  return { canonical, notices: notice ? [notice] : [] };
}