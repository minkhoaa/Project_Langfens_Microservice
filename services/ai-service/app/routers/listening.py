from fastapi import APIRouter

from app.schemas.listening import ListeningExplainRequest
from app.schemas.rag_feedback import RagFeedbackEnvelope
from app.services import listening_feedback_service

router = APIRouter(prefix="/v1/listening")

@router.post("/explain-item", response_model=RagFeedbackEnvelope)
async def explain_item(req: ListeningExplainRequest) -> RagFeedbackEnvelope:
    return await listening_feedback_service.explain_item(req)
