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
    """Placeholder so ``app.routers.speaking`` can import this symbol.

    !!! TK ACTION REQUIRED ON MERGE !!!
    The real implementation lives on Trong Khoi's speaking branch. When that
    branch merges into master, DELETE this stub. Hitting any
    /speaking/roleplay/* endpoint with this stub returns 500 via
    NotImplementedError. Tracking note in TASKS-MINH-KHOA.md Week 7.
    """
    raise NotImplementedError(
        "generate_roleplay_reply is not implemented on this branch — "
        "remove this stub when TK's speaking branch merges."
    )
