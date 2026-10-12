"""T00-01: Replay sample requests for the 4 generation-service reading-paper endpoints.

Verifies: field names, nullability, status codes, content-types, and terminal events
against the legacy contract snapshots.
"""
from __future__ import annotations

import json
from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app
from tests.test_pipeline import valid_section

MOCK_SOURCE = {
    "pmcid": "PMC8910001",
    "title": "Trophic Interactions in Coral Reefs",
    "url": "https://europepmc.org/articles/PMC8910001",
    "license": "https://creativecommons.org/licenses/by/4.0/",
    "wordCount": 1840,
    "authors": "Elena Rostova",
    "doi": "10.1016/j.ecol.2023.1001",
    "sourceType": "pmc",
    "metadata": None,
    "content": "A " * 650,
    "contentPreview": "A " * 50,
}

AUTH_KEY = "test-internal-service-key-t00"
AUTH_HEADERS = {"X-Internal-Service-Key": AUTH_KEY}


@pytest.fixture(autouse=True)
def setup_auth_environment(monkeypatch):
    """Configures internal service key in environment by default."""
    monkeypatch.setenv("EXAMSERVICE__INTERNAL__API__KEY", AUTH_KEY)


@pytest.mark.asyncio
async def test_t00_01_get_sources():
    """T00-01.1: Replay GET /v1/autogen/reading-paper/sources."""
    mock_search = AsyncMock(return_value={
        "sources": [MOCK_SOURCE],
        "selectedPmcids": ["PMC8910001"],
        "message": None,
    })

    with patch("app.facade.GenerationFacade.search_sources", mock_search):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "marine biology"})
            assert resp.status_code == 200
            assert "application/json" in resp.headers["content-type"]
            data = resp.json()

            # Contract verification
            assert "sources" in data and isinstance(data["sources"], list)
            assert "selectedPmcids" in data and isinstance(data["selectedPmcids"], list)
            assert "message" in data
            assert len(data["sources"]) == 1

            source = data["sources"][0]
            assert source["pmcid"] == "PMC8910001"
            assert source["title"] == "Trophic Interactions in Coral Reefs"
            assert source["license"] == "https://creativecommons.org/licenses/by/4.0/"
            assert isinstance(source["wordCount"], int)
            assert source["wordCount"] >= 600

            # Test topic length boundary validation
            bad_resp = await client.get("/v1/autogen/reading-paper/sources", params={"topic": "ab"})
            assert bad_resp.status_code == 422  # query param min_length=3


@pytest.mark.asyncio
async def test_t00_01_post_source():
    """T00-01.2: Replay POST /v1/autogen/reading-paper/source."""
    mock_fetch = AsyncMock(return_value=dict(MOCK_SOURCE))

    with patch("app.facade.GenerationFacade.fetch_source", mock_fetch):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "PMC8910001"})
            assert resp.status_code == 200
            assert "application/json" in resp.headers["content-type"]
            data = resp.json()

            # Contract schema: 'content' must be stripped from response
            assert data.get("content") is None
            assert data["pmcid"] == "PMC8910001"
            assert data["title"] == "Trophic Interactions in Coral Reefs"
            assert data["license"] == "https://creativecommons.org/licenses/by/4.0/"
            assert data["wordCount"] == 1840

            # Invalid PMCID format
            invalid_resp = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "NOT_A_PMC"})
            assert invalid_resp.status_code == 422


@pytest.mark.asyncio
async def test_t00_01_post_source_ingest():
    """T00-01.3: Replay POST /v1/autogen/reading-paper/source/ingest."""
    payload_text = "Artificial intelligence monitoring. " + ("biodiversity " * 620)
    mock_ingest = AsyncMock(return_value={
        "sourceType": "text",
        "sourceId": "CUSTOM:abc123456789",
        "pmcid": "CUSTOM:abc123456789",
        "title": "Ecological Monitoring Study",
        "url": "",
        "authors": "Researcher",
        "doi": None,
        "license": "User Provided",
        "wordCount": 623,
        "content": payload_text[:70000],
        "contentPreview": payload_text[:300].strip(),
        "metadata": {"domain": None, "description": None, "format": "text"},
    })

    with patch("app.facade.GenerationFacade.ingest_source", mock_ingest):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/source/ingest",
                json={
                    "payload": payload_text,
                    "type": "text",
                    "title": "Ecological Monitoring Study",
                },
            )
            assert resp.status_code == 200
            assert "application/json" in resp.headers["content-type"]
            data = resp.json()

            assert data["sourceType"] == "text"
            assert data["sourceId"].startswith("CUSTOM:")
            assert data["pmcid"] == data["sourceId"]
            assert data["title"] == "Ecological Monitoring Study"
            assert data["wordCount"] == 623
            assert data["doi"] is None
            assert data["license"] == "User Provided"

            # Empty payload should fail validation
            empty_resp = await client.post("/v1/autogen/reading-paper/source/ingest", json={"payload": ""})
            assert empty_resp.status_code == 422


@pytest.mark.asyncio
async def test_t00_01_post_section_json():
    """T00-01.4: Replay POST /v1/autogen/reading-paper/section with application/json."""
    section_data = valid_section(1)
    mock_gen = AsyncMock(return_value=section_data)

    with patch("app.facade.GenerationFacade.generate_section", mock_gen):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/section",
                headers={"Accept": "application/json"},
                json={
                    "topic": "marine ecology",
                    "index": 1,
                    "source": MOCK_SOURCE,
                    "runId": "run_t00",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_t00",
                },
            )
            assert resp.status_code == 200
            assert "application/json" in resp.headers["content-type"]
            data = resp.json()

            assert data["title"] == "Passage 1"
            assert "passage" in data
            assert len(data["groups"]) == 2
            assert data["groups"][0]["type"] == "TRUE_FALSE_NOT_GIVEN"
            assert len(data["groups"][0]["questions"]) == 7
            assert data["groups"][1]["type"] == "SENTENCE_COMPLETION"
            assert len(data["groups"][1]["questions"]) == 6


@pytest.mark.asyncio
async def test_t00_01_post_section_ndjson_stream():
    """T00-01.5: Replay POST /v1/autogen/reading-paper/section with application/x-ndjson."""
    section_data = valid_section(1)

    async def fake_gen(self, topic, index, source, progress=None, **kwargs):
        if progress:
            await progress("Information", "Simulated step 1")
            await progress("Information", "Simulated step 2")
        return section_data

    with patch("app.facade.GenerationFacade.generate_section", fake_gen):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/section",
                headers={"Accept": "application/x-ndjson"},
                json={
                    "topic": "marine ecology",
                    "index": 1,
                    "source": MOCK_SOURCE,
                    "runId": "run_t00",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_t00",
                },
            )
            assert resp.status_code == 200
            assert "application/x-ndjson" in resp.headers["content-type"]

            lines = [line.strip() for line in resp.text.split("\n") if line.strip()]
            assert len(lines) >= 3

            events = [json.loads(line) for line in lines]
            log_events = [e for e in events if e.get("type") == "log"]
            result_events = [e for e in events if e.get("type") == "result"]

            assert len(log_events) >= 2
            for le in log_events:
                assert "timestamp" in le
                assert le["level"] in ("Information", "Warning", "Error")
                assert "message" in le

            assert len(result_events) == 1
            result = result_events[0]
            assert "section" in result
            assert result["section"]["title"] == "Passage 1"
            assert len(result["section"]["groups"]) == 2


@pytest.mark.asyncio
async def test_t00_02_post_questions_v2_success():
    """Validates POST /v1/autogen/reading-paper/questions routes to generate_questions_v2."""
    mock_res = {
        "status": "COMPLETED",
        "totalQuestions": 4,
        "resumedCount": 3,
        "generatedCount": 1,
        "questions": {
            14: {"prompt": "Q14"},
            15: {"prompt": "Q15"},
            16: {"prompt": "Q16"},
            17: {"prompt": "Q17"},
        },
    }

    from app.contracts.artifact import ArtifactEnvelope, ArtifactType
    valid_env = ArtifactEnvelope.create(
        artifact_id="art_p_1",
        artifact_type=ArtifactType.PASSAGE,
        version=1,
        payload={"text": "Ancient archaeology text sample."},
        run_id="run_q_test",
        producer_version="2.0.0",
    )
    mock_art = type("MockArt", (), {
        "artifactId": "art_p_1",
        "acceptedVersion": 1,
        "acceptedHash": valid_env.content_hash,
        "isStale": False,
        "envelopeJson": valid_env.model_dump_json(),
    })()
    mock_state = type("MockState", (), {"artifacts": [mock_art]})()

    with patch("app.facade.GenerationFacade.get_persistence_client") as mock_get_client, \
         patch("app.facade.GenerationFacade.generate_questions_v2", new_callable=AsyncMock) as mock_gen_q:
        mock_client = mock_get_client.return_value
        mock_client.resume_state.return_value = mock_state
        mock_gen_q.return_value = mock_res

        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/questions",
                json={
                    "passageRef": {
                        "artifactId": "art_p_1",
                        "artifactType": "Passage",
                        "version": 1,
                        "contentHash": valid_env.content_hash,
                    },
                    "blueprintRef": {
                        "artifactId": "art_bp_1",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "b" * 64,
                    },
                    "runId": "run_q_test",
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "epoch": 1,
                    "sectionIndex": 1,
                },
            )
            assert resp.status_code == 200, resp.text
            data = resp.json()
            assert data["status"] == "COMPLETED"
            assert data["totalQuestions"] == 4
            mock_gen_q.assert_awaited_once()


@pytest.mark.asyncio
async def test_t00_02_post_questions_v2_wrong_artifact_type_negative():
    """Fails with 422 when passageRef is not ArtifactType.PASSAGE."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
        resp = await client.post(
            "/v1/autogen/reading-paper/questions",
            json={
                "passageRef": {
                    "artifactId": "art_sec_1",
                    "artifactType": "Section",  # Invalid type for passageRef
                    "version": 1,
                    "contentHash": "a" * 64,
                },
                "blueprintRef": {
                    "artifactId": "art_bp_1",
                    "artifactType": "ExamBlueprint",
                    "version": 1,
                    "contentHash": "b" * 64,
                },
                "leaseOwner": "00000000-0000-0000-0000-000000000001",
                "runId": "run_q_test",
            },
        )
        assert resp.status_code == 422
        assert "Expected passageRef to be ArtifactType.PASSAGE" in resp.text


@pytest.mark.asyncio
async def test_t00_02_post_questions_v2_missing_passage_persistence_negative():
    """Fails with 422 when passage is not found in authoritative persistence store."""
    mock_state = type("MockState", (), {"artifacts": []})()
    with patch("app.facade.GenerationFacade.get_persistence_client") as mock_get_client:
        mock_client = mock_get_client.return_value
        mock_client.resume_state.return_value = mock_state

        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/questions",
                json={
                    "passageRef": {
                        "artifactId": "art_missing_1",
                        "artifactType": "Passage",
                        "version": 1,
                        "contentHash": "a" * 64,
                    },
                    "blueprintRef": {
                        "artifactId": "art_bp_1",
                        "artifactType": "ExamBlueprint",
                        "version": 1,
                        "contentHash": "b" * 64,
                    },
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                "runId": "run_q_test",
                },
            )
            assert resp.status_code == 422
            assert "Passage dependency missing" in resp.text
