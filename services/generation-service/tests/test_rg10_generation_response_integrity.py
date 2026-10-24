"""Offline behavioral regressions for response-originated research generation."""
from __future__ import annotations

import hashlib
import json
from dataclasses import replace

import pytest

from app.contracts.research import (
    ExecutionStatus, GrammarExerciseType, GrammarRulePack, GrammarTask,
    OutputAvailability, ReadingTask, SourceRef, StandaloneGrammarRequest,
    StandaloneGroupType, StandaloneReadingRequest,
)
from app.experiment.runners import (
    ConfigurationARunner, ConfigurationBRunner, ConfigurationCRunner,
    DefaultRecordingExperimentClient, LLMDispatchResponse,
)

MODEL = "minimax/MiniMax-Text-01"
PASSAGE = "Researchers restored wetlands. Otters returned after water quality improved."
RUNNERS = {"A": ConfigurationARunner, "B": ConfigurationBRunner, "C": ConfigurationCRunner}


def request_for(domain, arm, count=2, exercise_type=GrammarExerciseType.GAP_FILL):
    if domain == "READING":
        return StandaloneReadingRequest(
            run_id=f"integrity-{domain}-{arm}", dataset_item_id="wetland-item",
            configuration_id=arm, source_pack_id="wetland-source",
            task=ReadingTask(requested_groups=[StandaloneGroupType.TFNG],
                             requested_question_count=count, difficulty="B2"),
        )
    source = SourceRef(source_id="grammar-source", source_family="public-grammar",
                       source_version="1", source_sha256="a" * 64,
                       license="CC0", provenance_uri="https://example.org/grammar")
    pack = GrammarRulePack(rule_pack_id="past-perfect", source=source,
                           topic="Past perfect", level="B2", rule_ids=["past-perfect-1"],
                           applicability=["An event completed before another past event."],
                           examples=["They had left before we arrived."])
    return StandaloneGrammarRequest(
        run_id=f"integrity-{domain}-{arm}", dataset_item_id="grammar-item",
        configuration_id=arm, rule_pack=pack,
        task=GrammarTask(grammar_rule_pack_ref=pack.rule_pack_id,
                         exercise_type=exercise_type, requested_question_count=count,
                         difficulty="B2"),
    )


def candidate(domain, marker="alpha", count=2):
    kind = "TFNG" if domain == "READING" else "GRAMMAR_GAP"
    return {
        "context_text": PASSAGE if domain == "READING" else f"A {marker} research expedition.",
        "question_groups": [{"group_id": "g1", "question_ids": [f"q{i+1}" for i in range(count)]}],
        "questions": [
            {"question_id": f"q{i+1}", "question_type": kind,
             "text": f"{marker} statement {i+1}" if domain == "READING" else f"{marker}: They ____ left before noon ({i+1}).",
             "instructions": "Write TRUE, FALSE or NOT GIVEN." if domain == "READING" else "Write one verb.",
             "options": [], "proposed_answer": "TRUE" if domain == "READING" else "had",
             "private_rationale": "PRIVATE-CANDIDATE-RATIONALE"}
            for i in range(count)
        ],
        "gold_answer": "FORBIDDEN-GOLD-SENTINEL",
        "internal_verdict": "FORBIDDEN-INTERNAL-SENTINEL",
    }


def scripted_response(text, model_id=MODEL):
    raw = json.dumps(text) if not isinstance(text, str) else text
    return LLMDispatchResponse(raw_text=raw, prompt_tokens=11, completion_tokens=7,
                               total_tokens=18, latency_ms=1.0, confidence="ESTIMATED",
                               cost_usd=None, model_id=model_id)


class ScriptedClient:
    def __init__(self, responses):
        self.responses = list(responses)
        self.recorded_dispatches = []

    def dispatch(self, **kwargs):
        self.recorded_dispatches.append(kwargs)
        response = self.responses.pop(0)
        if isinstance(response, Exception):
            raise response
        return response


def responses_for(domain, arm, output):
    draft = scripted_response(output)
    if arm == "A":
        return [draft]
    if arm == "B":
        return [draft, scripted_response({"verdict": "REVISION_NEEDED", "score": 3.5,
                                          "issues": ["Use clearer wording."]}), draft]
    answer = "TRUE" if domain == "READING" else "had"
    return [draft, scripted_response({"status": "APPROVED", "issues": []}),
            scripted_response({"answers": [{"question_id": q["question_id"],
                                             "answer": answer, "ambiguous": False}
                                            for q in output["questions"]]}),
            scripted_response({"accepted": True, "issues": []})]


def generate(domain, arm, client, *, count=2, **kwargs):
    runner = RUNNERS[arm](client=client)
    method = runner.generate_reading if domain == "READING" else runner.generate_grammar
    args = {"request": request_for(domain, arm, count), "prompt_version": f"integrity-{arm}-v1",
            "foundation_model_id": MODEL, **kwargs}
    if domain == "READING":
        args["passage_text"] = PASSAGE
    values = method(**args)
    return values[0], values[-1], values[1] if arm != "A" else None


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_all_paths_change_when_only_model_response_changes(domain, arm):
    outputs = []
    for marker in ("response-alpha", "response-beta"):
        supplied = candidate(domain, marker)
        client = ScriptedClient(responses_for(domain, arm, supplied))
        result, usage, _ = generate(domain, arm, client)
        assert result.execution_status == ExecutionStatus.COMPLETED
        assert result.generated_content is not None
        assert [q.text for q in result.generated_content.questions] == [q["text"] for q in supplied["questions"]]
        assert len(result.generated_content.questions) == 2
        assert usage["confidence"] == "ESTIMATED"
        outputs.append(result.generated_content)
    assert outputs[0] != outputs[1]


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_malformed_provider_text_never_becomes_fabricated_questions(domain, arm):
    client = ScriptedClient([scripted_response("this is not JSON")])
    result, usage, _ = generate(domain, arm, client)
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "RAW_OUTPUT_UNPARSEABLE"
    assert result.output_availability == OutputAvailability.RAW_ONLY
    assert result.generated_content is None
    assert usage["call_count"] == 1


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_actual_model_mismatch_stops_dispatch_without_fallback(domain, arm):
    client = ScriptedClient([scripted_response(candidate(domain), model_id="other/model")])
    result, usage, _ = generate(domain, arm, client)
    assert result.execution_status == ExecutionStatus.FAILED_RUNTIME
    assert result.failure_code == "MODEL_IDENTITY_MISMATCH"
    assert usage["call_count"] == 1
    assert len(client.recorded_dispatches) == 1
    assert usage["provenance"]["dispatches"][0]["actual_model_id"] == "other/model"


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_missing_questions_preserves_assessable_partial_without_padding(domain, arm):
    supplied = candidate(domain, count=1)
    client = ScriptedClient(responses_for(domain, arm, supplied))
    result, _, _ = generate(domain, arm, client, count=2)
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.generated_content is not None
    assert len(result.generated_content.questions) == 1
    assert result.output_availability in (OutputAvailability.PARSEABLE, OutputAvailability.NORMALIZED)
    assert result.failure_code == "QUESTION_COUNT_MISMATCH"


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_provenance_binds_actual_prompt_responses_and_neutral_output(domain, arm):
    supplied = candidate(domain)
    responses = responses_for(domain, arm, supplied)
    client = ScriptedClient(responses)
    result, usage, trace = generate(domain, arm, client)
    provenance = usage["provenance"]
    assert provenance["prompt_version"] == f"integrity-{arm}-v1"
    assert provenance["configuration_id"] == arm
    for call, response, record in zip(client.recorded_dispatches, responses, provenance["dispatches"]):
        assert record["prompt_sha256"] == hashlib.sha256(call["prompt"].encode()).hexdigest()
        assert record["response_sha256"] == hashlib.sha256(response.raw_text.encode()).hexdigest()
        assert record["actual_model_id"] == MODEL
        assert len(record["config_sha256"]) == 64
    encoded = json.dumps(result.generated_content.model_dump(mode="json"), sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    assert provenance["normalized_output_sha256"] == hashlib.sha256(encoded.encode()).hexdigest()
    output_response = responses[2] if arm == "B" else responses[0]
    assert provenance["output_response_sha256"] == hashlib.sha256(output_response.raw_text.encode()).hexdigest()
    visible = json.dumps(result.model_dump(mode="json"))
    assert "FORBIDDEN-GOLD-SENTINEL" not in visible
    assert "FORBIDDEN-INTERNAL-SENTINEL" not in visible
    assert "PRIVATE-CANDIDATE-RATIONALE" not in visible
    for call in client.recorded_dispatches:
        if call["stage"] in ("REVIEWER", "BLIND_SOLVER"):
            assert "PRIVATE-CANDIDATE-RATIONALE" not in call["prompt"]
            assert "proposed_answer" not in call["prompt"]
            assert "FORBIDDEN-GOLD-SENTINEL" not in call["prompt"]
    if trace is not None:
        assert trace["provenance"] == provenance


@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_default_offline_client_cannot_claim_genuine_generation(arm):
    result, usage, _ = generate("READING", arm, DefaultRecordingExperimentClient())
    assert result.execution_status == ExecutionStatus.FAILED_RUNTIME
    assert result.failure_code == "PROVIDER_NOT_CONFIGURED"
    assert result.generated_content is None
    assert usage["confidence"] != "EXACT"
    assert usage["cost_usd"] is None
    assert usage["cost_source"] == "UNKNOWN"


def test_missing_usage_stays_unknown_and_is_not_inferred_from_words():
    response = replace(scripted_response(candidate("READING")), prompt_tokens=None,
                       completion_tokens=None, total_tokens=None, confidence="UNKNOWN")
    result, usage, _ = generate("READING", "A", ScriptedClient([response]))
    assert result.execution_status == ExecutionStatus.COMPLETED
    assert usage["prompt_tokens"] is None
    assert usage["completion_tokens"] is None
    assert usage["total_tokens"] is None
    assert usage["cost_usd"] is None
    assert usage["confidence"] == "UNKNOWN"
    assert usage["token_source"] == "UNKNOWN"
    assert usage["cost_source"] == "UNKNOWN"


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_b_uses_actual_critique_and_actual_revision_response(domain):
    draft, revised = candidate(domain, "draft"), candidate(domain, "revised")
    client = ScriptedClient([
        scripted_response(draft),
        scripted_response({"verdict": "REVISION_NEEDED", "score": 2.0,
                           "issues": ["Response-specific issue sentinel"]}),
        scripted_response(revised),
    ])
    result, usage, trace = generate(domain, "B", client)
    assert result.generated_content.questions[0].text == revised["questions"][0]["text"]
    assert draft["questions"][0]["text"] in client.recorded_dispatches[1]["prompt"]
    assert "Response-specific issue sentinel" in client.recorded_dispatches[2]["prompt"]
    assert usage["repair_count"] == 1
    assert trace["steps"][1]["internal_score"] == 2.0


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_b_exhausted_revisions_remains_rejected_and_keeps_last_candidate(domain):
    supplied = candidate(domain)
    client = ScriptedClient([
        scripted_response(supplied),
        scripted_response({"verdict": "REJECTED", "score": 1.0, "issues": ["Ambiguous"]}),
    ])
    result, usage, _ = generate(domain, "B", client, max_revisions=0)
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "SELF_CRITIQUE_REJECTED"
    assert result.generated_content is not None
    assert usage["repair_count"] == 0
    assert usage["call_count"] == 2


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_c_review_rejection_cannot_be_overridden_by_validator(domain):
    supplied = candidate(domain)
    client = ScriptedClient([
        scripted_response(supplied),
        scripted_response({"status": "REJECTED", "issues": ["Unsupported question"]}),
    ])
    result, usage, trace = generate(domain, "C", client, max_repairs=0)
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "REVIEW_REJECTED"
    assert result.generated_content is not None
    assert trace["internal_accepted_head"] is False
    assert usage["call_count"] == 2


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_c_repair_replays_review_solve_validation_on_actual_revised_content(domain):
    draft, revised = candidate(domain, "draft"), candidate(domain, "repaired")
    accepted_tail = responses_for(domain, "C", revised)[1:]
    client = ScriptedClient([
        scripted_response(draft),
        scripted_response({"status": "REJECTED", "issues": ["Fix draft sentinel"]}),
        scripted_response(revised), *accepted_tail,
    ])
    result, usage, trace = generate(domain, "C", client, max_repairs=1)
    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.generated_content.questions[0].text == revised["questions"][0]["text"]
    assert [c["stage"] for c in client.recorded_dispatches] == [
        "GENERATOR", "REVIEWER", "REPAIR", "REVIEWER", "BLIND_SOLVER", "VALIDATOR",
    ]
    assert "Fix draft sentinel" in client.recorded_dispatches[2]["prompt"]
    assert revised["questions"][0]["text"] in client.recorded_dispatches[3]["prompt"]
    assert usage["repair_count"] == 1
    assert trace["internal_accepted_head"] is True


@pytest.mark.parametrize("domain", ["READING", "GRAMMAR"])
def test_c_repair_exhaustion_keeps_actual_last_partial(domain):
    first, second = candidate(domain), candidate(domain, "still-short", count=1)
    client = ScriptedClient([scripted_response(first),
                             scripted_response({"status": "REJECTED", "issues": ["Bad"]}),
                             scripted_response(second)])
    result, usage, trace = generate(domain, "C", client, max_repairs=1)
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "QUESTION_COUNT_MISMATCH"
    assert len(result.generated_content.questions) == 1
    assert result.generated_content.questions[0].text == second["questions"][0]["text"]
    assert usage["repair_count"] == 1
    assert trace["internal_accepted_head"] is False


@pytest.mark.parametrize("stage", ["REVIEWER", "BLIND_SOLVER", "VALIDATOR"])
def test_c_malformed_control_response_preserves_candidate_without_acceptance(stage):
    supplied = candidate("READING")
    responses = responses_for("READING", "C", supplied)
    index = ["GENERATOR", "REVIEWER", "BLIND_SOLVER", "VALIDATOR"].index(stage)
    responses[index] = scripted_response("malformed control response")
    result, usage, trace = generate("READING", "C", ScriptedClient(responses[:index+1]))
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == f"{stage}_OUTPUT_UNPARSEABLE"
    assert result.generated_content is not None
    assert usage["call_count"] == index + 1
    assert trace["internal_accepted_head"] is False


def test_intermediate_timeout_keeps_prior_candidate_and_unknown_usage():
    client = ScriptedClient([scripted_response(candidate("READING")), TimeoutError("private network error")])
    result, usage, trace = generate("READING", "B", client)
    assert result.execution_status == ExecutionStatus.TIMED_OUT
    assert result.generated_content is not None
    assert usage["call_count"] == 2
    assert usage["total_tokens"] is None
    assert usage["confidence"] == "UNKNOWN"
    assert "private network error" not in json.dumps(trace)


def test_partial_schema_keeps_valid_response_questions_and_no_synthesized_items():
    supplied = candidate("READING")
    supplied["questions"][1] = {"question_id": "q2", "text": "Missing type and instructions"}
    result, _, _ = generate("READING", "A", ScriptedClient([scripted_response(supplied)]))
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "OUTPUT_SCHEMA_INVALID"
    assert len(result.generated_content.questions) == 1
    assert result.generated_content.questions[0].text == supplied["questions"][0]["text"]


def test_generation_receives_untruncated_source_and_complete_grammar_rules():
    long_passage = PASSAGE + " filler" * 200 + " FULL-SOURCE-END-SENTINEL"
    client = ScriptedClient([scripted_response(candidate("READING"))])
    ConfigurationARunner(client=client).generate_reading(
        request_for("READING", "A"), long_passage, "v1", MODEL)
    assert "FULL-SOURCE-END-SENTINEL" in client.recorded_dispatches[0]["prompt"]
    grammar_client = ScriptedClient([scripted_response(candidate("GRAMMAR"))])
    generate("GRAMMAR", "A", grammar_client)
    prompt = grammar_client.recorded_dispatches[0]["prompt"]
    assert "An event completed before another past event." in prompt
    assert "They had left before we arrived." in prompt


def test_reading_authoritative_source_excerpt_bound_from_frozen_input():
    supplied = {**candidate("READING"), "context_text": "An excerpt or modified model passage."}
    result, _, _ = generate("READING", "A", ScriptedClient([scripted_response(supplied)]))
    assert result.execution_status == ExecutionStatus.COMPLETED
    assert result.generated_content.context_text == PASSAGE

def test_provider_partial_exception_preserves_response_usage_and_assessable_output():
    from app.providers.errors import TruncatedOutputError
    from app.providers.models import UsageAccountingType, UsageReport
    raw = json.dumps(candidate("READING"))
    error = TruncatedOutputError(
        "private provider diagnostic", raw_text=raw,
        usage=UsageReport(prompt_tokens=23, completion_tokens=17, total_tokens=40,
                          accounting_type=UsageAccountingType.REPORTED),
    )
    result, usage, _ = generate("READING", "A", ScriptedClient([error]))
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "PROVIDER_OUTPUT_TRUNCATED"
    assert result.generated_content is not None
    assert usage["total_tokens"] == 40
    assert usage["confidence"] == "EXACT"
    assert usage["provenance"]["output_response_sha256"] == hashlib.sha256(raw.encode()).hexdigest()
    assert "private provider diagnostic" not in json.dumps(usage)


@pytest.mark.parametrize("arm", ["A", "B", "C"])
def test_grammar_error_correction_type_is_not_silently_changed_to_gap_fill(arm):
    supplied = candidate("GRAMMAR")
    supplied["questions"] = [{**q, "question_type": "GRAMMAR_CORRECTION",
                              "text": f"Correct the error in model sentence {index}."}
                             for index, q in enumerate(supplied["questions"])]
    result, _, _ = generate(
        "GRAMMAR", arm, ScriptedClient(responses_for("GRAMMAR", arm, supplied)),
        request=request_for("GRAMMAR", arm, exercise_type=GrammarExerciseType.ERROR_CORRECTION),
    )
    assert result.execution_status == ExecutionStatus.COMPLETED
    assert all(q.question_type.value == "GRAMMAR_CORRECTION" for q in result.generated_content.questions)


def test_c_missing_proposed_answers_is_honest_incomplete_verification():
    supplied = candidate("READING")
    supplied["questions"] = [{key: value for key, value in q.items() if key != "proposed_answer"}
                             for q in supplied["questions"]]
    result, _, trace = generate("READING", "C", ScriptedClient(responses_for("READING", "C", supplied)))
    assert result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert result.failure_code == "PROPOSED_ANSWERS_MISSING"
    assert result.generated_content is not None
    assert trace["internal_accepted_head"] is False


@pytest.mark.parametrize("source", ["PROVIDER", "BILLING"])
def test_provider_and_billing_costs_remain_distinct_from_estimates(source):
    response = replace(scripted_response(candidate("READING")), cost_usd=0.012,
                       cost_source=source, estimated_cost_usd=0.010)
    _, usage, _ = generate("READING", "A", ScriptedClient([response]))
    assert usage["cost_usd"] == 0.012
    assert usage["cost_source"] == source
    assert usage["estimated_cost_usd"] == 0.010
    assert usage["provider_cost_usd"] == (0.012 if source == "PROVIDER" else None)
    assert usage["billed_cost_usd"] == (0.012 if source == "BILLING" else None)


def test_failed_revision_does_not_erase_earlier_assessable_draft_or_its_origin():
    draft = candidate("READING", "retained-draft")
    client = ScriptedClient([
        scripted_response(draft),
        scripted_response({"verdict": "REVISION_NEEDED", "issues": ["Repair"]}),
        scripted_response("malformed revised content"),
    ])
    result, usage, _ = generate("READING", "B", client)
    assert result.failure_code == "RAW_OUTPUT_UNPARSEABLE"
    assert result.generated_content.questions[0].text == draft["questions"][0]["text"]
    assert usage["call_count"] == 3
    assert usage["repair_count"] == 1
    assert usage["provenance"]["output_response_sha256"] == hashlib.sha256(json.dumps(draft).encode()).hexdigest()
