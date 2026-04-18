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
