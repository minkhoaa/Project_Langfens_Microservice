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


class RoleplayScenario(BaseModel):
    id: str
    slug: str
    title: str
    difficulty: Literal["BEGINNER", "INTERMEDIATE", "ADVANCED"]
    ielts_part: Literal["PART_1", "PART_2", "PART_3", "SITUATIONAL"]
    context: str
    user_role: str
    agent_role: str
    opening_prompt: str
    target_vocabulary: list[str]
    target_grammar: list[str] = []
    suggested_topics: list[str] = []
    duration_min: int
    turn_count_target: int = 8


class RoleplayScenariosResponse(BaseModel):
    scenarios: list[RoleplayScenario]
    total: int


class CompareRequest(BaseModel):
    essay_text: str = Field(..., min_length=50, max_length=3000)
    topic: str = Field(..., min_length=5, max_length=500)
    task_type: Literal["TASK_1", "TASK_2"] = "TASK_2"
    student_band: float = Field(..., ge=1.0, le=9.0)


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
    step_up_band: float = 0.0
    target_band: float = 0.0
    step_up_analysis: str = ""
    target_analysis: str = ""
    key_improvements: list[str] = []
    no_references_found: bool = False
    sentence_comparisons: list[SentenceComparison] = []
    references: list[ReferenceEssay] = []
