"""Verification script exercising the actual FastAPI route /section under V2 and legacy modes."""

import json
from pathlib import Path
from uuid import uuid4

from fastapi.testclient import TestClient

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.facade import get_generation_facade
from app.main import app
from app.providers.gateway import ProviderGateway
from app.providers.registry import ProviderRegistry
from tests.test_t08_passage_loop import (
    DurableStoreFake,
    FakePassageProvider,
    _generate_academic_passage,
)


def run_verification():
    client = TestClient(app)
    print("=== EXERCISING ACTUAL SERVICE ROUTE (/section) ===")

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

    provider = FakePassageProvider(passage_text=valid_passage, title="Neolithic Archaeology")
    store_path = Path("/tmp/route_fresh_test_script.db")
    if store_path.exists():
        store_path.unlink()
    owner_id = uuid4()
    store = DurableStoreFake(store_path, owner=owner_id, epoch=1)
    reg = ProviderRegistry()
    reg.register_provider(provider, keys=["fake_key_12345678"])
    gateway = ProviderGateway(registry=reg, checkpoint_client=store)

    facade = get_generation_facade()
    facade._gateway = gateway
    facade._persistence_client = store
    facade._passage_generator.gateway = gateway

    fresh_run_id = f"run_fresh_{uuid4().hex[:8]}"

    # Scenario 1: Short source (< 50 chars) -> typed SOURCE_INSUFFICIENT
    resp_short = client.post(
        "/api/v1/autogen/reading-paper/section",
        json={
            "topic": "Neolithic Settlements",
            "index": 1,
            "source": {"content": "Too short."},
            "runId": fresh_run_id,
            "epoch": 1,
            "leaseOwner": str(owner_id),
            "parentOperationId": "op_test",
            "engine": "v2",
        },
    )
    print("Scenario 1 (short source):", resp_short.json())
    assert resp_short.json()["decision"] == "FAIL"
    assert resp_short.json()["terminalReasonCode"] == "SOURCE_INSUFFICIENT"

    # Scenario 2: Missing dependencies -> typed STALE_DEPENDENCY
    resp_missing = client.post(
        "/api/v1/autogen/reading-paper/section",
        json={
            "topic": "Neolithic Settlements",
            "index": 1,
            "source": {"content": source_facts},
            "runId": fresh_run_id,
            "epoch": 1,
            "leaseOwner": str(owner_id),
            "parentOperationId": "op_test",
            "engine": "v2",
        },
    )
    print("Scenario 2 (missing deps):", resp_missing.json())
    assert resp_missing.json()["decision"] == "FAIL"
    assert resp_missing.json()["terminalReasonCode"] == "STALE_DEPENDENCY"

    # Scenario 3: Authoritatively seed accepted dependencies into store
    bp_art = ArtifactEnvelope.create("art_bp_01", ArtifactType.EXAM_BLUEPRINT, fresh_run_id, {"title": "BP"}, "2.0.0")
    eg_art = ArtifactEnvelope.create("art_eg_01", ArtifactType.EVIDENCE_GRAPH, fresh_run_id, {"title": "EG"}, "2.0.0")
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": bp_art, "evaluations": []})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": eg_art, "evaluations": []})())

    initial_call_count = provider.call_count

    resp_v2_ok = client.post(
        "/api/v1/autogen/reading-paper/section",
        json={
            "topic": "Neolithic Settlements",
            "index": 1,
            "source": {"content": source_facts},
            "runId": fresh_run_id,
            "epoch": 1,
            "leaseOwner": str(owner_id),
            "parentOperationId": "op_test",
            "engine": "v2",
            "blueprintRef": bp_art.to_ref().model_dump(by_alias=True, mode="json"),
            "evidenceGraphRef": eg_art.to_ref().model_dump(by_alias=True, mode="json"),
        },
    )
    print("Scenario 3 (fresh generation): status =", resp_v2_ok.status_code, "wordCount =", resp_v2_ok.json().get("wordCount"))
    assert resp_v2_ok.status_code == 200
    assert "passage" in resp_v2_ok.json()
    assert 720 <= resp_v2_ok.json()["wordCount"] <= 915
    assert provider.call_count > initial_call_count, "Fresh provider execution MUST be exercised!"

    # Scenario 4: V2 + NDJSON
    run_id_nd = f"run_nd_{uuid4().hex[:8]}"
    bp_art_nd = ArtifactEnvelope.create("art_bp_02", ArtifactType.EXAM_BLUEPRINT, run_id_nd, {"title": "BP"}, "2.0.0")
    eg_art_nd = ArtifactEnvelope.create("art_eg_02", ArtifactType.EVIDENCE_GRAPH, run_id_nd, {"title": "EG"}, "2.0.0")
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": bp_art_nd, "evaluations": []})())
    store.commit_checkpoint(type("Req", (), {"epoch": 1, "leaseOwner": owner_id, "artifact": eg_art_nd, "evaluations": []})())

    resp_nd = client.post(
        "/api/v1/autogen/reading-paper/section",
        headers={"accept": "application/x-ndjson"},
        json={
            "topic": "Neolithic Settlements",
            "index": 1,
            "source": {"content": source_facts},
            "runId": run_id_nd,
            "epoch": 1,
            "leaseOwner": str(owner_id),
            "parentOperationId": "op_test",
            "engine": "v2",
            "blueprintRef": bp_art_nd.to_ref().model_dump(by_alias=True, mode="json"),
            "evidenceGraphRef": eg_art_nd.to_ref().model_dump(by_alias=True, mode="json"),
        },
    )
    assert resp_nd.status_code == 200
    lines = [json.loads(line) for line in resp_nd.text.strip().split("\n")]
    assert any(l.get("type") == "section" for l in lines)

    print("=== ALL 4 SERVICE ROUTE SCENARIOS VERIFIED SUCCESSFULLY! ===")


if __name__ == "__main__":
    run_verification()
