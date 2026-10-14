"""Generation API behavior at both quality gates and the runtime boundary."""
import copy
import json
from unittest.mock import AsyncMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.generation_main import app
from app.main import app as inference_app
from app.prompts.autogen_data import JSON_SHAPES
from app.middleware.rate_limit import RateLimitMiddleware


@pytest.fixture(autouse=True)
def clear_request_buckets():
    stack = app.middleware_stack
    while stack is not None:
        if isinstance(stack, RateLimitMiddleware):
            stack._requests.clear()
            break
        stack = getattr(stack, "app", None)


@pytest.fixture
def payload():
    return {
        "type": "MULTIPLE_CHOICE_SINGLE", "skill": "READING",
        "passage": "Paper was invented in China using plant fibres.",
        "count": 1, "difficulty": 3,
    }


def question():
    item = json.loads(JSON_SHAPES["MULTIPLE_CHOICE_SINGLE"])
    item["promptMd"] = "Where was paper invented?"
    item["skill"] = "READING"
    item["difficulty"] = 3
    item["options"] = [
        {"idx": 1, "contentMd": "A. China", "isCorrect": True},
        {"idx": 2, "contentMd": "B. Egypt", "isCorrect": False},
    ]
    return item


async def post(payload):
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        return await client.post("/api/v1/autogen/questions", json=payload)


def approval(source="Paper was invented in China using plant fibres."):
    return {"reviews": [{"question": 1, "valid": True, "evidenceQuote": source,
                         "issues": []}]}


def rejection(issue):
    return {"reviews": [{"question": 1, "valid": False, "issues": [issue]}]}


@pytest.mark.asyncio
async def test_invalid_draft_is_revised_and_only_validated_set_is_returned(payload):
    invalid = question()
    invalid["options"][0]["isCorrect"] = False
    accepted = question()
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [
            {"questions": [invalid]},
            {"questions": [accepted]},
            approval(),
        ]
        response = await post(payload)
    assert response.status_code == 200
    assert response.json()["questions"] == [accepted]
    assert generate.await_count == 3


@pytest.mark.asyncio
async def test_independent_review_rejection_requires_revision_and_second_review(payload):
    candidate = question()
    revised = copy.deepcopy(candidate)
    revised["promptMd"] = "What material was used for early paper?"
    revised["options"] = [
        {"idx": 1, "contentMd": "A. Plant fibres", "isCorrect": True},
        {"idx": 2, "contentMd": "B. Metal", "isCorrect": False},
    ]
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [
            {"questions": [candidate]},
            rejection("Source does not support Egypt as distractor"),
            {"questions": [revised]},
            approval(),
        ]
        response = await post(payload)
    assert response.status_code == 200
    assert response.json()["questions"] == [revised]
    assert generate.await_count == 4
    assert "Source does not support" in generate.await_args_list[2].kwargs["variables"]["user"]


@pytest.mark.asyncio
async def test_exhausted_drafts_fail_closed_without_partial_question_set(payload):
    payload["count"] = 2
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.return_value = {"questions": [question()]}
        response = await post(payload)
    assert response.status_code == 502
    assert generate.await_count == 3
    assert "questions" not in response.json()


@pytest.mark.asyncio
async def test_invalid_reviewer_verdict_never_releases_candidate(payload):
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [
            {"questions": [question()]},
            {"reviews": [{"question": 1, "valid": True, "evidenceQuote": "Fabricated quote", "issues": []}]},
        ]
        response = await post(payload)
    assert response.status_code == 502



@pytest.mark.asyncio
async def test_extra_context_cannot_supply_answer_evidence(payload):
    payload["extra_context"] = "Secret answer invented outside the source"
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [{"questions": [question()]}, approval(payload["extra_context"])]
        response = await post(payload)
    assert response.status_code == 502

@pytest.mark.asyncio
async def test_partial_independent_review_cannot_approve_a_batch(payload):
    payload["count"] = 2
    other = question()
    other["promptMd"] = "Which fibres were used for paper?"
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [{"questions": [question(), other]}, approval()]
        response = await post(payload)
    assert response.status_code == 502
    assert generate.await_count == 2


@pytest.mark.asyncio
async def test_repeated_review_rejections_exhaust_budget(payload):
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [response for _ in range(3) for response in
                                ({"questions": [question()]}, rejection("Answer unsupported"))]
        response = await post(payload)
    assert response.status_code == 502
    assert generate.await_count == 6

@pytest.mark.asyncio
async def test_matching_invalid_key_requires_repair_before_review():
    item = json.loads(JSON_SHAPES["MATCHING_FEATURES"])
    bad = copy.deepcopy(item)
    bad["matchPairs"]["1"][0] = "Z"
    payload = {"type": "MATCHING_FEATURES", "skill": "READING",
               "passage": item["promptMd"], "count": 1, "difficulty": item["difficulty"]}
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [{"questions": [bad]}, {"questions": [item]},
                                approval(item["promptMd"].splitlines()[0])]
        response = await post(payload)
    assert response.status_code == 200
    assert response.json()["questions"] == [item]
    assert generate.await_count == 3


@pytest.mark.asyncio
async def test_generation_is_absent_from_general_ai_runtime(payload):
    async with AsyncClient(transport=ASGITransport(app=inference_app), base_url="http://test") as client:
        response = await client.post("/api/v1/autogen/questions", json=payload)
    assert response.status_code == 404
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        generate.side_effect = [{"questions": [question()]}, approval()]
        generated = await post(payload)
    assert generated.status_code == 200


@pytest.mark.asyncio
async def test_unknown_type_is_rejected_before_provider_call(payload):
    payload["type"] = "NOT_A_TYPE"
    with patch("app.services.autogen_loop.groq_generate", new_callable=AsyncMock) as generate:
        response = await post(payload)
    assert response.status_code == 400
    generate.assert_not_called()
