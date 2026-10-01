"""Base abstractions and metadata for surgical repair capabilities."""

from __future__ import annotations

from abc import ABC, abstractmethod
from enum import Enum
from typing import List, Optional, Sequence, Set
from pydantic import Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.issue import Issue, IssueCode, IssueScope
from app.loop.capabilities import RepairerCapability
from app.loop.context import LoopContext


class RepairScope(str, Enum):
    """Surgical scope of a repair action."""

    QUESTION = "QUESTION"      # Single question prompt, options, or answer
    GROUP = "GROUP"            # Shared group context, blank alignment, coherence
    PASSAGE = "PASSAGE"        # Passage sentence, paragraph, word count, or fidelity
    SECTION = "SECTION"        # Section-level restructuring


class RepairExecutionError(Exception):
    """Raised when a repair action fails to execute or violates contracts."""


class RepairJustificationError(RepairExecutionError):
    """Raised when an answer or factual repair lacks required passage evidence justification."""


class RepairInvalidationError(RepairExecutionError):
    """Raised when dependent evaluations are not properly invalidated after higher-scope repair."""


class RepairCapabilityMetadata(CanonicalBaseModel):
    """Declarative metadata for a repair capability."""

    repairer_id: str = Field(..., alias="repairerId")
    repairer_version: str = Field(default="1.0.0", alias="repairerVersion")
    name: str
    description: str = ""
    handled_codes: Set[IssueCode] = Field(..., alias="handledCodes")
    scope: RepairScope
    target_artifact_types: List[ArtifactType] = Field(..., alias="targetArtifactTypes")
    timeout_seconds: float = Field(default=30.0, gt=0, alias="timeoutSeconds")
    estimated_tokens: int = Field(default=1500, ge=0, alias="estimatedTokens")
    estimated_cost_usd: float = Field(default=0.015, ge=0, alias="estimatedCostUsd")


class BaseRepairer(ABC, RepairerCapability):
    """Base implementation for surgical repairers enforcing immutability."""

    def __init__(self, metadata: RepairCapabilityMetadata):
        self._metadata = metadata

    @property
    def metadata(self) -> RepairCapabilityMetadata:
        return self._metadata

    @property
    def repairer_id(self) -> str:
        return self._metadata.repairer_id

    @property
    def repairer_version(self) -> str:
        return self._metadata.repairer_version

    @property
    def scope(self) -> RepairScope:
        return self._metadata.scope

    async def repair(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        """Applies surgical repair to produce a new immutable ArtifactEnvelope at version."""
        if version <= artifact.version:
            raise RepairExecutionError(
                f"Repair must produce an incremented version ({version} <= current {artifact.version})"
            )
        new_envelope = await self._repair_impl(context, artifact, issues, intent_id, version)
        if new_envelope.version != version:
            raise RepairExecutionError(
                f"Repairer returned envelope with mismatched version ({new_envelope.version} != {version})"
            )
        if new_envelope.content_hash == artifact.content_hash:
            raise RepairExecutionError(
                "Repair produced an identical content hash to the previous version; no progress made"
            )
        return new_envelope

    @abstractmethod
    async def _repair_impl(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        """Internal repair logic to be implemented by concrete repairers."""
        ...
