"""Unified Dependency Injection and Service Facade for Langfens V2 Loop Engine.

Orchestrates ProviderGateway, EvaluatorRegistry, RepairRegistry,
authoritative CheckpointClient, and the PassageLoop composition.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List, Optional
from uuid import UUID

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    DuplicateAndShingleEvaluator,
    EvidenceOffsetEvaluator,
    PaperStructureEvaluator,
    PassageStyleEvaluator,
    PassageWordCountEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    HeuristicQualityScorer,
    NotGivenSemanticsEvaluator,
)
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.generators.passage.prompts import PassageStyleProfile
from app.loop.passage import PassageLoop
from app.loop.policy import LoopPolicy
from app.loop.runtime import LoopResult
from app.persistence.client import CheckpointClient
from app.providers.gateway import ProviderGateway
from app.providers.registry import ProviderRegistry
from app.repair.passage import PassageSentenceRepairer
from app.repair.registry import RepairRegistry

logger = logging.getLogger(__name__)


class GenerationFacade:
    """Central entrypoint for V2 Autonomous Generation capabilities."""

    def __init__(
        self,
        gateway: Optional[ProviderGateway] = None,
        evaluator_registry: Optional[EvaluatorRegistry] = None,
        repair_registry: Optional[RepairRegistry] = None,
        persistence_client: Optional[CheckpointClient] = None,
    ):
        if gateway is None:
            provider_reg = ProviderRegistry()
            provider_reg.initialize_from_settings()
            gateway = ProviderGateway(registry=provider_reg)
        self._gateway = gateway

        if evaluator_registry is None:
            eval_reg = EvaluatorRegistry()
            # Register canonical evaluators
            eval_reg.register(PassageWordCountEvaluator())
            eval_reg.register(PassageStyleEvaluator())
            eval_reg.register(QuestionStructureEvaluator())
            eval_reg.register(AnswerVerbatimAndLengthEvaluator())
            eval_reg.register(EvidenceOffsetEvaluator())
            eval_reg.register(DuplicateAndShingleEvaluator())
            eval_reg.register(PaperStructureEvaluator())
            eval_reg.register(GroundingFidelityEvaluator())
            eval_reg.register(AmbiguityAndDistractorEvaluator())
            eval_reg.register(NotGivenSemanticsEvaluator())
            eval_reg.register(HeuristicQualityScorer())
            evaluator_registry = eval_reg
        self._evaluator_registry = evaluator_registry

        if repair_registry is None:
            rep_reg = RepairRegistry()
            rep_reg.register(PassageSentenceRepairer())
            repair_registry = rep_reg
        self._repair_registry = repair_registry

        self._persistence_client = persistence_client
        if self._persistence_client and self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = self._persistence_client
        self._passage_generator = PassageGenerator(gateway=self._gateway)
    @property
    def gateway(self) -> ProviderGateway:
        return self._gateway

    @property
    def evaluator_registry(self) -> EvaluatorRegistry:
        return self._evaluator_registry

    @property
    def repair_registry(self) -> RepairRegistry:
        return self._repair_registry

    @property
    def persistence_client(self) -> Optional[CheckpointClient]:
        return self._persistence_client

    def get_persistence_client(self) -> CheckpointClient:
        if self._persistence_client is None:
            self._persistence_client = CheckpointClient()
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = self._persistence_client
        return self._persistence_client
    async def generate_passage_v2(
        self,
        passage_context: PassageGenerationContext,
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        persistence_client: Optional[CheckpointClient] = None,
        policy: Optional[LoopPolicy] = None,
        accepted_dependencies: Optional[Dict[str, ArtifactRef]] = None,
    ) -> LoopResult:
        """Executes the V2 PassageLoop through configured DI composition."""
        client = persistence_client or self.get_persistence_client()
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = client
        passage_loop = PassageLoop(
            generator=self._passage_generator,
            persistence_client=client,
            policy=policy,
        )
        return await passage_loop.run(
            passage_context=passage_context,
            run_id=run_id,
            lease_owner=lease_owner,
            epoch=epoch,
            accepted_dependencies=accepted_dependencies,
        )

    async def generate_questions_v2(
        self,
        passage_artifact: ArtifactEnvelope,
        blueprint_ref: ArtifactRef,
        question_slots: List[Dict[str, Any]],
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        section_index: int = 1,
        persistence_client: Optional[CheckpointClient] = None,
        policy: Optional[LoopPolicy] = None,
    ) -> Dict[str, Any]:
        """Executes V2 Question Candidate Loop through configured DI composition."""
        from app.generators.question.generator import QuestionCandidateGenerator
        from app.loop.question import QuestionCandidateLoop

        client = persistence_client or self.get_persistence_client()
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = client
        generator = QuestionCandidateGenerator(gateway=self._gateway)
        q_loop = QuestionCandidateLoop(
            generator=generator,
            persistence_client=client,
            evaluator_registry=self._evaluator_registry,
            policy=policy,
        )
        return await q_loop.run(
            passage_artifact=passage_artifact,
            blueprint_ref=blueprint_ref,
            question_slots=question_slots,
            run_id=run_id,
            lease_owner=lease_owner,
            epoch=epoch,
            section_index=section_index,
        )


_default_facade: Optional[GenerationFacade] = None


def get_generation_facade() -> GenerationFacade:
    """Returns the shared singleton instance of GenerationFacade."""
    global _default_facade
    if _default_facade is None:
        _default_facade = GenerationFacade()
    return _default_facade
