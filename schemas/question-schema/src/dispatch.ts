/**
 * Frontend UI-shape dispatch contract.
 *
 * Each canonical {@link QuestionTypeSlug} maps to a small, intentionally
 * coarse UI shape. The renderer layer — `QuestionPanel` + the
 * `QuestionComponentRegistry` — uses this map to:
 *
 *   1. Pick which prop API to invoke the renderer with
 *      (`selected`/`onSelect` vs `value`/`onChange` vs `values`/`onBlankChange`).
 *   2. Decide whether the prompt-derived `isWordListBlank` heuristic applies.
 *
 * Single source of truth: previously every shape had to be re-declared inside
 * the FE panel and the API mapper (`COMPLETION_SLUGS`, `CHOICE_SLUGS`,
 * `radioSlugs`). Those duplicates are gone — the SSOT owns the canonical
 * dispatch table; the FE only consumes it.
 *
 * Shown names are picked so callers can branch on them in plain JavaScript
 * (`if (shape === "radio") { ... }`) without leaking internal model details.
 *
 * ### Shapes
 *
 * - `"radio"`: single-select list. Renderer consumes `selected` + `onSelect`.
 * - `"checkbox"`: multi-select list. Renderer consumes `value` (CSV) + `onChange`.
 * - `"orderMatch"`: permutation / ordering. Renderer consumes `value` (JSON-ordered)
 *   + `onChange`.
 * - `"pairMatch"`: two-column matching (headings↔paragraphs, features↔endings, etc.).
 *   Renderer decides its own prop mix; the panel just hands it through.
 * - `"blankSingle"`: a single text input replacing the prompt body. Consumes
 *   `value` + `onChange`.
 * - `"blankArray"`: N text inputs aligned to N blanks in the prompt. Consumes
 *   `values` (string[]) + `onBlankChange(idx, value)`. The `___` runs and
 *   structured gaps live on the renderer side; the panel just buffers the array.
 * - `"inline"`: fallthrough — QuestionPanel renders a custom inline view
 *   (MATCHING_INFORMATION paragraph-match A-F single-letter input is the
 *   only current occupant). The renderer entry is therefore `undefined` and
 *   the panel dispatches on prompt-derived heuristics.
 */
export type DispatchShape =
  | "radio"
  | "checkbox"
  | "orderMatch"
  | "pairMatch"
  | "blankSingle"
  | "blankArray"
  | "inline";

import type { QuestionTypeSlug } from "./discriminator";

/**
 * Authoritative mapping. 21 canonical slugs → 1 of 7 shape names.
 *
 * Keep alphabetical inside groups for diff hygiene. Adding a new slug means
 * adding exactly one entry here AND a registry entry — nothing else.
 */
export const DispatchByType: Record<QuestionTypeSlug, DispatchShape> = {
  // Radio (single-select from BE-supplied options).
  MULTIPLE_CHOICE_SINGLE: "radio",
  MULTIPLE_CHOICE_SINGLE_IMAGE: "radio",
  TRUE_FALSE_NOT_GIVEN: "radio",
  YES_NO_NOT_GIVEN: "radio",
  CLASSIFICATION: "radio",

  // Checkbox (multi-select).
  MULTIPLE_CHOICE_MULTIPLE: "checkbox",

  // Permutation / ordering.
  FLOW_CHART: "orderMatch",

  // Pair-match (renderer-specific prop mix).
  MATCHING_HEADING: "pairMatch",
  MATCHING_INFORMATION: "pairMatch",
  MATCHING_FEATURES: "pairMatch",
  MATCHING_ENDINGS: "pairMatch",

  // Single text input.
  SENTENCE_COMPLETION: "blankSingle",
  DIAGRAM_LABEL: "blankSingle",
  MAP_LABEL: "blankSingle",

  // N text inputs aligned to blanks.
  SUMMARY_COMPLETION: "blankArray",
  TABLE_COMPLETION: "blankArray",
  NOTE_COMPLETION: "blankArray",
  FORM_COMPLETION: "blankArray",
  SHORT_ANSWER: "blankArray",
  AUDIO_RESPONSE: "blankArray",
  FLOW_CHART_COMPLETION: "blankArray",
};

/** Type guard. */
export function isDispatchShape(s: string): s is DispatchShape {
  return (
    s === "radio" ||
    s === "checkbox" ||
    s === "orderMatch" ||
    s === "pairMatch" ||
    s === "blankSingle" ||
    s === "blankArray" ||
    s === "inline"
  );
}

/**
 * MATCHING_INFORMATION has two real render variants — same BE slug:
 *   - "Word List" blanks (BE injects `**Word List:**` + `___` runs and
 *     ships a structured `wordList`); rendered by `WordListCompletionCard`.
 *   - Paragraph-match A-F inputs (no word list, just a stem with blanks);
 *     rendered inline by `QuestionPanel` as an A-F single-letter input.
 *
 * The prompt tells us apart. Single source of truth — `mapApiQuestionToUi`
 * used to ship an identical copy; `QuestionPanel` used to ship another.
 * Both removed.
 */
export function isWordListBlank(promptMd: string | undefined): boolean {
  const s = promptMd ?? "";
  return s.includes("**Word List:**") && s.includes("___");
}

/** Convenience: render shape for a slug, returns `"inline"` for unknown input. */
export function dispatchShapeFor(
  slug: string,
  promptMd?: string,
): DispatchShape {
  if ((slug as QuestionTypeSlug) in DispatchByType) {
    const base = DispatchByType[slug as QuestionTypeSlug];
    if (
      base === "pairMatch" &&
      slug === "MATCHING_INFORMATION" &&
      !isWordListBlank(promptMd)
    ) {
      return "inline";
    }
    return base;
  }
  return "inline";
}
