"""Canonical Artifact Envelope for Langfens Loop Engine V2.

Artifacts are immutable units of generation state. Any change to content
or parent dependencies produces a strictly new version with a new content hash.
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from enum import Enum
from types import MappingProxyType
from typing import Annotated, Any, Sequence, Tuple, Union
from pydantic import Field, PlainSerializer, field_validator

from .base import CanonicalBaseModel


class ArtifactType(str, Enum):
    SOURCE_PACK = "SourcePack"
    EVIDENCE_GRAPH = "EvidenceGraph"
    EXAM_BLUEPRINT = "ExamBlueprint"
    PASSAGE = "Passage"
    QUESTION_GROUP = "QuestionGroup"
    QUESTION = "Question"
    SECTION = "Section"
    READING_PAPER = "ReadingPaper"


def canonical_json_dump(obj: Any) -> str:
    """Produces deterministic canonical JSON serialization for hashing."""
    if isinstance(obj, MappingProxyType):
        obj = dict(obj)
    if isinstance(obj, CanonicalBaseModel):
        obj = obj.model_dump(mode="json", exclude_none=False)
    elif isinstance(obj, (tuple, list)):
        obj = [canonical_json_dump_prep(x) for x in obj]
    elif isinstance(obj, dict):
        obj = {k: canonical_json_dump_prep(v) for k, v in obj.items()}
    return json.dumps(obj, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


def canonical_json_dump_prep(obj: Any) -> Any:
    if isinstance(obj, MappingProxyType):
        return {k: canonical_json_dump_prep(v) for k, v in obj.items()}
    if isinstance(obj, (tuple, list)):
        return [canonical_json_dump_prep(x) for x in obj]
    if isinstance(obj, CanonicalBaseModel):
        return obj.model_dump(mode="json", exclude_none=False)
    return obj


def freeze_container(val: Any) -> Any:
    """Recursively freezes dicts and lists to guarantee deep immutability."""
    if isinstance(val, dict):
        return MappingProxyType({k: freeze_container(v) for k, v in val.items()})
    if isinstance(val, list):
        return tuple(freeze_container(x) for x in val)
    return val


def compute_content_hash(
    payload: Any,
    parent_refs: Sequence[ArtifactRef] | None = None,
) -> str:
    """Computes SHA-256 hash binding both payload and exact parent references.
    
    Any change to payload content OR upstream parent lineage version/hash
    strictly produces a different content hash.
    """
    refs_data = []
    if parent_refs:
        for r in sorted(parent_refs, key=lambda x: (x.artifact_type.value, x.artifact_id, x.version)):
            refs_data.append({
                "artifactId": r.artifact_id,
                "artifactType": r.artifact_type.value,
                "contentHash": r.content_hash,
                "version": r.version,
            })
    body = {
        "parentRefs": refs_data,
        "payload": canonical_json_dump_prep(payload),
    }
    serialized = canonical_json_dump(body)
    return hashlib.sha256(serialized.encode("utf-8")).hexdigest()


class ArtifactRef(CanonicalBaseModel):
    """Exact reference to an immutable artifact version."""

    artifact_id: str = Field(..., alias="artifactId")
    artifact_type: ArtifactType = Field(..., alias="artifactType")
    version: int = Field(..., ge=1)
    content_hash: str = Field(..., alias="contentHash", min_length=64, max_length=64, pattern=r"^[0-9a-f]{64}$")

    @field_validator("content_hash")
    @classmethod
    def validate_hash_hex(cls, v: str) -> str:
        return v.lower()


class ArtifactEnvelope(CanonicalBaseModel):
    """Immutable envelope enclosing an artifact's payload, lineage, and provenance."""

    artifact_id: str = Field(..., alias="artifactId")
    artifact_type: ArtifactType = Field(..., alias="artifactType")
    version: int = Field(..., ge=1)
    run_id: str = Field(..., alias="runId")
    section_id: int | None = Field(default=None, alias="sectionId")
    schema_version: str = Field(default="1.0.0", alias="schemaVersion")
    content_hash: str = Field(..., alias="contentHash", min_length=64, max_length=64, pattern=r"^[0-9a-f]{64}$")
    created_at: datetime = Field(..., alias="createdAt")
    producer_version: str = Field(..., alias="producerVersion")
    payload: Annotated[Any, PlainSerializer(canonical_json_dump_prep, return_type=Any)]
    parent_refs: Tuple[ArtifactRef, ...] = Field(default_factory=tuple, alias="parentRefs")

    @field_validator("content_hash")
    @classmethod
    def validate_hash_hex(cls, v: str) -> str:
        return v.lower()

    @field_validator("payload", mode="after")
    @classmethod
    def freeze_payload(cls, v: Any) -> Any:
        return freeze_container(v)

    def to_ref(self) -> ArtifactRef:
        """Returns the exact immutable reference to this artifact version."""
        return ArtifactRef(
            artifactId=self.artifact_id,
            artifactType=self.artifact_type,
            version=self.version,
            contentHash=self.content_hash,
        )

    def verify_integrity(self) -> bool:
        """Verifies that content_hash strictly matches the payload and parentRefs."""
        expected_hash = compute_content_hash(self.payload, self.parent_refs)
        return self.content_hash.lower() == expected_hash.lower()

    @classmethod
    def create(
        cls,
        artifact_id: str,
        artifact_type: ArtifactType,
        run_id: str,
        payload: Any,
        producer_version: str,
        version: int = 1,
        section_id: int | None = None,
        parent_refs: Sequence[ArtifactRef] | None = None,
        schema_version: str = "1.0.0",
        created_at: datetime | None = None,
    ) -> ArtifactEnvelope:
        """Creates a new validated ArtifactEnvelope with calculated content_hash."""
        refs_tuple = tuple(parent_refs or ())
        content_hash = compute_content_hash(payload, refs_tuple)
        ts = created_at or datetime.now(timezone.utc)
        return cls(
            artifactId=artifact_id,
            artifactType=artifact_type,
            version=version,
            runId=run_id,
            sectionId=section_id,
            schemaVersion=schema_version,
            contentHash=content_hash,
            createdAt=ts,
            producerVersion=producer_version,
            payload=payload,
            parentRefs=refs_tuple,
        )

    def create_next_version(
        self,
        new_payload: Any,
        producer_version: str,
        parent_refs: Sequence[ArtifactRef] | None = None,
        created_at: datetime | None = None,
    ) -> ArtifactEnvelope:
        """Creates next version of this artifact with updated payload and lineage."""
        return ArtifactEnvelope.create(
            artifact_id=self.artifact_id,
            artifact_type=self.artifact_type,
            run_id=self.run_id,
            payload=new_payload,
            producer_version=producer_version,
            version=self.version + 1,
            section_id=self.section_id,
            parent_refs=tuple(parent_refs) if parent_refs is not None else self.parent_refs,
            schema_version=self.schema_version,
            created_at=created_at,
        )
