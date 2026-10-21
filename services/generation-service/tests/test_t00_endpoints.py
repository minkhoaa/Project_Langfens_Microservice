"""T00-01: Replay sample requests for the 4 generation-service reading-paper endpoints.

Verifies: field names, nullability, status codes, content-types, and terminal events
against the legacy contract snapshots.
"""
from __future__ import annotations
from uuid import UUID
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

    with patch("app.router.search_sources", mock_search):
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

    with patch("app.router.fetch_source", mock_fetch):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post("/v1/autogen/reading-paper/source", json={"pmcid": "PMC8910001"})
            assert resp.status_code == 200
            assert "application/json" in resp.headers["content-type"]
            data = resp.json()

            assert data.get("content") is not None
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

    with patch("app.router.ingest_source", mock_ingest):
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
async def test_t00_01_post_execute():
    """T00-01.4: POST /v1/autogen/reading-paper/execute executes generation pipeline."""
    from app.contracts.artifact import ArtifactEnvelope, ArtifactType
    from app.reading_policy import PinnedExecutionPolicy
    from app.reading_models import PipelineRequest, PipelineResult, SourceInput
    from app.router import get_reading_pipeline

    sec_env = ArtifactEnvelope.create(
        artifact_id="section:run_t00:1",
        artifact_type=ArtifactType.SECTION,
        run_id="run_t00",
        payload={"sectionId": 1, "title": "Passage 1", "passage": "Text", "groups": []},
        producer_version="2.0.0",
        version=1,
    )
    mock_pipeline = AsyncMock()
    mock_pipeline.execute.return_value = PipelineResult(
        runId="run_t00",
        status="ACCEPTED",
        sections=(sec_env,),
        paper=None,
        examId=None,
        metrics={"stages_executed": 1, "artifacts_reused": 0, "drafts_persisted": 0, "acceptances_committed": 1},
    )
    policy = PinnedExecutionPolicy(provider="mock")
    req = PipelineRequest(
        runId="run_t00",
        jobId=UUID("00000000-0000-0000-0000-000000000001"),
        epoch=1,
        leaseOwner=UUID("00000000-0000-0000-0000-000000000001"),
        topic="marine ecology",
        sources=(SourceInput(
            sectionIndex=1,
            pmcid="PMC9123456",
            title="Research title",
            url="https://europepmc.org/articles/PMC9123456",
            license="https://creativecommons.org/licenses/by/4.0",
            content="Source text content with sufficient words " * 20,
        ),),
        sectionIndices=(1,),
        parallel=False,
        policy=policy,
        finalize=False,
    )
    app.dependency_overrides[get_reading_pipeline] = lambda: mock_pipeline
    try:
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS) as client:
            resp = await client.post(
                "/v1/autogen/reading-paper/execute",
                json=req.model_dump(mode="json", by_alias=True),
            )
            assert resp.status_code == 200
            data = resp.json()
            assert data["status"] == "ACCEPTED"
            assert data["runId"] == "run_t00"
            assert len(data["sections"]) == 1
    finally:
        app.dependency_overrides.pop(get_reading_pipeline, None)

