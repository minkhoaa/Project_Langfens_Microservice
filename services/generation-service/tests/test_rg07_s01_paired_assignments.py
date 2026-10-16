"""Unit tests for RG07-S01: Paired assignments and common task fixture.

Invariants:
- One experiment item mapped to A/B/C with immutable prompt/model/source pins and stable IDs.
- All three configs receive identical task/spec and comparable constraints.
- Duplicate assignment or provider fallback cannot alter a frozen row.
- Contracts match JSON_SCHEMAS.json#/$defs/ExperimentAssignment and #/$defs/ExperimentManifest.
"""

from __future__ import annotations

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.research import (
    ExperimentAssignment,
    ExperimentManifest,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGrammarRequest,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.experiment.paired import (
    DuplicateAssignmentError,
    PairedAssignmentManager,
    ProviderFallbackForbiddenError,
)


def load_schemas():
    schema_path = (
        Path(__file__).resolve().parents[3]
        / "generation_baseline"
        / "contracts"
        / "JSON_SCHEMAS.json"
    )
    return json.loads(schema_path.read_text())


@pytest.fixture
def reading_source_ref():
    return SourceRef(
        source_id="src-natgeo-01",
        source_family="national_geographic",
        source_version="2024-v1",
        source_sha256="a" * 64,
        license="CC-BY-4.0",
        provenance_uri="https://natgeo.example.com/deep-sea",
    )

@pytest.fixture
def reading_task():
    return ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG, StandaloneGroupType.SENTENCE_COMPLETION],
        requested_question_count=13,
        difficulty="ACADEMIC_BAND_7_8",
    )


@pytest.fixture
def reading_fixture(reading_source_ref, reading_task):
    return PairedTaskFixture(
        dataset_item_id="item-reading-001",
        domain="READING",
        source=reading_source_ref,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="prompt-rd-a-v1.0",
            B="prompt-rd-b-v1.0",
            C="prompt-rd-c-v1.0",
        ),
        rubric_version="rubric-qgeval-v2.0",
        reading_task=reading_task,
        passage_text="The deep-sea hydrothermal vents represent some of the most extreme environments on Earth. " * 15,
    )


@pytest.fixture
def grammar_fixture():
    source = SourceRef(
        source_id="src-cambridge-01",
        source_family="cambridge_advanced",
        source_version="2024-v2",
        source_sha256="b" * 64,
        license="CC-BY-SA-4.0",
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
    grammar_task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref="grp-c1-inv",
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=2,
        difficulty="C1",
    )
    return PairedTaskFixture(
        dataset_item_id="item-grammar-001",
        domain="GRAMMAR",
        source=source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="prompt-gr-a-v1.0",
            B="prompt-gr-b-v1.0",
            C="prompt-gr-c-v1.0",
        ),
        rubric_version="rubric-qgeval-v2.0",
        grammar_task=grammar_task,
        rule_pack=rule_pack,
    )


def test_pos_rg07_s01_paired_assignments_and_common_fixture(reading_fixture):
    """POS-RG07-S01: All three configs receive same task/spec and comparable constraints."""
    manager = PairedAssignmentManager()
    assignments = manager.create_paired_assignments(reading_fixture, attempt_number=1)

    # 1. Must generate exactly 3 assignments (A, B, C)
    assert len(assignments) == 3
    configs = [a.configuration_id for a in assignments]
    assert configs == ["A", "B", "C"]

    # 2. Stable deterministic IDs
    assert assignments[0].assignment_id == "item-reading-001__arm_A__att1"
    assert assignments[1].assignment_id == "item-reading-001__arm_B__att1"
    assert assignments[2].assignment_id == "item-reading-001__arm_C__att1"

    # 3. All three receive same task/spec and constraints
    req_a = manager.map_arm_request(reading_fixture, "A", run_id="run-a-01")
    req_b = manager.map_arm_request(reading_fixture, "B", run_id="run-b-01")
    req_c = manager.map_arm_request(reading_fixture, "C", run_id="run-c-01")

    assert req_a.configuration_id == "A"
    assert req_b.configuration_id == "B"
    assert req_c.configuration_id == "C"

    # Common task spec equality
    assert req_a.task == req_b.task == req_c.task
    assert req_a.task.requested_question_count == 13
    assert req_a.task.difficulty == "ACADEMIC_BAND_7_8"

    # 4. Validates cleanly against JSON_SCHEMAS.json
    schemas = load_schemas()
    assignment_schema = schemas["$defs"]["ExperimentAssignment"]
    manifest_schema = schemas["$defs"]["ExperimentManifest"]

    for a in assignments:
        jsonschema.Draft202012Validator(
            {"$defs": schemas["$defs"], **assignment_schema}
        ).validate(a.model_dump())

    manifest = ExperimentManifest(
        experiment_id="exp-rq2-pilot-01",
        dataset_version="v2.0-final",
        split="FINAL_EVAL",
        source_sha256="c" * 64,
        code_commit_sha="9e81cda156e950d7e705df9effe23e685cc89de5",
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(
            A="prompt-rd-a-v1.0",
            B="prompt-rd-b-v1.0",
            C="prompt-rd-c-v1.0",
        ),
        rubric_version="rubric-qgeval-v2.0",
        assignments=assignments,
        primary_endpoint="independent_final_pass_rate",
        analysis_plan_sha256="d" * 64,
    )
    jsonschema.Draft202012Validator(
        {"$defs": schemas["$defs"], **manifest_schema}
    ).validate(manifest.model_dump())


def test_neg_rg07_s01_duplicate_assignment_and_provider_fallback_forbidden(reading_fixture):
    """NEG-RG07-S01: Duplicate assignment or provider fallback cannot alter a frozen row."""
    manager = PairedAssignmentManager()
    assignments = manager.create_paired_assignments(reading_fixture, attempt_number=1)

    for a in assignments:
        manager.register_assignment(a)

    # 1. Duplicate registration of same assignment must be safely rejected
    with pytest.raises(DuplicateAssignmentError, match="Duplicate assignment"):
        manager.register_assignment(assignments[0])

    # 2. Immutable row: frozen assignment cannot be mutated in-place
    with pytest.raises(ValidationError):
        assignments[0].configuration_id = "B"

    # 3. Provider fallback rejection: unpinned model or provider fallback is forbidden
    with pytest.raises(ProviderFallbackForbiddenError, match="Provider fallback forbidden"):
        manager.verify_model_provider_pin(
            requested_model_id="groq/llama-3.3-70b-versatile",
            pinned_model_id=reading_fixture.foundation_model_id,
        )

    # Correct pinned model succeeds without error
    manager.verify_model_provider_pin(
        requested_model_id="minimax/MiniMax-Text-01",
        pinned_model_id=reading_fixture.foundation_model_id,
    )


def test_edge_rg07_s01_malformed_and_missing_inputs(reading_fixture):
    """EDGE-RG07-S01: Missing, stale, or malformed fields are safely rejected."""
    # 1. Invalid assignment configuration_id
    with pytest.raises(ValidationError):
        ExperimentAssignment(
            assignment_id="asg-01",
            dataset_item_id="item-01",
            configuration_id="D",  # Invalid, must be A, B, or C
            attempt_number=1,
            run_id=None,
            result_ref=None,
        )

    # 2. Invalid attempt_number (less than 1)
    with pytest.raises(ValidationError):
        ExperimentAssignment(
            assignment_id="asg-01",
            dataset_item_id="item-01",
            configuration_id="A",
            attempt_number=0,
            run_id=None,
            result_ref=None,
        )

    # 3. Invalid ExperimentManifest split
    with pytest.raises(ValidationError):
        ExperimentManifest(
            experiment_id="exp-01",
            dataset_version="v1.0",
            split="INVALID_SPLIT",  # const is FINAL_EVAL
            source_sha256="e" * 64,
            code_commit_sha="commit-01",
            foundation_model_id="minimax/MiniMax-Text-01",
            prompt_versions=PromptVersionMap(A="v1", B="v1", C="v1"),
            rubric_version="rubric-v1",
            assignments=[
                ExperimentAssignment(
                    assignment_id="asg-01",
                    dataset_item_id="item-01",
                    configuration_id="A",
                    attempt_number=1,
                    run_id=None,
                    result_ref=None,
                )
            ],
            primary_endpoint="pass_rate",
            analysis_plan_sha256="f" * 64,
        )

    # 4. Invalid SHA256 length in manifest
    with pytest.raises(ValidationError):
        ExperimentManifest(
            experiment_id="exp-01",
            dataset_version="v1.0",
            split="FINAL_EVAL",
            source_sha256="too-short",
            code_commit_sha="commit-01",
            foundation_model_id="minimax/MiniMax-Text-01",
            prompt_versions=PromptVersionMap(A="v1", B="v1", C="v1"),
            rubric_version="rubric-v1",
            assignments=[
                ExperimentAssignment(
                    assignment_id="asg-01",
                    dataset_item_id="item-01",
                    configuration_id="A",
                    attempt_number=1,
                    run_id=None,
                    result_ref=None,
                )
            ],
            primary_endpoint="pass_rate",
            analysis_plan_sha256="f" * 64,
        )


def test_reg_rg07_s01_existing_reading_and_grammar_contracts_preserved(
    reading_source_ref, reading_task, grammar_fixture
):
    """REG-RG07-S01: Adding experiment contracts does not regress StandaloneReading/Grammar contracts."""
    # Reading request continues to reject >2 groups
    with pytest.raises((ValueError, ValidationError)):
        ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[
                StandaloneGroupType.TFNG,
                StandaloneGroupType.MCQ_SINGLE,
                StandaloneGroupType.SUMMARY_COMPLETION,
            ],
            requested_question_count=20,
            target_word_count_min=720,
            target_word_count_max=915,
            difficulty="ACADEMIC_BAND_7_8",
        )

    # Grammar request mapping via manager preserves rule_pack and task
    manager = PairedAssignmentManager()
    grammar_req_a = manager.map_arm_request(grammar_fixture, "A", run_id="run-gr-a")
    assert isinstance(grammar_req_a, StandaloneGrammarRequest)
    assert grammar_req_a.rule_pack.rule_pack_id == "grp-c1-inv"
    assert grammar_req_a.task.requested_question_count == 2
