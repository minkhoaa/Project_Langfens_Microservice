"""Security guards, nested leakage detection, and publication protection (RG08-S03).

Invariants:
- Attempt data leakage via nested fields; bypass role/tenant and publish research artifacts.
- All forbidden cases denied with security event and no data exposure.
- Metadata false is NOT the only publication guard (tampering fails closed with structural verification).
- Emits immutable SecurityAuditEvent for every blocked violation.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict, List, Literal, Optional, Set
from uuid import uuid4

from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.persistence.grammar_store import ResearchPublicationForbiddenError


class DataLeakageDetectedError(RuntimeError):
    """Raised when forbidden gold, rationale, or internal verdict is detected in nested fields."""


class RoleTenantAuthorizationError(RuntimeError):
    """Raised when actor role or tenant authorization check fails."""


class TamperedPublicationGuardError(RuntimeError):
    """Raised when metadata tampering is detected on research artifacts."""


FORBIDDEN_LEAK_KEYS: Set[str] = {
    "_gold_answer",
    "gold_answer",
    "goldAnswer",
    "reference_answer",
    "referenceAnswer",
    "proposed_answer",
    "proposedAnswer",
    "internal_verdict",
    "internalVerdict",
    "in_loop_pass",
    "inLoopPass",
    "private_rationale",
    "privateRationale",
    "ground_truth",
    "groundTruth",
}


class SecurityAuditEvent(CanonicalBaseModel):
    """Immutable audit record of a security violation attempt."""

    event_id: str = Field(default_factory=lambda: f"sec-evt-{uuid4().hex[:12]}")
    event_type: Literal[
        "DATA_LEAKAGE_ATTEMPT",
        "UNAUTHORIZED_TENANT_ACCESS",
        "ILLEGAL_RESEARCH_PUBLISH_ATTEMPT",
        "TAMPERED_METADATA_ATTEMPT",
    ]
    actor_id: str
    target_resource_id: str
    details: Dict[str, Any] = Field(default_factory=dict)
    blocked: bool = True
    timestamp: str = Field(
        default_factory=lambda: datetime.now(timezone.utc).isoformat()
    )


class SecurityGuardAndLeakageDetector:
    """Detects hostile nested leakage, verifies tenant/role boundaries, and blocks research publication."""

    def __init__(self) -> None:
        self._security_audit_log: List[SecurityAuditEvent] = []

    def scan_payload_for_leakage(
        self,
        payload: Any,
        actor_id: str = "unknown",
        target_resource_id: str = "unknown",
    ) -> None:
        """Deeply scans payload for forbidden nested answer or internal verdict fields.

        Fails closed with DataLeakageDetectedError and logs a SecurityAuditEvent upon discovery.
        """
        leaked_key = self._find_forbidden_key(payload)
        if leaked_key:
            event = SecurityAuditEvent(
                event_type="DATA_LEAKAGE_ATTEMPT",
                actor_id=actor_id,
                target_resource_id=target_resource_id,
                details={
                    "detected_forbidden_key": leaked_key,
                    "violation": "Nested gold or internal verdict detected in solver/student-facing view",
                },
                blocked=True,
            )
            self._security_audit_log.append(event)
            raise DataLeakageDetectedError(
                f"DATA_LEAKAGE_DETECTED: Forbidden gold or internal verdict leaked in nested field '{leaked_key}'."
            )

    def _find_forbidden_key(self, obj: Any) -> Optional[str]:
        """Recursively traverses object to find any key belonging to FORBIDDEN_LEAK_KEYS."""
        if isinstance(obj, dict):
            for k, v in obj.items():
                if k in FORBIDDEN_LEAK_KEYS:
                    return k
                nested_match = self._find_forbidden_key(v)
                if nested_match:
                    return nested_match
        elif isinstance(obj, (list, tuple, set)):
            for item in obj:
                nested_match = self._find_forbidden_key(item)
                if nested_match:
                    return nested_match
        elif hasattr(obj, "__dict__"):
            return self._find_forbidden_key(obj.__dict__)
        return None

    def validate_access(
        self,
        actor_id: str,
        actor_role: str,
        actor_tenant_id: str,
        resource_tenant_id: str,
        resource_id: str,
    ) -> bool:
        """Validates tenant boundaries and role authorization for research resources."""
        if actor_tenant_id != resource_tenant_id:
            event = SecurityAuditEvent(
                event_type="UNAUTHORIZED_TENANT_ACCESS",
                actor_id=actor_id,
                target_resource_id=resource_id,
                details={
                    "actor_tenant_id": actor_tenant_id,
                    "resource_tenant_id": resource_tenant_id,
                    "reason": "Cross-tenant access strictly forbidden",
                },
                blocked=True,
            )
            self._security_audit_log.append(event)
            raise RoleTenantAuthorizationError(
                f"AUTH_DENIED: Cross-tenant access forbidden ({actor_tenant_id} != {resource_tenant_id})."
            )

        allowed_roles = {"ADMIN", "RESEARCHER_AUTHORIZED"}
        if actor_role.upper() not in allowed_roles:
            event = SecurityAuditEvent(
                event_type="UNAUTHORIZED_TENANT_ACCESS",
                actor_id=actor_id,
                target_resource_id=resource_id,
                details={
                    "actor_role": actor_role,
                    "reason": f"Role '{actor_role}' lacks required research access permission",
                },
                blocked=True,
            )
            self._security_audit_log.append(event)
            raise RoleTenantAuthorizationError(
                f"AUTH_DENIED: Role '{actor_role}' lacks permission to access research artifact."
            )

        return True

    def validate_publication_eligibility(
        self,
        artifact_metadata: Dict[str, Any],
        content_tags: List[str],
        run_id: str,
        actor_id: str,
        actor_role: str,
    ) -> bool:
        """Multi-layer structural guard verifying production publish eligibility.

        Guarantees that metadata tampering (setting publish_eligible=True) cannot bypass deep structural guards.
        """
        # Role check
        if actor_role.upper() != "ADMIN":
            event = SecurityAuditEvent(
                event_type="ILLEGAL_RESEARCH_PUBLISH_ATTEMPT",
                actor_id=actor_id,
                target_resource_id=run_id,
                details={"reason": "Only authorized Admin can publish exams"},
                blocked=True,
            )
            self._security_audit_log.append(event)
            raise ResearchPublicationForbiddenError(
                "RESEARCH_PUBLICATION_FORBIDDEN: Only authorized Admin can publish."
            )

        # Multi-layer structural check for research artifact
        is_research_run = (
            run_id.startswith("pilot-")
            or run_id.startswith("run-bench-")
            or run_id.startswith("research-")
        )
        has_research_tag = any("RESEARCH" in tag.upper() for tag in content_tags)
        is_flagged_research = artifact_metadata.get("is_research", False) is True

        # Anti-tampering check: Flag is True, but structural indicators prove it is a research artifact
        if artifact_metadata.get("publish_eligible") is True and (
            is_research_run or has_research_tag or is_flagged_research
        ):
            event = SecurityAuditEvent(
                event_type="TAMPERED_METADATA_ATTEMPT",
                actor_id=actor_id,
                target_resource_id=run_id,
                details={
                    "reason": "Tampered publish_eligible=True flag detected on research artifact",
                    "is_research_run": is_research_run,
                    "has_research_tag": has_research_tag,
                },
                blocked=True,
            )
            self._security_audit_log.append(event)
            raise ResearchPublicationForbiddenError(
                "RESEARCH_PUBLICATION_FORBIDDEN: Tampered metadata detected. Research artifact cannot be published to production."
            )

        # Standard research publication rejection
        if is_research_run or has_research_tag or is_flagged_research or not artifact_metadata.get("publish_eligible"):
            event = SecurityAuditEvent(
                event_type="ILLEGAL_RESEARCH_PUBLISH_ATTEMPT",
                actor_id=actor_id,
                target_resource_id=run_id,
                details={"reason": "Research artifact cannot be published to production"},
                blocked=True,
            )
            self._security_audit_log.append(event)
            raise ResearchPublicationForbiddenError(
                "RESEARCH_PUBLICATION_FORBIDDEN: Research artifact cannot be published to production."
            )

        return True

    def get_security_events(self) -> List[SecurityAuditEvent]:
        """Returns the chronological audit log of all security violation events."""
        return list(self._security_audit_log)
