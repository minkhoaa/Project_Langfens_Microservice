from fastapi import APIRouter
from pydantic import BaseModel
from app.services.embedding_service import embed_texts, EMBEDDING_DIM

router = APIRouter(prefix="/v1")


class EmbedRequest(BaseModel):
    text: str


class EmbedResponse(BaseModel):
    embedding: list[float]
    dim: int


@router.post("/embed", response_model=EmbedResponse)
async def embed(req: EmbedRequest):
    vectors = await embed_texts([req.text])
    return EmbedResponse(embedding=vectors[0], dim=EMBEDDING_DIM)
