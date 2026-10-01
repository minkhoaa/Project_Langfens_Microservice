"""EvidenceGraph capability for Langfens Loop Engine V2.

Hard Invariants:
- Only ACCEPTED verified graphs may be consumed downstream by passage generation.
- Zero unverified claims in accepted graph fixtures.
- Invalid or distorted claims trigger REJECTED status with structured issues.
- Excerpts outside coverage produce INSUFFICIENT_EVIDENCE or REJECTED.
- Packages cleanly into ArtifactEnvelope for durable PostgreSQL persistence.
- Downstream invalidation when parent SourcePack changes revision or hash.
"""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
import hashlib
from typing import List, Optional, Tuple
from pydantic import BaseModel, ConfigDict, Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evidence import (
    AbsenceAssessment,
    EvidenceGraph,
    SourceOffset,
    VerifiedClaim,
)
from app.contracts.issue import (
    Issue,
    IssueCode,
    IssueScope,
    IssueSeverity,
)
from app.contracts.source import SourcePack
from app.evidence.extractor import AtomicClaim
from app.evidence.validators import ClaimValidationResult, EvidenceValidator
from app.ingestion.chunker import CoverageMap

MIN_VERIFIED_CLAIMS_FOR_PASSAGE = 3


class EvidenceGraphStatus(str, Enum):
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"
    INSUFFICIENT_EVIDENCE = "INSUFFICIENT_EVIDENCE"


class EvidenceGraphBuildResult(BaseModel):
    """Result of building and independently verifying an EvidenceGraph."""

    model_config = ConfigDict(frozen=True)

    graph: Optional[EvidenceGraph] = None
    status: EvidenceGraphStatus
    verified_claims: List[VerifiedClaim] = Field(default_factory=list)
    rejected_claims: List[ClaimValidationResult] = Field(default_factory=list)
    issues: List[Issue] = Field(default_factory=list)
    blocking_reason: Optional[str] = None


class EvidenceGraphBuilder:
    """Orchestrates claim validation and constructs canonical EvidenceGraph instances."""

    @staticmethod
    def build_evidence_graph(
        graph_id: str,
        run_id: str,
        candidate_claims: List[AtomicClaim | VerifiedClaim],
        source_text: str,
        source_pack: Optional[SourcePack] = None,
        section_id: Optional[int] = None,
        coverage_map: Optional[CoverageMap] = None,
        absence_assessments: Optional[List[AbsenceAssessment]] = None,
        fail_closed_on_any_invalid: bool = True,
    ) -> EvidenceGraphBuildResult:
        """Validates each claim against source text and constructs an EvidenceGraph.

        Invariants:
        - If fail_closed_on_any_invalid is True, any distorted/unsupported claim fails the entire graph.
        - Only claims passing all code and semantic checks are included.
        - Zero unverified claims in an ACCEPTED graph.
        """
        source_pack_ref = (
            ArtifactRef(
                artifactId=source_pack.pack_id,
                artifactType=ArtifactType.SOURCE_PACK,
                version=source_pack.revision,
                contentHash=hashlib.sha256(source_pack.model_dump_json(by_alias=True).encode()).hexdigest(),
            )
            if source_pack
            else None
        )

        verified_claims: List[VerifiedClaim] = []
        rejected_results: List[ClaimValidationResult] = []
        all_issues: List[Issue] = []

        for candidate in candidate_claims:
            val_result = EvidenceValidator.validate_claim(
                claim=candidate,
                source_text=source_text,
                coverage_map=coverage_map,
                source_pack_ref=source_pack_ref,
            )

            if val_result.is_valid:
                if isinstance(candidate, AtomicClaim):
                    vc = candidate.to_verified_claim(
                        entailment=val_result.entailment,
                        confidence=1.0,
                    )
                else:
                    vc = candidate
                verified_claims.append(vc)
            else:
                rejected_results.append(val_result)
                all_issues.extend(val_result.issues)

        # Evaluate graph status
        if fail_closed_on_any_invalid and rejected_results:
            first_blocking = next((iss.message for iss in all_issues if iss.severity == IssueSeverity.CRITICAL), "Claims failed verification")
            return EvidenceGraphBuildResult(
                graph=None,
                status=EvidenceGraphStatus.REJECTED,
                verified_claims=[],
                rejected_claims=rejected_results,
                issues=all_issues,
                blocking_reason=first_blocking,
            )

        if len(verified_claims) < MIN_VERIFIED_CLAIMS_FOR_PASSAGE:
            issue = Issue.create(
                issue_id=f"iss_insufficient_claims_{graph_id}",
                code=IssueCode.SOURCE_INSUFFICIENT,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.EVIDENCE,
                message=(
                    f"EvidenceGraph has only {len(verified_claims)} verified claims "
                    f"(minimum required: {MIN_VERIFIED_CLAIMS_FOR_PASSAGE})"
                ),
                affected_refs=[source_pack_ref] if source_pack_ref else [],
            )
            all_issues.append(issue)
            return EvidenceGraphBuildResult(
                graph=None,
                status=EvidenceGraphStatus.INSUFFICIENT_EVIDENCE,
                verified_claims=verified_claims,
                rejected_claims=rejected_results,
                issues=all_issues,
                blocking_reason="Insufficient verified claims to construct passage",
            )

        graph = EvidenceGraph(
            graphId=graph_id,
            runId=run_id,
            sectionId=section_id,
            claims=verified_claims,
            absenceAssessments=absence_assessments or [],
            verifiedAt=datetime.now(timezone.utc),
        )

        return EvidenceGraphBuildResult(
            graph=graph,
            status=EvidenceGraphStatus.ACCEPTED,
            verified_claims=verified_claims,
            rejected_claims=rejected_results,
            issues=all_issues,
            blocking_reason=None,
        )

    @staticmethod
    def to_artifact_envelope(
        graph: EvidenceGraph,
        source_pack_ref: ArtifactRef,
    ) -> ArtifactEnvelope:
        """Encapsulates the verified EvidenceGraph for Phase 02 durable storage."""
        raw_json = graph.model_dump_json(by_alias=True)
        content_hash = hashlib.sha256(raw_json.encode()).hexdigest()

        return ArtifactEnvelope(
            artifactId=graph.graph_id,
            artifactType=ArtifactType.EVIDENCE_GRAPH,
            version=1,
            runId=graph.run_id,
            sectionId=graph.section_id,
            schemaVersion="1.0.0",
            contentHash=content_hash,
            createdAt=graph.verified_at,
            producerVersion="v2.0.0",
            payload=graph.model_dump(by_alias=True),
            parentRefs=[source_pack_ref],
        )
