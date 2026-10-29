import { Value } from "typebox/value";
import { schemaIssues } from "./diagnostics.ts";
import { questionSchema, answerSlots, counts, diagnostic as d, families, ACADEMIC_READING_SUPPORTED_TYPES, PLATFORM_ONLY_TYPES, type Diagnostic, type DiagnosticCategory, type Exam, type Group, type Kind, type Profile, type Question } from "./contracts.ts";
import { choiceTextIdentity } from "./grading.ts";
const hasText = (xs?: string[]) => xs?.some(x => x.trim().length > 0) ?? false;
const populated = (m?: Record<string, string[]>) => Object.values(m ?? {}).some(hasText);
function duplicates(xs: (string | number)[]) { return new Set(xs).size !== xs.length; }
function contiguous(xs: number[], first: number) { return [...xs].sort((a, b) => a - b).every((x, i) => x === first + i); }
export function validateQuestion(q: Question, path = "question", profile: Profile = "platform-reference"): Diagnostic[] {
  const issues: Diagnostic[] = [];
  const add = (code: string, message: string, severity: Diagnostic["severity"] = "error", category?: DiagnosticCategory, guidance?: string) => issues.push(d(code, path, message, severity, category, guidance));
  const family = families[q.type];
  if (!family) { add("QUESTION_TYPE_UNKNOWN", "Unknown shared contract question type.", "error", "invalid-input", "Declare one of the 19 valid QuestionType literals."); return issues; }
  if (profile === "strict-academic") {
    if (PLATFORM_ONLY_TYPES.has(q.type)) {
      add("ACADEMIC_TYPE_UNSUPPORTED", `${q.type} is excluded by the selected strict Academic generation profile; this does not prove that IELTS universally prohibits this presentation.`, "error", "unsupported-capability", `Use supported Academic Reading types: ${[...ACADEMIC_READING_SUPPORTED_TYPES].join(", ")}.`);
    }
    if (answerSlots(q) !== 1) {
      add("ACADEMIC_MULTI_SLOT_UNSUPPORTED", `Question ${q.id} has ${answerSlots(q)} answer slots. Under strict IELTS Academic, each mark must be an independent scoring item; multi-blank questions cannot collapse multiple marks into one all-or-nothing Question.`, "error", "unsupported-capability", "Structure each answer slot as an independently scored Question.");
    }
  }
  if (!q.promptMd.trim()) add("PROMPT_EMPTY", "A student-visible prompt is required.");
  if (duplicates(q.options.map(o => o.idx)) || duplicates(q.options.map(o => o.id.toLowerCase()))) add("OPTION_DUPLICATE", "Option IDs and indices must be unique.");
  if (!contiguous(q.options.map(o => o.idx), 1)) add("OPTION_INDEX_COVERAGE", "Option indices must cover 1..N.");
  if (q.options.some(o => !o.contentMd.trim())) add("OPTION_CONTENT_EMPTY", "Option content is required.");
  // Single-choice text fallback compares trimmed, case-insensitive option text.
  // A distractor with the same text as a key can therefore grade as correct.
  const keyedTexts = new Set(q.options.filter(o => o.isCorrect).map(o => choiceTextIdentity(o.contentMd)));
  if ((family === "single" || family === "multiple") && q.options.some(o => !o.isCorrect && keyedTexts.has(choiceTextIdentity(o.contentMd)))) {
    add("DISTRACTOR_KEY_CONFLICT", "A distractor duplicates keyed option text under backend-compatible whitespace and case comparison.");
  }
  if ((family === "single" || family === "multiple") && duplicates(q.options.map(o => choiceTextIdentity(o.contentMd)))) {
    if (!issues.some(i => i.code === "DISTRACTOR_KEY_CONFLICT")) {
      add("OPTION_CONTENT_DUPLICATE", "Option choices must have distinct text content.");
    }
  }
  const correct = q.options.filter(o => o.isCorrect).length;
  if (family === "single" && correct !== 1) add("CHOICE_KEY_COUNT", "Exactly one correct option is required.");
  if (family === "multiple" && correct < 2) add("CHOICE_KEY_COUNT", "Multiple choice requires at least two correct options.");
  if ((family === "single" || family === "multiple") && q.options.length < 2) add("CHOICE_OPTIONS_MISSING", "At least two options are required.");
  if ((q.type === "TRUE_FALSE_NOT_GIVEN" || q.type === "YES_NO_NOT_GIVEN") &&
      JSON.stringify(q.options.map(o => o.contentMd.trim().toUpperCase()).sort()) !== JSON.stringify((q.type === "TRUE_FALSE_NOT_GIVEN" ? ["TRUE", "FALSE", "NOT GIVEN"] : ["YES", "NO", "NOT GIVEN"]).sort())) {
    add("IELTS_TRUTH_OPTIONS", "Truth questions require their three canonical student choices.");
  }
  if (q.type === "MULTIPLE_CHOICE_SINGLE_IMAGE") {
    const hasQuestionImage = !!q.imageUrl?.trim();
    const hasOptionImages = q.options.length > 0 && q.options.every(o => !!o.imageUrl?.trim());
    if (!hasQuestionImage && !hasOptionImages) add("IMAGE_REQUIRED", "MULTIPLE_CHOICE_SINGLE_IMAGE requires either question-level imageUrl or all options with imageUrl.");
  }
  for (const opt of q.options) {
    if (opt.imageUrl?.trim() && !opt.altText?.trim()) {
      add("OPTION_ALT_TEXT_REQUIRED", `Option ${opt.id} with imageUrl requires descriptive altText.`);
    }
  }
  if (family === "completion") {
    if (!populated(q.blankAcceptTexts)) add("INGESTION_BLANK_KEY_REQUIRED", "Admin requires non-empty BlankAcceptTexts even when regexes exist.");
    const keys = [...new Set([...Object.keys(q.blankAcceptTexts ?? {}), ...Object.keys(q.blankAcceptRegex ?? {})])];
    if (!keys.length || keys.some(k => !/^[1-9]\d*$/.test(k))) add("BLANK_INDEX_INVALID", "Blank IDs must be positive numeric strings.");
    const diagram = (q.type === "DIAGRAM_LABEL" || q.type === "MAP_LABEL") && /\[(?:Diagram|Map):\s*[^\]]+\]/.test(q.promptMd);
    const markers = [...q.promptMd.matchAll(/\[(\d+)\]/g)].map(m => m[1]);
    for (const key of keys) {
      if (!hasText(q.blankAcceptTexts?.[key]) && !hasText(q.blankAcceptRegex?.[key])) add("BLANK_KEY_EMPTY", `Blank ${key} has no accepted answer.`);
      if (!diagram && !markers.includes(key)) add("INGESTION_BLANK_MARKER_MISSING", `Prompt lacks [${key}].`);
    }
    if (!diagram && markers.some(k => !keys.includes(k))) add("BLANK_MARKER_UNKEYED", "Every visible blank must have a grading key.");
    if (duplicates(markers)) add("BLANK_MARKER_DUPLICATE", "Repeated blank markers make answer slots ambiguous.");
  }
  if (family === "short" && !hasText(q.shortAnswerAcceptTexts)) add("INGESTION_SHORT_KEY_REQUIRED", "Admin requires ShortAnswerAcceptTexts.");
  if (family === "matching") {
    if (!populated(q.matchPairs)) add("INGESTION_MATCH_KEY_REQUIRED", "Admin requires MatchPairs.");
    for (const [key, values] of Object.entries(q.matchPairs ?? {})) {
      if (!key.trim() || values.length < 2 || !values[0]?.trim()) add("INGESTION_MATCH_PAIR_INVALID", `Pair ${key} requires [gradingKey, displayLabel].`);
      if (!values[1]?.trim()) add("MATCH_DISPLAY_EMPTY", `Pair ${key} lacks its display label.`);
    }
    add("MATCHING_DISPLAY_TEXT_ACCEPTED", "The backend accepts every pair value, including display text, without trimming JSON values.", "warning");
  }
  if (family === "flow") {
    if (!hasText(q.orderCorrects)) add("INGESTION_FLOW_ORDER_REQUIRED", "Admin requires OrderCorrects.");
    if (q.orderCorrects?.some(k => !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(k))) add("INGESTION_FLOW_ORDER_INVALID", "Flow node keys must be lowercase slugs.");
    if (duplicates(q.orderCorrects ?? [])) add("FLOW_NODE_DUPLICATE", "Duplicate node keys cannot be independently delivered.");
    add("FLOW_NOT_IELTS_COMPLETION", "Backend FLOW_CHART grades ordering, not IELTS flow-chart blank completion.", "warning");
    add("FLOW_OBJECT_CASE_MISMATCH", "Legacy JS oracle models case-sensitive Steps/Labels; current dirty .NET source accepts lowercase. Use canonical arrays; see the separate actual-.NET fixture.", "warning");
  }
  if (family !== "completion" && populated(q.blankAcceptTexts)) add(family === "flow" ? "INGESTION_FLOW_LABELS_FORBIDDEN" : "INGESTION_BLANK_KEY_FORBIDDEN", "Admin forbids BlankAcceptTexts for this type, including FLOW_CHART labels.");
  if (family !== "matching" && populated(q.matchPairs)) add("INGESTION_MATCH_KEY_FORBIDDEN", "Admin forbids MatchPairs for this type.");
  if (family !== "flow" && hasText(q.orderCorrects)) add("INGESTION_FLOW_ORDER_FORBIDDEN", "Admin forbids OrderCorrects for this type.");
  if (family !== "short" && hasText(q.shortAnswerAcceptTexts)) add("INGESTION_SHORT_KEY_FORBIDDEN", "Admin forbids ShortAnswerAcceptTexts for this type.");
  // Stronger canonical policy than admin: don't silently retain ignored private keys.
  if (family !== "completion" && Object.keys(q.blankAcceptRegex ?? {}).length) add("REGEX_KEY_FORBIDDEN", "Blank regex keys only belong to completion questions.");
  if (family !== "short" && q.shortAnswerAcceptRegex?.length) add("REGEX_KEY_FORBIDDEN", "Short-answer regex keys only belong to short answers.");
  if (Object.values(q.blankAcceptTexts ?? {}).flat().some(x => !x.trim()) || q.shortAnswerAcceptTexts?.some(x => !x.trim())) add("ACCEPTED_TEXT_EMPTY", "Empty accepted answers can grade missing input as correct.");
  if (answerSlots(q) > 1) add("MULTI_SLOT_ALL_OR_NOTHING", "Several answer slots still earn only one independent all-or-nothing scoring unit.", "warning");
  return issues;
}
export function validateGroup(g: Group, path = "group", profile: Profile = "platform-reference"): Diagnostic[] {
  const issues = g.questions.flatMap((q, i) => validateQuestion(q, `${path}.questions[${i}]`, profile));
  if (!g.instructionMd.trim()) issues.push(d("GROUP_INSTRUCTION_EMPTY", path, "Student instructions are required."));
  if (!g.questions.length) issues.push(d("GROUP_EMPTY", path, "A group must contain questions."));
  if (g.endIdx < g.startIdx || g.endIdx - g.startIdx + 1 !== g.questions.length || !contiguous(g.questions.map(q => q.idx), g.startIdx)) issues.push(d("GROUP_INDEX_COVERAGE", path, "Group bounds must exactly cover its question indices."));
  if (duplicates(g.questions.map(q => q.id))) issues.push(d("QUESTION_DUPLICATE", path, "Question IDs must be unique."));
  const allOptions = g.questions.flatMap(q => q.options);
  if (duplicates(allOptions.map(o => o.id.toLowerCase()))) issues.push(d("OPTION_DUPLICATE", path, "Option IDs must be unique within the group."));
  if (g.questions.some(q => q.groupId !== g.id)) issues.push(d("QUESTION_GROUP_MEMBERSHIP", path, "Every question must belong to its containing group."));
  return issues;
}
export type PaperRequirements = { sectionScoringUnits?: number[]; answerSlotCount?: number; profile?: Profile };
export function validateExam(exam: Exam, complete: boolean, requirements: PaperRequirements = {}): Diagnostic[] {
  const issues: Diagnostic[] = [];
  const profile = requirements.profile ?? "platform-reference";
  const groups = exam.sections.flatMap(s => s.questionGroups);
  const qs = groups.flatMap(g => g.questions);
  if (!exam.sections.length) issues.push(d("EXAM_EMPTY", "exam", "An exam must contain sections."));
  if (duplicates(exam.sections.map(s => s.id)) || !contiguous(exam.sections.map(s => s.idx), 1)) issues.push(d("SECTION_INDEX_COVERAGE", "exam.sections", "Sections must have unique IDs and indices covering 1..N."));
  for (const [i, s] of exam.sections.entries()) {
    const path = `exam.sections[${i}]`;
    if (s.examId !== exam.id) issues.push(d("SECTION_EXAM_MEMBERSHIP", path, "Section belongs to another exam."));
    if (!s.passageMd.trim()) issues.push(d("PASSAGE_EMPTY", path, "Academic Reading requires passage content."));
    if (!s.questionGroups.length) issues.push(d("SECTION_EMPTY", path, "Section must contain question groups."));
    if (!contiguous(s.questionGroups.map(g => g.idx), 1)) issues.push(d("GROUP_INDEX_ORDER", path, "Group indices must cover 1..N within their section."));
    const orderedGroups = [...s.questionGroups].sort((a, b) => a.idx - b.idx);
    if (orderedGroups.some((g, i) => i > 0 && g.startIdx !== orderedGroups[i - 1].endIdx + 1)) issues.push(d("SECTION_GROUP_RANGE_CONTINUITY", path, "Group ranges must be consecutive and non-overlapping in delivery order."));
    for (const [j, g] of s.questionGroups.entries()) {
      if (g.sectionId !== s.id) issues.push(d("GROUP_SECTION_MEMBERSHIP", `${path}.questionGroups[${j}]`, "Group belongs to another section."));
      issues.push(...validateGroup(g, `${path}.questionGroups[${j}]`, profile));
    }
  }
  if (duplicates(groups.map(g => g.id))) issues.push(d("GROUP_DUPLICATE", "exam", "Group IDs must be paper-wide unique."));
  if (duplicates(qs.map(q => q.id))) issues.push(d("QUESTION_DUPLICATE", "exam", "Question IDs must be paper-wide unique."));
  const allOptions = qs.flatMap(q => q.options);
  if (duplicates(allOptions.map(o => o.id.toLowerCase()))) issues.push(d("OPTION_DUPLICATE", "exam", "Option IDs must be paper-wide unique."));
  const orderedSections = [...exam.sections].sort((a, b) => a.idx - b.idx);
  for (let sIdx = 1; sIdx < orderedSections.length; sIdx++) {
    const prevGroups = [...orderedSections[sIdx - 1].questionGroups].sort((a, b) => a.idx - b.idx);
    const currGroups = [...orderedSections[sIdx].questionGroups].sort((a, b) => a.idx - b.idx);
    if (prevGroups.length && currGroups.length && currGroups[0].startIdx !== prevGroups.at(-1)!.endIdx + 1) {
      const origIdx = exam.sections.indexOf(orderedSections[sIdx]);
      issues.push(d("SECTION_GROUP_RANGE_CONTINUITY", `exam.sections[${origIdx}]`, "Group ranges must be consecutive and non-overlapping in delivery order."));
    }
  }
  const firstSectionGroups = orderedSections[0]?.questionGroups ? [...orderedSections[0].questionGroups].sort((a, b) => a.idx - b.idx) : [];
  if (firstSectionGroups.length && firstSectionGroups[0].startIdx !== 1) {
    const firstOrigIdx = exam.sections.indexOf(orderedSections[0]);
    issues.push(d("SECTION_GROUP_RANGE_CONTINUITY", `exam.sections[${firstOrigIdx}]`, "First group range must start at question index 1."));
  }
  const ordered = [...exam.sections].sort((a, b) => a.idx - b.idx).flatMap(s => [...s.questionGroups].sort((a, b) => a.idx - b.idx)).flatMap(g => [...g.questions].sort((a, b) => a.idx - b.idx));
  if (ordered.some((q, i) => q.idx !== i + 1)) issues.push(d("PAPER_INDEX_COVERAGE", "exam", "Delivery order requires paper-wide question indices 1..N, not section-local indices."));
  if (requirements.sectionScoringUnits && (requirements.sectionScoringUnits.length !== orderedSections.length || orderedSections.some((s, i) => counts(s.questionGroups).scoringUnitCount !== requirements.sectionScoringUnits![i]))) {
    issues.push(d("SECTION_SCORING_UNIT_COUNT", "exam.sections", "Section scoring units must match the caller-supplied distribution in section index order."));
  }
  if (requirements.answerSlotCount !== undefined && counts(groups).answerSlotCount !== requirements.answerSlotCount) {
    issues.push(d("PAPER_ANSWER_SLOT_COUNT", "exam", "Answer slots must match the caller-supplied count; slots are not independent scoring units."));
  }
  if (complete && counts(groups).scoringUnitCount !== 40) issues.push(d("PAPER_SCORING_UNIT_COUNT", "exam", "A complete paper requires exactly 40 independent scoring units, not 40 answer slots."));
  if (complete && exam.sections.length !== 3) issues.push(d("ACADEMIC_SECTION_COUNT", "exam", "A complete Academic Reading paper requires three sections."));
  if (complete && profile === "strict-academic") {
    const c = counts(groups);
    if (c.scoringUnitCount !== 40 || c.answerSlotCount !== 40 || c.questionCount !== 40) {
      issues.push(d("ACADEMIC_SCORING_UNIT_COUNT", "exam", `A complete Academic Reading paper requires exactly 40 independent scoring units and 40 answer slots (found ${c.scoringUnitCount} scoring units, ${c.answerSlotCount} slots, ${c.questionCount} questions).`));
    }
    const totalWords = exam.sections.reduce((n, s) => n + s.passageMd.trim().split(/\s+/).length, 0);
    if (totalWords < 2150 || totalWords > 2750) {
      issues.push(d("ACADEMIC_PASSAGE_LENGTH_INVALID", "exam.sections", `Academic Reading requires 2,150–2,750 total passage words (found ${totalWords} words across 3 sections).`, "warning"));
    }
  }
  return issues;
}

export type DraftInspectionReport = {
  status: "PASS" | "FAIL";
  isDraft: true;
  diagnostics: Diagnostic[];
  questionType?: Kind;
  family?: string;
  missingFields: string[];
  presentFields: string[];
  repairGuidance: string[];
  validForIngestion: boolean;
};

export function inspectDraft(input: unknown, path = "draft"): DraftInspectionReport {
  const issues: Diagnostic[] = [];
  const add = (code: string, message: string, severity: Diagnostic["severity"] = "error", category: DiagnosticCategory = "invalid-input", guidance?: string) => {
    issues.push(d(code, path, message, severity, category, guidance));
  };
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    add("DRAFT_NOT_OBJECT", "Draft input must be a non-null object.", "error", "invalid-input", "Supply a JSON object representing the question draft.");
    return {
      status: "FAIL", isDraft: true, diagnostics: issues, missingFields: ["type", "promptMd", "options"], presentFields: [], repairGuidance: ["Supply a valid JSON object."], validForIngestion: false,
    };
  }
  const dObj = input as Record<string, unknown>;
  const presentFields = Object.keys(dObj);
  const missingFields: string[] = [];
  const repairGuidance: string[] = [];

  const type = typeof dObj.type === "string" && Object.hasOwn(families, dObj.type) ? (dObj.type as Kind) : undefined;
  const family = type ? families[type] : undefined;

  if (!type) {
    missingFields.push("type");
    add("DRAFT_TYPE_MISSING", "Draft must declare a valid canonical QuestionType.", "error", "invalid-input", "Specify one of the 19 canonical question types in the 'type' field.");
    repairGuidance.push("Add 'type' with one of the 19 canonical types.");
  }

  if (typeof dObj.promptMd !== "string" || !dObj.promptMd.trim()) {
    missingFields.push("promptMd");
    add("DRAFT_PROMPT_MISSING", "Draft must contain a non-empty 'promptMd' string.", "error", "invalid-input", "Provide promptMd describing the question or passage-referenced statement.");
    repairGuidance.push("Add non-empty 'promptMd'.");
  }

  if (!("id" in dObj) || typeof dObj.id !== "string" || !dObj.id.trim()) {
    missingFields.push("id");
    add("DRAFT_ID_MISSING", "Draft lacks a stable question 'id'.", "warning", "invalid-input", "Supply an explicit local ID (e.g. 'q1') or UUID.");
    repairGuidance.push("Add a question 'id'.");
  }

  if (!("groupId" in dObj) || typeof dObj.groupId !== "string" || !dObj.groupId.trim()) {
    missingFields.push("groupId");
    add("DRAFT_GROUP_ID_MISSING", "Draft lacks 'groupId' reference.", "warning", "invalid-input", "Set groupId to match the containing QuestionGroup.");
    repairGuidance.push("Set groupId to containing group ID.");
  }

  if (!("idx" in dObj) || typeof dObj.idx !== "number" || !Number.isInteger(dObj.idx) || dObj.idx < 1) {
    missingFields.push("idx");
    add("DRAFT_IDX_MISSING", "Draft lacks positive 1-based question 'idx'.", "warning", "invalid-input", "Assign a positive integer idx (1..N).");
    repairGuidance.push("Assign positive integer idx.");
  }

  if (family === "single" || family === "multiple") {
    if (!Array.isArray(dObj.options) || dObj.options.length < 2) {
      missingFields.push("options");
      add("DRAFT_OPTIONS_INCOMPLETE", `${type ?? "Choice question"} requires at least 2 options in 'options'.`, "error", "invalid-input", "Provide options array with at least 2 choice objects.");
      repairGuidance.push("Provide options array with choice objects.");
    } else {
      const opts = dObj.options as Array<Record<string, unknown>>;
      const correctCount = opts.filter(o => o && typeof o === "object" && o.isCorrect === true).length;
      if (family === "single" && correctCount !== 1) {
        add("CHOICE_KEY_COUNT", `Single choice requires exactly 1 option with isCorrect: true (found ${correctCount}).`, "error", "invalid-input", "Mark exactly one option as isCorrect: true.");
        repairGuidance.push("Mark exactly one option as isCorrect: true.");
      } else if (family === "multiple" && correctCount < 2) {
        add("CHOICE_KEY_COUNT", `Multiple choice requires at least 2 options with isCorrect: true (found ${correctCount}).`, "error", "invalid-input", "Mark at least two options as isCorrect: true.");
        repairGuidance.push("Mark at least two options as isCorrect: true.");
      }
    }
  } else if (family === "completion") {
    const hasTexts = dObj.blankAcceptTexts && typeof dObj.blankAcceptTexts === "object" && Object.keys(dObj.blankAcceptTexts).length > 0;
    if (!hasTexts) {
      missingFields.push("blankAcceptTexts");
      add("INGESTION_BLANK_KEY_REQUIRED", "Completion question requires non-empty 'blankAcceptTexts' dictionary.", "error", "invalid-input", "Provide blankAcceptTexts mapping blank IDs (e.g. '1') to accepted answers array.");
      repairGuidance.push("Add blankAcceptTexts map: { '1': ['accepted text'] }.");
    }
    if (typeof dObj.promptMd === "string" && hasTexts) {
      const markers = [...dObj.promptMd.matchAll(/\[(\d+)\]/g)].map(m => m[1]);
      const keys = Object.keys(dObj.blankAcceptTexts as object);
      for (const k of keys) {
        if (!markers.includes(k) && !/\[(?:Diagram|Map):\s*[^\]]+\]/.test(dObj.promptMd)) {
          add("INGESTION_BLANK_MARKER_MISSING", `Prompt lacks [${k}] marker corresponding to blankAcceptTexts key.`, "error", "invalid-input", `Add [${k}] to promptMd.`);
          repairGuidance.push(`Add [${k}] placeholder in promptMd.`);
        }
      }
    }
  } else if (family === "matching") {
    const hasPairs = dObj.matchPairs && typeof dObj.matchPairs === "object" && Object.keys(dObj.matchPairs).length > 0;
    if (!hasPairs) {
      missingFields.push("matchPairs");
      add("INGESTION_MATCH_KEY_REQUIRED", "Matching question requires non-empty 'matchPairs' dictionary.", "error", "invalid-input", "Provide matchPairs: { targetId: [gradingKey, displayLabel] }.");
      repairGuidance.push("Add matchPairs mapping target IDs to [gradingKey, displayLabel].");
    }
  } else if (family === "short") {
    const hasShort = Array.isArray(dObj.shortAnswerAcceptTexts) && dObj.shortAnswerAcceptTexts.length > 0;
    if (!hasShort) {
      missingFields.push("shortAnswerAcceptTexts");
      add("INGESTION_SHORT_KEY_REQUIRED", "Short answer requires non-empty 'shortAnswerAcceptTexts' array.", "error", "invalid-input", "Provide shortAnswerAcceptTexts: ['accepted answer'].");
      repairGuidance.push("Add shortAnswerAcceptTexts array with accepted answers.");
    }
  } else if (family === "flow") {
    const hasOrder = Array.isArray(dObj.orderCorrects) && dObj.orderCorrects.length > 0;
    if (!hasOrder) {
      missingFields.push("orderCorrects");
      add("INGESTION_FLOW_ORDER_REQUIRED", "FLOW_CHART requires non-empty 'orderCorrects' array of slug keys.", "error", "invalid-input", "Provide orderCorrects with ordered slug strings.");
      repairGuidance.push("Add orderCorrects array with ordered step slug keys.");
    }
  }

  // Permissive means malformed drafts receive diagnostics, not exceptions or fabricated keys.
  // Full wire/semantic validation still gates eligibility; this is not an actual ingestion receipt.
  issues.push(...schemaIssues(questionSchema, input));
  if (Value.Check(questionSchema, input)) issues.push(...validateQuestion(input as Question, path));
  const validForIngestion = issues.every(i => i.severity !== "error") && missingFields.length === 0;
  return {
    status: issues.some(i => i.severity === "error") ? "FAIL" : "PASS",
    isDraft: true,
    diagnostics: issues,
    questionType: type,
    family,
    missingFields,
    presentFields,
    repairGuidance,
    validForIngestion,
  };
}
