"""LANGFENS — Targeted Offline Runner Tests for Live Single-Section Workflow.

Verifies:
- Default CLI execution and --confirm-live gating
- Credential loading, masking, and validation
- Database persistent storage detection
- Missing image detection and safe rebuild guidance
- Persistent submission marker duplicate prevention
- Uncertain HTTP submission recovery and fail-closed behavior
- Bounded polling timeout handling
- Safe topology cleanup (NEVER docker compose down -v)
- Deep read-only forensic extraction and unique snapshot generation

ALL TESTS RUN STRICTLY OFFLINE WITH NO LIVE PROVIDER CALLS.
"""

from __future__ import annotations

import json
import os
import sys
import unittest
from unittest.mock import MagicMock, call, patch

# Ensure repository root is on sys.path
def find_repo_root(start: str) -> str:
    cur = os.path.abspath(start)
    while cur and cur != os.path.dirname(cur):
        if os.path.exists(os.path.join(cur, "deploy", "compose.benchmark-text.yaml")):
            return cur
        cur = os.path.dirname(cur)
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

REPO_ROOT = find_repo_root(__file__)
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

import scripts.run_hybrid_single_section_live as runner


class TestLiveRunnerOffline(unittest.TestCase):
    """Offline unit test suite for run_hybrid_single_section_live.py."""

    def setUp(self):
        # Ensure temporary test marker path doesn't conflict
        self.orig_marker = runner.SUBMISSION_MARKER_PATH
        self.test_marker = os.path.join(runner.REPORTS_DIR, ".test_submission_marker.json")
        runner.SUBMISSION_MARKER_PATH = self.test_marker
        if os.path.exists(self.test_marker):
            os.remove(self.test_marker)
        if os.path.exists(self.test_marker + ".lock"):
            os.remove(self.test_marker + ".lock")

    def tearDown(self):
        if os.path.exists(self.test_marker):
            os.remove(self.test_marker)
        if os.path.exists(self.test_marker + ".lock"):
            os.remove(self.test_marker + ".lock")
        runner.SUBMISSION_MARKER_PATH = self.orig_marker

    # --------------------------------------------------------------------------
    # 1. CLI Default & Confirmation Gating
    # --------------------------------------------------------------------------

    def test_default_execution_without_arguments_does_not_submit_job(self):
        """Default execution with no arguments prints help and exits with 0 without submitting."""
        with patch.object(sys, "argv", ["run_hybrid_single_section_live.py"]), \
             patch("builtins.print") as mock_print:
            with self.assertRaises(SystemExit) as cm:
                runner.main()
            self.assertEqual(cm.exception.code, 0)

    def test_execute_without_confirm_live_refuses_submission(self):
        """Passing --execute without --confirm-live fails closed immediately."""
        with patch.object(sys, "argv", ["run_hybrid_single_section_live.py", "--execute"]), \
             patch("sys.stderr.write") as mock_err:
            with self.assertRaises(SystemExit) as cm:
                runner.main()
            self.assertEqual(cm.exception.code, 1)

    # --------------------------------------------------------------------------
    # 2. Credential Loading & Masking
    # --------------------------------------------------------------------------

    def test_missing_minimax_key_detected(self):
        """load_minimax_key returns empty string when neither env nor ai.env has a valid key."""
        with patch.dict(os.environ, {}, clear=True), \
             patch("os.path.exists", return_value=False):
            key = runner.load_minimax_key()
            self.assertEqual(key, "")

    def test_placeholder_minimax_key_rejected(self):
        """load_minimax_key rejects placeholder or mock values."""
        for ph in ["placeholder", "mock", "xxx", "your_key_here"]:
            with patch.dict(os.environ, {"MINIMAX_API_KEY": ph}):
                key = runner.load_minimax_key()
                self.assertEqual(key, "", f"Expected placeholder '{ph}' to be rejected")

    def test_secret_masking(self):
        """mask_secret masks the middle of secrets preserving only boundary characters."""
        self.assertEqual(runner.mask_secret("sk-cpq-1234567890-test"), "sk-c...test")
        self.assertEqual(runner.mask_secret(""), "<EMPTY>")
        self.assertEqual(runner.mask_secret("short"), "***")

    def test_missing_jwt_sign_key_raises(self):
        """load_jwt_settings raises ValueError when signing key cannot be found."""
        with patch.dict(os.environ, {}, clear=True), \
             patch("os.path.exists", return_value=False):
            with self.assertRaises(ValueError) as cm:
                runner.load_jwt_settings()
            self.assertIn("JwtSettings__SignKey could not be resolved", str(cm.exception))

    def test_missing_internal_api_key_raises(self):
        """load_internal_api_key raises ValueError when internal key is missing."""
        with patch.dict(os.environ, {}, clear=True), \
             patch("os.path.exists", return_value=False):
            with self.assertRaises(ValueError) as cm:
                runner.load_internal_api_key()
            self.assertIn("INTERNAL_API_KEY could not be resolved", str(cm.exception))

    # --------------------------------------------------------------------------
    # 3. Database Persistent Storage Detection
    # --------------------------------------------------------------------------

    def test_preflight_detects_unbacked_data_directory(self):
        """check_db_readiness detects when data_directory is not backed by persistent mount."""
        with patch("scripts.run_hybrid_single_section_live.is_container_running", return_value=True), \
             patch("scripts.run_hybrid_single_section_live.run_container_command") as mock_cmd, \
             patch("subprocess.run") as mock_sub:

            # pg_isready succeeds, select 1 succeeds, SHOW data_directory returns unmounted /var/lib/postgresql/data
            mock_cmd.side_effect = [
                MagicMock(returncode=0, stdout=""),  # pg_isready
                MagicMock(returncode=0, stdout="1\n"),  # SELECT 1
                MagicMock(returncode=0, stdout="/var/lib/postgresql/data\n"),  # SHOW data_directory
            ]
            # docker inspect returns mount at /var/lib/postgresql/exam-data (mismatch!)
            mock_sub.return_value = MagicMock(
                returncode=0,
                stdout=json.dumps([{"Type": "volume", "Destination": "/var/lib/postgresql/exam-data"}])
            )

            res = runner.check_db_readiness()
            self.assertFalse(res["volume_backed"])
            self.assertIn("NOT backed by a mounted persistent volume", res["details"])

    def test_preflight_accepts_correctly_mounted_data_directory(self):
        """check_db_readiness accepts data_directory when inside mounted persistent volume."""
        with patch("scripts.run_hybrid_single_section_live.is_container_running", return_value=True), \
             patch("scripts.run_hybrid_single_section_live.run_container_command") as mock_cmd, \
             patch("subprocess.run") as mock_sub:

            mock_cmd.side_effect = [
                MagicMock(returncode=0, stdout=""),  # pg_isready
                MagicMock(returncode=0, stdout="1\n"),  # SELECT 1
                MagicMock(returncode=0, stdout="/var/lib/postgresql/exam-data/pgdata\n"),  # SHOW data_directory
                MagicMock(returncode=0, stdout="5\n"),  # table count
                MagicMock(returncode=0, stdout="4\n"),  # lease columns count
            ]
            mock_sub.return_value = MagicMock(
                returncode=0,
                stdout=json.dumps([{"Type": "volume", "Destination": "/var/lib/postgresql/exam-data"}])
            )

            res = runner.check_db_readiness()
            self.assertTrue(res["volume_backed"])
            self.assertTrue(res["schema_ready"])

    # --------------------------------------------------------------------------
    # 4. Image Checks & Safe Rebuild Guidance
    # --------------------------------------------------------------------------

    def test_missing_benchmark_image_detected(self):
        """check_benchmark_images returns False for missing images."""
        with patch("subprocess.run") as mock_sub:
            # Let postgres and generation pass, but exam-service fail
            def inspect_side_effect(cmd, **kwargs):
                img = cmd[3]
                if "exam" in img:
                    return MagicMock(returncode=1, stderr="Error: No such image")
                return MagicMock(returncode=0, stdout="{}")
            mock_sub.side_effect = inspect_side_effect

            status = runner.check_benchmark_images()
            self.assertTrue(status["postgres:16-alpine"])
            self.assertTrue(status["langfens-generation:benchmark"])
            self.assertFalse(status["langfens-exam:benchmark"])

    # --------------------------------------------------------------------------
    # 5. Persistent Submission Marker & Duplicate Prevention
    # --------------------------------------------------------------------------

    def test_submission_marker_blocks_duplicate_submission(self):
        """SubmissionMarker.check_safety blocks submission when an existing marker is present."""
        runner.SubmissionMarker.write(status="SUBMITTED", job_id="job-existing-123")

        with self.assertRaises(RuntimeError) as cm:
            runner.SubmissionMarker.check_safety()
        self.assertIn("DUPLICATE SUBMISSION BLOCKED", str(cm.exception))
        self.assertIn("job-existing-123", str(cm.exception))

    def test_submission_marker_cannot_be_reset_via_cli(self):
        """The runner rejects reset requests and preserves the duplicate-submission marker."""
        runner.SubmissionMarker.write(status="SUBMITTED", job_id="job-existing-123")
        self.assertTrue(os.path.exists(self.test_marker))

        with patch.object(sys, "argv", ["run_hybrid_single_section_live.py", "--reset-submission-marker"]):
            with self.assertRaises(SystemExit) as cm:
                runner.main()
        self.assertEqual(cm.exception.code, 2)
        self.assertTrue(os.path.exists(self.test_marker))

    # --------------------------------------------------------------------------
    # 6. Uncertain HTTP Submission & Recovery
    # --------------------------------------------------------------------------

    def test_uncertain_http_submission_recovers_existing_job_without_reposting(self):
        """When POST times out, submit_single_job queries existing jobs and adopts it without reposting."""
        auth_headers = {"Authorization": "Bearer test"}

        # 1st call: urlopen(POST) raises TimeoutError
        # 2nd call: urlopen(GET /api/admin/reading-paper/jobs) returns list with recent job
        post_err = TimeoutError("HTTP request timed out")
        get_resp = MagicMock()
        get_resp.read.return_value = json.dumps([
            {"id": "recovered-job-777", "topic": runner.TOPIC, "status": "Pending"}
        ]).encode("utf-8")
        get_resp.__enter__.return_value = get_resp

        with patch("urllib.request.urlopen") as mock_url:
            mock_url.side_effect = [post_err, get_resp]

            recovered_id = runner.submit_single_job("http://127.0.0.1:8087", auth_headers)
            self.assertEqual(recovered_id, "recovered-job-777")

            # Check that marker reflects recovery
            marker = runner.SubmissionMarker.get_existing()
            self.assertEqual(marker.get("status"), "RECOVERED_SUBMISSION")
            self.assertEqual(marker.get("job_id"), "recovered-job-777")

    def test_uncertain_http_submission_fails_closed_when_not_found(self):
        """When POST times out and GET recovers no matching job, runner halts without retrying."""
        auth_headers = {"Authorization": "Bearer test"}

        post_err = TimeoutError("Network connection dropped")
        get_resp = MagicMock()
        get_resp.read.return_value = json.dumps([]).encode("utf-8")
        get_resp.__enter__.return_value = get_resp

        with patch("urllib.request.urlopen") as mock_url:
            mock_url.side_effect = [post_err, get_resp]

            with self.assertRaises(RuntimeError) as cm:
                runner.submit_single_job("http://127.0.0.1:8087", auth_headers)
            self.assertIn("No matching job was recovered", str(cm.exception))

    # --------------------------------------------------------------------------
    # 7. Bounded Polling Timeout
    # --------------------------------------------------------------------------

    def test_bounded_polling_handles_timeout(self):
        """poll_job returns gracefully with TIMEOUT status when deadline expires."""
        auth_headers = {"Authorization": "Bearer test"}

        running_resp = MagicMock()
        running_resp.read.return_value = json.dumps({
            "id": "job-timeout-test",
            "status": "Running",
            "completedSections": 0,
            "logs": [{"timestamp": "2026-10-25T00:00:00Z", "level": "Info", "message": "Drafting passage..."}]
        }).encode("utf-8")
        running_resp.__enter__.return_value = running_resp

        with patch("urllib.request.urlopen", return_value=running_resp), \
             patch("time.sleep", return_value=None):
            # Pass timeout_seconds = 0 to trigger immediate deadline expiration
            res = runner.poll_job("job-timeout-test", "http://127.0.0.1:8087", auth_headers, timeout_seconds=0)
            self.assertEqual(res.get("status"), "TIMEOUT")

    # --------------------------------------------------------------------------
    # 8. Safe Cleanup (NEVER down -v)
    # --------------------------------------------------------------------------

    def test_safe_cleanup_never_uses_down_v(self):
        """stop_topology calls `docker compose down` and strictly omits `-v`."""
        with patch("subprocess.run") as mock_sub:
            runner.stop_topology()
            mock_sub.assert_called_once()
            cmd = mock_sub.call_args[0][0]
            self.assertEqual(cmd[:4], ["docker", "compose", "-f", runner.COMPOSE_FILE])
            self.assertEqual(cmd[4], "down")
            self.assertNotIn("-v", cmd, "FATAL: `-v` flag must NEVER be passed to `docker compose down`")

    # --------------------------------------------------------------------------
    # 9. Deep Read-Only Forensics & Unique Snapshot Generation
    # --------------------------------------------------------------------------

    def test_forensic_collection_performs_only_readonly_queries_and_records_metrics(self):
        """collect_forensics extracts read-only SQL data and creates unique snapshot file."""
        job_id = "test-job-9999"
        run_id = f"run_{job_id.replace('-', '')}"
        expected_snapshot = os.path.join(runner.REPORTS_DIR, f"hybrid_13q_post_hardening_{job_id}.json")

        sample_runs = [{"RunId": run_id, "JobId": job_id, "Epoch": 1, "LeaseOwner": "owner-1"}]
        sample_ops = [
            {
                "OperationId": "op:passage:1", "OperationType": "PROVIDER_CALL", "Status": "COMPLETED",
                "ArtifactId": "passage:1", "SectionId": "1", "TokensUsed": 5000,
                "PromptTokensUsed": 4000, "CompletionTokensUsed": 1000, "ReasoningTokensUsed": None,
                "WallTimeUsedSeconds": 15.0, "ResultRefJson": '{"model_name": "MiniMax-Text-01"}',
                "CreatedAt": "2026-10-25T00:00:00Z"
            },
            {
                "OperationId": "op:m3:plan:1", "OperationType": "PROVIDER_CALL", "Status": "COMPLETED",
                "ArtifactId": "question:1", "SectionId": "1", "TokensUsed": 3000,
                "PromptTokensUsed": 2000, "CompletionTokensUsed": 500, "ReasoningTokensUsed": 500,
                "WallTimeUsedSeconds": 10.0, "ResultRefJson": '{"model_name": "MiniMax-M3"}',
                "CreatedAt": "2026-10-25T00:01:00Z"
            }
        ]
        sample_heads = [
            {
                "ArtifactId": "passage:1", "ArtifactType": "Passage", "AcceptedVersion": 1,
                "AcceptedHash": "passhash123", "PayloadJson": json.dumps({"title": "Didé West 1", "passage": "Passage text with 800 words."})
            },
            {
                "ArtifactId": "question:1", "ArtifactType": "Question", "AcceptedVersion": 2,
                "AcceptedHash": "qhash123", "PayloadJson": json.dumps({"questionNumber": 1, "prompt": "Prompt 1", "answer": "Answer 1", "evidenceClaimRef": "claim:1:1"})
            }
        ]
        sample_evals = [
            {
                "EvaluationId": "ev-1", "EvaluatorId": "eval_passage_fidelity", "EvaluatorVersion": "1.0.0",
                "TargetArtifactId": "passage:1", "TargetVersion": 1, "TargetContentHash": "h1",
                "Status": "PASS", "IsPass": True, "PayloadJson": "{}"
            }
        ]
        # Include mandatory passing evaluations for question:1 v2
        for eid in runner.MANDATORY_QUESTION_EVALUATORS:
            sample_evals.append({
                "EvaluationId": f"ev-{eid}", "EvaluatorId": eid, "EvaluatorVersion": "1.0.0",
                "TargetArtifactId": "question:1", "TargetVersion": 2, "TargetContentHash": "qhash123",
                "Status": "PASS", "IsPass": True, "PayloadJson": "{}"
            })
        sample_outbox = [
            {"EventId": "ev-1", "IdempotencyKey": "key-1", "Sequence": 1, "Status": "Published", "EventType": "RunCreated"}
        ]

        def query_mock(sql: str) -> list:
            # Verify every SQL query starts with SELECT (strictly read-only)
            self.assertTrue(sql.strip().upper().startswith("SELECT"), f"Query must be SELECT: {sql}")
            if "reading_paper_runs" in sql:
                return sample_runs
            if "reading_paper_operations" in sql:
                return sample_ops
            if "reading_paper_artifact_heads" in sql:
                return sample_heads
            if "reading_paper_evaluations" in sql:
                return sample_evals
            if "reading_paper_event_outbox" in sql:
                return sample_outbox
            return []

        try:
            with patch("scripts.run_hybrid_single_section_live.query_db_json", side_effect=query_mock):
                snapshot = runner.collect_forensics(
                    job_id=job_id,
                    final_job_data={"status": "Completed", "completedSections": 1},
                    wall_time_total=45.2,
                    impl_sha=runner.IMPLEMENTATION_COMMIT,
                )

                self.assertTrue(os.path.exists(expected_snapshot))
                self.assertNotEqual(expected_snapshot, runner.HISTORICAL_SNAPSHOT_PATH)

                # Check snapshot contents
                self.assertEqual(snapshot["job_id"], job_id)
                self.assertEqual(snapshot["implementation_sha"], runner.get_git_head_sha())
                self.assertEqual(snapshot["operations"]["text01_calls"], 1)
                self.assertEqual(snapshot["operations"]["m3_calls"], 1)
                self.assertEqual(snapshot["operations"]["tokens"]["m3_reasoning_tokens"], 500)
                self.assertTrue(snapshot["durability_and_replay"]["operations_unique"])
                self.assertTrue(snapshot["durability_and_replay"]["outbox_idempotency_keys_unique"])
                self.assertIn("Q1", snapshot["questions"]["blueprint_bound_claim_references"])
                self.assertEqual(snapshot["questions"]["repaired_count"], 1)

        finally:
            if os.path.exists(expected_snapshot):
                os.remove(expected_snapshot)

    # --------------------------------------------------------------------------
    # 10. Correctness Fixes Verification (Phase 1 A, B, C, D)
    # --------------------------------------------------------------------------

    def test_preflight_blocks_when_active_reading_jobs_exist(self):
        """Preflight fails closed (BLOCKER) when pre-existing active reading jobs exist."""
        active_mock = {
            "active_jobs_present": True,
            "active_jobs": [{"Id": "job-running-1", "Status": "Running", "Topic": "test"}],
            "active_runs": [],
            "details": "Detected 1 active job(s) and 0 active run(s) in PostgreSQL.",
        }
        with patch("scripts.run_hybrid_single_section_live.check_git_revision", return_value={"head_sha": "abc", "matches_baseline_head": True}), \
             patch("scripts.run_hybrid_single_section_live.check_docker_available", return_value=(True, "Docker OK")), \
             patch("scripts.run_hybrid_single_section_live.check_benchmark_images", return_value={"postgres:16-alpine": True, "langfens-generation:benchmark": True, "langfens-exam:benchmark": True}), \
             patch("scripts.run_hybrid_single_section_live.load_minimax_key", return_value="sk-real-key-12345"), \
             patch("scripts.run_hybrid_single_section_live.load_jwt_settings", return_value=("key", "iss", "aud")), \
             patch("scripts.run_hybrid_single_section_live.load_internal_api_key", return_value="internal-key"), \
             patch("scripts.run_hybrid_single_section_live.check_db_readiness", return_value={"container_running": True, "pg_isready": True, "authenticated_query": True, "volume_backed": True, "schema_ready": True, "fencing_schema_ready": True}), \
             patch("scripts.run_hybrid_single_section_live.check_active_reading_jobs", return_value=active_mock), \
             patch("scripts.run_hybrid_single_section_live.verify_worker_topology", return_value={"single_worker_instance": True, "authoritative_worker_enabled": True, "exam_provider": "minimax", "generation_provider": "minimax", "minimax_key_in_generation": True, "minimax_key_masked": "sk-r...2345"}), \
             patch("urllib.request.urlopen") as mock_url:

            health_resp = MagicMock(status=200)
            mock_url.return_value.__enter__.return_value = health_resp

            passed = runner.run_preflight(start_stack_if_needed=False, keep_stack=False)
            self.assertFalse(passed, "Preflight must fail closed when active reading jobs are detected")

    def test_forensics_does_not_invent_fallback_run_id(self):
        """When reading_paper_runs has no matching row, collect_forensics does not invent a fallback run ID."""
        job_id = "job-no-run-record"
        expected_snapshot = os.path.join(runner.REPORTS_DIR, f"hybrid_13q_post_hardening_{job_id}.json")

        def query_mock(sql: str) -> list:
            if "reading_paper_runs" in sql:
                return []  # No run found
            return []

        try:
            with patch("scripts.run_hybrid_single_section_live.query_db_json", side_effect=query_mock):
                snapshot = runner.collect_forensics(
                    job_id=job_id,
                    final_job_data={"status": "Failed"},
                    wall_time_total=5.0,
                    impl_sha=runner.IMPLEMENTATION_COMMIT,
                )
                self.assertIsNone(snapshot["run_id"], "Fallback RunId must NEVER be invented")
        finally:
            if os.path.exists(expected_snapshot):
                os.remove(expected_snapshot)

    def test_forensics_does_not_count_historical_exams(self):
        """When reading_paper_jobs.ExamId is null, exam_persisted is False even if historical exams exist."""
        job_id = "job-no-committed-exam"
        expected_snapshot = os.path.join(runner.REPORTS_DIR, f"hybrid_13q_post_hardening_{job_id}.json")

        def query_mock(sql: str) -> list:
            if "reading_paper_runs" in sql:
                return [{"RunId": "run_test_123", "JobId": job_id, "Epoch": 1, "LeaseOwner": "owner-1"}]
            if "reading_paper_jobs" in sql:
                return [{"ExamId": None, "Status": "Completed", "CompletedSections": 1}]
            if "exams" in sql:
                # If queried, this historical exam must not be associated
                return [{"Id": "hist-exam-1", "Title": "Historical Exam", "Slug": "reading-old"}]
            return []

        try:
            with patch("scripts.run_hybrid_single_section_live.query_db_json", side_effect=query_mock):
                snapshot = runner.collect_forensics(
                    job_id=job_id,
                    final_job_data={"status": "Completed", "completedSections": 1},
                    wall_time_total=10.0,
                    impl_sha=runner.IMPLEMENTATION_COMMIT,
                )
                self.assertFalse(snapshot["section_checkpoint_status"]["exam_persisted"])
                self.assertEqual(len(snapshot["section_checkpoint_status"]["exams"]), 0)
        finally:
            if os.path.exists(expected_snapshot):
                os.remove(expected_snapshot)

    def test_forensics_rejects_question_without_explicit_provenance(self):
        """A question head whose eval_question_semantic failed with CLAIM_PROVENANCE_MISMATCH is REJECTED."""
        job_id = "job-prov-fail"
        run_id = "run-prov-fail"
        expected_snapshot = os.path.join(runner.REPORTS_DIR, f"hybrid_13q_post_hardening_{job_id}.json")

        sample_heads = [{
            "ArtifactId": "question:1", "ArtifactType": "Question", "AcceptedVersion": 1,
            "AcceptedHash": "h1", "PayloadJson": json.dumps({"questionNumber": 1, "prompt": "P", "answer": "A", "evidenceClaimRef": "claim:1"})
        }]
        # All mandatory evaluations pass EXCEPT eval_question_semantic which has CLAIM_PROVENANCE_MISMATCH
        sample_evals = []
        for eid in runner.MANDATORY_QUESTION_EVALUATORS:
            is_sem = (eid == "eval_question_semantic")
            sample_evals.append({
                "EvaluationId": f"ev-{eid}", "EvaluatorId": eid, "EvaluatorVersion": "1.0.0",
                "TargetArtifactId": "question:1", "TargetVersion": 1, "TargetContentHash": "h1",
                "Status": "FAIL" if is_sem else "PASS",
                "IsPass": not is_sem,
                "PayloadJson": json.dumps({"issues": [{"code": "CLAIM_PROVENANCE_MISMATCH"}]}) if is_sem else "{}",
            })

        def query_mock(sql: str) -> list:
            if "reading_paper_runs" in sql:
                return [{"RunId": run_id, "JobId": job_id, "Epoch": 1, "LeaseOwner": "owner-1"}]
            if "reading_paper_artifact_heads" in sql:
                return sample_heads
            if "reading_paper_evaluations" in sql:
                return sample_evals
            return []

        try:
            with patch("scripts.run_hybrid_single_section_live.query_db_json", side_effect=query_mock):
                snapshot = runner.collect_forensics(
                    job_id=job_id,
                    final_job_data={"status": "Completed"},
                    wall_time_total=10.0,
                    impl_sha=runner.IMPLEMENTATION_COMMIT,
                )
                q1 = next(q for q in snapshot["questions"]["scorecard"] if q["questionNumber"] == 1)
                self.assertEqual(q1["status"], "REJECTED")
                self.assertEqual(q1["provenance_outcome"], "FAIL_PROVENANCE")
                self.assertEqual(snapshot["questions"]["accepted_count"], 0)
        finally:
            if os.path.exists(expected_snapshot):
                os.remove(expected_snapshot)

    def test_forensics_rejects_unevaluated_question(self):
        """A question head with NO evaluations is REJECTED rather than assumed accepted."""
        job_id = "job-uneval"
        run_id = "run-uneval"
        expected_snapshot = os.path.join(runner.REPORTS_DIR, f"hybrid_13q_post_hardening_{job_id}.json")

        sample_heads = [{
            "ArtifactId": "question:1", "ArtifactType": "Question", "AcceptedVersion": 1,
            "AcceptedHash": "h1", "PayloadJson": json.dumps({"questionNumber": 1, "prompt": "P", "answer": "A", "evidenceClaimRef": "claim:1"})
        }]

        def query_mock(sql: str) -> list:
            if "reading_paper_runs" in sql:
                return [{"RunId": run_id, "JobId": job_id, "Epoch": 1, "LeaseOwner": "owner-1"}]
            if "reading_paper_artifact_heads" in sql:
                return sample_heads
            if "reading_paper_evaluations" in sql:
                return []  # No evaluations!
            return []

        try:
            with patch("scripts.run_hybrid_single_section_live.query_db_json", side_effect=query_mock):
                snapshot = runner.collect_forensics(
                    job_id=job_id,
                    final_job_data={"status": "Completed"},
                    wall_time_total=10.0,
                    impl_sha=runner.IMPLEMENTATION_COMMIT,
                )
                q1 = next(q for q in snapshot["questions"]["scorecard"] if q["questionNumber"] == 1)
                self.assertEqual(q1["status"], "REJECTED")
                self.assertIn("Missing mandatory evaluations", q1["failure_reason"])
                self.assertEqual(snapshot["questions"]["accepted_count"], 0)
        finally:
            if os.path.exists(expected_snapshot):
                os.remove(expected_snapshot)

    def test_submission_fails_closed_with_uncertain_submission_on_ambiguous_correlation(self):
        """When POST times out and multiple jobs match the topic, recovery halts with UNCERTAIN_SUBMISSION."""
        auth_headers = {"Authorization": "Bearer test"}
        post_err = TimeoutError("Network connection dropped")

        get_resp = MagicMock()
        # Two jobs matching topic -> ambiguous!
        get_resp.read.return_value = json.dumps([
            {"id": "candidate-job-1", "topic": runner.TOPIC, "status": "Pending"},
            {"id": "candidate-job-2", "topic": runner.TOPIC, "status": "Running"},
        ]).encode("utf-8")
        get_resp.__enter__.return_value = get_resp

        with patch("urllib.request.urlopen") as mock_url:
            mock_url.side_effect = [post_err, get_resp]

            with self.assertRaises(RuntimeError) as cm:
                runner.submit_single_job("http://127.0.0.1:8087", auth_headers)
            self.assertIn("UNCERTAIN_SUBMISSION", str(cm.exception))
            self.assertIn("Ambiguous job recovery", str(cm.exception))

            marker = runner.SubmissionMarker.get_existing()
            self.assertEqual(marker.get("status"), "UNCERTAIN_SUBMISSION")

    def test_accounting_distinguishes_partial_and_unknown_usage(self):
        """When token usage telemetry is missing from an operation, status is PARTIAL and total is not assumed 0."""
        job_id = "job-partial-tokens"
        run_id = "run-partial-tokens"
        expected_snapshot = os.path.join(runner.REPORTS_DIR, f"hybrid_13q_post_hardening_{job_id}.json")

        sample_ops = [
            {
                "OperationId": "op:text:1", "OperationType": "PROVIDER_CALL", "Status": "COMPLETED",
                "TokensUsed": 4000, "PromptTokensUsed": 3000, "CompletionTokensUsed": 1000, "ReasoningTokensUsed": None,
                "WallTimeUsedSeconds": 10.0, "ResultRefJson": '{"model_name": "MiniMax-Text-01"}',
            },
            {
                # Missing all token telemetry
                "OperationId": "op:text:2", "OperationType": "PROVIDER_CALL", "Status": "COMPLETED",
                "TokensUsed": None, "PromptTokensUsed": None, "CompletionTokensUsed": None, "ReasoningTokensUsed": None,
                "WallTimeUsedSeconds": 8.0, "ResultRefJson": '{"model_name": "MiniMax-Text-01"}',
            }
        ]

        def query_mock(sql: str) -> list:
            if "reading_paper_runs" in sql:
                return [{"RunId": run_id, "JobId": job_id, "Epoch": 1, "LeaseOwner": "owner-1"}]
            if "reading_paper_operations" in sql:
                return sample_ops
            return []

        try:
            with patch("scripts.run_hybrid_single_section_live.query_db_json", side_effect=query_mock):
                snapshot = runner.collect_forensics(
                    job_id=job_id,
                    final_job_data={"status": "Completed"},
                    wall_time_total=18.0,
                    impl_sha=runner.IMPLEMENTATION_COMMIT,
                )
                tok_info = snapshot["operations"]["tokens"]
                self.assertEqual(snapshot["operations"]["telemetry_status"], "PARTIAL")
                self.assertTrue(tok_info["unknown_total_usage"])
                self.assertIsNone(tok_info["complete_reported_usage"])
                self.assertEqual(tok_info["partial_known_tokens_subtotal"], 4000)
                self.assertIn("PARTIAL", str(tok_info["total_tokens"]))
        finally:
            if os.path.exists(expected_snapshot):
                os.remove(expected_snapshot)


if __name__ == "__main__":
    unittest.main()
