"""Offline RG10 scoring integrity through the public campaign scorer boundary."""

from __future__ import annotations

import hashlib
import json
from typing import Any

import pytest
from pydantic import ConfigDict

from app.contracts.artifact import canonical_json_dump
from app.contracts.research import (
    ExecutionStatus,
    ExperimentAssignment,
    GenerationResult,
    GrammarQuestionType,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    StandaloneGroupType,
)
from app.contracts.solver import SecurityLeakageError
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import (
    CanonicalEvaluationResult,
    EvaluationVerdict,
    GrammarRubricProfile,
    RubricDimension,
    RubricProfile,
)
from app.experiment.blind_review import GoldSmugglingForbiddenError
from app.experiment.campaign_runner import IndependentCampaignScorer


RUBRIC_VERSION = "rubric-qgeval-v2.0"
CONTEXT = (
    "Negative adverbials at the beginning of a clause require auxiliary inversion. "
    "The scientific survey also describes how researchers compare different observations."
)


class RecordingEvaluator(NeutralEvaluator):
    """Deterministic contract double; never creates a provider or performs I/O."""

    def __init__(
        self,
        responses: tuple[Any, ...],
        rubric: RubricProfile | None = None,
        *,
        bind_hash: bool = True,
    ) -> None:
        super().__init__(rubric=rubric or RubricProfile(rubric_version=RUBRIC_VERSION),
                         evaluator_version="neutral-eval-v2.0-test")
        self.responses = responses
        self.calls: list[dict[str, Any]] = []
        self.bind_hash = bind_hash

    def evaluate_item(self, **kwargs: Any) -> CanonicalEvaluationResult | None:
        response = self.responses[len(self.calls)]
        self.calls.append(kwargs)
        if isinstance(response, Exception):
            raise response
        if response is None or not self.bind_hash:
            return response
        payload = kwargs.get("raw_output_text") or json.dumps(kwargs["question_data"], sort_keys=True, default=str)
        return response.model_copy(update={"output_sha256": hashlib.sha256(payload.encode("utf-8")).hexdigest()})


def _evaluation(
    score: float = 4.0,
    verdict: EvaluationVerdict = EvaluationVerdict.PASS,
    *,
    evaluable: bool = True,
    rubric_version: str = RUBRIC_VERSION,
) -> CanonicalEvaluationResult:
    return CanonicalEvaluationResult(
        evaluation_id=f"question-evaluation-{score}-{verdict.value}",
        dataset_item_id="item-neutral",
        output_sha256="a" * 64,
        rubric_version=rubric_version,
        evaluator_version="neutral-eval-v2.0-test",
        evaluable=evaluable,
        hard_checks={"schema_valid": True},
        semantic_scores={dimension.value: score for dimension in RubricDimension} if evaluable else {},
        task_validity={"independent_check": evaluable},
        verdict=verdict,
        abstention_reason=None if evaluable else "Assessor cannot evaluate this question",
        evidence_refs=["source-span:1"] if evaluable else [],
    )


def _content(domain: str = "READING", count: int = 3) -> NeutralOutput:
    question_types = (
        (GrammarQuestionType.GRAMMAR_MCQ, GrammarQuestionType.GRAMMAR_GAP, GrammarQuestionType.GRAMMAR_CORRECTION)
        if domain == "GRAMMAR"
        else (StandaloneGroupType.MCQ_SINGLE, StandaloneGroupType.TFNG, StandaloneGroupType.SHORT_ANSWER)
    )
    questions = [
        NeutralQuestion(
            question_id=f"q-{index + 1}",
            question_type=question_types[index % len(question_types)],
            text=f"Question {index + 1}: Which observation or grammatical construction is supported?",
            options=["First possibility", "Second possibility"] if index == 0 else [],
            instructions="Use the supplied context to answer independently.",
        )
        for index in range(count)
    ]
    groups = [
        NeutralQuestionGroup(group_id=f"group-{index + 1}", question_ids=[question.question_id])
        for index, question in enumerate(questions)
    ]
    return NeutralOutput(context_text=CONTEXT, question_groups=groups, questions=questions)


def _result(
    domain: str = "READING",
    *,
    content: NeutralOutput | None = None,
    status: ExecutionStatus = ExecutionStatus.COMPLETED,
    availability: OutputAvailability = OutputAvailability.NORMALIZED,
    arm: str = "A",
) -> GenerationResult:
    return GenerationResult(
        run_id=f"private-run-{arm}",
        dataset_item_id="item-neutral",
        configuration_id=arm,
        task_type="GRAMMAR_EXERCISE" if domain == "GRAMMAR" else "READING_SINGLE_PASSAGE",
        execution_status=status,
        output_availability=availability,
        generated_content=content,
        private_answer_ref=f"private-answer-{arm}",
        trace_ref=f"internal-trace-{arm}",
        usage_ref=f"private-usage-{arm}",
    )


def _assignment(arm: str = "A") -> ExperimentAssignment:
    return ExperimentAssignment(
        assignment_id=f"assignment-{arm}",
        dataset_item_id="item-neutral",
        configuration_id=arm,
        attempt_number=1,
    )


def _score(
    evaluator: RecordingEvaluator,
    result: GenerationResult,
    **kwargs: Any,
) -> CanonicalEvaluationResult:
    scorer = IndependentCampaignScorer(evaluator=evaluator)
    return scorer.score_generation_result(result=result, assignment=_assignment(result.configuration_id), **kwargs)


def _output_hash(content: NeutralOutput) -> str:
    serialized = canonical_json_dump(content.model_dump(mode="json"))
    return hashlib.sha256(serialized.encode("utf-8")).hexdigest()


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_scores_every_question_and_retains_records_with_arithmetic_means(domain):
    evaluator = RecordingEvaluator((_evaluation(5), _evaluation(4), _evaluation(3, EvaluationVerdict.FAIL)))
    content = _content(domain)

    scored = _score(evaluator, _result(domain, content=content))

    assert len(evaluator.calls) == 3
    assert isinstance(scored, CanonicalEvaluationResult)
    assert scored.evaluable_question_count == 3
    assert scored.evaluated_question_count == 3
    assert scored.execution_completed is True
    assert scored.aggregate_kind == "arithmetic_mean_assessed_questions"
    assert scored.semantic_scores == {dimension.value: 4.0 for dimension in RubricDimension}
    assert scored.verdict == EvaluationVerdict.FAIL
    assert [record.question_id for record in scored.per_question_evaluations] == ["q-1", "q-2", "q-3"]
    assert [record.evaluation.verdict for record in scored.per_question_evaluations] == [
        EvaluationVerdict.PASS, EvaluationVerdict.PASS, EvaluationVerdict.FAIL,
    ]
    assert [record.group_ids for record in scored.per_question_evaluations] == [["group-1"], ["group-2"], ["group-3"]]
    assert len({record.question_sha256 for record in scored.per_question_evaluations}) == 3
    assert scored.output_sha256 == _output_hash(content)
    assert all(record.question_sha256 != scored.output_sha256 for record in scored.per_question_evaluations)
    assert all(record.evaluation.output_sha256 == record.question_sha256 for record in scored.per_question_evaluations)


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("status", [ExecutionStatus.FAILED_VALIDATION, ExecutionStatus.TIMED_OUT])
def test_failed_parseable_output_is_assessed_without_becoming_completed(domain, status):
    evaluator = RecordingEvaluator((_evaluation(), _evaluation(), _evaluation()))
    result = _result(domain, content=_content(domain), status=status, availability=OutputAvailability.PARSEABLE)

    scored = _score(evaluator, result)

    assert len(evaluator.calls) == 3
    assert scored.evaluable is True
    assert scored.evaluated_question_count == 3
    assert scored.execution_completed is False
    assert scored.verdict == EvaluationVerdict.PASS
    assert result.execution_status == status
    assert result.output_availability == OutputAvailability.PARSEABLE


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("status", [ExecutionStatus.COMPLETED, ExecutionStatus.FAILED_VALIDATION])
def test_missing_output_never_fabricates_scores_or_passes(domain, status):
    evaluator = RecordingEvaluator(())

    scored = _score(evaluator, _result(domain, status=status, availability=OutputAvailability.NONE))

    assert evaluator.calls == []
    assert scored.evaluated_question_count == 0
    assert scored.evaluable_question_count == 0
    assert scored.evaluable is False
    assert scored.execution_completed is (status == ExecutionStatus.COMPLETED)
    assert scored.verdict == EvaluationVerdict.NOT_RUN
    assert scored.semantic_scores == {}
    assert scored.per_question_evaluations == []
    assert scored.diagnostics
    assert "cannot evaluate" in scored.abstention_reason.lower()


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_empty_question_list_does_not_evaluate_empty_dictionary(domain):
    evaluator = RecordingEvaluator(())
    content = _content(domain, count=0)

    scored = _score(evaluator, _result(domain, content=content))

    assert evaluator.calls == []
    assert scored.evaluated_question_count == 0
    assert scored.evaluable_question_count == 0
    assert scored.verdict == EvaluationVerdict.NOT_RUN
    assert scored.semantic_scores == {}
    assert scored.output_sha256 == _output_hash(content)
    assert scored.diagnostics


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_missing_evaluation_is_explicit_and_does_not_count_as_assessed(domain):
    evaluator = RecordingEvaluator((_evaluation(5), None, _evaluation(3)))

    scored = _score(evaluator, _result(domain, content=_content(domain)))

    assert len(evaluator.calls) == 3
    assert scored.evaluable_question_count == 3
    assert scored.evaluated_question_count == 2
    assert scored.verdict == EvaluationVerdict.UNCERTAIN
    assert scored.semantic_scores == {dimension.value: 4.0 for dimension in RubricDimension}
    assert scored.missing_evaluation_question_ids == ["q-2"]
    assert scored.per_question_evaluations[1].evaluation is None
    assert scored.per_question_evaluations[1].diagnostic
    assert scored.abstention_reason


def test_unevaluable_evaluation_is_retained_without_inventing_score():
    unavailable = _evaluation(verdict=EvaluationVerdict.NOT_RUN, evaluable=False)
    evaluator = RecordingEvaluator((_evaluation(5), unavailable, _evaluation(3)))

    scored = _score(evaluator, _result(content=_content()))

    assert scored.evaluated_question_count == 2
    assert scored.verdict == EvaluationVerdict.UNCERTAIN
    assert scored.unevaluable_question_ids == ["q-2"]
    assert scored.per_question_evaluations[1].evaluation.verdict == unavailable.verdict
    assert scored.per_question_evaluations[1].evaluation.abstention_reason == unavailable.abstention_reason
    assert scored.per_question_evaluations[1].evaluation.semantic_scores == {}


def test_all_missing_evaluations_remain_not_run():
    evaluator = RecordingEvaluator((None, None, None))

    scored = _score(evaluator, _result(content=_content()))

    assert len(evaluator.calls) == 3
    assert scored.evaluable_question_count == 3
    assert scored.evaluated_question_count == 0
    assert scored.verdict == EvaluationVerdict.NOT_RUN
    assert scored.semantic_scores == {}
    assert scored.missing_evaluation_question_ids == ["q-1", "q-2", "q-3"]


@pytest.mark.parametrize(
    "responses, expected",
    [
        ((_evaluation(), _evaluation(), _evaluation()), EvaluationVerdict.PASS),
        ((_evaluation(), _evaluation(verdict=EvaluationVerdict.UNCERTAIN), _evaluation()), EvaluationVerdict.UNCERTAIN),
        ((_evaluation(verdict=EvaluationVerdict.FAIL), None, _evaluation(verdict=EvaluationVerdict.UNCERTAIN)), EvaluationVerdict.FAIL),
    ],
)
def test_aggregate_verdict_obeys_fail_uncertain_pass_precedence(responses, expected):
    evaluator = RecordingEvaluator(responses)

    scored = _score(evaluator, _result(content=_content()))

    assert scored.verdict == expected


def test_partial_output_missing_group_question_cannot_receive_pass():
    content = _content(count=2)
    incomplete_group = NeutralQuestionGroup(group_id="expected-group", question_ids=["q-1", "q-2", "q-missing"])
    content = content.model_copy(update={"question_groups": [incomplete_group]})
    evaluator = RecordingEvaluator((_evaluation(), _evaluation()))

    scored = _score(evaluator, _result(content=content, status=ExecutionStatus.FAILED_VALIDATION,
                                      availability=OutputAvailability.PARSEABLE))

    assert scored.evaluated_question_count == 2
    assert scored.missing_question_ids == ["q-missing"]
    assert scored.verdict == EvaluationVerdict.UNCERTAIN
    assert scored.output_sha256 == _output_hash(content)
    assert scored.execution_completed is False


def test_whitespace_question_is_diagnosed_without_hiding_assessable_siblings():
    content = _content()
    invalid_question = content.questions[1].model_copy(update={"text": "   "})
    content = content.model_copy(update={"questions": [content.questions[0], invalid_question, content.questions[2]]})
    evaluator = RecordingEvaluator((_evaluation(), _evaluation()))

    scored = _score(evaluator, _result(content=content))

    assert len(evaluator.calls) == 2
    assert scored.evaluable_question_count == 2
    assert scored.evaluated_question_count == 2
    assert scored.unevaluable_question_ids == ["q-2"]
    assert scored.per_question_evaluations[1].evaluation is None
    assert scored.verdict == EvaluationVerdict.UNCERTAIN


def test_missing_semantic_dimension_is_not_zero_filled_or_reported_as_pass():
    incomplete = _evaluation().model_copy(update={"semantic_scores": {"clarity": 5.0}})
    evaluator = RecordingEvaluator((_evaluation(3), incomplete, _evaluation(4)))

    scored = _score(evaluator, _result(content=_content()))

    assert scored.semantic_scores == {"clarity": 4.0}
    assert scored.evaluated_question_count == 3
    assert scored.verdict == EvaluationVerdict.UNCERTAIN
    assert any("dimension" in diagnostic.lower() for diagnostic in scored.diagnostics)


def test_question_hash_changes_with_context_and_full_hash_covers_order_and_groups():
    original = _content().model_copy(update={"context_text": CONTEXT + " Étude: données vérifiées."})
    changed_context = original.model_copy(update={"context_text": original.context_text + " Additional source context."})
    reordered = original.model_copy(update={"questions": list(reversed(original.questions))})
    regrouped = original.model_copy(update={"question_groups": list(reversed(original.question_groups))})
    results = [
        _score(RecordingEvaluator((_evaluation(), _evaluation(), _evaluation())), _result(content=content))
        for content in (original, changed_context, reordered, regrouped)
    ]

    assert len({scored.output_sha256 for scored in results}) == 4
    assert results[0].per_question_evaluations[0].question_sha256 != results[1].per_question_evaluations[0].question_sha256
    assert original.context_text == CONTEXT + " Étude: données vérifiées."


def test_configured_rubric_mismatch_rejects_instead_of_replacing_injected_evaluator():
    evaluator = RecordingEvaluator((_evaluation(),))
    scorer = IndependentCampaignScorer(evaluator=evaluator)

    with pytest.raises(ValueError, match="rubric"):
        scorer.score_generation_result(result=_result(content=_content(count=1)), assignment=_assignment(),
                                       rubric_version="different-frozen-rubric")

    assert evaluator.calls == []
    assert scorer.evaluator is evaluator


def test_constructor_rejects_explicit_injected_rubric_mismatch():
    evaluator = RecordingEvaluator((_evaluation(),))

    with pytest.raises(ValueError, match="rubric"):
        IndependentCampaignScorer(evaluator=evaluator, rubric_version="different-frozen-rubric")


def test_grammar_uses_existing_neutral_contract_and_preserves_grammar_rubric():
    rubric = GrammarRubricProfile(min_grounding_score=4.5)
    evaluator = RecordingEvaluator((_evaluation(5, rubric_version=rubric.rubric_version),) * 3, rubric=rubric)

    scored = _score(evaluator, _result("GRAMMAR", content=_content("GRAMMAR")))

    assert len(evaluator.calls) == 3
    assert [call["question_data"]["question_type"] for call in evaluator.calls] == [
        "GRAMMAR_MCQ", "GRAMMAR_GAP", "GRAMMAR_CORRECTION",
    ]
    assert all(call["passage_text"] == CONTEXT for call in evaluator.calls)
    assert scored.rubric_version == rubric.rubric_version
    assert evaluator.rubric.min_grounding_score == 4.5
    assert scored.verdict == EvaluationVerdict.PASS


def test_evaluator_returned_wrong_dataset_or_rubric_is_rejected():
    wrong = _evaluation().model_copy(update={"dataset_item_id": "other-item"})
    evaluator = RecordingEvaluator((wrong, _evaluation(), _evaluation()))

    with pytest.raises(ValueError, match="dataset"):
        _score(evaluator, _result(content=_content()))

    wrong = _evaluation().model_copy(update={"rubric_version": "other-rubric"})
    evaluator = RecordingEvaluator((wrong, _evaluation(), _evaluation()))
    with pytest.raises(ValueError, match="rubric"):
        _score(evaluator, _result(content=_content()))

    stale = _evaluation()
    evaluator = RecordingEvaluator((stale,), bind_hash=False)
    with pytest.raises(ValueError, match="hash"):
        _score(evaluator, _result(content=_content(count=1)))

    evaluator = RecordingEvaluator(({"verdict": "PASS"},), bind_hash=False)
    with pytest.raises(ValueError, match="evaluation"):
        _score(evaluator, _result(content=_content(count=1)))


def test_assignment_dataset_mismatch_rejects_before_evaluator_dispatch():
    evaluator = RecordingEvaluator((_evaluation(),))
    scorer = IndependentCampaignScorer(evaluator=evaluator)
    assignment = _assignment().model_copy(update={"dataset_item_id": "other-item"})

    with pytest.raises(ValueError, match="dataset"):
        scorer.score_generation_result(result=_result(content=_content(count=1)), assignment=assignment)

    assert evaluator.calls == []


def test_arm_metadata_private_refs_and_internal_trace_never_enter_evaluator():
    class ExtendedQuestion(NeutralQuestion):
        model_config = ConfigDict(extra="allow")

    content = _content(count=1)
    extended = ExtendedQuestion(**content.questions[0].model_dump(), configuration_id="C", trace="private trace",
                                foundation_model_id="private-model", generator_verdict="PASS")
    content = content.model_copy(update={"questions": [extended]})
    evaluator_a = RecordingEvaluator((_evaluation(),))
    evaluator_c = RecordingEvaluator((_evaluation(),))

    scored_a = _score(evaluator_a, _result(content=content, arm="A"))
    scored_c = _score(evaluator_c, _result(content=content, arm="C"))

    assert evaluator_a.calls == evaluator_c.calls
    assert set(evaluator_a.calls[0]) == {"dataset_item_id", "passage_text", "question_data", "raw_output_text"}
    assert set(evaluator_a.calls[0]["question_data"]) == {
        "question_id", "question_type", "text", "options", "instructions",
    }
    assert json.loads(evaluator_a.calls[0]["raw_output_text"]) == {
        "context_text": CONTEXT,
        "question": evaluator_a.calls[0]["question_data"],
    }
    assert scored_a.output_sha256 == scored_c.output_sha256 == _output_hash(content)
    assert scored_a.semantic_scores == scored_c.semantic_scores
    assert scored_a.verdict == scored_c.verdict


@pytest.mark.parametrize("key", ["gold_answer", "reference_answer", "correct_answer", "goldAnswer", "referenceAnswer"])
def test_gold_and_reference_fields_fail_closed_before_evaluator_dispatch(key):
    class ExtendedQuestion(NeutralQuestion):
        model_config = ConfigDict(extra="allow")

    content = _content(count=1)
    contaminated = ExtendedQuestion(**content.questions[0].model_dump(), **{key: "sealed answer"})
    content = content.model_copy(update={"questions": [contaminated]})
    evaluator = RecordingEvaluator((_evaluation(),))

    with pytest.raises(GoldSmugglingForbiddenError):
        _score(evaluator, _result(content=content))

    assert evaluator.calls == []


@pytest.mark.parametrize("field", ["context_text", "text", "instructions", "options"])
@pytest.mark.parametrize(
    "hidden_payload",
    [
        '{"gold_answer": "sealed answer"}',
        '{"referenceAnswer": "sealed answer"}',
        '{"configuration_id": "C", "trace_ref": "private trace"}',
        "generator_proposed_answer: private answer",
    ],
)
def test_serialized_leaks_in_visible_text_fail_closed_before_evaluator_dispatch(field, hidden_payload):
    content = _content(count=1)
    if field == "context_text":
        content = content.model_copy(update={"context_text": hidden_payload})
    else:
        value = [hidden_payload, "Safe distractor"] if field == "options" else hidden_payload
        question = content.questions[0].model_copy(update={field: value})
        content = content.model_copy(update={"questions": [question]})
    evaluator = RecordingEvaluator((_evaluation(),))

    with pytest.raises((GoldSmugglingForbiddenError, SecurityLeakageError, ValueError)):
        _score(evaluator, _result(content=content))

    assert evaluator.calls == []
