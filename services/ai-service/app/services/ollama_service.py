import logging

from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_ollama import ChatOllama

from app.config import settings

logger = logging.getLogger(__name__)


def _get_model() -> ChatOllama:
    return ChatOllama(
        model=settings.ollama_model,
        base_url=settings.ollama_base_url,
        temperature=settings.ollama_temperature,
        timeout=settings.ollama_timeout,
    )


async def generate(prompt_template: str, variables: dict) -> dict:
    """Call Ollama with a prompt template and parse JSON output."""
    prompt = PromptTemplate.from_template(prompt_template)
    model = _get_model()
    parser = JsonOutputParser()
    chain = prompt | model | parser
    result = await chain.ainvoke(variables)
    return result


async def generate_roleplay_reply(*args, **kwargs):
    """Placeholder so app.routers.speaking can import this symbol.

    The real implementation is owned by Trong Khoi and lives on a separate
    branch. Hitting any /speaking/roleplay/* endpoint with this stub returns
    501; importing it must succeed so unrelated routers (writing, grammar)
    can boot.
    """
    raise NotImplementedError(
        "generate_roleplay_reply is not implemented on this branch"
    )
