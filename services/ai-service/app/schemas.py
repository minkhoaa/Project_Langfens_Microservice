from typing import Literal

from pydantic import BaseModel, Field


class SearchRequest(BaseModel):
    query: str = Field(..., min_length=1, description="Text to search for similar documents")
    top_k: int = Field(default=5, ge=1, le=20, description="Number of results to return")
    filters: dict = Field(default_factory=dict, description="Metadata filters (e.g. {'task_type': 'TASK_2', 'band_overall': 8.0})")


class SearchResult(BaseModel):
    id: str
    text: str
    score: float
    metadata: dict


class SearchResponse(BaseModel):
    results: list[SearchResult]
    query: str
    collection: str


class CompareRequest(BaseModel):
    essay_text: str = Field(..., min_length=50, max_length=3000)
    topic: str = Field(..., min_length=5, max_length=500)
    task_type: Literal["TASK_1", "TASK_2"] = "TASK_2"
    band_filter: float = Field(default=8.0, ge=6.0, le=9.0)


class SentenceComparison(BaseModel):
    original: str
    improved: str
    explanation: str
    category: Literal["vocabulary", "grammar", "coherence", "structure"]


class ReferenceEssay(BaseModel):
    id: str
    text: str
    band: float
    similarity_score: float


class CompareResponse(BaseModel):
    overall_analysis: str
    vocabulary_feedback: str = ""
    coherence_feedback: str = ""
    grammar_feedback: str = ""
    task_response_feedback: str = ""
    sentence_comparisons: list[SentenceComparison] = []
    references: list[ReferenceEssay]
