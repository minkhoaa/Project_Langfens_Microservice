import { Type, type Static, type TSchema } from "typebox";
import { Value } from "typebox/value";
import type { ExtensionAPI, ToolDefinition } from "generation-harness-core";
import { answerSchema, answerSlots, counts, diagnostic as d, examSchema, groupSchema, kindSchema, questionSchema, report, spec, type Diagnostic, type Group, type Question } from "../reading/contracts.js";
import { validateExam, validateGroup, validateQuestion } from "../reading/validation.js";
import { grade, hasRegex } from "../reading/grading.js";
import { privatePaths, stableJson, studentProjection, validateProjectionCandidate } from "../reading/projection.js";

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
  // Native validation deliberately coerces scalar values. The public pre-validation
  // hook enforces this domain's strict wire types before that conversion occurs.
  function register<T extends TSchema>(tool: ToolDefinition<T>) {
    api.registerTool({ ...tool, prepareArguments(args: unknown) {
      if (!Value.Check(tool.parameters, args)) throw new Error("INPUT_SCHEMA_INVALID: Arguments must exactly match the IELTS tool schema.");
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
    parameters: Type.Object({ question: questionSchema }, strict),
    async execute(_id, { question }) { return output(report(validateQuestion(question), { questionCount: 1, answerSlotCount: answerSlots(question), scoringUnitCount: 1, questionGroupCount: 0 })); },
  });
  register({
    name: "validate_group", label: "Validate Reading group", description: "Check membership, exact bounds, keys and independent scoring units; groups do not require 40 questions.",
    parameters: Type.Object({ group: groupSchema }, strict),
    async execute(_id, { group }) { return output(report(validateGroup(group), counts([group]))); },
  });
  register({
    name: "validate_exam", label: "Validate Reading exam", description: "Validate canonical Exam -> Sections -> QuestionGroups -> Questions -> Options and paper-wide indices. Only complete papers require 40 independent scoring units.",
    parameters: Type.Object({ exam: examSchema, complete: Type.Boolean(), requirements: Type.Optional(Type.Object({
      sectionScoringUnits: Type.Optional(Type.Array(Type.Integer({ minimum: 1 }), { minItems: 1 })),
      answerSlotCount: Type.Optional(Type.Integer({ minimum: 1 })),
    }, strict)) }, strict),
    async execute(_id, { exam, complete, requirements }) { return output(report(validateExam(exam, complete, requirements), { ...counts(exam.sections.flatMap(s => s.questionGroups)), complete })); },
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
      return output(report(diagnostics, { results, backendCompatible: !diagnostics.some(x => x.severity === "error"), ieltsQualityEstablished: false }));
    },
  });
  register({
    name: "inspect_delivery_projection", label: "Inspect Reading delivery projection", description: "Produce an allowlisted, normalized student projection; optionally inspect serialized delivery against it. Removes keys, explanations, model answers and reviews before blind delegation.",
    parameters: Type.Object({ exam: examSchema, projectionJson: Type.Optional(Type.String()) }, strict),
    async execute(_id, { exam, projectionJson }) {
      const projection = studentProjection(exam);
      const diagnostics = validateExam(exam, false);
      if (!validateProjectionCandidate(projection)) diagnostics.push(d("DELIVERY_PRIVATE_CONTENT", "projection", "Student-visible fields contain private markers or do not conform to the public allowlist."));
      if (projectionJson !== undefined) {
        try {
          const candidate: unknown = JSON.parse(projectionJson);
          const leaked = privatePaths(candidate);
          for (const path of leaked) diagnostics.push(d("DELIVERY_PRIVATE_FIELD", path, "Private fields must be absent, not merely null or empty."));
          if (stableJson(candidate) !== stableJson(projection)) diagnostics.push(d("DELIVERY_PROJECTION_MISMATCH", "projection", "Delivery differs from the normalized student allowlist (content, membership, indices or unexpected fields)."));
        } catch { diagnostics.push(d("DELIVERY_JSON_INVALID", "projection", "Delivery is not valid serialized JSON.")); }
      }
      return output(report(diagnostics, { projection, ...counts(exam.sections.flatMap(s => s.questionGroups)), ieltsQualityEstablished: false }));
    },
  });
}
