"""Fail-closed content evaluations bound to exact immutable artifact references.

Provider judgements supplement, never replace, deterministic checks. The four
paper IDs/versions are the canonical exam-service finalization contract.
"""
from __future__ import annotations

import hashlib
import re
from collections import Counter
from collections.abc import Iterable, Mapping, Sequence
from itertools import combinations
from typing import Any

from pydantic import TypeAdapter, ValidationError

from app.contracts.artifact import ArtifactEnvelope, ArtifactType, canonical_json_dump, canonical_json_dump_prep
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.evidence import EvidenceGraph
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.policies import (
    calculate_shingle_overlap, count_words, match_verbatim_in_passage,
    normalize_prompt, validate_answer_length,
)
from app.contracts.questions import QuestionUnion
from app.evaluators.deterministic import check_cross_prompt_answer_leakage, check_prompt_answer_leakage
from app.evaluators.semantic import detect_comparison_inversion, detect_negation_polarity_conflict
from app.reading_policy import PinnedExecutionPolicy, SectionConfig

PAPER_EVALUATORS = {
    "eval_paper_structure": "2.0.0",
    "eval_paper_cross_section": "2.0.0",
    "eval_paper_leakage": "2.1.0",
    "eval_paper_monotony": "2.0.0",
}
EVALUATION_CATALOG = {
    "eval_source": "1.0.0", "eval_evidence_graph": "1.0.0", "eval_blueprint": "1.0.0",
    "eval_passage_word_count": "1.0.0", "eval_passage_fidelity": "1.0.0",
    "eval_passage_semantic": "1.0.0", "eval_question_structure": "1.0.0",
    "eval_answer_verbatim_length": "1.0.0", "eval_evidence_offsets": "1.0.0",
    "eval_question_uniqueness": "1.0.0", "eval_question_semantic": "1.0.0",
    "eval_blind_solver_adversary": "1.0.0", "eval_candidate_pool": "1.0.0",
    "eval_section_structure": "1.0.0", "eval_section_editorial": "1.0.0",
    "eval_paper_closure": "1.0.0", **PAPER_EVALUATORS,
}
PASSAGE_EVALUATORS = ("eval_passage_word_count", "eval_passage_fidelity", "eval_passage_semantic")
QUESTION_EVALUATORS = (
    "eval_question_structure", "eval_answer_verbatim_length", "eval_evidence_offsets",
    "eval_question_uniqueness", "eval_question_semantic", "eval_blind_solver_adversary",
)
QUESTION_ADAPTER = TypeAdapter(QuestionUnion)
QUESTION_FIELDS = {
    "questionNumber", "questionType", "explanation", "statement", "answer",
    "evidenceQuote", "absenceAssessment", "prompt", "options", "correctOption",
    "answers", "headings", "features", "endings", "categories", "summaryText",
    "tableContext", "flowSteps", "calloutLabel", "partDescription", "headingContext",
    "fieldLabel", "svgAssetId",
}
NUMBER = re.compile(r"(?<![\w])\d+(?:[.,]\d+)*(?:%|)(?![\w])")
POPULATIONS = re.compile(r"\b(humans?|mice|rats|patients?|children|adults?|cells?|animals?)\b", re.I)
SCOPES = {
    ArtifactType.SOURCE_PACK: IssueScope.SOURCE,
    ArtifactType.EVIDENCE_GRAPH: IssueScope.EVIDENCE,
    ArtifactType.EXAM_BLUEPRINT: IssueScope.BLUEPRINT,
    ArtifactType.PASSAGE: IssueScope.PASSAGE,
    ArtifactType.QUESTION_GROUP: IssueScope.QUESTION_GROUP,
    ArtifactType.QUESTION: IssueScope.QUESTION,
    ArtifactType.SECTION: IssueScope.SECTION,
    ArtifactType.READING_PAPER: IssueScope.PAPER,
}
Problem = tuple[IssueCode, str]


def data(value: Any) -> Any:
    """Unfreeze a canonical payload without modifying its source."""
    return canonical_json_dump_prep(value)


def result(artifact: ArtifactEnvelope, evaluator_id: str, problems: Iterable[Problem]) -> EvaluationResult:
    failures = tuple(problems)
    identity = hashlib.sha256(f"{evaluator_id}:{artifact.content_hash}".encode()).hexdigest()[:20]
    issues = [Issue.create(
        issue_id=f"iss_{identity}_{index}", code=code, severity=IssueSeverity.CRITICAL,
        scope=SCOPES[artifact.artifact_type], message=message,
        affected_refs=[artifact.to_ref()], evaluator_id=evaluator_id,
    ) for index, (code, message) in enumerate(failures)]
    return EvaluationResult(
        evaluationId=f"evaluation_{identity}", evaluatorId=evaluator_id,
        evaluatorVersion=EVALUATION_CATALOG[evaluator_id], targetRef=artifact.to_ref(),
        status=EvaluationStatus.FAIL if issues else EvaluationStatus.PASS,
        issues=issues, score=0.0 if issues else 1.0,
        inputDependencyRefs=list(artifact.parent_refs),
    )


def source_texts(payload: Mapping[str, Any]) -> dict[str, str]:
    return {item["sourceId"]: item["document"]["text"] for item in payload["sources"]}


def evaluate_source(artifact: ArtifactEnvelope, policy: PinnedExecutionPolicy) -> list[EvaluationResult]:
    payload = artifact.payload
    sources = payload.get("sources", ())
    problems = []
    if not sources or not payload.get("licenseCleared"):
        problems.append((IssueCode.SOURCE_INSUFFICIENT, "Source pack lacks cleared, attributed sources"))
    for item in sources:
        metadata, document = item["metadata"], item["document"]
        if not metadata.get("licenseCleared") or not metadata.get("pmcid") or not metadata.get("sourceUrl"):
            problems.append((IssueCode.SOURCE_INSUFFICIENT, "Source metadata lacks exact provenance and license"))
        if count_words(document["text"]) < policy.source_min_words:
            problems.append((IssueCode.SOURCE_INSUFFICIENT, "Normalized source is below pinned minimum length"))
    for chunk in payload.get("chunks", ()):
        text = source_texts(payload).get(chunk["sourceId"], "")
        if text[chunk["start_char"]:chunk["end_char"]] != chunk["text"]:
            problems.append((IssueCode.EVIDENCE_MISSING, "Normalized source chunk has invalid exact offsets"))
    if not payload.get("chunks"):
        problems.append((IssueCode.SOURCE_INSUFFICIENT, "Source has no sentence-aligned chunks"))
    return [result(artifact, "eval_source", problems)]


def evidence_problems(graph: EvidenceGraph, texts: Mapping[str, str], minimum: int) -> tuple[Problem, ...]:
    problems: list[Problem] = []
    if graph.status != "ACCEPTED" or len(graph.claims) < minimum:
        problems.append((IssueCode.SOURCE_INSUFFICIENT, "Evidence graph has insufficient verified atomic claims"))
    ids = [claim.claim_id for claim in graph.claims]
    if len(set(ids)) != len(ids):
        problems.append((IssueCode.DUPLICATE_CONTENT, "Evidence claim identities are duplicated"))
    for claim in graph.claims:
        offsets = claim.offsets
        text = texts.get(claim.source_id, "")
        if (offsets is None or offsets.source_id != claim.source_id or offsets.start_char >= offsets.end_char
                or text[offsets.start_char:offsets.end_char] != claim.text
                or claim.entailment.value != "ENTAILS"):
            problems.append((IssueCode.EVIDENCE_MISSING, f"Claim {claim.claim_id} lacks exact entailing source offsets"))
    for first, second in combinations(graph.claims, 2):
        # Opposed predicates for the same lexical subject cannot be silently
        # promoted to one authoritative factual graph; obtain another source.
        conflict, _ = detect_negation_polarity_conflict(first.text, second.text)
        if conflict or detect_comparison_inversion(first.text, second.text):
            problems.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                             f"Contradictory claims: {first.claim_id}, {second.claim_id}"))
    return tuple(problems)


def evaluate_evidence(artifact: ArtifactEnvelope, texts: Mapping[str, str], minimum: int) -> list[EvaluationResult]:
    try:
        graph = EvidenceGraph.model_validate(data(artifact.payload))
    except ValidationError as error:
        return [result(artifact, "eval_evidence_graph", [(IssueCode.SCHEMA_VIOLATION, str(error))])]
    return [result(artifact, "eval_evidence_graph", evidence_problems(graph, texts, minimum))]


def evaluate_blueprint(artifact: ArtifactEnvelope, policy: PinnedExecutionPolicy, indices: tuple[int, ...]) -> list[EvaluationResult]:
    payload = artifact.payload
    sections = payload.get("sections", ())
    problems = []
    if tuple(item["sectionId"] for item in sections) != tuple(sorted(indices)):
        problems.append((IssueCode.SCHEMA_VIOLATION, "Blueprint does not cover exactly the requested sections"))
    for item in sections:
        config = policy.section(item["sectionId"])
        slots = item.get("questionSlots", ())
        if tuple(slot["questionNumber"] for slot in slots) != config.question_numbers():
            problems.append((IssueCode.QUESTION_NUMBERING_INVALID, "Blueprint question numbers diverge from pinned allocation"))
        if not slots or any(not slot.get("claimRefIds") for slot in slots):
            problems.append((IssueCode.EVIDENCE_MISSING, "Every blueprint slot must bind verified evidence"))
        if not item.get("passageObjectives") or not item.get("evidenceGraphRef"):
            problems.append((IssueCode.EVIDENCE_MISSING, "Blueprint lacks evidence graph or coherent editorial objectives"))
    return [result(artifact, "eval_blueprint", problems)]


def evaluate_passage(artifact: ArtifactEnvelope, source_text: str, claims: Mapping[str, Any], config: SectionConfig) -> list[EvaluationResult]:
    payload = artifact.payload
    passage = str(payload.get("passage", ""))
    words = count_words(passage)
    lengths = [] if config.min_words <= words <= config.max_words else [
        (IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS, f"Passage has {words} canonical words; expected {config.min_words}–{config.max_words}")]
    fidelity_problems: list[Problem] = []
    semantic_problems: list[Problem] = []
    if not str(payload.get("title", "")).strip() or re.search(r"(?im)^\s*(section|reading passage)\s+[123]\s*:", passage):
        fidelity_problems.append((IssueCode.EDITORIAL_STYLE_DEFECT, "Passage has missing title or internal exam labels"))
    invented = set(NUMBER.findall(passage)) - set(NUMBER.findall(source_text))
    if invented:
        semantic_problems.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, f"Invented or altered source quantities: {sorted(invented)}"))
    if set(w.lower() for w in POPULATIONS.findall(passage)) - set(w.lower() for w in POPULATIONS.findall(source_text)):
        semantic_problems.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, "Scientific population drift from source"))
    alignments = payload.get("claimAlignments", ())
    if not alignments:
        fidelity_problems.append((IssueCode.EVIDENCE_MISSING, "Passage has no verified claim alignments"))
    for alignment in alignments:
        claim = claims.get(alignment["claimId"])
        start, end = alignment["sourceStart"], alignment["sourceEnd"]
        quote, source_quote = alignment["passageQuote"], alignment["sourceQuote"]
        if (claim is None or not quote or quote not in passage or start >= end
                or source_text[start:end] != source_quote or source_quote != claim["text"]):
            fidelity_problems.append((IssueCode.EVIDENCE_MISSING, "Passage alignment fails exact source/passage quote verification"))
            continue
        if set(NUMBER.findall(quote)) - set(NUMBER.findall(source_quote)):
            semantic_problems.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, "Aligned claim changes a quantity"))
        if quote.strip().lower() != source_quote.strip().lower():
            conflict, reason = detect_negation_polarity_conflict(quote, source_quote)
            if conflict or detect_comparison_inversion(quote, source_quote):
                semantic_problems.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, reason or "Scientific comparison inverted"))
        if re.search(r"\b(proves?|always|certainly|causes?)\b", quote, re.I) and re.search(r"\b(may|might|associated|suggests?|correlat\w*)\b", source_quote, re.I):
            semantic_problems.append((IssueCode.CAUSAL_OVERSTATEMENT, "Passage inflates source certainty or causation"))
    for paragraph in re.split(r"\n\s*\n", passage):
        if paragraph.strip() and not any(a["passageQuote"] in paragraph for a in alignments if a.get("passageQuote")):
            fidelity_problems.append((IssueCode.EVIDENCE_MISSING, "Every substantive paragraph needs a verified claim alignment"))
    return [
        result(artifact, "eval_passage_word_count", lengths),
        result(artifact, "eval_passage_fidelity", fidelity_problems),
        result(artifact, "eval_passage_semantic", semantic_problems),
    ]


def semantic_result(artifact: ArtifactEnvelope, evaluator_id: str, report: Mapping[str, Any], required: Sequence[str]) -> EvaluationResult:
    checks = report.get("checks", {})
    failed = tuple(name for name in required if checks.get(name) is not True)
    messages = tuple(str(message) for message in report.get("issues", ()))
    problems = [(IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, f"Required semantic checks failed: {', '.join(failed)}; {'; '.join(messages)}")] if failed or messages else []
    return result(artifact, evaluator_id, problems)


def question_core(payload: Mapping[str, Any]) -> dict[str, Any]:
    core = {key: data(value) for key, value in payload.items() if key in QUESTION_FIELDS}
    q_type = str(core.get("questionType", ""))
    if q_type in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
        if "statement" not in core and "prompt" in core:
            core["statement"] = core.pop("prompt")
        else:
            core.pop("prompt", None)
    else:
        if "prompt" not in core and "statement" in core:
            core["prompt"] = core.pop("statement")
        else:
            core.pop("statement", None)
    return core

def question_answer(question: Mapping[str, Any]) -> str:
    return str(question.get("correctOption", question.get("answer", "")))


def question_prompt(question: Mapping[str, Any]) -> str:
    return str(question.get("statement", question.get("prompt", "")))


def question_digest(question: Mapping[str, Any]) -> str:
    return hashlib.sha256(canonical_json_dump(question_core(question)).encode()).hexdigest()


def evaluate_question(artifact: ArtifactEnvelope, passage: str, difficulty: str, siblings: Sequence[Mapping[str, Any]]) -> list[EvaluationResult]:
    payload = artifact.payload
    structure: list[Problem] = []
    evidence: list[Problem] = []
    answer_problems: list[Problem] = []
    unique: list[Problem] = []
    try:
        QUESTION_ADAPTER.validate_python(question_core(payload))
    except ValidationError as error:
        structure.append((IssueCode.SCHEMA_VIOLATION, str(error)))
    prompt, answer = question_prompt(payload), question_answer(payload)
    question_type = payload.get("questionType")
    if len(str(payload.get("explanation", ""))) < 25:
        structure.append((IssueCode.SCHEMA_VIOLATION, "Explanation must explain the actual passage inference"))
    if not prompt.strip() or payload.get("difficulty", difficulty) != difficulty:
        structure.append((IssueCode.EDITORIAL_STYLE_DEFECT, "Missing prompt or incorrect configured difficulty"))
    span = payload.get("passageEvidence", {})
    start, end = span.get("startChar", -1), span.get("endChar", -1)
    if start < 0 or end <= start or passage[start:end] != span.get("text") or not payload.get("evidenceClaimRef"):
        evidence.append((IssueCode.EVIDENCE_MISSING, "Question has no exact passage offsets and verified claim identity"))
    if answer == "NOT_GIVEN":
        assessment = payload.get("absenceAssessment") or {}
        if payload.get("evidenceQuote") is not None or not assessment.get("absenceConfirmed") or not assessment.get("absenceReason"):
            evidence.append((IssueCode.EVIDENCE_MISSING, "NOT GIVEN requires an absence assessment, never fabricated positive evidence"))
    else:
        quote = str(payload.get("evidenceQuote", ""))
        if len(quote) < 15 or quote not in passage or span.get("text") != quote:
            evidence.append((IssueCode.EVIDENCE_MISSING, "Evidence quote must be the exact identified passage span"))
    if question_type in {"SENTENCE_COMPLETION", "SUMMARY_COMPLETION", "SHORT_ANSWER"}:
        if not validate_answer_length(answer) or not match_verbatim_in_passage(answer, passage):
            q_num_label = payload.get("questionNumber") or payload.get("number") or ""
            answer_problems.append((IssueCode.WORD_LIMIT_EXCEEDED, f"Question {q_num_label}: Answer '{answer}' is not a full-token source phrase within IELTS word/number limits"))
        if question_type != "SHORT_ANSWER" and f"[{payload.get('questionNumber')}]" not in prompt:
            structure.append((IssueCode.SCHEMA_VIOLATION, "Completion item lacks its numbered blank"))
        if check_prompt_answer_leakage(prompt, answer):
            answer_problems.append((IssueCode.ANSWER_LEAKAGE, "Question prompt exposes its own answer"))
    if question_type == "MULTIPLE_CHOICE_SINGLE":
        options = tuple(payload.get("options", ()))
        if len(options) != 4 or any(not option.startswith(f"{chr(65 + i)}.") for i, option in enumerate(options)):
            structure.append((IssueCode.INSUFFICIENT_OPTIONS, "MCQ needs distinct, labeled A–D options"))
        bodies = tuple(re.sub(r"^[A-D]\.\s*", "", option).strip().casefold() for option in options)
        if len(set(bodies)) != 4:
            structure.append((IssueCode.BAD_DISTRACTOR, "MCQ distractors duplicate another option"))
    for other in siblings:
        if (normalize_prompt(prompt) == normalize_prompt(question_prompt(other))
                or calculate_shingle_overlap(prompt, question_prompt(other)) > 0.7):
            unique.append((IssueCode.DUPLICATE_CONTENT, "Candidate duplicates an already accepted question"))
    semantic: list[Problem] = []
    if answer == "NOT_GIVEN":
        assessment = payload.get("absenceAssessment") or {}
        if payload.get("evidenceQuote") is not None:
            semantic.append((IssueCode.EVIDENCE_MISSING, "NOT GIVEN must not provide positive evidenceQuote"))
        if assessment.get("absenceConfirmed") is not True:
            semantic.append((IssueCode.EVIDENCE_MISSING, "NOT GIVEN requires verified absenceConfirmed=True"))
        if not assessment.get("absenceReason"):
            semantic.append((IssueCode.EVIDENCE_MISSING, "NOT GIVEN requires an explicit absenceReason"))
        if len(prompt.strip()) >= 10 and prompt.lower().strip(". ") in passage.lower():
            semantic.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, "NOT GIVEN statement is directly present in passage text"))
    elif question_type in {"TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"}:
        quote = str(payload.get("evidenceQuote", ""))
        if answer in ("TRUE", "YES"):
            conflict, reason = detect_negation_polarity_conflict(prompt, quote)
            if conflict or detect_comparison_inversion(prompt, quote):
                semantic.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, reason or "Statement contradicts evidence quote"))
        elif answer in ("FALSE", "NO"):
            conflict, _ = detect_negation_polarity_conflict(prompt, quote)
            inverted = detect_comparison_inversion(prompt, quote)
            if not conflict and not inverted and prompt.strip().lower() == quote.strip().lower():
                semantic.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, "FALSE/NO statement verbatim matches evidence quote without contradiction"))
    elif question_type == "MULTIPLE_CHOICE_SINGLE":
        correct_opt = str(payload.get("correctOption", "")).strip().upper()
        if correct_opt not in ("A", "B", "C", "D"):
            semantic.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, f"MCQ key '{correct_opt}' is unsupported; must be A, B, C, or D"))
        options = tuple(payload.get("options", ()))
        bodies = tuple(re.sub(r"^[A-D]\.\s*", "", option).strip().casefold() for option in options)
        if len(set(bodies)) != len(options):
            semantic.append((IssueCode.BAD_DISTRACTOR, "MCQ options contain duplicate distractors"))
        opt_idx = ord(correct_opt) - ord('A') if correct_opt in ("A", "B", "C", "D") else -1
        if 0 <= opt_idx < len(bodies):
            correct_body = bodies[opt_idx]
            quote = str(payload.get("evidenceQuote", "")).casefold()
            for d_idx, d_body in enumerate(bodies):
                if d_idx != opt_idx:
                    if len(d_body) > 10 and len(correct_body) > 10 and calculate_shingle_overlap(d_body, correct_body) > 0.8:
                        semantic.append((IssueCode.BAD_DISTRACTOR, f"MCQ distractor {chr(65 + d_idx)} is ambiguously similar to correct option {correct_opt}"))
                    if len(d_body) > 15 and quote and d_body in quote:
                        semantic.append((IssueCode.BAD_DISTRACTOR, f"MCQ distractor {chr(65 + d_idx)} is directly supported by evidence quote"))
    if question_type in {"SENTENCE_COMPLETION", "SUMMARY_COMPLETION", "SHORT_ANSWER"}:
        clean_prompt = prompt.replace(f"[{payload.get('questionNumber')}]", "")
        if check_prompt_answer_leakage(clean_prompt, answer):
            semantic.append((IssueCode.ANSWER_LEAKAGE, "Question prompt exposes its own answer"))
        quote = str(payload.get("evidenceQuote", ""))
        if quote and answer.lower() not in quote.lower():
            semantic.append((IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM, "Completion answer is not contained in the evidence quote"))
    return [result(artifact, "eval_question_structure", structure),
            result(artifact, "eval_answer_verbatim_length", answer_problems),
            result(artifact, "eval_evidence_offsets", evidence),
            result(artifact, "eval_question_uniqueness", unique),
            result(artifact, "eval_question_semantic", semantic)]


def blind_result(artifact: ArtifactEnvelope, report: Mapping[str, Any], solver: Mapping[str, Any], adversary: Mapping[str, Any], passage: str) -> EvaluationResult:
    expected = question_answer(artifact.payload).replace("_", " ").casefold().strip()
    actual = str(solver.get("answer", "")).replace("_", " ").casefold().strip()
    problems = []
    if report.get("questionHash") != question_digest(artifact.payload):
        problems.append((IssueCode.STALE_DEPENDENCY, "Review does not bind this exact candidate content"))
    if actual != expected:
        problems.append((IssueCode.AMBIGUOUS_ANSWER, "Independent blind solver disagrees with the author key"))
    quote = str(solver.get("evidenceQuote", ""))
    if not solver.get("reasoning") or (expected != "not given" and (len(quote) < 15 or quote not in passage)):
        problems.append((IssueCode.EVIDENCE_MISSING, "Blind solver did not independently identify exact passage evidence"))
    if adversary.get("unambiguous") is not True or adversary.get("alternativeAnswers") or not adversary.get("reasoning"):
        problems.append((IssueCode.AMBIGUOUS_ANSWER, "Adversary found a defensible alternative or omitted its review"))
    return result(artifact, "eval_blind_solver_adversary", problems)


def evaluate_section(artifact: ArtifactEnvelope, config: SectionConfig) -> list[EvaluationResult]:
    payload = artifact.payload
    groups = payload.get("groups", ())
    problems: list[Problem] = []
    if payload.get("sectionId") != config.index:
        problems.append((IssueCode.SECTION_GROUP_COUNT_MISMATCH, "Section differs from configured section ID"))
    is_exact_preset = len(groups) == len(config.groups) and all(
        actual.get("questionType") == expected.question_type.value and len(actual.get("questions", ())) == expected.count
        for actual, expected in zip(groups, config.groups)
    )
    if is_exact_preset:
        for index, (actual, expected) in enumerate(zip(groups, config.groups)):
            if not actual.get("instructions"):
                problems.append((IssueCode.SCHEMA_VIOLATION, "Every group needs its canonical instructions"))
            if expected.question_type.value in ("SUMMARY_COMPLETION", "SUMMARY_COMPLETION_BOX"):
                context = str(actual.get("sharedContext", ""))
                if not context or any(context.count(f"[{number}]") != 1 for number in config.group_numbers(index)):
                    problems.append((IssueCode.SCHEMA_VIOLATION, "Summary must be one coherent context with each blank exactly once"))
    else:
        if not (2 <= len(groups) <= 4):
            problems.append((IssueCode.SECTION_GROUP_COUNT_MISMATCH, f"Section has {len(groups)} question group(s), expected 2-4"))
        for index, actual in enumerate(groups):
            if not actual.get("questions"):
                problems.append((IssueCode.SECTION_GROUP_SIZE_MISMATCH, f"Group {index} has no questions"))
            if not actual.get("instructions"):
                problems.append((IssueCode.SCHEMA_VIOLATION, "Every group needs its canonical instructions"))
            if actual.get("questionType") in ("SUMMARY_COMPLETION", "SUMMARY_COMPLETION_BOX"):
                context = str(actual.get("sharedContext", ""))
                grp_nums = [q.get("questionNumber") for q in actual.get("questions", []) if q.get("questionNumber")]
                if not context or any(context.count(f"[{number}]") != 1 for number in grp_nums):
                    problems.append((IssueCode.SCHEMA_VIOLATION, "Summary must be one coherent context with each blank exactly once"))
    questions = tuple(q for group in groups for q in group.get("questions", ()))
    if tuple(q.get("questionNumber") for q in questions) != config.question_numbers():
        problems.append((IssueCode.QUESTION_NUMBERING_INVALID, "Section numbering is not its contiguous pinned range"))
    if len(payload.get("questionRefs", ())) != config.question_count:
        problems.append((IssueCode.EVIDENCE_MISSING, "Section lacks individual accepted question references"))
    passage = str(payload.get("passage", ""))
    if not config.min_words <= count_words(passage) <= config.max_words:
        problems.append((IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS, "Section passage falls outside configured bounds"))
    editorial: list[Problem] = []
    prompts = [normalize_prompt(question_prompt(q)) for q in questions]
    if len(set(prompts)) != len(prompts):
        editorial.append((IssueCode.DUPLICATE_CONTENT, "Section contains duplicate prompts"))
    for first, second in combinations(questions, 2):
        if calculate_shingle_overlap(question_prompt(first), question_prompt(second)) > 0.7:
            editorial.append((IssueCode.DUPLICATE_CONTENT, "Section questions substantially repeat the same prompt"))
    return [result(artifact, "eval_section_structure", problems), result(artifact, "eval_section_editorial", editorial)]


def evaluate_paper(artifact: ArtifactEnvelope, policy: PinnedExecutionPolicy) -> list[EvaluationResult]:
    payload = artifact.payload
    sections = tuple(payload.get("sections", ()))
    all_questions = tuple(q for section in sections for group in section.get("groups", ()) for q in group.get("questions", ()))
    structure: list[Problem] = []
    cross: list[Problem] = []
    leakage: list[Problem] = []
    monotony: list[Problem] = []
    closure: list[Problem] = []
    if tuple(section.get("sectionId") for section in sections) != (1, 2, 3) or len(all_questions) != 40:
        structure.append((IssueCode.QUESTION_COUNT_MISMATCH, "A complete paper requires exactly three sections and forty questions"))
    if tuple(q.get("questionNumber") for q in all_questions) != tuple(range(1, 41)):
        structure.append((IssueCode.QUESTION_NUMBERING_INVALID, "Paper numbering must be exactly 1–40, in order"))
    total = sum(count_words(section.get("passage", "")) for section in sections)
    if not policy.paper_min_words <= total <= policy.paper_max_words or payload.get("totalWords") != total:
        structure.append((IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS, "Paper total length violates the pinned policy or declared word count"))
    if payload.get("totalQuestions") != 40:
        structure.append((IssueCode.QUESTION_COUNT_MISMATCH, "Declared paper total must be forty"))
    for section in sections:
        for evaluation in evaluate_section(artifact.model_copy(update={"payload": section}), policy.section(section["sectionId"])):
            structure.extend((issue.code, issue.message) for issue in evaluation.issues)
    for first, second in combinations(sections, 2):
        first_source, second_source = first.get("source", {}), second.get("source", {})
        if (first_source.get("pmcid") == second_source.get("pmcid")
                or (first_source.get("doi") and first_source.get("doi") == second_source.get("doi"))):
            cross.append((IssueCode.DUPLICATE_CONTENT, "Paper sections reuse the same source or DOI"))
        if calculate_shingle_overlap(first.get("passage", ""), second.get("passage", "")) > 0.45:
            cross.append((IssueCode.DUPLICATE_CONTENT, "Paper passages substantially duplicate one another"))
    prompts = [normalize_prompt(question_prompt(q)) for q in all_questions]
    if len(set(prompts)) != len(prompts):
        cross.append((IssueCode.DUPLICATE_CONTENT, "Paper repeats question prompts across sections"))
    lexical = tuple(q for q in all_questions if q.get("questionType") in {"SHORT_ANSWER", "SENTENCE_COMPLETION", "SUMMARY_COMPLETION"})
    for question in lexical:
        answer = question_answer(question)
        for other in all_questions:
            if question.get("questionNumber") == other.get("questionNumber"):
                continue
            if check_cross_prompt_answer_leakage(question_prompt(other), answer):
                leakage.append((IssueCode.ANSWER_LEAKAGE, f"Question {other.get('questionNumber')} exposes another item's answer"))
    # Long runs of identical author keys create exploitable patterns even if the
    # individual answers are correct. This is mandatory, not an advisory score.
    for section in sections:
        for group in section.get("groups", ()):
            keys = [question_answer(q) for q in group.get("questions", ())]
            if group.get("questionType") in {"TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE"} and len(keys) >= 4:
                if len(set(keys)) < 2 or any(len(set(keys[i:i + 4])) == 1 for i in range(len(keys) - 3)):
                    monotony.append((IssueCode.ANSWER_CONCENTRATION_DETECTED, "Objective answer keys have a monotonous exploitable run"))
    ranks = {"FOUNDATION": 0, "MODERATE": 1, "ADVANCED": 2}
    levels = [ranks[policy.section(section["sectionId"]).difficulty.value] for section in sections]
    if levels != sorted(levels) or (len(levels) == 3 and len(set(levels)) < 2):
        monotony.append((IssueCode.EDITORIAL_SKILL_DIVERSITY_DEFECT, "Configured paper lacks a nondecreasing difficulty progression"))
    expected = tuple(data(ref) for key in ("blueprintRef", "sectionRefs", "passageRefs", "questionRefs")
                     for ref in ([payload[key]] if key == "blueprintRef" and key in payload else payload.get(key, ())))
    actual = tuple(ref.model_dump(mode="json", by_alias=True) for ref in artifact.parent_refs)
    if (len(payload.get("sectionRefs", ())) != 3 or len(payload.get("passageRefs", ())) != 3
            or len(payload.get("questionRefs", ())) != 40 or len(expected) != len(actual)
            or {canonical_json_dump(ref) for ref in expected} != {canonical_json_dump(ref) for ref in actual}
            or len({canonical_json_dump(ref) for ref in actual}) != len(actual)):
        closure.append((IssueCode.STALE_DEPENDENCY, "Paper does not bind one exact blueprint, three sections/passages and forty questions"))
    return [result(artifact, "eval_paper_structure", structure), result(artifact, "eval_paper_cross_section", cross),
            result(artifact, "eval_paper_leakage", leakage), result(artifact, "eval_paper_monotony", monotony),
            result(artifact, "eval_paper_closure", closure)]
