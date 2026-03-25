from fastapi import APIRouter

router = APIRouter(prefix="/practice", tags=["practice"])


@router.get("/hello")
async def hello():
    return {"message": "Hello from TK's practice endpoint!"}


@router.post("/echo")
async def echo(message: str):
    return {"echo": message}
