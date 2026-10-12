"""Unit tests for Phase 14: Curation State Machine, Dataset Export, and Partitioning.

Covers:
- T14-05: Raw labels do not enter gold set without curation; curation audit trail is complete.
- T14-06: Source-family and near-duplicate partitioning prevents leakage; repeat export produces
  identical SHA256; blind solver view excludes answer keys.
"""
import copy
import json
import pytest

from app.curation.curation import (
    ActionType,
    CurationAuditLog,
    CurationError,
    CurationManager,
    CurationStatus,
    FeedbackRecord,
)
from app.curation.export import (
    BlindSolverBenchmarkExport,
    CuratedDatasetExport,
    DatasetExporter,
    anonymize_id,
    compute_deterministic_sha256,
    redact_pii_and_secrets,
)
from app.curation.partitioning import (
    ConnectedComponentSplitter,
    PartitionResult,
    jaccard_similarity,
)


class TestT14CurationStateMachine:
    """T14-05: Raw labels do not enter gold set without curation; audit trail is complete."""

    def test_raw_feedback_initial_state(self) -> None:
        mgr = CurationManager()
        rec = mgr.register(
            feedback_id="fb_001",
            editor_id="user_admin_1",
            editor_role="admin",
            action_type=ActionType.EDIT,
            reasons=["unsupported_claim"],
            comment="Corrected factual discrepancy in passage line 4",
        )
        assert rec.status == CurationStatus.RAW
        assert not mgr.is_gold_eligible("fb_001")
        with pytest.raises(CurationError, match="not eligible for gold"):
            mgr.assert_can_mark_gold("fb_001")

    def test_cannot_skip_directly_to_curated(self) -> None:
        mgr = CurationManager()
        rec = mgr.register(
            feedback_id="fb_002",
            editor_id="user_editor_1",
            editor_role="editor",
            action_type=ActionType.EDIT,
            reasons=["ambiguity"],
            comment="Clarified option B text",
        )
        # Attempt RAW -> CURATED must fail
        with pytest.raises(CurationError, match="illegal transition"):
            mgr.transition(
                feedback_id="fb_002",
                target=CurationStatus.CURATED,
                reviewer_id="reviewer_1",
                reviewer_role="curator",
                comment="Direct approve",
            )
        assert rec.status == CurationStatus.RAW

    def test_full_lifecycle_raw_to_curated(self) -> None:
        mgr = CurationManager()
        rec = mgr.register(
            feedback_id="fb_003",
            editor_id="editor_alice",
            editor_role="editor",
            action_type=ActionType.EDIT,
            reasons=["weak_distractor", "style_or_grammar"],
            comment="Strengthened distractor C to align with paragraph 2 context",
        )

        # 1. RAW -> ANNOTATED (Annotator adds tax reasons / references)
        rec = mgr.transition(
            feedback_id="fb_003",
            target=CurationStatus.ANNOTATED,
            reviewer_id="annotator_bob",
            reviewer_role="annotator",
            comment="Tagged taxonomy reasons and added grounding span",
        )
        assert rec.status == CurationStatus.ANNOTATED
        assert not mgr.is_gold_eligible("fb_003")

        # 2. ANNOTATED -> REVIEWED (Independent reviewer checks edit)
        rec = mgr.transition(
            feedback_id="fb_003",
            target=CurationStatus.REVIEWED,
            reviewer_id="reviewer_charlie",
            reviewer_role="reviewer",
            comment="Verified factual grounding and distractor plausibility",
        )
        assert rec.status == CurationStatus.REVIEWED
        assert mgr.is_gold_eligible("fb_003")

        # 3. REVIEWED -> CURATED (Curator promotes to authoritative gold set)
        rec = mgr.transition(
            feedback_id="fb_003",
            target=CurationStatus.CURATED,
            reviewer_id="curator_david",
            reviewer_role="curator",
            comment="Approved for benchmark release v2",
        )
        assert rec.status == CurationStatus.CURATED
        assert rec.curated_at is not None
        assert mgr.is_gold_eligible("fb_003")

        # Audit trail verification
        trail = mgr.get_audit_trail("fb_003")
        assert len(trail) == 4  # RAW creation + 3 transitions
        assert trail[0].to_status == CurationStatus.RAW
        assert trail[1].from_status == CurationStatus.RAW and trail[1].to_status == CurationStatus.ANNOTATED
        assert trail[2].from_status == CurationStatus.ANNOTATED and trail[2].to_status == CurationStatus.REVIEWED
        assert trail[3].from_status == CurationStatus.REVIEWED and trail[3].to_status == CurationStatus.CURATED

    def test_reviewer_role_enforcement(self) -> None:
        mgr = CurationManager()
        rec = mgr.register(
            feedback_id="fb_004",
            editor_id="editor_1",
            editor_role="editor",
            action_type=ActionType.EDIT,
        )
        mgr.transition(
            feedback_id="fb_004",
            target=CurationStatus.ANNOTATED,
            reviewer_id="editor_1",
            reviewer_role="editor",
            comment="Tagged",
        )
        # Unauthorized role cannot review/curate
        with pytest.raises(CurationError, match="cannot transition"):
            mgr.transition(
                feedback_id="fb_004",
                target=CurationStatus.REVIEWED,
                reviewer_id="editor_1",
                reviewer_role="editor",
                comment="Self review",
            )

    def test_idempotent_replay_after_curated(self) -> None:
        mgr = CurationManager()
        rec = mgr.register(
            feedback_id="fb_idem_001",
            editor_id="test_editor_1",
            editor_role="editor",
            action_type=ActionType.EDIT,
            reasons=["weak_distractor"],
            comment="Clarified distractor text",
            before_payload={"question": "Old question text"},
            after_payload={"question": "New question text"},
            idempotency_key="key_12345",
        )
        # Progress through to CURATED
        mgr.transition(feedback_id="fb_idem_001", target=CurationStatus.ANNOTATED, reviewer_id="annotator_1", reviewer_role="annotator", comment="Annotated")
        mgr.transition(feedback_id="fb_idem_001", target=CurationStatus.REVIEWED, reviewer_id="reviewer_1", reviewer_role="reviewer", comment="Reviewed")
        rec = mgr.transition(feedback_id="fb_idem_001", target=CurationStatus.CURATED, reviewer_id="curator_1", reviewer_role="curator", comment="Curated")
        assert rec.status == CurationStatus.CURATED
        assert len(mgr.get_audit_trail("fb_idem_001")) == 4

        # Re-register with identical payload (idempotent replay)
        rec_replay = mgr.register(
            feedback_id="fb_idem_001",
            editor_id="test_editor_1",
            editor_role="editor",
            action_type=ActionType.EDIT,
            reasons=["weak_distractor"],
            comment="Clarified distractor text",
            before_payload={"question": "Old question text"},
            after_payload={"question": "New question text"},
            idempotency_key="key_12345",
        )
        assert rec_replay.status == CurationStatus.CURATED, "Status must remain CURATED on replay"
        assert len(mgr.get_audit_trail("fb_idem_001")) == 4, "No duplicate audit logs should be created"

    def test_idempotent_payload_conflict(self) -> None:
        mgr = CurationManager()
        mgr.register(
            feedback_id="fb_conflict_001",
            editor_id="test_editor_1",
            editor_role="editor",
            action_type=ActionType.EDIT,
            reasons=["weak_distractor"],
            comment="Original comment",
            idempotency_key="key_conflict",
        )
        # Attempt re-register with conflicting comment/reasons
        with pytest.raises(CurationError, match="Idempotent conflict"):
            mgr.register(
                feedback_id="fb_conflict_001",
                editor_id="test_editor_1",
                editor_role="editor",
                action_type=ActionType.EDIT,
                reasons=["unsupported_claim"],  # Different reason
                comment="Different comment",
                idempotency_key="key_conflict",
            )

    def test_t14_raw_vs_curated_separation(self) -> None:
        """Canonical T14-05 test."""
        self.test_raw_feedback_initial_state()
        self.test_cannot_skip_directly_to_curated()
        self.test_full_lifecycle_raw_to_curated()
        self.test_reviewer_role_enforcement()
        self.test_idempotent_replay_after_curated()
        self.test_idempotent_payload_conflict()


class TestT14ExportAndPartitioning:
    """T14-06: Source-family partitioning, reproducible exports, blind solver isolation."""

    def test_pii_and_secret_redaction(self) -> None:
        raw_record = {
            "editor_id": "usr_real_john_doe_999",
            "author_email": "john.doe@example.org",
            "api_key": "sk-secret-key-live-1234567890",
            "token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.secret",
            "comment": "Contact admin@langfens.com with questions. Bearer abcdef1234567890xyz",
            "details": {
                "secret_key": "topsecret",
                "nested_user_id": "usr_jane_doe_888",
            },
        }

        sanitized = redact_pii_and_secrets(raw_record)
        assert sanitized["editor_id"].startswith("usr_anon_")
        assert "john_doe" not in sanitized["editor_id"]
        assert sanitized["api_key"] == "[REDACTED_SECRET]"
        assert sanitized["details"]["secret_key"] == "[REDACTED_SECRET]"
        assert "[EMAIL_REDACTED]" in sanitized["comment"]
        assert "Bearer [TOKEN_REDACTED]" in sanitized["comment"]

    def test_deterministic_export_sha256(self) -> None:
        exporter = DatasetExporter()
        records = [
            FeedbackRecord(
                feedback_id="fb_A",
                editor_id="editor_1",
                editor_role="curator",
                action_type=ActionType.EDIT,
                status=CurationStatus.CURATED,
                target_entity_type="QUESTION",
                target_entity_id="q_100",
                artifact_id="art_100",
                reasons=["weak_distractor"],
            ),
            FeedbackRecord(
                feedback_id="fb_B",
                editor_id="editor_2",
                editor_role="curator",
                action_type=ActionType.EDIT,
                status=CurationStatus.CURATED,
                target_entity_type="QUESTION",
                target_entity_id="q_101",
                artifact_id="art_101",
                reasons=["ambiguity"],
            ),
        ]

        # First export
        exp1 = exporter.export_curated(records, version="v1.0.0")
        # Second export with reversed input order
        exp2 = exporter.export_curated(list(reversed(records)), version="v1.0.0")

        assert exp1.dataset_sha256 == exp2.dataset_sha256
        assert len(exp1.dataset_sha256) == 64

    def test_blind_solver_view_excludes_answers(self) -> None:
        exporter = DatasetExporter()
        records = [
            {
                "feedback_id": "fb_solv_1",
                "target_entity_type": "QUESTION",
                "target_entity_id": "q_1",
                "artifact_id": "art_1",
                "status": "CURATED",
                "question_text": "What is the primary migration driver for monarch butterflies?",
                "expected_answer": "Temperature gradients and photoperiod",
                "answer_key": "B",
                "hidden_explanation": "Passage paragraph 3 explicitly specifies photoperiod.",
                "options": [
                    {"label": "A", "text": "Predation risk", "is_correct": False},
                    {"label": "B", "text": "Temperature gradients and photoperiod", "is_correct": True},
                ],
            }
        ]

        curated = exporter.export_curated(records, version="v1.0.0")
        blind = exporter.export_blind_solver_benchmark(records, version="v1.0.0-blind")

        assert curated.records[0]["expected_answer"] == "Temperature gradients and photoperiod"
        assert "expected_answer" not in blind.records[0]
        assert "answer_key" not in blind.records[0]
        assert "hidden_explanation" not in blind.records[0]
        # Option correct flags stripped
        for opt in blind.records[0]["options"]:
            assert "is_correct" not in opt

    def test_connected_component_partitioning_zero_leakage(self) -> None:
        splitter = ConnectedComponentSplitter(
            train_ratio=0.70,
            val_ratio=0.15,
            test_ratio=0.15,
            jaccard_threshold=0.8,
        )

        items = [
            # Family 1 (PMC9999) - 3 related questions
            {"id": "item_1", "pmcid": "PMC9999", "passage_text": "Glacial retreat in Greenland..."},
            {"id": "item_2", "pmcid": "PMC9999", "passage_text": "Glacial retreat in Greenland..."},
            {"id": "item_3", "pmcid": "PMC9999", "passage_text": "Glacial retreat in Greenland..."},
            # Family 2 (DOI: 10.1000/volcano) - 2 related questions
            {"id": "item_4", "doi": "10.1000/volcano", "passage_text": "Volcanic pyroclastic flows..."},
            {"id": "item_5", "doi": "10.1000/volcano", "passage_text": "Volcanic pyroclastic flows..."},
            # Family 3 - Near-duplicates by text (>80% Jaccard) without shared IDs
            {"id": "item_6", "passage_text": "Quantum entanglement occurs when pairs of particles interact in ways such that physical state cannot be described independently"},
            {"id": "item_7", "passage_text": "Quantum entanglement occurs when pairs of particles interact in ways such that their physical state cannot be described independently"},
            # Family 4..8 - Distinct independent items
            {"id": "item_8", "pmcid": "PMC1001", "passage_text": "Ancient Roman aqueduct engineering..."},
            {"id": "item_9", "pmcid": "PMC1002", "passage_text": "Deep sea hydrothermal vent ecosystems..."},
            {"id": "item_10", "pmcid": "PMC1003", "passage_text": "Linguistic origins of Indo-European roots..."},
        ]

        res = splitter.partition(items)

        assert res.leakage_violations == 0
        assert res.train_count + res.val_count + res.test_count == len(items)

        # Verify that all Family 1 items are in the exact same split
        splits_for_fam1 = []
        for s_name, s_items in [("train", res.train), ("val", res.val), ("test", res.test)]:
            ids = {it["id"] for it in s_items}
            if "item_1" in ids:
                splits_for_fam1.append(s_name)
            if "item_2" in ids:
                splits_for_fam1.append(s_name)
            if "item_3" in ids:
                splits_for_fam1.append(s_name)
        assert len(set(splits_for_fam1)) == 1, "Family 1 items were split across multiple partitions (LEAKAGE)!"

        # Verify near-duplicate Family 3 items are together
        splits_for_fam3 = []
        for s_name, s_items in [("train", res.train), ("val", res.val), ("test", res.test)]:
            ids = {it["id"] for it in s_items}
            if "item_6" in ids:
                splits_for_fam3.append(s_name)
            if "item_7" in ids:
                splits_for_fam3.append(s_name)
        assert len(set(splits_for_fam3)) == 1, "Near duplicate items leaked across partitions!"

    def test_t14_source_family_partitioning_and_reproducible_export(self) -> None:
        """Canonical T14-06 test."""
        self.test_pii_and_secret_redaction()
        self.test_deterministic_export_sha256()
        self.test_blind_solver_view_excludes_answers()
        self.test_connected_component_partitioning_zero_leakage()
