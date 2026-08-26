import type { QuestionTypeSlug } from '../discriminator';

/**
 * Canonical examples for every question type.
 *
 * These are the single source of truth referenced by:
 * - `tests/samples.ts` (consumed by vitest)
 * - `scripts/parity-check.mjs` (consumed indirectly via JSON Schema `examples`)
 *
 * Each value is a complete envelope-shaped object: `{ type, payload, correctAnswer }`.
 * The envelope `type` matches the JSON Schema contract; `payload.type` and
 * `correctAnswer.type` are duplicated inside so the same object also satisfies
 * the Zod discriminated unions (which key off inner `type`).
 *
 * Every example satisfies:
 *   - all required fields populated
 *   - 2-3 optional fields included (realistic IELTS-style content, no Lorem ipsum)
 *   - LocalId-pattern ids (`opt_1`, `n_1`, `gap_1`, `p_1`, `b_1`, …)
 */
export interface CanonicalExample {
  type: QuestionTypeSlug;
  payload: Record<string, unknown> & { type: QuestionTypeSlug };
  correctAnswer: Record<string, unknown> & { type: QuestionTypeSlug };
}

function buildExample<T extends QuestionTypeSlug>(
  slug: T,
  payload: Omit<Record<string, unknown>, 'type'>,
  correctAnswer: Omit<Record<string, unknown>, 'type'>,
): CanonicalExample {
  return {
    type: slug,
    payload: { type: slug, ...payload },
    correctAnswer: { type: slug, ...correctAnswer },
  };
}

export const canonicalExamples: Record<QuestionTypeSlug, CanonicalExample> = {
  MULTIPLE_CHOICE_SINGLE: buildExample(
    'MULTIPLE_CHOICE_SINGLE',
    {
      id: '11111111-1111-4111-8111-111111111101',
      skill: 'READING',
      difficulty: 3,
      promptMd: "Which of the following best describes the author's view of urban rewilding projects?",
      schemaVersion: '1.0.0',
      explanationMd: 'The author contrasts the promise of biodiversity gains with concerns about pacing and funding.',
      options: [
        { id: 'opt_1', idx: 0, contentMd: 'They are an underfunded distraction from real conservation.' },
        { id: 'opt_2', idx: 1, contentMd: 'They are a promising but unevenly executed experiment.' },
        { id: 'opt_3', idx: 2, contentMd: 'They have already proven their long-term value.' },
        { id: 'opt_4', idx: 3, contentMd: 'They should replace traditional nature reserves entirely.' },
      ],
    },
    {
      correctOptionId: 'opt_2',
    },
  ),

  MULTIPLE_CHOICE_SINGLE_IMAGE: buildExample(
    'MULTIPLE_CHOICE_SINGLE_IMAGE',
    {
      id: '11111111-1111-4111-8111-111111111102',
      skill: 'READING',
      difficulty: 2,
      promptMd: 'Look at the diagram of the water cycle. Which stage is shown in panel C?',
      schemaVersion: '1.0.0',
      explanationMd: 'Panel C shows condensation forming clouds above the lake.',
      options: [
        { id: 'img_1', idx: 0, contentMd: 'Evaporation', mediaUrl: 'https://example.com/c1-evap.png', altText: 'Diagram showing water rising from a lake toward the sky.' },
        { id: 'img_2', idx: 1, contentMd: 'Condensation', mediaUrl: 'https://example.com/c2-cond.png', altText: 'Diagram showing water vapour forming a cloud.' },
        { id: 'img_3', idx: 2, contentMd: 'Precipitation', mediaUrl: 'https://example.com/c3-prec.png', altText: 'Diagram showing rain falling from a cloud.' },
      ],
    },
    {
      correctOptionId: 'img_2',
    },
  ),

  MULTIPLE_CHOICE_MULTIPLE: buildExample(
    'MULTIPLE_CHOICE_MULTIPLE',
    {
      id: '11111111-1111-4111-8111-111111111103',
      skill: 'READING',
      difficulty: 4,
      promptMd: 'Which **two** factors does the passage cite as causes of coral bleaching on the Great Barrier Reef?',
      schemaVersion: '1.0.0',
      options: [
        { id: 'opt_1', idx: 0, contentMd: 'Rising sea-surface temperatures' },
        { id: 'opt_2', idx: 1, contentMd: 'Increased coastal tourism' },
        { id: 'opt_3', idx: 2, contentMd: 'Ocean acidification' },
        { id: 'opt_4', idx: 3, contentMd: 'Overfishing of parrotfish' },
        { id: 'opt_5', idx: 4, contentMd: 'Storm-driven sediment runoff' },
      ],
      minSelections: 2,
      maxSelections: 2,
    },
    {
      correctOptionIds: ['opt_1', 'opt_3'],
      scoring: 'all-or-nothing',
    },
  ),

  TRUE_FALSE_NOT_GIVEN: buildExample(
    'TRUE_FALSE_NOT_GIVEN',
    {
      id: '11111111-1111-4111-8111-111111111104',
      skill: 'READING',
      difficulty: 2,
      promptMd: 'Do the following statements agree with the information in the passage?',
      schemaVersion: '1.0.0',
      statement: 'The Okavango Delta is the largest inland delta in the world.',
      options: [
        { id: 't', idx: 0, contentMd: 'TRUE' },
        { id: 'f', idx: 1, contentMd: 'FALSE' },
        { id: 'ng', idx: 2, contentMd: 'NOT GIVEN' },
      ],
    },
    {
      choice: 'TRUE',
    },
  ),

  YES_NO_NOT_GIVEN: buildExample(
    'YES_NO_NOT_GIVEN',
    {
      id: '11111111-1111-4111-8111-111111111105',
      skill: 'READING',
      difficulty: 3,
      promptMd: 'Do the following statements agree with the views of the author?',
      schemaVersion: '1.0.0',
      statement: 'The author believes that four-day workweeks improve employee wellbeing.',
      options: [
        { id: 'y', idx: 0, contentMd: 'YES' },
        { id: 'n', idx: 1, contentMd: 'NO' },
        { id: 'ng', idx: 2, contentMd: 'NOT GIVEN' },
      ],
    },
    {
      choice: 'YES',
    },
  ),

  SUMMARY_COMPLETION: buildExample(
    'SUMMARY_COMPLETION',
    {
      id: '11111111-1111-4111-8111-111111111106',
      skill: 'READING',
      difficulty: 4,
      promptMd:
        'Complete the summary below. Choose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n' +
        'The {{gap:gap_1}} is a layer of gas that traps heat close to the Earth. ' +
        'When its concentration rises, average surface {{gap:gap_2}} increase. ' +
        'Scientists monitor this with instruments placed on {{gap:gap_3}} and in orbit.',
      schemaVersion: '1.0.0',
      gaps: [
        { id: 'gap_1', wordLimit: 2 },
        { id: 'gap_2', wordLimit: 2 },
        { id: 'gap_3', wordLimit: 2 },
      ],
    },
    {
      answers: {
        gap_1: ['greenhouse', 'green house'],
        gap_2: ['temperatures'],
        gap_3: ['mountains'],
      },
    },
  ),

  TABLE_COMPLETION: buildExample(
    'TABLE_COMPLETION',
    {
      id: '11111111-1111-4111-8111-111111111107',
      skill: 'LISTENING',
      difficulty: 4,
      promptMd: 'Complete the table below. Write **NO MORE THAN ONE WORD** for each answer.',
      schemaVersion: '1.0.0',
      cells: [
        { rowId: 'row_mon', colId: 'col_focus', gapId: 'gap_1' },
        { rowId: 'row_wed', colId: 'col_focus', gapId: 'gap_2' },
      ],
      gaps: [
        { id: 'gap_1', wordLimit: 1, expectedKind: 'text' },
        { id: 'gap_2', wordLimit: 1, expectedKind: 'text' },
      ],
    },
    {
      answers: {
        gap_1: ['vocabulary'],
        gap_2: ['pronunciation'],
      },
    },
  ),

  NOTE_COMPLETION: buildExample(
    'NOTE_COMPLETION',
    {
      id: '11111111-1111-4111-8111-111111111108',
      skill: 'LISTENING',
      difficulty: 3,
      promptMd:
        'Complete the notes below. Write **ONE WORD ONLY**.\n\n' +
        'Library orientation\n' +
        '- Borrow up to {{gap:gap_1}} books at a time.\n' +
        '- Returns must be made by the {{gap:gap_2}} of each month.',
      schemaVersion: '1.0.0',
      gaps: [
        { id: 'gap_1', wordLimit: 1, expectedKind: 'number' },
        { id: 'gap_2', wordLimit: 1 },
      ],
    },
    {
      answers: {
        gap_1: ['five'],
        gap_2: ['tenth'],
      },
    },
  ),

  FORM_COMPLETION: buildExample(
    'FORM_COMPLETION',
    {
      id: '11111111-1111-4111-8111-111111111109',
      skill: 'LISTENING',
      difficulty: 3,
      promptMd: 'Complete the booking form below.',
      schemaVersion: '1.0.0',
      gaps: [
        { id: 'gap_1', expectedKind: 'date' },
        { id: 'gap_2', expectedKind: 'text' },
      ],
    },
    {
      answers: {
        gap_1: ['14 March 2024'],
        gap_2: ['Kingston'],
      },
    },
  ),

  SENTENCE_COMPLETION: buildExample(
    'SENTENCE_COMPLETION',
    {
      id: '11111111-1111-4111-8111-111111111110',
      skill: 'READING',
      difficulty: 2,
      promptMd:
        "Complete the sentence. The blackbird's song is most distinctive at {{gap:gap_1}}.",
      schemaVersion: '1.0.0',
      gap: { id: 'gap_1', wordLimit: 1 },
    },
    {
      acceptedTexts: ['dawn'],
      acceptedRegexes: ['^sunrise$'],
    },
  ),

  SHORT_ANSWER: buildExample(
    'SHORT_ANSWER',
    {
      id: '11111111-1111-4111-8111-111111111111',
      skill: 'READING',
      difficulty: 2,
      promptMd: "What colour are the seats at Wimbledon's Centre Court? Answer in **ONE WORD**.",
      schemaVersion: '1.0.0',
      wordLimit: 1,
      normalization: { case: 'insensitive', trimWhitespace: true, collapseInnerWhitespace: true },
    },
    {
      acceptedTexts: ['purple', 'green'],
      acceptedRegexes: [],
    },
  ),

  AUDIO_RESPONSE: buildExample(
    'AUDIO_RESPONSE',
    {
      id: '11111111-1111-4111-8111-111111111112',
      skill: 'LISTENING',
      difficulty: 3,
      promptMd: 'Describe a memorable journey you have taken. You should say where you went, how you travelled, and explain why it was memorable.',
      schemaVersion: '1.0.0',
      maxDurationSec: 120,
      promptAudioUrl: 'https://example.com/prompts/ielts-part2-cue.mp3',
    },
    {
      acceptedTranscriptions: [
        'Last summer I travelled by train through the Scottish Highlands with two friends.',
      ],
      modelTranscription:
        'Last summer I travelled by train through the Scottish Highlands with two friends. We spent three days hiking near Glencoe and the views from the ridge were unforgettable.',
      scoring: 'ai+human',
    },
  ),

  DIAGRAM_LABEL: buildExample(
    'DIAGRAM_LABEL',
    {
      id: '11111111-1111-4111-8111-111111111113',
      skill: 'READING',
      difficulty: 4,
      promptMd: 'Label the diagram. Write **NO MORE THAN TWO WORDS** for each label.',
      schemaVersion: '1.0.0',
      diagramImageUrl: 'https://example.com/diagrams/plant-cell.png',
      diagramAltText: 'Cross-section of a plant cell showing the main organelles.',
      labels: [
        { id: 'lbl_1', text: 'A', region: { x: 0.10, y: 0.20, w: 0.08, h: 0.05 } },
        { id: 'lbl_2', text: 'B', region: { x: 0.55, y: 0.40, w: 0.08, h: 0.05 } },
      ],
      // Per Phase 3 invariant: gap.id must be one of labels[].id (each labelled
      // region has its own gap answer slot).
      gaps: [
        { id: 'lbl_1', wordLimit: 2 },
        { id: 'lbl_2', wordLimit: 1 },
      ],
    },
    {
      answers: {
        lbl_1: ['cell wall', 'wall'],
        lbl_2: ['nucleus'],
      },
    },
  ),

  MAP_LABEL: buildExample(
    'MAP_LABEL',
    {
      id: '11111111-1111-4111-8111-111111111114',
      skill: 'LISTENING',
      difficulty: 3,
      promptMd: 'Label the map of Newton village. Write **ONE WORD ONLY** for each answer.',
      schemaVersion: '1.0.0',
      diagramImageUrl: 'https://example.com/maps/newton.png',
      diagramAltText: 'Sketch map of Newton village showing the school, library, and bus stop.',
      labels: [
        { id: 'lbl_1', text: '?', region: { x: 0.20, y: 0.30, w: 0.10, h: 0.06 } },
        { id: 'lbl_2', text: '?', region: { x: 0.65, y: 0.55, w: 0.10, h: 0.06 } },
      ],
      // Per Phase 3 invariant: gap.id must be one of labels[].id.
      gaps: [
        { id: 'lbl_1', wordLimit: 1 },
        { id: 'lbl_2', wordLimit: 1 },
      ],
    },
    {
      answers: {
        lbl_1: ['library'],
        lbl_2: ['school'],
      },
    },
  ),

  MATCHING_HEADING: buildExample(
    'MATCHING_HEADING',
    {
      id: '11111111-1111-4111-8111-111111111115',
      skill: 'READING',
      difficulty: 4,
      promptMd: 'Match each paragraph with the correct heading.',
      schemaVersion: '1.0.0',
      paragraphs: [
        { id: 'p_1', romanNumeral: 'i' },
        { id: 'p_2', romanNumeral: 'ii' },
        { id: 'p_3', romanNumeral: 'iii' },
      ],
      headings: [
        { id: 'h_1', text: 'A long-standing tradition' },
        { id: 'h_2', text: 'An unexpected consequence' },
        { id: 'h_3', text: 'The economic backdrop' },
      ],
      arity: '1-1',
    },
    {
      pairs: [
        { paragraphId: 'p_1', headingId: 'h_1' },
        { paragraphId: 'p_2', headingId: 'h_3' },
        { paragraphId: 'p_3', headingId: 'h_2' },
      ],
      scoring: 'all-or-nothing',
    },
  ),

  MATCHING_INFORMATION: buildExample(
    'MATCHING_INFORMATION',
    {
      id: '11111111-1111-4111-8111-111111111116',
      skill: 'READING',
      difficulty: 4,
      promptMd: 'Match each piece of information with the paragraph (A, B, C) that contains it.',
      schemaVersion: '1.0.0',
      paragraphs: [
        { id: 'p_1', label: 'A' },
        { id: 'p_2', label: 'B' },
        { id: 'p_3', label: 'C' },
      ],
      questions: [
        { id: 'q_1', prompt: 'A reference to the role of soil microbes.' },
        { id: 'q_2', prompt: 'A statistic on urban canopy coverage.' },
      ],
      allowReuse: false,
    },
    {
      pairs: [
        { questionId: 'q_1', paragraphId: 'p_2' },
        { questionId: 'q_2', paragraphId: 'p_3' },
      ],
      scoring: 'all-or-nothing',
    },
  ),

  MATCHING_FEATURES: buildExample(
    'MATCHING_FEATURES',
    {
      id: '11111111-1111-4111-8111-111111111117',
      skill: 'LISTENING',
      difficulty: 3,
      promptMd: 'Match each theory with the researcher who proposed it.',
      schemaVersion: '1.0.0',
      items: [
        { id: 'i_1', text: 'Relativity' },
        { id: 'i_2', text: 'Natural selection' },
        { id: 'i_3', text: 'Plate tectonics' },
      ],
      features: [
        { id: 'f_1', label: 'Einstein' },
        { id: 'f_2', label: 'Darwin' },
        { id: 'f_3', label: 'Wegener' },
      ],
      allowReuse: false,
    },
    {
      pairs: [
        { itemId: 'i_1', featureId: 'f_1' },
        { itemId: 'i_2', featureId: 'f_2' },
        { itemId: 'i_3', featureId: 'f_3' },
      ],
      scoring: 'all-or-nothing',
    },
  ),

  MATCHING_ENDINGS: buildExample(
    'MATCHING_ENDINGS',
    {
      id: '11111111-1111-4111-8111-111111111118',
      skill: 'READING',
      difficulty: 3,
      promptMd: 'Match each sentence beginning with the correct ending.',
      schemaVersion: '1.0.0',
      beginnings: [
        { id: 'b_1', text: 'When the rain stops,' },
        { id: 'b_2', text: 'Before the bell rings,' },
        { id: 'b_3', text: 'Although the road was flooded,' },
      ],
      endings: [
        { id: 'e_1', text: 'we usually walk home together.' },
        { id: 'e_2', text: 'they leave the classroom quietly.' },
        { id: 'e_3', text: 'we still managed to get to school.' },
      ],
    },
    {
      pairs: [
        { beginId: 'b_1', endId: 'e_1' },
        { beginId: 'b_2', endId: 'e_2' },
        { beginId: 'b_3', endId: 'e_3' },
      ],
      scoring: 'all-or-nothing',
    },
  ),

  CLASSIFICATION: buildExample(
    'CLASSIFICATION',
    {
      id: '11111111-1111-4111-8111-111111111119',
      skill: 'READING',
      difficulty: 3,
      promptMd: 'Classify each item as either Fruit or Vegetable.',
      schemaVersion: '1.0.0',
      items: [
        { id: 'i_1', text: 'Apple' },
        { id: 'i_2', text: 'Carrot' },
        { id: 'i_3', text: 'Spinach' },
        { id: 'i_4', text: 'Tomato' },
      ],
      categories: [
        { id: 'c_1', label: 'Fruit' },
        { id: 'c_2', label: 'Vegetable' },
      ],
    },
    {
      pairs: [
        { itemId: 'i_1', categoryId: 'c_1' },
        { itemId: 'i_2', categoryId: 'c_2' },
        { itemId: 'i_3', categoryId: 'c_2' },
        { itemId: 'i_4', categoryId: 'c_1' },
      ],
      scoring: 'all-or-nothing',
    },
  ),

  FLOW_CHART: buildExample(
    'FLOW_CHART',
    {
      id: '11111111-1111-4111-8111-111111111120',
      skill: 'READING',
      difficulty: 4,
      promptMd: 'Order the stages of the coffee roasting process.',
      schemaVersion: '1.0.0',
      nodes: [
        { id: 'n_1', label: 'Harvest', position: { x: 0, y: 0 } },
        { id: 'n_2', label: 'Wash', position: { x: 1, y: 0 } },
        { id: 'n_3', label: 'Roast', position: { x: 2, y: 0 } },
        { id: 'n_4', label: 'Cool', position: { x: 3, y: 0 } },
        { id: 'n_5', label: 'Package', position: { x: 4, y: 0 } },
      ],
      edges: [
        { from: 'n_1', to: 'n_2' },
        { from: 'n_2', to: 'n_3' },
        { from: 'n_3', to: 'n_4' },
        { from: 'n_4', to: 'n_5' },
      ],
    },
    {
      order: ['n_1', 'n_2', 'n_3', 'n_4', 'n_5'],
      scoring: 'exact',
    },
  ),

  FLOW_CHART_COMPLETION: buildExample(
    'FLOW_CHART_COMPLETION',
    {
      id: '11111111-1111-4111-8111-111111111121',
      skill: 'READING',
      difficulty: 5,
      promptMd:
        'Complete the flow chart showing the water cycle. ' +
        'Use **ONE WORD** for each gap. Then order the stages.',
      schemaVersion: '1.0.0',
      nodes: [
        { id: 'n_1', label: 'Step 1', position: { x: 0, y: 0 } },
        { id: 'n_2', label: 'Step 2', position: { x: 1, y: 0 } },
        { id: 'n_3', label: 'Step 3', position: { x: 2, y: 0 } },
        { id: 'n_4', label: 'Step 4', position: { x: 3, y: 0 } },
      ],
      edges: [
        { from: 'n_1', to: 'n_2' },
        { from: 'n_2', to: 'n_3' },
        { from: 'n_3', to: 'n_4' },
      ],
      gaps: [
        { nodeId: 'n_1', wordLimit: 1 },
        { nodeId: 'n_3', wordLimit: 1 },
      ],
    },
    {
      order: ['n_1', 'n_2', 'n_3', 'n_4'],
      gapAnswers: {
        n_1: { acceptedTexts: ['evaporation'] },
        n_3: { acceptedTexts: ['precipitation'] },
      },
    },
  ),
};
