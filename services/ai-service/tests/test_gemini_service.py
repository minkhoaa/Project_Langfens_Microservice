import warnings
warnings.filterwarnings("ignore")

import pytest
from unittest.mock import AsyncMock, MagicMock, patch


@pytest.mark.asyncio
async def test_generate_returns_parsed_dict():
    mock_result = {"greeting": "hello"}
    mock_chain = AsyncMock()
    mock_chain.ainvoke = AsyncMock(return_value=mock_result)

    mock_prompt = MagicMock()
    mock_model = MagicMock()
    mock_parser = MagicMock()

    # Simulate prompt | model | parser chain
    mock_pipe1 = MagicMock()
    mock_prompt.__or__ = MagicMock(return_value=mock_pipe1)
    mock_pipe1.__or__ = MagicMock(return_value=mock_chain)

    with patch("app.services.gemini_service.PromptTemplate") as MockPrompt, \
         patch("app.services.gemini_service._get_model", return_value=mock_model), \
         patch("app.services.gemini_service.JsonOutputParser", return_value=mock_parser):
        MockPrompt.from_template.return_value = mock_prompt

        from app.services.gemini_service import generate
        result = await generate("Say hello to {name}", {"name": "test"})

    assert result == {"greeting": "hello"}


@pytest.mark.asyncio
async def test_generate_propagates_exceptions():
    mock_chain = AsyncMock()
    mock_chain.ainvoke = AsyncMock(side_effect=Exception("LLM error"))

    mock_prompt = MagicMock()
    mock_pipe1 = MagicMock()
    mock_prompt.__or__ = MagicMock(return_value=mock_pipe1)
    mock_pipe1.__or__ = MagicMock(return_value=mock_chain)

    with patch("app.services.gemini_service.PromptTemplate") as MockPrompt, \
         patch("app.services.gemini_service._get_model", return_value=MagicMock()), \
         patch("app.services.gemini_service.JsonOutputParser", return_value=MagicMock()):
        MockPrompt.from_template.return_value = mock_prompt

        from app.services.gemini_service import generate
        with pytest.raises(Exception, match="LLM error"):
            await generate("Say hello to {name}", {"name": "test"})
