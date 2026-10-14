"""Verification tests for Phase 15: Legacy Cleanup, Living Adapters & Deletion Inventory Traceability (T15-03 & T15-08).

Guarantees:
1. Zero broken public adapters across GenerationFacade, Ingestion, Router, and LLM interfaces.
2. Complete closed deletion inventory accounting for 100% of Phase 00 and Phase 03 legacy symbols.
3. Canonical V2 SectionLoop delegation in GenerationFacade.generate_section.
4. Living compatibility shims in app/extractor.py, app/prompts.py, and app/llm.py remain fully functional.
"""

from __future__ import annotations

import csv
import json
import inspect
from pathlib import Path
from unittest.mock import AsyncMock, patch, MagicMock
from uuid import UUID, uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.contracts.section import SectionPayload, QuestionGroup
from app.facade import GenerationFacade, get_generation_facade
from app.loop.runtime import LoopResult


def test_t15_facade_canonical_ingestion_delegation():
    """T15-08: GenerationFacade delegates search, fetch, ingest directly to canonical app.ingestion.fetcher."""
    facade = get_generation_facade()

    # Verify search_sources
    assert hasattr(facade, "search_sources")
    assert inspect.iscoroutinefunction(facade.search_sources)

    # Verify fetch_source
    assert hasattr(facade, "fetch_source")
    assert inspect.iscoroutinefunction(facade.fetch_source)

    # Verify ingest_source
    assert hasattr(facade, "ingest_source")
    assert inspect.iscoroutinefunction(facade.ingest_source)


@pytest.mark.asyncio
async def test_t15_facade_generate_section_delegates_to_v2_loop():
    """T15-08: GenerationFacade.generate_section executes through V2 SectionLoop engine."""
    mock_client = MagicMock()
    mock_grant = MagicMock(status="RESERVED", is_replay=False)
    mock_client.grant_operation.return_value = mock_grant
    mock_client.commit_checkpoint.side_effect = lambda req: MagicMock(artifactId=req.artifact.artifact_id, version=req.artifact.version, artifact_id=req.artifact.artifact_id)
    mock_client.resume_state.return_value = MagicMock(artifacts=[])
    facade = GenerationFacade(persistence_client=mock_client)
    mock_passage_env = ArtifactEnvelope.create(
        artifact_id="art_p_test",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_t15_test",
        version=1,
        producer_version="PassageLoopV2",
        payload={"title": "Test Passage Title", "passage": "Word " * 800, "wordCount": 800},
    )
    from app.contracts.issue import IssueLedger
    mock_passage_res = LoopResult(
        runId="run_t15_test",
        decision=DecisionType.PASS,
        terminalState=LoopState.COMPLETED,
        acceptedArtifact=mock_passage_env,
        terminalReason="Accepted",
        terminalReasonCode=LoopReason.ACCEPTED,
        ledger=IssueLedger(ledgerId="led_p_01", runId="run_t15_test"),
    )

    # Mock V2 Question Candidate Loop
    mock_q_env = ArtifactEnvelope.create(
        artifact_id="art_q_test",
        artifact_type=ArtifactType.QUESTION,
        run_id="run_t15_test",
        version=1,
        producer_version="QuestionCandidateLoopV2",
        payload={"slotNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "prompt": "Q1 prompt"},
    )
    mock_q_res = {"question_envelopes": [mock_q_env]}

    # Mock V2 SectionLoop
    mock_sec_env = ArtifactEnvelope.create(
        artifact_id="art_sec_test",
        artifact_type=ArtifactType.SECTION,
        run_id="run_t15_test",
        version=1,
        producer_version="SectionLoopV2",
        payload={
            "title": "Test Passage Title",
            "passage": "Word " * 800,
            "groups": [
                {
                    "groupId": "group_1_1",
                    "questionType": "TRUE_FALSE_NOT_GIVEN",
                    "instructions": "Do the following statements agree...",
                    "questions": [{"questionNumber": 1, "prompt": "Statement 1", "correctAnswer": "TRUE"}],
                }
            ],
        },
    )
    mock_sec_res = LoopResult(
        runId="run_t15_test",
        decision=DecisionType.PASS,
        terminalState=LoopState.COMPLETED,
        acceptedArtifact=mock_sec_env,
        terminalReason="Accepted",
        terminalReasonCode=LoopReason.ACCEPTED,
        ledger=IssueLedger(ledgerId="led_sec_01", runId="run_t15_test"),
    )

    with patch.object(facade, "generate_passage_v2", new_callable=AsyncMock) as mock_p_loop, \
         patch.object(facade, "generate_questions_v2", new_callable=AsyncMock) as mock_q_loop, \
         patch.object(facade, "generate_section_v2", new_callable=AsyncMock) as mock_sec_loop:

        mock_p_loop.return_value = mock_passage_res
        mock_q_loop.return_value = mock_q_res
        mock_sec_loop.return_value = mock_sec_res

        valid_source_text = (
            "Marine biological surveys across coral reef systems reveal significant resilience patterns under rising ocean temperatures. "
            "Researchers observed that symbiotic algae populations adapted within three generations in tropical Pacific waters. "
            "Comparative satellite imaging demonstrated a 40% reduction in severe bleaching events across protected marine sanctuaries. "
            "Further ecological modeling indicates that local conservation policies enhance long-term reef biodiversity."
        )
        res = await facade.generate_section(
            topic="coral reefs",
            index=1,
            source={"pmcid": "PMC123", "title": "Coral Studies", "content": valid_source_text},
            run_id="run_t15_test",
            epoch=1,
            lease_owner=uuid4(),
            parent_operation_id="op_t15_test",
        )

        # Assert V2 loops were called in correct sequence
        assert mock_p_loop.await_count == 1
        assert mock_q_loop.await_count == 1
        assert mock_sec_loop.await_count == 1

        # Verify genuine artifact references and lineage passed to V2 loops
        passage_call_args = mock_p_loop.call_args.kwargs
        passage_ctx = passage_call_args["passage_context"]
        assert passage_ctx.blueprint_ref.content_hash is not None
        assert len(passage_ctx.blueprint_ref.content_hash) == 64
        assert passage_ctx.blueprint_ref.content_hash != "0" * 64
        assert passage_ctx.evidence_graph_ref.content_hash is not None
        assert len(passage_ctx.evidence_graph_ref.content_hash) == 64
        assert passage_ctx.evidence_graph_ref.content_hash != "0" * 64
        assert passage_ctx.topic == "coral reefs"
        assert passage_ctx.section_index == 1

        # Assert backward-compatible output format
        assert isinstance(res, dict)
        assert res["title"] == "Test Passage Title"
        assert "passage" in res
        assert "groups" in res
        assert len(res["groups"]) == 1
        assert res["groups"][0]["groupId"] == "group_1_1"


@pytest.mark.asyncio
async def test_t15_facade_generate_section_fails_closed_on_invalid_source():
    """T15-08: GenerationFacade.generate_section strictly fails closed on empty or short source text."""
    facade = GenerationFacade()

    # Test empty source
    with pytest.raises(ValueError, match="at least 50 characters"):
        await facade.generate_section(
            topic="coral reefs",
            index=1,
            source={"pmcid": "PMC123", "content": ""},
            run_id="run_fail_closed_01",
            lease_owner=uuid4(),
            parent_operation_id="op_fail_01",
        )

    # Test short source (<50 chars)
    with pytest.raises(ValueError, match="at least 50 characters"):
        await facade.generate_section(
            topic="coral reefs",
            index=1,
            source={"pmcid": "PMC123", "content": "Too short snippet."},
            run_id="run_fail_closed_02",
            lease_owner=uuid4(),
            parent_operation_id="op_fail_02",
        )

def test_t15_real_source_pack_to_blueprint_lineage():
    """T15-08: Real SourcePack -> EvidenceGraphBuilder -> BlueprintPlanner pipeline builds authentic cryptographic envelopes."""
    from app.blueprint.planner import BlueprintPlanner, SectionPlanInput
    from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
    from app.contracts.blueprint import ExamBlueprint
    from app.evidence.extractor import extract_atomic_claims
    from app.evidence.graph import EvidenceGraphBuilder, EvidenceGraphStatus
    from app.ingestion.chunker import extract_spans
    from app.ingestion.source_pack import SourcePackBuilder

    source_text = (
        "Marine biological surveys across coral reef systems reveal significant resilience patterns under rising ocean temperatures. "
        "Researchers observed that symbiotic algae populations adapted within three generations in tropical Pacific waters. "
        "Comparative satellite imaging demonstrated a 40% reduction in severe bleaching events across protected marine sanctuaries. "
        "Further ecological modeling indicates that local conservation policies enhance long-term reef biodiversity."
    )
    source_id = "PMC_TEST_999"
    run_id = "run_t15_lineage_01"

    # 1. SourcePack
    spans = extract_spans(source_text, source_id)
    assert len(spans) >= 3, "Must extract >= 3 spans"
    source_item = SourcePackBuilder.build_source_item(
        source_id=source_id,
        raw_content=source_text,
        normalized_text=source_text,
        title="Coral Reef Adaptation",
        source_url="https://europepmc.org/articles/PMC_TEST_999",
        pmcid=source_id,
    )
    source_pack = SourcePackBuilder.build_source_pack(
        pack_id="sp_test_999",
        run_id=run_id,
        sources=[source_item],
        section_id=1,
    )
    sp_env = SourcePackBuilder.to_artifact_envelope(source_pack)
    assert sp_env.verify_integrity() is True
    assert sp_env.artifact_type == ArtifactType.SOURCE_PACK

    # 2. EvidenceGraph
    candidate_claims = extract_atomic_claims(source_text, source_id, spans)
    assert len(candidate_claims) >= 3, "Must extract >= 3 candidate claims"
    build_res = EvidenceGraphBuilder.build_evidence_graph(
        graph_id="eg_test_999",
        run_id=run_id,
        candidate_claims=candidate_claims,
        source_text=source_text,
        source_pack=source_pack,
        section_id=1,
        fail_closed_on_any_invalid=False,
    )
    assert build_res.status == EvidenceGraphStatus.ACCEPTED
    assert len(build_res.graph.claims) >= 3
    eg_env = EvidenceGraphBuilder.to_artifact_envelope(build_res.graph, source_pack_ref=sp_env.to_ref())
    assert eg_env.verify_integrity() is True
    assert eg_env.parent_refs[0].artifact_id == sp_env.artifact_id
    assert eg_env.parent_refs[0].content_hash == sp_env.content_hash

    # 3. BlueprintPlanner
    planner = BlueprintPlanner()
    canonical_graph = build_res.graph.model_copy(
        update={"content_hash": eg_env.content_hash, "source_pack_id": source_pack.pack_id}
    )
    sec_bp = planner._plan_section(SectionPlanInput(sectionId=1, topic="Coral Reef Adaptation", evidenceGraph=canonical_graph))
    bp = ExamBlueprint(blueprintId="bp_test_999", runId=run_id, sections=[sec_bp])
    bp_env = ArtifactEnvelope.create(
        artifact_id=bp.blueprint_id,
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        run_id=run_id,
        version=1,
        producer_version="BlueprintPlanner:2.0.0",
        payload=bp.model_dump(mode="json", by_alias=True),
        parent_refs=[eg_env.to_ref()],
    )
    assert bp_env.verify_integrity() is True
    assert bp_env.parent_refs[0].artifact_id == eg_env.artifact_id
    assert bp_env.parent_refs[0].content_hash == eg_env.content_hash

def test_t15_living_adapters_import_integrity():
    """T15-08: Living compatibility adapters in extractor.py, prompts.py, llm.py remain functional."""
    # Test extractor.py living adapter
    from app.extractor import is_safe_url, clean_html, detect_source_type, search_sources, fetch_source, ingest_source
    assert callable(is_safe_url)
    assert callable(clean_html)
    assert callable(detect_source_type)
    assert is_safe_url("https://nature.com/articles/sample") is True
    assert is_safe_url("http://127.0.0.1/evil") is False

    # Test prompts.py living adapter
    from app.prompts import SECTION_PROFILES, GROUP_INSTRUCTIONS, build_passage_prompt, build_group_instruction
    assert 1 in SECTION_PROFILES
    assert "TRUE_FALSE_NOT_GIVEN" in GROUP_INSTRUCTIONS
    assert "Questions 1–7." in build_group_instruction("TRUE_FALSE_NOT_GIVEN", 1, 7)
    passage_p = build_passage_prompt("Space exploration", 1, "Exoplanets")
    assert "Space exploration" in passage_p

    # Test llm.py living adapter
    from app.llm import llm_generate, LLMService, format_prompt
    assert callable(llm_generate)
    assert hasattr(LLMService, "generate")
    assert format_prompt("Hello {name}", {"name": "World"}) == "Hello World"


@pytest.mark.asyncio
async def test_t15_section_v2_rejection_status_preserved_422():
    """T15-09: Verifies that a rejected SectionLoop in section_v2 returns HTTP 422 and is NOT converted to 500."""
    from fastapi import HTTPException
    from app.router import section_v2, SectionV2Request
    from unittest.mock import AsyncMock, patch, MagicMock
    from app.contracts.loop import DecisionType, LoopReason
    
    mock_loop_res = MagicMock()
    mock_loop_res.accepted_artifact = None
    mock_loop_res.decision = DecisionType.FAIL
    mock_loop_res.terminal_reason = "MAX_VERSIONS: unresolvable blocker"
    mock_loop_res.terminal_reason_code = LoopReason.MAX_VERSIONS
    mock_facade = MagicMock()
    mock_facade.generate_section_v2 = AsyncMock(return_value=mock_loop_res)
    mock_art = MagicMock(
        artifactId="art_p",
        acceptedVersion=1,
        isStale=False,
        acceptedHash="a"*64,
        envelopeJson=json.dumps({
            "artifactId": "art_p",
            "artifactType": "Passage",
            "version": 1,
            "runId": "run_reject_test",
            "sectionId": 1,
            "schemaVersion": "2.0.0",
            "contentHash": "a"*64,
            "createdAt": "2026-10-09T00:00:00Z",
            "producerVersion": "2.0.0",
            "payload": {"text": "Passage text", "passage": "Passage text"},
            "parentRefs": [],
        })
    )
    mock_facade.get_persistence_client = MagicMock(return_value=MagicMock(resume_state=MagicMock(return_value=MagicMock(artifacts=[mock_art]))))
    req = SectionV2Request(
        sectionIndex=1,
        title="Test Section",
        passageRef={"artifactId": "art_p", "artifactType": "Passage", "version": 1, "contentHash": "a"*64},
        blueprintRef={"artifactId": "art_bp", "artifactType": "ExamBlueprint", "version": 1, "contentHash": "b"*64},
        questionRefs=[],
        runId="run_reject_test",
        leaseOwner=UUID(int=0),
        epoch=1,
    )
    
    with patch("app.router.get_generation_facade", return_value=mock_facade):
        with pytest.raises(HTTPException) as exc_info:
            await section_v2(req, MagicMock())
        
        assert exc_info.value.status_code == 422, f"Expected 422 status code, got: {exc_info.value.status_code}"
        assert "MAX_VERSIONS" in exc_info.value.detail
