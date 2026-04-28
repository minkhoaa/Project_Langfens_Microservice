from unittest.mock import AsyncMock, patch

import pytest

from app.schemas import GrammarExplainRequest, SearchResult


@pytest.mark.asyncio
async def test_explain_single_uses_runtime_service_and_parses_response():
    from app.services.grammar_service import explain_single

    request = GrammarExplainRequest(
        error_text="He go to school yesterday.",
        context="Short practice sentence",
        correct_form="He went to school yesterday.",
        language="en-GB",
    )
    rules = [
        SearchResult(
            id="rule-1",
            text="Use past tense for completed actions in the past.",
            score=0.9,
            metadata={"task": "gec"},
        )
    ]
    llm_result = {
        "explanation": "The verb needs past tense.",
        "rule_description": "Past completed actions use the past simple.",
        "correct_form": "He went to school yesterday.",
        "examples": ["She went home early."],
        "category": "tense",
    }

    with patch("app.services.grammar_service.search_service.search", new_callable=AsyncMock, return_value=rules), \
         patch("app.services.grammar_service.llm_service.generate", new_callable=AsyncMock, return_value=llm_result) as mock_generate:
        result = await explain_single(request)

    assert result.category == "tense"
    assert "past tense" in result.explanation
    mock_generate.assert_awaited_once()


@pytest.mark.asyncio
async def test_detect_returns_errors_for_essay_with_known_mistakes():
    from app.schemas import GrammarDetectRequest
    from app.services.grammar_service import detect

    request = GrammarDetectRequest(
        essay="He go to school yesterday. She have many books.",
        max_errors=20,
    )
    llm_result = {
        "errors": [
            {
                "error_text": "He go to school",
                "context": "He go to school yesterday.",
                "correct_form": "He went to school",
            },
            {
                "error_text": "She have many books",
                "context": "She have many books.",
                "correct_form": "She has many books",
            },
        ]
    }

    with patch(
        "app.services.grammar_service.llm_service.generate",
        new_callable=AsyncMock,
        return_value=llm_result,
    ) as mock_generate:
        response = await detect(request)

    assert len(response.errors) == 2
    assert response.errors[0].error_text == "He go to school"
    assert response.errors[0].correct_form == "He went to school"
    assert response.errors[1].error_text == "She have many books"
    mock_generate.assert_awaited_once()
