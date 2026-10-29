import { Type, type Static } from "typebox";

// Pinned to Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs.
// A source-contract regression test rejects drift in either the names or grader families.
export const families = {
  MULTIPLE_CHOICE_SINGLE: "single", MULTIPLE_CHOICE_MULTIPLE: "multiple",
  TRUE_FALSE_NOT_GIVEN: "single", YES_NO_NOT_GIVEN: "single", MULTIPLE_CHOICE_SINGLE_IMAGE: "single",
  SUMMARY_COMPLETION: "completion", TABLE_COMPLETION: "completion", NOTE_COMPLETION: "completion",
  FORM_COMPLETION: "completion", SENTENCE_COMPLETION: "completion", SHORT_ANSWER: "short",
  DIAGRAM_LABEL: "completion", MAP_LABEL: "completion", MATCHING_HEADING: "matching",
  MATCHING_INFORMATION: "matching", MATCHING_FEATURES: "matching", MATCHING_ENDINGS: "matching",
  CLASSIFICATION: "matching", FLOW_CHART: "flow",
} as const;
export type Kind = keyof typeof families;
export const kindSchema = Type.Union(Object.keys(families).map(k => Type.Literal(k as Kind)));
const text = Type.String();
const id = Type.String({ minLength: 1 });
const idx = Type.Integer({ minimum: 1 });
export const strings = Type.Array(text);
export const mapSchema = Type.Record(Type.String(), strings);
const objectOptions = { additionalProperties: false } as const;
export const optionSchema = Type.Object({
  id, idx, contentMd: text, isCorrect: Type.Boolean(),
  imageUrl: Type.Optional(text), altText: Type.Optional(text),
}, objectOptions);
export const questionSchema = Type.Object({
  id, groupId: id, idx, type: kindSchema, promptMd: text, options: Type.Array(optionSchema),
  explanationMd: Type.Optional(text), imageUrl: Type.Optional(text), wordList: Type.Optional(strings),
  blankAcceptTexts: Type.Optional(mapSchema), blankAcceptRegex: Type.Optional(mapSchema),
  matchPairs: Type.Optional(mapSchema), orderCorrects: Type.Optional(strings),
  shortAnswerAcceptTexts: Type.Optional(strings), shortAnswerAcceptRegex: Type.Optional(strings),
  modelAnswers: Type.Optional(strings),
}, objectOptions);
export const groupSchema = Type.Object({
  id, sectionId: id, idx, startIdx: idx, endIdx: idx, instructionMd: text,
  questions: Type.Array(questionSchema),
}, objectOptions);
export const sectionSchema = Type.Object({
  id, examId: id, idx, title: text, passageMd: text, questionGroups: Type.Array(groupSchema),
}, objectOptions);
export const examSchema = Type.Object({ id, title: text, sections: Type.Array(sectionSchema) }, objectOptions);
export const answerSchema = Type.Object({
  selectedOptionIds: Type.Optional(strings), textAnswer: Type.Optional(text),
}, objectOptions);
export type Question = Static<typeof questionSchema>;
export type Group = Static<typeof groupSchema>;
export type Exam = Static<typeof examSchema>;
export type Answer = Static<typeof answerSchema>;
export type DiagnosticCategory = "invalid-input" | "unsupported-capability" | "semantic-uncertainty";
export type Diagnostic = {
  code: string;
  severity: "error" | "warning";
  path: string;
  message: string;
  category?: DiagnosticCategory;
  repairGuidance?: string;
};
export function diagnostic(
  code: string,
  path: string,
  message: string,
  severity: Diagnostic["severity"] = "error",
  category?: DiagnosticCategory,
  repairGuidance?: string
): Diagnostic {
  if (!category) {
    if (code.includes("UNSUPPORTED") || code.includes("PARITY_REGEX_UNSUPPORTED") || code.includes("BLOCKED") || code.includes("ACADEMIC_TYPE_UNSUPPORTED") || code.includes("ACADEMIC_MULTI_SLOT_UNSUPPORTED")) {
      category = "unsupported-capability";
    } else if (code.includes("SEMANTIC") || code.includes("UNCERTAIN") || code.includes("REVIEW") || code.includes("TRUTH_EVIDENCE") || code.includes("QUALITY")) {
      category = "semantic-uncertainty";
    } else {
      category = "invalid-input";
    }
  }
  return { code, severity, path, message, category, ...(repairGuidance ? { repairGuidance } : {}) };
}
export function report<T extends object = Record<never, never>>(diagnostics: Diagnostic[], extra: T = {} as T) {
  return { status: diagnostics.some(d => d.severity === "error") ? "FAIL" : "PASS", diagnostics, ...extra };
}
function int64(value: string): bigint | undefined {
  if (!/^[+-]?\d+$/.test(value)) return undefined;
  const n = BigInt(value);
  return n >= -9223372036854775808n && n <= 9223372036854775807n ? n : undefined;
}
export const sortedKeys = (m: Record<string, unknown>) => Object.keys(m).sort((a, b) => {
  const x = int64(a), y = int64(b);
  // GraderScoring.SortedUnionKeys uses Int64, then ordinal (not locale) fallback.
  return x !== undefined && y !== undefined ? (x < y ? -1 : x > y ? 1 : 0) : a < b ? -1 : a > b ? 1 : 0;
});
export function answerSlots(q: Question): number {
  switch (families[q.type]) {
    case "completion": return new Set([...Object.keys(q.blankAcceptTexts ?? {}), ...Object.keys(q.blankAcceptRegex ?? {})]).size;
    case "matching": return Object.keys(q.matchPairs ?? {}).length;
    case "multiple": return q.options.filter(o => o.isCorrect).length;
    case "flow": return (q.orderCorrects ?? []).length;
    default: return 1;
  }
}
export function counts(groups: Group[]) {
  const qs = groups.flatMap(g => g.questions);
  return { questionCount: qs.length, answerSlotCount: qs.reduce((n, q) => n + answerSlots(q), 0), scoringUnitCount: qs.length, questionGroupCount: groups.length };
}
export type Profile = "platform-reference" | "strict-academic";
export const ACADEMIC_READING_SUPPORTED_TYPES = new Set<Kind>([
  "MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_MULTIPLE", "TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN",
  "SUMMARY_COMPLETION", "TABLE_COMPLETION", "NOTE_COMPLETION", "SENTENCE_COMPLETION", "SHORT_ANSWER",
  "DIAGRAM_LABEL", "MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS",
  "CLASSIFICATION",
]);
export const PLATFORM_ONLY_TYPES = new Set<Kind>([
  "MULTIPLE_CHOICE_SINGLE_IMAGE", "MAP_LABEL", "FORM_COMPLETION", "FLOW_CHART",
]);
export function spec(type: Kind) {
  const family = families[type];
  const formats = {
    single: "selectedOptionIds: [option UUID]; legacy text UUID/content fallback",
    multiple: "selectedOptionIds: exact set of correct option UUIDs; duplicates collapse",
    completion: "textAnswer: JSON object keyed by numeric blank IDs; plaintext/newline positional fallback",
    matching: "textAnswer: JSON object of leftKey -> rightValue; plaintext only for a single pair",
    short: "textAnswer: plain text",
    flow: 'textAnswer: JSON array of node keys; legacy JS oracle models case-sensitive Steps/Labels; current dirty .NET source accepts lowercase (separate fixture evidence)',
  };
  const isPlatformOnly = PLATFORM_ONLY_TYPES.has(type);
  return {
    type, family, answerFormat: formats[family], scoring: "all-or-nothing per Question (one independent scoring unit)",
    requiredKey: { single: "options.isCorrect (exactly one)", multiple: "options.isCorrect (at least two)", completion: "blankAcceptTexts plus optional blankAcceptRegex", matching: "matchPairs: leftKey -> [gradingKey, displayText]", short: "shortAnswerAcceptTexts plus optional shortAnswerAcceptRegex", flow: "orderCorrects: lowercase slug array; ingestion forbids labels" }[family],
    ieltsCorrectness: family === "flow" ? "INCOMPATIBLE_STANDARD_FLOW_COMPLETION" : "REQUIRES_INDEPENDENT_SEMANTIC_REVIEW",
    platformOnly: isPlatformOnly,
    academicReadingStatus: isPlatformOnly ? "BLOCKED_BY_SELECTED_ACADEMIC_PROFILE" : "ACADEMIC_CANDIDATE_REQUIRES_SLOT_AND_CONSUMER_GATES",
    ...(family === "flow" ? { unsupportedCapability: "BLOCKED: Standard IELTS flow-chart blank completion is unsupported on the current platform ordering contract." } : {}),
  };
}
