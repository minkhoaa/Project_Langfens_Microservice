"""End-to-end integration test exercising the complete Phase 14 loop lifecycle.

Exercises the single path:
1. Executing a generated-Draft edit on PostgreSQL and fetching the exact committed `HUMAN_FEEDBACK_CAPTURED` event.
2. Ingesting this exact event into the Curation Pipeline (`RAW`).
3. Advancing through `RAW -> ANNOTATED -> REVIEWED -> CURATED` with full audit logging.
4. Exporting curated gold dataset and blind solver benchmark views with deterministic SHA-256 hashes.
5. Partitioning via ConnectedComponentSplitter with non-empty splits (train > 0, val > 0, test > 0) and zero cross-split leakage.
6. Running paired offline evaluation comparing baseline and candidate versions on benchmark items.
7. Evaluating promotion gates, version pinning, in-flight run version isolation, and clean rollback.
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import uuid
import pytest

from app.curation.curation import ActionType, CurationManager, CurationStatus
from app.curation.export import DatasetExporter
from app.curation.partitioning import ConnectedComponentSplitter
from app.offline_eval.comparison import (
    GateVerdict,
    ItemEvalResult,
    PairedComparisonReport,
    PairedOfflineComparator,
)
from app.offline_eval.runner import OfflineEvalRunner
from app.promotion.promotion import PromotionStatus, VersionPromotionManager
from app.promotion.registry import PromptVersionRegistry


def execute_and_fetch_generated_draft_edit_outbox_event() -> dict:
    """Use an explicit captured event for offline replay, or execute the DB producer.

    The replay file must be exported by the inspected .NET test on a disposable
    database. This mode tests the consumer lifecycle, not a fresh PostgreSQL write.
    """
    capture_path = os.environ.get("PHASE14_OUTBOX_EVENT_FILE")
    if capture_path:
        from pathlib import Path
        capture = json.loads(Path(capture_path).read_text(encoding="utf-8"))
        assert capture["source_mode"] == "DISPOSABLE_POSTGRES_OUTBOX"
        assert capture["dotnet_test"] == "T14_01_EditGeneratedExam_CapturesExactLineageDiffHashesAndOutbox"
        payload = capture["payload"]
        digest = hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
        assert digest == capture["payload_sha256"], "Captured PostgreSQL event was modified"
        return payload
    # Never silently invoke a destructive fixture against its hardcoded/shared
    # fallback. The caller must explicitly select the already isolated database.
    assert os.environ.get("READING_TEST_POSTGRES"), "Explicit disposable READING_TEST_POSTGRES required"
    host = os.environ.get("PGHOST", "localhost")
    port = os.environ.get("PGPORT", "5433")
    user = os.environ.get("PGUSER", "exam")
    password = os.environ.get("PGPASSWORD", "exam")

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    cmd_dotnet = [
        "dotnet", "test",
        os.path.join(repo_root, "services/exam-service.Tests/exam-service.Tests.csproj"),
        "--no-restore",
        "--filter", "FullyQualifiedName~T14_01_EditGeneratedExam_CapturesExactLineageDiffHashesAndOutbox",
    ]
    res_dotnet = subprocess.run(cmd_dotnet, capture_output=True, text=True)
    assert res_dotnet.returncode == 0, f"Dotnet test failed: {res_dotnet.stdout}\n{res_dotnet.stderr}"

    target_db = "exam_test_phase14_lineage"
    cmd_select = [
        "psql", "-h", host, "-p", port, "-U", user, "-d", target_db,
        "-t", "-A", "-c",
        'SELECT "PayloadJson", "IdempotencyKey" FROM reading_paper_event_outbox WHERE "EventType" = \'HUMAN_FEEDBACK_CAPTURED\' AND "IdempotencyKey" = \'idemp-q17-prompt-001\' LIMIT 1;',
    ]
    proc_sel = subprocess.run(cmd_select, env={**os.environ, "PGPASSWORD": password}, capture_output=True, text=True)
    assert proc_sel.returncode == 0 and proc_sel.stdout.strip(), "Could not find exact committed outbox event for idemp-q17-prompt-001"

    line = proc_sel.stdout.strip()
    payload_raw, idemp_key = line.rsplit("|", 1)
    payload = json.loads(payload_raw)
    payload["idempotencyKey"] = idemp_key
    return payload


def test_full_phase14_lifecycle_e2e() -> None:
    # -------------------------------------------------------------------------
    # Step 1: Ingest Exact PostgreSQL Outbox Event from Generated Draft Edit
    # -------------------------------------------------------------------------
    payload = execute_and_fetch_generated_draft_edit_outbox_event()
    assert payload is not None, "PostgreSQL outbox payload must not be null"
    assert payload.get("idempotencyKey") == "idemp-q17-prompt-001"
    assert payload.get("targetEntityType") == "QUESTION"
    assert "editor-admin-test" in payload.get("editorId", "")

    # -------------------------------------------------------------------------
    # Step 2: Curation Ingestion from Exact Outbox Event
    # -------------------------------------------------------------------------
    curation_mgr = CurationManager()
    action_type_str = str(payload.get("actionType", "EDIT")).upper()
    action_type = ActionType.EDIT if action_type_str in ("UPDATE", "EDIT") else ActionType.ACCEPT

    reasons_raw = payload.get("reasons") or payload.get("reasonsJson") or ["UNSUPPORTED_CLAIM", "AMBIGUITY"]
    if isinstance(reasons_raw, str):
        try:
            reasons = json.loads(reasons_raw)
        except Exception:
            reasons = [r.strip() for r in reasons_raw.split(",") if r.strip()]
    else:
        reasons = list(reasons_raw)

    before_p = payload.get("beforePayloadJson")
    if isinstance(before_p, str):
        try:
            before_p = json.loads(before_p)
        except Exception:
            before_p = {"raw": before_p}

    after_p = payload.get("afterPayloadJson")
    if isinstance(after_p, str):
        try:
            after_p = json.loads(after_p)
        except Exception:
            after_p = {"raw": after_p}

    diff_p = payload.get("diffJson")
    if isinstance(diff_p, str):
        try:
            diff_p = json.loads(diff_p)
        except Exception:
            diff_p = {"raw": diff_p}

    record = curation_mgr.register(
        feedback_id=payload.get("feedbackId") or f"fb-{uuid.uuid4().hex}",
        editor_id=payload.get("editorId", "editor-admin-test"),
        editor_role=str(payload.get("editorRole", "ADMIN")).lower(),
        action_type=action_type,
        reasons=reasons,
        comment=payload.get("comment", "Clarified prompt wording regarding primordial gas composition."),
        artifact_id=payload.get("artifactId", "art_q_17"),
        artifact_version=str(payload.get("artifactVersion", "1")),
        target_entity_type=payload.get("targetEntityType", "QUESTION"),
        target_entity_id=payload.get("targetEntityId"),
        before_payload=before_p,
        after_payload=after_p,
        diff=diff_p,
        idempotency_key=payload.get("idempotencyKey", "idemp-q17-prompt-001"),
    )
    assert record.status == CurationStatus.RAW
    assert not curation_mgr.is_gold_eligible(record.feedback_id)

    # -------------------------------------------------------------------------
    # Step 3: Curation Review Progression (RAW -> ANNOTATED -> REVIEWED -> CURATED)
    # -------------------------------------------------------------------------
    record = curation_mgr.transition(
        feedback_id=record.feedback_id,
        target=CurationStatus.ANNOTATED,
        reviewer_id="test_annotator_phase14_01",
        reviewer_role="annotator",
        comment="Taxonomy tags verified; grounded in passage section 2 paragraph 1.",
    )
    assert record.status == CurationStatus.ANNOTATED

    record = curation_mgr.transition(
        feedback_id=record.feedback_id,
        target=CurationStatus.REVIEWED,
        reviewer_id="test_reviewer_phase14_01",
        reviewer_role="reviewer",
        comment="Distractor verified scientifically plausible and unambiguous.",
    )
    assert record.status == CurationStatus.REVIEWED

    record = curation_mgr.transition(
        feedback_id=record.feedback_id,
        target=CurationStatus.CURATED,
        reviewer_id="test_curator_phase14_01",
        reviewer_role="curator",
        comment="Approved for inclusion in Gold Evaluation Corpus v2.",
    )
    assert record.status == CurationStatus.CURATED
    assert curation_mgr.is_gold_eligible(record.feedback_id)

    trail = curation_mgr.get_audit_trail(record.feedback_id)
    assert len(trail) == 4
    assert [t.to_status for t in trail] == [
        CurationStatus.RAW,
        CurationStatus.ANNOTATED,
        CurationStatus.REVIEWED,
        CurationStatus.CURATED,
    ]

    # -------------------------------------------------------------------------
    # Step 4: Dataset Export (Curated view vs Blind Solver view)
    # -------------------------------------------------------------------------
    exporter = DatasetExporter(salt="test_e2e_salt_deterministic")
    curated_export = exporter.export_curated([record], version="v2.0.0-gold")
    blind_export = exporter.export_blind_solver_benchmark([record], version="v2.0.0-blind")

    # Repeat export to verify bit-for-bit deterministic SHA256
    curated_export_repeat = exporter.export_curated([record], version="v2.0.0-gold")
    assert curated_export.dataset_sha256 == curated_export_repeat.dataset_sha256

    blind_rec = blind_export.records[0]
    assert "explanation" not in blind_rec
    assert "before_payload" not in blind_rec
    assert "after_payload" not in blind_rec
    assert "diff" not in blind_rec

    # -------------------------------------------------------------------------
    # Step 5: Connected Component Partitioning with Non-Empty Splits (Train/Val/Test > 0)
    # -------------------------------------------------------------------------
    splitter = ConnectedComponentSplitter(train_ratio=0.50, val_ratio=0.25, test_ratio=0.25)
    dataset_items = [
        {"id": "q1", "pmcid": "PMC8001", "passage_text": "Photosynthesis pathways in C4 plants..."},
        {"id": "q2", "pmcid": "PMC8001", "passage_text": "Photosynthesis pathways in C4 plants..."},
        {"id": "q3", "doi": "10.1038/nature123", "passage_text": "Gravitational wave detections from LIGO..."},
        {"id": "q4", "doi": "10.1038/nature123", "passage_text": "Gravitational wave detections from LIGO..."},
        {"id": "q5", "pmcid": "PMC9002", "passage_text": "Neural mechanisms of spatial navigation..."},
        {"id": "q6", "pmcid": "PMC9002", "passage_text": "Neural mechanisms of spatial navigation..."},
        {"id": "q7", "doi": "10.1016/j.cell.456", "passage_text": "Mitochondrial dynamics in aging cells..."},
        {"id": "q8", "doi": "10.1016/j.cell.456", "passage_text": "Mitochondrial dynamics in aging cells..."},
        {"id": "q9", "topic_id": "linguistics_phonology", "passage_text": "Vowel shifts in early middle english..."},
        {"id": "q10", "topic_id": "linguistics_phonology", "passage_text": "Vowel shifts in early middle english..."},
        {"id": "q11", "pmcid": "PMC7003", "passage_text": "Quantum computing architectures with trapped ions..."},
        {"id": "q12", "pmcid": "PMC7003", "passage_text": "Quantum computing architectures with trapped ions..."},
        {"id": "q13", "doi": "10.1126/science.789", "passage_text": "Deep sea hydrothermal vent microbiological diversity..."},
        {"id": "q14", "doi": "10.1126/science.789", "passage_text": "Deep sea hydrothermal vent microbiological diversity..."},
        {"id": "q15", "pmcid": "PMC6004", "passage_text": "Synthetic biology metabolic pathway optimization..."},
        {"id": "q16", "pmcid": "PMC6004", "passage_text": "Synthetic biology metabolic pathway optimization..."},
    ]
    partition_res = splitter.partition(dataset_items)
    assert partition_res.leakage_violations == 0
    assert partition_res.train_count > 0, "Train split must be non-empty"
    assert partition_res.val_count > 0, "Val split must be non-empty"
    assert partition_res.test_count > 0, "Test split must be non-empty"
    assert partition_res.train_count + partition_res.val_count + partition_res.test_count == len(dataset_items)

    # -------------------------------------------------------------------------
    # Step 6: Paired Offline Evaluation
    # -------------------------------------------------------------------------
    comparator = PairedOfflineComparator()
    runner = OfflineEvalRunner(comparator=comparator)

    benchmark_items = [
        {"id": f"bench_{i:02d}", "is_canary": (i < 5), "is_ambiguity_item": (i < 5)}
        for i in range(25)
    ]

    def baseline_eval(it: dict) -> ItemEvalResult:
        return ItemEvalResult(
            item_id=it["id"],
            hard_invariants_pass=True,
            critical_canary_pass=True if it.get("is_canary") else None,
            semantic_pass=True,
            ambiguity_detected=True if it.get("is_ambiguity_item") else None,
            false_rejected=False,
        )

    def candidate_eval(it: dict) -> ItemEvalResult:
        return ItemEvalResult(
            item_id=it["id"],
            hard_invariants_pass=True,
            critical_canary_pass=True if it.get("is_canary") else None,
            semantic_pass=True,
            ambiguity_detected=True if it.get("is_ambiguity_item") else None,
            false_rejected=False,
        )

    eval_report = runner.run_paired_evaluation(
        benchmark_items=benchmark_items,
        baseline_evaluator_fn=baseline_eval,
        candidate_evaluator_fn=candidate_eval,
        baseline_name="prompts_v2_0_0",
        candidate_name="prompts_v2_1_0",
        save_report=False,
    )

    assert eval_report.verdict == GateVerdict.PASSED
    assert eval_report.passed

    # -------------------------------------------------------------------------
    # Step 7: Staging Version Promotion, Run Binding, and Rollback
    # -------------------------------------------------------------------------
    registry = PromptVersionRegistry(initial_active_version="prompts_v2_0_0")
    promo_mgr = VersionPromotionManager(registry=registry)

    in_flight_run_id = "run_session_alpha"
    assert registry.get_version_for_run(in_flight_run_id) == "prompts_v2_0_0"

    promo_decision = promo_mgr.evaluate_and_promote(
        candidate_version="prompts_v2_1_0",
        description="Phase 14 Promoted Model & Prompts",
        comparison_report=eval_report,
        approver_id="test_curator_phase14_01",
        approver_role="curator",
        reason="Benchmark G14 Passed with 0 Regressions",
        dataset_records=[record],
        dataset_version=curated_export.dataset_version,
    )
    assert promo_decision.status == PromotionStatus.PROMOTED
    assert registry.active_pinned_version == "prompts_v2_1_0"

    new_run_id = "run_session_beta"
    assert registry.get_version_for_run(new_run_id) == "prompts_v2_1_0"
    assert registry.get_version_for_run(in_flight_run_id) == "prompts_v2_0_0"

    rb_decision = promo_mgr.rollback(
        target_version="prompts_v2_0_0",
        operator_id="test_admin_phase14_01",
        operator_role="admin",
        reason="Emergency rollback validation",
    )
    assert rb_decision.status == PromotionStatus.ROLLED_BACK
    assert registry.active_pinned_version == "prompts_v2_0_0"
