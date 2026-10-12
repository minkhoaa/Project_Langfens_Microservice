"""R04 — Authoritative V2 passage path checkpoints through authenticated .NET boundary into PostgreSQL.

Validates exact accepted references, real CAS, stale-epoch/cancel rejection,
crash before commit, crash after commit before acknowledgement (lost ACK),
idempotent replay, and accepted-passage resume with zero regeneration.

Deterministic fault injection uses FakePassageProvider for protocol and durability
verification only, not as live model quality evidence.
"""

from __future__ import annotations

import hashlib
import json
from uuid import UUID, uuid4

import httpx
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.loop import DecisionType, LoopReason
from app.facade import GenerationFacade
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.generators.passage.prompts import PassageStyleProfile
from app.loop.passage import PassageLoop
from app.persistence.client import CheckpointApiError, CheckpointClient
from app.persistence.models import (
    CheckpointCommitRequest,
    OperationGrantRequest,
)
from app.providers.gateway import ProviderGateway
from app.providers.registry import ProviderRegistry
from tests.test_t08_passage_loop import FakePassageProvider, _generate_academic_passage
from tests.test_t09_real_postgres_durability import (
    REAL_API_KEY,
    REAL_SERVICE_URL,
    is_docker_postgres_available,
    is_service_available,
    run_psql,
    seed_real_job_and_run,
)


pytestmark = [
    pytest.mark.skipif(not is_service_available(), reason="exam-service live process not reachable on port 5099"),
    pytest.mark.skipif(not is_docker_postgres_available(), reason="docker exam-database not running"),
]


def _ref_key(ref: ArtifactRef) -> tuple[str, str, int, str]:
    return (ref.artifact_id, ref.artifact_type.value, ref.version, ref.content_hash)


def _seed_passage_parents(client: CheckpointClient, run_id: str, owner_id: UUID, epoch: int = 1):
    """Seed real ExamBlueprint and EvidenceGraph dependencies through authenticated .NET boundary."""
    source_facts = (
        "Archaeological excavations at the Neolithic settlement revealed stone masonry structures, "
        "domestic pottery artifacts, and evidence of early agricultural cultivation dating back six millennia. "
        "Analysis of charred seed remains indicated systematic harvesting of emmer wheat and barley."
    )
    base_text = _generate_academic_passage(800, num_paragraphs=5)
    paragraphs = base_text.split("\n\n")
    paragraphs[0] = source_facts + " " + paragraphs[0]
    paragraphs[-1] = source_facts + " " + paragraphs[-1]
    valid_passage = "\n\n".join(paragraphs)

    blueprint = ArtifactEnvelope.create(
        artifact_id=f"art_blueprint_{run_id[:8]}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload={"title": "R04 PostgreSQL durability fixture", "sections": [{"sectionIndex": 1}]},
        run_id=run_id,
        producer_version="2.0.0",
    )
    evidence_graph = ArtifactEnvelope.create(
        artifact_id=f"art_evidence_graph_{run_id[:8]}",
        artifact_type=ArtifactType.EVIDENCE_GRAPH,
        version=1,
        payload={"sourceFacts": source_facts, "claimCount": 6},
        run_id=run_id,
        producer_version="2.0.0",
    )

    for artifact in (blueprint, evidence_graph):
        op_id = f"op_seed_{artifact.artifact_id}_{uuid4().hex[:6]}"
        client.grant_operation(OperationGrantRequest(
            runId=run_id,
            epoch=epoch,
            leaseOwner=owner_id,
            operationId=op_id,
            operationType="CHECKPOINT_COMMIT",
            requestHash=artifact.content_hash,
            tokenReservation=0,
            wallTimeReservationSeconds=0,
        ))
        client.commit_checkpoint(CheckpointCommitRequest(
            runId=run_id,
            epoch=epoch,
            leaseOwner=owner_id,
            operationId=op_id,
            requestHash=artifact.content_hash,
            artifact=artifact,
            evaluations=[],
        ))

    context = PassageGenerationContext(
        blueprintRef=blueprint.to_ref(),
        evidenceGraphRef=evidence_graph.to_ref(),
        sectionIndex=1,
        topic="Neolithic Archaeology",
        sourceText=source_facts,
        styleProfile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
    )
    provider = FakePassageProvider(passage_text=valid_passage, title="Neolithic Archaeology")
    return blueprint, evidence_graph, context, provider


def _make_facade(client: CheckpointClient, provider: FakePassageProvider) -> GenerationFacade:
    reg = ProviderRegistry()
    reg.register_provider(provider, keys=["test-only-r04-key-00000000"])
    gateway = ProviderGateway(registry=reg, checkpoint_client=client)
    return GenerationFacade(gateway=gateway, persistence_client=client)


@pytest.mark.asyncio
async def test_r04_exact_accepted_references_and_stale_dependency_rejection():
    """Verify exact accepted references in PostgreSQL and fail-closed rejection on missing/stale dependencies."""
    owner_id = uuid4()
    run_id = f"run_r04_refs_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    blueprint, evidence_graph, context, provider = _seed_passage_parents(client, run_id, owner_id)
    facade = _make_facade(client, provider)

    # 1. Successful execution through facade into real PostgreSQL
    res = await facade.generate_passage_v2(
        passage_context=context,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res.decision == DecisionType.PASS
    assert res.accepted_artifact is not None
    passage_art = res.accepted_artifact
    assert passage_art.artifact_type == ArtifactType.PASSAGE
    assert 720 <= passage_art.payload["wordCount"] <= 915

    # 2. Verify exact parent references in PostgreSQL
    passage_id = "art_passage_s1"
    persisted_parent_rows = run_psql(
        f"""SELECT "ParentArtifactId" || ':' || "ParentVersion"::text
        FROM reading_paper_artifact_dependencies WHERE "RunId" = '{run_id}' AND "ArtifactId" = '{passage_id}'
        ORDER BY "ParentArtifactId" """
    ).splitlines()
    assert set(persisted_parent_rows) == {
        f"{blueprint.artifact_id}:1",
        f"{evidence_graph.artifact_id}:1",
    }
    assert {_ref_key(ref) for ref in passage_art.parent_refs} == {
        _ref_key(blueprint.to_ref()),
        _ref_key(evidence_graph.to_ref()),
    }

    # 3. Verify PostgreSQL head, evaluations, and decisions
    persisted_head = run_psql(
        f"""SELECT "AcceptedVersion"::text || ':' || "AcceptedHash"
        FROM reading_paper_artifact_heads WHERE "RunId" = '{run_id}' AND "ArtifactId" = '{passage_id}'"""
    )
    assert persisted_head == f"1:{passage_art.content_hash}"

    db_eval_count = int(run_psql(
        f"SELECT COUNT(*) FROM reading_paper_evaluations WHERE \"RunId\" = '{run_id}'"
    ))
    assert db_eval_count > 0

    db_decisions = run_psql(
        f"SELECT \"Decision\" FROM reading_paper_decisions WHERE \"RunId\" = '{run_id}'"
    )
    assert "PASS" in db_decisions.split()

    # 4. Stale dependency rejection on a run missing required upstream artifacts
    unseeded_run_id = f"run_r04_unseeded_{uuid4().hex[:10]}"
    seed_real_job_and_run(unseeded_run_id, owner_id)
    unseeded_ctx = PassageGenerationContext(
        blueprintRef=ArtifactRef(
            artifactId=f"art_blueprint_missing_{unseeded_run_id[:8]}",
            artifactType=ArtifactType.EXAM_BLUEPRINT,
            version=1,
            contentHash=blueprint.content_hash,
        ),
        evidenceGraphRef=evidence_graph.to_ref(),
        sectionIndex=1,
        topic="Neolithic Archaeology",
        sourceText="Archaeological excavations at the Neolithic settlement revealed stone masonry structures.",
        styleProfile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
    )
    generator = PassageGenerator(gateway=facade.gateway)
    loop_missing = PassageLoop(generator=generator, persistence_client=client)
    res_stale = await loop_missing.run(
        passage_context=unseeded_ctx,
        run_id=unseeded_run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_stale.decision == DecisionType.FAIL
    assert res_stale.terminal_reason_code == LoopReason.STALE_DEPENDENCY
    assert provider.call_count == 1, "Must not invoke provider when dependencies are stale/uncommitted"


@pytest.mark.asyncio
async def test_r04_real_cas_conflict_rejection():
    """Verify that committing a passage with wrong expectedHeadVersion is rejected with HTTP 409 and does not overwrite head."""
    owner_id = uuid4()
    run_id = f"run_r04_cas_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    blueprint, _, _, _ = _seed_passage_parents(client, run_id, owner_id)

    # Initial head version is 1 for blueprint
    current_head = run_psql(
        f"SELECT \"AcceptedVersion\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}' AND \"ArtifactId\" = '{blueprint.artifact_id}'"
    )
    assert current_head == "1"

    # Attempt commit with expectedHeadVersion=0 (wrong version, expecting no prior head)
    conflict_artifact = ArtifactEnvelope.create(
        artifact_id=blueprint.artifact_id,
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=2,
        payload={"title": "CAS conflict candidate"},
        run_id=run_id,
        producer_version="2.0.0",
    )
    cas_operation = f"r04_cas_{uuid4().hex[:8]}"
    client.grant_operation(OperationGrantRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=owner_id,
        operationId=cas_operation,
        operationType="CHECKPOINT_COMMIT",
        requestHash=conflict_artifact.content_hash,
        tokenReservation=0,
        wallTimeReservationSeconds=0,
    ))

    with pytest.raises(CheckpointApiError) as exc_info:
        client.commit_checkpoint(CheckpointCommitRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=owner_id,
            operationId=cas_operation,
            requestHash=conflict_artifact.content_hash,
            artifact=conflict_artifact,
            evaluations=[],
            expectedHeadVersion=0,
        ))
    assert exc_info.value.status_code == 409

    # Verify head was not modified in PostgreSQL
    head_after_conflict = run_psql(
        f"SELECT \"AcceptedVersion\" FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}' AND \"ArtifactId\" = '{blueprint.artifact_id}'"
    )
    assert head_after_conflict == "1"


@pytest.mark.asyncio
async def test_r04_stale_epoch_fencing_rejection():
    """Verify that operations from a stale epoch or mismatched lease owner are rejected with HTTP 409."""
    owner_id = uuid4()
    run_id = f"run_r04_epoch_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id, epoch=2)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    # Attempt operation with epoch=1 (stale, active is 2)
    with pytest.raises(CheckpointApiError) as exc_stale:
        client.grant_operation(OperationGrantRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=owner_id,
            operationId=f"r04_stale_{uuid4().hex[:8]}",
            operationType="PROVIDER_CALL",
            requestHash=hashlib.sha256(b"stale-epoch").hexdigest(),
            tokenReservation=100,
            wallTimeReservationSeconds=5.0,
        ))
    assert exc_stale.value.status_code == 409

    # Attempt operation with wrong lease owner
    wrong_owner = uuid4()
    with pytest.raises(CheckpointApiError) as exc_owner:
        client.grant_operation(OperationGrantRequest(
            runId=run_id,
            epoch=2,
            leaseOwner=wrong_owner,
            operationId=f"r04_wrong_owner_{uuid4().hex[:8]}",
            operationType="PROVIDER_CALL",
            requestHash=hashlib.sha256(b"wrong-owner").hexdigest(),
            tokenReservation=100,
            wallTimeReservationSeconds=5.0,
        ))
    assert exc_owner.value.status_code == 409


@pytest.mark.asyncio
async def test_r04_cancelled_job_run_rejection():
    """Verify that operations on a cancelled job/run fail closed with HTTP 409."""
    owner_id = uuid4()
    run_id = f"run_r04_cancel_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

    run_psql(
        f"""UPDATE reading_paper_jobs SET "Status" = 'Cancelled', "CancelVersion" = 1 WHERE "ActiveRunId" = '{run_id}';
        UPDATE reading_paper_runs SET "Status" = 'CANCELLED', "CancelVersion" = 1 WHERE "RunId" = '{run_id}';"""
    )

    with pytest.raises(CheckpointApiError) as exc_cancel:
        client.grant_operation(OperationGrantRequest(
            runId=run_id,
            epoch=1,
            leaseOwner=owner_id,
            operationId=f"r04_cancel_grant_{uuid4().hex[:8]}",
            operationType="PROVIDER_CALL",
            requestHash=hashlib.sha256(b"cancel-check").hexdigest(),
            tokenReservation=50,
            wallTimeReservationSeconds=2.0,
        ))
    assert exc_cancel.value.status_code == 409


@pytest.mark.asyncio
async def test_r04_crash_before_commit_draft_only_no_accepted_head():
    """Verify fault injection before commit: draft may be durable but no accepted head exists in PostgreSQL."""
    owner_id = uuid4()
    run_id = f"run_r04_precommit_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    _, _, context, provider = _seed_passage_parents(client, run_id, owner_id)

    class BeforeCommitFaultClient(CheckpointClient):
        def __init__(self):
            super().__init__(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)

        def commit_checkpoint(self, request):
            if request.artifact.artifact_type == ArtifactType.PASSAGE:
                raise CheckpointApiError(503, "Injected fault before passage commit POST")
            return super().commit_checkpoint(request)

    fault_client = BeforeCommitFaultClient()
    facade = _make_facade(fault_client, provider)

    with pytest.raises(CheckpointApiError) as exc_fault:
        await facade.generate_passage_v2(
            passage_context=context,
            run_id=run_id,
            lease_owner=owner_id,
            epoch=1,
        )
    assert exc_fault.value.status_code == 503
    assert provider.call_count == 1

    # Verify that NO accepted head exists in PostgreSQL
    head_count = run_psql(
        f"SELECT COUNT(*) FROM reading_paper_artifact_heads WHERE \"RunId\" = '{run_id}' AND \"ArtifactId\" = 'art_passage_s1'"
    )
    assert head_count == "0"

    # Verify resume state has no accepted passage head
    state_after_fault = client.resume_state(run_id)
    assert not any(
        item.artifactId == "art_passage_s1" and not item.isStale
        for item in state_after_fault.artifacts
    )

    # Draft envelope was persisted before commit; it must not be an accepted head
    draft_count = run_psql(
        f"SELECT COUNT(*) FROM reading_paper_artifacts WHERE \"RunId\" = '{run_id}' AND \"ArtifactId\" = 'art_passage_s1'"
    )
    assert draft_count == "1"


@pytest.mark.asyncio
async def test_r04_crash_after_commit_lost_ack_and_idempotent_replay(monkeypatch):
    """Verify lost ACK after commit: PostgreSQL commits head, replay is idempotent with isReplay=True and zero extra ops."""
    owner_id = uuid4()
    run_id = f"run_r04_lostack_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    blueprint, evidence_graph, context, provider = _seed_passage_parents(client, run_id, owner_id)
    facade = _make_facade(client, provider)

    original_post = httpx.Client.post
    dropped_commit_payload = {}

    def drop_commit_ack(http_client, url, *args, **kwargs):
        response = original_post(http_client, url, *args, **kwargs)
        payload = kwargs.get("json")
        artifact_payload = payload.get("artifact", {}) if isinstance(payload, dict) else {}
        if (
            str(url).endswith("/commit")
            and payload.get("runId") == run_id
            and artifact_payload.get("artifactType") == ArtifactType.PASSAGE.value
        ):
            assert response.status_code == 200
            dropped_commit_payload.update(payload)
            request = response.request
            response.close()
            raise httpx.ReadError("Injected lost response before CheckpointClient receives the ACK", request=request)
        return response

    monkeypatch.setattr(httpx.Client, "post", drop_commit_ack)
    with pytest.raises(httpx.ReadError, match="before CheckpointClient receives the ACK"):
        await facade.generate_passage_v2(
            passage_context=context,
            run_id=run_id,
            lease_owner=owner_id,
            epoch=1,
        )
    monkeypatch.undo()

    assert dropped_commit_payload
    lost_request = CheckpointCommitRequest.model_validate(dropped_commit_payload)
    passage_id = "art_passage_s1"

    # PostgreSQL already accepted the head despite lost ACK
    persisted_head = run_psql(
        f"""SELECT "AcceptedVersion"::text || ':' || "AcceptedHash"
        FROM reading_paper_artifact_heads WHERE "RunId" = '{run_id}' AND "ArtifactId" = '{passage_id}'"""
    )
    assert persisted_head == f"1:{lost_request.artifact.content_hash}"

    # Idempotent replay of the commit
    ops_before_replay = int(run_psql(
        f"SELECT COUNT(*) FROM reading_paper_operations WHERE \"RunId\" = '{run_id}'"
    ))
    replay_ack = client.commit_checkpoint(lost_request)
    assert replay_ack.isReplay is True
    assert (replay_ack.artifactId, replay_ack.version, replay_ack.contentHash) == (
        lost_request.artifact.artifact_id,
        lost_request.artifact.version,
        lost_request.artifact.content_hash,
    )
    ops_after_replay = int(run_psql(
        f"SELECT COUNT(*) FROM reading_paper_operations WHERE \"RunId\" = '{run_id}'"
    ))
    assert ops_after_replay == ops_before_replay, "Idempotent replay must not create duplicate operation rows"


@pytest.mark.asyncio
async def test_r04_accepted_passage_resume_zero_regeneration():
    """Verify that resuming a run with an accepted PostgreSQL passage executes zero provider calls."""
    owner_id = uuid4()
    run_id = f"run_r04_resume_{uuid4().hex[:10]}"
    seed_real_job_and_run(run_id, owner_id)
    client = CheckpointClient(base_url=REAL_SERVICE_URL, internal_api_key=REAL_API_KEY)
    _, _, context, provider = _seed_passage_parents(client, run_id, owner_id)
    facade = _make_facade(client, provider)

    # 1. Initial generation
    res_initial = await facade.generate_passage_v2(
        passage_context=context,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_initial.decision == DecisionType.PASS
    assert res_initial.accepted_artifact is not None
    assert provider.call_count == 1

    # 2. Resumed generation with identical run_id and matching fresh dependencies
    res_resumed = await facade.generate_passage_v2(
        passage_context=context,
        run_id=run_id,
        lease_owner=owner_id,
        epoch=1,
    )
    assert res_resumed.decision == DecisionType.PASS
    assert res_resumed.accepted_artifact is not None
    assert res_resumed.accepted_artifact.to_ref() == res_initial.accepted_artifact.to_ref()
    assert provider.call_count == 1, "An accepted PostgreSQL passage must resume without any new provider calls!"
    assert res_resumed.calls_count == 0, "Resumed loop result must reflect 0 calls consumed"
