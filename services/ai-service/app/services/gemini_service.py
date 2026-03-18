import logging

from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI

from app.config import settings

logger = logging.getLogger(__name__)


def _get_model() -> ChatGoogleGenerativeAI:
    return ChatGoogleGenerativeAI(
        model=settings.gemini_chat_model,
        google_api_key=settings.gemini_api_key,
        temperature=settings.gemini_chat_temperature,
        max_output_tokens=settings.gemini_chat_max_tokens,
        timeout=settings.gemini_chat_timeout,
    )


async def generate(prompt_template: str, variables: dict) -> dict:
    """Call Gemini with a prompt template and parse JSON output."""
    prompt = PromptTemplate.from_template(prompt_template)
    model = _get_model()
    parser = JsonOutputParser()
    chain = prompt | model | parser
    result = await chain.ainvoke(variables)
    return result
