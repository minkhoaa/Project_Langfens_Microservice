from fastapi import APIRouter

from app.schemas import SpeakingGradeRequest, SpeakingGradeResponse
from app.services import grade_service

router = APIRouter(prefix="/v1/speaking")


@router.post("/grade", response_model=SpeakingGradeResponse)
async def speaking_grade(req: SpeakingGradeRequest):
    return await grade_service.grade_speaking(req)
