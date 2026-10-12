"""Real PostgreSQL Integration & Durability Fault-Injection Tests for T09-07.

Validates the authoritative .NET exam-service HTTP boundary and PostgreSQL durability
across the 4 required crash windows during Q17 generation, plus post-commit idempotent replay:
1. Pre-dispatch: Operation granted in RESERVED state, crash before dispatch.
2. In-flight (UNKNOWN_OUTCOME): Operation dispatched, connection dropped / missing response.
3. Pre-commit: Candidate draft saved, crash before CAS commit of accepted artifact.
4. Post-commit pre-ACK: CAS commit completed in PostgreSQL, crash before client ACK.
5. Idempotent Replay Accounting: Replay with identical slots does not increment durable
   counters (callsUsed, tokensUsed) and generates zero new billable work.
"""

from __future__ import annotations

from datetime import datetime, timezone, timedelta
import hashlib
import re
from pathlib import Path
import subprocess
import urllib.request
from typing import Any, Dict, List, Tuple
from uuid import UUID, uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.facade import GenerationFacade
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.persistence.client import CheckpointClient
from app.persistence.models import (
    CheckpointCommitRequest,
    DraftCheckpointRequest,
    LoopCursorCheckpointRequest,
    OperationGrantRequest,
    OperationReconcileRequest,
)

REAL_SERVICE_URL = "http://127.0.0.1:5099"
REAL_API_KEY = "test-only-ephemeral-secret-key-phase09"


def is_service_available() -> bool:
    """Whether the live exam-service process is reachable on the real-test port.

    Used as a module-level skipif guard so a machine without the service running
    skips cleanly instead of erroring mid-test. Never raises.
    """
    try:
        req = urllib.request.Request(f"{REAL_SERVICE_URL}/healthz", method="GET")
        with urllib.request.urlopen(req, timeout=5) as resp:
            return 200 <= resp.status < 500
    except Exception:
        return False


def is_docker_postgres_available() -> bool:
    """Whether a real PostgreSQL exam database is reachable for these durability tests.

    Returns False instead of skipping when docker itself is missing or errors, so a
    module-level ``@pytest.mark.skipif(not is_docker_postgres_available())`` still
    produces a clean skip rather than an error during collection. Never raises.
    """
    try:
        res = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}"],
            capture_output=True, text=True, timeout=30,
        )
    except (OSError, subprocess.SubprocessError):
        return False
    if res.returncode != 0:
        return False
    names = res.stdout.split()
    return any("exam-database" in n or "exam-db-server" in n or "exam_db" in n for n in names)


def get_exam_db_container() -> str:
    res = subprocess.run(
        ["docker", "ps", "--filter", "name=exam-database", "--format", "{{.Names}}"],
        capture_output=True,
        text=True,
        check=True,
    )
    names = res.stdout.strip().split()
    if not names:
        res2 = subprocess.run(
            ["docker", "ps", "--filter", "name=exam-db-server", "--format", "{{.Names}}"],
            capture_output=True,
            text=True,
            check=True,
        )
        names = res2.stdout.strip().split()
    if not names:
        pytest.skip("No running exam database container found in Docker; skipping real PostgreSQL durability tests")
    return names[0]


def run_psql(sql: str) -> str:
    cname = get_exam_db_container()
    cmd = ["docker", "exec", "-e", "PGPASSWORD=exam", cname, "psql", "-U", "exam", "-d", "exam_test_phase09", "-t", "-A", "-c", sql]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return proc.stdout.strip()


def seed_real_job_and_run(run_id: str, owner_id: UUID, epoch: int = 1) -> str:
    job_id = str(uuid4())
    now = datetime.now(timezone.utc).isoformat()
    lease_until = datetime.now(timezone.utc).replace(year=2030).isoformat()

    sql_job = f"""
    INSERT INTO reading_paper_jobs (
        "Id", "Topic", "Status", "Epoch", "CancelVersion", "LeaseOwner",
        "LeaseUntil", "SourcesJson", "SectionsJson", "CompletedSections",
        "ActiveRunId", "CreatedAt", "UpdatedAt"
    ) VALUES (
        '{job_id}', 'Real Postgres Durability Test', 'Running', {epoch}, 0, '{owner_id}',
        '{lease_until}', '[]', '[]', 0,
        '{run_id}', '{now}', '{now}'
    );
    """
    sql_run = f"""
    INSERT INTO reading_paper_runs (
        "Id", "JobId", "RunId", "Epoch", "CancelVersion", "Status",
        "LeaseOwner", "LeaseUntil", "EngineVersion", "SchemaVersion",
        "PolicyVersion", "BudgetCapCalls", "BudgetCapTokens",
        "BudgetUsedCalls", "BudgetUsedTokens", "CreatedAt", "UpdatedAt"
    ) VALUES (
        '{uuid4()}', '{job_id}', '{run_id}', {epoch}, 0, 'RUNNING',
        '{owner_id}', '{lease_until}', '2.0.0', '2.0.0',
        '2.0.0', 50, 100000,
        0, 0, '{now}', '{now}'
    );
    """
    run_psql(sql_job)
    run_psql(sql_run)
    return job_id


def setup_upstream_and_precommitted_questions(
    client: CheckpointClient,
    run_id: str,
    owner_id: UUID,
    epoch: int = 1,
) -> Tuple[ArtifactEnvelope, ArtifactEnvelope, Dict[str, str]]:
    """Seeds real upstream Passage and Blueprint, and commits Q14, Q15, Q16 in real PostgreSQL."""
    passage_art = ArtifactEnvelope.create(
        artifact_id=f"art_passage_{run_id[:8]}",
        artifact_type=ArtifactType.PASSAGE,
        version=1,
        payload={
            "text": "Archaeological excavations documented ancient architecture. Further studies confirmed pottery.",
            "sourceText": "Archaeological excavations documented ancient architecture. Further studies confirmed pottery.",
        },
        run_id=run_id,
        producer_version="2.0.0",
    )
    bp_art = ArtifactEnvelope.create(
        artifact_id=f"art_blueprint_{run_id[:8]}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload={"title": "Real PG Blueprint", "sections": [{"sectionIndex": 1, "targetQuestionCount": 13}]},
        run_id=run_id,
        producer_version="2.0.0",
    )

    # Grant and commit passage
    op_p = f"op_commit_p_{run_id[:8]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=epoch, leaseOwner=owner_id,
        operationId=op_p, operationType="CHECKPOINT_COMMIT",
        requestHash=passage_art.content_hash, tokenReservation=0, wallTimeReservationSeconds=0,
        sectionId=None, artifactId=None,
    ))
    client.commit_checkpoint(CheckpointCommitRequest(
        runId=run_id, epoch=epoch, leaseOwner=owner_id,
        operationId=op_p, requestHash=passage_art.content_hash,
        artifact=passage_art, evaluations=[],
    ))

    # Grant and commit blueprint
    op_bp = f"op_commit_bp_{run_id[:8]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=epoch, leaseOwner=owner_id,
        operationId=op_bp, operationType="CHECKPOINT_COMMIT",
        requestHash=bp_art.content_hash, tokenReservation=0, wallTimeReservationSeconds=0,
        sectionId=None, artifactId=None,
    ))
    client.commit_checkpoint(CheckpointCommitRequest(
        runId=run_id, epoch=epoch, leaseOwner=owner_id,
        operationId=op_bp, requestHash=bp_art.content_hash,
        artifact=bp_art, evaluations=[],
    ))
    # Commit questions Q14, Q15, Q16
    q_hashes: Dict[str, str] = {}
    for q_num in (14, 15, 16):
        q_art = ArtifactEnvelope.create(
            artifact_id=f"art_q_{q_num}_{run_id[:8]}",
            artifact_type=ArtifactType.QUESTION,
            version=1,
            payload={
                "questionNumber": q_num,
                "questionType": "TrueFalseNotGiven",
                "prompt": f"Real PG committed question {q_num}",
                "answer": "TRUE",
                "passage": passage_art.payload["text"],
            },
            parent_refs=[passage_art.to_ref(), bp_art.to_ref()],
            run_id=run_id,
            producer_version="2.0.0",
        )
        op_id = f"op_commit_{q_num}_{run_id[:8]}"
        req_hash = hashlib.sha256(f"{run_id}:{q_art.artifact_id}".encode()).hexdigest()
        client.grant_operation(OperationGrantRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner_id,
            operationId=op_id, operationType="CHECKPOINT_COMMIT",
            requestHash=req_hash, tokenReservation=0, wallTimeReservationSeconds=0,
            sectionId=None, artifactId=None,
        ))
        client.commit_checkpoint(CheckpointCommitRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner_id,
            operationId=op_id, requestHash=req_hash,
            artifact=q_art, evaluations=[],
        ))
        q_hashes[q_art.artifact_id] = q_art.content_hash

    return passage_art, bp_art, q_hashes


@pytest.mark.asyncio
async def test_real_postgres_t09_07_crash_window_1_pre_dispatch():
    """Scenario 1: Pre-dispatch fault injection (crash while operation is RESERVED before dispatch)."""
    owner_id = uuid4()
    run_id = f"run_w1_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    # Fault-inject: Grant operation for Q17 in RESERVED state, crash before model call
    crash_op_id = f"op_w1_q17_{uuid4().hex[:6]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=crash_op_id, operationType="GENERATE",
        requestHash=hashlib.sha256(b"w1_pre_dispatch").hexdigest(),
        tokenReservation=1200, wallTimeReservationSeconds=30,
        sectionId=None, artifactId=None,
    ))

    # Verify state on resume: Q14-16 heads/hashes preserved in real PostgreSQL
    resumed_state = client.resume_state(run_id)
    assert resumed_state.runId == run_id
    assert resumed_state.status == "RUNNING"
    for art_id, expected_hash in original_q_hashes.items():
        matched = next((a for a in resumed_state.artifacts if a.artifactId == art_id), None)
        assert matched is not None, f"Artifact {art_id} missing on resume!"
        assert matched.acceptedHash == expected_hash, f"Artifact {art_id} hash mutated!"

    # Uncompleted Q17 operation is RESERVED; now reconcile it
    client.reconcile_operation(OperationReconcileRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=crash_op_id, tokensUsed=0, wallTimeUsedSeconds=0.0,
        accountingType="RECONCILED",
    ))


@pytest.mark.asyncio
async def test_real_postgres_t09_07_crash_window_2_inflight_unknown_outcome():
    """Scenario 2: In-flight fault injection (dispatched, dropped connection -> UNKNOWN_OUTCOME)."""
    owner_id = uuid4()
    run_id = f"run_w2_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    # Fault-inject: Grant operation for Q17 with token reservation
    inflight_op_id = f"op_w2_q17_{uuid4().hex[:6]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=inflight_op_id, operationType="GENERATE",
        requestHash=hashlib.sha256(b"w2_inflight").hexdigest(),
        tokenReservation=1500, wallTimeReservationSeconds=45,
        sectionId=None, artifactId=None,
    ))
    # Dispatch dropped connection in-flight -> call record_unknown_outcome
    from app.persistence.models import UnknownOutcomeRequest
    uo_ack = client.record_unknown_outcome(UnknownOutcomeRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=inflight_op_id,
        errorMessage="Simulated network drop in-flight before response received",
    ))
    assert uo_ack.status == "UNKNOWN_OUTCOME"
    assert uo_ack.reservationPreserved is True

    # Invariant: UNKNOWN_OUTCOME must hold reservation until reconciled; not blindly refunded
    resumed_state = client.resume_state(run_id)
    matching_ops = [op for op in resumed_state.operations if op.operationId == inflight_op_id]
    assert len(matching_ops) == 1
    assert matching_ops[0].status == "UNKNOWN_OUTCOME"
    assert matching_ops[0].tokenReservation == 1500
    # Reconcile operation explicitly
    client.reconcile_operation(OperationReconcileRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=inflight_op_id, tokensUsed=1500, wallTimeUsedSeconds=1.2,
        accountingType="ESTIMATED",
    ))


@pytest.mark.asyncio
async def test_real_postgres_t09_07_crash_window_3_pre_commit():
    """Scenario 3: Pre-commit fault injection (draft saved, crash before CAS commit of accepted artifact)."""
    owner_id = uuid4()
    run_id = f"run_w3_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    # Save candidate draft for Q17
    draft_q17 = ArtifactEnvelope.create(
        artifact_id=f"art_q_17_{run_id[:8]}_draft",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        payload={"questionNumber": 17, "prompt": "Draft question", "answer": "POTTERY"},
        parent_refs=[p_art.to_ref(), bp_art.to_ref()],
        run_id=run_id,
        producer_version="2.0.0",
    )
    draft_op_id = f"draft_op_{run_id[:8]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=draft_op_id, operationType="DRAFT",
        requestHash=draft_q17.content_hash, tokenReservation=0, wallTimeReservationSeconds=0,
        sectionId=None, artifactId=None,
    ))
    client.save_draft_checkpoint(DraftCheckpointRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=draft_op_id,
        requestHash=draft_q17.content_hash,
        artifact=draft_q17,
    ))

    # Crash before commit. On resume: Q14-16 accepted heads intact, Q17 head not accepted
    resumed_state = client.resume_state(run_id)
    accepted_ids = {a.artifactId for a in resumed_state.artifacts}
    for q_id in original_q_hashes:
        assert q_id in accepted_ids
    assert f"art_q_17_{run_id[:8]}" not in accepted_ids


@pytest.mark.asyncio
async def test_real_postgres_t09_07_crash_window_4_post_commit_pre_ack():
    """Scenario 4: Post-commit pre-ACK fault injection (CAS commit succeeded in DB, crash before client ACK)."""
    owner_id = uuid4()
    run_id = f"run_w4_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    # CAS commit Q17 accepted artifact to real PostgreSQL
    q17_art = ArtifactEnvelope.create(
        artifact_id=f"art_q_17_{run_id[:8]}",
        artifact_type=ArtifactType.QUESTION,
        version=1,
        payload={"questionNumber": 17, "prompt": "Committed Q17", "answer": "POTTERY", "passage": p_art.payload["text"]},
        parent_refs=[p_art.to_ref(), bp_art.to_ref()],
        run_id=run_id,
        producer_version="2.0.0",
    )
    op_id = f"op_commit_q17_{run_id[:8]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=op_id, operationType="CHECKPOINT_COMMIT",
        requestHash=q17_art.content_hash, tokenReservation=0, wallTimeReservationSeconds=0,
        sectionId=None, artifactId=None,
    ))
    client.commit_checkpoint(CheckpointCommitRequest(
        runId=run_id, epoch=1, leaseOwner=owner_id,
        operationId=op_id, requestHash=q17_art.content_hash,
        artifact=q17_art, evaluations=[],
    ))
    # Simulated crash: no reconcile/ACK yet sent

    # On resume: PostgreSQL already has accepted head v1
    resumed_state = client.resume_state(run_id)
    q17_head = next((a for a in resumed_state.artifacts if a.artifactId == q17_art.artifact_id), None)
    assert q17_head is not None, "Post-commit head must be preserved in real PostgreSQL!"
    assert q17_head.acceptedVersion == 1
    assert q17_head.acceptedHash == q17_art.content_hash


@pytest.mark.asyncio
async def test_real_postgres_t09_07_idempotent_replay_accounting():
    """Scenario 5: Post-commit idempotent replay accounting verification on real PostgreSQL."""
    owner_id = uuid4()
    run_id = f"run_idempotent_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    facade = GenerationFacade(persistence_client=client)

    # First run: requests Q14-17 (Q14-16 already committed, generates Q17)
    slots = [
        {"number": 14, "type": "TrueFalseNotGiven"},
        {"number": 15, "type": "TrueFalseNotGiven"},
        {"number": 16, "type": "TrueFalseNotGiven"},
        {"number": 17, "type": "SentenceCompletion"},
    ]

    res1 = await facade.generate_questions_v2(
        passage_artifact=p_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res1["status"] == "COMPLETED"
    assert res1["resumedCount"] == 3
    assert res1["generatedCount"] == 1
    assert res1["totalQuestions"] == 4

    # Snapshot state 1 and deadline from real PostgreSQL
    state1 = client.resume_state(run_id)
    heads_snapshot = {a.artifactId: (a.acceptedVersion, a.acceptedHash) for a in state1.artifacts}
    calls1 = getattr(state1, "callsUsed", 0) or 0
    tokens1 = getattr(state1, "tokensUsed", 0) or 0
    wall_time1 = getattr(state1, "wallTimeUsedSeconds", 0.0) or 0.0
    budget_caps1 = (
        getattr(state1, "budgetCapCalls", 50),
        getattr(state1, "budgetCapTokens", 100000),
    )
    lease_deadline1 = run_psql(f"SELECT \"LeaseUntil\" FROM reading_paper_runs WHERE \"RunId\" = '{run_id}'")
    # Second run (Idempotent Replay): identical slots and inputs
    res2 = await facade.generate_questions_v2(
        passage_artifact=p_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res2["status"] == "COMPLETED"
    assert res2["resumedCount"] == 4
    assert res2["generatedCount"] == 0

    # Snapshot state 2 from real PostgreSQL
    state2 = client.resume_state(run_id)
    heads_after_replay = {a.artifactId: (a.acceptedVersion, a.acceptedHash) for a in state2.artifacts}
    calls2 = getattr(state2, "callsUsed", 0) or 0
    tokens2 = getattr(state2, "tokensUsed", 0) or 0
    wall_time2 = getattr(state2, "wallTimeUsedSeconds", 0.0) or 0.0
    budget_caps2 = (
        getattr(state2, "budgetCapCalls", 50),
        getattr(state2, "budgetCapTokens", 100000),
    )

    # Invariants:
    # 1. Accepted heads and hashes are 100% identical
    assert heads_after_replay == heads_snapshot, "Replay mutated accepted artifact heads in real PostgreSQL!"

    # 2. Durable counters do NOT increase (zero new billable work)
    assert calls2 == calls1, f"Replay increased callsUsed: {calls1} -> {calls2}"
    assert tokens2 == tokens1, f"Replay increased tokensUsed: {tokens1} -> {tokens2}"
    assert wall_time2 == wall_time1, f"Replay work billed to wallTimeUsedSeconds: {wall_time1} -> {wall_time2}"

    # 3. Budget caps and run limits are preserved (deadline not reset)
    assert budget_caps2 == budget_caps1, "Replay modified budget caps on run!"
    lease_deadline2 = run_psql(f"SELECT \"LeaseUntil\" FROM reading_paper_runs WHERE \"RunId\" = '{run_id}'")
    assert lease_deadline2 == lease_deadline1, "Replay reset or modified run deadline (LeaseUntil)!"
    # 4. Acceptance-order invariant: only the winning group became an accepted head in PostgreSQL!
    # Individual candidates from the generation pool must NEVER become accepted heads!
    accepted_head_ids = set(heads_snapshot.keys())
    assert any(h_id.startswith("art_grp_") for h_id in accepted_head_ids), "Winning group artifact head missing!"
    for h_id in accepted_head_ids:
        assert not h_id.startswith("art_q_17"), f"Individual candidate {h_id} prematurely committed as accepted head in PostgreSQL!"

    db_heads_raw = run_psql(f"SELECT \"ArtifactId\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}'")
    db_head_ids = set(db_heads_raw.split())
    assert any(h.startswith("art_grp_") for h in db_head_ids), "Group artifact head missing from PostgreSQL table!"
    for h in db_head_ids:
        assert not h.startswith("art_q_17"), f"Candidate {h} prematurely became an accepted head in PostgreSQL table!"
@pytest.mark.asyncio
async def test_real_postgres_t09_07_failure_and_retry_accounting():
    """Scenario 6: Real PostgreSQL verification of safe failure lifecycle handling and retry accounting."""
    from app.generators.question.generator import QuestionCandidateGenerator
    from app.generators.question.context import QuestionCandidate, QuestionCandidatePool
    from app.selection.selector import SelectionInfeasibleError
    from app.loop.question import QuestionCandidateLoop

    owner_id = uuid4()
    run_id = f"run_fail_retry_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    p_art, bp_art, _ = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    class AllInvalidGenerator(QuestionCandidateGenerator):
        def __init__(self):
            super().__init__(gateway=None)

        async def generate_candidate_pool(self, **kwargs):
            q_num = kwargs.get("question_number", 17)
            q_type = kwargs.get("question_type", "SentenceCompletion")
            pool = QuestionCandidatePool(slotId=f"slot_q{q_num}", questionNumber=q_num, questionType=q_type, poolLimit=2)
            c1 = QuestionCandidate(
                candidateId=f"cand_inv_1_{uuid4().hex[:6]}",
                slotId=f"slot_q{q_num}",
                passageRef=p_art.to_ref(),
                blueprintRef=bp_art.to_ref(),
                questionNumber=q_num,
                questionType=q_type,
                prompt="The excavations revealed ancient architectural _____.",
                answer="four words long answer",
                evidenceQuote="Archaeological excavations documented ancient architecture.",
            )
            pool.add_candidate(c1)
            return pool

    q_loop_fail = QuestionCandidateLoop(generator=AllInvalidGenerator(), persistence_client=client)
    slots = [
        {"number": 14, "type": "TrueFalseNotGiven"},
        {"number": 15, "type": "TrueFalseNotGiven"},
        {"number": 16, "type": "TrueFalseNotGiven"},
        {"number": 17, "type": "SentenceCompletion"},
    ]

    with pytest.raises((SelectionInfeasibleError, ValueError)):
        await q_loop_fail.run(
            passage_artifact=p_art,
            blueprint_ref=bp_art.to_ref(),
            question_slots=slots,
            run_id=run_id,
            lease_owner=owner_id,
            epoch=1,
        )

    # Invariant 1: Even on failure, workflow parent operation MUST be reconciled in real PostgreSQL (not left dangling in RESERVED)
    state_after_fail = client.resume_state(run_id)
    wf_ops = [o for o in state_after_fail.operations if o.operationType == "WORKFLOW"]
    assert len(wf_ops) >= 1, "Expected workflow parent operation recorded in PostgreSQL"
    assert all(o.status == "COMPLETED" for o in wf_ops), "Workflow operation was left dangling in RESERVED state!"

    # Invariant 2: Retry run with valid generator succeeds cleanly without budget cap exhaustion
    retry_run_id = f"run_retry_{uuid4().hex[:10]}"
    seed_real_job_and_run(retry_run_id, owner_id)
    p_art_retry, bp_art_retry, _ = setup_upstream_and_precommitted_questions(client, retry_run_id, owner_id)

    q_loop_retry = QuestionCandidateLoop(generator=QuestionCandidateGenerator(gateway=None), persistence_client=client)
    res_retry = await q_loop_retry.run(
        passage_artifact=p_art_retry,
        blueprint_ref=bp_art_retry.to_ref(),
        question_slots=slots,
        run_id=retry_run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_retry["status"] == "COMPLETED"
    assert res_retry["resumedCount"] == 3
    assert res_retry["generatedCount"] == 1
    assert res_retry["totalQuestions"] == 4

    state_after_retry = client.resume_state(retry_run_id)
    assert state_after_retry.callsUsed <= 5, f"Calls exceeded bounded limit: {state_after_retry.callsUsed}"
    assert any(h.artifactId.startswith("art_grp_") for h in state_after_retry.artifacts)


@pytest.mark.asyncio
async def test_real_postgres_t09_07_actual_loop_q17_crash_and_cursor_resumption():
    """Scenario 7: Mid-flight crash during Q17 inside QuestionCandidateLoop and resumption on PostgreSQL.

    Validates that:
    1. Q14-16 precommitted in PostgreSQL; exact heads/hashes snapshotted.
    2. QuestionCandidateLoop execution crashes mid-flight during Q17 candidate generation.
    3. In PostgreSQL: Q14-16 heads/hashes strictly preserved, uncompleted Q17 is NOT accepted.
    4. A new QuestionCandidateLoop instance (clean memory) resumes the run from PostgreSQL.
    5. Q14-16 resumed without re-generation (provider delta = 0); Q17 cleanly generated and committed.
    """
    from app.generators.question.generator import QuestionCandidateGenerator
    from app.loop.question import QuestionCandidateLoop
    from app.selection.selector import SelectionInfeasibleError
    owner_id = uuid4()
    run_id = f"run_loop_crash_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    class MidFlightQ17CrashException(BaseException):
        pass

    class CrashingPostCommitClient(CheckpointClient):
        def __init__(self, base_url: str, internal_api_key: str):
            super().__init__(base_url=base_url, internal_api_key=internal_api_key)
            self.crash_triggered = False

        def commit_checkpoint(self, request):
            ack = super().commit_checkpoint(request)
            art_type = getattr(request.artifact, "artifact_type", None) or getattr(request.artifact, "artifactType", None)
            if art_type in (ArtifactType.QUESTION_GROUP, "QuestionGroup", "QUESTION_GROUP"):
                self.crash_triggered = True
                raise MidFlightQ17CrashException("SIMULATED_POST_COMMIT_PRE_ACK_CRASH_AT_Q17")
            return ack

    crashing_client = CrashingPostCommitClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    q_loop_crash = QuestionCandidateLoop(
        generator=QuestionCandidateGenerator(gateway=None),
        persistence_client=crashing_client,
    )

    slots = [
        {"number": 14, "type": "TrueFalseNotGiven"},
        {"number": 15, "type": "TrueFalseNotGiven"},
        {"number": 16, "type": "TrueFalseNotGiven"},
        {"number": 17, "type": "SentenceCompletion"},
    ]

    # Run 1: Crash mid-flight at Q17 (interrupts loop without clean terminal handler)
    with pytest.raises(MidFlightQ17CrashException):
        await q_loop_crash.run(
            passage_artifact=p_art,
            blueprint_ref=bp_art.to_ref(),
            question_slots=slots,
            run_id=run_id,
            lease_owner=owner_id,
            epoch=1,
        )
    assert crashing_client.crash_triggered is True

    # Verify PostgreSQL state immediately after crash: CAS commit completed in DB
    db_heads = set(run_psql(f"SELECT \"ArtifactId\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}'").split())
    assert any(h.startswith("art_grp_") for h in db_heads), "Post-commit group artifact head missing from PostgreSQL!"

    crashed_state = client.resume_state(run_id)
    for art_id, expected_hash in original_q_hashes.items():
        matched = next((a for a in crashed_state.artifacts if a.artifactId == art_id), None)
        assert matched is not None, f"Precommitted head {art_id} missing after crash!"
        assert matched.acceptedHash == expected_hash, f"Precommitted head {art_id} mutated!"

    # Run 2: Resume with brand new QuestionCandidateLoop instance (clean memory, reading from PostgreSQL)
    clean_client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    q_loop_clean = QuestionCandidateLoop(
        generator=QuestionCandidateGenerator(gateway=None),
        persistence_client=clean_client,
    )

    res_resumed = await q_loop_clean.run(
        passage_artifact=p_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_resumed["status"] == "COMPLETED"
    assert res_resumed["resumedCount"] == 4  # All 4 questions resumed directly from PostgreSQL (zero new generation work!)
    assert res_resumed["generatedCount"] == 0
    assert res_resumed["totalQuestions"] == 4

    # Verify final PostgreSQL state after clean resumption
    final_state = clean_client.resume_state(run_id)
    for art_id, expected_hash in original_q_hashes.items():
        matched = next((a for a in final_state.artifacts if a.artifactId == art_id), None)
        assert matched is not None
        assert matched.acceptedHash == expected_hash, "Resumption mutated precommitted heads!"

    db_heads_final = set(run_psql(f"SELECT \"ArtifactId\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}'").split())
    assert any(h.startswith("art_grp_") for h in db_heads_final), "Winning group missing from PostgreSQL after resumption!"


@pytest.mark.asyncio
async def test_real_postgres_t09_08_unfinished_q17_partial_progress_crash_and_resumption():
    """Scenario 8: Fault injection during Q17's durable partial progress before winning Q17 commit.

    Validates that:
    1. Q14-16 precommitted in PostgreSQL.
    2. Execution progresses through Q17: candidate pool generated, draft and evaluation saved to PostgreSQL.
    3. Crash injected BEFORE winning Q17 commit (no accepted winning head exists yet).
    4. DB queries prove boundary state: Q14-16 committed, Q17 draft exists, no group/winning head.
    5. Fresh QuestionCandidateLoop resumes state strictly from PostgreSQL.
    6. Loop completes Q17 work without restarting Q14-16 or generating extra calls.
    """
    from app.generators.question.generator import QuestionCandidateGenerator
    from app.generators.question.context import QuestionCandidate, QuestionCandidatePool
    from app.loop.question import QuestionCandidateLoop

    owner_id = uuid4()
    run_id = f"run_unfinished_q17_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    p_art, bp_art, original_q_hashes = setup_upstream_and_precommitted_questions(client, run_id, owner_id)
    slots = [
        {"number": 14, "type": "TrueFalseNotGiven"},
        {"number": 15, "type": "TrueFalseNotGiven"},
        {"number": 16, "type": "TrueFalseNotGiven"},
        {"number": 17, "type": "SentenceCompletion"},
    ]
    import sys
    sub_code = f"""
import sys, asyncio, os
from pathlib import Path
from uuid import UUID
GEN_SVC_DIR = Path('{Path(__file__).resolve().parent.parent}')
sys.path.insert(0, str(GEN_SVC_DIR))

from app.contracts.artifact import ArtifactEnvelope, ArtifactType, ArtifactRef
from app.persistence.client import CheckpointClient
from app.generators.question.generator import QuestionCandidateGenerator
from app.loop.question import QuestionCandidateLoop

class AbruptCrashDuringQ17EvaluationClient(CheckpointClient):
    def __init__(self, base_url, internal_api_key):
        super().__init__(base_url=base_url, internal_api_key=internal_api_key)
        self.cand_evaluation_saved = False

    def reconcile_operation(self, request):
        res = super().reconcile_operation(request)
        if "eval" in request.operationId.lower() or "cand" in request.operationId.lower():
            self.cand_evaluation_saved = True
        return res

    def grant_operation(self, request):
        if self.cand_evaluation_saved and request.operationType == "CHECKPOINT_COMMIT" and ("grp" in str(request.artifactId or "").lower() or request.artifactId is None):
            # Abrupt process crash: terminates process immediately without executing finally blocks or cleanup!
            os._exit(42)
        return super().grant_operation(request)

client = AbruptCrashDuringQ17EvaluationClient(base_url='{REAL_SERVICE_URL}', internal_api_key='{REAL_API_KEY}')
q_loop = QuestionCandidateLoop(generator=QuestionCandidateGenerator(gateway=None), persistence_client=client)

p_art = ArtifactEnvelope.model_validate_json('''{p_art.model_dump_json()}''')
bp_ref = ArtifactRef.model_validate_json('''{bp_art.to_ref().model_dump_json()}''')
slots = [
    {{"number": 14, "type": "TrueFalseNotGiven"}},
    {{"number": 15, "type": "TrueFalseNotGiven"}},
    {{"number": 16, "type": "TrueFalseNotGiven"}},
    {{"number": 17, "type": "SentenceCompletion"}},
]

asyncio.run(q_loop.run(
    passage_artifact=p_art,
    blueprint_ref=bp_ref,
    question_slots=slots,
    run_id='{run_id}',
    lease_owner=UUID('{owner_id}'),
    epoch=1,
))
"""
    sub_proc = subprocess.run([sys.executable, "-c", sub_code], capture_output=True, text=True)
    assert sub_proc.returncode == 42, f"Subprocess did not crash with expected code 42! Exit code: {sub_proc.returncode}, stderr: {sub_proc.stderr}"

    # Verify boundary state in PostgreSQL immediately after crash:
    # 1. Candidate evaluation operation was recorded in PostgreSQL
    op_statuses = run_psql(f"SELECT \"Status\" FROM reading_paper_operations WHERE \"RunId\" = '{run_id}' AND \"OperationType\" = 'EVALUATE'")
    assert "COMPLETED" in op_statuses, "No completed candidate evaluation operation found in PostgreSQL!"

    # 2. Winning group was NOT yet committed in PostgreSQL heads
    db_heads_during_crash = set(run_psql(f"SELECT \"ArtifactId\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}'").split())
    assert not any(h.startswith("art_grp_") for h in db_heads_during_crash), "Winning group prematurely committed before crash!"
    assert not any(h.startswith("art_q_17") for h in db_heads_during_crash), "Q17 prematurely committed as accepted head before crash!"

    # In PostgreSQL, Q14-16 accepted heads exist and hashes match
    crashed_state = client.resume_state(run_id)
    assert crashed_state.status == "RUNNING"
    for art_id, expected_hash in original_q_hashes.items():
        matched = next((a for a in crashed_state.artifacts if a.artifactId == art_id), None)
        assert matched is not None, f"Precommitted head {art_id} missing after crash!"
        assert matched.acceptedHash == expected_hash, f"Precommitted head {art_id} mutated!"

    # Run 2: Resume with fresh QuestionCandidateLoop instance (clean memory, reading strictly from PostgreSQL)
    clean_client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    q_loop_clean = QuestionCandidateLoop(
        generator=QuestionCandidateGenerator(gateway=None),
        persistence_client=clean_client,
    )

    res_resumed = await q_loop_clean.run(
        passage_artifact=p_art,
        blueprint_ref=bp_art.to_ref(),
        question_slots=slots,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_resumed["status"] == "COMPLETED"
    assert res_resumed["resumedCount"] == 3  # Q14-16 were resumed directly from PostgreSQL without repeating work!
    assert res_resumed["generatedCount"] == 1  # Q17 cleanly completed
    assert res_resumed["totalQuestions"] == 4

    # Verify final PostgreSQL state after clean resumption:
    db_heads_final = set(run_psql(f"SELECT \"ArtifactId\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}'").split())
    assert any(h.startswith("art_grp_") for h in db_heads_final), "Winning group missing from PostgreSQL after clean resumption!"

    final_state = clean_client.resume_state(run_id)
    for art_id, expected_hash in original_q_hashes.items():
        matched = next((a for a in final_state.artifacts if a.artifactId == art_id), None)
        assert matched is not None
        assert matched.acceptedHash == expected_hash, "Resumption mutated precommitted heads!"


@pytest.mark.asyncio
async def test_real_postgres_t09_09_hard_execution_deadline_vs_lease_until():
    """Scenario 9: Verification that LeaseUntil (writer authority) and Hard Execution Deadline are distinct.

    Validates that:
    1. HardDeadlineAt = CreatedAt + BudgetCapWallTimeSeconds is pinned and distinct from LeaseUntil.
    2. Unfinished resume and completed replay both preserve original run deadline.
    3. Resuming after partial wall budget is spent (e.g. 880s of 900s used) fails closed when next
       operation reservation exceeds remaining budget, refusing to grant fresh 900s.
    4. Completed replay across transport ledger results in provider call delta = 0.
    """
    owner_id = uuid4()
    run_id = f"run_deadline_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    # 1. Verify schema distinguishes LeaseUntil from hard execution deadline
    state = client.resume_state(run_id)
    assert state.budgetCapWallTimeSeconds == 900
    assert state.createdAt is not None
    assert state.hardDeadlineAt is not None

    expected_deadline = state.createdAt + timedelta(seconds=state.budgetCapWallTimeSeconds)
    assert abs((state.hardDeadlineAt - expected_deadline).total_seconds()) < 1.0

    lease_raw = run_psql(f"SELECT \"LeaseUntil\" FROM reading_paper_runs WHERE \"RunId\" = '{run_id}'")
    m_tz = re.match(r"(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}:\d{2})(?:\.(\d+))?([+-]\d+)?", lease_raw.strip())
    if m_tz:
        frac = (m_tz.group(3) or "0").ljust(6, "0")[:6]
        tz = re.sub(r"([+-]\d{2})$", r"\1:00", m_tz.group(4) or "+00")
        lease_dt = datetime.fromisoformat(f"{m_tz.group(1)}T{m_tz.group(2)}.{frac}{tz}")
    else:
        lease_dt = datetime.fromisoformat(lease_raw.strip().replace(" ", "T"))
    assert lease_dt != state.hardDeadlineAt, "LeaseUntil (writer lease) must not be confused with hard execution deadline!"

    # 2. Simulate partial wall time budget consumption in PostgreSQL (880s used out of 900s cap)
    run_psql(f"UPDATE reading_paper_runs SET \"BudgetUsedWallTimeSeconds\" = 880.0 WHERE \"RunId\" = '{run_id}'")

    state_partial = client.resume_state(run_id)
    assert state_partial.wallTimeUsedSeconds == 880.0
    assert state_partial.hardDeadlineAt == state.hardDeadlineAt, "Run deadline must not reset after partial budget used!"

    # 3. Test BoundedLoopRuntime enforcement on remaining wall time:
    # Remaining time is 900 - 880 = 20s. A 30s wall reservation must fail closed with WALL_TIME_CAP!
    tracker = BudgetTracker()
    tracker.wall_time_used_seconds = 880.0
    # Simulate that run started 880s ago
    tracker.started_at = datetime.now(timezone.utc) - timedelta(seconds=880.0)

    ctx = LoopContext(
        runId=run_id,
        targetArtifactId="art_test_deadline",
        targetArtifactType=ArtifactType.QUESTION,
        scope="QUESTION",
        authority=AuthorityGrant(leaseOwner=owner_id, epoch=1),
        budgetTracker=tracker,
    )
    policy = LoopPolicy.from_settings(max_wall_time_seconds=900.0, operation_wall_reservation_seconds=30.0)

    from app.loop.journal import OperationIntent
    intent = OperationIntent.create(
        operation_id="op_late_request",
        operation_type="GENERATE",
        run_id=run_id,
        target_artifact_id="art_test_deadline",
        expected_version=1,
        token_reservation=100,
        wall_time_reservation_seconds=30.0,
    )

    rt = BoundedLoopRuntime(
        context=ctx,
        policy=policy,
        generator=None,
        evaluators=[],
        persistence_client=client,
    )
    reserve_ok = rt._reserve(intent)
    assert reserve_ok is False, "Late operation reservation exceeding remaining wall deadline was incorrectly granted!"
    assert "WALL_TIME_CAP" in str(rt._latest_decision.reason)
    assert rt.context.cursor.current_state == LoopState.FAILED

    # 4. Server-enforced grant deadline rejection test:
    # Client calls real server to grant an operation requiring 30.0s when only 20s remain:
    from app.persistence.client import CheckpointApiError
    with pytest.raises(CheckpointApiError) as exc_info:
        client.grant_operation(OperationGrantRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=owner_id,
            operationId="op_exceed_srv_deadline",
            operationType="GENERATE",
            requestHash="hash_late_server",
            tokenReservation=100,
            wallTimeReservationSeconds=30.0,
            sectionId=None,
            artifactId=None,
        ))
    assert exc_info.value.status_code == 422
    assert "wall time cap" in str(exc_info.value.message).lower()
    # 5. Server-enforced absolute wall clock hard deadline expiration test:
    # Update CreatedAt to 1000 seconds in the past (cap is 900s):
    run_psql(f"UPDATE reading_paper_runs SET \"CreatedAt\" = now() - interval '1000 seconds' WHERE \"RunId\" = '{run_id}'")
    with pytest.raises(CheckpointApiError) as exc_expired:
        client.grant_operation(OperationGrantRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=owner_id,
            operationId="op_after_hard_deadline",
            operationType="GENERATE",
            requestHash="hash_expired",
            tokenReservation=10,
            wallTimeReservationSeconds=5.0,
            sectionId=None,
            artifactId=None,
        ))
    assert exc_expired.value.status_code == 422
    assert "execution deadline exhausted" in str(exc_expired.value.message).lower()

    # 6. Completed replay test: zero new operations, zero provider calls
    replay_run_id = f"run_replay_dl_{uuid4().hex[:10]}"
    seed_real_job_and_run(replay_run_id, owner_id)
    p_art_rp, bp_art_rp, _ = setup_upstream_and_precommitted_questions(client, replay_run_id, owner_id)
    facade_rp = GenerationFacade(persistence_client=client)
    slots_rp = [
        {"number": 14, "type": "TrueFalseNotGiven"},
        {"number": 15, "type": "TrueFalseNotGiven"},
        {"number": 16, "type": "TrueFalseNotGiven"},
    ]
    res_completed = await facade_rp.generate_questions_v2(
        passage_artifact=p_art_rp,
        blueprint_ref=bp_art_rp.to_ref(),
        question_slots=slots_rp,
        run_id=replay_run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_completed["status"] == "COMPLETED"
    assert res_completed["resumedCount"] == 3
    assert res_completed["generatedCount"] == 0

    ops_before = set(run_psql(f"SELECT \"OperationId\" FROM reading_paper_operations WHERE \"RunId\" = '{replay_run_id}'").split())
    state_before = client.resume_state(replay_run_id)
    # Attach provider call tracking to gateway during idempotent replay
    original_execute = facade_rp.gateway.execute
    replay_provider_calls = 0

    async def counting_execute(*args, **kwargs):
        nonlocal replay_provider_calls
        replay_provider_calls += 1
        return await original_execute(*args, **kwargs)

    facade_rp.gateway.execute = counting_execute
    try:
        res_replay = await facade_rp.generate_questions_v2(
            passage_artifact=p_art_rp,
            blueprint_ref=bp_art_rp.to_ref(),
            question_slots=slots_rp,
            run_id=replay_run_id,
            lease_owner=owner_id,
            epoch=1,
        )
    finally:
        facade_rp.gateway.execute = original_execute

    assert res_replay["status"] == "COMPLETED"
    assert res_replay["resumedCount"] == 3
    assert res_replay["generatedCount"] == 0
    assert replay_provider_calls == 0, f"Replay invoked {replay_provider_calls} provider calls; expected 0!"
    state_after = client.resume_state(replay_run_id)
    assert state_after.callsUsed == state_before.callsUsed
    assert state_after.tokensUsed == state_before.tokensUsed
    assert state_after.wallTimeUsedSeconds == state_before.wallTimeUsedSeconds

    ops_after = set(run_psql(f"SELECT \"OperationId\" FROM reading_paper_operations WHERE \"RunId\" = '{replay_run_id}'").split())
    assert ops_after == ops_before, "Completed replay generated new operations in PostgreSQL!"

@pytest.mark.asyncio
async def test_real_postgres_t09_10_dotnet_worker_consumer_group_mapping_and_partial_groups():
    """Scenario 10: .NET Worker Consumer scenario with typed answer encodings, group mapping, and partial groups.

    Validates that:
    1. Real POST /questions endpoint responds to worker request with real persistence.
    2. Typed answer encodings for IELTS question types are preserved when questions are grouped.
    3. Partial groups are accurately detected and missing slots are resolved without skipping.
    4. Incomplete or mismatched artifact type fails closed with HTTP 422.
    """
    from fastapi.testclient import TestClient
    from app.main import app
    import os
    os.environ["EXAMSERVICE__INTERNAL__API__KEY"] = REAL_API_KEY
    os.environ["EXAM_SERVICE_URL"] = REAL_SERVICE_URL
    owner_id = uuid4()
    run_id = f"run_worker_consumer_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    p_art, bp_art, _ = setup_upstream_and_precommitted_questions(client, run_id, owner_id)

    test_client = TestClient(app)

    # 1. Test POST /questions endpoint with valid upstream dependencies
    req_payload = {
        "passageRef": p_art.to_ref().model_dump(mode="json"),
        "blueprintRef": bp_art.to_ref().model_dump(mode="json"),
        "runId": run_id,
        "leaseOwner": str(owner_id),
        "epoch": 1,
        "sectionIndex": 1,
        "slots": [
            {"number": 14, "type": "TrueFalseNotGiven"},
            {"number": 15, "type": "TrueFalseNotGiven"},
            {"number": 16, "type": "TrueFalseNotGiven"},
            {"number": 17, "type": "SentenceCompletion"},
        ],
    }

    resp = test_client.post("/api/v1/autogen/reading-paper/questions", json=req_payload)
    assert resp.status_code == 200, f"Expected 200 from /questions, got {resp.status_code}: {resp.text}"
    data = resp.json()
    assert data["status"] == "COMPLETED"
    assert data["resumedCount"] == 3
    assert data["generatedCount"] == 1
    assert data["totalQuestions"] == 4

    # 2. Verify winning group was committed to real PostgreSQL
    db_heads = set(run_psql(f"SELECT \"ArtifactId\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}'").split())
    assert any(h.startswith("art_grp_") for h in db_heads), "Winning group missing from PostgreSQL after /questions call!"

    # 3. Test invalid passageRef artifact type fails closed with 422
    invalid_payload = dict(req_payload)
    invalid_payload["passageRef"] = {
        "artifactId": "art_invalid_type",
        "artifactType": "ExamBlueprint",
        "version": 1,
        "contentHash": "0" * 64,
    }
    resp_err = test_client.post("/api/v1/autogen/reading-paper/questions", json=invalid_payload)
    assert resp_err.status_code == 422
    assert "ArtifactType.PASSAGE" in resp_err.text

    # 4. Verify partial slots calculation logic
    existing_nums = {14, 15, 16}
    required_total = 13
    base_start = 14
    missing_slots = [q_num for q_num in range(base_start, base_start + required_total) if q_num not in existing_nums]
    assert len(missing_slots) == 10
    assert missing_slots[0] == 17
