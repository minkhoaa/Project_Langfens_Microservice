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
