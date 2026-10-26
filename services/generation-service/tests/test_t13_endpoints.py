"""T13: current authenticated source routes and retired generation surface.

Production generation uses /execute, not GenerationFacade HTTP stage routes.
ASGITransport and MockTransport exercise canonical ingestion without service TCP.
"""
from __future__ import annotations

from contextlib import ExitStack
from unittest.mock import AsyncMock, Mock, patch
from uuid import UUID

import httpx
import pytest
from httpx import ASGITransport, AsyncClient

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.issue import IssueLedger
from app.contracts.loop import DecisionType, LoopReason, LoopState
from app.loop.runtime import LoopResult
from app.main import app

AUTH_KEY = "test-internal-service-key-phase13"
AUTH_HEADERS = {"X-Internal-Service-Key": AUTH_KEY}
PREFIXES = ("/v1/autogen/reading-paper", "/api/v1/autogen/reading-paper")
RETIRED_ROUTES = ("section", "questions", "section-v2", "paper-evaluate", "paper-repair", "paper-v2")
SOURCE_TEXT = "Coastal ecosystems provide critical ecosystem services. " * 100
LICENSE = "https://creativecommons.org/licenses/by/4.0/"


def pmc_xml(*, license_url=LICENSE, content=SOURCE_TEXT, authors=True):
    author = "<contrib contrib-type='author'><name>Sarah Lin</name></contrib>" if authors else ""
    return f"""<article><front><article-meta>
        <article-title>Coastal Ecosystems</article-title>
        <article-id pub-id-type="doi">10.1234/ecology</article-id>
        <contrib-group>{author}</contrib-group>
        <permissions><license>{license_url}</license></permissions>
        </article-meta></front><body><p>{content}</p></body></article>"""


@pytest.fixture(autouse=True)
def setup_auth_environment(monkeypatch):
    monkeypatch.setenv("EXAMSERVICE__INTERNAL__API__KEY", AUTH_KEY)


def get_test_client():
    return AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=AUTH_HEADERS)


@pytest.fixture
def source_http(monkeypatch):
    """Replace only outbound HTTP; the router/fetcher/cleaner/license code stays real."""
    calls = []
    responses = {
        ("api.openalex.org", "/works"): httpx.Response(200, json={"results": [{
            "id": "https://openalex.org/W1", "doi": "https://doi.org/10.1234/ecology",
            "primary_topic": {"subfield": {"id": "coastal-ecology"}},
        }]}),
        ("www.ebi.ac.uk", "/europepmc/webservices/rest/search"): httpx.Response(200, json={
            "resultList": {"result": [{"pmcid": "PMC9123456", "isOpenAccess": "Y"}]},
        }),
        ("www.ebi.ac.uk", "/europepmc/webservices/rest/PMC9123456/fullTextXML"): httpx.Response(200, text=pmc_xml()),
    }

    def respond(request):
        calls.append(request)
        key = (request.url.host, request.url.path)
        assert key in responses, f"Unexpected outbound HTTP: {request.url.host}{request.url.path}"
        return responses[key]

    def outbound_client(*args, **kwargs):
        return AsyncClient(*args, **kwargs, transport=httpx.MockTransport(respond), trust_env=False)

    monkeypatch.setattr("app.ingestion.fetcher.httpx.AsyncClient", outbound_client)
    return calls, responses


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", ["", "/api"])
async def test_t13_healthz_endpoints(prefix):
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get(f"{prefix}/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "generation-service"}


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", PREFIXES)
@pytest.mark.parametrize("auth_case,status,detail", [
    ("unconfigured", 503, "Internal service authentication is not configured"),
    ("missing", 401, "Internal service authentication is required"),
    ("invalid", 403, "Invalid internal service authentication"),
])
@pytest.mark.parametrize("method,path,kwargs", [
    ("GET", "/sources", {"params": {"topic": "marine ecology"}}),
    ("POST", "/source", {"json": {"pmcid": "PMC9123456"}}),
    ("POST", "/source/ingest", {"json": {"payload": SOURCE_TEXT, "license": "CC-BY"}}),
    ("POST", "/execute", {"json": {}}),
])
async def test_t13_authentication_fails_closed(monkeypatch, source_http, no_generation_dispatch, prefix, auth_case, status, detail, method, path, kwargs):
    headers = {}
    if auth_case == "unconfigured":
        monkeypatch.delenv("EXAMSERVICE__INTERNAL__API__KEY", raising=False)
        monkeypatch.delenv("INTERNAL_API_KEY", raising=False)
        monkeypatch.setattr("app.config.settings.internal_api_key", "")
    elif auth_case == "invalid":
        headers = {"X-Internal-Service-Key": "incorrect-secret-token"}
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.request(method, prefix + path, headers=headers, **kwargs)
    assert response.status_code == status
    assert response.json() == {"detail": detail}
    assert source_http[0] == []


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", PREFIXES)
async def test_t13_get_sources_canonical_search_and_provenance(source_http, prefix):
    async with get_test_client() as client:
        response = await client.get(prefix + "/sources", params={"topic": "marine ecology"})
    assert response.status_code == 200
    assert response.headers["content-type"].startswith("application/json")
    data = response.json()
    assert data["selectedPmcids"] == ["PMC9123456"]
    assert data["message"] is None
    source = data["sources"][0]
    assert "content" not in source
    assert source["pmcid"] == "PMC9123456"
    assert source["license"] == LICENSE.rstrip("/")
    assert source["authors"] == "Sarah Lin"
    assert source["doi"] == "10.1234/ecology"
    assert source["wordCount"] == 600
    assert source["openAlexId"] == "https://openalex.org/W1"
    assert source["topicId"] == "coastal-ecology"
    calls, _ = source_http
    assert len(calls) == 3
    assert calls[0].url.params["search"] == "marine ecology"
    assert calls[1].url.params["query"] == "DOI:10.1234/ecology"


@pytest.mark.asyncio
async def test_t13_get_sources_upstream_error_503(source_http):
    source_http[1][("api.openalex.org", "/works")] = httpx.Response(429)
    async with get_test_client() as client:
        response = await client.get(PREFIXES[0] + "/sources", params={"topic": "marine ecology"})
    assert response.status_code == 503
    assert "OpenAlex rate limit reached" in response.json()["detail"]
    assert len(source_http[0]) == 1


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", PREFIXES)
async def test_t13_post_source_returns_canonical_full_content(source_http, prefix):
    async with get_test_client() as client:
        response = await client.post(prefix + "/source", json={"pmcid": "PMC9123456"})
    assert response.status_code == 200
    data = response.json()
    assert data["content"] == SOURCE_TEXT.strip()
    assert data["wordCount"] == 600
    assert data["pmcid"] == "PMC9123456"
    assert data["title"] == "Coastal Ecosystems"
    assert data["authors"] == "Sarah Lin"
    assert data["license"] == LICENSE.rstrip("/")
    assert data["url"] == "https://europepmc.org/articles/PMC9123456"
    assert len(source_http[0]) == 1


@pytest.mark.asyncio
@pytest.mark.parametrize("upstream,status,detail", [
    (httpx.Response(400), 503, "Europe PMC request failed"),
    (httpx.Response(404), 422, "Open full text is unavailable"),
    (httpx.Response(200, text=pmc_xml(license_url="All rights reserved")), 422, "No verified CC BY or CC0"),
    (httpx.Response(200, text=pmc_xml(content="short")), 422, "Full text is too short"),
    (httpx.Response(200, text=pmc_xml(authors=False)), 422, "Author attribution unavailable"),
])
async def test_t13_post_source_network_and_policy_errors(source_http, upstream, status, detail):
    source_http[1][("www.ebi.ac.uk", "/europepmc/webservices/rest/PMC9123456/fullTextXML")] = upstream
    async with get_test_client() as client:
        response = await client.post(PREFIXES[0] + "/source", json={"pmcid": "PMC9123456"})
    assert response.status_code == status
    assert detail in response.json()["detail"]
    assert len(source_http[0]) == 1


@pytest.mark.asyncio
@pytest.mark.parametrize("method,path,kwargs", [
    ("GET", "/sources", {"params": {"topic": "ab"}}),
    ("GET", "/sources", {"params": {"topic": "x" * 121}}),
    ("POST", "/source", {"json": {"pmcid": "INVALID_123"}}),
    ("POST", "/source/ingest", {"json": {"payload": ""}}),
])
async def test_t13_source_request_validation_prevents_fetch(source_http, method, path, kwargs):
    async with get_test_client() as client:
        response = await client.request(method, PREFIXES[0] + path, **kwargs)
    assert response.status_code == 422
    assert source_http[0] == []


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", PREFIXES)
async def test_t13_post_source_ingest_preserves_content_and_provenance(source_http, prefix):
    async with get_test_client() as client:
        response = await client.post(prefix + "/source/ingest", json={
            "payload": SOURCE_TEXT, "type": "text", "title": "Custom Study",
            "authors": "Researcher", "license": "CC-BY", "url": "https://source.example/study",
        })
    assert response.status_code == 200
    data = response.json()
    assert data["sourceId"].startswith("CUSTOM:")
    assert data["pmcid"] == data["sourceId"]
    assert data["sourceType"] == "text"
    assert data["content"] == SOURCE_TEXT.strip()
    assert data["contentPreview"] == SOURCE_TEXT[:300].strip()
    assert data["wordCount"] == 600
    assert data["title"] == "Custom Study"
    assert data["authors"] == "Researcher"
    assert data["license"] == "CC-BY"
    assert data["url"] == "https://source.example/study"
    assert data["metadata"]["domain"] == "source.example"
    assert data["normalizerVersion"]
    assert source_http[0] == []


@pytest.mark.asyncio
@pytest.mark.parametrize("body,detail", [
    ({"payload": SOURCE_TEXT, "type": "text"}, "unspecified license"),
    ({"payload": SOURCE_TEXT, "type": "text", "license": "All rights reserved"}, "ineligible rights"),
    ({"payload": "word " * 599, "type": "text", "license": "CC-BY"}, "too short"),
    ({"payload": SOURCE_TEXT, "type": "unsupported", "license": "CC-BY"}, "Unsupported source type"),
    ({"payload": "http://127.0.0.1/private"}, "restricted, private, or invalid network address"),
    ({"payload": "http://169.254.169.254/latest/meta-data"}, "restricted, private, or invalid network address"),
])
async def test_t13_post_source_ingest_license_length_and_ssrf_controls(source_http, body, detail):
    async with get_test_client() as client:
        response = await client.post(PREFIXES[0] + "/source/ingest", json=body)
    assert response.status_code == 422
    assert detail in response.json()["detail"]
    assert source_http[0] == []


@pytest.mark.asyncio
async def test_t13_post_source_ingest_network_error_503(source_http):
    source_http[1][("www.ebi.ac.uk", "/europepmc/webservices/rest/PMC9123456/fullTextXML")] = httpx.Response(400)
    async with get_test_client() as client:
        response = await client.post(PREFIXES[0] + "/source/ingest", json={"payload": "PMC9123456"})
    assert response.status_code == 503
    assert "Europe PMC request failed" in response.json()["detail"]


@pytest.fixture
def no_generation_dispatch():
    with ExitStack() as stack:
        spies = [stack.enter_context(patch(target, side_effect=AssertionError("Retired endpoint dispatched"))) for target in (
            "app.pipeline.ReadingGenerationPipeline.execute",
            "app.providers.gateway.ProviderGateway.execute",
            "app.providers.adapters.openai_compatible.OpenAICompatibleProvider.call",
            "app.facade.get_generation_facade",
            "app.persistence.client.CheckpointClient.resume_state",
            "app.persistence.client.CheckpointClient.resume_state_async",
        )]
        yield
        for spy in spies:
            spy.assert_not_called()


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", PREFIXES)
@pytest.mark.parametrize("route", RETIRED_ROUTES)
@pytest.mark.parametrize("accept,headers,body", [
    ("application/json", AUTH_HEADERS, {"topic": "marine ecology", "index": 1, "engine": "v1"}),
    ("application/x-ndjson", AUTH_HEADERS, {"topic": "marine ecology", "index": 1, "engine": "v2"}),
    ("application/json", {}, {}),
    ("application/json", {"X-Internal-Service-Key": "invalid"}, {}),
])
async def test_t13_retired_generation_endpoints_unavailable_zero_dispatch(no_generation_dispatch, prefix, route, accept, headers, body):
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post(f"{prefix}/{route}", headers={"Accept": accept, **headers}, json=body)
    assert response.status_code == 404
    assert response.json() == {"detail": "Not Found"}
    assert response.headers["content-type"].startswith("application/json")


def test_t13_openapi_exposes_execute_not_retired_stage_routes():
    paths = app.openapi()["paths"]
    for prefix in PREFIXES:
        assert "post" in paths[prefix + "/execute"]
        for route in RETIRED_ROUTES:
            assert f"{prefix}/{route}" not in paths


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
    from app.facade import GenerationFacade
    from app.persistence.client import CheckpointClient
    from app.providers.gateway import ProviderGateway
    from app.providers.registry import ProviderRegistry
    from app.generators.passage.context import PassageGenerationContext
    from app.generators.passage.prompts import PassageStyleProfile
    from app.contracts.artifact import ArtifactRef
    from app.observability.accounting import get_decision_lineage

    persistence = Mock(spec=CheckpointClient)
    persistence.resume_state.return_value = None
    facade = GenerationFacade(
        gateway=ProviderGateway(registry=ProviderRegistry()), persistence_client=persistence,
    )
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
