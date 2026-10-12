"""Focused regression tests for no-dispatch campaign token reservations."""

from pathlib import Path
import sys


SERVICE_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = SERVICE_DIR.parents[1]
for import_path in (SERVICE_DIR, REPO_ROOT / "scripts" / "refactor"):
    if str(import_path) not in sys.path:
        sys.path.insert(0, str(import_path))

from app.providers.adapters.groq import GroqProvider
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.registry import ProviderRegistry
from build_g07_g10_budget_request import _planned_token_reservation


def test_planned_token_reservation_includes_prompt_schema_and_retry_attempts():
    registry = ProviderRegistry()
    provider = GroqProvider(models={"large": "test-model"})
    registry.register_provider(provider, keys=["test-key"])
    request = ProviderRequest(
        capability=Capability.GENERATE_JSON,
        messages=[
            ChatMessage(role="system", content="Return one JSON object with the requested answer."),
            ChatMessage(role="user", content="A deliberately non-empty prompt with serialized input."),
        ],
        operation_id="allocation-bound-test",
        max_tokens=17,
        response_schema={
            "type": "object",
            "properties": {"answer": {"type": "string"}},
            "required": ["answer"],
        },
    )

    planned = _planned_token_reservation(registry, request, retry_attempts=3)
    per_attempt = provider.conservative_token_reservation(request)

    assert planned == per_attempt * 3
    assert planned > request.max_tokens * 3
