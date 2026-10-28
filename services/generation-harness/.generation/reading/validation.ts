import { answerSlots, counts, diagnostic as d, families, type Diagnostic, type Exam, type Group, type Question } from "./contracts.js";
const hasText = (xs?: string[]) => xs?.some(x => x.trim().length > 0) ?? false;
const populated = (m?: Record<string, string[]>) => Object.values(m ?? {}).some(hasText);
function duplicates(xs: (string | number)[]) { return new Set(xs).size !== xs.length; }
function contiguous(xs: number[], first: number) { return [...xs].sort((a, b) => a - b).every((x, i) => x === first + i); }
export function validateQuestion(q: Question, path = "question"): Diagnostic[] {
  const issues: Diagnostic[] = [];
  const add = (code: string, message: string, severity: Diagnostic["severity"] = "error") => issues.push(d(code, path, message, severity));
  const family = families[q.type];
  if (!family) { add("QUESTION_TYPE_UNKNOWN", "Unknown shared contract question type."); return issues; }
  if (!q.promptMd.trim()) add("PROMPT_EMPTY", "A student-visible prompt is required.");
  if (duplicates(q.options.map(o => o.idx)) || duplicates(q.options.map(o => o.id))) add("OPTION_DUPLICATE", "Option IDs and indices must be unique.");
  if (!contiguous(q.options.map(o => o.idx), 1)) add("OPTION_INDEX_COVERAGE", "Option indices must cover 1..N.");
  if (q.options.some(o => !o.contentMd.trim())) add("OPTION_CONTENT_EMPTY", "Option content is required.");
  const correct = q.options.filter(o => o.isCorrect).length;
  if (family === "single" && correct !== 1) add("CHOICE_KEY_COUNT", "Exactly one correct option is required.");
  if (family === "multiple" && correct < 2) add("CHOICE_KEY_COUNT", "Multiple choice requires at least two correct options.");
  if ((family === "single" || family === "multiple") && q.options.length < 2) add("CHOICE_OPTIONS_MISSING", "At least two options are required.");
  if ((q.type === "TRUE_FALSE_NOT_GIVEN" || q.type === "YES_NO_NOT_GIVEN") &&
      JSON.stringify(q.options.map(o => o.contentMd.trim().toUpperCase()).sort()) !== JSON.stringify((q.type === "TRUE_FALSE_NOT_GIVEN" ? ["TRUE", "FALSE", "NOT GIVEN"] : ["YES", "NO", "NOT GIVEN"]).sort())) {
    add("IELTS_TRUTH_OPTIONS", "Truth questions require their three canonical student choices.");
  }
  if (q.type === "MULTIPLE_CHOICE_SINGLE_IMAGE" && !q.imageUrl?.trim()) add("IMAGE_REQUIRED", "Image question requires a student-visible image.");
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
    add("FLOW_OBJECT_CASE_MISMATCH", "Default System.Text.Json parsing expects Steps/Labels; lowercase steps/labels does not grade.", "warning");
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
export function validateGroup(g: Group, path = "group"): Diagnostic[] {
  const issues = g.questions.flatMap((q, i) => validateQuestion(q, `${path}.questions[${i}]`));
  if (!g.instructionMd.trim()) issues.push(d("GROUP_INSTRUCTION_EMPTY", path, "Student instructions are required."));
  if (!g.questions.length) issues.push(d("GROUP_EMPTY", path, "A group must contain questions."));
  if (g.endIdx < g.startIdx || g.endIdx - g.startIdx + 1 !== g.questions.length || !contiguous(g.questions.map(q => q.idx), g.startIdx)) issues.push(d("GROUP_INDEX_COVERAGE", path, "Group bounds must exactly cover its question indices."));
  if (duplicates(g.questions.map(q => q.id))) issues.push(d("QUESTION_DUPLICATE", path, "Question IDs must be unique."));
  if (g.questions.some(q => q.groupId !== g.id)) issues.push(d("QUESTION_GROUP_MEMBERSHIP", path, "Every question must belong to its containing group."));
  return issues;
}
export function validateExam(exam: Exam, complete: boolean): Diagnostic[] {
  const issues: Diagnostic[] = [];
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
    for (const [j, g] of s.questionGroups.entries()) {
      if (g.sectionId !== s.id) issues.push(d("GROUP_SECTION_MEMBERSHIP", `${path}.questionGroups[${j}]`, "Group belongs to another section."));
      issues.push(...validateGroup(g, `${path}.questionGroups[${j}]`));
    }
  }
  if (duplicates(groups.map(g => g.id))) issues.push(d("GROUP_DUPLICATE", "exam", "Group IDs must be paper-wide unique."));
  if (duplicates(qs.map(q => q.id))) issues.push(d("QUESTION_DUPLICATE", "exam", "Question IDs must be paper-wide unique."));
  const ordered = [...exam.sections].sort((a, b) => a.idx - b.idx).flatMap(s => [...s.questionGroups].sort((a, b) => a.idx - b.idx)).flatMap(g => [...g.questions].sort((a, b) => a.idx - b.idx));
  if (ordered.some((q, i) => q.idx !== i + 1)) issues.push(d("PAPER_INDEX_COVERAGE", "exam", "Delivery order requires paper-wide question indices 1..N, not section-local indices."));
  if (complete && counts(groups).scoringUnitCount !== 40) issues.push(d("PAPER_SCORING_UNIT_COUNT", "exam", "A complete paper requires exactly 40 independent scoring units, not 40 answer slots."));
  if (complete && exam.sections.length !== 3) issues.push(d("ACADEMIC_SECTION_COUNT", "exam", "A complete Academic Reading paper requires three sections."));
  return issues;
}
