import logging

import requests

from app.config import settings
from app.services import gemini_service, ollama_service
from app.services.openai_like_service import get_llm_key_status, openai_like_generate

logger = logging.getLogger(__name__)


def get_active_provider() -> str:
    if settings.use_ollama:
        return "ollama"
    if settings.use_openai_like:
        return "openai_like"
    return "gemini"


async def generate(prompt_template: str, variables: dict, **kwargs) -> dict:
    provider = get_active_provider()

    if provider == "ollama":
        return await ollama_service.generate(prompt_template, variables)
    if provider == "openai_like":
        return await openai_like_generate(prompt_template, variables, **kwargs)
    return await gemini_service.generate(prompt_template, variables)


def get_runtime_status() -> dict:
    provider = get_active_provider()

    if provider == "ollama":
        status = {
            "provider": provider,
            "base_url": settings.ollama_base_url,
            "llm_model": settings.ollama_model,
            "embedding_model": settings.ollama_embed_model,
            "embedding_dimensions": settings.ollama_embed_dimensions,
            "available": False,
        }
        try:
            response = requests.get(f"{settings.ollama_base_url}/api/tags", timeout=5)
            response.raise_for_status()
            models = {
                model.get("name", "")
                for model in response.json().get("models", [])
                if model.get("name")
            }
            status["available"] = (
                settings.ollama_model in models
                and settings.ollama_embed_model in models
            )
            status["installed_models"] = sorted(models)
        except Exception as exc:
            logger.warning("Failed to inspect Ollama runtime: %s", exc)
            status["error"] = str(exc)
        return status

    if provider == "openai_like":
        key_status = get_llm_key_status()
        return {
            "provider": provider,
            "available": any(info["available"] > 0 for info in key_status.values()),
            "keys": key_status,
        }

    return {
        "provider": provider,
        "available": bool(settings.gemini_api_key),
        "model": settings.gemini_chat_model,
    }
