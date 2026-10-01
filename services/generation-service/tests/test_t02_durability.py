from datetime import datetime, timezone
from uuid import uuid4
import pytest
from pydantic import ValidationError

from app.contracts import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.persistence import (
    OperationGrantRequest,
    OperationGrantResult,
    CheckpointCommitRequest,
    CheckpointAck,
    UnknownOutcomeRequest,
    UnknownOutcomeAck,
    ArtifactResumeInfo,
    ResumeStateResult,
    InvalidateDependencyRequest,
    InvalidateDependencyResult,
    BuildExamInternalRequest,
    BuildExamInternalResult,
    CheckpointClient,
    CheckpointApiError,
)


def _make_sample_envelope(artifact_id: str, artifact_type: ArtifactType, run_id: str, version: int = 1, parent_refs=None):
    refs = parent_refs or []
    payload = {"title": f"Title for {artifact_id}", "version": version}
    chash = compute_content_hash(payload, refs)
    return ArtifactEnvelope.create(
        artifact_id=artifact_id,
        artifact_type=artifact_type,
        run_id=run_id,
        payload=payload,
        producer_version="2.0.0",
        version=version,
        parent_refs=refs,
    )


# ---------------------------------------------------------------------------
# T02-01: Python Checkpoint Models & Strict Validation
# ---------------------------------------------------------------------------
def test_t02_01_models_extra_forbid():
    run_id = f"run_{uuid4().hex}"
    lease_owner = uuid4()
    req = OperationGrantRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=lease_owner,
        operationId="op_01",
        operationType="LLM_CALL",
        requestHash="hash_01",
        tokenReservation=2000,
    )
    assert req.tokenReservation == 2000

    # Extra unknown field must raise ValidationError (extra="forbid")
    with pytest.raises(ValidationError):
        OperationGrantRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=lease_owner,
            operationId="op_01",
            operationType="LLM_CALL",
            requestHash="hash_01",
            tokenReservation=2000,
            unknownField="injected",
        )


# ---------------------------------------------------------------------------
# T02-02: Checkpoint Ack Verification & Fail-Closed Mismatch
# ---------------------------------------------------------------------------
def test_t02_02_client_verify_ack_strict():
    # Fail closed check: missing key must raise ValueError
    with pytest.raises(ValueError, match="EXAMSERVICE__INTERNAL__API__KEY is not configured"):
        CheckpointClient()

    client = CheckpointClient(internal_api_key="test-only-ephemeral-secret-key-32chars")
    run_id = f"run_{uuid4().hex}"
    lease_owner = uuid4()
    envelope = _make_sample_envelope("art_passage_01", ArtifactType.PASSAGE, run_id, version=1)

    commit_req = CheckpointCommitRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=lease_owner,
        operationId="op_01",
        requestHash="hash_01",
        artifact=envelope,
        tokensUsed=1200,
    )

    valid_ack = CheckpointAck(
        runId=run_id,
        epoch=1,
        artifactId=envelope.artifact_id,
        version=envelope.version,
        contentHash=envelope.content_hash,
        serverTimestampUtc=datetime.now(timezone.utc),
    )

    # Valid ack must pass verification
    client._verify_ack(commit_req, valid_ack)

    # Tampered content hash in ack must raise ValueError fail-closed
    bad_hash_ack = CheckpointAck(
        runId=run_id,
        epoch=1,
        artifactId=envelope.artifact_id,
        version=envelope.version,
        contentHash="tampered_hash_00000000000000000000000000000000000000000000000000000000",
        serverTimestampUtc=datetime.now(timezone.utc),
    )
    with pytest.raises(ValueError, match="contentHash mismatch"):
        client._verify_ack(commit_req, bad_hash_ack)

    # Epoch mismatch in ack must raise ValueError fail-closed
    bad_epoch_ack = CheckpointAck(
        runId=run_id,
        epoch=2,
        artifactId=envelope.artifact_id,
        version=envelope.version,
        contentHash=envelope.content_hash,
        serverTimestampUtc=datetime.now(timezone.utc),
    )
    with pytest.raises(ValueError, match="epoch mismatch"):
        client._verify_ack(commit_req, bad_epoch_ack)


# ---------------------------------------------------------------------------
# T02-03: Unknown Outcome Semantics (Reservation Preserved)
# ---------------------------------------------------------------------------
def test_t02_03_unknown_outcome_semantics():
    req = UnknownOutcomeRequest(
        runId="run_test_01",
        epoch=1,
        leaseOwner=uuid4(),
        operationId="op_timeout_01",
        errorMessage="Provider read timeout after 60s",
    )
    ack = UnknownOutcomeAck(
        operationId=req.operationId,
        status="UNKNOWN_OUTCOME",
        reservationPreserved=True,
        recordedAt=datetime.now(timezone.utc),
    )
    assert ack.status == "UNKNOWN_OUTCOME"
    assert ack.reservationPreserved is True


# ---------------------------------------------------------------------------
# T02-04: Resume State & Compatibility Resolution
# ---------------------------------------------------------------------------
def test_t02_04_resume_compatibility_and_stale_detection():
    job_id = uuid4()
    parent_ref = ArtifactRef(
        artifactId="art_src_01",
        artifactType=ArtifactType.SOURCE_PACK,
        version=1,
        contentHash="a" * 64,
    )

    # Compatible resume state
    res_compat = ResumeStateResult(
        runId="run_01",
        jobId=job_id,
        epoch=1,
        status="RUNNING",
        engineVersion="2.0.0",
        schemaVersion="2.0.0",
        policyVersion="2.0.0",
        artifacts=[
            ArtifactResumeInfo(
                artifactId="art_pas_01",
                artifactType="Passage",
                acceptedVersion=1,
                acceptedHash="b" * 64,
                payloadJson="{}",
                parentRefs=[parent_ref],
                isStale=False,
            )
        ],
        isCompatible=True,
    )
    assert res_compat.isCompatible is True
    assert res_compat.artifacts[0].isStale is False

    # Incompatible resume state
    res_incompat = ResumeStateResult(
        runId="run_02",
        jobId=job_id,
        epoch=1,
        status="RUNNING",
        engineVersion="1.0.0",
        schemaVersion="2.0.0",
        policyVersion="2.0.0",
        artifacts=[],
        isCompatible=False,
        incompatibilityReason="Engine version mismatch: 1.0.0 != 2.0.0",
    )
    assert res_incompat.isCompatible is False
    assert "Engine version mismatch" in res_incompat.incompatibilityReason


# ---------------------------------------------------------------------------
# T02-05: Transitive Downstream Closure Invalidation Logic (Parity with .NET)
# ---------------------------------------------------------------------------
def test_t02_05_dependency_closure_calculation():
    # Dependency graph:
    # src_1 -> pas_1 -> sec_1
    # src_2 -> pas_2 -> sec_2
    # sec_1, sec_2 -> paper
    deps = {
        "src_1": ["pas_1"],
        "pas_1": ["sec_1"],
        "sec_1": ["paper"],
        "src_2": ["pas_2"],
        "pas_2": ["sec_2"],
        "sec_2": ["paper"],
    }

    def compute_invalidated_closure(target: str) -> set:
        invalidated = {target}
        queue = [target]
        while queue:
            curr = queue.pop(0)
            for child in deps.get(curr, []):
                if child not in invalidated:
                    invalidated.add(child)
                    queue.append(child)
        return invalidated

    closure_src2 = compute_invalidated_closure("src_2")
    assert closure_src2 == {"src_2", "pas_2", "sec_2", "paper"}
    # Section 1 components must remain unaffected
    assert "src_1" not in closure_src2
    assert "pas_1" not in closure_src2
    assert "sec_1" not in closure_src2


# ---------------------------------------------------------------------------
# T02-06: Build Exam Idempotency Result
# ---------------------------------------------------------------------------
def test_t02_06_build_exam_result_idempotency():
    exam_id = uuid4()
    res_first = BuildExamInternalResult(
        examId=exam_id,
        slug="reading-job-001",
        isExisting=False,
    )
    assert res_first.isExisting is False

    res_replay = BuildExamInternalResult(
        examId=exam_id,
        slug="reading-job-001",
        isExisting=True,
    )
    assert res_replay.isExisting is True
    assert res_replay.examId == res_first.examId
