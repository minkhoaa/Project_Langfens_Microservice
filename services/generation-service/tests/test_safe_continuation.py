"""Safe Continuation & Blocker Resolution Tests.

Verifies:
1. Active lease authority and fencing semantics.
2. Cryptographic content hash integrity and tamper rejection.
3. Immutable Section 2 Redfield ratio v2 correction (63d5991c...) and Section 3 v1 (e8fe102c...).
4. Checkpoint import with verified provenance and binding to new continuation runs.
5. Cumulative budget enforcement (<= 100k tokens, <= 900s) accounting for prior usage.
6. Target question slot numbering and IELTS types (Section 2 Q14-26, Section 3 Q27-40 YesNoNotGiven).
"""

import json
import sys
from pathlib import Path
from uuid import UUID, uuid4
import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, ArtifactRef, compute_content_hash, canonical_json_dump
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.policy import LoopPolicy
from app.loop.question import QuestionCandidateLoop, SECTION_MAX_TOKENS, SECTION_MAX_WALL_TIME_SECONDS
from app.persistence.models import CheckpointImportRequest, CheckpointAck, OperationGrantRequest, OperationGrantResult
from app.persistence.client import CheckpointClient, CheckpointApiError
from app.selection.selector import SelectionInfeasibleError

from continue_sections_2_and_3 import (
    SECTION_2_SLOTS,
    SECTION_3_SLOTS,
    SECTION_2_PASSAGE_V1_HASH,
    SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH,
    SECTION_3_PASSAGE_V1_HASH,
    SECTION_2_BLUEPRINT_V1_HASH,
    SECTION_3_BLUEPRINT_V1_HASH,
    validate_cumulative_budget,
    get_verified_passage_envelope,
    build_checkpoint_import_request,
    build_questions_request,
    build_section_assembly_request,
)


class MockContinuationStore(CheckpointClient):
    """Test store supporting lease fencing, operation tracking, and checkpoint imports."""

    def __init__(self, run_id: str, owner: UUID, epoch: int = 1):
        super().__init__(base_url="http://test.local", internal_api_key="test_key")
        self.run_id = run_id
        self.owner = owner
        self.epoch = epoch
        self.operations: dict[str, dict] = {}
        self.artifacts: list[ArtifactEnvelope] = []
        self.tokens_used = 0
        self.calls_used = 0
        self.wall_time_used = 0.0

    def grant_operation(self, request: OperationGrantRequest) -> OperationGrantResult:
        if request.runId != self.run_id:
            raise CheckpointApiError(404, f"Run '{request.runId}' not found")
        if request.epoch != self.epoch:
            raise CheckpointApiError(409, f"Epoch fencing conflict: requested {request.epoch} != {self.epoch}")
        if request.leaseOwner != self.owner:
            raise CheckpointApiError(409, f"Lease owner conflict: requested {request.leaseOwner} != {self.owner}")

        self.operations[request.operationId] = {
            "operationId": request.operationId,
            "operationType": request.operationType,
            "status": "RESERVED",
            "tokenReservation": request.tokenReservation,
            "tokensUsed": 0,
            "wallTimeReservationSeconds": request.wallTimeReservationSeconds,
            "wallTimeUsedSeconds": 0.0,
        }
        from datetime import datetime, timezone
        return OperationGrantResult(
            operationId=request.operationId,
            runId=request.runId,
            status="RESERVED",
            tokenReservation=request.tokenReservation,
            wallTimeReservationSeconds=request.wallTimeReservationSeconds,
            grantedAt=datetime.now(timezone.utc),
            isReplay=False,
            resultRefJson=None,
            reservationBreached=False,
            budgetBreachDetected=False,
        )

    def import_checkpoint(self, request: CheckpointImportRequest) -> CheckpointAck:
        if request.run_id != self.run_id:
            raise CheckpointApiError(404, f"Run '{request.run_id}' not found")
        if request.epoch != self.epoch:
            raise CheckpointApiError(409, f"Epoch fencing conflict: {request.epoch} != {self.epoch}")
        if request.lease_owner != self.owner:
            raise CheckpointApiError(409, f"Lease owner conflict: {request.lease_owner} != {self.owner}")

        # Hash integrity check
        if not request.artifact.verify_integrity():
            raise CheckpointApiError(400, "Artifact content hash mismatch")

        # Provenance check: if source_run_id is specified, must be non-empty
        if request.source_run_id is not None and not request.source_run_id.strip():
            raise CheckpointApiError(404, "Invalid empty source run id")

        # Bind artifact to target run
        self.artifacts.append(request.artifact)
        from datetime import datetime, timezone
        return CheckpointAck(
            runId=request.run_id,
            epoch=request.epoch,
            artifactId=request.artifact.artifact_id,
            version=request.artifact.version,
            contentHash=request.artifact.content_hash,
            serverTimestampUtc=datetime.now(timezone.utc),
            isReplay=False,
        )

    def resume_state(self, run_id: str):
        from app.persistence.models import ResumeStateResult, ArtifactResumeInfo
        resume_artifacts = [
            ArtifactResumeInfo(
                artifactId=a.artifact_id,
                artifactType=a.artifact_type.value,
                acceptedVersion=a.version,
                acceptedHash=a.content_hash,
                payloadJson=canonical_json_dump(a.payload),
                parentRefs=list(a.parent_refs),
                isStale=False,
                envelopeJson=a.model_dump_json(by_alias=True),
            )
            for a in self.artifacts
        ]
        return ResumeStateResult(
            runId=self.run_id,
            jobId=uuid4(),
            epoch=self.epoch,
            status="RUNNING",
            engineVersion="2.0.0",
            schemaVersion="2.0.0",
            policyVersion="2.0.0",
            artifacts=resume_artifacts,
            tokensUsed=self.tokens_used,
            callsUsed=self.calls_used,
            wallTimeUsedSeconds=self.wall_time_used,
            budgetCapTokens=100000,
            budgetCapWallTimeSeconds=900,
        )

    def reconcile_operation(self, request):
        if request.operationId in self.operations:
            self.operations[request.operationId]["status"] = "COMPLETED"
            self.operations[request.operationId]["wallTimeUsedSeconds"] = request.wallTimeUsedSeconds
            self.operations[request.operationId]["tokensUsed"] = request.tokensUsed


# ─── 1. Lease Authority and Fencing ──────────────────────────────────────────

def test_lease_authority_active_and_fenced():
    """AuthorityGrant enforces epoch and lease owner match; rejects stale writers."""
    owner1 = uuid4()
    owner2 = uuid4()
    grant = AuthorityGrant(leaseOwner=owner1, epoch=2)

    # Active match
    assert grant.is_authority_active(current_lease_owner=owner1, current_epoch=2) is True

    # Stale epoch rejected
    assert grant.is_authority_active(current_lease_owner=owner1, current_epoch=1) is False
    assert grant.is_authority_active(current_lease_owner=owner1, current_epoch=3) is False

    # Stale lease owner rejected
    assert grant.is_authority_active(current_lease_owner=owner2, current_epoch=2) is False


def test_mock_continuation_store_rejects_fencing_violations():
    """Persistence store rejects grant and import requests with stale epoch or lease owner."""
    owner = uuid4()
    store = MockContinuationStore(run_id="run_cont_01", owner=owner, epoch=2)

    # Valid grant
    res = store.grant_operation(OperationGrantRequest(
        runId="run_cont_01", epoch=2, leaseOwner=owner,
        operationId="op_valid", operationType="GENERATE",
        requestHash="hash_1", tokenReservation=5000,
    ))
    assert res.status == "RESERVED"

    # Epoch mismatch rejected
    with pytest.raises(CheckpointApiError) as exc:
        store.grant_operation(OperationGrantRequest(
            runId="run_cont_01", epoch=1, leaseOwner=owner,
            operationId="op_stale_epoch", operationType="GENERATE",
            requestHash="hash_2", tokenReservation=5000,
        ))
    assert exc.value.status_code == 409
    assert "Epoch fencing conflict" in exc.value.message

    # Lease owner mismatch rejected
    with pytest.raises(CheckpointApiError) as exc:
        store.grant_operation(OperationGrantRequest(
            runId="run_cont_01", epoch=2, leaseOwner=uuid4(),
            operationId="op_wrong_owner", operationType="GENERATE",
            requestHash="hash_3", tokenReservation=5000,
        ))
    assert exc.value.status_code == 409
    assert "Lease owner conflict" in exc.value.message


# ─── 2. Cryptographic Content Hash Integrity ─────────────────────────────────

def test_hash_integrity_verification_and_tamper_detection():
    """ArtifactEnvelope verify_integrity detects payload mutations and parentRefs alterations."""
    p_env = get_verified_passage_envelope(section_index=3, version=1)
    env = ArtifactEnvelope.model_validate(p_env)
    assert env.verify_integrity() is True
    assert env.content_hash == SECTION_3_PASSAGE_V1_HASH

    # Tampered payload fails integrity
    tampered_payload = dict(env.payload)
    tampered_payload["passage"] = str(tampered_payload["passage"]) + " Tampered addition."
    tampered_env = ArtifactEnvelope(
        artifactId=env.artifact_id,
        artifactType=env.artifact_type,
        version=env.version,
        runId=env.run_id,
        schemaVersion=env.schema_version,
        contentHash=env.content_hash,  # Claiming old hash
        createdAt=env.created_at,
        producerVersion=env.producer_version,
        payload=tampered_payload,
        parentRefs=env.parent_refs,
    )
    assert tampered_env.verify_integrity() is False

    # Tampered parentRefs fails integrity
    tampered_parents_env = ArtifactEnvelope(
        artifactId=env.artifact_id,
        artifactType=env.artifact_type,
        version=env.version,
        runId=env.run_id,
        schemaVersion=env.schema_version,
        contentHash=env.content_hash,
        createdAt=env.created_at,
        producerVersion=env.producer_version,
        payload=env.payload,
        parentRefs=(),  # Dropped parent refs
    )
    assert tampered_parents_env.verify_integrity() is False


# ─── 3. Section 2 Redfield Ratio v2 Correction ───────────────────────────────

def test_section_2_redfield_ratio_corrected_in_v2():
    """Section 2 v2 has corrected classical Redfield ratio (106:16:1) and deterministic hash."""
    s2_v2_env_data = get_verified_passage_envelope(section_index=2, version=2)
    env = ArtifactEnvelope.model_validate(s2_v2_env_data)

    assert env.artifact_id == "art_passage_s2"
    assert env.version == 2
    assert env.verify_integrity() is True
    assert env.content_hash == SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH
    assert env.content_hash == "63d5991ce36d7dba3b956f69fa49ed1401d8cbef18d1f09ac43e537030194e39"

    # Invariant: Must contain classical Redfield ratio 106:16:1
    passage_text = str(env.payload.get("passage", ""))
    assert "classical Redfield ratio of 106:16:1" in passage_text
    # Invariant: Must NOT contain erroneous 106:16:6.7
    assert "106:16:6.7" not in passage_text


def test_section_2_v1_and_v2_immutability():
    """Section 2 v1 and v2 are distinct immutable versions preserving lineage."""
    s2_v2_data = get_verified_passage_envelope(section_index=2, version=2)
    env_v2 = ArtifactEnvelope.model_validate(s2_v2_data)

    # v2 content hash is distinct from v1 hash
    assert env_v2.content_hash != SECTION_2_PASSAGE_V1_HASH
    assert env_v2.version == 2

    # Lineage parentRefs match Section 2 blueprint/evidence/sourcepack
    parent_ids = [p.artifact_id for p in env_v2.parent_refs]
    assert "bp_sec_2_a39ea79c" in parent_ids
    assert "eg_sec_2_a39ea79c" in parent_ids
    assert "sp_sec_2_a39ea79c" in parent_ids


def test_section_3_v1_verified_hash():
    """Section 3 v1 passage content hash strictly matches verified PostgreSQL persistence."""
    s3_v1_data = get_verified_passage_envelope(section_index=3, version=1)
    env = ArtifactEnvelope.model_validate(s3_v1_data)

    assert env.artifact_id == "art_passage_s3"
    assert env.version == 1
    assert env.verify_integrity() is True
    assert env.content_hash == SECTION_3_PASSAGE_V1_HASH
    assert env.content_hash == "e8fe102c8034f1ee672f1a177de3e99a578415527aaf77eb39cb9ecfc12904ad"


# ─── 4. Checkpoint Import and Bindings ────────────────────────────────────────

def test_checkpoint_import_and_binding_to_continuation_run():
    """Verified passage artifact is imported into continuation run without passage regeneration."""
    owner = uuid4()
    cont_run_id = f"run_cont_{uuid4().hex[:8]}"
    store = MockContinuationStore(run_id=cont_run_id, owner=owner, epoch=1)

    s2_v2_data = get_verified_passage_envelope(section_index=2, version=2)
    env = ArtifactEnvelope.model_validate(s2_v2_data)

    # Import checkpoint with provenance
    import_req = CheckpointImportRequest(
        runId=cont_run_id,
        epoch=1,
        leaseOwner=owner,
        artifact=env,
        sourceRunId="run_70d6a3b92ecf4f5ab61ac42cef20dd4c",
    )
    ack = store.import_checkpoint(import_req)
    assert ack.runId == cont_run_id
    assert ack.artifactId == "art_passage_s2"
    assert ack.version == 2
    assert ack.contentHash == SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH

    # Verify resume state now exposes the imported passage head
    state = store.resume_state(cont_run_id)
    assert len(state.artifacts) == 1
    art_info = state.artifacts[0]
    assert art_info.artifactId == "art_passage_s2"
    assert art_info.acceptedVersion == 2
    assert art_info.acceptedHash == SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH
    assert art_info.isStale is False


def test_checkpoint_import_rejects_tampered_artifact():
    """Checkpoint import fails closed when artifact content hash does not match payload."""
    owner = uuid4()
    store = MockContinuationStore(run_id="run_cont_tamper", owner=owner, epoch=1)

    s2_v2_data = get_verified_passage_envelope(section_index=2, version=2)
    env = ArtifactEnvelope.model_validate(s2_v2_data)

    # Tamper payload
    tampered_payload = dict(env.payload)
    tampered_payload["passage"] = "Tampered text."
    tampered_env = ArtifactEnvelope(
        artifactId=env.artifact_id,
        artifactType=env.artifact_type,
        version=env.version,
        runId=env.run_id,
        schemaVersion=env.schema_version,
        contentHash=env.content_hash,
        createdAt=env.created_at,
        producerVersion=env.producer_version,
        payload=tampered_payload,
        parentRefs=env.parent_refs,
    )

    with pytest.raises(CheckpointApiError) as exc:
        store.import_checkpoint(CheckpointImportRequest(
            runId="run_cont_tamper",
            epoch=1,
            leaseOwner=owner,
            artifact=tampered_env,
        ))
    assert exc.value.status_code == 400
    assert "Artifact content hash mismatch" in exc.value.message


# ─── 5. Cumulative Budget Enforcement ────────────────────────────────────────

def test_cumulative_budget_validation_allows_safe_continuation():
    """validate_cumulative_budget allows operations fitting within 100k tokens and 900s."""
    # Section 2 prior usage: 8,220 tokens, 48.67s
    prior_tokens_s2 = 8220
    prior_wall_s2 = 48.67
    assert validate_cumulative_budget(prior_tokens_s2, prior_wall_s2, requested_tokens=50000, requested_wall_time=300.0) is True

    # Section 3 prior usage: 16,949 tokens, 71.42s
    prior_tokens_s3 = 16949
    prior_wall_s3 = 71.42
    assert validate_cumulative_budget(prior_tokens_s3, prior_wall_s3, requested_tokens=60000, requested_wall_time=400.0) is True


def test_cumulative_budget_validation_rejects_overruns():
    """validate_cumulative_budget raises ValueError when cumulative ceiling is breached."""
    # Exceeding 100k tokens
    with pytest.raises(ValueError) as exc:
        validate_cumulative_budget(prior_tokens=90000, prior_wall_time=100.0, requested_tokens=15000)
    assert "Section cumulative token limit exceeded" in str(exc.value)

    # Exceeding 900s wall time
    with pytest.raises(ValueError) as exc:
        validate_cumulative_budget(prior_tokens=20000, prior_wall_time=850.0, requested_wall_time=60.0)
    assert "Section cumulative wall time limit exceeded" in str(exc.value)


@pytest.mark.asyncio
async def test_question_candidate_loop_enforces_prior_budget_exhaustion():
    """QuestionCandidateLoop immediately fails closed if prior section usage already reached 100k tokens."""
    from app.generators.question.generator import QuestionCandidateGenerator
    owner = uuid4()
    run_id = f"run_budget_exhausted_{uuid4().hex[:8]}"
    store = MockContinuationStore(run_id=run_id, owner=owner, epoch=1)

    # Simulate prior usage that exhausted the 100k token ceiling
    store.tokens_used = 100_000
    store.wall_time_used = 150.0

    s2_env = ArtifactEnvelope.model_validate(get_verified_passage_envelope(section_index=2, version=2))
    store.import_checkpoint(CheckpointImportRequest(runId=run_id, epoch=1, leaseOwner=owner, artifact=s2_env))

    bp_ref = ArtifactRef(
        artifactId="bp_sec_2_a39ea79c",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash=SECTION_2_BLUEPRINT_V1_HASH,
    )

    loop = QuestionCandidateLoop(
        generator=QuestionCandidateGenerator(gateway=None),
        persistence_client=store,
    )

    with pytest.raises(SelectionInfeasibleError) as exc:
        await loop.run(
            passage_artifact=s2_env,
            blueprint_ref=bp_ref,
            question_slots=[{"number": 14, "type": "MultipleChoice"}],
            run_id=run_id,
            lease_owner=owner,
            epoch=1,
            section_index=2,
        )
    assert "Cumulative section token budget exhausted before question loop" in str(exc.value)


# ─── 6. Question Numbering and IELTS Types ────────────────────────────────────

def test_section_2_slot_numbering_and_types():
    """Section 2 specifies exactly 13 items: Q14-Q19 MultipleChoice and Q20-Q26 SummaryCompletion."""
    assert len(SECTION_2_SLOTS) == 13
    assert SECTION_2_SLOTS[0]["number"] == 14
    assert SECTION_2_SLOTS[-1]["number"] == 26

    # Q14–Q19: MultipleChoice (6 items)
    for slot in SECTION_2_SLOTS[:6]:
        assert slot["questionType"] == "MultipleChoice"
        assert slot["type"] == "MultipleChoice"

    # Q20–Q26: SummaryCompletion (7 items)
    for slot in SECTION_2_SLOTS[6:]:
        assert slot["questionType"] == "SummaryCompletion"
        assert slot["type"] == "SummaryCompletion"


def test_section_3_slot_numbering_and_yes_no_not_given_types():
    """Section 3 specifies exactly 14 items: Q27-Q33 YesNoNotGiven and Q34-Q40 ShortAnswer."""
    assert len(SECTION_3_SLOTS) == 14
    assert SECTION_3_SLOTS[0]["number"] == 27
    assert SECTION_3_SLOTS[-1]["number"] == 40

    # Q27–Q33: Strictly YesNoNotGiven (7 items) — never TrueFalseNotGiven
    for slot in SECTION_3_SLOTS[:7]:
        assert slot["questionType"] == "YesNoNotGiven"
        assert slot["type"] == "YesNoNotGiven"

    # Q34–Q40: ShortAnswer (7 items)
    for slot in SECTION_3_SLOTS[7:]:
        assert slot["questionType"] == "ShortAnswer"
        assert slot["type"] == "ShortAnswer"


# ─── 7. Continuation Request Builders ─────────────────────────────────────────

def test_continuation_request_builders_structure():
    """build_questions_request and build_section_assembly_request generate valid payloads with envelope bindings."""
    p2_env = get_verified_passage_envelope(section_index=2, version=2)
    bp_ref = {"artifactId": "bp_sec_2_a39ea79c", "artifactType": "ExamBlueprint", "version": 1, "contentHash": SECTION_2_BLUEPRINT_V1_HASH}
    p_ref = {"artifactId": "art_passage_s2", "artifactType": "Passage", "version": 2, "contentHash": SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH}

    q_req = build_questions_request(
        run_id="run_test_cont",
        lease_owner="11111111-1111-1111-1111-111111111111",
        epoch=1,
        section_index=2,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        slots=SECTION_2_SLOTS,
        passage_envelope=p2_env,
    )

    assert q_req["runId"] == "run_test_cont"
    assert q_req["sectionIndex"] == 2
    assert q_req["engine"] == "v2"
    assert q_req["passageRef"] == p_ref
    assert len(q_req["slots"]) == 13
    assert q_req["passageEnvelope"]["contentHash"] == SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH

    sec_req = build_section_assembly_request(
        run_id="run_test_cont",
        lease_owner="11111111-1111-1111-1111-111111111111",
        epoch=1,
        section_index=2,
        title="Marine Ecosystems and Global Climate Change",
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        question_refs=[],
        passage_envelope=p2_env,
    )
    assert sec_req["title"] == "Marine Ecosystems and Global Climate Change"
    assert sec_req["passageEnvelope"]["version"] == 2
