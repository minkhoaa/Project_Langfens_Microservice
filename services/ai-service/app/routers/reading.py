from fastapi import APIRouter

from app.schemas.reading import ReadingExplainRequest
from app.schemas.rag_feedback import RagFeedbackEnvelope
from app.services import reading_feedback_service

router = APIRouter(prefix="/v1/reading")

@router.post("/explain-item", response_model=RagFeedbackEnvelope)
async def explain_item(req: ReadingExplainRequest) -> RagFeedbackEnvelope:
    return await reading_feedback_service.explain_item(req)
