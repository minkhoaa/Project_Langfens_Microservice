"""Shared RagFeedbackEnvelope used by writing, reading, listening, speaking, grammar."""
from typing import Literal, Optional

from pydantic import BaseModel, Field

class Evidence(BaseModel):
    id: str = Field(..., description="Stable reference id (e.g. 'ref-3', 'passage:span-12-30')")
    text: str = Field(..., max_length=2000, description="Quoted excerpt, <=2000 chars")
    source: str = Field(..., description="Collection name or 'passage:inline' / 'transcript:inline'")
    relevance: float = Field(..., ge=0.0, le=1.0)

class CriterionScore(BaseModel):
    name: str = Field(..., description="e.g. 'task_response', 'coherence', 'comprehension'")
    band: float = Field(..., ge=0.0, le=9.0)
    comment: str = Field(...)
    evidence_ids: list[str] = Field(default_factory=list, description="Cites Evidence.id")

class Suggestion(BaseModel):
    text: str
    target: str = Field(..., description="Which criterion this targets")

class RagFeedbackEnvelope(BaseModel):
    item_id: str
    domain: Literal["writing", "reading", "listening", "speaking", "grammar"]
    overall_band: Optional[float] = Field(default=None, ge=0.0, le=9.0)
    criteria: list[CriterionScore] = Field(..., min_length=1)
    evidence: list[Evidence] = Field(default_factory=list)
    suggestions: list[Suggestion] = Field(default_factory=list)
    raw_llm_json: str = Field(default="")
