from typing import Literal, Optional

from pydantic import BaseModel, Field

class ReadingExplainRequest(BaseModel):
    item_id: str = Field(..., min_length=1, max_length=128)
    passage_text: str = Field(..., description="The passage the student saw")
    question: str = Field(..., min_length=1, max_length=2000)
    question_type: Literal["MCQ", "MATCHING", "TRUE_FALSE_NOT_GIVEN", "SUMMARY_COMPLETE", "SHORT_ANSWER"] = "MCQ"
    options: list[str] = Field(default_factory=list)
    user_answer: str = Field(..., min_length=0, max_length=2000)
    correct_answer: str = Field(..., min_length=0, max_length=2000)
    language: Optional[Literal["en-GB", "en-US"]] = "en-GB"
