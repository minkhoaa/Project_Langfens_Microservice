"""Answer-free, question-complete independent campaign scoring.

The aggregate hashes the complete ordered NeutralOutput using the same canonical
UTF-8 JSON as the replay ledger. Each assessment separately binds its exact safe
context/question view; the evaluator's raw_output_text argument carries only that
view for its existing content-hash contract, never a private generation response.

Semantic scores are unweighted arithmetic means over actual assessments. A
missing dimension is omitted, not zero-filled. Question failures cannot be
averaged away; incomplete assessment is UNCERTAIN, or NOT_RUN when none ran.
Execution completion is reported independently of content evaluability/quality.
"""

from __future__ import annotations

import hashlib
import math
import re
from typing import Any, Literal
from uuid import uuid4

from pydantic import Field

from app.contracts.artifact import canonical_json_dump
from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    ExecutionStatus,
    GenerationResult,
    NeutralOutput,
    NeutralQuestion,
    OutputAvailability,
)
from app.contracts.solver import SecurityLeakageError, scan_text_for_security_leaks
from app.evaluators.independent import METADATA_STRIP_KEYS, NeutralEvaluator
from app.evaluators.rubric import CanonicalEvaluationResult, EvaluationVerdict, RubricDimension
from app.experiment.blind_review import FORBIDDEN_GOLD_KEYS, GoldSmugglingForbiddenError
from app.solvers.serializer import project_to_solver_view


def _normalized_key(key: str) -> str:
    return re.sub(r"[^a-z0-9]", "", key.lower())


_ANSWER_KEYS = frozenset(
    _normalized_key(key)
    for key in (
        *FORBIDDEN_GOLD_KEYS,
        "answer", "proposed_answer", "generator_proposed_answer", "answer_key",
        "ground_truth", "acceptable_variants", "private_rationale",
    )
)
_INTERNAL_KEYS = frozenset(
    _normalized_key(key)
    for key in (
        *METADATA_STRIP_KEYS,
        "trace_ref", "usage_ref", "private_answer_ref", "foundation_model_id",
        "prompt_version", "internal_verdict", "internal_state",
    )
)
_SERIALIZED_KEY = re.compile(r"[\"']?([a-zA-Z_][a-zA-Z0-9_-]*)[\"']?\s*[:=]")


class QuestionEvaluationRecord(CanonicalBaseModel):
    """One ordered output question, including explicit non-assessment records."""

    question_id: str
    question_index: int = Field(ge=0)
    group_ids: list[str] = Field(default_factory=list)
    question_sha256: str = Field(pattern=r"^[0-9a-f]{64}$")
    evaluable: bool
    evaluation: CanonicalEvaluationResult | None = None
    diagnostic: str | None = None

    @property
    def assessed(self) -> bool:
        return bool(
            self.evaluation is not None
            and self.evaluation.evaluable
            and self.evaluation.verdict != EvaluationVerdict.NOT_RUN
        )


class CampaignEvaluationResult(CanonicalEvaluationResult):
    """Canonical-compatible quality aggregate, not an execution-success verdict.

    evaluable_question_count counts structurally assessable questions regardless
    of assessor availability; evaluated_question_count counts actual assessments.
    A zero digest denotes absent content only; present content is always hashed.
    """

    per_question_evaluations: list[QuestionEvaluationRecord] = Field(default_factory=list)
    aggregate_kind: Literal["arithmetic_mean_assessed_questions"] = "arithmetic_mean_assessed_questions"
    execution_completed: bool
    evaluable_question_count: int = Field(ge=0)
    evaluated_question_count: int = Field(ge=0)
    missing_question_ids: list[str] = Field(default_factory=list)
    missing_evaluation_question_ids: list[str] = Field(default_factory=list)
    unevaluable_question_ids: list[str] = Field(default_factory=list)
    diagnostics: list[str] = Field(default_factory=list)


def _sha256(payload: Any) -> str:
    return hashlib.sha256(canonical_json_dump(payload).encode("utf-8")).hexdigest()


def _guard_visible_payload(payload: Any) -> None:
    """Reject serialized private views before even an injected judge sees them."""
    if isinstance(payload, dict):
        for key, value in payload.items():
            normalized = _normalized_key(key)
            if normalized in _ANSWER_KEYS:
                raise GoldSmugglingForbiddenError(f"Scoring view contains forbidden gold key '{key}'")
            if normalized in _INTERNAL_KEYS:
                raise SecurityLeakageError(f"Scoring view contains internal metadata key '{key}'")
            _guard_visible_payload(value)
    elif isinstance(payload, (list, tuple)):
        for value in payload:
            _guard_visible_payload(value)
    elif isinstance(payload, str):
        scan_text_for_security_leaks(payload)
        for match in _SERIALIZED_KEY.finditer(payload):
            key = match.group(1)
            normalized = _normalized_key(key)
            # Plain IELTS instructions may say "Answer:"; serialized answer
            # objects are already checked by the existing security scanner.
            if normalized in _ANSWER_KEYS and normalized != "answer":
                raise GoldSmugglingForbiddenError(f"Scoring text contains forbidden gold key '{key}'")
            if normalized in _INTERNAL_KEYS:
                raise SecurityLeakageError(f"Scoring text contains internal metadata key '{key}'")


def _question_inputs(content: NeutralOutput) -> list[dict[str, Any]]:
    """Allowlist all views and guard the entire set before the first dispatch."""
    questions = [
        question.model_dump(mode="json", include=set(NeutralQuestion.model_fields))
        for question in content.questions
    ]
    _guard_visible_payload(content.context_text)
    for question in questions:
        _guard_visible_payload(question)
    return questions


def _validated_assessment(
    assessment: Any,
    evaluator: NeutralEvaluator,
    dataset_item_id: str,
    question_sha256: str,
) -> CanonicalEvaluationResult | None:
    if assessment is None:
        return None
    if not isinstance(assessment, CanonicalEvaluationResult):
        raise ValueError("Independent evaluator returned a malformed evaluation record")
    if assessment.dataset_item_id != dataset_item_id:
        raise ValueError("Independent evaluation dataset does not match the scored output")
    if assessment.rubric_version != evaluator.rubric.rubric_version:
        raise ValueError("Independent evaluation rubric does not match the configured rubric")
    if assessment.evaluator_version != evaluator.evaluator_version:
        raise ValueError("Independent evaluation evaluator version does not match the configured evaluator")
    if assessment.output_sha256 != question_sha256:
        raise ValueError("Independent evaluation hash does not match the assessed question view")
    return assessment.model_copy(deep=True)


def _evaluate_question(
    evaluator: NeutralEvaluator,
    dataset_item_id: str,
    context_text: str,
    question: dict[str, Any],
    index: int,
    group_ids: list[str],
    context_metadata: dict[str, Any] | None = None,
) -> QuestionEvaluationRecord:
    evaluable = bool(context_text.strip() and question["text"].strip() and question["instructions"].strip())
    if evaluable:
        view = project_to_solver_view(context_text=context_text, question_data=question)
        context_text = view.context_text
        question = view.question.model_dump(mode="json")
    payload = {"context_text": context_text, "question": question}
    question_sha = _sha256(payload)
    assessment = None
    diagnostic = None
    if evaluable:
        eval_kwargs = {
            "dataset_item_id": dataset_item_id,
            "passage_text": context_text,
            "question_data": question,
            "raw_output_text": canonical_json_dump(payload),
        }
        if context_metadata:
            eval_kwargs["context_metadata"] = context_metadata
        assessment = _validated_assessment(
            evaluator.evaluate_item(**eval_kwargs),
            evaluator, dataset_item_id, question_sha,
        )
        if assessment is None:
            diagnostic = f"{question['question_id']}: independent evaluation missing"
        elif not assessment.evaluable or assessment.verdict == EvaluationVerdict.NOT_RUN:
            diagnostic = f"{question['question_id']}: {assessment.abstention_reason or 'independent assessment not run'}"
        elif assessment.verdict != EvaluationVerdict.PASS:
            diagnostic = f"{question['question_id']}: {assessment.abstention_reason or assessment.verdict.value}"
    else:
        diagnostic = f"{question['question_id']}: context, question text or instructions missing; cannot evaluate"
    return QuestionEvaluationRecord(
        question_id=question["question_id"], question_index=index, group_ids=group_ids,
        question_sha256=question_sha, evaluable=evaluable,
        evaluation=assessment, diagnostic=diagnostic,
    )


def _semantic_means(
    assessments: list[CanonicalEvaluationResult],
) -> tuple[dict[str, float], list[str]]:
    scores: dict[str, float] = {}
    diagnostics: list[str] = []
    if not assessments:
        return scores, diagnostics
    for dimension in RubricDimension:
        values = [assessment.semantic_scores.get(dimension.value) for assessment in assessments]
        if not all(
            isinstance(value, (int, float)) and not isinstance(value, bool)
            and math.isfinite(value) and 1.0 <= value <= 5.0
            for value in values
        ):
            diagnostics.append(f"Missing or invalid semantic dimension {dimension.value}; aggregate dimension omitted")
            continue
        scores[dimension.value] = math.fsum(values) / len(assessments)
    return scores, diagnostics


def _aggregate_verdict(
    assessments: list[CanonicalEvaluationResult],
    diagnostics: list[str],
) -> EvaluationVerdict:
    if not assessments:
        return EvaluationVerdict.NOT_RUN
    if any(assessment.verdict == EvaluationVerdict.FAIL for assessment in assessments):
        return EvaluationVerdict.FAIL
    if diagnostics or any(assessment.verdict == EvaluationVerdict.UNCERTAIN for assessment in assessments):
        return EvaluationVerdict.UNCERTAIN
    return EvaluationVerdict.PASS


def score_campaign_output(
    result: GenerationResult,
    evaluator: NeutralEvaluator,
) -> CampaignEvaluationResult:
    """Score both domains via their existing NeutralEvaluator item contract."""
    content = result.generated_content
    diagnostics: list[str] = []
    records: list[QuestionEvaluationRecord] = []
    missing_question_ids: list[str] = []
    if content is None:
        diagnostics.append("Output missing: cannot evaluate")
    elif result.output_availability not in (OutputAvailability.PARSEABLE, OutputAvailability.NORMALIZED):
        diagnostics.append("Output is not parseable: cannot evaluate")
    else:
        questions = _question_inputs(content)
        present_ids = {question["question_id"] for question in questions}
        missing_question_ids = list(dict.fromkeys(
            question_id for group in content.question_groups for question_id in group.question_ids
            if question_id not in present_ids
        ))
        diagnostics.extend(f"{question_id}: question referenced by group is missing" for question_id in missing_question_ids)
        if not questions:
            diagnostics.append("Output contains no questions: cannot evaluate")
        is_grammar = "grammar" in result.dataset_item_id.lower() or result.task_type == "GRAMMAR_EXERCISE"
        context_meta: dict[str, Any] = {"is_grammar": True} if is_grammar else {}
        if is_grammar:
            try:
                from app.experiment.final_dataset import FinalDatasetRegistry
                registry = FinalDatasetRegistry()
                tasks = registry.build_grammar_final_tasks()
                task_map = {t.dataset_item_id: t.rule_pack for t in tasks}
                if result.dataset_item_id in task_map:
                    context_meta["rule_pack"] = task_map[result.dataset_item_id]
            except Exception:
                pass
        records = [
            _evaluate_question(
                evaluator, result.dataset_item_id, content.context_text, question, index,
                [group.group_id for group in content.question_groups if question["question_id"] in group.question_ids],
                context_metadata=context_meta,
            )
            for index, question in enumerate(questions)
        ]
    diagnostics.extend(record.diagnostic for record in records if record.diagnostic)
    assessments = [record.evaluation for record in records if record.assessed]
    semantic_scores, semantic_diagnostics = _semantic_means(assessments)
    diagnostics.extend(semantic_diagnostics)
    verdict = _aggregate_verdict(assessments, diagnostics)
    evaluable_count = sum(record.evaluable for record in records)
    missing_evaluation_ids = [record.question_id for record in records if record.evaluable and record.evaluation is None]
    unevaluable_ids = [
        record.question_id for record in records
        if not record.evaluable or (record.evaluation is not None and not record.assessed)
    ]
    return CampaignEvaluationResult(
        evaluation_id=f"eval-campaign-{uuid4().hex[:12]}",
        dataset_item_id=result.dataset_item_id,
        output_sha256=_sha256(content.model_dump(mode="json")) if content is not None else "0" * 64,
        rubric_version=evaluator.rubric.rubric_version,
        evaluator_version=evaluator.evaluator_version,
        evaluable=evaluable_count > 0,
        hard_checks={
            "has_content": content is not None,
            "has_questions": bool(records),
            "all_questions_evaluated": bool(records) and len(assessments) == len(records),
            "question_groups_complete": not missing_question_ids,
        },
        semantic_scores=semantic_scores,
        task_validity={"all_questions_pass": verdict == EvaluationVerdict.PASS},
        verdict=verdict,
        abstention_reason="; ".join(diagnostics) or None,
        evidence_refs=list(dict.fromkeys(ref for assessment in assessments for ref in assessment.evidence_refs)),
        per_question_evaluations=records,
        execution_completed=result.execution_status == ExecutionStatus.COMPLETED,
        evaluable_question_count=evaluable_count,
        evaluated_question_count=len(assessments),
        missing_question_ids=missing_question_ids,
        missing_evaluation_question_ids=missing_evaluation_ids,
        unevaluable_question_ids=unevaluable_ids,
        diagnostics=diagnostics,
    )
