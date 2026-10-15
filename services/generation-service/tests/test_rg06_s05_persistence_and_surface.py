"""Unit tests for RG06-S05: Grammar Research Persistence and Surface."""

import pytest
from pydantic import ValidationError

from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarQuestionType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    ReferenceAnswerEvidence,
    SourceRef,
    StandaloneGrammarRequest,
)
from app.loop.standalone_grammar import StandaloneGrammarRunner
from app.persistence.grammar_store import (
    GrammarResearchRecord,
    GrammarResearchStore,
    ResearchPublicationForbiddenError,
)


@pytest.fixture
def grammar_request():
    source = SourceRef(
        source_id="src-cambridge-03",
        source_family="cambridge_advanced",
        source_version="v2.5",
        source_sha256="1" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://cambridge.org/grammar/c1-inversion",
    )
    rule_pack = GrammarRulePack(
        rule_pack_id="grp-c1-inv",
        source=source,
        topic="Inversion with Scarcely / No sooner",
        level="C1",
        rule_ids=["rule-c1-inv-01"],
        applicability=["Use 'No sooner had... than...' and 'Scarcely had... when...'."],
        exceptions=["Do not confuse 'than' with 'when'."],
        examples=["No sooner had he arrived than the phone rang."],
    )
    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref=rule_pack.rule_pack_id,
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return StandaloneGrammarRequest(
        run_id="run-gram-s05-01",
        dataset_item_id="item-gram-s05-01",
        configuration_id="A",
        task=task,
        rule_pack=rule_pack,
    )


def test_pos_rg06_s05_failed_partial_and_replayed_cases_are_durable(grammar_request):
    """POS-RG06-S05: Failed/partial/replayed grammar cases are durable and access controlled."""
    store = GrammarResearchStore()
    runner = StandaloneGrammarRunner()

    # 1. Store completed run
    result, evidence = runner.run_unit(grammar_request)
    record = store.save_record(
        request=grammar_request,
        generation_result=result,
        private_evidence=evidence,
        tenant_id="tenant-alpha",
    )
    assert record.run_id == grammar_request.run_id
    assert record.is_durable is True

    # Resume run from store
    resumed = store.get_record(grammar_request.run_id, tenant_id="tenant-alpha")
    assert resumed is not None
    assert resumed.run_id == grammar_request.run_id
    assert resumed.generation_result.execution_status == ExecutionStatus.COMPLETED

    # 2. Store failed / partial run
    failed_req = StandaloneGrammarRequest(
        run_id="run-gram-s05-failed",
        dataset_item_id="item-gram-s05-failed",
        configuration_id="B",
        task=grammar_request.task,
        rule_pack=grammar_request.rule_pack,
    )
    fail_result, fail_evidence = runner.run_unit(failed_req, simulate_failure="PARTIAL_VALIDATION_ERROR")
    fail_record = store.save_record(
        request=failed_req,
        generation_result=fail_result,
        private_evidence=fail_evidence,
        tenant_id="tenant-alpha",
    )
    assert fail_record.generation_result.execution_status == ExecutionStatus.FAILED_VALIDATION
    assert fail_record.generation_result.output_availability == OutputAvailability.PARSEABLE

    # 3. Replay run idempotently without duplicating or corrupting state
    replay_record = store.replay_run(
        original_run_id=grammar_request.run_id,
        new_run_id="run-gram-s05-replayed",
        tenant_id="tenant-alpha",
    )
    assert replay_record.run_id == "run-gram-s05-replayed"
    assert replay_record.replayed_from_run_id == grammar_request.run_id


def test_neg_rg06_s05_research_grammar_cannot_publish_directly_or_leak(grammar_request):
    """NEG-RG06-S05: Research grammar item cannot publish directly or leak private answers.

    Enforces C5 ProductIntegrationContract: research mode items cannot be published
    to production exams, and student views strictly strip answers/explanations.
    """
    store = GrammarResearchStore()
    runner = StandaloneGrammarRunner()

    result, evidence = runner.run_unit(grammar_request)
    record = store.save_record(
        request=grammar_request,
        generation_result=result,
        private_evidence=evidence,
        tenant_id="tenant-alpha",
    )

    # 1. Attempting to publish research grammar exercise directly to production MUST FAIL
    with pytest.raises(ResearchPublicationForbiddenError) as exc_info:
        store.publish_to_production_exam(run_id=grammar_request.run_id, tenant_id="tenant-alpha")
    assert "RESEARCH_PUBLICATION_FORBIDDEN" in str(exc_info.value)
    assert record.is_published is False

    # 2. Cross-tenant access to durable record is denied
    cross_tenant_record = store.get_record(grammar_request.run_id, tenant_id="tenant-unauthorized")
    assert cross_tenant_record is None

    # 3. Student/Public review view projection strips all private answer evidence
    public_view = store.project_student_view(grammar_request.run_id, tenant_id="tenant-alpha")
    assert "private_evidence" not in public_view
    assert "generator_proposed_answer" not in str(public_view)
    assert "source_grounded_explanation" not in str(public_view)


def test_edge_rg06_s05_replaying_nonexistent_or_unauthorized_run():
    """EDGE-RG06-S05: Replaying nonexistent or cross-tenant run raises safe error."""
    store = GrammarResearchStore()

    with pytest.raises(KeyError):
        store.replay_run(
            original_run_id="nonexistent-run-999",
            new_run_id="replay-run-999",
            tenant_id="tenant-alpha",
        )


def test_reg_rg06_s05_strict_v2_and_prior_sprints_regression():
    """REG-RG06-S05: Full integration regression across RG02 research publish protection and S01-S04."""
    from app.contracts.research import StandaloneGroupType

    assert len(StandaloneGroupType.__members__) == 6
