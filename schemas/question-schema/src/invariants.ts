/**
 * Cross-reference validators between payload and correctAnswer fields.
 *
 * Each helper takes the validated data plus a Zod refinement context, and
 * emits `ctx.addIssue({ code: 'custom', path, message })` with paths prefixed
 * by `payload` or `correctAnswer` and messages listing the available ids so
 * an LLM retry loop can self-correct.
 */
import type { z } from 'zod';

type RefinementCtx = z.RefinementCtx;

const GAP_PLACEHOLDER_RE = /\{\{gap:([a-zA-Z0-9_-]{1,32})\}\}/g;

function formatList(ids: readonly string[], max = 8): string {
  if (ids.length === 0) return '[]';
  const head = ids.slice(0, max).map((s) => `'${s}'`).join(', ');
  return ids.length > max ? `[${head}, …]` : `[${head}]`;
}

interface MaybeNodes {
  nodes?: unknown;
  gaps?: unknown;
}

interface MaybeParagraphHeadings {
  paragraphs?: unknown;
  headings?: unknown;
}

interface MaybeLabelsAndGaps {
  labels?: unknown;
  gaps?: unknown;
}

/**
 * FCC envelope: `payload.gaps[].nodeId ⊆ payload.nodes[].id`
 *              AND `correctAnswer.order` is a **permutation** of `payload.nodes[].id`
 *              (combined with the existing `order ⊆ nodes[].id` and the array's
 *              `uniqueItems` refinement, this guarantees every node appears
 *              exactly once in `order`).
 *
 * Used for both FLOW_CHART and FLOW_CHART_COMPLETION envelopes. FLOW_CHART has
 * no `gaps` field, so the gap-check loop is a no-op for that type.
 */
export function refineFccGapsAndOrder(env: { payload?: unknown; correctAnswer?: unknown }, ctx: RefinementCtx): void {
  if (!env || typeof env !== 'object') return;
  const payload = env.payload as MaybeNodes | null;
  const answer = env.correctAnswer as { order?: unknown } | null;
  if (!payload || typeof payload !== 'object') return;
  const nodeIds = Array.isArray(payload.nodes)
    ? (payload.nodes as Array<Record<string, unknown>>).map((n) => String(n.id))
    : [];
  const gaps = Array.isArray(payload.gaps) ? (payload.gaps as Array<Record<string, unknown>>) : [];
  for (let i = 0; i < gaps.length; i++) {
    const nodeId = String(gaps[i]?.nodeId ?? '');
    if (!nodeIds.includes(nodeId)) {
      ctx.addIssue({
        code: 'custom',
        path: ['payload', 'gaps', i, 'nodeId'],
        message: `gaps[${i}].nodeId '${nodeId}' does not exist in nodes. Available node ids: ${formatList(nodeIds)}.`,
      });
    }
  }
  if (answer && typeof answer === 'object' && Array.isArray(answer.order)) {
    const order = (answer.order as unknown[]).map(String);
    const nodeIdSet = new Set(nodeIds);
    const orderSet = new Set(order);
    const missing = nodeIds.filter((id) => !orderSet.has(id));
    const extra = order.filter((id) => !nodeIdSet.has(id));
    if (missing.length > 0) {
      ctx.addIssue({
        code: 'custom',
        path: ['correctAnswer', 'order'],
        message: `correctAnswer.order is missing node id(s): ${missing.map((s) => `'${s}'`).join(', ')}. Every node in payload.nodes[].id must appear exactly once. Available node ids: ${formatList(nodeIds)}.`,
      });
    }
    if (extra.length > 0) {
      ctx.addIssue({
        code: 'custom',
        path: ['correctAnswer', 'order'],
        message: `correctAnswer.order contains unknown node id(s): ${extra.map((s) => `'${s}'`).join(', ')}. Available node ids: ${formatList(nodeIds)}.`,
      });
    }
  }
}

/**
 * MULTIPLE_CHOICE_MULTIPLE envelope: correctOptionIds ⊆ options[].id
 */
export function refineMcmCorrectOptionIds(env: { payload?: unknown; correctAnswer?: unknown }, ctx: RefinementCtx): void {
  if (!env || typeof env !== 'object') return;
  const payload = env.payload as { options?: unknown } | null;
  const answer = env.correctAnswer as { correctOptionIds?: unknown } | null;
  if (!payload || typeof payload !== 'object') return;
  if (!answer || typeof answer !== 'object') return;
  const optionIds = Array.isArray(payload.options)
    ? (payload.options as Array<Record<string, unknown>>).map((o) => String(o.id))
    : [];
  const correct = Array.isArray(answer.correctOptionIds)
    ? (answer.correctOptionIds as unknown[]).map(String)
    : [];
  const missing = correct.filter((id) => !optionIds.includes(id));
  if (missing.length > 0) {
    ctx.addIssue({
      code: 'custom',
      path: ['correctAnswer', 'correctOptionIds'],
      message: `correctOptionIds contains unknown option id(s): ${missing.map((s) => `'${s}'`).join(', ')}. Available options: ${formatList(optionIds)}.`,
    });
  }
}

/**
 * MATCHING_HEADING envelope: pairs.{paragraphId, headingId} ∈ {paragraphs, headings}[].id
 */
export function refineMhPairs(env: { payload?: unknown; correctAnswer?: unknown }, ctx: RefinementCtx): void {
  if (!env || typeof env !== 'object') return;
  const payload = env.payload as MaybeParagraphHeadings | null;
  const answer = env.correctAnswer as { pairs?: unknown } | null;
  if (!payload || typeof payload !== 'object') return;
  if (!answer || typeof answer !== 'object') return;
  const paragraphIds = Array.isArray(payload.paragraphs)
    ? (payload.paragraphs as Array<Record<string, unknown>>).map((p) => String(p.id))
    : [];
  const headingIds = Array.isArray(payload.headings)
    ? (payload.headings as Array<Record<string, unknown>>).map((h) => String(h.id))
    : [];
  const pairs = Array.isArray(answer.pairs)
    ? (answer.pairs as Array<Record<string, unknown>>)
    : [];
  for (let i = 0; i < pairs.length; i++) {
    const pId = String(pairs[i]?.paragraphId ?? '');
    const hId = String(pairs[i]?.headingId ?? '');
    if (!paragraphIds.includes(pId)) {
      ctx.addIssue({
        code: 'custom',
        path: ['correctAnswer', 'pairs', i, 'paragraphId'],
        message: `pairs[${i}].paragraphId '${pId}' not found in paragraphs. Available paragraph ids: ${formatList(paragraphIds)}.`,
      });
    }
    if (!headingIds.includes(hId)) {
      ctx.addIssue({
        code: 'custom',
        path: ['correctAnswer', 'pairs', i, 'headingId'],
        message: `pairs[${i}].headingId '${hId}' not found in headings. Available heading ids: ${formatList(headingIds)}.`,
      });
    }
  }
}

/**
 * MATCHING_INFORMATION envelope: when payload.allowReuse === false,
 * no duplicate pairs[].paragraphId.
 */
export function refineMiNoDuplicateParagraphs(env: { payload?: unknown; correctAnswer?: unknown }, ctx: RefinementCtx): void {
  if (!env || typeof env !== 'object') return;
  const payload = env.payload as { allowReuse?: unknown } | null;
  const answer = env.correctAnswer as { pairs?: unknown } | null;
  if (!payload || typeof payload !== 'object') return;
  if (!answer || typeof answer !== 'object') return;
  if (payload.allowReuse !== false) return;
  const pairs = Array.isArray(answer.pairs)
    ? (answer.pairs as Array<Record<string, unknown>>)
    : [];
  const seen = new Set<string>();
  const duplicates = new Set<string>();
  for (let i = 0; i < pairs.length; i++) {
    const pId = String(pairs[i]?.paragraphId ?? '');
    if (seen.has(pId)) {
      duplicates.add(pId);
    } else {
      seen.add(pId);
    }
  }
  for (const pId of duplicates) {
    ctx.addIssue({
      code: 'custom',
      path: ['correctAnswer', 'pairs'],
      message: `paragraph '${pId}' is paired twice but allowReuse is false. Set allowReuse: true or remove duplicate pairs.`,
    });
  }
}

/**
 * DIAGRAM_LABEL / MAP_LABEL payload-only: payload.gaps[].id ⊆ payload.labels[].id.
 * Used as `.superRefine(refineLabelGapIds)` on the per-type payload schema.
 */
export function refineLabelGapIds(payload: MaybeLabelsAndGaps, ctx: RefinementCtx): void {
  if (!payload || typeof payload !== 'object') return;
  const labelIds = Array.isArray(payload.labels)
    ? (payload.labels as Array<Record<string, unknown>>).map((l) => String(l.id))
    : [];
  const gaps = Array.isArray(payload.gaps)
    ? (payload.gaps as Array<Record<string, unknown>>)
    : [];
  const missing: string[] = [];
  for (let i = 0; i < gaps.length; i++) {
    const gId = String(gaps[i]?.id ?? '');
    if (!labelIds.includes(gId)) missing.push(`gaps[${i}].id '${gId}'`);
  }
  if (missing.length > 0) {
    ctx.addIssue({
      code: 'custom',
      path: ['gaps'],
      message: `${missing.join(', ')} not found in labels. Available label ids: ${formatList(labelIds)}.`,
    });
  }
}

/**
 * COMPLETION payload-only: promptMd `{{gap:ID}}` placeholders must match
 * a gap id in the payload. For SENTENCE_COMPLETION the gap is singular;
 * otherwise `gaps` is an array.
 */
export function refineCompletionPlaceholders(
  payload: { promptMd?: unknown; gaps?: unknown; gap?: unknown },
  ctx: RefinementCtx,
  gapField: 'gaps' | 'gap',
): void {
  if (!payload || typeof payload !== 'object') return;
  const prompt = typeof payload.promptMd === 'string' ? payload.promptMd : '';
  if (!prompt) return;
  let validIds: string[];
  if (gapField === 'gap') {
    validIds =
      payload.gap && typeof payload.gap === 'object'
        ? [String((payload.gap as Record<string, unknown>).id ?? '')]
        : [];
  } else {
    validIds = Array.isArray(payload.gaps)
      ? (payload.gaps as Array<Record<string, unknown>>).map((g) => String(g.id ?? ''))
      : [];
  }
  const placeholderIds = Array.from(prompt.matchAll(GAP_PLACEHOLDER_RE)).map((m) => m[1]);
  const seen = new Set<string>();
  for (const pid of placeholderIds) {
    if (seen.has(pid)) continue;
    seen.add(pid);
    if (!validIds.includes(pid)) {
      ctx.addIssue({
        code: 'custom',
        path: ['promptMd'],
        message: `promptMd placeholder {{gap:${pid}}} has no matching gap definition. Available gap ids: ${formatList(validIds)}.`,
      });
    }
  }
}