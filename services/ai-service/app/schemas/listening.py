from typing import Literal, Optional

from pydantic import BaseModel, Field

class ListeningExplainRequest(BaseModel):
    item_id: str = Field(..., min_length=1, max_length=128)
    transcript: str = Field(..., description="The transcript the student heard")
    question: str = Field(..., min_length=1, max_length=2000)
    question_type: Literal["MCQ", "MATCHING", "MAP_PLAN_DIAGRAM", "FORM_COMPLETE", "NOTE_COMPLETE", "SHORT_ANSWER", "SENTENCE_COMPLETE"] = "MCQ"
    options: list[str] = Field(default_factory=list)
    user_answer: str = Field(..., min_length=0, max_length=2000)
    correct_answer: str = Field(..., min_length=0, max_length=2000)
    section: int = Field(..., ge=1, le=4, description="IELTS listening section (1-4)")
    language: Optional[Literal["en-GB", "en-US"]] = "en-GB"
