import { readFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { Type, type TSchema } from "typebox";
import { Value } from "typebox/value";
import { answerSlots, diagnostic as d, families, report, type Diagnostic, type Kind, type Profile, type Question, type Exam, examSchema, groupSchema, sectionSchema } from "./contracts.ts";
import { validateExam, validateGroup, validateQuestion } from "./validation.ts";
import { schemaIssues } from "./diagnostics.ts";
import { choiceTextIdentity, hasRegex } from "./grading.ts";

// Execute the normative Draft 2020-12 schema, not a second hand-written approximation.
const source = readFileSync(new URL("../contracts/question-types.v1.schema.json", import.meta.url), "utf8");
export const canonicalSchema = JSON.parse(source);
export const contractVersion = canonicalSchema["x-langfens"].contractVersion as string;
export const contractSha256 = createHash("sha256").update(source).digest("hex");
export type CanonicalQuestion = Omit<Question, "modelAnswers"> & { sectionId: string; skill: "READING" | "LISTENING"; difficulty: number };
export type RuleContext = { instructionMd?: string; profile?: Profile };
type Rule = (q: CanonicalQuestion, context: RuleContext) => Diagnostic[];
const same = (a: string[], b: string[]) => JSON.stringify([...a].sort()) === JSON.stringify([...b].sort());
const dup = (a: string[]) => new Set(a).size !== a.length;
const uncertain = (code: string, message: string) => [d(code, "/question", message, "warning", "semantic-uncertainty", "Supply hash-bound independent/consumer evidence; do not repair by guessing.")];
const unsupported = (code: string, message: string) => [d(code, "/question", `BLOCKED: ${message}`, "error", "unsupported-capability", "Stop automated repair; request a separately authorized capability change.")];
const targets = (q: CanonicalQuestion) => [...q.promptMd.matchAll(/^\s*([1-9]\d*)\.\s+(.+)$/gm)].map(m => [m[1], m[2].trim()]);
const bank = (q: CanonicalQuestion) => q.options.map(o => /^([A-Z]|[ivxlcdm]+)\.\s+(.+)$/.exec(o.contentMd));
const used = (q: CanonicalQuestion) => Object.values(q.matchPairs ?? {}).map(p => p[0]);
const selectionCount = (text: string) => {
  const m = /\bchoose\s+(ONE|TWO|THREE|FOUR|FIVE|\d+)\b/i.exec(text);
  return m ? ({ ONE: 1, TWO: 2, THREE: 3, FOUR: 4, FIVE: 5 }[m[1].toUpperCase()] ?? Number(m[1])) : undefined;
};
const reuse = (q: CanonicalQuestion, ctx: RuleContext) => {
  const text = `${ctx.instructionMd ?? ""}\n${q.promptMd}`;
  const allowed = /(?:may|can)\s+(?:use|choose)[^.\n]*more than once/i.test(text) && !/(?:may|can)\s+not\s+(?:use|choose)/i.test(text);
  if (!allowed && dup(used(q))) return [d("REUSE_INSTRUCTION_MISMATCH", "/promptMd", "Repeated keys require explicit reuse permission.")];
  // Permission never requires actual repetition.
  return [];
};
export const semanticRules: Record<string, Rule> = {
  COMMON(q) {
    const ds: Diagnostic[] = [];
    if (dup(q.options.map(o => o.id.toLowerCase()))) ds.push(d("IDENTITY_DUPLICATE", "/options", "Option IDs must be unique, case-insensitively."));
    if ([...q.options].sort((a,b) => a.idx-b.idx).some((o,i) => o.idx !== i+1)) ds.push(d("OPTION_INDEX_COVERAGE", "/options", "Option indices must cover 1..N."));
    return ds;
  },
  CHOICE(q) {
    return dup(q.options.map(o => choiceTextIdentity(o.contentMd))) ? [d("OPTION_CONTENT_DUPLICATE", "/options", "Option texts collide under the .NET text fallback comparison.")] : [];
  },
  MULTIPLE_SELECTION_COUNT(q, ctx) {
    return selectionCount(`${ctx.instructionMd ?? ""}\n${q.promptMd}`) === q.options.filter(o => o.isCorrect).length ? [] : [d("CHOICE_COUNT_INSTRUCTION_MISMATCH", "/promptMd", "Explicit choose-count must equal the keyed selection count.")];
  },
  TRUTH_EVIDENCE: () => uncertain("TRUTH_EVIDENCE_UNVERIFIED", "Fact/view distinction and Not Given absence require independent passage-based review."),
  BLANKS(q, ctx) {
    const ds: Diagnostic[] = [], keys = Object.keys(q.blankAcceptTexts ?? {}), regex = Object.keys(q.blankAcceptRegex ?? {});
    const markers = [...q.promptMd.matchAll(/\[([1-9]\d*)\]/g)].map(m => m[1]);
    if (!same(markers, keys) || dup(markers)) ds.push(d("BLANK_MARKER_KEY_MISMATCH", "/promptMd", "Explicit [N] markers must occur once and equal text keys, including diagram/map tasks."));
    if (/_{2,}|\[\s+\d+\s*\]|\[\d+\s+\]|blank-q/i.test(q.promptMd)) ds.push(d("BLANK_MARKER_NONCANONICAL", "/promptMd", "Decorative underscores, padded markers and blank-q prefixes are not canonical inputs."));
    if (regex.some(k => !keys.includes(k))) ds.push(d("REGEX_KEY_WITHOUT_TEXT", "/blankAcceptRegex", "Every regex key also requires accepted text."));
    if (keys.some(k => BigInt(k) > 9223372036854775807n)) ds.push(d("BLANK_KEY_OVERFLOW", "/blankAcceptTexts", "Blank IDs must fit signed Int64."));
    if (!/\b(?:ONE|TWO|THREE|FOUR|FIVE|\d+)\s+WORDS?\b/i.test(`${ctx.instructionMd ?? ""}\n${q.promptMd}`)) ds.push(d("WORD_LIMIT_MISSING", "/promptMd", "State an explicit answer word/number limit in the question or containing group."));
    ds.push(...uncertain("WORD_LIMIT_COUNTING_UNVERIFIED", "Accepted-answer word/number counting requires a separately tested counting profile; no universal tokenizer is assumed."));
    return ds;
  },
  COMPLETION_LAYOUT(q) {
    const bad = q.type === "TABLE_COMPLETION" ? !/\|[^\n]*\|\s*\n\s*\|?\s*:?-{3,}/.test(q.promptMd) : q.type === "NOTE_COMPLETION" ? !/^\s*[-*]\s+/m.test(q.promptMd) : q.type === "FORM_COMPLETION" ? !/^\s*[^:\n]+:\s*.+/m.test(q.promptMd) : false;
    return [...(bad ? [d("COMPLETION_LAYOUT_INVALID", "/promptMd", "Use the declared table, note or form layout.")] : []), ...uncertain("COMPLETION_RENDERING_UNVERIFIED", "Input reachability and coherent summary/sentence rendering require actual renderer evidence.")];
  },
  REGEX(q) { return hasRegex(q) ? unsupported("DOTNET_REGEX_PARITY_UNVERIFIED", "Regex-bearing artifacts require actual bounded .NET engine evidence.") : []; },
  SHORT_INPUT: () => uncertain("SHORT_INPUT_UNVERIFIED", "A marker-free short answer needs one reachable frontend input; schema cannot prove it."),
  MEDIA: () => uncertain("MEDIA_ASSET_UNVERIFIED", "Asset provenance, licensing, accessibility and actual propagation/renderability are unverified."),
  LABEL_ALIGNMENT: () => uncertain("LABEL_ALIGNMENT_UNVERIFIED", "Explicit markers are checked; actual image callout alignment needs supplied media and consumer evidence."),
  MATCHING_TARGETS(q) {
    const ts = targets(q);
    return same(ts.map(t => t[0]), Object.keys(q.matchPairs ?? {})) && !dup(ts.map(t => t[0])) ? [] : [d("MATCH_TARGET_KEY_MISMATCH", "/promptMd", "Visible numbered targets must equal matchPairs keys; never shift statement IDs.")];
  },
  MATCHING_BANK(q) {
    const ds: Diagnostic[] = [], bs = bank(q), labels = bs.map(b => b?.[1] ?? ""), pairs = Object.values(q.matchPairs ?? {});
    if (bs.some(b => !b) || dup(labels)) ds.push(d("MATCH_BANK_LABEL_DUPLICATE", "/options", "Use distinct parseable Roman/letter bank labels."));
    if (used(q).some(k => !labels.includes(k))) ds.push(d("MATCH_BANK_KEY_UNKNOWN", "/matchPairs", "Each grading key must identify a public bank label."));
    if (q.type !== "CLASSIFICATION" && !labels.some(k => !used(q).includes(k))) ds.push(d("MATCH_DISTRACTOR_MISSING", "/options", "New MATCHING_* authoring needs an unused distractor."));
    for (const [k, p] of Object.entries(q.matchPairs ?? {})) {
      const expected = q.type === "MATCHING_HEADING" ? bs.find(b => b?.[1] === p[0])?.[2] : targets(q).find(t => t[0] === k)?.[1];
      if (p[1] !== expected) ds.push(d("MATCH_DISPLAY_INVALID", `/matchPairs/${k}`, "Display label must equal the heading text or visible target text, according to type."));
    }
    if (pairs.length) ds.push(d("MATCHING_DISPLAY_TEXT_ACCEPTED", "/matchPairs", "Current .NET grader also accepts display text, not just bank keys.", "warning"));
    return ds;
  },
  HEADING(q) {
    return [...(!/List of Headings:/i.test(q.promptMd) || bank(q).some(b => !b || !/^[ivxlcdm]+$/.test(b[1])) || q.options.some(o => !q.promptMd.includes(o.contentMd)) ? [d("HEADING_BANK_MISSING", "/promptMd", "List the complete Roman-labeled heading bank under List of Headings:.")] : []), ...(dup(used(q)) ? [d("HEADING_REUSED", "/matchPairs", "Headings cannot be reused.")] : [])];
  },
  INFORMATION(q, ctx) {
    const ds = reuse(q, ctx);
    if (q.options.some(o => !/^([A-Z])\. Paragraph \1$/.test(o.contentMd))) ds.push(d("PARAGRAPH_BANK_INVALID", "/options", "Information matching uses A. Paragraph A, etc."));
    if (!/more than once|only once|not.+reuse|not.+more than once/i.test(`${ctx.instructionMd ?? ""}\n${q.promptMd}`)) ds.push(d("REUSE_POLICY_MISSING", "/promptMd", "State whether letters may be reused."));
    if (q.wordList) ds.push(...unsupported("WORD_BANK_UNSUPPORTED", "Current admin/proto wordList propagation is unsupported; never convert paragraph matching into completion."));
    return ds;
  },
  FEATURES(q, ctx) { return [...reuse(q, ctx), ...uncertain("FEATURE_SEMANTICS_UNVERIFIED", "Feature/passage relationships require independent review.")]; },
  ENDINGS(q) { return [...(dup(used(q)) ? [d("ENDING_REUSED", "/matchPairs", "Sentence endings cannot be reused.")] : []), ...uncertain("ENDING_SENTENCE_UNVERIFIED", "Grammar and factual support of each completed sentence need independent review.")]; },
  CLASSIFICATION_KEYS(q) { return bank(q).some(b => !b || !/^[A-Z]$/.test(b[1])) ? [d("CLASSIFICATION_CATEGORY_UNPARSED", "/options", "Use A. label category lines; preserve exact statement IDs.")] : []; },
  FLOW_ORDERING(q) {
    const norm = (k: string) => k.toLowerCase().replace(/-/g, " ").replace(/[^a-z0-9\s]/g, " ").replace(/\s+/g, " ").trim();
    const order = q.orderCorrects ?? [];
    const positions = order.map(k => q.promptMd.indexOf(k));
    const explicitLeak = /\b(?:correct order|answer sequence)\s*:/i.test(q.promptMd) && positions.every((p,i) => p >= 0 && (i === 0 || p > positions[i-1]));
    return [...(dup(order.map(norm)) ? [d("FLOW_NODE_KEY_COLLISION", "/orderCorrects", "Flow keys collide under backend NormNode.")] : []), ...(explicitLeak ? [d("FLOW_ORDER_LEAK", "/promptMd", "Prompt explicitly discloses the keyed correct sequence.")] : []), ...uncertain("FLOW_ORDER_PRIVACY_UNVERIFIED", "Public nodes must be independent of solution order; other answer hints require review. Standard IELTS blank flow completion remains BLOCKED.")];
  },
  PROJECTION: () => uncertain("PROJECTION_CONSUMER_UNVERIFIED", "Allowlisted domain projection cannot certify actual student HTTP/proto snapshots or encoded answer hints."),
  SUBMISSION: () => uncertain("SUBMISSION_ROUNDTRIP_UNVERIFIED", "Actual persisted UUID mapping, renderer actions, restore/clear/autosave and .NET ingestion need consumer evidence."),
  COMPATIBILITY: () => uncertain("SCHEMA_VALIDITY_ONLY", "Structural/semantic-shape PASS is not frontend rendering, .NET grading, pedagogical quality or production readiness."),
};

export const canonicalValidators = Object.fromEntries(Object.keys(families).map(type => {
  const schema = { $schema: canonicalSchema.$schema, $defs: canonicalSchema.$defs, $ref: `#/$defs/${type}` } as TSchema;
  return [type, {
    schema,
    rules: canonicalSchema["x-langfens"].registry[type].rules as string[],
    validate(input: unknown, context: RuleContext = {}) {
      const structural = schemaIssues(schema, input);
      if (structural.length) return structural;
      const q = input as CanonicalQuestion;
      const ds: Diagnostic[] = this.rules.flatMap(rule => semanticRules[rule](q, context));
      if (context.profile === "strict-academic") {
        if (q.skill !== "READING") ds.push(d("ACADEMIC_SKILL_INVALID", "/skill", "Strict Academic Reading requires READING."));
        ds.push(...validateQuestion(q, "/question", "strict-academic").filter(x => x.code.startsWith("ACADEMIC_")));
      }
      return ds;
    },
  }];
})) as Record<Kind, { schema: TSchema; rules: string[]; validate(input: unknown, context?: RuleContext): Diagnostic[] }>;

export function validateCanonicalQuestion(input: unknown, context: RuleContext = {}) {
  const type = input && typeof input === "object" ? (input as { type?: unknown }).type : undefined;
  const validator = typeof type === "string" && Object.hasOwn(canonicalValidators, type) ? canonicalValidators[type as Kind] : undefined;
  const diagnostics = validator ? validator.validate(input, context) : [d("QUESTION_TYPE_UNKNOWN", "/type", "Declare one of the 19 exact literals; no fallback or conversion.")];
  return report(diagnostics, { contractVersion, contractSha256, structuralStatus: validator && Value.Check(validator.schema, input) ? "PASS" : "FAIL", capabilityStatus: diagnostics.some(x => x.category === "unsupported-capability" && x.severity === "error") ? "BLOCKED" : "UNVERIFIED", compatibility: "UNVERIFIED", ieltsQualityEstablished: false, frontendVerified: false, dotnetVerified: false });
}

// Group-first container profile adds membership/order invariants without changing v1's Question definition.
export const canonicalGroupSchema = Type.Object({ ...groupSchema.properties, questions: Type.Array(canonicalSchema as TSchema) }, { additionalProperties: false });
const canonicalSectionSchema = Type.Object({ ...sectionSchema.properties, questionGroups: Type.Array(canonicalGroupSchema) }, { additionalProperties: false });
export const canonicalExamSchema = Type.Object({ ...examSchema.properties, sections: Type.Array(canonicalSectionSchema) }, { additionalProperties: false });
export function validateCanonicalGroup(input: unknown, profile: Profile = "platform-reference") {
  const structural = schemaIssues(canonicalGroupSchema, input);
  if (structural.length) return report(structural, { contractVersion, contractSha256, compatibility: "UNVERIFIED" });
  const g = input as import("./contracts.ts").Group;
  const diagnostics = validateGroup(g, "/group", profile);
  for (const q of g.questions) {
    diagnostics.push(...validateCanonicalQuestion(q, { instructionMd: g.instructionMd, profile }).diagnostics);
    if ((q as CanonicalQuestion).sectionId !== g.sectionId) diagnostics.push(d("MEMBERSHIP_INVALID", "/group", "Question sectionId must equal its containing Group sectionId."));
  }
  return report(diagnostics, { contractVersion, contractSha256, compatibility: "UNVERIFIED", questionCount: g.questions.length, scoringUnitCount: g.questions.length, answerSlotCount: g.questions.reduce((n,q) => n + answerSlots(q), 0) });
}
export function validateCanonicalExam(input: unknown, complete: boolean, profile: Profile = "platform-reference") {
  const structural = schemaIssues(canonicalExamSchema, input);
  if (structural.length) return report(structural, { contractVersion, contractSha256, compatibility: "UNVERIFIED" });
  const exam = input as Exam;
  const diagnostics = validateExam(exam, complete && profile === "strict-academic", { profile });
  for (const s of exam.sections) for (const g of s.questionGroups) for (const q of g.questions) {
    diagnostics.push(...validateCanonicalQuestion(q, { instructionMd: g.instructionMd, profile }).diagnostics.map(x => ({ ...x, path: `/sections/${s.idx - 1}/questionGroups/${g.idx - 1}/questions/${q.idx - g.startIdx}${x.path}` })));
    if ((q as CanonicalQuestion).sectionId !== s.id) diagnostics.push(d("MEMBERSHIP_INVALID", "/sections", "Question sectionId must equal its containing Section."));
  }
  const qs = exam.sections.flatMap(s => s.questionGroups.flatMap(g => g.questions));
  return report(diagnostics, { contractVersion, contractSha256, questionCount: qs.length, scoringUnitCount: qs.length, answerSlotCount: qs.reduce((n,q) => n + answerSlots(q), 0), intendedMarkCount: profile === "strict-academic" && qs.every(q => answerSlots(q) === 1) ? qs.length : null, compatibility: "UNVERIFIED", ieltsQualityEstablished: false });
}
