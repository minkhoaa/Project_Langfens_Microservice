import { Type, type Static, type TSchema } from "typebox";
import { Value } from "typebox/value";
import type { ExtensionAPI, ToolDefinition } from "generation-harness-core";
import { answerSchema, answerSlots, counts, diagnostic as d, examSchema, groupSchema, kindSchema, questionSchema, report, spec, type Diagnostic } from "../reading/contracts.js";
import { validateExam, validateGroup, validateQuestion } from "../reading/validation.js";
import { grade, hasRegex } from "../reading/grading.js";
import { privatePaths, stableJson, studentProjection } from "../reading/projection.js";

const strict = { additionalProperties: false } as const;
const evidenceSchema = Type.Object({ questionId: Type.String(), start: Type.Integer({ minimum: 0 }), end: Type.Integer({ minimum: 1 }), quote: Type.String({ minLength: 1 }) }, strict);
const reviewSchema = Type.Object({ reviewerId: Type.String({ minLength: 1 }), questionIds: Type.Array(Type.String()), verdict: Type.Union([Type.Literal("PASS"), Type.Literal("FAIL")]), rationale: Type.String({ minLength: 1 }), mocked: Type.Boolean() }, strict);
const parityCase = Type.Object({ id: Type.String({ minLength: 1 }), answer: answerSchema, expectedCorrect: Type.Boolean() }, strict);
const evidenceInput = Type.Object({
  passageMd: Type.String(), group: groupSchema, evidence: Type.Array(evidenceSchema),
  blindSolverId: Type.String({ minLength: 1 }), semanticReviews: Type.Array(reviewSchema),
}, strict);
function verifyEvidence(input: Static<typeof evidenceInput>) {
  const { passageMd, group, evidence, blindSolverId, semanticReviews } = input;
  const diagnostics: Diagnostic[] = [...validateGroup(group)];
  const ids = new Set(group.questions.map(q => q.id));
  for (const [i, span] of evidence.entries()) {
    const path = `evidence[${i}]`;
    if (!ids.has(span.questionId)) diagnostics.push(d("EVIDENCE_QUESTION_UNKNOWN", path, "Evidence references a question outside the group."));
    if (span.start >= span.end || span.end > passageMd.length || passageMd.slice(span.start, span.end) !== span.quote) diagnostics.push(d("EVIDENCE_SPAN_MISMATCH", path, "UTF-16 offsets and exact quotation must match the passage."));
  }
  for (const id of ids) if (!evidence.some(e => e.questionId === id)) diagnostics.push(d("EVIDENCE_MISSING", id, "Every question requires passage evidence (absence claims still require independent review)."));
  if (!semanticReviews.length) diagnostics.push(d("SEMANTIC_REVIEW_MISSING", "semanticReviews", "Independent semantic-review input is required."));
  const reviewers = new Set<string>();
  for (const [i, review] of semanticReviews.entries()) {
    const path = `semanticReviews[${i}]`;
    const reviewerId = review.reviewerId.trim().toLowerCase();
    if (!reviewerId || reviewerIdInvalid(review.reviewerId, blindSolverId) || reviewers.has(reviewerId)) diagnostics.push(d("REVIEW_NOT_INDEPENDENT", path, "Review identities must be distinct from the blind solver and one another."));
    reviewers.add(reviewerId);
    if (!review.rationale.trim() || review.verdict !== "PASS") diagnostics.push(d("SEMANTIC_REVIEW_REJECTED", path, "Review did not approve with a substantive rationale."));
    if (new Set(review.questionIds).size !== review.questionIds.length || review.questionIds.some(id => !ids.has(id)) || [...ids].some(id => !review.questionIds.includes(id))) diagnostics.push(d("SEMANTIC_REVIEW_COVERAGE", path, "Each independent review must cover exactly this group's questions."));
  }
  diagnostics.push(d("SEMANTIC_QUALITY_NOT_ESTABLISHED", "semanticReviews", "Span checks and supplied reviews do not prove IELTS correctness; mocked approvals are offline plumbing evidence only.", "warning"));
  return report(diagnostics, { evidenceCount: evidence.length, semanticReviewCount: semanticReviews.length, mocked: semanticReviews.some(r => r.mocked), ieltsQualityEstablished: false });
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
    parameters: Type.Object({ exam: examSchema, complete: Type.Boolean() }, strict),
    async execute(_id, { exam, complete }) { return output(report(validateExam(exam, complete), { ...counts(exam.sections.flatMap(s => s.questionGroups)), complete })); },
  });
  register({
    name: "verify_evidence", label: "Verify Reading evidence", description: "Check exact passage spans, question coverage and independent semantic-review inputs. Never proves entailment or real IELTS quality.",
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
