"""T13-01 & T13-02: Comprehensive API Endpoints & GenerationFacade Routing Tests.

Verifies:
- All 9 reading-paper API routes delegate directly to GenerationFacade.
- Exact field names, nullability, error status codes (401, 403, 422, 502, 503, 500).
- Content-Types: application/json and application/x-ndjson streaming.
- Route prefixes: with and without /api prefix.
- Health checks: /healthz and /api/healthz.
- Authentication: internal service key validation (503 unconfigured, 401 missing, 403 invalid, 200 valid).
"""
from __future__ import annotations

import json
from unittest.mock import AsyncMock, patch
from uuid import UUID

import pytest
from httpx import ASGITransport, AsyncClient

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import IssueLedger
from app.contracts.loop import DecisionType, LoopReason, LoopState
from app.extractor import SourceError, SourceNetworkError
from app.loop.runtime import LoopResult
from app.main import app
from app.repair.paper import PaperRepairActionType, PaperRepairResult

MOCK_SOURCE_DATA = {
    "pmcid": "PMC9123456",
    "title": "Biodiversity Conservation in Coastal Ecosystems",
    "url": "https://europepmc.org/articles/PMC9123456",
    "license": "https://creativecommons.org/licenses/by/4.0/",
    "wordCount": 1500,
    "authors": "Dr. Sarah Lin",
    "doi": "10.1016/j.ecol.2024.1002",
    "sourceType": "pmc",
    "metadata": None,
    "content": "Coastal ecosystems provide critical ecosystem services. " * 50,
    "contentPreview": "Coastal ecosystems provide critical ecosystem services.",
}

AUTH_KEY = "test-internal-service-key-phase13"
AUTH_HEADERS = {"X-Internal-Service-Key": AUTH_KEY}


@pytest.fixture(autouse=True)
def setup_auth_environment(monkeypatch):
    """Configures internal service key in environment by default."""
    monkeypatch.setenv("EXAMSERVICE__INTERNAL__API__KEY", AUTH_KEY)


def get_test_client() -> AsyncClient:
    """Creates an AsyncClient with default internal service authentication headers."""
    return AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
        headers=AUTH_HEADERS,
    )


# ============================================================================
# 1. Healthz & Route Mounting Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_healthz_endpoints():
    """Verifies /healthz and /api/healthz return 200 OK without requiring authentication."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r1 = await client.get("/healthz")
        assert r1.status_code == 200
        assert r1.json() == {"status": "ok", "service": "generation-service"}

        r2 = await client.get("/api/healthz")
        assert r2.status_code == 200
        assert r2.json() == {"status": "ok", "service": "generation-service"}


@pytest.mark.asyncio
async def test_t13_api_prefix_routing():
    """Verifies that routes are mounted both with and without /api prefix."""
    mock_search = AsyncMock(return_value={
        "sources": [MOCK_SOURCE_DATA],
        "selectedPmcids": ["PMC9123456"],
        "message": None,
    })

    with patch("app.facade.GenerationFacade.search_sources", mock_search):
        async with get_test_client() as client:
            # Without /api prefix
            r1 = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
            assert r1.status_code == 200
            assert r1.json()["selectedPmcids"] == ["PMC9123456"]

            # With /api prefix
            r2 = await client.get("/api/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
            assert r2.status_code == 200
            assert r2.json()["selectedPmcids"] == ["PMC9123456"]


# ============================================================================
# 2. Authentication (503 / 401 / 403 / 200) Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_authentication_unconfigured_503(monkeypatch):
    """Verifies 503 when internal service key is not configured anywhere."""
    monkeypatch.delenv("EXAMSERVICE__INTERNAL__API__KEY", raising=False)
    with patch("app.config.settings.internal_api_key", ""):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
            assert resp.status_code == 503
            assert "Internal service authentication is not configured" in resp.text


@pytest.mark.asyncio
async def test_t13_authentication_missing_header_401():
    """Verifies 401 when internal service key is configured but header is omitted."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
        assert resp.status_code == 401
        assert "Internal service authentication is required" in resp.text


@pytest.mark.asyncio
async def test_t13_authentication_invalid_header_403():
    """Verifies 403 when provided header does not match expected internal key."""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
        headers={"X-Internal-Service-Key": "incorrect-secret-token"},
    ) as client:
        resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
        assert resp.status_code == 403
        assert "Invalid internal service authentication" in resp.text


@pytest.mark.asyncio
async def test_t13_authentication_valid_header_200():
    """Verifies 200 when provided header matches expected internal key."""
    mock_search = AsyncMock(return_value={"sources": [], "selectedPmcids": [], "message": None})
    with patch("app.facade.GenerationFacade.search_sources", mock_search):
        async with get_test_client() as client:
            resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
            assert resp.status_code == 200


# ============================================================================
# 3. GET /sources Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_get_sources_success():
    """GET /v1/autogen/reading-paper/sources delegates to facade.search_sources."""
    mock_search = AsyncMock(return_value={
        "sources": [MOCK_SOURCE_DATA],
        "selectedPmcids": ["PMC9123456"],
        "message": None,
    })

    with patch("app.facade.GenerationFacade.search_sources", mock_search):
        async with get_test_client() as client:
            resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "climate change"})
            assert resp.status_code == 200
            assert resp.headers["content-type"].startswith("application/json")
            data = resp.json()
            assert len(data["sources"]) == 1
            assert data["sources"][0]["pmcid"] == "PMC9123456"
            mock_search.assert_awaited_once_with("climate change")


@pytest.mark.asyncio
async def test_t13_get_sources_validation_and_errors():
    """GET /v1/autogen/reading-paper/sources handles validation and SourceError."""
    async with get_test_client() as client:
        # 422 on short topic
        r_short = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "ab"})
        assert r_short.status_code == 422

    mock_search_err = AsyncMock(side_effect=SourceError("Europe PMC unreachable"))
    with patch("app.facade.GenerationFacade.search_sources", mock_search_err):
        async with get_test_client() as client:
            r_err = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine ecology"})
            assert r_err.status_code == 503
            assert "Europe PMC unreachable" in r_err.text


# ============================================================================
# 4. POST /source Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_source_success_nulls_content():
    """POST /v1/autogen/reading-paper/source delegates to facade.fetch_source and returns content as null."""
    mock_fetch = AsyncMock(return_value=dict(MOCK_SOURCE_DATA))

    with patch("app.facade.GenerationFacade.fetch_source", mock_fetch):
        async with get_test_client() as client:
            resp = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "PMC9123456"})
            assert resp.status_code == 200
            data = resp.json()
            assert "content" in data
            assert data["content"] is None
            assert data["pmcid"] == "PMC9123456"
            assert data["title"] == "Biodiversity Conservation in Coastal Ecosystems"
            mock_fetch.assert_awaited_once_with("PMC9123456")


@pytest.mark.asyncio
async def test_t13_post_source_errors():
    """POST /v1/autogen/reading-paper/source handles validation, network, and source errors."""
    async with get_test_client() as client:
        # Invalid PMCID format
        r_bad_pmc = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "INVALID_123"})
        assert r_bad_pmc.status_code == 422

    mock_net_err = AsyncMock(side_effect=SourceNetworkError("Connection timed out"))
    with patch("app.facade.GenerationFacade.fetch_source", mock_net_err):
        async with get_test_client() as client:
            r_net = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "PMC9123456"})
            assert r_net.status_code == 503

    mock_src_err = AsyncMock(side_effect=SourceError("License not CC-BY"))
    with patch("app.facade.GenerationFacade.fetch_source", mock_src_err):
        async with get_test_client() as client:
            r_src = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "PMC9123456"})
            assert r_src.status_code == 422


# ============================================================================
# 5. POST /source/ingest Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_source_ingest_success():
    """POST /v1/autogen/reading-paper/source/ingest delegates to facade.ingest_source."""
    mock_ingest = AsyncMock(return_value={
        "sourceType": "text",
        "sourceId": "CUSTOM:test12345",
        "pmcid": "CUSTOM:test12345",
        "title": "Custom Study",
        "url": "",
        "authors": "Researcher",
        "doi": None,
        "license": "User Provided",
        "wordCount": 800,
        "content": "Sample content",
        "contentPreview": "Sample preview",
        "metadata": {},
    })

    with patch("app.facade.GenerationFacade.ingest_source", mock_ingest):
        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/source/ingest",
                json={
                    "payload": "Sample source content text for ingestion.",
                    "type": "text",
                    "title": "Custom Study",
                },
            )
            assert resp.status_code == 200
            data = resp.json()
            assert data["sourceId"] == "CUSTOM:test12345"
            mock_ingest.assert_awaited_once()


@pytest.mark.asyncio
async def test_t13_post_source_ingest_errors():
    """POST /v1/autogen/reading-paper/source/ingest handles validation and errors."""
    async with get_test_client() as client:
        # Empty payload
        r_empty = await client.post("/v1/autogen/reading-paper/source/ingest", json={"payload": ""})
        assert r_empty.status_code == 422

    mock_net_err = AsyncMock(side_effect=SourceNetworkError("Failed to fetch URL"))
    with patch("app.facade.GenerationFacade.ingest_source", mock_net_err):
        async with get_test_client() as client:
            r_net = await client.post("/v1/autogen/reading-paper/source/ingest", json={"payload": "https://bad.url"})
            assert r_net.status_code == 503


# ============================================================================
# 6. POST /section (V1 and V2) Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_section_v1_json():
    """POST /v1/autogen/reading-paper/section delegates V1 generation to facade."""
    mock_v1_res = {
        "title": "Passage 1",
        "passage": "Passage text...",
        "groups": [],
    }
    mock_gen = AsyncMock(return_value=mock_v1_res)

    with patch("app.facade.GenerationFacade.generate_section", mock_gen):
        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/section",
                headers={"Accept": "application/json", **AUTH_HEADERS},
                json={
                    "topic": "marine ecology",
                    "index": 1,
                    "source": MOCK_SOURCE_DATA,
                    "runId": "run_v1_test",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_v1_test",
                },
            )
            assert resp.status_code == 200
            assert resp.json()["title"] == "Passage 1"


@pytest.mark.asyncio
async def test_t13_post_section_v1_errors():
    """POST /v1/autogen/reading-paper/section V1 error mapping (502, 503, 422)."""
    with patch("app.facade.GenerationFacade.generate_section", AsyncMock(side_effect=ValueError("Malformed model response"))):
        async with get_test_client() as client:
            r_502 = await client.post(
                "/v1/autogen/reading-paper/section",
                json={
                    "topic": "marine ecology",
                    "index": 1,
                    "source": MOCK_SOURCE_DATA,
                    "runId": "run_v1",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_v1",
                },
            )
            assert r_502.status_code == 502

    with patch("app.facade.GenerationFacade.generate_section", AsyncMock(side_effect=SourceNetworkError("Timeout"))):
        async with get_test_client() as client:
            r_503 = await client.post(
                "/v1/autogen/reading-paper/section",
                json={
                    "topic": "marine ecology",
                    "index": 1,
                    "source": MOCK_SOURCE_DATA,
                    "runId": "run_v1",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_v1",
                },
            )
            assert r_503.status_code == 503


@pytest.mark.asyncio
async def test_t13_post_section_v2_json_success():
    """POST /v1/autogen/reading-paper/section routes to generate_passage_v2 when engine=v2."""
    passage_env = ArtifactEnvelope.create(
        artifact_id="art_passage_sec1",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_v2_sec",
        payload={"title": "V2 Passage", "text": "Synthesized academic text..."},
        producer_version="2.0.0",
        version=1,
    )
    mock_loop_res = LoopResult(
        run_id="run_v2_sec",
        decision=DecisionType.PASS,
        terminal_state=LoopState.COMPLETED,
        terminal_reason="Passage passed all quality gates",
        terminal_reason_code=LoopReason.ACCEPTED,
        accepted_artifact=passage_env,
        ledger=IssueLedger(ledger_id="led_v2", run_id="run_v2_sec"),
    )

    with patch("app.facade.GenerationFacade.generate_passage_v2", AsyncMock(return_value=mock_loop_res)):
        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/section",
                json={
                    "topic": "archaeology",
                    "index": 1,
                    "source": {"content": "Sufficient source content for IELTS passage generation exceeding 50 chars."},
                    "runId": "run_v2_sec",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_v2",
                    "engine": "v2",
                    "blueprintRef": {
                        "artifactId": "art_bp",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "a" * 64,
                    },
                    "evidenceGraphRef": {
                        "artifactId": "art_eg",
                        "artifactType": "EvidenceGraph",
                        "version": 1,
                        "contentHash": "b" * 64,
                    },
                },
            )
            assert resp.status_code == 200
            data = resp.json()
            assert data["title"] == "V2 Passage"


@pytest.mark.asyncio
async def test_t13_post_section_v2_insufficient_source():
    """POST /v1/autogen/reading-paper/section returns SOURCE_INSUFFICIENT on short source."""
    async with get_test_client() as client:
        resp = await client.post(
            "/v1/autogen/reading-paper/section",
            json={
                "topic": "archaeology",
                "index": 1,
                "source": {"content": "Too short"},
                "runId": "run_v2_sec",
                "epoch": 1,
                "leaseOwner": "00000000-0000-0000-0000-000000000001",
                "parentOperationId": "op_v2",
                "engine": "v2",
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["decision"] == "FAIL"
        assert data["terminalReasonCode"] == "SOURCE_INSUFFICIENT"

@pytest.mark.asyncio
async def test_t13_post_section_v2_ndjson_streaming_success():
    """POST /v1/autogen/reading-paper/section V2 NDJSON streaming emits log and result events."""
    passage_env = ArtifactEnvelope.create(
        artifact_id="art_passage_ndjson",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_v2_ndjson",
        payload={"title": "V2 Passage", "text": "Synthesized academic text..."},
        producer_version="2.0.0",
        version=1,
    )
    mock_loop_res = LoopResult(
        run_id="run_v2_ndjson",
        decision=DecisionType.PASS,
        terminal_state=LoopState.COMPLETED,
        terminal_reason="Passage passed all quality gates",
        terminal_reason_code=LoopReason.ACCEPTED,
        accepted_artifact=passage_env,
        ledger=IssueLedger(ledger_id="led_v2_ndjson", run_id="run_v2_ndjson"),
    )

    with patch("app.facade.GenerationFacade.generate_passage_v2", AsyncMock(return_value=mock_loop_res)):
        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/section",
                headers={"Accept": "application/x-ndjson", **AUTH_HEADERS},
                json={
                    "topic": "archaeology",
                    "index": 1,
                    "source": {"content": "Sufficient source content for IELTS passage generation exceeding 50 chars."},
                    "runId": "run_v2_ndjson",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_v2",
                    "engine": "v2",
                    "blueprintRef": {
                        "artifactId": "art_bp",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "a" * 64,
                    },
                    "evidenceGraphRef": {
                        "artifactId": "art_eg",
                        "artifactType": "EvidenceGraph",
                        "version": 1,
                        "contentHash": "b" * 64,
                    },
                },
            )
            assert resp.status_code == 200
            assert "application/x-ndjson" in resp.headers["content-type"]
            lines = [line.strip() for line in resp.text.split("\n") if line.strip()]
            events = [json.loads(line) for line in lines]
            log_events = [e for e in events if e.get("type") == "log"]
            result_events = [e for e in events if e.get("type") == "result"]
            assert len(log_events) >= 1
            assert len(result_events) == 1
            assert result_events[0]["section"]["title"] == "V2 Passage"


@pytest.mark.asyncio
async def test_t13_post_section_v2_ndjson_streaming_insufficient_source_error():
    """POST /v1/autogen/reading-paper/section V2 NDJSON streaming emits error on short source."""
    async with get_test_client() as client:
        resp = await client.post(
            "/v1/autogen/reading-paper/section",
            headers={"Accept": "application/x-ndjson", **AUTH_HEADERS},
            json={
                "topic": "archaeology",
                "index": 1,
                "source": {"content": "Too short"},
                "runId": "run_v2_err",
                "epoch": 1,
                "leaseOwner": "00000000-0000-0000-0000-000000000001",
                "parentOperationId": "op_v2",
                "engine": "v2",
            },
        )
        assert resp.status_code == 200
        assert "application/x-ndjson" in resp.headers["content-type"]
        lines = [line.strip() for line in resp.text.split("\n") if line.strip()]
        events = [json.loads(line) for line in lines]
        assert len(events) == 1
        assert events[0]["type"] == "error"
        assert events[0]["httpStatus"] == 422
        assert "insufficient" in events[0]["message"].lower()


# ============================================================================
# 7. POST /questions Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_questions_success():
    """POST /v1/autogen/reading-paper/questions delegates to facade.generate_questions_v2."""
    valid_env = ArtifactEnvelope.create(
        artifact_id="art_p_10",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_q_t13",
        payload={"text": "Archaeological analysis text."},
        producer_version="2.0.0",
        version=1,
    )
    mock_art = type("MockArt", (), {
        "artifactId": "art_p_10",
        "acceptedVersion": 1,
        "acceptedHash": valid_env.content_hash,
        "isStale": False,
        "envelopeJson": valid_env.model_dump_json(),
    })()
    mock_state = type("MockState", (), {"artifacts": [mock_art]})()

    mock_q_res = {
        "status": "COMPLETED",
        "totalQuestions": 4,
        "questions": {1: {"prompt": "Question 1"}},
    }

    with patch("app.facade.GenerationFacade.get_persistence_client") as mock_get_client, \
         patch("app.facade.GenerationFacade.generate_questions_v2", new_callable=AsyncMock) as mock_gen_q:
        mock_get_client.return_value.resume_state.return_value = mock_state
        mock_gen_q.return_value = mock_q_res

        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/questions",
                json={
                    "passageRef": {
                        "artifactId": "art_p_10",
                        "artifactType": "Passage",
                        "version": 1,
                        "contentHash": valid_env.content_hash,
                    },
                    "blueprintRef": {
                        "artifactId": "art_bp_10",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "c" * 64,
                    },
                    "runId": "run_q_t13",
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "epoch": 1,
                    "sectionIndex": 1,
                },
            )
            assert resp.status_code == 200
            assert resp.json()["status"] == "COMPLETED"


# ============================================================================
# 8. POST /section-v2 Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_section_v2_success():
    """POST /v1/autogen/reading-paper/section-v2 delegates to facade.generate_section_v2."""
    passage_env = ArtifactEnvelope.create(
        artifact_id="art_p_sec",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_sec_v2",
        payload={"text": "Passage text"},
        producer_version="2.0.0",
        version=1,
    )
    mock_art = type("MockArt", (), {
        "artifactId": "art_p_sec",
        "acceptedVersion": 1,
        "acceptedHash": passage_env.content_hash,
        "isStale": False,
        "envelopeJson": passage_env.model_dump_json(),
    })()
    mock_state = type("MockState", (), {"artifacts": [mock_art]})()

    sec_env = ArtifactEnvelope.create(
        artifact_id="art_section_out",
        artifact_type=ArtifactType.SECTION,
        run_id="run_sec_v2",
        payload={"sectionIndex": 1, "title": "Academic Reading Section", "groups": []},
        producer_version="2.0.0",
        version=1,
    )
    mock_loop_res = LoopResult(
        run_id="run_sec_v2",
        decision=DecisionType.PASS,
        terminal_state=LoopState.COMPLETED,
        terminal_reason="Section accepted",
        terminal_reason_code=LoopReason.ACCEPTED,
        accepted_artifact=sec_env,
        ledger=IssueLedger(ledger_id="led_sec", run_id="run_sec_v2"),
    )

    with patch("app.facade.GenerationFacade.get_persistence_client") as mock_get_client, \
         patch("app.facade.GenerationFacade.generate_section_v2", new_callable=AsyncMock) as mock_gen_sec:
        mock_get_client.return_value.resume_state.return_value = mock_state
        mock_gen_sec.return_value = mock_loop_res

        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/section-v2",
                json={
                    "sectionIndex": 1,
                    "title": "Academic Reading Section",
                    "passageRef": {
                        "artifactId": "art_p_sec",
                        "artifactType": "Passage",
                        "version": 1,
                        "contentHash": passage_env.content_hash,
                    },
                    "blueprintRef": {
                        "artifactId": "art_bp_sec",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "d" * 64,
                    },
                    "questionRefs": [],
                    "runId": "run_sec_v2",
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "epoch": 1,
                },
            )
            assert resp.status_code == 200
            assert resp.json()["title"] == "Academic Reading Section"


# ============================================================================
# 9. POST /paper-evaluate Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_paper_evaluate_success():
    """POST /v1/autogen/reading-paper/paper-evaluate delegates to facade.evaluate_paper_async."""
    paper_env = ArtifactEnvelope.create(
        artifact_id="art_paper_eval",
        artifact_type=ArtifactType.READING_PAPER,
        run_id="run_eval",
        payload={"sections": []},
        producer_version="2.0.0",
        version=1,
    )

    eval_res = EvaluationResult(
        evaluation_id="eval_test_123",
        evaluator_id="eval_paper_monotony",
        evaluator_version="2.0.0",
        target_ref=paper_env.to_ref(),
        status=EvaluationStatus.PASS,
        issues=[],
    )

    with patch("app.facade.GenerationFacade.evaluate_paper_async", new_callable=AsyncMock) as mock_eval:
        mock_eval.return_value = [eval_res]

        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/paper-evaluate",
                json={
                    "paperEnvelope": paper_env.model_dump(mode="json"),
                    "runId": "run_eval",
                    "epoch": 1,
                },
            )
            assert resp.status_code == 200
            data = resp.json()
            assert isinstance(data, list)
            assert len(data) == 1
            assert data[0]["evaluatorId"] == "eval_paper_monotony"
            assert data[0]["status"] == "PASS"


@pytest.mark.asyncio
async def test_t13_post_paper_evaluate_validation_error():
    """POST /v1/autogen/reading-paper/paper-evaluate returns 422 on invalid envelope."""
    async with get_test_client() as client:
        resp = await client.post(
            "/v1/autogen/reading-paper/paper-evaluate",
            json={"paperEnvelope": {"not": "valid"}},
        )
        assert resp.status_code == 422


# ============================================================================
# 10. POST /paper-repair Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_paper_repair_success():
    """POST /v1/autogen/reading-paper/paper-repair delegates to facade.repair_paper_async."""
    paper_env = ArtifactEnvelope.create(
        artifact_id="art_paper_rep",
        artifact_type=ArtifactType.READING_PAPER,
        run_id="run_rep",
        payload={"sections": []},
        producer_version="2.0.0",
        version=1,
    )
    rep_res = PaperRepairResult(
        repaired_envelope=paper_env,
        applied_actions=["SECTION_REPAIR"],
        invalidated_refs=[],
        preserved_refs=[],
        tokens_used=100,
        wall_time_used_seconds=1.5,
    )

    with patch("app.facade.GenerationFacade.repair_paper_async", new_callable=AsyncMock) as mock_rep:
        mock_rep.return_value = rep_res

        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/paper-repair",
                json={
                    "paperEnvelope": paper_env.model_dump(mode="json"),
                    "directive": {
                        "directiveId": "dir_test_123",
                        "targetSectionId": 1,
                        "patchPayload": {"rationale": "Repair needed"},
                    },
                },
            )
            assert resp.status_code == 200
            data = resp.json()
            assert "repairedEnvelope" in data
            assert data["appliedActions"] == ["SECTION_REPAIR"]


# ============================================================================
# 11. POST /paper-v2 Tests
# ============================================================================


@pytest.mark.asyncio
async def test_t13_post_paper_v2_success():
    """POST /v1/autogen/reading-paper/paper-v2 delegates to facade.generate_paper_v2."""
    sec_arts = []
    mock_arts = []
    for i in (1, 2, 3):
        env = ArtifactEnvelope.create(
            artifact_id=f"art_sec_{i}",
            artifact_type=ArtifactType.SECTION,
            run_id="run_paper_v2",
            payload={"sectionIndex": i, "title": f"Section {i}"},
            producer_version="2.0.0",
            version=1,
        )
        sec_arts.append(env)
        mock_arts.append(
            type("MockArt", (), {
                "artifact_id": f"art_sec_{i}",
                "artifactId": f"art_sec_{i}",
                "accepted_version": 1,
                "acceptedVersion": 1,
                "accepted_hash": env.content_hash,
                "acceptedHash": env.content_hash,
                "is_stale": False,
                "isStale": False,
                "envelope_json": env.model_dump_json(),
                "envelopeJson": env.model_dump_json(),
            })()
        )

    paper_out = ArtifactEnvelope.create(
        artifact_id="art_final_paper",
        artifact_type=ArtifactType.READING_PAPER,
        run_id="run_paper_v2",
        payload={"title": "IELTS Academic Reading Paper", "sections": []},
        producer_version="2.0.0",
        version=1,
    )
    mock_loop_res = LoopResult(
        run_id="run_paper_v2",
        decision=DecisionType.PASS,
        terminal_state=LoopState.COMPLETED,
        terminal_reason="Paper passed",
        terminal_reason_code=LoopReason.ACCEPTED,
        accepted_artifact=paper_out,
        ledger=IssueLedger(ledger_id="led_p", run_id="run_paper_v2"),
    )

    mock_state = type("MockState", (), {"artifacts": mock_arts})()

    with patch("app.facade.GenerationFacade.get_persistence_client") as mock_get_client, \
         patch("app.facade.GenerationFacade.generate_paper_v2", new_callable=AsyncMock) as mock_gen_p:
        mock_get_client.return_value.resume_state.return_value = mock_state
        mock_gen_p.return_value = mock_loop_res

        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/paper-v2",
                json={
                    "blueprintRef": {
                        "artifactId": "art_bp_paper",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "e" * 64,
                    },
                    "sectionRefs": [
                        {
                            "artifactId": f"art_sec_{i}",
                            "artifactType": "Section",
                            "version": 1,
                            "contentHash": sec_arts[i - 1].content_hash,
                        }
                        for i in (1, 2, 3)
                    ],
                    "runId": "run_paper_v2",
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "epoch": 1,
                    "title": "IELTS Academic Reading Paper",
                },
            )
            assert resp.status_code == 200
            data = resp.json()
            assert data["artifactId"] == "art_final_paper"


@pytest.mark.asyncio
async def test_t13_post_paper_v2_missing_sections_error():
    """POST /v1/autogen/reading-paper/paper-v2 returns 422 if fewer than 3 sections in persistence."""
    mock_state = type("MockState", (), {"artifacts": []})()

    with patch("app.facade.GenerationFacade.get_persistence_client") as mock_get_client:
        mock_get_client.return_value.resume_state.return_value = mock_state

        async with get_test_client() as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/paper-v2",
                json={
                    "blueprintRef": {
                        "artifactId": "art_bp_paper",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "e" * 64,
                    },
                    "sectionRefs": [
                        {
                            "artifactId": f"art_sec_{i}",
                            "artifactType": "Section",
                            "version": 1,
                            "contentHash": "f" * 64,
                        }
                        for i in (1, 2, 3)
                    ],
                    "runId": "run_paper_v2",
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "epoch": 1,
                },
            )
            assert resp.status_code == 422
            assert "Expected 3 valid accepted section artifacts" in resp.text

# ============================================================================
# 12. Prometheus Metrics & Observability Tests (T13-07)
# ============================================================================


@pytest.mark.asyncio
async def test_t13_metrics_endpoints():
    """Verifies /metrics and /api/metrics return Prometheus text format."""
    from app.observability.metrics import get_metrics_recorder
    from app.observability.redaction import ModelKind, OutcomeKind, ProviderKind

    get_metrics_recorder().record_provider_call(ProviderKind.MINIMAX, ModelKind.MINIMAX_TEXT_01, OutcomeKind.OK)

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r1 = await client.get("/metrics")
        assert r1.status_code == 200
        assert "text/plain" in r1.headers["content-type"]
        assert "# HELP" in r1.text or "# TYPE" in r1.text

        r2 = await client.get("/api/metrics")
        assert r2.status_code == 200
        assert "text/plain" in r2.headers["content-type"]
        assert "# HELP" in r2.text or "# TYPE" in r2.text

@pytest.mark.asyncio
async def test_t13_facade_instrumentation_records_metrics_and_lineage():
    """Verifies that GenerationFacade methods record operation latency and decision lineage."""
    from app.facade import get_generation_facade
    from app.generators.passage.context import PassageGenerationContext
    from app.generators.passage.prompts import PassageStyleProfile
    from app.contracts.artifact import ArtifactRef
    from app.observability.accounting import get_decision_lineage
    from app.observability.metrics import get_metrics_recorder

    facade = get_generation_facade()
    passage_env = ArtifactEnvelope.create(
        artifact_id="art_inst_passage",
        artifact_type=ArtifactType.PASSAGE,
        run_id="run_inst_test",
        payload={"title": "Test Passage", "text": "Passage text for instrumentation test."},
        producer_version="2.0.0",
        version=1,
    )
    mock_loop_res = LoopResult(
        run_id="run_inst_test",
        decision=DecisionType.PASS,
        terminal_state=LoopState.COMPLETED,
        terminal_reason="Passage passed quality gates",
        terminal_reason_code=LoopReason.ACCEPTED,
        accepted_artifact=passage_env,
        ledger=IssueLedger(ledger_id="led_inst", run_id="run_inst_test"),
    )

    ctx = PassageGenerationContext(
        blueprintRef=ArtifactRef(artifactId="bp_1", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="a"*64),
        evidenceGraphRef=ArtifactRef(artifactId="eg_1", artifactType=ArtifactType.EVIDENCE_GRAPH, version=1, contentHash="b"*64),
        sectionIndex=1,
        topic="botany",
        sourceText="Source text exceeding fifty characters for passage generation validation.",
        styleProfile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
    )

    with patch("app.loop.passage.PassageLoop.run", new_callable=AsyncMock) as mock_run:
        mock_run.return_value = mock_loop_res
        res = await facade.generate_passage_v2(
            passage_context=ctx,
            run_id="run_inst_test",
            lease_owner=UUID("00000000-0000-0000-0000-000000000001"),
            epoch=1,
        )
        assert res.decision == DecisionType.PASS

        # Verify decision was recorded in DecisionLineage
        lineage = get_decision_lineage()
        records = lineage.get_records(run_id="run_inst_test")
        assert len(records) >= 1
        assert records[-1].decision_type == "PASS"
        assert records[-1].run_id == "run_inst_test"
