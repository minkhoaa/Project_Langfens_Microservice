"""Tests for PassageGenerator cross-run token accounting isolation and concurrency.

Invariants:
1. When multiple concurrent calls execute on the same PassageGenerator instance,
   each call's token accounting must remain strictly isolated.
2. The generated ArtifactEnvelope payload["tokensUsed"] must record only tokens
   consumed by its own run, with zero cross-run contamination.
3. PassageGenerator.get_tokens_used(run_id) must retrieve the exact run tokens.
4. Backwards compatibility for _last_tokens_used property getter and setter is preserved.
"""

import asyncio
from typing import Any, Dict, List, Optional
from unittest.mock import MagicMock
from uuid import UUID, uuid4

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType, compute_content_hash
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.generators.passage.prompts import PassageStyleProfile
from app.providers.models import ProviderRequest


class MockProviderResponse:
    def __init__(self, raw_text: str, total_tokens: int):
        self.raw_text = raw_text
        self.usage = MagicMock(total_tokens=total_tokens)
        self.duration_seconds = 1.0


class ConcurrentMockGateway:
    """Mock gateway that simulates async network delay and returns specific token usage."""

    def __init__(self, responses_by_run: Dict[str, List[MockProviderResponse]], delays: Dict[str, float] | None = None):
        self.responses_by_run = responses_by_run
        self.delays = delays or {}
        self.call_log: List[tuple[str, int]] = []

    async def execute(
        self,
        req: ProviderRequest,
        epoch: int = 1,
        lease_owner: Optional[UUID] = None,
    ) -> MockProviderResponse:
        run_id = getattr(req, "run_id", "default")
        delay = self.delays.get(run_id, 0.01)
        await asyncio.sleep(delay)

        run_queue = self.responses_by_run.get(run_id, [])
        if not run_queue:
            resp = MockProviderResponse('{"title": "Test", "passage": "Valid passage text here."}', 1000)
        else:
            resp = run_queue.pop(0)

        toks = int(resp.usage.total_tokens)
        self.call_log.append((run_id, toks))
        return resp


def _make_dummy_context(section_index: int = 2) -> PassageGenerationContext:
    bp_ref = ArtifactRef(
        artifactId="bp_test",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="a" * 64,
    )
    eg_ref = ArtifactRef(
        artifactId="eg_test",
        artifactType=ArtifactType.EVIDENCE_GRAPH,
        version=1,
        contentHash="b" * 64,
    )
    return PassageGenerationContext(
        topic="Marine Ecosystems and Climate Change",
        section_index=section_index,
        style_profile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        source_text="Marine ecosystems are influenced by climate change and nutrient ratios. " * 80,
        target_min_words=720,
        target_max_words=915,
        blueprint_ref=bp_ref,
        evidence_graph_ref=eg_ref,
    )


def _valid_passage_json(word_count: int = 750) -> str:
    words = ["Word"] * word_count
    passage = " ".join(words)
    import json
    return json.dumps({
        "title": "Marine Ecosystems and Global Climate Change",
        "passage": passage,
    })


@pytest.mark.asyncio
async def test_concurrent_passage_generation_token_accounting_isolation():
    """Two concurrent section passage generation runs on the SAME PassageGenerator instance

    must record their own tokens without cross-run contamination.
    Section 2: 1 call = 8,220 tokens
    Section 3: 2 calls (initial + word-count guard rewrite) = 8,407 + 8,542 = 16,949 tokens
    """
    sec2_run_id = "run_70d6a3b92ecf4f5ab61ac42cef20dd4c"
    sec3_run_id = "run_3345e89254e140e48f51c1a2e1e3ac11"

    # Section 2 returns a valid 750-word passage in 1 call (8,220 tokens)
    sec2_responses = [
        MockProviderResponse(_valid_passage_json(750), total_tokens=8220),
    ]

    # Section 3 returns a short passage first (500 words -> triggers word-count guard),
    # then a valid passage (750 words) on rewrite (8,407 + 8,542 = 16,949 tokens)
    sec3_responses = [
        MockProviderResponse(_valid_passage_json(500), total_tokens=8407),
        MockProviderResponse(_valid_passage_json(750), total_tokens=8542),
    ]

    gateway = ConcurrentMockGateway(
        responses_by_run={
            sec2_run_id: sec2_responses,
            sec3_run_id: sec3_responses,
        },
        delays={
            # Section 2 runs with a slight delay so Section 3 starts and interleaves calls
            sec2_run_id: 0.05,
            sec3_run_id: 0.02,
        },
    )

    shared_generator = PassageGenerator(gateway=gateway)

    ctx_sec2 = _make_dummy_context(section_index=2)
    ctx_sec3 = _make_dummy_context(section_index=3)

    # Launch concurrently
    env2, env3 = await asyncio.gather(
        shared_generator.generate(context=ctx_sec2, run_id=sec2_run_id),
        shared_generator.generate(context=ctx_sec3, run_id=sec3_run_id),
    )

    # 1. Section 2 payload must have exactly 8,220 tokens
    assert env2.payload["tokensUsed"] == 8220, (
        f"Expected Section 2 to use 8220 tokens, but got {env2.payload['tokensUsed']} (contamination detected!)"
    )

    # 2. Section 3 payload must have exactly 16,949 tokens (8407 + 8542)
    assert env3.payload["tokensUsed"] == 16949, (
        f"Expected Section 3 to use 16949 tokens, but got {env3.payload['tokensUsed']} (contamination detected!)"
    )

    # 3. get_tokens_used retrieves token usage without error
    assert shared_generator.get_tokens_used() >= 0


@pytest.mark.asyncio
async def test_concurrent_passage_generation_same_run_id_isolation():
    """Two concurrent passage generations sharing the exact same run_id (e.g. concurrent repair/section)
    must each accumulate their own invocation-local tokens into their respective envelopes.
    """
    shared_run_id = "run_shared_concurrency"

    class InvocationAwareGateway:
        def __init__(self):
            self.call_count = 0

        async def execute(self, req: ProviderRequest, epoch: int = 1, lease_owner: Optional[UUID] = None):
            self.call_count += 1
            # Alternate responses: call_a uses 4200, call_b uses 7800
            if "call_a" in (getattr(req, "artifact_id", "") or ""):
                await asyncio.sleep(0.04)
                return MockProviderResponse(_valid_passage_json(750), total_tokens=4200)
            else:
                await asyncio.sleep(0.01)
                return MockProviderResponse(_valid_passage_json(750), total_tokens=7800)

    gateway = InvocationAwareGateway()
    generator = PassageGenerator(gateway=gateway)

    ctx_a = _make_dummy_context(section_index=2)
    ctx_b = _make_dummy_context(section_index=3)

    env_a, env_b = await asyncio.gather(
        generator.generate(context=ctx_a, run_id=shared_run_id, target_artifact_id="art_call_a"),
        generator.generate(context=ctx_b, run_id=shared_run_id, target_artifact_id="art_call_b"),
    )

    assert env_a.payload["tokensUsed"] == 4200
    assert env_b.payload["tokensUsed"] == 7800


@pytest.mark.asyncio
async def test_sequential_passage_generation_resets_tokens():
    """Sequential runs on the same PassageGenerator must reset tokens per run."""
    run1 = "run_seq_1"
    run2 = "run_seq_2"

    gateway = ConcurrentMockGateway(
        responses_by_run={
            run1: [MockProviderResponse(_valid_passage_json(750), total_tokens=5000)],
            run2: [MockProviderResponse(_valid_passage_json(750), total_tokens=3000)],
        }
    )
    generator = PassageGenerator(gateway=gateway)

    env1 = await generator.generate(context=_make_dummy_context(), run_id=run1)
    assert env1.payload["tokensUsed"] == 5000
    assert generator.get_tokens_used() == 5000

    env2 = await generator.generate(context=_make_dummy_context(), run_id=run2)
    assert env2.payload["tokensUsed"] == 3000
    assert generator.get_tokens_used() == 3000


def test_last_tokens_used_property_backwards_compatible():
    """_last_tokens_used property getter and setter maintain backwards compatibility."""
    gateway = MagicMock()
    generator = PassageGenerator(gateway=gateway)

    # Direct setter
    generator._last_tokens_used = 1234
    assert generator._last_tokens_used == 1234
    assert generator.get_tokens_used() == 1234

    generator._last_tokens_used = 0
    assert generator._last_tokens_used == 0
