"""Unit and integration test suite for RG08-S03: Auth, evidence-view and publication negative cases.

Invariants:
- Attempt data leakage via nested fields; bypass role/tenant and publish research artifacts.
- All forbidden cases denied with security event and no data exposure.
- Metadata false is NOT the only publication guard (tampering with metadata still fails closed).
- Emits immutable SecurityAuditEvent for every blocked violation.
- Strict Reading V2 nonregression and security boundaries remain intact.
"""

from __future__ import annotations

import pytest

from app.experiment.security import (
    DataLeakageDetectedError,
    ResearchPublicationForbiddenError,
    RoleTenantAuthorizationError,
    SecurityAuditEvent,
    SecurityGuardAndLeakageDetector,
    TamperedPublicationGuardError,
)


def test_pos_rg08_s03_all_forbidden_cases_denied_with_security_event_and_no_exposure() -> None:
    """POS-RG08-S03: All forbidden cases denied with security event and no data exposure.

    Evidence identifies input fixture/source and observed output.
    """
    guard = SecurityGuardAndLeakageDetector()

    # 1. Attempt data leakage via nested fields in student / solver payload
    hostile_payload = {
        "question_id": "q-101",
        "prompt": "What causes the aurora?",
        "options": ["Solar wind", "Moonlight", "Clouds"],
        "metadata": {
            "display_order": 1,
            "nested_context": {
                "_gold_answer": "Solar wind",  # Hostile nested leak!
                "private_rationale": "Directly stated in passage paragraph 1",
            },
        },
    }

    with pytest.raises(DataLeakageDetectedError, match="DATA_LEAKAGE_DETECTED"):
        guard.scan_payload_for_leakage(
            payload=hostile_payload,
            actor_id="attacker-01",
            target_resource_id="item-reading-101",
        )

    # 2. Attempt role/tenant bypass
    with pytest.raises(RoleTenantAuthorizationError, match="AUTH_DENIED"):
        guard.validate_access(
            actor_id="user-external",
            actor_role="STUDENT",
            actor_tenant_id="tenant-beta",
            resource_tenant_id="tenant-alpha",  # Cross-tenant access
            resource_id="research-corpus-01",
        )

    # 3. Attempt research artifact publication to production
    research_metadata = {
        "dataset_item_id": "item-research-01",
        "run_id": "pilot-reading-01",
        "is_research": True,
        "publish_eligible": False,
    }
    with pytest.raises(ResearchPublicationForbiddenError, match="RESEARCH_PUBLICATION_FORBIDDEN"):
        guard.validate_publication_eligibility(
            artifact_metadata=research_metadata,
            content_tags=["RESEARCH_PILOT", "UNPUBLISHABLE"],
            run_id="pilot-reading-01",
            actor_id="admin-user-01",
            actor_role="ADMIN",
        )

    # Invariant: Each forbidden attempt generated an immutable security audit event
    events = guard.get_security_events()
    assert len(events) == 3
    event_types = {e.event_type for e in events}
    assert "DATA_LEAKAGE_ATTEMPT" in event_types
    assert "UNAUTHORIZED_TENANT_ACCESS" in event_types
    assert "ILLEGAL_RESEARCH_PUBLISH_ATTEMPT" in event_types

    # Invariant: All events show blocked=True
    for ev in events:
        assert ev.blocked is True


def test_neg_rg08_s03_metadata_false_is_not_the_only_publication_guard() -> None:
    """NEG-RG08-S03: Metadata false is not the only publication guard.

    Tampering with metadata (e.g. setting publish_eligible=True) cannot bypass deep structural guards.
    """
    guard = SecurityGuardAndLeakageDetector()

    # Attacker tampers with metadata to claim publish_eligible=True on a research run
    tampered_metadata = {
        "dataset_item_id": "item-research-02",
        "run_id": "pilot-reading-tampered",
        "is_research": True,
        "publish_eligible": True,  # TAMPERED FLAG
    }

    # Deep structural guard detects research run prefix / research tags and blocks publish
    with pytest.raises(ResearchPublicationForbiddenError, match="RESEARCH_PUBLICATION_FORBIDDEN"):
        guard.validate_publication_eligibility(
            artifact_metadata=tampered_metadata,
            content_tags=["RESEARCH_PILOT"],
            run_id="pilot-reading-tampered",
            actor_id="malicious-admin",
            actor_role="ADMIN",
        )

    # Verify a security event was logged for the tampered attempt
    tampered_events = [
        e for e in guard.get_security_events() if e.event_type == "TAMPERED_METADATA_ATTEMPT"
    ]
    assert len(tampered_events) == 1
    assert tampered_events[0].blocked is True


def test_edge_rg08_s03_empty_and_deeply_nested_clean_payloads() -> None:
    """EDGE-RG08-S03: Test deeply nested clean payloads, empty dictionaries, and none values."""
    guard = SecurityGuardAndLeakageDetector()

    # Empty payload passes without error
    guard.scan_payload_for_leakage(payload={}, actor_id="user-1", target_resource_id="res-1")

    # Clean nested payload (no leakage keys) passes safely
    clean_nested = {
        "section": {
            "group": {
                "question": {
                    "text": "What is the primary gas in Venus' atmosphere?",
                    "options": ["CO2", "Nitrogen", "Oxygen"],
                }
            }
        }
    }
    guard.scan_payload_for_leakage(
        payload=clean_nested,
        actor_id="user-1",
        target_resource_id="res-clean",
    )

    # No security violation events generated for clean payloads
    assert len(guard.get_security_events()) == 0


def test_reg_rg08_s03_strict_v2_admin_publish_preserves_legitimate_flow() -> None:
    """REG-RG08-S03: Legitimate production draft publish by authorized Admin continues to succeed."""
    guard = SecurityGuardAndLeakageDetector()

    legitimate_production_metadata = {
        "exam_id": "exam-prod-v2-01",
        "run_id": "run-prod-v2-100",
        "is_research": False,
        "publish_eligible": True,
        "has_v2_accepted_closure": True,
        "questions_count": 40,
    }

    # Authorized admin publishing legitimate production draft succeeds
    res = guard.validate_publication_eligibility(
        artifact_metadata=legitimate_production_metadata,
        content_tags=["PRODUCTION_DRAFT", "STRICT_V2"],
        run_id="run-prod-v2-100",
        actor_id="admin-authorized",
        actor_role="ADMIN",
    )
    assert res is True


def test_runner_provenance_clean_of_forbidden_serialized_aliases() -> None:
    """Ensures runner provenance dicts never contain private answer aliases or canary tokens."""
    import json
    from app.contracts.solver import scan_text_for_security_leaks
    from app.experiment.runners import ConfigurationARunner, ConfigurationCRunner
    from app.contracts.research import StandaloneReadingRequest, ReadingTask, StandaloneGroupType

    req = StandaloneReadingRequest(
        run_id="run-prov-check-01",
        dataset_item_id="item-prov-01",
        configuration_id="C",
        task=ReadingTask(
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=1,
            difficulty="MEDIUM",
        ),
        source_pack_id="src-pack-01",
    )
    runner = ConfigurationCRunner()
    # Mock client emits minimal output
    result, trace, usage = runner.generate_reading(
        request=req,
        passage_text="This is a test passage with at least fifty characters for valid length.",
        prompt_version="v3.2",
        foundation_model_id="test-model",
    )
    prov_str = json.dumps(usage["provenance"])
    # scan_text_for_security_leaks must not raise SecurityLeakageError
    scan_text_for_security_leaks(prov_str)
    trace_str = json.dumps(trace["provenance"])
    scan_text_for_security_leaks(trace_str)
