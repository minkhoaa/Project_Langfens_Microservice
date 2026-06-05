import asyncio
from app.routers.speaking import roleplay_turn
from app.schemas import RoleplayTurnWithSpeechRequest

async def main():
    req = RoleplayTurnWithSpeechRequest(
        session_id="test_session",
        user_id="demo_user",
        text="The stale smell of old beer lingers.",
        score=None
    )
    # Start a session first
    from app.services.roleplay_session_service import get_or_create_session
    import uuid
    sid = str(uuid.uuid4())
    req.session_id = sid
    get_or_create_session(sid, "demo_user", "university-course-advice")
    
    try:
        res = await roleplay_turn(req)
        print(res.model_dump_json(indent=2))
    except Exception as e:
        import traceback
        traceback.print_exc()

asyncio.run(main())
