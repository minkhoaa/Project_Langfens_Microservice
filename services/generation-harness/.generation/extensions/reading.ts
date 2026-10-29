import { Type, type Static, type TSchema } from "typebox";
import { Value } from "typebox/value";
import type { ExtensionAPI, ToolDefinition } from "generation-harness-core";
import { answerSchema, answerSlots, counts, diagnostic as d, examSchema, groupSchema, kindSchema, questionSchema, report, spec, type Diagnostic, type Group, type Question } from "../reading/contracts.ts";
import { inspectDraft, validateExam, validateGroup, validateQuestion } from "../reading/validation.ts";
import { grade, hasRegex } from "../reading/grading.ts";
import { privatePaths, stableJson, studentProjection, validateProjectionCandidate } from "../reading/projection.ts";
import { formatTypeBoxErrors } from "../reading/diagnostics.ts";
import { validateCanonicalQuestion, validateCanonicalGroup, validateCanonicalExam } from "../reading/canonical.ts";
import { QuestionRepairPolicy } from "../reading/repair-policy.ts";

const strict = { additionalProperties: false } as const;
const duplicates = (xs: (string | number)[]) => new Set(xs).size !== xs.length;
const contiguous = (xs: number[], first: number) => [...xs].sort((a, b) => a - b).every((x, i) => x === first + i);
const evidenceSchema = Type.Object({ questionId: Type.String(), start: Type.Integer({ minimum: 0 }), end: Type.Integer({ minimum: 1 }), quote: Type.String({ minLength: 1 }) }, strict);
const reviewSchema = Type.Object({ reviewerId: Type.String({ minLength: 1 }), questionIds: Type.Array(Type.String()), verdict: Type.Union([Type.Literal("PASS"), Type.Literal("FAIL")]), rationale: Type.String({ minLength: 1 }), mocked: Type.Boolean() }, strict);
const parityCase = Type.Object({ id: Type.String({ minLength: 1 }), answer: answerSchema, expectedCorrect: Type.Boolean() }, strict);
const evidenceInput = Type.Object({
  passageMd: Type.Optional(Type.String()), group: Type.Optional(groupSchema), groups: Type.Optional(Type.Array(groupSchema)),
  exam: Type.Optional(examSchema), sectionId: Type.Optional(Type.String({ minLength: 1 })), evidence: Type.Array(evidenceSchema),
  blindSolverId: Type.String({ minLength: 1 }), semanticReviews: Type.Array(reviewSchema),
}, strict);
function verifyEvidence(input: Static<typeof evidenceInput>) {
  const { passageMd, group, groups, exam, sectionId, evidence, blindSolverId, semanticReviews } = input;
  const diagnostics: Diagnostic[] = [];

  const targetCount = (group !== undefined ? 1 : 0) + (groups !== undefined ? 1 : 0) + (exam !== undefined ? 1 : 0);
  if (targetCount === 0) {
    diagnostics.push(d("TARGET_MISSING", "target", "Exactly one target (group, groups, or exam) must be provided."));
    return report(diagnostics, { evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
  }
  if (targetCount > 1) {
    diagnostics.push(d("TARGET_AMBIGUOUS", "target", "Multiple targets provided; supply exactly one of group, groups, or exam."));
    return report(diagnostics, { evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
  }

  if (sectionId !== undefined && exam === undefined) {
    diagnostics.push(d("EVIDENCE_SECTION_TARGET_INVALID", "sectionId", "A section selector requires its canonical exam."));
    return report(diagnostics);
  }

  let effectivePassage = "";
  let targetGroups: Group[] = [];

  if (exam !== undefined) {
    diagnostics.push(...validateExam(exam, false));
    if (!exam.sections.length) {
      diagnostics.push(d("EXAM_EMPTY", "exam.sections", "Exam must contain sections."));
      return report(diagnostics, { evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
    }
    if (exam.sections.length > 1 && sectionId === undefined) {
      diagnostics.push(d("EVIDENCE_MULTI_SECTION_UNSUPPORTED", "exam.sections", "Verify independently per section: select sectionId from the canonical exam."));
      return report(diagnostics, { evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
    }
    const section = sectionId === undefined ? exam.sections[0] : exam.sections.find(s => s.id === sectionId);
    if (!section) return report([...diagnostics, d("EVIDENCE_SECTION_UNKNOWN", "sectionId", "Selected section does not belong to the canonical exam.")]);
    effectivePassage = section.passageMd ?? "";
    if (!effectivePassage.trim()) {
      diagnostics.push(d("PASSAGE_EMPTY", "exam.sections[0].passageMd", "Academic Reading section requires passage content."));
    }
    if (passageMd !== undefined && passageMd !== effectivePassage) {
      diagnostics.push(d("PASSAGE_MISMATCH", "passageMd", "Supplied passageMd does not match the canonical section passage."));
    }
    targetGroups = section.questionGroups;
  } else if (groups !== undefined) {
    effectivePassage = passageMd ?? "";
    if (!effectivePassage.trim()) {
      diagnostics.push(d("PASSAGE_EMPTY", "passageMd", "Academic Reading requires passage content."));
    }
    if (!groups.length) {
      diagnostics.push(d("GROUP_EMPTY", "groups", "At least one group must be provided."));
      return report(diagnostics, { evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
    }
    for (const [gIdx, g] of groups.entries()) {
      diagnostics.push(...validateGroup(g, `groups[${gIdx}]`));
    }
    const sectionIds = new Set(groups.map(g => g.sectionId));
    if (sectionIds.size > 1) {
      diagnostics.push(d("GROUP_SECTION_MEMBERSHIP", "groups", "All groups in groups mode must belong to the same section."));
    }
    if (duplicates(groups.map(g => g.id))) {
      diagnostics.push(d("GROUP_DUPLICATE", "groups", "Group IDs must be unique across groups."));
    }
    if (!contiguous(groups.map(g => g.idx), 1)) {
      diagnostics.push(d("GROUP_INDEX_ORDER", "groups", "Group indices must cover 1..N."));
    }
    const orderedGroups = [...groups].sort((a, b) => a.idx - b.idx);
    if (orderedGroups.some((g, i) => i > 0 && g.startIdx !== orderedGroups[i - 1].endIdx + 1)) {
      diagnostics.push(d("SECTION_GROUP_RANGE_CONTINUITY", "groups", "Group ranges must be consecutive and non-overlapping."));
    }
    const qs = groups.flatMap(g => g.questions);
    if (duplicates(qs.map(q => q.id))) {
      diagnostics.push(d("QUESTION_DUPLICATE", "groups", "Question IDs must be unique across groups."));
    }
    const opts = qs.flatMap(q => q.options);
    if (duplicates(opts.map(o => o.id.toLowerCase()))) {
      diagnostics.push(d("OPTION_DUPLICATE", "groups", "Option IDs must be unique across groups."));
    }
    targetGroups = groups;
  } else if (group !== undefined) {
    effectivePassage = passageMd ?? "";
    if (!effectivePassage.trim()) {
      diagnostics.push(d("PASSAGE_EMPTY", "passageMd", "Academic Reading requires passage content."));
    }
    diagnostics.push(...validateGroup(group, "group"));
    targetGroups = [group];
  }

  const allQuestions = targetGroups.flatMap(g => g.questions);
  const questionMap = new Map<string, Question>();
  for (const q of allQuestions) {
    if (questionMap.has(q.id)) {
      if (!diagnostics.some(diag => diag.code === "QUESTION_DUPLICATE")) {
        diagnostics.push(d("QUESTION_DUPLICATE", "questions", "Question IDs must be unique across groups."));
      }
    } else {
      questionMap.set(q.id, q);
    }
  }

  for (const [i, span] of evidence.entries()) {
    const path = `evidence[${i}]`;
    if (!questionMap.has(span.questionId)) {
      diagnostics.push(d("EVIDENCE_QUESTION_UNKNOWN", path, "Evidence references a question outside the group."));
    }
    if (span.start >= span.end || span.end > effectivePassage.length || effectivePassage.slice(span.start, span.end) !== span.quote) {
      diagnostics.push(d("EVIDENCE_SPAN_MISMATCH", path, "UTF-16 offsets and exact quotation must match the passage."));
    }
  }

  for (const q of allQuestions) {
    if (!evidence.some(e => e.questionId === q.id)) {
      diagnostics.push(d("EVIDENCE_MISSING", q.id, "Every question requires passage evidence (absence claims still require independent review)."));
    }
  }

  if (!semanticReviews.length) {
    diagnostics.push(d("SEMANTIC_REVIEW_MISSING", "semanticReviews", "Independent semantic-review input is required."));
  }
  const reviewers = new Set<string>();
  for (const [i, review] of semanticReviews.entries()) {
    const path = `semanticReviews[${i}]`;
    const reviewerId = review.reviewerId.trim().toLowerCase();
    if (!reviewerId || reviewerIdInvalid(review.reviewerId, blindSolverId) || reviewers.has(reviewerId)) {
      diagnostics.push(d("REVIEW_NOT_INDEPENDENT", path, "Review identities must be distinct from the blind solver and one another."));
    }
    reviewers.add(reviewerId);
    if (!review.rationale.trim() || review.verdict !== "PASS") {
      diagnostics.push(d("SEMANTIC_REVIEW_REJECTED", path, "Review did not approve with a substantive rationale."));
    }
    if (
      duplicates(review.questionIds) ||
      review.questionIds.length !== allQuestions.length ||
      review.questionIds.some(id => !questionMap.has(id))
    ) {
      diagnostics.push(d("SEMANTIC_REVIEW_COVERAGE", path, group !== undefined ? "Each independent review must cover exactly this group's questions." : "Each independent review must cover exactly the verified target's questions."));
    }
  }

  diagnostics.push(d("SEMANTIC_QUALITY_NOT_ESTABLISHED", "semanticReviews", "Span checks and supplied reviews do not prove IELTS correctness; mocked approvals are offline plumbing evidence only.", "warning"));
  return report(diagnostics, { ...counts(targetGroups), evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
}
function reviewerIdInvalid(reviewer: string, solver: string) { return reviewer.trim().toLowerCase() === solver.trim().toLowerCase(); }
function output(details: object) { return { content: [{ type: "text" as const, text: JSON.stringify(details) }], details }; }

/** Native extension only: no model/provider, coordinator, retries, or publication. */
export default function reading(api: ExtensionAPI) {
  const repairs = new QuestionRepairPolicy();
  api.on("session_start", (_event, ctx) => {
    repairs.clear();
    // Public session history restores validation budgets on resume. No hidden runtime or retry loop.
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.toolName === "validate_question") {
        const details = entry.message.details as { repairState?: import("../reading/repair-policy.ts").RepairState } | undefined;
        if (details?.repairState) repairs.restore(details.repairState);
      }
    }
  });
  api.on("session_shutdown", () => { repairs.clear(); });

  // Native validation deliberately coerces scalar values. The public pre-validation
  // hook enforces this domain's strict wire types before that conversion occurs.
  function register<T extends TSchema>(tool: ToolDefinition<T>) {
    api.registerTool({ ...tool, prepareArguments(args: unknown) {
      if (!Value.Check(tool.parameters, args)) {
        const details = formatTypeBoxErrors(tool.parameters, args);
        throw new Error(`INPUT_SCHEMA_INVALID: Arguments must exactly match the IELTS tool schema. Violations: ${details}. Repair guidance: Check required properties, field types, and strict object constraints against get_question_spec.`);
      }
      return args as Static<T>;
    } });
  }
  register({
    name: "get_question_spec", label: "Reading question specification", description: "Executable contract for one of the 19 shared .NET question types; backend compatibility is not IELTS correctness.",
    parameters: Type.Object({ type: kindSchema }, strict),
    async execute(_id, { type }) { return output(report([], { ...spec(type) })); },
  });
  register({
    name: "validate_question", label: "Validate Reading question", description: "Validate canonical question, admin ingestion and key completeness. Stronger canonical policy is distinguished from backend rules by diagnostic codes.",
    parameters: Type.Object({
      question: Type.Optional(questionSchema),
      draft: Type.Optional(Type.Unknown()),
      canonicalQuestion: Type.Optional(Type.Unknown()),
      instructionMd: Type.Optional(Type.String()),
      profile: Type.Optional(Type.Union([Type.Literal("platform-reference"), Type.Literal("strict-academic")])),
    }, strict),
    async execute(_id, { question, draft, canonicalQuestion, instructionMd, profile }) {
      if ([question, draft, canonicalQuestion].filter(x => x !== undefined).length !== 1) throw new Error("INPUT_SCHEMA_INVALID: Supply exactly one of question, draft, canonicalQuestion; expected one target, actual ambiguous/missing target. Repair guidance: Remove other targets.");
      if (draft !== undefined) return output(inspectDraft(draft));
      if (canonicalQuestion !== undefined) {
        const result = validateCanonicalQuestion(canonicalQuestion, { instructionMd, profile });
        const q = canonicalQuestion as Question;
        if (!q || typeof q !== "object" || typeof q.id !== "string" || typeof q.type !== "string" || !Number.isInteger(q.idx)) return output(result);
        const checked = repairs.check(q, result.diagnostics);
        return output({ ...result, ...report(checked.diagnostics), ...checked });
      }
      const checked = repairs.check(question!, validateQuestion(question!, "question", profile));
      return output(report(checked.diagnostics, { ...checked, questionCount: 1, answerSlotCount: answerSlots(question!), scoringUnitCount: 1, questionGroupCount: 0, compatibility: "UNVERIFIED", frontendVerified: false, dotnetVerified: false }));
    },
  });
  register({
    name: "validate_group", label: "Validate Reading group", description: "Check membership, exact bounds, keys and independent scoring units; groups do not require 40 questions.",
    parameters: Type.Object({ group: Type.Optional(groupSchema), canonicalGroup: Type.Optional(Type.Unknown()), profile: Type.Optional(Type.Union([Type.Literal("platform-reference"), Type.Literal("strict-academic")])) }, strict),
    async execute(_id, { group, canonicalGroup, profile }) {
      if ((group !== undefined) === (canonicalGroup !== undefined)) throw new Error("INPUT_SCHEMA_INVALID: Supply exactly one of group or canonicalGroup. Repair guidance: Select the intended representation.");
      if (canonicalGroup !== undefined) return output(validateCanonicalGroup(canonicalGroup, profile));
      return output(report(validateGroup(group!, "group", profile), counts([group!])));
    },
  });
  register({
    name: "validate_exam", label: "Validate Reading exam", description: "Validate canonical Exam -> Sections -> QuestionGroups -> Questions -> Options and paper-wide indices. Only complete papers require 40 independent scoring units.",
    parameters: Type.Object({ exam: Type.Optional(examSchema), canonicalExam: Type.Optional(Type.Unknown()), complete: Type.Boolean(), requirements: Type.Optional(Type.Object({
      sectionScoringUnits: Type.Optional(Type.Array(Type.Integer({ minimum: 1 }), { minItems: 1 })),
      answerSlotCount: Type.Optional(Type.Integer({ minimum: 1 })),
      profile: Type.Optional(Type.Union([Type.Literal("platform-reference"), Type.Literal("strict-academic")])),
    }, strict)) }, strict),
    async execute(_id, { exam, canonicalExam, complete, requirements }) {
      if ((exam !== undefined) === (canonicalExam !== undefined)) throw new Error("INPUT_SCHEMA_INVALID: Supply exactly one of exam or canonicalExam. Repair guidance: Select the intended artifact representation.");
      if (canonicalExam !== undefined) return output(validateCanonicalExam(canonicalExam, complete, requirements?.profile));
      return output(report(validateExam(exam!, complete, requirements), { ...counts(exam!.sections.flatMap(s => s.questionGroups)), complete, compatibility: "UNVERIFIED" }));
    },
  });
  register({
    name: "verify_evidence", label: "Verify Reading evidence", description: "Check exact passage spans, question coverage and independent semantic-review inputs across single group, multiple groups, or one selected canonical exam section. Never proves entailment or real IELTS quality.",
    parameters: evidenceInput,
    async execute(_id, input) { return output(verifyEvidence(input)); },
  });
  register({
    name: "check_grading_parity", label: "Check Reading grading parity", description: "Execute source-derived backend grading against explicit IELTS expectations. All-or-nothing scoring; regex-bearing keys fail closed rather than claiming .NET/JS equivalence.",
    parameters: Type.Object({ question: questionSchema, cases: Type.Array(parityCase, { minItems: 1 }) }, strict),
    async execute(_id, { question, cases }) {
      const diagnostics = validateQuestion(question);
      if (new Set(cases.map(c => c.id)).size !== cases.length) diagnostics.push(d("PARITY_CASE_DUPLICATE", "cases", "Parity case IDs must be unique."));
      if (hasRegex(question)) return output(report([...diagnostics, d("PARITY_REGEX_UNSUPPORTED", "question", "Exact .NET regex parity is not claimed; use text-only keys for this slice or test with the .NET grader.")], { results: [], backendCompatible: false, ieltsQualityEstablished: false }));
      const results = cases.map(c => {
        const backend = grade(question, c.answer);
        if (backend.isCorrect !== c.expectedCorrect) diagnostics.push(d("GRADING_IELTS_DIVERGENCE", `cases.${c.id}`, "Backend result differs from the supplied IELTS expectation."));
        const selected = new Set((c.answer.selectedOptionIds ?? []).map(id => id.toLowerCase()));
        // AnswerValidator runs before graders, even on text fallback paths.
        if ([...selected].some(id => !question.options.some(o => o.id.toLowerCase() === id)) || (spec(question.type).family === "single" && selected.size > 1)) diagnostics.push(d("ANSWER_SELECTION_INVALID", `cases.${c.id}`, "Attempt ingestion rejects unknown options or too many single-choice selections."));
        return { id: c.id, expectedCorrect: c.expectedCorrect, ...backend };
      });
      return output(report(diagnostics, { results, backendCompatible: !diagnostics.some(x => x.severity === "error"), parityEvidence: "SOURCE_DERIVED_JAVASCRIPT_ONLY", dotnetVerified: false, frontendVerified: false, ieltsQualityEstablished: false }));
    },
  });
  register({
    name: "inspect_delivery_projection", label: "Inspect Reading delivery projection", description: "Produce an allowlisted, normalized student projection; optionally inspect serialized delivery against it. Removes keys, explanations, model answers and reviews before blind delegation.",
    parameters: Type.Object({ exam: Type.Optional(examSchema), canonicalExam: Type.Optional(Type.Unknown()), projectionJson: Type.Optional(Type.String()) }, strict),
    async execute(_id, { exam, canonicalExam, projectionJson }) {
      if ((exam !== undefined) === (canonicalExam !== undefined)) throw new Error("INPUT_SCHEMA_INVALID: Supply exactly one of exam or canonicalExam. Repair guidance: Select the intended representation.");
      const canonical = canonicalExam !== undefined ? validateCanonicalExam(canonicalExam, false) : undefined;
      if (canonical?.status === "FAIL") return output(canonical);
      const source = (canonicalExam ?? exam) as import("../reading/contracts.ts").Exam;
      const projection = studentProjection(source);
      const diagnostics = canonical?.diagnostics ?? validateExam(source, false);
      if (!validateProjectionCandidate(projection)) diagnostics.push(d("DELIVERY_PRIVATE_CONTENT", "projection", "Student-visible fields contain private markers or do not conform to the public allowlist."));
      if (projectionJson !== undefined) {
        try {
          const candidate: unknown = JSON.parse(projectionJson);
          const leaked = privatePaths(candidate);
          for (const path of leaked) diagnostics.push(d("DELIVERY_PRIVATE_FIELD", path, "Private fields must be absent, not merely null or empty."));
          if (stableJson(candidate) !== stableJson(projection)) diagnostics.push(d("DELIVERY_PROJECTION_MISMATCH", "projection", "Delivery differs from the normalized student allowlist (content, membership, indices or unexpected fields)."));
        } catch { diagnostics.push(d("DELIVERY_JSON_INVALID", "projection", "Delivery is not valid serialized JSON.")); }
      }
      return output(report(diagnostics, { projection, ...counts(source.sections.flatMap(s => s.questionGroups)), compatibility: "UNVERIFIED", frontendVerified: false, ieltsQualityEstablished: false }));
    },
  });
}
