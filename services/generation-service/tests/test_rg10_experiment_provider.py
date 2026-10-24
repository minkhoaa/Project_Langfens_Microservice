"""Deterministic transport tests: no live provider or environment credentials."""
from __future__ import annotations

import json

import httpx
import pytest

from app.experiment.providers import OpenAICompatibleExperimentClient
from app.providers.adapters.minimax import MiniMaxProvider
from app.experiment.runners import ConfigurationARunner
from tests.test_rg10_generation_response_integrity import MODEL, PASSAGE, candidate, request_for


def make_client(handler, *, model="MiniMax-Text-01"):
    transport = httpx.MockTransport(handler)
    provider = MiniMaxProvider(base_url="https://provider.example.invalid/v1",
                               models={"large": model},
                               http_client=httpx.AsyncClient(transport=transport))
    return OpenAICompatibleExperimentClient(provider=provider, api_key="fixture-only-not-a-secret",
                                             max_tokens=2000, timeout_seconds=5)


def provider_payload(*, model="MiniMax-Text-01", usage=True, content=None):
    payload = {"id": "fixture-request-1", "object": "chat.completion", "created": 0,
               "model": model,
               "choices": [{"index": 0, "finish_reason": "stop",
                            "message": {"role": "assistant", "content": content or json.dumps(candidate("READING"))}}]}
    if usage:
        payload["usage"] = {"prompt_tokens": 23, "completion_tokens": 17, "total_tokens": 40}
    return payload


def test_real_adapter_uses_configured_provider_and_actual_response_model_and_usage():
    calls = []
    def handler(request):
        calls.append(request)
        return httpx.Response(200, json=provider_payload())
    client = make_client(handler)
    result, usage = ConfigurationARunner(client=client).generate_reading(
        request_for("READING", "A"), PASSAGE, "adapter-v1", MODEL)
    assert result.generated_content.questions[0].text == candidate("READING")["questions"][0]["text"]
    sent = json.loads(calls[0].content)
    assert sent["model"] == "MiniMax-Text-01"
    assert sent["max_tokens"] == 2000
    assert sent["extra_body"]["reasoning_split"] if "extra_body" in sent else sent["reasoning_split"]
    assert usage["prompt_tokens"] == 23
    assert usage["total_tokens"] == 40
    assert usage["confidence"] == "EXACT"
    assert usage["token_source"] == "PROVIDER"
    assert usage["cost_usd"] is None
    assert usage["estimated_cost_usd"] is None
    assert usage["cost_source"] == "UNKNOWN"
    assert usage["provenance"]["dispatches"][0]["provider_request_id"] == "fixture-request-1"
    assert "fixture-only-not-a-secret" not in json.dumps(usage)


def test_real_adapter_rejects_actual_response_model_mismatch():
    client = make_client(lambda request: httpx.Response(200, json=provider_payload(model="substituted-model")))
    result, usage = ConfigurationARunner(client=client).generate_reading(
        request_for("READING", "A"), PASSAGE, "adapter-v1", MODEL)
    assert result.failure_code == "MODEL_IDENTITY_MISMATCH"
    assert usage["provenance"]["dispatches"][0]["actual_model_id"] == "minimax/substituted-model"


def test_real_adapter_missing_usage_is_unknown_not_zero_or_word_estimate():
    client = make_client(lambda request: httpx.Response(200, json=provider_payload(usage=False)))
    result, usage = ConfigurationARunner(client=client).generate_reading(
        request_for("READING", "A"), PASSAGE, "adapter-v1", MODEL)
    assert result.generated_content is not None
    assert usage["prompt_tokens"] is None
    assert usage["completion_tokens"] is None
    assert usage["total_tokens"] is None
    assert usage["confidence"] == "UNKNOWN"
    assert usage["cost_usd"] is None


@pytest.mark.parametrize("status", [401, 429, 503])
def test_real_adapter_has_no_hidden_retries_or_provider_fallback(status):
    calls = []
    def handler(request):
        calls.append(request)
        return httpx.Response(status, json={"error": {"message": "fixture rejection"}})
    client = make_client(handler)
    result, usage = ConfigurationARunner(client=client).generate_reading(
        request_for("READING", "A"), PASSAGE, "adapter-v1", MODEL)
    assert result.execution_status.value == "FAILED_RUNTIME"
    assert len(calls) == 1
    assert usage["call_count"] == 1
    assert usage["confidence"] == "UNKNOWN"
    assert usage["total_tokens"] is None


def test_configured_model_mismatch_fails_before_network_dispatch():
    calls = []
    def handler(request):
        calls.append(request)
        return httpx.Response(200, json=provider_payload())
    client = make_client(handler, model="different-configured-model")
    result, usage = ConfigurationARunner(client=client).generate_reading(
        request_for("READING", "A"), PASSAGE, "adapter-v1", MODEL)
    assert result.failure_code == "MODEL_IDENTITY_MISMATCH"
    assert calls == []
    assert usage["call_count"] == 0


def test_explicit_offline_override_is_estimated_and_never_provider_reported():
    from app.experiment.runners import DefaultRecordingExperimentClient
    client = DefaultRecordingExperimentClient()
    response = client.dispatch(prompt="fixture prompt", model_id=MODEL,
                               raw_output_override=json.dumps(candidate("READING")))
    assert response.confidence == "ESTIMATED"
    assert response.cost_usd is None
    assert response.token_source == "ESTIMATED"
    assert response.cost_source == "UNKNOWN"
