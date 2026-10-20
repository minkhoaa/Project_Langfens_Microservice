"""Immutable wire contracts for the single unified Reading generation path."""
from __future__ import annotations

from typing import Any, Literal, Tuple
from uuid import UUID

from pydantic import ConfigDict, Field, model_validator

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.reading_policy import PinnedExecutionPolicy


class SourceInput(CanonicalBaseModel):
    section_index: int = Field(..., ge=1, le=3, alias="sectionIndex")
    pmcid: str = Field(..., min_length=1)
    title: str = Field(..., min_length=1)
    url: str = Field(..., min_length=1)
    license: str = Field(..., min_length=1)
    content: str | None = None
    doi: str | None = None
    authors: str | None = None


class PipelineRequest(CanonicalBaseModel):
    run_id: str = Field(..., min_length=1, alias="runId")
    job_id: UUID = Field(..., alias="jobId")
    epoch: int = Field(..., ge=1)
    lease_owner: UUID = Field(..., alias="leaseOwner")
    topic: str = Field(..., min_length=1)
    sources: Tuple[SourceInput, ...] = Field(..., min_length=1)
    section_indices: Tuple[int, ...] = Field(default=(1, 2, 3), alias="sectionIndices", min_length=1)
    parallel: bool = False
    policy: PinnedExecutionPolicy
    finalize: bool = True

    @model_validator(mode="after")
    def _validate_selected_sections(self) -> "PipelineRequest":
        selected = set(self.section_indices)
        if len(selected) != len(self.section_indices) or not selected.issubset(self.policy.section_indices):
            raise ValueError("sectionIndices must be unique indices configured in policy")
        supplied = tuple(source.section_index for source in self.sources)
        if len(set(supplied)) != len(supplied) or set(supplied) != selected:
            raise ValueError("sources must supply exactly one input for each selected section")
        return self


class RunContext(CanonicalBaseModel):
    run_id: str = Field(..., min_length=1, alias="runId")
    job_id: UUID = Field(..., alias="jobId")
    epoch: int = Field(..., ge=1)
    lease_owner: UUID = Field(..., alias="leaseOwner")
    policy_hash: str = Field(..., pattern=r"^[0-9a-f]{64}$", alias="policyHash")
    client: Any = Field(default=None, exclude=True, repr=False)
    gateway: Any = Field(default=None, exclude=True, repr=False)

    @classmethod
    def from_request(cls, request: PipelineRequest, *, client: Any = None, gateway: Any = None) -> "RunContext":
        return cls(run_id=request.run_id, job_id=request.job_id, epoch=request.epoch,
                   lease_owner=request.lease_owner, policy_hash=request.policy.hash,
                   client=client, gateway=gateway)


class SourceRef(CanonicalBaseModel):
    """Exact accepted source/evidence envelopes passed to every section runner."""
    source: ArtifactEnvelope
    evidence: ArtifactEnvelope

    @model_validator(mode="after")
    def _validate_source_closure(self) -> "SourceRef":
        if self.source.artifact_type != ArtifactType.SOURCE_PACK or not self.source.verify_integrity():
            raise ValueError("source must be an intact SourcePack envelope")
        if self.evidence.artifact_type != ArtifactType.EVIDENCE_GRAPH or not self.evidence.verify_integrity():
            raise ValueError("evidence must be an intact EvidenceGraph envelope")
        if self.source.to_ref() not in self.evidence.parent_refs:
            raise ValueError("evidence must depend on the exact source envelope")
        return self


class AcceptedSectionArtifact(CanonicalBaseModel):
    """Accepted section and exact dependencies needed for paper closure."""
    section: ArtifactEnvelope
    passage: ArtifactEnvelope
    questions: Tuple[ArtifactEnvelope, ...]
    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")

    @model_validator(mode="after")
    def _validate_closure(self) -> "AcceptedSectionArtifact":
        if self.section.artifact_type != ArtifactType.SECTION or self.passage.artifact_type != ArtifactType.PASSAGE:
            raise ValueError("section and passage must have their canonical artifact types")
        envelopes = (self.section, self.passage, *self.questions)
        if not all(envelope.verify_integrity() for envelope in envelopes):
            raise ValueError("accepted section closure contains corrupt envelope")
        required = (self.passage.to_ref(), self.blueprint_ref, *(item.to_ref() for item in self.questions))
        if any(ref not in self.section.parent_refs for ref in required):
            raise ValueError("section must depend on every exact accepted content reference")
        return self

    @property
    def envelope(self) -> ArtifactEnvelope:
        return self.section


class PipelineResult(CanonicalBaseModel):
    run_id: str = Field(..., alias="runId")
    status: Literal["ACCEPTED"] = "ACCEPTED"
    sections: Tuple[ArtifactEnvelope, ...] = Field(..., min_length=1)
    paper: ArtifactEnvelope | None = None
    exam_id: UUID | None = Field(default=None, alias="examId")
    metrics: dict[str, Any] = Field(default_factory=dict)
