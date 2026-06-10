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

if __name__ == "__main__":
    asyncio.run(main())


from unittest.mock import AsyncMock, patch

def test_reading_explain_item_routes():
    from fastapi.testclient import TestClient
    from app.main import app

    client = TestClient(app)
    payload = {
        "item_id": "r1",
        "passage_text": "The library opens at nine. Members may borrow up to five books.",
        "question": "When does the library open?",
        "question_type": "MCQ",
        "options": ["A) 7am", "B) 9am"],
        "user_answer": "A) 7am",
        "correct_answer": "B) 9am",
    }
    with patch(
        "app.services.reading_feedback_service.llm_service.generate",
        new=AsyncMock(return_value={
            "criterion_band": 6.0,
            "explanation": "...",
            "passage_quote": "The library opens at nine.",
            "distractor_analysis": "A) 7am is wrong.",
            "suggestions": ["Re-read paragraph 1."],
        }),
    ):
        resp = client.post("/api/v1/reading/explain-item", json=payload)
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["domain"] == "reading"
    assert body["criteria"][0]["name"] == "comprehension"

def test_listening_explain_item_routes():
    from fastapi.testclient import TestClient
    from app.main import app

    client = TestClient(app)
    payload = {
        "item_id": "l1",
        "transcript": "Librarian: The library closes at six.",
        "question": "When does it close?",
        "question_type": "MCQ",
        "options": ["A) 5pm", "B) 6pm"],
        "user_answer": "A) 5pm",
        "correct_answer": "B) 6pm",
        "section": 1,
    }
    with patch(
        "app.services.listening_feedback_service.search_service.search",
        new=AsyncMock(return_value=[]),
    ), patch(
        "app.services.listening_feedback_service.llm_service.generate",
        new=AsyncMock(return_value={
            "criterion_band": 6.5,
            "explanation": "...",
            "transcript_quote": "The library closes at six.",
            "skill_tags": ["detail"],
            "suggestions": ["Listen for numbers."],
        }),
    ):
        resp = client.post("/api/v1/listening/explain-item", json=payload)
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["domain"] == "listening"
    assert body["criteria"][0]["name"] == "comprehension"
