"""Unit tests for RG09-S01: Frozen paired FINAL tasks.

Parent: generation_baseline/prompts/sprints/prompt-sprint-09-01.md
Objective: 25-40 Reading passage/group and 25-40 Grammar requests with balanced difficulty/type strata.
Decisive acceptance condition: Family-disjoint task IDs, hashes, licenses and full A/B/C assignment grid.
"""

from __future__ import annotations

import pytest

from app.contracts.research import (
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
)
from app.experiment.final_dataset import (
    DatasetStrataDefectError,
    FinalDatasetRegistry,
    SourceFamilyOverlapError,
)
from app.experiment.paired import DuplicateAssignmentError


def test_pos_rg09_s01_frozen_tasks_and_grid():
    """POS-RG09-S01: 28 Reading + 28 Grammar tasks with balanced strata, real hashes, and full A/B/C grid."""
    registry = FinalDatasetRegistry()
    reading_tasks = registry.build_reading_final_tasks()
    grammar_tasks = registry.build_grammar_final_tasks()

    # 1. Verify item counts are within 25-40 range for both domains
    assert len(reading_tasks) == 28
    assert len(grammar_tasks) == 28
    assert 25 <= len(reading_tasks) <= 40
    assert 25 <= len(grammar_tasks) <= 40

    # 2. Verify all reading sources are verified clean open-access sources
    reading_families = {t.source.source_family for t in reading_tasks}
    assert len(reading_families) == 7
    for task in reading_tasks:
        assert task.source.license == "CC-BY-4.0"
        assert len(task.source.source_sha256) == 64
        assert len(task.passage_text) >= 1000

    # 3. Verify all grammar sources are clean curated families
    grammar_families = {t.source.source_family for t in grammar_tasks}
    assert len(grammar_families) == 7
    for task in grammar_tasks:
        assert task.source.license == "synthetic_not_expert"
        assert len(task.source.source_sha256) == 64
        assert task.rule_pack is not None
        assert len(task.rule_pack.examples) >= 2

    # 4. Verify balanced difficulty and question/exercise type strata
    assert {t.reading_task.difficulty for t in reading_tasks if t.reading_task} == {"B1", "B2", "C1"}
    assert {t.grammar_task.difficulty for t in grammar_tasks if t.grammar_task} == {"B1", "B2", "C1"}

    reading_types = {t.reading_task.requested_groups[0] for t in reading_tasks if t.reading_task}
    assert {
        StandaloneGroupType.TFNG,
        StandaloneGroupType.MCQ_SINGLE,
        StandaloneGroupType.SENTENCE_COMPLETION,
        StandaloneGroupType.SUMMARY_COMPLETION,
        StandaloneGroupType.YNNG,
        StandaloneGroupType.SHORT_ANSWER,
    }.issubset(reading_types)

    grammar_types = {t.grammar_task.exercise_type for t in grammar_tasks if t.grammar_task}
    assert grammar_types == {
        GrammarExerciseType.MCQ_SINGLE,
        GrammarExerciseType.GAP_FILL,
        GrammarExerciseType.ERROR_CORRECTION,
    }

    # 5. Generate paired assignments and verify full A/B/C grid
    assignments = registry.generate_paired_assignments()
    assert len(assignments) == (28 + 28) * 3  # Exactly 168 assignments

    all_tasks = reading_tasks + grammar_tasks
    for task in all_tasks:
        arm_asgs = [a for a in assignments if a.dataset_item_id == task.dataset_item_id]
        assert len(arm_asgs) == 3
        arms = {a.configuration_id for a in arm_asgs}
        assert arms == {"A", "B", "C"}
        for a in arm_asgs:
            assert a.assignment_id == f"{task.dataset_item_id}__arm_{a.configuration_id}__att1"

    # 6. Verify batch partitioning (FINAL_BATCH_RULES.md: max 5 items per batch)
    batches = registry.partition_into_batches(max_items_per_batch=5)
    assert len(batches) == 12  # 56 items // 5 = 11 batches of 5 + 1 batch of 1
    for b in batches:
        assert len(b) <= 5


def test_neg_rg09_s01_leaked_dev_calibration_source_rejected():
    """NEG-RG09-S01: Leaked DEV/CALIBRATION/G15 sources into FINAL raise SourceFamilyOverlapError."""
    registry = FinalDatasetRegistry()

    # Leaked DEV passage source
    leaked_dev = PairedTaskFixture(
        dataset_item_id="final-reading-999",
        domain="READING",
        source=SourceRef(
            source_id="src-coral-reefs-dev",
            source_family="coral_reefs",
            source_version="v1.0",
            source_sha256="c" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://example.org/coral",
        ),
        foundation_model_id="llama-3.3-70b-versatile",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        reading_task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=4,
            difficulty="B2",
        ),
        passage_text="Coral reefs support diverse marine life across tropical ocean basins.",
    )
    with pytest.raises(SourceFamilyOverlapError) as exc_info:
        registry.validate_disjointness([leaked_dev])
    assert "coral_reefs" in str(exc_info.value)

    # Leaked canonical G15 campaign source (PMC13503497)
    leaked_g15 = PairedTaskFixture(
        dataset_item_id="final-reading-998",
        domain="READING",
        source=SourceRef(
            source_id="src-g15-pmc-13503497",
            source_family="fam-pmc-13503497",
            source_version="v1.0",
            source_sha256="d" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://example.org/pmc13503497",
        ),
        foundation_model_id="llama-3.3-70b-versatile",
        prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
        reading_task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=4,
            difficulty="B2",
        ),
        passage_text="Power grid synchronization dynamics under high renewables penetration.",
    )
    with pytest.raises(SourceFamilyOverlapError) as exc_info:
        registry.validate_disjointness([leaked_g15])
    assert "13503497" in str(exc_info.value)


def test_edge_rg09_s01_strata_defects_rejected():
    """EDGE-RG09-S01: Empty or under-cardinality (<25 items) and missing strata raise explicit error."""
    registry = FinalDatasetRegistry()

    # Under-cardinality (<25 items)
    with pytest.raises(DatasetStrataDefectError):
        registry.validate_strata([], domain="READING")

    with pytest.raises(DatasetStrataDefectError):
        registry.validate_strata([], domain="GRAMMAR")


def test_reg_rg09_s01_duplicate_assignment_idempotence():
    """REG-RG09-S01: Idempotency invariant prevents duplicate assignment registration."""
    registry = FinalDatasetRegistry()
    registry.build_reading_final_tasks()
    registry.build_grammar_final_tasks()
    registry.generate_paired_assignments(attempt_number=1)

    # Attempting to re-register the same assignments must fail closed
    with pytest.raises(DuplicateAssignmentError):
        registry.generate_paired_assignments(attempt_number=1)
