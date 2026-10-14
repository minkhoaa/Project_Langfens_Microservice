"""Unit tests for Phase 14: Paired Offline Comparison, Gating, Promotion, and Rollback.

Covers:
- T14-07: Candidate failing hard gate is rejected from promotion despite higher soft metrics.
- T14-08: Staging new version applies to new runs; in-flight/cache retain old version; rollback succeeds cleanly.
"""
import pytest

from app.curation.curation import ActionType, CurationManager, CurationStatus, FeedbackRecord
from app.offline_eval.comparison import (
    GateVerdict,
    ItemEvalResult,
    PairedComparisonReport,
    PairedOfflineComparator,
)
from app.offline_eval.runner import OfflineEvalRunner, create_mock_evaluator
from app.promotion.promotion import (
    PromotionDecision,
    PromotionError,
    PromotionStatus,
    VersionPromotionManager,
)
from app.promotion.registry import PromptVersionRegistry, RegistryError


class TestT14OfflineEvalComparison:
    """T14-07: Paired Offline Comparison and Hard Gate Rejection."""

    def test_candidate_failing_hard_invariants_rejected_despite_higher_soft_metrics(self) -> None:
        """Candidate has 99% semantic recall (+5% over baseline) but fails 1 hard invariant (98% < 100%).

        Must be classified as REJECTED_HARD_GATE and refused promotion.
        """
        comparator = PairedOfflineComparator()

        # 50 benchmark items
        baseline_results: list[ItemEvalResult] = []
        candidate_results: list[ItemEvalResult] = []

        for i in range(50):
            item_id = f"item_{i:03d}"
            # Baseline: 100% hard pass, 94% semantic recall
            baseline_results.append(
                ItemEvalResult(
                    item_id=item_id,
                    hard_invariants_pass=True,
                    critical_canary_pass=True if i < 10 else None,
                    semantic_pass=(i % 16 != 0),  # 3 items fail -> 47/50 = 94%
                    ambiguity_detected=True if i < 10 else None,
                    false_rejected=False,
                )
            )

            # Candidate: Fails 1 hard invariant (item_005), but has 100% semantic recall (50/50)
            cand_hard_pass = (i != 5)  # item_005 fails hard invariant!
            candidate_results.append(
                ItemEvalResult(
                    item_id=item_id,
                    hard_invariants_pass=cand_hard_pass,
                    critical_canary_pass=True if i < 10 else None,
                    semantic_pass=True,  # 100% semantic recall (+6% over baseline)
                    ambiguity_detected=True if i < 10 else None,
                    false_rejected=False,
                )
            )

        report = comparator.compare(
            report_id="rep_hard_fail_01",
            baseline_results=baseline_results,
            candidate_results=candidate_results,
            baseline_name="prompts_v2_0_0",
            candidate_name="prompts_v2_1_0_flawed",
        )

        assert report.verdict == GateVerdict.REJECTED_HARD_GATE
        assert not report.passed
        assert "item_005" in report.hard_invariant_regressions
        assert any("hard invariants" in r.lower() for r in report.rejection_reasons)

        # Attempt to promote through VersionPromotionManager
        mgr = VersionPromotionManager()
        decision = mgr.evaluate_and_promote(
            candidate_version="prompts_v2_1_0_flawed",
            description="Candidate with superior semantic recall but 1 broken hard invariant",
            comparison_report=report,
            approver_id="admin_1",
            approver_role="admin",
            reason="Attempting promotion based on soft metric gains",
        )

        assert decision.status == PromotionStatus.REJECTED
        assert mgr.registry.active_pinned_version == "prompts_v2_0_0"  # Did NOT change

    def test_candidate_passing_all_gates_promoted(self) -> None:
        """Candidate with 100% hard invariants, 100% canaries, >=95% recall, <=10% false rejection."""
        comparator = PairedOfflineComparator()

        baseline_results: list[ItemEvalResult] = []
        candidate_results: list[ItemEvalResult] = []

        for i in range(50):
            item_id = f"item_{i:03d}"
            # Baseline: 100% hard, 95% semantic
            baseline_results.append(
                ItemEvalResult(
                    item_id=item_id,
                    hard_invariants_pass=True,
                    critical_canary_pass=True if i < 10 else None,
                    semantic_pass=(i % 20 != 0),
                    ambiguity_detected=True if i < 10 else None,
                    false_rejected=(i == 49),
                )
            )
            # Candidate: 100% hard, 98% semantic, 0 false rejection
            candidate_results.append(
                ItemEvalResult(
                    item_id=item_id,
                    hard_invariants_pass=True,
                    critical_canary_pass=True if i < 10 else None,
                    semantic_pass=(i % 50 != 0),  # 49/50 = 98%
                    ambiguity_detected=True if i < 10 else None,
                    false_rejected=False,
                )
            )

        report = comparator.compare(
            report_id="rep_pass_01",
            baseline_results=baseline_results,
            candidate_results=candidate_results,
        )

        assert report.verdict == GateVerdict.PASSED
        assert report.passed

        mgr = VersionPromotionManager()
        decision = mgr.evaluate_and_promote(
            candidate_version="prompts_v2_1_0_valid",
            description="Production candidate passing all hard and soft gates",
            comparison_report=report,
            approver_id="curator_lead",
            approver_role="curator",
            reason="Passed benchmark with 0 regressions",
        )

        assert decision.status == PromotionStatus.PROMOTED
        assert mgr.registry.active_pinned_version == "prompts_v2_1_0_valid"

    def test_security_rule_uncurated_data_blocks_promotion(self) -> None:
        """Candidate trained on RAW or ANNOTATED feedback cannot be promoted to production."""
        comparator = PairedOfflineComparator()
        # Create passing report
        report = comparator.compare(
            report_id="rep_clean_01",
            baseline_results=[ItemEvalResult(item_id="i1", hard_invariants_pass=True, critical_canary_pass=None, semantic_pass=True, ambiguity_detected=None, false_rejected=False)],
            candidate_results=[ItemEvalResult(item_id="i1", hard_invariants_pass=True, critical_canary_pass=None, semantic_pass=True, ambiguity_detected=None, false_rejected=False)],
        )

        # Dataset contains uncurated RAW record
        uncurated_records = [
            FeedbackRecord(
                feedback_id="fb_raw_1",
                editor_id="ed_1",
                editor_role="editor",
                action_type=ActionType.EDIT,
                status=CurationStatus.RAW,
            )
        ]

        mgr = VersionPromotionManager()
        decision = mgr.evaluate_and_promote(
            candidate_version="prompts_v2_2_0_raw_data",
            description="Model trained on uncurated feedback",
            comparison_report=report,
            approver_id="admin_1",
            approver_role="admin",
            reason="Test raw data prevention",
            dataset_records=uncurated_records,
        )

        assert decision.status == PromotionStatus.REJECTED
        assert any("Security Violation" in r for r in decision.rejection_reasons)
        assert mgr.registry.active_pinned_version == "prompts_v2_0_0"

    def test_t14_hard_gate_failure_blocks_promotion(self) -> None:
        """Canonical T14-07 test."""
        self.test_candidate_failing_hard_invariants_rejected_despite_higher_soft_metrics()
        self.test_candidate_passing_all_gates_promoted()
        self.test_security_rule_uncurated_data_blocks_promotion()


class TestT14PromotionAndRollback:
    """T14-08: Staging version, In-flight run retention, and Rollback."""

    def test_in_flight_run_retention_and_routing(self) -> None:
        registry = PromptVersionRegistry(initial_active_version="prompts_v2_0_0")

        # Run 1 starts under v2.0.0
        run_1_id = "run_exam_session_1001"
        v_run1 = registry.get_version_for_run(run_1_id)
        assert v_run1 == "prompts_v2_0_0"

        # Stage and pin new version v2.1.0
        registry.register_version(
            version="prompts_v2_1_0",
            description="Phase 14 improved prompts",
            registered_by="curator_1",
        )
        registry.pin_active_version(
            "prompts_v2_1_0",
            pinned_by="curator_1",
            reason="Benchmark promotion",
        )
        assert registry.active_pinned_version == "prompts_v2_1_0"

        # Run 2 starts after promotion -> receives new version v2.1.0
        run_2_id = "run_exam_session_1002"
        v_run2 = registry.get_version_for_run(run_2_id)
        assert v_run2 == "prompts_v2_1_0"

        # In-flight Run 1 performs a subsequent step -> STILL bound to v2.0.0!
        v_run1_step2 = registry.get_version_for_run(run_1_id)
        assert v_run1_step2 == "prompts_v2_0_0", "In-flight run failed to retain its bound version!"

    def test_version_rollback(self) -> None:
        mgr = VersionPromotionManager()
        # Register v2.1.0 and pin it
        mgr.registry.register_version(
            version="prompts_v2_1_0",
            description="Version 2.1.0",
            registered_by="admin_1",
        )
        mgr.registry.pin_active_version(
            "prompts_v2_1_0",
            pinned_by="admin_1",
            reason="Manual upgrade",
        )
        assert mgr.registry.active_pinned_version == "prompts_v2_1_0"

        # Perform rollback to previous version v2.0.0
        decision = mgr.rollback(
            target_version="prompts_v2_0_0",
            operator_id="admin_1",
            operator_role="admin",
            reason="Detected anomaly in production metrics",
        )

        assert decision.status == PromotionStatus.ROLLED_BACK
        assert decision.version == "prompts_v2_0_0"
        assert decision.previous_version == "prompts_v2_1_0"
        assert mgr.registry.active_pinned_version == "prompts_v2_0_0"

        # New runs after rollback get v2.0.0
        run_3_id = "run_exam_session_1003"
        assert mgr.registry.get_version_for_run(run_3_id) == "prompts_v2_0_0"

    def test_t14_staging_version_pinning_and_rollback(self) -> None:
        """Canonical T14-08 test."""
        self.test_in_flight_run_retention_and_routing()
        self.test_version_rollback()


class TestPromotionSecurityAndPinning:
    """Additional security, auth, and version pinning test coverage."""

    def test_unauthorized_role_promotion_rejected(self) -> None:
        comparator = PairedOfflineComparator()
        report = comparator.compare(
            report_id="rep_clean_role_01",
            baseline_results=[ItemEvalResult(item_id="i1", hard_invariants_pass=True, critical_canary_pass=None, semantic_pass=True, ambiguity_detected=None, false_rejected=False)],
            candidate_results=[ItemEvalResult(item_id="i1", hard_invariants_pass=True, critical_canary_pass=None, semantic_pass=True, ambiguity_detected=None, false_rejected=False)],
        )
        mgr = VersionPromotionManager()
        # Unauthorized role 'guest' / 'student'
        decision = mgr.evaluate_and_promote(
            candidate_version="prompts_v2_3_0_unauth",
            description="Attempted promotion by unauthorized role",
            comparison_report=report,
            approver_id="user_guest_01",
            approver_role="guest",
            reason="Unauthorized attempt",
        )
        assert decision.status == PromotionStatus.REJECTED
        assert any("not authorized" in r for r in decision.rejection_reasons)
        assert mgr.registry.active_pinned_version == "prompts_v2_0_0"

    def test_registry_persistence_save_load(self, tmp_path) -> None:
        save_file = tmp_path / "version_registry.json"
        registry = PromptVersionRegistry(initial_active_version="prompts_v2_0_0")
        registry.register_version(
            version="prompts_v2_1_0",
            description="Persisted test version",
            registered_by="admin_test",
        )
        registry.pin_active_version(
            "prompts_v2_1_0",
            pinned_by="admin_test",
            reason="Testing save/load",
        )
        registry.get_version_for_run("run_persisted_001")

        # Save
        registry.save(save_file)
        assert save_file.exists()

        # Load
        loaded = PromptVersionRegistry.load(save_file)
        assert loaded.active_pinned_version == "prompts_v2_1_0"
        assert loaded.get_version_for_run("run_persisted_001") == "prompts_v2_1_0"
        assert len(loaded.list_versions()) == 2

    def test_facade_run_binding_and_cache_isolation(self) -> None:
        from app.facade import GenerationFacade
        facade = GenerationFacade()

        run_alpha = "run_session_alpha"
        v_alpha = facade.bind_run(run_alpha)
        assert v_alpha == "prompts_v2_0_0"

        cache_key_alpha = facade.compute_solver_cache_key(run_alpha, "sha_chunk_123")
        assert cache_key_alpha.startswith("prompts_v2_0_0:prompts_v2_0_0:v2:sha_chunk_123")
