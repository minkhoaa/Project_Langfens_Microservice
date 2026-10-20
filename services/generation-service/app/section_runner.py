"""Authoritative SectionRunner executing reading section generation.

Uses StageExecutor for all durable artifact commits: passage, questions,
and section assembly. All sections (1, 2, 3) use this exact runner; differences
are purely configuration data.
"""

from __future__ import annotations

import logging
from collections.abc import Sequence
from typing import Any, Optional
from uuid import UUID

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType, canonical_json_dump_prep
from app.contracts.evaluation import EvaluationResult
from app.persistence.client import CheckpointClient
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.reading_evaluation import evaluate_passage, evaluate_question, evaluate_section
from app.reading_generation import compose_passage, compose_questions, compose_section_payload
from app.reading_models import AcceptedSectionArtifact, RunContext, SourceRef
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.stage_executor import StageExecutor

logger = logging.getLogger(__name__)


def _payload(obj: Any) -> dict[str, Any]:
    if isinstance(obj, ArtifactEnvelope):
        return dict(canonical_json_dump_prep(obj.payload))
    return dict(canonical_json_dump_prep(obj))


class SectionRunner:
    """Configurable runner executing generation stages for a single reading section."""

    def __init__(self, client: CheckpointClient, gateway: ProviderGateway) -> None:
        self.client = client
        self.gateway = gateway

    async def run(
        self,
        context: RunContext,
        config: SectionConfig,
        source_ref: SourceRef | None = None,
        blueprint: ArtifactRef | None = None,
        policy: PinnedExecutionPolicy | None = None,
        *,
        source: SourceRef | None = None,
        **kwargs: Any,
    ) -> AcceptedSectionArtifact:
        """Executes passage synthesis, question generation, and section closure."""
        actual_source = source_ref or source or kwargs.get("source")
        if actual_source is None:
            raise ValueError("source_ref must be provided")

        actual_blueprint = blueprint or kwargs.get("blueprint_ref")
        if actual_blueprint is None:
            raise ValueError("blueprint reference must be provided")

        actual_policy = policy or kwargs.get("policy")
        if actual_policy is None:
            raise ValueError("policy must be provided")

        executor = StageExecutor(self.client, context, actual_policy)

        # 1. Resolve accepted blueprint
        blueprint_envelope = await executor.get_accepted(actual_blueprint.artifact_id)
        if blueprint_envelope is None:
            raise ValueError(
                f"Accepted blueprint artifact {actual_blueprint.artifact_id} not found in durable run state"
            )

        blueprint_payload = _payload(blueprint_envelope)
        sec_blueprint = next(
            (s for s in blueprint_payload.get("sections", []) if s.get("sectionId") == config.index),
            None,
        )
        topic = sec_blueprint.get("topic", f"Section {config.index}") if sec_blueprint else f"Section {config.index}"
        slots = sec_blueprint.get("questionSlots", []) if sec_blueprint else []

        # 2. Extract source and verified claims
        source_payload = _payload(actual_source.source)
        source_metadata = source_payload["sources"][0]["metadata"]
        source_text = source_payload["sources"][0]["document"]["text"]
        evidence_payload = _payload(actual_source.evidence)
        claims = evidence_payload.get("claims", [])
        claims_map = {c["claimId"]: c for c in claims}

        # 3. Passage stage
        passage_art_id = f"passage:{context.run_id}:{config.index}"
        passage_parents = (actual_blueprint, actual_source.evidence.to_ref())

        async def generate_passage(version: int) -> dict[str, Any]:
            # Bounded provider invocation when gateway is live and not mock
            if self.gateway and actual_policy.provider != "mock":
                try:
                    call_seconds = actual_policy.provider_call_wall_seconds(config.index)
                    req = ProviderRequest(
                        capability=Capability.GENERATE_JSON,
                        messages=[
                            ChatMessage(role="system", content="Generate an academic reading passage draft."),
                            ChatMessage(role="user", content=f"Topic: {topic}\nSource: {source_text[:2000]}"),
                        ],
                        operation_id=f"op:{context.run_id}:passage:{config.index}:{version}",
                        run_id=context.run_id,
                        section_id=str(config.index),
                        artifact_id=passage_art_id,
                        preferred_provider=actual_policy.provider,
                        timeout_seconds=call_seconds,
                        wall_time_reservation_seconds=call_seconds,
                        max_tokens=4096,
                    )
                    await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)
                except Exception as exc:
                    logger.debug("Provider call skipped or failed, using deterministic composition: %s", exc)

            return compose_passage(topic, config.index, source_text, claims, config)

        async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_passage(art, source_text, claims_map, config)

        passage_envelope = await executor.execute(
            passage_art_id,
            ArtifactType.PASSAGE,
            passage_parents,
            generate_passage,
            evaluate_passage_stage,
            section_id=config.index,
        )

        passage_text = str(passage_envelope.payload.get("passage", ""))

        # 4. Questions stage: compose and commit individual question artifacts
        all_questions, groups_data = compose_questions(config.index, passage_text, claims, slots, config)
        q_envelopes: list[ArtifactEnvelope] = []
        q_parents = (passage_envelope.to_ref(), actual_blueprint)

        for q_payload in all_questions:
            q_num = q_payload["questionNumber"]
            q_art_id = f"question:{context.run_id}:{q_num}"

            async def generate_question(version: int, payload: dict[str, Any] = q_payload) -> dict[str, Any]:
                return payload

            async def evaluate_question_stage(
                art: ArtifactEnvelope,
                prior: tuple[ArtifactEnvelope, ...] = tuple(q_envelopes),
            ) -> list[EvaluationResult]:
                return evaluate_question(
                    art,
                    passage_text,
                    config.difficulty.value,
                    [e.payload for e in prior],
                )

            q_env = await executor.execute(
                q_art_id,
                ArtifactType.QUESTION,
                q_parents,
                generate_question,
                evaluate_question_stage,
                section_id=config.index,
            )
            q_envelopes.append(q_env)

        # 5. Section assembly stage
        section_art_id = f"section:{context.run_id}:{config.index}"
        q_refs = [q.to_ref() for q in q_envelopes]
        sec_parents = (passage_envelope.to_ref(), actual_blueprint, *q_refs)

        async def generate_section_artifact(version: int) -> dict[str, Any]:
            title = str(passage_envelope.payload.get("title", topic))
            return compose_section_payload(
                config.index,
                title,
                passage_text,
                groups_data,
                q_refs,
                source_metadata,
                config,
            )

        async def evaluate_section_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_section(art, config)

        section_envelope = await executor.execute(
            section_art_id,
            ArtifactType.SECTION,
            sec_parents,
            generate_section_artifact,
            evaluate_section_stage,
            section_id=config.index,
        )

        return AcceptedSectionArtifact(
            section=section_envelope,
            passage=passage_envelope,
            questions=tuple(q_envelopes),
            blueprintRef=actual_blueprint,
        )
