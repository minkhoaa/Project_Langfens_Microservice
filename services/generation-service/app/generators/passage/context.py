"""Input context contract for PassageGenerator (P08-01).

Accepts exact ExamBlueprint and EvidenceGraph references, verified spans and provenance,
section constraints, and pinned policy/config.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional
from pydantic import Field, field_validator

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.policies import POLICY_VERSION, PASSAGE_MAX_WORDS, PASSAGE_MIN_WORDS
from app.generators.passage.prompts import PassageStyleProfile


class PassageGenerationContext(CanonicalBaseModel):
    """Execution context bound to exact upstream artifact dependencies."""

    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")
    evidence_graph_ref: ArtifactRef = Field(..., alias="evidenceGraphRef")
    source_pack_ref: Optional[ArtifactRef] = Field(default=None, alias="sourcePackRef")
    section_index: int = Field(..., ge=1, le=3, alias="sectionIndex")
    topic: str = Field(..., min_length=3, max_length=200)
    style_profile: PassageStyleProfile = Field(
        default=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        alias="styleProfile",
    )
    source_text: str = Field(..., min_length=50, alias="sourceText")
    policy_version: str = Field(default=POLICY_VERSION, alias="policyVersion")
    target_min_words: int = Field(default=PASSAGE_MIN_WORDS, alias="targetMinWords")
    target_max_words: int = Field(default=PASSAGE_MAX_WORDS, alias="targetMaxWords")
    constraints: Dict[str, Any] = Field(default_factory=dict)

    @field_validator("blueprint_ref")
    @classmethod
    def _validate_blueprint_ref(cls, v: ArtifactRef) -> ArtifactRef:
        if v.artifact_type not in (ArtifactType.EXAM_BLUEPRINT, ArtifactType.SECTION):
            raise ValueError(f"blueprint_ref must be ExamBlueprint or Section, got {v.artifact_type}")
        return v

    @field_validator("evidence_graph_ref")
    @classmethod
    def _validate_evidence_graph_ref(cls, v: ArtifactRef) -> ArtifactRef:
        if v.artifact_type not in (ArtifactType.EVIDENCE_GRAPH, ArtifactType.SOURCE_PACK):
            raise ValueError(f"evidence_graph_ref must be EvidenceGraph or SourcePack, got {v.artifact_type}")
        return v
