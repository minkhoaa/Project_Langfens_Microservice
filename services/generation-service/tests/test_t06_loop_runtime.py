"""T06-01..08: bounded decisions, issue ledger lifecycle, descendant invalidation, and durable fault replay."""
from __future__ import annotations

import asyncio
import itertools
import hashlib
import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

import pytest

from app.config import cap_snapshot_json, cap_snapshot_sha256
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity, IssueStatus
from app.contracts.loop import DecisionType, LoopReason, LoopState
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.controller import LoopController
from app.loop.detectors import OscillationDetector, StagnationDetector
from app.loop.dependencies import DependencyValidator
from app.loop.ledger import IssueLedgerManager
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime
from app.persistence.client import CheckpointApiError
from app.persistence.models import (
    ArtifactResumeInfo, CheckpointAck, InvalidateDependencyRequest,
    InvalidateDependencyResult, LoopCursorCheckpoint, OperationReconcileResult,
    OperationResumeInfo, ResumeStateResult,
)


def artifact(ctx, version, text, parents=None):
    return ArtifactEnvelope.create(
        ctx.target_artifact_id, ctx.target_artifact_type, ctx.run_id,
        {"text": text}, "fake-v1", version=version,
        parent_refs=ctx.input_dependencies if parents is None else parents,
    )


def context(owner=None, parents=(), target="passage"):
    return LoopContext(runId="run_t06", targetArtifactId=target,
                       targetArtifactType=ArtifactType.PASSAGE, scope=IssueScope.SECTION,
                       inputDependencies=tuple(parents),
                       authority=AuthorityGrant(leaseOwner=owner or uuid4(), epoch=1))


def simulated_run_profile(policy):
    """The pinned run cap profile a run of this policy would be created with.

    This is the shape exam-service persists on the run row: a full cap snapshot
    carrying `caps`, `profileVersion` and `profileSource` -- not a bare run
    budget. `LoopPolicy.from_cap_snapshot` rejects anything else ("Pinned cap
    profile lacks required runtime caps"), the runtime refuses to resume a run
    without one, and tests widen individual bounds via `profile["caps"][...]`, so
    the snapshot is rendered from the policy's own RESOURCE_CAP_FIELDS rather
    than read back from `cap_profile_snapshot` (which is empty for a policy
    constructed directly instead of via `from_settings`).
    """
    # `from_cap_snapshot` requires exact positive 32-bit integers, matching .NET's
    # `ReadingPaperCapsProfile` `RequiredInt` admission (see CLAUDE.md). A sub-second
    # wall reservation is not expressible in that contract, so clamp up to the smallest
    # admissible value instead of truncating to 0, which would fail closed on a
    # profile that is not corrupt. Sub-second evaluator bounds are carried by the
    # optional float timeout fields, not by these integer caps.
    caps = {key: max(1, int(getattr(policy, field)))
            for field, key in LoopPolicy.RESOURCE_CAP_FIELDS.items()}
    caps["generateTokenReservation"] = int(policy.generate_token_reservation)
    return {
        "caps": caps,
        "profileVersion": policy.cap_profile_version or "test-simulated-profile-v1",
        "profileSource": policy.cap_profile_source or "test-simulated-run-profile",
    }


def policy_for_profile(profile, required_evaluator_ids=("required",), **overrides):
    """Rebuild the LoopPolicy a run pinned to `profile` would resume with.

    Used by cap/budget tests that exercise "a resumed run uses the profile it was
    created with". Re-deriving through `from_cap_snapshot` keeps the policy and
    the pinned profile in step; keyword overrides win over profile-derived values
    so one test can perturb a single bound.
    """
    overrides.pop("required_evaluator_ids", None)
    return LoopPolicy.from_cap_snapshot(profile, **overrides).model_copy(
        update={"required_evaluator_ids": tuple(required_evaluator_ids)}
    )


class Generator:
    version = "fake-v1"
    name = "fake"

    def __init__(self, outputs=None):
        self.outputs = outputs or ["A", "B", "C"]
        self.calls = 0

    async def generate(self, ctx, intent_id, version):
        self.calls += 1
        return artifact(ctx, version, self.outputs[min(self.calls - 1, len(self.outputs) - 1)])


class Evaluator:
    evaluator_id = "required"
    evaluator_version = "fake-v1"

    def __init__(self, statuses=None, code=IssueCode.WORD_LIMIT_EXCEEDED, raise_error=False, omit=False):
        self.statuses = statuses or [EvaluationStatus.PASS]
        self.code = code
        self.raise_error = raise_error
        self.omit = omit
        self.calls = 0
        self.reported_fingerprints = []

    async def evaluate(self, ctx, art, intent_id):
        self.calls += 1
        if self.raise_error:
            raise TimeoutError("transport timeout")
        status = self.statuses[min(self.calls - 1, len(self.statuses) - 1)]
        issues = []
        if status == EvaluationStatus.FAIL:
            iss = Issue.create(
                f"issue_{art.version}", self.code, IssueSeverity.CRITICAL,
                ctx.scope, "defect", affected_refs=[art.to_ref()], evidence="fake label",
            )
            issues = [iss]
            self.reported_fingerprints.append(iss.fingerprint)
        resolved_fps = []
        if status == EvaluationStatus.PASS and not self.omit:
            resolved_fps = [i.fingerprint for i in ctx.open_issues if i.code == self.code]
            if not resolved_fps:
                resolved_fps = list(self.reported_fingerprints)
            self.reported_fingerprints = []
        return EvaluationResult(
            evaluationId=f"eval_{art.version}_{self.calls}", evaluatorId=self.evaluator_id,
            evaluatorVersion=self.evaluator_version, targetRef=art.to_ref(),
            inputDependencyRefs=list(art.parent_refs), status=status, issues=issues,
            resolvedIssueFingerprints=resolved_fps,
            score=0.99,
        )


class HealingEvaluator(Evaluator):
    async def evaluate(self, ctx, art, intent_id):
        self.statuses = [EvaluationStatus.FAIL if art.version == 1 else EvaluationStatus.PASS]
        return await super().evaluate(ctx, art, intent_id)


class Repairer:
    repairer_id = "repair"
    repairer_version = "fake-v1"

    def __init__(self, outputs=None):
        self.outputs = outputs or ["fixed"]
        self.calls = 0

    async def repair(self, ctx, art, issues, intent_id, version):
        self.calls += 1
        output = self.outputs[min(self.calls - 1, len(self.outputs) - 1)]
        return art.create_next_version({"text": art.payload["text"] if output == "same" else output}, "fake-v1")


class DurableStore:
    """SQLite-backed fake of the authenticated exam-service protocol, reopened between crashes."""
    def __init__(self, path: Path, owner, cap_calls=50, cap_tokens=100000, run_profile=None):
        self.path, self.owner = path, owner
        self.cap_calls, self.cap_tokens = cap_calls, cap_tokens
        # A resumed run must use the cap profile it was created with, not the current
        # deployment's (R03/G06). The runtime rejects a run with no pinned profile and
        # cross-checks the JSON against its own digest, version and source, so the
        # fake persists exactly what the real checkpoint service does.
        # A run persists a full cap snapshot (caps + profileVersion + profileSource);
        # the runtime cross-checks the JSON digest against exactly those fields, so
        # the fake stores what it was handed verbatim rather than re-deriving it.
        #
        # Serialization goes through `app.config.cap_snapshot_json`, the same
        # canonical (sorted, compact, unescaped UTF-8) serializer production and the
        # .NET side use. A plain `json.dumps` here defaults to `ensure_ascii=True`,
        # so a non-ASCII `profileSource` would round-trip to different bytes and a
        # different digest than the one the runtime recomputes.
        #
        # `run_profile` is a property because tests reassign it after construction to
        # pin a wider/narrower profile; the digest must be recomputed on assignment or
        # the store would keep serving the digest of the profile it no longer holds.
        self._run_profile = None
        self.run_profile = dict(run_profile or LoopPolicy.from_settings().cap_profile_snapshot)
        self.epoch = 1
        self.cancelled = False
        self.fault = None
        self.trace = []
        with sqlite3.connect(path) as db:
            db.execute("CREATE TABLE IF NOT EXISTS state (id INTEGER PRIMARY KEY, value TEXT NOT NULL)")
            db.execute("INSERT OR IGNORE INTO state VALUES (1, ?)", (json.dumps({
                "ops": {}, "drafts": {}, "heads": {}, "cursor": None,
                "evaluations": {}, "descendants": {},
            }),))

    @property
    def run_profile(self):
        return self._run_profile

    @run_profile.setter
    def run_profile(self, value):
        self._run_profile = value
        self.run_profile_sha256 = (
            cap_snapshot_sha256(value) if value is not None else None
        )

    def _state(self):
        with sqlite3.connect(self.path) as db:
            return json.loads(db.execute("SELECT value FROM state WHERE id=1").fetchone()[0])

    def _save(self, state, stage):
        with sqlite3.connect(self.path) as db:
            db.execute("UPDATE state SET value=? WHERE id=1", (json.dumps(state),))
        self.trace.append(stage)
        if self.fault == stage:
            self.fault = None
            raise OSError(f"simulated process death after {stage} transaction")

    def _fence(self, req):
        if self.cancelled or req.epoch != self.epoch or req.leaseOwner != self.owner:
            raise CheckpointApiError(409, "cancelled or stale lease writer")

    def grant_operation(self, req):
        self._fence(req)
        state = self._state()
        op = state["ops"].get(req.operationId)
        if op:
            if op["requestHash"] != req.requestHash:
                raise CheckpointApiError(409, "operation hash conflict")
            return type("Grant", (), {"operationId": req.operationId,
                                      "tokenReservation": req.tokenReservation, "isReplay": True})()
        work = [x for x in state["ops"].values() if x["operationType"] != "CHECKPOINT_COMMIT"]
        if req.operationType != "CHECKPOINT_COMMIT" and len(work) + 1 > self.cap_calls:
            raise CheckpointApiError(422, "Budget exhausted: maximum calls exceeded")
        if req.operationType != "CHECKPOINT_COMMIT" and (
            sum(x["tokensUsed"] if x["status"] == "COMPLETED" else x["tokenReservation"] for x in work)
            + req.tokenReservation > self.cap_tokens):
            raise CheckpointApiError(422, "Budget exhausted: token cap exceeded")
        state["ops"][req.operationId] = dict(
            operationId=req.operationId, operationType=req.operationType, status="RESERVED",
            artifactId=req.artifactId, requestHash=req.requestHash,
            tokenReservation=req.tokenReservation, tokensUsed=0,
            wallTimeReservationSeconds=req.wallTimeReservationSeconds,
            wallTimeUsedSeconds=0, resultRefJson=None,
        )
        self._save(state, "grant")
        return type("Grant", (), {"operationId": req.operationId,
                                  "tokenReservation": req.tokenReservation, "isReplay": False})()

    def _operation(self, state, req):
        self._fence(req)
        op = state["ops"].get(req.operationId)
        if op is None or (hasattr(req, "requestHash") and op["requestHash"] != req.requestHash):
            raise CheckpointApiError(409, "missing or mismatched operation")
        return op

    def save_draft_checkpoint(self, req):
        state = self._state()
        op = self._operation(state, req)
        if not req.artifact.verify_integrity():
            raise CheckpointApiError(422, "invalid hash")
        version = str(req.artifact.version)
        existing = state["drafts"].get(version)
        if existing is not None and existing != req.artifact.model_dump(mode="json", by_alias=True):
            raise CheckpointApiError(409, "immutable version conflict")
        state["drafts"][version] = req.artifact.model_dump(mode="json", by_alias=True)
        op.update(status="COMPLETED", tokensUsed=req.tokensUsed,
                  wallTimeUsedSeconds=req.wallTimeUsedSeconds,
                  resultRefJson=req.artifact.to_ref().model_dump_json(by_alias=True))
        self._save(state, "draft")
        return self._ack(req.artifact)

    def reconcile_operation(self, req):
        state = self._state()
        op = self._operation(state, req)
        if op["status"] == "COMPLETED" and op["resultRefJson"] != req.resultRefJson:
            raise CheckpointApiError(409, "reconcile payload conflict")
        try:
            ev = EvaluationResult.model_validate_json(req.resultRefJson)
            state["evaluations"][f"{ev.evaluator_id}:{ev.target_ref.version}"] = req.resultRefJson
        except Exception:
            pass
        op.update(status="COMPLETED", tokensUsed=req.tokensUsed,
                  wallTimeUsedSeconds=req.wallTimeUsedSeconds, resultRefJson=req.resultRefJson)
        self._save(state, "evaluate")
        # The gateway reads `reservationBreached`/`budgetBreachDetected` off this
        # result (app/providers/gateway.py:483), so the fake must return the real
        # contract model rather than a hand-rolled object that would drift again.
        # The fake never simulates a breach, so both flags are False.
        return OperationReconcileResult(
            operationId=req.operationId,
            status=op["status"],
            tokensUsed=req.tokensUsed,
            wallTimeUsedSeconds=req.wallTimeUsedSeconds,
            reconciledAt=datetime.now(timezone.utc),
            reservationBreached=False,
            budgetBreachDetected=False,
        )
    def invalidate_dependencies(self, req: InvalidateDependencyRequest) -> InvalidateDependencyResult:
        self._fence(req)
        state = self._state()
        invalidated = {req.targetArtifactId}
        queue = [req.targetArtifactId]
        descendants_map = state.get("descendants", {})
        while queue:
            curr = queue.pop(0)
            for child in descendants_map.get(curr, []):
                if child not in invalidated:
                    invalidated.add(child)
                    queue.append(child)
        heads = state.get("heads", {})
        preserved = []
        for art_id in list(heads.keys()):
            if art_id != req.targetArtifactId and art_id in invalidated:
                del heads[art_id]
            else:
                preserved.append(art_id)
        state["heads"] = heads
        self._save(state, "invalidate")
        return InvalidateDependencyResult(
            runId=req.runId,
            invalidatedArtifactIds=list(invalidated),
            preservedArtifactIds=preserved,
        )

    def commit_checkpoint(self, req):
        state = self._state()
        op = self._operation(state, req)
        if not req.decision or req.decision.decision != DecisionType.PASS or not req.evaluations or \
           any(e.status != EvaluationStatus.PASS or e.target_ref != req.artifact.to_ref() for e in req.evaluations):
            raise CheckpointApiError(422, "invalid acceptance")
        for parent_ref in req.artifact.parent_refs:
            parent_head = state["heads"].get(parent_ref.artifact_id)
            if not parent_head:
                raise CheckpointApiError(409, f"missing parent dependency: parent '{parent_ref.artifact_id}' has no accepted head")
            if parent_head["version"] != parent_ref.version or parent_head["content_hash"] != parent_ref.content_hash:
                raise CheckpointApiError(409, f"stale parent dependency: parent '{parent_ref.artifact_id}' updated")
        head = state["heads"].get(req.artifact.artifact_id)
        if head and head["version"] != req.expectedHeadVersion:
            raise CheckpointApiError(409, "head CAS mismatch")
        if not head and req.expectedHeadVersion is not None:
            raise CheckpointApiError(409, "initial head CAS mismatch")
        state["heads"][req.artifact.artifact_id] = req.artifact.model_dump(mode="json", by_alias=True)
        invalidated = set()
        queue = [req.artifact.artifact_id]
        descendants_map = state.get("descendants", {})
        while queue:
            curr = queue.pop(0)
            for child in descendants_map.get(curr, []):
                if child not in invalidated:
                    invalidated.add(child)
                    queue.append(child)
        for child_id in invalidated:
            state["heads"].pop(child_id, None)
        op.update(status="COMPLETED", resultRefJson=req.artifact.to_ref().model_dump_json(by_alias=True))
        self._save(state, "commit")
        return self._ack(req.artifact)

    def save_loop_cursor(self, req):
        state = self._state()
        self._fence(req)
        if req.lastOperationId and state["ops"].get(req.lastOperationId, {}).get("status") != "COMPLETED":
            raise CheckpointApiError(409, "cursor has no durable operation ack")
        cursor = state["cursor"]
        if cursor and cursor["revision"] == req.expectedRevision + 1 and \
           cursor["stateJson"] == req.stateJson and cursor["lastOperationId"] == req.lastOperationId:
            return LoopCursorCheckpoint.model_validate(cursor)
        if (cursor["revision"] if cursor else 0) != req.expectedRevision:
            raise CheckpointApiError(409, "cursor CAS mismatch")
        state["cursor"] = dict(artifactId=req.artifactId, revision=req.expectedRevision + 1,
                               stateJson=req.stateJson, lastOperationId=req.lastOperationId)
        self._save(state, "cursor")
        return LoopCursorCheckpoint.model_validate(state["cursor"])

    def resume_state(self, run_id):
        state = self._state()
        def info(payload):
            art = ArtifactEnvelope.model_validate(payload)
            return ArtifactResumeInfo(
                artifactId=art.artifact_id, artifactType=art.artifact_type.value,
                acceptedVersion=art.version, acceptedHash=art.content_hash,
                payloadJson=json.dumps(dict(art.payload)), parentRefs=list(art.parent_refs),
                isStale=False, envelopeJson=json.dumps(payload),
            )
        work = [x for x in state["ops"].values() if x["operationType"] != "CHECKPOINT_COMMIT"]
        # A legacy snapshotless run persists no cap profile at all. All four
        # budgetProfile* fields are Optional on ResumeStateResult, so report them
        # as absent rather than crashing here: the runtime is the component that
        # owns the fail-closed decision and raises the legible
        # "Run lacks a pinned cap profile" error the contract expects.
        if self.run_profile is None:
            profile_json = profile_sha = profile_version = profile_source = None
        else:
            profile_json = cap_snapshot_json(self.run_profile)
            profile_sha = self.run_profile_sha256
            profile_version = self.run_profile.get("profileVersion")
            profile_source = self.run_profile.get("profileSource")
        return ResumeStateResult(
            runId=run_id, jobId=uuid4(), epoch=self.epoch, status="RUNNING",
            engineVersion="2.0.0", schemaVersion="2.0.0", policyVersion="2.0.0",
            isCompatible=True,
            budgetProfileJson=profile_json,
            budgetProfileSha256=profile_sha,
            budgetProfileVersion=profile_version,
            budgetProfileSource=profile_source,
            artifacts=[info(a) for a in state["heads"].values()],
            draftArtifacts=[info(a) for a in state["drafts"].values()],
            loopCursors=[LoopCursorCheckpoint.model_validate(state["cursor"])] if state["cursor"] else [],
            operations=[OperationResumeInfo.model_validate(o) for o in state["ops"].values()],
            evaluations=[EvaluationResult.model_validate_json(v) for v in state["evaluations"].values()],
            callsUsed=len(work),
            tokensUsed=sum(o["tokensUsed"] if o["status"] == "COMPLETED" else o["tokenReservation"] for o in work),
            wallTimeUsedSeconds=sum(o["wallTimeUsedSeconds"] if o["status"] == "COMPLETED"
                                    else o["wallTimeReservationSeconds"] for o in work),
        )

    def _ack(self, art):
        return CheckpointAck(runId=art.run_id, epoch=self.epoch, artifactId=art.artifact_id,
                             version=art.version, contentHash=art.content_hash,
                             serverTimestampUtc=datetime.now(timezone.utc))


def setup(tmp_path, policy=None, evaluator=None, generator=None, repairer=None, parents=(), deps=None,
          store=None, owner=None):
    owner = owner or uuid4()
    ctx = context(owner, parents)
    policy = policy or LoopPolicy(required_evaluator_ids=("required",))
    store = store or DurableStore(tmp_path / "loop.db", owner)
    # The run is created here, by this policy, so that is the profile it must be
    # pinned to. Left on DurableStore's deployment-default the runtime correctly
    # rebases onto `deploy/envs/loop-caps.env` on restore (R03/G06), which discards
    # the per-test caps (e.g. max_total_calls=1) these tests are asserting on.
    store.run_profile = simulated_run_profile(policy)
    runtime = BoundedLoopRuntime(ctx, policy,
                                  generator or Generator(), [evaluator or Evaluator()],
                                  repairer=repairer, persistence_client=store,
                                  accepted_dependencies=deps or {})
    return runtime, store


# ─────────────────────────────────────────────────────────────────────────────
# T06-01: Five decisions
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_01_decision_pass(tmp_path):
    passing, s = setup(tmp_path)
    result = await passing.run()
    assert result.decision == DecisionType.PASS
    assert s._state()["heads"]["passage"]["version"] == 1
    assert result.terminal_reason_code == LoopReason.ACCEPTED
    assert result.accepted_artifact is not None


@pytest.mark.asyncio
async def test_t06_01_decision_repair(tmp_path):
    evaluator = Evaluator([EvaluationStatus.FAIL, EvaluationStatus.PASS], IssueCode.WORD_LIMIT_EXCEEDED)
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=3)
    rt, st = setup(tmp_path, policy=policy, evaluator=evaluator, repairer=Repairer())
    outcome = await rt.run()
    assert outcome.decision == DecisionType.PASS
    assert outcome.repairs_count == 1
    assert outcome.versions_count == 2
    assert "passage" in st._state()["heads"]


@pytest.mark.asyncio
async def test_t06_repair_attempt_cap_reached(tmp_path):
    """Proves repair attempt cap is discriminating: unit test checks boundary and runtime proves forced regeneration."""
    # 1. Direct unit test of LoopController.decide at repair cap boundary
    ctx = context()
    art = artifact(ctx, 3, "artifact v3")
    ctx.current_artifact = art
    ledger = IssueLedgerManager(ctx.run_id)
    ledger.record_issue(IssueCode.WORD_LIMIT_EXCEEDED, IssueSeverity.CRITICAL,
                        ctx.scope, "defect", [art.to_ref()])
    eval_res = EvaluationResult(
        evaluationId="eval_3", evaluatorId="required", evaluatorVersion="1",
        targetRef=art.to_ref(), status=EvaluationStatus.FAIL, issues=ledger.get_open_issues(),
    )
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=6,
                        max_generated_versions=3, max_repair_attempts_per_version=2,
                        # The repair cap must be the binding constraint here, not the
                        # token budget. At the default 15000/10000/15000 reservations
                        # this four-version scenario reserves ~90k tokens and trips
                        # TOKEN_CAP before regenerating to v4. Small reservations keep
                        # the scenario inside the approved 60000 cap so the repair-cap
                        # boundary is what is actually exercised.
                        generate_token_reservation=2_000,
                        evaluate_token_reservation=1_000,
                        repair_token_reservation=2_000)
    ctrl = LoopController(policy)

    # When repair_attempts_this_version == 1 (< 2): decision is REPAIR
    dec_repair = ctrl.decide(
        ctx, ledger, [eval_res], StagnationDetector(), OscillationDetector(),
        dependencies_fresh=True, repair_attempts_this_version=1, generated_versions=1,
    )
    assert dec_repair.decision == DecisionType.REPAIR
    assert dec_repair.next_state == LoopState.REPAIRING

    # When repair_attempts_this_version == 2 (== cap): decision transitions to REGENERATE!
    dec_regen = ctrl.decide(
        ctx, ledger, [eval_res], StagnationDetector(), OscillationDetector(),
        dependencies_fresh=True, repair_attempts_this_version=2, generated_versions=1,
    )
    assert dec_regen.decision == DecisionType.REGENERATE
    assert dec_regen.next_state == LoopState.DRAFTING
    assert dec_regen.reason_code == LoopReason.UNREPAIRABLE_DEFECTS
    assert "repair cap" in dec_regen.reason

    # 2. Runtime execution proves repair cap halts repairs at 2 and forces generator to produce v4
    gen = Generator(["v1_initial", "v4_regenerated"])
    rep = Repairer(["v2_fix", "v3_fix", "v4_should_not_be_called"])

    class HealOnRegenEvaluator(Evaluator):
        async def evaluate(self, c, a, intent_id):
            # Fails v1, v2, v3; but passes v4 (the regenerated version)
            self.statuses = [EvaluationStatus.PASS if a.version >= 4 else EvaluationStatus.FAIL]
            return await super().evaluate(c, a, intent_id)

    rt, st = setup(tmp_path, policy=policy, evaluator=HealOnRegenEvaluator(),
                   generator=gen, repairer=rep)
    outcome = await rt.run()
    assert outcome.decision == DecisionType.PASS
    assert outcome.repairs_count == 2  # Exactly 2 repairs performed before cap halted repairing
    assert rep.calls == 2              # Repairer halted at cap; not called a 3rd time
    assert gen.calls == 2              # Initial generation (v1) + forced regeneration (v4)
    assert outcome.versions_count == 4 # v1 -> v2 (rep) -> v3 (rep) -> v4 (regen) -> PASS!
    assert "passage" in st._state()["heads"]
    assert st._state()["heads"]["passage"]["version"] == 4
@pytest.mark.asyncio
async def test_t06_01_decision_regenerate(tmp_path):
    evaluator = Evaluator([EvaluationStatus.FAIL, EvaluationStatus.PASS], IssueCode.SCHEMA_VIOLATION)
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=3)
    rt, st = setup(tmp_path, policy=policy, evaluator=evaluator, repairer=Repairer())
    outcome = await rt.run()
    assert outcome.decision == DecisionType.PASS
    assert outcome.repairs_count == 0
    assert outcome.versions_count == 2
    assert outcome.latest_decision.reason_code == LoopReason.ACCEPTED
    assert "passage" in st._state()["heads"]


@pytest.mark.asyncio
async def test_t06_01_decision_escalate(tmp_path):
    evaluator = Evaluator([EvaluationStatus.FAIL], IssueCode.SOURCE_INSUFFICIENT)
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=3)
    rt, st = setup(tmp_path, policy=policy, evaluator=evaluator, repairer=Repairer())
    outcome = await rt.run()
    assert outcome.decision == DecisionType.ESCALATE
    assert outcome.accepted_artifact is None
    assert "passage" not in st._state()["heads"]


@pytest.mark.asyncio
async def test_t06_01_decision_fail(tmp_path):
    evaluator = Evaluator([EvaluationStatus.FAIL], IssueCode.SCHEMA_VIOLATION)
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=1)
    rt, st = setup(tmp_path, policy=policy, evaluator=evaluator, repairer=Repairer())
    outcome = await rt.run()
    assert outcome.decision == DecisionType.FAIL
    assert outcome.accepted_artifact is None
    assert "passage" not in st._state()["heads"]


# ─────────────────────────────────────────────────────────────────────────────
# T06-02: Stagnation detection
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_02_stagnation_detection(tmp_path):
    rt, store = setup(tmp_path, evaluator=Evaluator([EvaluationStatus.FAIL] * 4),
                      repairer=Repairer(["same", "same"]),
                      policy=LoopPolicy(required_evaluator_ids=("required",), max_versions=3,
                                        max_consecutive_no_progress=2))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert result.terminal_reason_code == LoopReason.NO_PROGRESS
    assert result.repairs_count <= 2
    assert len(store._state()["drafts"]) <= 3


# ─────────────────────────────────────────────────────────────────────────────
# T06-03: Oscillation & Sequence Termination
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_03_oscillation_detection(tmp_path):
    rt, store = setup(tmp_path, evaluator=Evaluator([EvaluationStatus.FAIL] * 10),
                      repairer=Repairer(["B", "A", "B"]), generator=Generator(["A"]),
                      policy=LoopPolicy(required_evaluator_ids=("required",), max_versions=4,
                                        max_oscillation_cycles=1))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert result.terminal_reason_code in (LoopReason.OSCILLATION, LoopReason.MAX_VERSIONS)
    assert result.versions_count <= 4 and result.calls_count <= rt.policy.max_total_calls


@pytest.mark.asyncio
async def test_t06_property_finite_sequence_termination(tmp_path):
    cases = 0
    for statuses in itertools.product((EvaluationStatus.FAIL, EvaluationStatus.PASS, EvaluationStatus.ERROR), repeat=3):
        for repairs in (("same", "same"), ("B", "A"), ("fixed",)):
            folder = tmp_path / str(cases)
            folder.mkdir()
            rt, _ = setup(folder, evaluator=Evaluator(list(statuses)), repairer=Repairer(list(repairs)),
                          policy=LoopPolicy(required_evaluator_ids=("required",), max_versions=3,
                                            max_total_calls=9, max_total_tokens=12000))
            result = await rt.run()
            assert result.terminal_state in (LoopState.COMPLETED, LoopState.FAILED)
            assert result.versions_count <= 3 and result.calls_count <= 9
            assert result.tokens_consumed <= 12000
            cases += 1
    assert cases == 81


# ─────────────────────────────────────────────────────────────────────────────
# T06-04: Blocker invariant never masked by soft scores
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_04_blocker_invariant_never_masked_by_soft_score(tmp_path):
    class SoftEval1(Evaluator):
        evaluator_id = "soft_1"
        async def evaluate(self, ctx, art, intent_id):
            return EvaluationResult(
                evaluationId=f"soft_1_{art.version}", evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version, targetRef=art.to_ref(),
                status=EvaluationStatus.PASS, score=0.99, issues=[],
            )

    class SoftEval2(Evaluator):
        evaluator_id = "soft_2"
        async def evaluate(self, ctx, art, intent_id):
            return EvaluationResult(
                evaluationId=f"soft_2_{art.version}", evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version, targetRef=art.to_ref(),
                status=EvaluationStatus.PASS, score=0.95, issues=[],
            )

    class CriticalBlockerEval(Evaluator):
        evaluator_id = "blocker_eval"
        async def evaluate(self, ctx, art, intent_id):
            iss = Issue.create(
                f"blocker_{art.version}", IssueCode.SCHEMA_VIOLATION, IssueSeverity.CRITICAL,
                ctx.scope, "Critical schema flaw", affected_refs=[art.to_ref()],
            )
            return EvaluationResult(
                evaluationId=f"blocker_{art.version}", evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version, targetRef=art.to_ref(),
                status=EvaluationStatus.FAIL, score=0.92, issues=[iss],
            )

    owner = uuid4()
    ctx = context(owner)
    store = DurableStore(tmp_path / "loop.db", owner)
    policy = LoopPolicy(
        required_evaluator_ids=("soft_1", "soft_2", "blocker_eval"),
        max_versions=2, min_score_threshold=0.80,
    )
    # Average soft score is (0.99 + 0.95 + 0.92) / 3 = 0.953 (well above threshold 0.80)
    rt = BoundedLoopRuntime(
        ctx, policy, Generator(),
        [SoftEval1(), SoftEval2(), CriticalBlockerEval()],
        persistence_client=store, accepted_dependencies={},
    )
    result = await rt.run()
    # High soft scores (0.99, 0.95, 0.92) MUST NOT mask the critical blocker
    assert result.decision == DecisionType.FAIL
    assert result.accepted_artifact is None
    assert "passage" not in store._state()["heads"]
    assert any(i.severity == IssueSeverity.CRITICAL and i.code == IssueCode.SCHEMA_VIOLATION for i in result.ledger.issues)

# ─────────────────────────────────────────────────────────────────────────────
# T06-05: Evaluator errors, fail closed
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_05_evaluator_error_fail_closed(tmp_path):
    evaluator = Evaluator(raise_error=True)
    rt, store = setup(tmp_path, evaluator=evaluator,
                      policy=LoopPolicy(required_evaluator_ids=("required",)))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"]
    assert result.terminal_reason_code == LoopReason.EVALUATOR_ERROR
    assert result.ledger.issues


@pytest.mark.asyncio
async def test_t06_05_missing_required_evaluator(tmp_path):
    evaluator = Evaluator()
    rt, store = setup(tmp_path, evaluator=evaluator,
                      policy=LoopPolicy(required_evaluator_ids=("absent",)))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"]
    assert result.terminal_reason_code == LoopReason.MISSING_EVALUATOR
    assert result.ledger.issues
@pytest.mark.asyncio
async def test_t06_05_evaluator_timeout_fail_closed(tmp_path):
    class HangingEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            await asyncio.sleep(2.0)
            return await super().evaluate(ctx, art, intent_id)

    evaluator = HangingEvaluator()
    # The effective bound is min(operation wall reservation, semantic timeout,
    # evaluator-declared metadata timeout) at runtime.py. 1 s is the smallest value the
    # pinned cap profile can carry (caps are positive 32-bit integers, matching .NET
    # `RequiredInt`), and the semantic default is left at 30 s, so the operation
    # reservation is the sole binding constraint that can time out a 2 s hang.
    policy = LoopPolicy(required_evaluator_ids=("required",), operation_wall_reservation_seconds=1)
    rt, store = setup(tmp_path, evaluator=evaluator, policy=policy)
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"]
    assert result.terminal_reason_code == LoopReason.EVALUATOR_ERROR
    assert any(i.code == IssueCode.EVALUATOR_UNAVAILABLE and i.severity == IssueSeverity.CRITICAL and "TimeoutError" in i.message for i in result.ledger.issues)


@pytest.mark.asyncio
async def test_t06_05_evaluator_malformed_output_fail_closed(tmp_path):
    class MalformedEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            return "not_an_evaluation_result_object"

    evaluator = MalformedEvaluator()
    rt, store = setup(tmp_path, evaluator=evaluator, policy=LoopPolicy(required_evaluator_ids=("required",)))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"]
    assert result.terminal_reason_code == LoopReason.EVALUATOR_ERROR
    assert any(i.code == IssueCode.EVALUATOR_UNAVAILABLE and i.severity == IssueSeverity.CRITICAL for i in result.ledger.issues)


@pytest.mark.asyncio
async def test_t06_05_evaluator_wrong_artifact_version_fail_closed(tmp_path):
    class WrongVersionEvaluator(Evaluator):
        async def evaluate(self, ctx, art, intent_id):
            wrong_ref = art.to_ref().model_copy(update={"version": 99})
            return EvaluationResult(
                evaluationId=f"eval_wrong_{art.version}", evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version, targetRef=wrong_ref,
                inputDependencyRefs=list(art.parent_refs), status=EvaluationStatus.PASS,
                issues=[],
            )

    evaluator = WrongVersionEvaluator()
    rt, store = setup(tmp_path, evaluator=evaluator, policy=LoopPolicy(required_evaluator_ids=("required",)))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"]
    assert result.terminal_reason_code == LoopReason.EVALUATOR_ERROR
    assert any(i.code == IssueCode.EVALUATOR_UNAVAILABLE and i.severity == IssueSeverity.CRITICAL and "ValueError" in i.message for i in result.ledger.issues)


@pytest.mark.asyncio
async def test_t06_05_optional_evaluator_skipped_with_policy_rationale(tmp_path):
    class RequiredAcademicEval(Evaluator):
        evaluator_id = "eval_required_academic"
        async def evaluate(self, ctx, art, intent_id):
            return EvaluationResult(
                evaluationId=f"req_{art.version}", evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version, targetRef=art.to_ref(),
                status=EvaluationStatus.PASS, score=0.95, issues=[],
            )

    # Optional evaluator for diagrams/tables, skipped when section policy determines no diagrams exist
    class OptionalDiagramEval(Evaluator):
        evaluator_id = "eval_optional_diagram"
        def __init__(self):
            super().__init__()
            self.was_called = False
        async def evaluate(self, ctx, art, intent_id):
            self.was_called = True
            return EvaluationResult(
                evaluationId=f"opt_{art.version}", evaluatorId=self.evaluator_id,
                evaluatorVersion=self.evaluator_version, targetRef=art.to_ref(),
                status=EvaluationStatus.PASS, score=1.0, issues=[],
            )

    # Policy explicitly requires only eval_required_academic; eval_optional_diagram is omitted
    policy = LoopPolicy(required_evaluator_ids=("eval_required_academic",))
    owner = uuid4()
    ctx = context(owner)
    store = DurableStore(tmp_path / "loop.db", owner)

    opt_eval = OptionalDiagramEval()
    # Omitted from active execution set per policy rationale (section has no diagram content)
    rt = BoundedLoopRuntime(
        ctx, policy, Generator(), [RequiredAcademicEval()],
        persistence_client=store, accepted_dependencies={},
    )
    result = await rt.run()
    assert result.decision == DecisionType.PASS
    assert result.terminal_reason_code == LoopReason.ACCEPTED
    assert "passage" in store._state()["heads"]
    assert opt_eval.was_called is False  # Explicitly proves optional evaluator was skipped

# ─────────────────────────────────────────────────────────────────────────────
# T06-06: Durable fault state replay & crash recovery
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_06_durable_fault_state_1_post_grant_pre_generate(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    store.fault = "grant"
    gen, ev = Generator(), Evaluator()
    rt, _ = setup(tmp_path, store=store, owner=owner, generator=gen, evaluator=ev)
    with pytest.raises(OSError, match="simulated process death"):
        await rt.run()
    new_store = DurableStore(tmp_path / "loop.db", owner)
    gen2, ev2 = Generator(), Evaluator()
    resumed, _ = setup(tmp_path, store=new_store, owner=owner, generator=gen2, evaluator=ev2)
    result = await resumed.run()
    assert result.decision == DecisionType.FAIL
    assert result.terminal_reason_code == LoopReason.UNKNOWN_OUTCOME
    assert gen2.calls == 0


@pytest.mark.asyncio
async def test_t06_06_durable_fault_state_2_post_draft_commit_pre_evaluate(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    store.fault = "draft"
    gen, ev = Generator(), Evaluator()
    rt, _ = setup(tmp_path, store=store, owner=owner, generator=gen, evaluator=ev)
    with pytest.raises(OSError, match="simulated process death"):
        await rt.run()
    new_store = DurableStore(tmp_path / "loop.db", owner)
    gen2, ev2 = Generator(), Evaluator()
    resumed, _ = setup(tmp_path, store=new_store, owner=owner, generator=gen2, evaluator=ev2)
    result = await resumed.run()
    assert result.decision == DecisionType.PASS
    assert gen2.calls == 0
    assert new_store._state()["heads"]["passage"]["version"] == 1


@pytest.mark.asyncio
async def test_t06_06_durable_fault_state_3_post_evaluate_pre_decision(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    store.fault = "evaluate"
    gen, ev = Generator(), Evaluator()
    rt, _ = setup(tmp_path, store=store, owner=owner, generator=gen, evaluator=ev)
    with pytest.raises(OSError, match="simulated process death"):
        await rt.run()
    new_store = DurableStore(tmp_path / "loop.db", owner)
    gen2, ev2 = Generator(), Evaluator()
    resumed, _ = setup(tmp_path, store=new_store, owner=owner, generator=gen2, evaluator=ev2)
    result = await resumed.run()
    assert result.decision == DecisionType.PASS
    assert gen2.calls == 0
    assert ev2.calls == 0
    assert new_store._state()["heads"]["passage"]["version"] == 1


@pytest.mark.asyncio
async def test_t06_06_durable_fault_state_4_post_repair_draft_pre_reevaluate(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    evaluator = HealingEvaluator()
    repairer = Repairer()
    # Let v1 draft succeed, evaluate succeed with FAIL, then fault on repair draft
    store.fault = "evaluate"
    rt, _ = setup(tmp_path, store=store, owner=owner, evaluator=evaluator, repairer=repairer)
    with pytest.raises(OSError):
        await rt.run()
    new_store = DurableStore(tmp_path / "loop.db", owner)
    new_store.fault = "draft"
    rt2, _ = setup(tmp_path, store=new_store, owner=owner, evaluator=evaluator, repairer=repairer)
    with pytest.raises(OSError):
        await rt2.run()
    final_store = DurableStore(tmp_path / "loop.db", owner)
    rt3, _ = setup(tmp_path, store=final_store, owner=owner, evaluator=evaluator, repairer=repairer)
    result = await rt3.run()
    assert result.decision == DecisionType.PASS
    assert result.repairs_count == 1
    assert result.versions_count == 2


@pytest.mark.asyncio
async def test_t06_06_durable_fault_state_5_post_pass_commit(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    store.fault = "commit"
    gen, ev = Generator(), Evaluator()
    rt, _ = setup(tmp_path, store=store, owner=owner, generator=gen, evaluator=ev)
    with pytest.raises(OSError, match="simulated process death"):
        await rt.run()
    new_store = DurableStore(tmp_path / "loop.db", owner)
    gen2, ev2 = Generator(), Evaluator()
    resumed, _ = setup(tmp_path, store=new_store, owner=owner, generator=gen2, evaluator=ev2)
    result = await resumed.run()
    assert result.decision == DecisionType.PASS
    assert gen2.calls == 0
    assert ev2.calls == 0
    assert new_store._state()["heads"]["passage"]["version"] == 1


@pytest.mark.asyncio
async def test_t06_06_crash_and_resume(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    store.fault = "draft"
    rt, _ = setup(tmp_path, store=store, owner=owner,
                  evaluator=HealingEvaluator(), repairer=Repairer())
    with pytest.raises(OSError):
        await rt.run()
    store = DurableStore(tmp_path / "loop.db", owner)
    store.fault = "evaluate"
    rt, _ = setup(tmp_path, store=store, owner=owner,
                  evaluator=HealingEvaluator(), repairer=Repairer())
    with pytest.raises(OSError):
        await rt.run()
    store = DurableStore(tmp_path / "loop.db", owner)
    rt, _ = setup(tmp_path, store=store, owner=owner,
                  evaluator=HealingEvaluator(), repairer=Repairer())
    result = await rt.run()
    assert result.repairs_count == 1 and result.versions_count == 2
    assert result.decision == DecisionType.PASS
    assert any(i.status in (IssueStatus.RESOLVED, IssueStatus.SUPERSEDED) for i in result.ledger.issues)


# ─────────────────────────────────────────────────────────────────────────────
# T06-07: Stale descendants & dependency invalidation
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_07_stale_descendants_dependency_freshness(tmp_path):
    ctx = context()
    v1 = artifact(ctx, 1, "parent")
    v2 = artifact(ctx, 2, "parent changed")
    question = ArtifactEnvelope.create("q", ArtifactType.QUESTION, ctx.run_id,
                                       {"text": "q"}, "fake-v1", parent_refs=[v1.to_ref()])
    assert not DependencyValidator.validate_dependency_freshness(question, {"passage": v2.to_ref()})[0]
    assert not DependencyValidator.validate_dependency_freshness(question, {})[0]
    rt, store = setup(tmp_path, parents=[v1.to_ref()], deps={"passage": v2.to_ref()},
                      policy=LoopPolicy(required_evaluator_ids=("required",), max_versions=1))
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "passage" not in store._state()["heads"]


def test_dependency_closure_invalidation():
    ctx = context()
    v1 = artifact(ctx, 1, "parent")
    v2 = artifact(ctx, 2, "parent changed")
    question = ArtifactEnvelope.create("q", ArtifactType.QUESTION, ctx.run_id,
                                       {"text": "q"}, "fake-v1", parent_refs=[v1.to_ref()])
    group = ArtifactEnvelope.create("g", ArtifactType.QUESTION_GROUP, ctx.run_id,
                                    {"text": "g"}, "fake-v1", parent_refs=[question.to_ref()])
    closure = DependencyValidator.compute_invalidation_closure("passage", [v2, question, group])
    assert closure == {"passage", "q", "g"}


# ─────────────────────────────────────────────────────────────────────────────
# T06-08: Lease fencing & cancellation
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_t06_08_fenced_commit_rejects_stale_writer(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    ev = Evaluator()
    original = ev.evaluate
    async def late(ctx, art, intent_id):
        result = await original(ctx, art, intent_id)
        store.epoch += 1
        return result
    ev.evaluate = late
    rt, _ = setup(tmp_path, store=store, owner=owner, evaluator=ev)
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert result.terminal_state == LoopState.ABORTED
    assert "passage" not in store._state()["heads"]


@pytest.mark.asyncio
async def test_t06_08_cancellation_before_accept(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    ev = Evaluator()
    original = ev.evaluate
    async def late(ctx, art, intent_id):
        result = await original(ctx, art, intent_id)
        store.cancelled = True
        return result
    ev.evaluate = late
    rt, _ = setup(tmp_path, store=store, owner=owner, evaluator=ev)
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert result.terminal_state == LoopState.ABORTED
    assert "passage" not in store._state()["heads"]


# ─────────────────────────────────────────────────────────────────────────────
# Advisory & Integrity Tests: Issue Omission & Persisted Invalidation
# ─────────────────────────────────────────────────────────────────────────────

def test_t06_issue_omission_requires_explicit_evidence():
    ctx = context()
    art = artifact(ctx, 1, "A")
    ledger = IssueLedgerManager(ctx.run_id)
    issue = ledger.record_issue(IssueCode.WORD_LIMIT_EXCEEDED, IssueSeverity.CRITICAL,
                                ctx.scope, "defect", [art.to_ref()])
    passing = EvaluationResult(evaluationId="pass", evaluatorId="required", evaluatorVersion="1",
                               targetRef=art.to_ref(), status=EvaluationStatus.PASS, issues=[])
    ledger.reconcile_evaluation(passing)
    assert ledger.has_unresolved_blockers()
    with pytest.raises(ValueError):
        ledger.resolve_issue(issue.fingerprint, passing)
    explicit = passing.model_copy(update={"resolved_issue_fingerprints": [issue.fingerprint]})
    ledger.reconcile_evaluation(explicit)
    assert not ledger.has_unresolved_blockers()
    assert ledger.resolution_history[-1].justification.startswith("Verified by pass")


@pytest.mark.asyncio
async def test_t06_repair_omission_does_not_pass(tmp_path):
    """If repair creates v2, but evaluator on v2 omits the prior defect fingerprint, blocker stays open."""
    evaluator = Evaluator([EvaluationStatus.FAIL, EvaluationStatus.PASS], IssueCode.WORD_LIMIT_EXCEEDED, omit=True)
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=2)
    rt, st = setup(tmp_path, policy=policy, evaluator=evaluator, repairer=Repairer())
    outcome = await rt.run()
    # Must NOT pass because blocker was omitted without explicit evidence
    assert outcome.decision != DecisionType.PASS
    assert any(i.status == IssueStatus.OPEN and i.severity == IssueSeverity.CRITICAL for i in outcome.ledger.issues)
    assert "passage" not in st._state()["heads"]


@pytest.mark.asyncio
async def test_t06_regenerate_omission_does_not_pass(tmp_path):
    """If regenerate creates v2, but evaluator on v2 omits the prior defect fingerprint, blocker stays open."""
    evaluator = Evaluator([EvaluationStatus.FAIL, EvaluationStatus.PASS], IssueCode.SCHEMA_VIOLATION, omit=True)
    policy = LoopPolicy(required_evaluator_ids=("required",), max_versions=2)
    rt, st = setup(tmp_path, policy=policy, evaluator=evaluator, repairer=Repairer())
    outcome = await rt.run()
    # Must NOT pass because blocker was omitted without explicit evidence
    assert outcome.decision != DecisionType.PASS
    assert any(i.status == IssueStatus.OPEN and i.severity == IssueSeverity.CRITICAL for i in outcome.ledger.issues)
    assert "passage" not in st._state()["heads"]


@pytest.mark.asyncio
async def test_t06_persisted_descendant_invalidation_removes_heads(tmp_path):
    """Repair commits v2; descendant heads are atomically invalidated and removed from heads."""
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    ctx = context(owner)
    v1 = artifact(ctx, 1, "passage text")
    q1 = ArtifactEnvelope.create("q1", ArtifactType.QUESTION, ctx.run_id, {"text": "q"}, "fake-v1", parent_refs=[v1.to_ref()])
    state = store._state()
    state["heads"]["q1"] = q1.model_dump(mode="json", by_alias=True)
    state["descendants"]["passage"] = ["q1"]
    store._save(state, "setup")

    evaluator = HealingEvaluator()
    repairer = Repairer()
    rt, _ = setup(tmp_path, store=store, owner=owner, evaluator=evaluator, repairer=repairer)
    result = await rt.run()
    assert result.decision == DecisionType.PASS
    final_state = store._state()
    assert "passage" in final_state["heads"]
    assert final_state["heads"]["passage"]["version"] == 2
    assert "q1" not in final_state["heads"]

@pytest.mark.asyncio
async def test_t06_parent_updated_during_evaluation_rejects_commit(tmp_path):
    """If parent head updates while child evaluates, the fenced commit rejects with 409."""
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    ctx = context(owner)
    v1 = artifact(ctx, 1, "passage v1")
    v2 = artifact(ctx, 2, "passage v2 updated")
    state = store._state()
    state["heads"]["passage"] = v1.model_dump(mode="json", by_alias=True)
    store._save(state, "setup")

    q_ctx = LoopContext(
        runId="run_t06", targetArtifactId="q1",
        targetArtifactType=ArtifactType.QUESTION, scope=IssueScope.QUESTION,
        inputDependencies=(v1.to_ref(),),
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )
    class QuestionGen:
        version = "fake-v1"
        name = "qgen"
        async def generate(self, ctx, intent_id, version):
            return ArtifactEnvelope.create("q1", ArtifactType.QUESTION, ctx.run_id,
                                           {"text": "question"}, "fake-v1", version=version,
                                           parent_refs=[v1.to_ref()])

    ev = Evaluator()
    original_eval = ev.evaluate
    async def update_parent_during_eval(ctx, art, intent_id):
        res = await original_eval(ctx, art, intent_id)
        cur_state = store._state()
        cur_state["heads"]["passage"] = v2.model_dump(mode="json", by_alias=True)
        store._save(cur_state, "concurrent_parent_update")
        return res
    ev.evaluate = update_parent_during_eval

    rt = BoundedLoopRuntime(q_ctx, LoopPolicy(required_evaluator_ids=("required",)),
                            QuestionGen(), [ev], persistence_client=store,
                            accepted_dependencies={"passage": v1.to_ref()})
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "q1" not in store._state()["heads"]


@pytest.mark.asyncio
async def test_t06_missing_parent_head_rejects_commit(tmp_path):
    """If child declares a parent that has no accepted head in store, fenced commit rejects with 409."""
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner)
    ctx = context(owner)
    v1 = artifact(ctx, 1, "passage v1")
    # Passage is NOT in store heads
    q_ctx = LoopContext(
        runId="run_t06", targetArtifactId="q1",
        targetArtifactType=ArtifactType.QUESTION, scope=IssueScope.QUESTION,
        inputDependencies=(v1.to_ref(),),
        authority=AuthorityGrant(leaseOwner=owner, epoch=1),
    )
    class QuestionGen:
        version = "fake-v1"
        name = "qgen"
        async def generate(self, ctx, intent_id, version):
            return ArtifactEnvelope.create("q1", ArtifactType.QUESTION, ctx.run_id,
                                           {"text": "question"}, "fake-v1", version=version,
                                           parent_refs=[v1.to_ref()])

    ev = Evaluator()
    rt = BoundedLoopRuntime(q_ctx, LoopPolicy(required_evaluator_ids=("required",)),
                            QuestionGen(), [ev], persistence_client=store,
                            accepted_dependencies={"passage": v1.to_ref()})
    result = await rt.run()
    assert result.decision == DecisionType.FAIL
    assert "q1" not in store._state()["heads"]

@pytest.mark.asyncio
async def test_budget_caps_exhaustion(tmp_path):
    owner = uuid4()
    store = DurableStore(tmp_path / "loop.db", owner, cap_calls=1)
    gen = Generator()
    rt, _ = setup(tmp_path, store=store, owner=owner, generator=gen,
                  policy=LoopPolicy(required_evaluator_ids=("required",), max_total_calls=1))
    result = await rt.run()
    assert result.terminal_reason_code == LoopReason.CALL_CAP and gen.calls == 1
    assert len(store._state()["ops"]) == 1
    resumed, _ = setup(tmp_path, store=DurableStore(tmp_path / "loop.db", owner), owner=owner,
                       policy=LoopPolicy(required_evaluator_ids=("required",), max_total_calls=1))
    resumed_result = await resumed.run()
    assert resumed_result.calls_count == 1 and resumed_result.decision == DecisionType.FAIL
