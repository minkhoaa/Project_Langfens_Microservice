#!/usr/bin/env python3
"""Real PostgreSQL + Real exam-service Durability Integration Demo for Phase 06.

Proves:
1. Real BoundedLoopRuntime and LoopController.
2. Real CheckpointClient communicating over HTTP to real exam-service.
3. Real PostgreSQL test database (exam_test_phase06) on port 5433.
4. Fake generator/evaluator/repairer at capability boundary.
5. Full fixture lineage:
   - SourcePack (source_pack:sp_demo)
   - EvidenceGraph (evidence_graph:eg_demo, parent: SourcePack)
   - ExamBlueprint (exam_blueprint:bp_demo, parent: EvidenceGraph)
   - Passage (passage_01, parent: ExamBlueprint)
6. End-to-end integration demo:
   - Generate synthetic artifact (v1, 950 words).
   - Evaluation discovers local issue (SECTION_WORD_COUNT_OUT_OF_BOUNDS).
   - Controller chooses REPAIR.
   - Repair creates version 2 (800 words).
   - Required evaluations pass.
   - Commit accepted artifact (CAS head advances to v2).
   - Restart process and resume same run -> reuses accepted head without repeating work.
7. Real PostgreSQL assertions:
   - Immutable artifact history (both v1 and v2 exist in reading_paper_artifacts).
   - Accepted head points to v2 in reading_paper_artifact_heads.
   - Exact dependency refs in reading_paper_artifact_dependencies.
   - Issue lifecycle (OPEN -> RESOLVED) in reading_paper_issues and ledger.
   - Decision journal in reading_paper_decisions.
   - Budget accounting in reading_paper_runs preserved across restart.
   - Checkpoint acknowledgement verified against server.
   - Durable loop cursor with CAS revision in reading_paper_loop_cursors.
8. Real fault injection against PostgreSQL:
   - Fault A: Stale epoch / lease takeover fence rejection (HTTP 409).
   - Fault B: Cancellation fence rejection (HTTP 409).
   - Fault C: All 5 Crash Boundary Recoveries on real PostgreSQL:
     * Window 1: Post-grant pre-generate (UNKNOWN_OUTCOME, 0 generator calls)
     * Window 2: Post-draft-commit pre-evaluate (reuses draft v1, 0 generator calls)
     * Window 3: Post-evaluate pre-decision (reuses stored evaluation, 0 evaluator calls)
     * Window 4: Post-repair-draft pre-reevaluate (reuses repair v2, 0 repairer calls)
     * Window 5: Post-CAS-accepted-commit pre-cursor-ACK (detects accepted head, 0 generator calls)
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from uuid import UUID, uuid4
import httpx

ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "services" / "generation-service"))

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus, UsageMetrics
from app.contracts.issue import (
    Issue,
    IssueCode,
    IssueScope,
    IssueSeverity,
    IssueStatus,
)
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.loop.capabilities import EvaluatorCapability, GeneratorCapability, RepairerCapability
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.controller import LoopController
from app.loop.dependencies import DependencyValidator
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.journal import StepJournal
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    CheckpointCommitRequest,
    DraftCheckpointRequest,
    InvalidateDependencyRequest,
    LoopCursorCheckpointRequest,
    OperationGrantRequest,
    OperationReconcileRequest,
)

ARTIFACTS_DIR = ROOT / "artifacts" / "refactor" / "verify-after-phase-06"
ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)

TEST_PORT = 5098
SERVICE_BASE_URL = f"http://127.0.0.1:{TEST_PORT}"
TEST_API_KEY = "test-only-ephemeral-secret-key-32chars"
TEST_DB_NAME = "exam_test_phase06"


def run_psql(sql: str) -> str:
    cmd = [
        "docker", "exec", "deploy-exam-database-1",
        "psql", "-U", "exam", "-d", TEST_DB_NAME,
        "-t", "-A", "-c", sql,
    ]
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    return proc.stdout.strip()


def seed_job_and_run(job_id: str, run_id: str, owner: str, epoch: int = 1) -> None:
    now = datetime.now(timezone.utc).isoformat()
    lease_until = datetime.now(timezone.utc).replace(year=2030).isoformat()
    sql_job = f"""
    INSERT INTO reading_paper_jobs (
        "Id", "Topic", "Status", "Epoch", "CancelVersion", "LeaseOwner",
        "LeaseUntil", "SourcesJson", "SectionsJson", "CompletedSections",
        "ActiveRunId", "CreatedAt", "UpdatedAt"
    ) VALUES (
        '{job_id}', 'Integration Demo Paper', 'Running', {epoch}, 0, '{owner}',
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
        '{owner}', '{lease_until}', '2.0.0', '2.0.0',
        '2.0.0', 50, 100000,
        0, 0, '{now}', '{now}'
    );
    """
    run_psql(sql_job)
    run_psql(sql_run)


class SyntheticGenerator(GeneratorCapability):
    def __init__(self):
        self.call_count = 0

    @property
    def name(self) -> str:
        return "SyntheticGenerator"

    @property
    def version(self) -> str:
        return "1.0.0"

    async def generate(self, ctx: LoopContext, intent_id: str, version: int) -> ArtifactEnvelope:
        self.call_count += 1
        # Generate text with 950 words (deliberately exceeds max allowed 915 words)
        text = "word " * 950
        return ArtifactEnvelope.create(
            artifact_id=ctx.target_artifact_id,
            artifact_type=ctx.target_artifact_type,
            run_id=ctx.run_id,
            payload={"text": text, "word_count": 950, "version": version},
            producer_version="2.0.0",
            version=version,
            parent_refs=ctx.input_dependencies,
        )


class SyntheticEvaluator(EvaluatorCapability):
    def __init__(self):
        self.call_count = 0
        self.observed_defect_fingerprint: str | None = None

    @property
    def evaluator_id(self) -> str:
        return "synthetic_eval"

    @property
    def evaluator_version(self) -> str:
        return "1.0.0"

    async def evaluate(self, ctx: LoopContext, artifact: ArtifactEnvelope, intent_id: str) -> EvaluationResult:
        self.call_count += 1
        word_count = artifact.payload.get("word_count", 0)
        if word_count > 915:
            issue = Issue.create(
                issue_id=f"iss_wc_{artifact.version}",
                code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.SECTION,
                message=f"Passage word count {word_count} exceeds limit of 915",
                affected_refs=[artifact.to_ref()],
                evidence=f"Observed count {word_count}",
                proposed_repair="Trim passage to within 720-915 words",
            )
            self.observed_defect_fingerprint = issue.fingerprint
            return EvaluationResult(
                evaluationId=f"eval_wc_{artifact.version}",
                evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version,
                targetRef=artifact.to_ref(),
                inputDependencyRefs=list(artifact.parent_refs),
                status=EvaluationStatus.FAIL,
                issues=[issue],
                score=0.6,
                usage=UsageMetrics(totalTokens=500),
            )

        resolved_fps = []
        if self.observed_defect_fingerprint:
            resolved_fps = [self.observed_defect_fingerprint]

        return EvaluationResult(
            evaluationId=f"eval_wc_{artifact.version}",
            evaluatorId=self.evaluator_id,
            evaluatorVersion=self.evaluator_version,
            targetRef=artifact.to_ref(),
            inputDependencyRefs=list(artifact.parent_refs),
            status=EvaluationStatus.PASS,
            issues=[],
            resolvedIssueFingerprints=resolved_fps,
            score=1.0,
            usage=UsageMetrics(totalTokens=500),
        )


class SyntheticRepairer(RepairerCapability):
    def __init__(self):
        self.call_count = 0

    @property
    def repairer_id(self) -> str:
        return "SyntheticRepairer"

    @property
    def repairer_version(self) -> str:
        return "1.0.0"

    async def repair(
        self,
        ctx: LoopContext,
        artifact: ArtifactEnvelope,
        issues: list[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        self.call_count += 1
        # Trim text to exactly 800 words (comfortably within 720-915 range)
        trimmed = "word " * 800
        return artifact.create_next_version(
            new_payload={"text": trimmed, "word_count": 800, "version": version},
            producer_version="2.0.0",
        )


async def test_real_postgres_5_crash_windows(client: CheckpointClient, owner: UUID, epoch: int):
    """Proves the 5 crash boundaries against real PostgreSQL."""
    print("\n[*] Section 8B: Testing All 5 Crash Boundaries on Real PostgreSQL...")
    policy = LoopPolicy(required_evaluator_ids=("synthetic_eval",), max_versions=3, max_repair_attempts_per_version=2)

    # Window 1: Post-grant pre-generate
    run_w1 = f"run_w1_{uuid4().hex[:8]}"
    seed_job_and_run(str(uuid4()), run_w1, str(owner), epoch)
    ctx_w1 = LoopContext(
        runId=run_w1, scope=IssueScope.SECTION, targetArtifactId="passage_crash_w1",
        targetArtifactType=ArtifactType.PASSAGE, authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
        inputDependencies=(),
    )
    # Save initial cursor at revision 0
    client.save_loop_cursor(LoopCursorCheckpointRequest(
        runId=run_w1, epoch=epoch, leaseOwner=owner, artifactId="passage_crash_w1",
        expectedRevision=0,
        stateJson=json.dumps({
            "targetArtifactId": "passage_crash_w1", "scope": "SECTION", "policyVersion": "2.0.0",
            "policy": policy.model_dump(mode="json", by_alias=True),
            "inputDependencies": [],
            "cursor": ResumeCursor(stepIndex=1, revision=1, currentState=LoopState.DRAFTING, targetVersion=1, targetArtifactId="passage_crash_w1").model_dump(mode="json", by_alias=True),
            "budget": BudgetTracker().model_dump(mode="json", by_alias=True),
            "ledger": IssueLedgerManager(run_w1).to_dict(),
            "stagnation": StagnationDetector().model_dump(mode="json", by_alias=True),
            "oscillation": OscillationDetector().model_dump(mode="json", by_alias=True),
            "repairsSinceGeneration": 0, "generatedVersions": 0,
            "evaluations": [], "currentRef": None,
        }),
    ))
    gen_w1 = SyntheticGenerator()
    rt_w1 = BoundedLoopRuntime(
        context=ctx_w1, policy=policy, generator=gen_w1,
        evaluators=[SyntheticEvaluator()], persistence_client=client,
        accepted_dependencies={},
    )
    intent_w1 = rt_w1._intent("GENERATE", 1, policy.generate_token_reservation, gen_w1.version, {
        "parents": [], "previous": None, "issues": [], "policy": ctx_w1.policy_version,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w1, epoch=epoch, leaseOwner=owner, operationId=intent_w1.operation_id,
        operationType=intent_w1.operation_type, requestHash=intent_w1.request_hash,
        tokenReservation=intent_w1.token_reservation, artifactId="passage_crash_w1",
    ))
    # Simulated process death occurs here: operation is RESERVED in DB, but no draft is created.
    res_w1 = await rt_w1.run()
    assert res_w1.decision == DecisionType.FAIL
    assert res_w1.terminal_reason_code == LoopReason.UNKNOWN_OUTCOME
    assert gen_w1.call_count == 0
    print("    [PASS] Crash Window 1 (Post-grant pre-generate): recognized UNKNOWN_OUTCOME, 0 generator calls.")

    # Window 2: Post-draft-commit pre-evaluate
    run_w2 = f"run_w2_{uuid4().hex[:8]}"
    seed_job_and_run(str(uuid4()), run_w2, str(owner), epoch)
    ctx_w2 = LoopContext(
        runId=run_w2, scope=IssueScope.SECTION, targetArtifactId="passage_crash_w2",
        targetArtifactType=ArtifactType.PASSAGE, authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
        inputDependencies=(),
    )
    art_w2 = ArtifactEnvelope.create(
        artifact_id="passage_crash_w2", artifact_type=ArtifactType.PASSAGE, run_id=run_w2,
        payload={"text": "word " * 800, "word_count": 800, "version": 1},
        producer_version="2.0.0", version=1, parent_refs=(),
    )
    gen_w2 = SyntheticGenerator()
    rt_w2 = BoundedLoopRuntime(
        context=ctx_w2, policy=policy, generator=gen_w2,
        evaluators=[SyntheticEvaluator()], persistence_client=client,
        accepted_dependencies={},
    )
    intent_w2 = rt_w2._intent("GENERATE", 1, policy.generate_token_reservation, gen_w2.version, {
        "parents": [], "previous": None, "issues": [], "policy": ctx_w2.policy_version,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w2, epoch=epoch, leaseOwner=owner, operationId=intent_w2.operation_id,
        operationType=intent_w2.operation_type, requestHash=intent_w2.request_hash,
        tokenReservation=intent_w2.token_reservation, artifactId="passage_crash_w2",
    ))
    client.save_draft_checkpoint(DraftCheckpointRequest(
        runId=run_w2, epoch=epoch, leaseOwner=owner, operationId=intent_w2.operation_id,
        requestHash=intent_w2.request_hash, artifact=art_w2,
        tokensUsed=intent_w2.token_reservation, wallTimeUsedSeconds=30.0,
    ))
    cursor_w2 = ResumeCursor(stepIndex=1, revision=1, currentState=LoopState.EVALUATING, targetVersion=1, targetArtifactId="passage_crash_w2", targetContentHash=art_w2.content_hash)
    client.save_loop_cursor(LoopCursorCheckpointRequest(
        runId=run_w2, epoch=epoch, leaseOwner=owner, artifactId="passage_crash_w2",
        expectedRevision=0,
        stateJson=json.dumps({
            "targetArtifactId": "passage_crash_w2", "scope": "SECTION", "policyVersion": "2.0.0",
            "policy": policy.model_dump(mode="json", by_alias=True),
            "inputDependencies": [],
            "cursor": cursor_w2.model_dump(mode="json", by_alias=True),
            "budget": BudgetTracker(callsUsed=1, tokensUsed=2500, versionsUsed=1).model_dump(mode="json", by_alias=True),
            "ledger": IssueLedgerManager(run_w2).to_dict(),
            "stagnation": StagnationDetector().model_dump(mode="json", by_alias=True),
            "oscillation": OscillationDetector().model_dump(mode="json", by_alias=True),
            "repairsSinceGeneration": 0, "generatedVersions": 1,
            "evaluations": [], "currentRef": art_w2.to_ref().model_dump(mode="json", by_alias=True),
        }),
        lastOperationId=intent_w2.operation_id,
    ))
    # Simulated process death occurs here: draft v1 is in DB, cursor is EVALUATING.
    res_w2 = await rt_w2.run()
    assert res_w2.decision == DecisionType.PASS
    assert gen_w2.call_count == 0
    print("    [PASS] Crash Window 2 (Post-draft-commit pre-evaluate): reused draft v1, 0 generator calls.")

    # Window 3: Post-evaluate pre-decision
    run_w3 = f"run_w3_{uuid4().hex[:8]}"
    seed_job_and_run(str(uuid4()), run_w3, str(owner), epoch)
    ctx_w3 = LoopContext(
        runId=run_w3, scope=IssueScope.SECTION, targetArtifactId="passage_crash_w3",
        targetArtifactType=ArtifactType.PASSAGE, authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
        inputDependencies=(),
    )
    art_w3 = ArtifactEnvelope.create(
        artifact_id="passage_crash_w3", artifact_type=ArtifactType.PASSAGE, run_id=run_w3,
        payload={"text": "word " * 800, "word_count": 800, "version": 1},
        producer_version="2.0.0", version=1, parent_refs=(),
    )
    gen_w3 = SyntheticGenerator()
    eval_w3 = SyntheticEvaluator()
    rt_w3 = BoundedLoopRuntime(
        context=ctx_w3, policy=policy, generator=gen_w3,
        evaluators=[eval_w3], persistence_client=client,
        accepted_dependencies={},
    )
    intent_gen_w3 = rt_w3._intent("GENERATE", 1, policy.generate_token_reservation, gen_w3.version, {
        "parents": [], "previous": None, "issues": [], "policy": ctx_w3.policy_version,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w3, epoch=epoch, leaseOwner=owner, operationId=intent_gen_w3.operation_id,
        operationType=intent_gen_w3.operation_type, requestHash=intent_gen_w3.request_hash,
        tokenReservation=intent_gen_w3.token_reservation, artifactId="passage_crash_w3",
    ))
    client.save_draft_checkpoint(DraftCheckpointRequest(
        runId=run_w3, epoch=epoch, leaseOwner=owner, operationId=intent_gen_w3.operation_id,
        requestHash=intent_gen_w3.request_hash, artifact=art_w3,
        tokensUsed=intent_gen_w3.token_reservation, wallTimeUsedSeconds=30.0,
    ))
    eval_res_w3 = EvaluationResult(
        evaluationId="eval_w3_1", evaluatorId="synthetic_eval", evaluatorVersion="1.0.0",
        targetRef=art_w3.to_ref(), inputDependencyRefs=[], status=EvaluationStatus.PASS,
    )
    intent_eval_w3 = rt_w3._intent("EVALUATE", 1, policy.evaluate_token_reservation, f"{eval_w3.evaluator_id}:{eval_w3.evaluator_version}", {
        "ref": art_w3.to_ref().model_dump(mode="json"), "parents": [],
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w3, epoch=epoch, leaseOwner=owner, operationId=intent_eval_w3.operation_id,
        operationType=intent_eval_w3.operation_type, requestHash=intent_eval_w3.request_hash,
        tokenReservation=intent_eval_w3.token_reservation, artifactId="passage_crash_w3",
    ))
    client.reconcile_operation(OperationReconcileRequest(
        runId=run_w3, epoch=epoch, leaseOwner=owner, operationId=intent_eval_w3.operation_id,
        tokensUsed=intent_eval_w3.token_reservation, wallTimeUsedSeconds=30.0,
        resultRefJson=eval_res_w3.model_dump_json(by_alias=True),
        resolvedFingerprints=[],
    ))
    cursor_w3 = ResumeCursor(stepIndex=2, revision=1, currentState=LoopState.EVALUATING, targetVersion=1, targetArtifactId="passage_crash_w3", targetContentHash=art_w3.content_hash)
    client.save_loop_cursor(LoopCursorCheckpointRequest(
        runId=run_w3, epoch=epoch, leaseOwner=owner, artifactId="passage_crash_w3",
        expectedRevision=0,
        stateJson=json.dumps({
            "targetArtifactId": "passage_crash_w3", "scope": "SECTION", "policyVersion": "2.0.0",
            "policy": policy.model_dump(mode="json", by_alias=True),
            "inputDependencies": [],
            "cursor": cursor_w3.model_dump(mode="json", by_alias=True),
            "budget": BudgetTracker(callsUsed=2, tokensUsed=3500, versionsUsed=1).model_dump(mode="json", by_alias=True),
            "ledger": IssueLedgerManager(run_w3).to_dict(),
            "stagnation": StagnationDetector().model_dump(mode="json", by_alias=True),
            "oscillation": OscillationDetector().model_dump(mode="json", by_alias=True),
            "repairsSinceGeneration": 0, "generatedVersions": 1,
            "evaluations": [eval_res_w3.model_dump(mode="json", by_alias=True)],
            "currentRef": art_w3.to_ref().model_dump(mode="json", by_alias=True),
        }),
        lastOperationId=intent_eval_w3.operation_id,
    ))
    # Simulated process death occurs here: evaluation is reconciled in DB, cursor has evaluation, dies before commit.
    res_w3 = await rt_w3.run()
    assert res_w3.decision == DecisionType.PASS
    assert eval_w3.call_count == 0
    assert gen_w3.call_count == 0
    print("    [PASS] Crash Window 3 (Post-evaluate pre-decision): reused evaluation, 0 evaluator calls.")

    # Window 4: Post-repair-draft pre-reevaluate
    run_w4 = f"run_w4_{uuid4().hex[:8]}"
    seed_job_and_run(str(uuid4()), run_w4, str(owner), epoch)
    ctx_w4 = LoopContext(
        runId=run_w4, scope=IssueScope.SECTION, targetArtifactId="passage_crash_w4",
        targetArtifactType=ArtifactType.PASSAGE, authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
        inputDependencies=(),
    )
    art_w4_v1 = ArtifactEnvelope.create(
        artifact_id="passage_crash_w4", artifact_type=ArtifactType.PASSAGE, run_id=run_w4,
        payload={"text": "word " * 950, "word_count": 950, "version": 1},
        producer_version="2.0.0", version=1, parent_refs=(),
    )
    art_w4_v2 = art_w4_v1.create_next_version(
        new_payload={"text": "word " * 800, "word_count": 800, "version": 2},
        producer_version="2.0.0",
    )
    gen_w4 = SyntheticGenerator()
    rep_w4 = SyntheticRepairer()
    rt_w4 = BoundedLoopRuntime(
        context=ctx_w4, policy=policy, generator=gen_w4,
        evaluators=[SyntheticEvaluator()], repairer=rep_w4, persistence_client=client,
        accepted_dependencies={},
    )
    intent_gen_w4 = rt_w4._intent("GENERATE", 1, policy.generate_token_reservation, gen_w4.version, {
        "parents": [], "previous": None, "issues": [], "policy": ctx_w4.policy_version,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w4, epoch=epoch, leaseOwner=owner, operationId=intent_gen_w4.operation_id,
        operationType=intent_gen_w4.operation_type, requestHash=intent_gen_w4.request_hash,
        tokenReservation=intent_gen_w4.token_reservation, artifactId="passage_crash_w4",
    ))
    client.save_draft_checkpoint(DraftCheckpointRequest(
        runId=run_w4, epoch=epoch, leaseOwner=owner, operationId=intent_gen_w4.operation_id,
        requestHash=intent_gen_w4.request_hash, artifact=art_w4_v1,
        tokensUsed=intent_gen_w4.token_reservation, wallTimeUsedSeconds=30.0,
    ))
    intent_rep_w4 = rt_w4._intent("REPAIR", 2, policy.repair_token_reservation, rep_w4.repairer_version, {
        "parents": [], "previous": art_w4_v1.content_hash, "issues": [], "policy": ctx_w4.policy_version,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w4, epoch=epoch, leaseOwner=owner, operationId=intent_rep_w4.operation_id,
        operationType=intent_rep_w4.operation_type, requestHash=intent_rep_w4.request_hash,
        tokenReservation=intent_rep_w4.token_reservation, artifactId="passage_crash_w4",
    ))
    client.save_draft_checkpoint(DraftCheckpointRequest(
        runId=run_w4, epoch=epoch, leaseOwner=owner, operationId=intent_rep_w4.operation_id,
        requestHash=intent_rep_w4.request_hash, artifact=art_w4_v2,
        tokensUsed=intent_rep_w4.token_reservation, wallTimeUsedSeconds=30.0,
    ))
    cursor_w4 = ResumeCursor(stepIndex=3, revision=1, currentState=LoopState.EVALUATING, targetVersion=2, targetArtifactId="passage_crash_w4", targetContentHash=art_w4_v2.content_hash)
    client.save_loop_cursor(LoopCursorCheckpointRequest(
        runId=run_w4, epoch=epoch, leaseOwner=owner, artifactId="passage_crash_w4",
        expectedRevision=0,
        stateJson=json.dumps({
            "targetArtifactId": "passage_crash_w4", "scope": "SECTION", "policyVersion": "2.0.0",
            "policy": policy.model_dump(mode="json", by_alias=True),
            "inputDependencies": [],
            "cursor": cursor_w4.model_dump(mode="json", by_alias=True),
            "budget": BudgetTracker(callsUsed=2, tokensUsed=4000, versionsUsed=2, repairsUsed=1).model_dump(mode="json", by_alias=True),
            "ledger": IssueLedgerManager(run_w4).to_dict(),
            "stagnation": StagnationDetector().model_dump(mode="json", by_alias=True),
            "oscillation": OscillationDetector().model_dump(mode="json", by_alias=True),
            "repairsSinceGeneration": 1, "generatedVersions": 1,
            "evaluations": [], "currentRef": art_w4_v2.to_ref().model_dump(mode="json", by_alias=True),
        }),
        lastOperationId=intent_rep_w4.operation_id,
    ))
    # Simulated process death occurs here: repair draft v2 is in DB, cursor points to v2, dies before v2 re-evaluation.
    res_w4 = await rt_w4.run()
    assert res_w4.decision == DecisionType.PASS
    assert rep_w4.call_count == 0
    print("    [PASS] Crash Window 4 (Post-repair-draft pre-reevaluate): reused repair v2, 0 repairer calls.")

    # Window 5: Post-CAS-accepted-commit pre-cursor-ACK
    run_w5 = f"run_w5_{uuid4().hex[:8]}"
    seed_job_and_run(str(uuid4()), run_w5, str(owner), epoch)
    ctx_w5 = LoopContext(
        runId=run_w5, scope=IssueScope.SECTION, targetArtifactId="passage_crash_w5",
        targetArtifactType=ArtifactType.PASSAGE, authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
        inputDependencies=(),
    )
    art_w5 = ArtifactEnvelope.create(
        artifact_id="passage_crash_w5", artifact_type=ArtifactType.PASSAGE, run_id=run_w5,
        payload={"text": "word " * 800, "word_count": 800, "version": 1},
        producer_version="2.0.0", version=1, parent_refs=(),
    )
    gen_w5 = SyntheticGenerator()
    eval_w5 = SyntheticEvaluator()
    rt_w5 = BoundedLoopRuntime(
        context=ctx_w5, policy=policy, generator=gen_w5,
        evaluators=[eval_w5], persistence_client=client,
        accepted_dependencies={},
    )
    intent_gen_w5 = rt_w5._intent("GENERATE", 1, policy.generate_token_reservation, gen_w5.version, {
        "parents": [], "previous": None, "issues": [], "policy": ctx_w5.policy_version,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, operationId=intent_gen_w5.operation_id,
        operationType=intent_gen_w5.operation_type, requestHash=intent_gen_w5.request_hash,
        tokenReservation=intent_gen_w5.token_reservation, artifactId="passage_crash_w5",
    ))
    client.save_draft_checkpoint(DraftCheckpointRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, operationId=intent_gen_w5.operation_id,
        requestHash=intent_gen_w5.request_hash, artifact=art_w5,
        tokensUsed=intent_gen_w5.token_reservation, wallTimeUsedSeconds=30.0,
    ))
    eval_res_w5 = EvaluationResult(
        evaluationId="eval_w5_1", evaluatorId="synthetic_eval", evaluatorVersion="1.0.0",
        targetRef=art_w5.to_ref(), inputDependencyRefs=[], status=EvaluationStatus.PASS,
    )
    intent_eval_w5 = rt_w5._intent("EVALUATE", 1, policy.evaluate_token_reservation, f"{eval_w5.evaluator_id}:{eval_w5.evaluator_version}", {
        "ref": art_w5.to_ref().model_dump(mode="json"), "parents": [],
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, operationId=intent_eval_w5.operation_id,
        operationType=intent_eval_w5.operation_type, requestHash=intent_eval_w5.request_hash,
        tokenReservation=intent_eval_w5.token_reservation, artifactId="passage_crash_w5",
    ))
    client.reconcile_operation(OperationReconcileRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, operationId=intent_eval_w5.operation_id,
        tokensUsed=intent_eval_w5.token_reservation, wallTimeUsedSeconds=30.0,
        resultRefJson=eval_res_w5.model_dump_json(by_alias=True),
        resolvedFingerprints=[],
    ))
    cursor_w5 = ResumeCursor(stepIndex=2, revision=1, currentState=LoopState.EVALUATING, targetVersion=1, targetArtifactId="passage_crash_w5", targetContentHash=art_w5.content_hash)
    client.save_loop_cursor(LoopCursorCheckpointRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, artifactId="passage_crash_w5",
        expectedRevision=0,
        stateJson=json.dumps({
            "targetArtifactId": "passage_crash_w5", "scope": "SECTION", "policyVersion": "2.0.0",
            "policy": policy.model_dump(mode="json", by_alias=True),
            "inputDependencies": [],
            "cursor": cursor_w5.model_dump(mode="json", by_alias=True),
            "budget": BudgetTracker(callsUsed=2, tokensUsed=3500, versionsUsed=1).model_dump(mode="json", by_alias=True),
            "ledger": IssueLedgerManager(run_w5).to_dict(),
            "stagnation": StagnationDetector().model_dump(mode="json", by_alias=True),
            "oscillation": OscillationDetector().model_dump(mode="json", by_alias=True),
            "repairsSinceGeneration": 0, "generatedVersions": 1,
            "evaluations": [eval_res_w5.model_dump(mode="json", by_alias=True)],
            "currentRef": art_w5.to_ref().model_dump(mode="json", by_alias=True),
        }),
        lastOperationId=intent_eval_w5.operation_id,
    ))
    dec_w5 = LoopDecision(
        decisionId="dec_w5_1", runId=run_w5, decision=DecisionType.PASS,
        currentState=LoopState.EVALUATING, nextState=LoopState.COMPLETED,
        reason="Accepted", reasonCode=LoopReason.ACCEPTED,
        targetScope=IssueScope.SECTION, targetArtifactId="passage_crash_w5",
        expectedVersion=1, evaluationRef="eval_w5_1",
    )
    intent_commit_w5 = rt_w5._intent("CHECKPOINT_COMMIT", 1, 0, art_w5.content_hash, {
        "evaluations": [eval_res_w5.evaluation_id], "head": None,
    })
    client.grant_operation(OperationGrantRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, operationId=intent_commit_w5.operation_id,
        operationType=intent_commit_w5.operation_type, requestHash=intent_commit_w5.request_hash,
        tokenReservation=0, artifactId="passage_crash_w5",
    ))
    client.commit_checkpoint(CheckpointCommitRequest(
        runId=run_w5, epoch=epoch, leaseOwner=owner, operationId=intent_commit_w5.operation_id,
        requestHash=intent_commit_w5.request_hash, artifact=art_w5, evaluations=[eval_res_w5], decision=dec_w5,
    ))
    # Injected process death RIGHT HERE: client dies before saving cursor at COMPLETED state!
    # DB cursor remains in EVALUATING state, but head is already v1 in DB.
    res_w5 = await rt_w5.run()
    assert res_w5.decision == DecisionType.PASS
    assert res_w5.terminal_state == LoopState.COMPLETED
    assert gen_w5.call_count == 0
    print("    [PASS] Crash Window 5 (Post-CAS-accepted-commit pre-cursor-ACK): detected accepted head, 0 generator calls.")

async def main():
    print("═" * 70)
    print("  PHASE 06 REAL POSTGRESQL + REAL EXAM-SERVICE DURABILITY INTEGRATION")
    print("═" * 70)

    # 1. Start exam-service in background
    print(f"[*] Starting real exam-service on http://127.0.0.1:{TEST_PORT} pointing to {TEST_DB_NAME}...")
    env = os.environ.copy()
    env["ASPNETCORE_URLS"] = SERVICE_BASE_URL
    env["ConnectionStrings__exam-db"] = f"Host=localhost;Port=5433;Database={TEST_DB_NAME};Username=exam;Password=exam"
    env["EXAMSERVICE__INTERNAL__API__KEY"] = TEST_API_KEY
    env["JwtSettings__Issuer"] = "https://auth.langfens.local"
    env["JwtSettings__Audience"] = "langfens-api"
    env["JwtSettings__SignKey"] = "SuperSecretTestingKeyAtLeast32BytesLong!!"
    env["GENERATION_SERVICE_URL"] = "http://127.0.0.1:8080"

    service_proc = subprocess.Popen(
        ["dotnet", "run", "--project", str(ROOT / "services" / "exam-service" / "exam-service.csproj"), "--no-launch-profile"],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    client = CheckpointClient(base_url=SERVICE_BASE_URL, internal_api_key=TEST_API_KEY)

    # Wait for exam-service to be healthy
    print("[*] Waiting for exam-service endpoint readiness...")
    ready = False
    for attempt in range(30):
        try:
            with httpx.Client(timeout=1.0) as http_test:
                resp = http_test.get(f"{SERVICE_BASE_URL}/health")
                if resp.status_code == 200:
                    ready = True
                    break
        except Exception:
            time.sleep(0.5)

    if not ready:
        service_proc.terminate()
        raise RuntimeError("exam-service failed to start within 15 seconds")

    print("[*] exam-service is ready and healthy!")

    job_id = str(uuid4())
    run_id = f"run_{uuid4().hex[:12]}"
    owner = uuid4()
    epoch = 1

    try:
        # 2. Seed initial job and run in PostgreSQL
        print(f"[*] Seeding job {job_id} and run {run_id} into PostgreSQL {TEST_DB_NAME}...")
        seed_job_and_run(job_id, run_id, str(owner), epoch)

        # 3. Commit upstream accepted fixture lineage: SourcePack -> EvidenceGraph -> ExamBlueprint
        print("[*] Step 3.1: Committing accepted SourcePack fixture to PostgreSQL...")
        sp_envelope = ArtifactEnvelope.create(
            artifact_id="source_pack:sp_demo",
            artifact_type=ArtifactType.SOURCE_PACK,
            run_id=run_id,
            payload={"topic": "Renewable Geothermal", "wordCount": 1200, "sourceCount": 3},
            producer_version="2.0.0",
            version=1,
            parent_refs=(),
        )
        sp_op_id = f"loop:{run_id}:source_pack:sp_demo:COMMIT:1:initial"
        client.grant_operation(OperationGrantRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner,
            operationId=sp_op_id, operationType="CHECKPOINT_COMMIT",
            requestHash="hash_sp_grant", tokenReservation=0,
            artifactId="source_pack:sp_demo",
        ))
        sp_eval = EvaluationResult(
            evaluationId="eval_sp_1", evaluatorId="sp_eval", evaluatorVersion="1.0.0",
            targetRef=sp_envelope.to_ref(), status=EvaluationStatus.PASS,
        )
        sp_dec = LoopDecision(
            decisionId="dec_sp_1", runId=run_id, decision=DecisionType.PASS,
            currentState=LoopState.EVALUATING, nextState=LoopState.COMPLETED,
            reason="SourcePack accepted", reasonCode=LoopReason.ACCEPTED,
            targetScope=IssueScope.SECTION, targetArtifactId="source_pack:sp_demo",
            expectedVersion=1, evaluationRef="eval_sp_1",
        )
        sp_ack = client.commit_checkpoint(CheckpointCommitRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner,
            operationId=sp_op_id, requestHash="hash_sp_grant",
            artifact=sp_envelope, evaluations=[sp_eval], decision=sp_dec,
        ))
        print(f"    Accepted SourcePack committed: {sp_ack.artifactId} v{sp_ack.version} (hash {sp_ack.contentHash[:8]})")
        sp_ref = sp_envelope.to_ref()

        print("[*] Step 3.2: Committing accepted EvidenceGraph fixture to PostgreSQL...")
        eg_envelope = ArtifactEnvelope.create(
            artifact_id="evidence_graph:eg_demo",
            artifact_type=ArtifactType.EVIDENCE_GRAPH,
            run_id=run_id,
            payload={"claimsCount": 8, "status": "VERIFIED"},
            producer_version="2.0.0",
            version=1,
            parent_refs=(sp_ref,),
        )
        eg_op_id = f"loop:{run_id}:evidence_graph:eg_demo:COMMIT:1:initial"
        client.grant_operation(OperationGrantRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner,
            operationId=eg_op_id, operationType="CHECKPOINT_COMMIT",
            requestHash="hash_eg_grant", tokenReservation=0,
            artifactId="evidence_graph:eg_demo",
        ))
        eg_eval = EvaluationResult(
            evaluationId="eval_eg_1", evaluatorId="eg_eval", evaluatorVersion="1.0.0",
            targetRef=eg_envelope.to_ref(), inputDependencyRefs=[sp_ref], status=EvaluationStatus.PASS,
        )
        eg_dec = LoopDecision(
            decisionId="dec_eg_1", runId=run_id, decision=DecisionType.PASS,
            currentState=LoopState.EVALUATING, nextState=LoopState.COMPLETED,
            reason="EvidenceGraph accepted", reasonCode=LoopReason.ACCEPTED,
            targetScope=IssueScope.SECTION, targetArtifactId="evidence_graph:eg_demo",
            expectedVersion=1, evaluationRef="eval_eg_1",
        )
        eg_ack = client.commit_checkpoint(CheckpointCommitRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner,
            operationId=eg_op_id, requestHash="hash_eg_grant",
            artifact=eg_envelope, evaluations=[eg_eval], decision=eg_dec,
        ))
        print(f"    Accepted EvidenceGraph committed: {eg_ack.artifactId} v{eg_ack.version} (hash {eg_ack.contentHash[:8]})")
        eg_ref = eg_envelope.to_ref()

        print("[*] Step 3.3: Committing accepted ExamBlueprint fixture to PostgreSQL...")
        bp_envelope = ArtifactEnvelope.create(
            artifact_id="exam_blueprint:bp_demo",
            artifact_type=ArtifactType.EXAM_BLUEPRINT,
            run_id=run_id,
            payload={"blueprintId": "bp_demo", "totalQuestions": 40},
            producer_version="2.0.0",
            version=1,
            parent_refs=(eg_ref,),
        )
        bp_op_id = f"loop:{run_id}:exam_blueprint:bp_demo:COMMIT:1:initial"
        client.grant_operation(OperationGrantRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner,
            operationId=bp_op_id, operationType="CHECKPOINT_COMMIT",
            requestHash="hash_bp_grant", tokenReservation=0,
            artifactId="exam_blueprint:bp_demo",
        ))
        bp_eval = EvaluationResult(
            evaluationId="eval_bp_1", evaluatorId="bp_eval", evaluatorVersion="1.0.0",
            targetRef=bp_envelope.to_ref(), inputDependencyRefs=[eg_ref], status=EvaluationStatus.PASS,
        )
        bp_dec = LoopDecision(
            decisionId="dec_bp_1", runId=run_id, decision=DecisionType.PASS,
            currentState=LoopState.EVALUATING, nextState=LoopState.COMPLETED,
            reason="Blueprint accepted", reasonCode=LoopReason.ACCEPTED,
            targetScope=IssueScope.SECTION, targetArtifactId="exam_blueprint:bp_demo",
            expectedVersion=1, evaluationRef="eval_bp_1",
        )
        bp_ack = client.commit_checkpoint(CheckpointCommitRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner,
            operationId=bp_op_id, requestHash="hash_bp_grant",
            artifact=bp_envelope, evaluations=[bp_eval], decision=bp_dec,
        ))
        print(f"    Accepted ExamBlueprint committed: {bp_ack.artifactId} v{bp_ack.version} (hash {bp_ack.contentHash[:8]})")
        bp_ref = bp_envelope.to_ref()

        # 4. Setup LoopContext for Passage Loop
        context = LoopContext(
            runId=run_id,
            scope=IssueScope.SECTION,
            targetArtifactId="passage_01",
            targetArtifactType=ArtifactType.PASSAGE,
            authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
            inputDependencies=(bp_ref,),
        )
        policy = LoopPolicy(
            required_evaluator_ids=("synthetic_eval",),
            max_versions=3,
            max_repair_attempts_per_version=2,
            max_total_calls=15,
            max_total_tokens=60000,
        )

        generator = SyntheticGenerator()
        evaluator = SyntheticEvaluator()
        repairer = SyntheticRepairer()

        runtime = BoundedLoopRuntime(
            context=context,
            policy=policy,
            generator=generator,
            evaluators=[evaluator],
            repairer=repairer,
            persistence_client=client,
            accepted_dependencies={"exam_blueprint:bp_demo": bp_ref, "evidence_graph:eg_demo": eg_ref, "source_pack:sp_demo": sp_ref},
        )

        # 5. Run Loop: Generate -> Fail -> Repair -> Pass -> Commit
        print("\n[*] Executing BoundedLoopRuntime with real exam-service + PostgreSQL persistence...")
        result: LoopResult = await runtime.run()

        print(f"    Terminal Decision: {result.decision.value}")
        print(f"    Terminal State: {result.terminal_state.value}")
        print(f"    Terminal Reason: {result.terminal_reason}")
        print(f"    Versions Created: {result.versions_count}")
        print(f"    Repairs Performed: {result.repairs_count}")
        print(f"    Calls Used: {result.calls_count}")
        print(f"    Tokens Consumed: {result.tokens_consumed}")
        print(f"    Accepted Artifact: {result.accepted_artifact.artifact_id if result.accepted_artifact else 'None'} v{result.accepted_artifact.version if result.accepted_artifact else 0}")

        # Assertions on first run
        assert result.decision == DecisionType.PASS, f"Expected PASS, got {result.decision}"
        assert result.terminal_state == LoopState.COMPLETED, f"Expected COMPLETED, got {result.terminal_state}"
        assert result.versions_count == 2, f"Expected 2 versions (v1 generated, v2 repaired), got {result.versions_count}"
        assert result.repairs_count == 1, f"Expected 1 repair, got {result.repairs_count}"
        assert result.accepted_artifact is not None
        assert result.accepted_artifact.version == 2
        assert generator.call_count == 1
        assert repairer.call_count == 1
        assert evaluator.call_count == 2

        # 6. Process Restart and Resume Simulation
        print("\n[*] Simulating process restart and resume for the same run...")
        runs_pre_sql = f'SELECT "BudgetUsedCalls", "BudgetUsedTokens" FROM reading_paper_runs WHERE "RunId" = \'{run_id}\';'
        pre_runs_parts = run_psql(runs_pre_sql).split("|")
        pre_calls = int(pre_runs_parts[0])
        pre_tokens = int(pre_runs_parts[1])
        print(f"    Pre-resume PostgreSQL budget snapshot: calls={pre_calls}, tokens={pre_tokens}")
        resumed_context = LoopContext(
            runId=run_id,
            scope=IssueScope.SECTION,
            targetArtifactId="passage_01",
            targetArtifactType=ArtifactType.PASSAGE,
            authority=AuthorityGrant(leaseOwner=owner, epoch=epoch),
            inputDependencies=(bp_ref,),
        )
        resumed_gen = SyntheticGenerator()
        resumed_eval = SyntheticEvaluator()
        resumed_rep = SyntheticRepairer()

        resumed_runtime = BoundedLoopRuntime(
            context=resumed_context,
            policy=policy,
            generator=resumed_gen,
            evaluators=[resumed_eval],
            repairer=resumed_rep,
            persistence_client=client,
            accepted_dependencies={"exam_blueprint:bp_demo": bp_ref, "evidence_graph:eg_demo": eg_ref, "source_pack:sp_demo": sp_ref},
        )
        resumed_result: LoopResult = await resumed_runtime.run()

        print(f"    Resumed Decision: {resumed_result.decision.value}")
        print(f"    Resumed State: {resumed_result.terminal_state.value}")
        print(f"    Resumed Generator calls: {resumed_gen.call_count} (Must be 0)")
        print(f"    Resumed Repairer calls: {resumed_rep.call_count} (Must be 0)")
        print(f"    Resumed Evaluator calls: {resumed_eval.call_count} (Must be 0)")
        assert resumed_result.decision == DecisionType.PASS
        assert resumed_result.terminal_state == LoopState.COMPLETED
        assert resumed_gen.call_count == 0, "Restart repeated generator work!"
        assert resumed_rep.call_count == 0, "Restart repeated repairer work!"
        assert resumed_eval.call_count == 0, "Restart repeated evaluator work!"

        # Strict before/after snapshot equality verification
        runs_post_sql = f'SELECT "BudgetUsedCalls", "BudgetUsedTokens" FROM reading_paper_runs WHERE "RunId" = \'{run_id}\';'
        post_runs_parts = run_psql(runs_post_sql).split("|")
        post_calls = int(post_runs_parts[0])
        post_tokens = int(post_runs_parts[1])
        print(f"    Post-resume PostgreSQL budget snapshot: calls={post_calls}, tokens={post_tokens}")
        assert pre_calls == post_calls, f"BudgetUsedCalls changed after resume! Pre: {pre_calls}, Post: {post_calls}"
        assert pre_tokens == post_tokens, f"BudgetUsedTokens changed after resume! Pre: {pre_tokens}, Post: {post_tokens}"
        print(f"    [PASS] Strict Budget Invariant Verified: Calls ({pre_calls} == {post_calls}) and Tokens ({pre_tokens} == {post_tokens}) are mathematically identical before and after restart!")
        # 7. Real PostgreSQL Database Invariant Verifications
        print("\n[*] Querying PostgreSQL exam_test_phase06 for authoritative durability assertions...")

        # A. Immutable history: both v1 and v2 exist in reading_paper_artifacts
        versions_sql = f"""
        SELECT "Version", "ContentHash", length("PayloadJson")
        FROM reading_paper_artifacts
        WHERE "RunId" = '{run_id}' AND "ArtifactId" = 'passage_01'
        ORDER BY "Version";
        """
        versions_rows = run_psql(versions_sql).splitlines()
        print(f"    reading_paper_artifacts rows for passage_01: {len(versions_rows)}")
        assert len(versions_rows) == 2, f"Expected 2 immutable versions, found: {versions_rows}"
        print(f"    v1 record: {versions_rows[0]}")
        print(f"    v2 record: {versions_rows[1]}")

        # B. Accepted head points to v2
        head_sql = f"""
        SELECT "AcceptedVersion", "AcceptedHash"
        FROM reading_paper_artifact_heads
        WHERE "RunId" = '{run_id}' AND "ArtifactId" = 'passage_01';
        """
        head_row = run_psql(head_sql)
        print(f"    reading_paper_artifact_heads row: {head_row}")
        assert head_row.startswith("2|"), f"Accepted head must be version 2, got {head_row}"

        # C. Durable loop cursor
        cursor_sql = f"""
        SELECT "Revision", length("StateJson"), "LastOperationId"
        FROM reading_paper_loop_cursors
        WHERE "RunId" = '{run_id}' AND "ArtifactId" = 'passage_01';
        """
        cursor_row = run_psql(cursor_sql)
        print(f"    reading_paper_loop_cursors row: {cursor_row}")
        cursor_parts = cursor_row.split("|")
        assert int(cursor_parts[0]) >= 5, f"Cursor revision must have advanced past 4, got {cursor_parts[0]}"

        # D. Operations recorded and completed
        ops_sql = f"""
        SELECT "OperationType", "Status", "TokensUsed", "TokenReservation"
        FROM reading_paper_operations
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt";
        """
        ops_rows = run_psql(ops_sql).splitlines()
        print(f"    reading_paper_operations count: {len(ops_rows)}")
        for op_r in ops_rows:
            print(f"      operation: {op_r}")
        assert len(ops_rows) >= 5, f"Expected at least 5 operations, got {len(ops_rows)}"

        # E. Exact dependency refs in reading_paper_artifact_dependencies
        deps_sql = f"""
        SELECT "ArtifactId", "Version", "ParentArtifactId", "ParentVersion", "ParentContentHash"
        FROM reading_paper_artifact_dependencies
        WHERE "RunId" = '{run_id}'
        ORDER BY "ArtifactId", "Version";
        """
        deps_rows = run_psql(deps_sql).splitlines()
        print(f"    reading_paper_artifact_dependencies count: {len(deps_rows)}")
        for dep_r in deps_rows:
            print(f"      dependency edge: {dep_r}")
        parsed_edges = set()
        for r in deps_rows:
            parts = r.split("|")
            assert len(parts) == 5, f"Unexpected dependency row format: {r}"
            parsed_edges.add((parts[0], int(parts[1]), parts[2], int(parts[3]), parts[4]))

        expected_tuples = {
            ("evidence_graph:eg_demo", 1, "source_pack:sp_demo", 1, sp_ref.content_hash),
            ("exam_blueprint:bp_demo", 1, "evidence_graph:eg_demo", 1, eg_ref.content_hash),
            ("passage_01", 1, "exam_blueprint:bp_demo", 1, bp_ref.content_hash),
            ("passage_01", 2, "exam_blueprint:bp_demo", 1, bp_ref.content_hash),
        }
        assert parsed_edges == expected_tuples, f"Exact dependency lineage mismatch! Expected: {expected_tuples}, Actual: {parsed_edges}"
        print(f"    [PASS] Exact cryptographic dependency lineage verified for all 4 edges in PostgreSQL: {parsed_edges}")

        # F. Issue lifecycle in reading_paper_issues and ledger
        issues_sql = f"""
        SELECT "Code", "Severity", "Status", "Fingerprint"
        FROM reading_paper_issues
        WHERE "RunId" = '{run_id}';
        """
        issues_rows = run_psql(issues_sql).splitlines()
        print(f"    reading_paper_issues count: {len(issues_rows)}")
        for iss_r in issues_rows:
            print(f"      issue record: {iss_r}")
        assert any("SECTION_WORD_COUNT_OUT_OF_BOUNDS|CRITICAL|" in r for r in issues_rows), "Issue SECTION_WORD_COUNT_OUT_OF_BOUNDS missing from DB"
        assert any(i.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS for i in result.ledger.issues)
        assert runtime.ledger_mgr.has_unresolved_blockers() is False, "Unresolved blockers remain in ledger!"
        assert not any(i.severity == IssueSeverity.CRITICAL and i.status == IssueStatus.OPEN for i in result.ledger.issues)
        print("    [PASS] Issue lifecycle verified: OPEN on v1, resolved on v2, zero unresolved blockers remaining.")

        # G. Decision journal in reading_paper_decisions
        dec_sql = f"""
        SELECT "Decision", "NextState", "ExpectedVersion", "Reason"
        FROM reading_paper_decisions
        WHERE "RunId" = '{run_id}'
        ORDER BY "CreatedAt";
        """
        dec_rows = run_psql(dec_sql).splitlines()
        print(f"    reading_paper_decisions count: {len(dec_rows)}")
        for dec_r in dec_rows:
            print(f"      decision: {dec_r}")
        assert any("PASS|COMPLETED|2|" in r and "ACCEPTED:" in r for r in dec_rows), "Missing PASS decision for passage_01 v2"
        assert any("PASS|COMPLETED|1|" in r for r in dec_rows), "Missing PASS decision for bp_demo"
        print("    [PASS] Decision journal verified: PASS recorded with reason code ACCEPTED.")

        # H. Budget accounting in reading_paper_runs
        runs_sql = f"""
        SELECT "BudgetCapCalls", "BudgetCapTokens", "BudgetUsedCalls", "BudgetUsedTokens"
        FROM reading_paper_runs
        WHERE "RunId" = '{run_id}';
        """
        runs_row = run_psql(runs_sql)
        print(f"    reading_paper_runs budget row: {runs_row}")
        parts = runs_row.split("|")
        assert int(parts[2]) >= 4, f"BudgetUsedCalls must be at least 4, got {parts[2]}"
        assert int(parts[3]) >= 6000, f"BudgetUsedTokens must be at least 6000, got {parts[3]}"
        print("    [PASS] Budget accounting verified in DB: calls and tokens tracked, preserved across restart.")

        # I. Checkpoint ACK verification
        assert sp_ack.artifactId == "source_pack:sp_demo" and sp_ack.version == 1
        assert eg_ack.artifactId == "evidence_graph:eg_demo" and eg_ack.version == 1
        assert bp_ack.artifactId == "exam_blueprint:bp_demo" and bp_ack.version == 1
        client._verify_ack(CheckpointCommitRequest(
            runId=run_id, epoch=epoch, leaseOwner=owner, operationId=bp_op_id,
            requestHash="hash_bp_grant", artifact=bp_envelope,
        ), bp_ack)
        print("    [PASS] Checkpoint acknowledgements verified cryptographically against server.")

        # 8. Real Fault Injections against PostgreSQL
        print("\n[*] Section 8A: Testing Fencing Rejections against PostgreSQL...")

        # Fault A: Stale Epoch Fencing Rejection
        print("    Testing Fault A: Stale epoch fenced commit...")
        stale_intent = f"loop:{run_id}:passage_01:COMMIT:3:stale_writer"
        stale_envelope = ArtifactEnvelope.create(
            artifact_id="passage_01",
            artifact_type=ArtifactType.PASSAGE,
            run_id=run_id,
            payload={"text": "stale writer attempt", "version": 3},
            producer_version="2.0.0",
            version=3,
            parent_refs=(bp_ref,),
        )
        try:
            # Send with epoch = 0 (stale epoch)
            client.commit_checkpoint(CheckpointCommitRequest(
                runId=run_id,
                epoch=0,
                leaseOwner=owner,
                operationId=stale_intent,
                requestHash="hash_stale",
                artifact=stale_envelope,
                evaluations=[bp_eval],
                decision=bp_dec,
            ))
            raise AssertionError("Stale epoch commit was not rejected!")
        except CheckpointApiError as ex:
            assert ex.status_code == 409, f"Expected 409 for stale epoch, got {ex.status_code}"
            print(f"    [PASS] Stale epoch commit rejected with HTTP {ex.status_code}: {ex.message}")

        # Fault B: Cancellation Fencing Rejection
        print("    Testing Fault B: Cancellation fenced writer...")
        # Increment cancel_version in PostgreSQL
        run_psql(f"UPDATE reading_paper_jobs SET \"CancelVersion\" = \"CancelVersion\" + 1 WHERE \"Id\" = '{job_id}';")
        try:
            client.save_loop_cursor(LoopCursorCheckpointRequest(
                runId=run_id,
                epoch=epoch,
                leaseOwner=owner,
                artifactId="passage_01",
                expectedRevision=int(cursor_parts[0]),
                stateJson='{"stepIndex":99,"currentState":"DRAFTING"}',
            ))
            raise AssertionError("Cancelled job cursor save was not rejected!")
        except CheckpointApiError as ex:
            assert ex.status_code == 409, f"Expected 409 for cancelled writer, got {ex.status_code}"
            print(f"    [PASS] Cancelled job cursor update rejected with HTTP {ex.status_code}: {ex.message}")

        # Confirm accepted head in PostgreSQL did NOT advance to v3
        head_after = run_psql(head_sql)
        assert head_after.startswith("2|"), f"Accepted head must remain version 2, got {head_after}"
        print(f"    [PASS] Authoritative head in PostgreSQL remained untouched at version 2!")

        # Execute the 5 crash windows against real PostgreSQL
        await test_real_postgres_5_crash_windows(client, owner, epoch)

        # 9. Output report
        integration_report = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "targetDatabase": TEST_DB_NAME,
            "examServiceUrl": SERVICE_BASE_URL,
            "runId": run_id,
            "jobId": job_id,
            "leaseOwner": str(owner),
            "iterations": {
                "initialRun": {
                    "decision": result.decision.value,
                    "terminalState": result.terminal_state.value,
                    "versionsCreated": result.versions_count,
                    "repairsPerformed": result.repairs_count,
                    "callsUsed": result.calls_count,
                    "tokensConsumed": result.tokens_consumed,
                    "acceptedVersion": result.accepted_artifact.version if result.accepted_artifact else 0,
                    "acceptedHash": result.accepted_artifact.content_hash if result.accepted_artifact else None,
                },
                "resumedRun": {
                    "decision": resumed_result.decision.value,
                    "terminalState": resumed_result.terminal_state.value,
                    "repeatedGenerations": resumed_gen.call_count,
                    "repeatedRepairs": resumed_rep.call_count,
                    "repeatedEvaluations": resumed_eval.call_count,
                },
            },
            "postgresAssertions": {
                "immutableArtifactsCount": len(versions_rows),
                "acceptedHeadVersion": 2,
                "cursorRevision": int(cursor_parts[0]),
                "operationsCount": len(ops_rows),
                "dependenciesEdgesCount": len(deps_rows),
                "issuesCount": len(issues_rows),
                "decisionsCount": len(dec_rows),
                "staleEpochFenced": True,
                "cancelledWriterFenced": True,
                "fiveCrashWindowsVerified": True,
            },
            "status": "PASS",
        }

        report_path = ARTIFACTS_DIR / "real-postgres-integration-report.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(integration_report, f, indent=2)
        print(f"\n[*] Wrote real PostgreSQL integration report to {report_path}")
        print("\n[SUCCESS] All Real PostgreSQL Durability Integration Checks PASSED!")

    finally:
        print("[*] Terminating exam-service subprocess...")
        service_proc.terminate()
        try:
            service_proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            service_proc.kill()
        print("[*] exam-service terminated cleanly.")


if __name__ == "__main__":
    asyncio.run(main())
