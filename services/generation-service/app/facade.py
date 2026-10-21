"""Unified Dependency Injection and Service Facade for Langfens V2 Loop Engine.

Orchestrates ProviderGateway, EvaluatorRegistry, RepairRegistry,
authoritative CheckpointClient, and the PassageLoop composition.
"""

from __future__ import annotations
import hashlib
import logging
import time
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4
from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import IssueScope
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.persistence.models import CheckpointCommitRequest, OperationGrantRequest
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    DuplicateAndShingleEvaluator,
    EvidenceOffsetEvaluator,
    PassageStyleEvaluator,
    PassageWordCountEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.paper import (
    PaperCrossSectionEvaluator,
    PaperLeakageEvaluator,
    PaperMonotonyEvaluator,
    PaperStructureEvaluator,
)
from app.evaluators.section import (
    SectionDuplicateAndConcentrationEvaluator,
    SectionEditorialEvaluator,
    SectionStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.semantic import (
    AmbiguityAndDistractorEvaluator,
    GroundingFidelityEvaluator,
    HeuristicQualityScorer,
    NotGivenSemanticsEvaluator,
)
from app.evaluators.solver import BlindSolverEvaluator
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.generators.passage.prompts import PassageStyleProfile
from app.curation.curation import CurationManager
from app.curation.export import DatasetExporter
from app.curation.partitioning import ConnectedComponentSplitter
from app.offline_eval.comparison import PairedOfflineComparator
from app.offline_eval.runner import OfflineEvalRunner
from app.promotion.promotion import VersionPromotionManager
from app.promotion.registry import PromptVersionRegistry
from app.loop.passage import PassageLoop
from app.repair.section import SectionSurgicalRepairer
from app.repair.paper import (
    PaperRepairActionType,
    PaperRepairDirective,
    PaperRepairResult,
    PaperRepairRoute,
    PaperRepairRouter,
    PaperSurgicalRepairer,
)
from app.loop.paper import PaperLoop
from app.loop.policy import LoopPolicy
from app.loop.runtime import LoopResult
from app.persistence.client import CheckpointClient
from app.providers.gateway import ProviderGateway
from app.providers.registry import ProviderRegistry
from app.repair.passage import PassageSentenceRepairer
from app.repair.registry import RepairRegistry

from app.observability.accounting import get_decision_lineage
from app.observability.metrics import get_metrics_recorder
from app.observability.redaction import OperationKind, StatusKind, VerdictKind

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
            eval_reg.register(GroundingFidelityEvaluator())
            eval_reg.register(AmbiguityAndDistractorEvaluator())
            eval_reg.register(NotGivenSemanticsEvaluator())
            eval_reg.register(HeuristicQualityScorer())
            eval_reg.register(SectionStructureEvaluator())
            eval_reg.register(SectionDuplicateAndConcentrationEvaluator())
            eval_reg.register(SectionEditorialEvaluator())
            eval_reg.register(PaperStructureEvaluator())
            eval_reg.register(PaperCrossSectionEvaluator())
            eval_reg.register(PaperLeakageEvaluator())
            eval_reg.register(PaperMonotonyEvaluator())
            eval_reg.register(BlindSolverEvaluator(gateway=self._gateway))
            evaluator_registry = eval_reg
        self._evaluator_registry = evaluator_registry

        if repair_registry is None:
            rep_reg = RepairRegistry()
            rep_reg.register(PassageSentenceRepairer())
            repair_registry = rep_reg
            rep_reg.register(SectionSurgicalRepairer())
            rep_reg.register(PaperSurgicalRepairer())
        self._repair_registry = repair_registry

        self._persistence_client = persistence_client
        if self._persistence_client and self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = self._persistence_client
        self._passage_generator = PassageGenerator(gateway=self._gateway)
        self._curation_manager = CurationManager()
        self._dataset_exporter = DatasetExporter()
        self._component_splitter = ConnectedComponentSplitter()
        self._paired_comparator = PairedOfflineComparator()
        self._eval_runner = OfflineEvalRunner(comparator=self._paired_comparator)
        self._prompt_registry = PromptVersionRegistry()
        self._promotion_manager = VersionPromotionManager(registry=self._prompt_registry)
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
    @property
    def curation_manager(self) -> CurationManager:
        return self._curation_manager

    @property
    def dataset_exporter(self) -> DatasetExporter:
        return self._dataset_exporter

    @property
    def component_splitter(self) -> ConnectedComponentSplitter:
        return self._component_splitter

    @property
    def paired_comparator(self) -> PairedOfflineComparator:
        return self._paired_comparator

    @property
    def eval_runner(self) -> OfflineEvalRunner:
        return self._eval_runner

    @property
    def prompt_registry(self) -> PromptVersionRegistry:
        return self._prompt_registry

    @property
    def promotion_manager(self) -> VersionPromotionManager:
        return self._promotion_manager

    def bind_run(self, run_id: str) -> str:
        """Binds a run to the currently active pinned prompt version.

        If the run was already bound, returns its existing pinned version
        (in-flight run retention).
        """
        return self._prompt_registry.get_version_for_run(run_id)

    def compute_solver_cache_key(self, run_id: str, content_hash: str) -> str:
        """Generates version-isolated solver cache key."""
        prompt_ver = self.bind_run(run_id)
        eval_ver = f"{prompt_ver}:v2"
        return f"{prompt_ver}:{eval_ver}:{content_hash}"
    async def generate_passage_v2(
        self,
        passage_context: PassageGenerationContext,
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        persistence_client: Optional[CheckpointClient] = None,
        policy: Optional[LoopPolicy] = None,
        accepted_dependencies: Optional[Dict[str, ArtifactRef]] = None,
        is_benchmark: Optional[bool] = None,
        parent_operation_id: Optional[str] = None,
    ) -> LoopResult:
        """Executes the V2 PassageLoop through configured DI composition."""
        client = persistence_client or self.get_persistence_client()
        benchmark_mode = (
            is_benchmark is True
            or (is_benchmark is None and run_id.lower().startswith("bench_"))
        )
        if not benchmark_mode and client is not None:
            try:
                state = client.resume_state(run_id)
                if state and state.budgetProfileJson:
                    import json
                    prof = json.loads(state.budgetProfileJson) if isinstance(state.budgetProfileJson, str) else state.budgetProfileJson
                    if prof.get("benchmarkMode") == "UNLIMITED" and prof.get("benchmarkMonetaryCapMode") == "UNLIMITED":
                        benchmark_mode = True
            except Exception:
                pass
        resolved_policy = policy or LoopPolicy.from_settings(
            is_benchmark=benchmark_mode,
            generate_reservation_cap="passageGenerateTokenReservation",
        )
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = client
        passage_loop = PassageLoop(
            generator=self._passage_generator,
            persistence_client=client,
            policy=resolved_policy,
            is_benchmark=benchmark_mode,
        )
        t0 = time.perf_counter()
        try:
            res = await passage_loop.run(
                passage_context=passage_context,
                run_id=run_id,
                lease_owner=lease_owner,
                epoch=epoch,
                accepted_dependencies=accepted_dependencies,
                parent_operation_id=parent_operation_id,
            )
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.COMPLETED if res.decision.value == "PASS" else StatusKind.FAILED,
            )
            seq = getattr(res, "total_iterations", 1) or 1
            get_decision_lineage().record_decision(
                decision_id=f"dec_passage_{run_id}_{seq}",
                run_id=run_id,
                sequence=seq,
                decision_type=res.decision.value,
                reason=res.terminal_reason,
            )
            return res
        except Exception:
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.FAILED,
            )
            raise

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
        is_benchmark: Optional[bool] = None,
        parent_operation_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Executes V2 Question Candidate Loop through configured DI composition."""
        from app.generators.question.generator import QuestionCandidateGenerator
        from app.loop.question import QuestionCandidateLoop

        client = persistence_client or self.get_persistence_client()
        benchmark_mode = (
            is_benchmark is True
            or (is_benchmark is None and run_id.lower().startswith("bench_"))
        )
        if not benchmark_mode and client is not None:
            try:
                state = client.resume_state(run_id)
                if state and state.budgetProfileJson:
                    import json
                    prof = json.loads(state.budgetProfileJson) if isinstance(state.budgetProfileJson, str) else state.budgetProfileJson
                    if prof.get("benchmarkMode") == "UNLIMITED" and prof.get("benchmarkMonetaryCapMode") == "UNLIMITED":
                        benchmark_mode = True
            except Exception:
                pass
        resolved_policy = policy or LoopPolicy.from_settings(is_benchmark=benchmark_mode)

        client = persistence_client or self.get_persistence_client()
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = client
        generator = QuestionCandidateGenerator(gateway=self._gateway)

        # Per-request evaluator registry for question candidate loop
        reg = EvaluatorRegistry()
        reg.register(QuestionStructureEvaluator(timeout_seconds=resolved_policy.evaluator_deterministic_timeout_seconds))
        reg.register(AnswerVerbatimAndLengthEvaluator(timeout_seconds=resolved_policy.evaluator_deterministic_timeout_seconds))
        reg.register(AmbiguityAndDistractorEvaluator(timeout_seconds=resolved_policy.evaluator_semantic_timeout_seconds, estimated_tokens=resolved_policy.evaluator_max_tokens_per_evaluation))
        reg.register(NotGivenSemanticsEvaluator(timeout_seconds=resolved_policy.evaluator_semantic_timeout_seconds, estimated_tokens=resolved_policy.evaluator_max_tokens_per_evaluation))

        q_loop = QuestionCandidateLoop(
            generator=generator,
            persistence_client=client,
            evaluator_registry=reg,
            policy=resolved_policy,
        )
        t0 = time.perf_counter()
        try:
            res = await q_loop.run(
                passage_artifact=passage_artifact,
                blueprint_ref=blueprint_ref,
                question_slots=question_slots,
                run_id=run_id,
                lease_owner=lease_owner,
                epoch=epoch,
                section_index=section_index,
                parent_operation_id=parent_operation_id,
            )
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.COMPLETED,
            )
            return res
        except Exception:
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.FAILED,
            )
            raise

    # ----- Source / ingestion pass-throughs (Phase 15 Canonical Ingestion Delegation) -----
    async def search_sources(self, topic: str) -> Dict[str, Any]:
        """Canonical delegator to app.ingestion.fetcher.search_sources."""
        from app.ingestion.fetcher import search_sources as _search_sources

        return await _search_sources(topic)

    async def fetch_source(self, pmcid: str) -> Dict[str, Any]:
        """Canonical delegator to app.ingestion.fetcher.fetch_source."""
        from app.ingestion.fetcher import fetch_source as _fetch_source

        return await _fetch_source(pmcid)

    async def ingest_source(
        self,
        *,
        payload: str,
        source_type: str = "auto",
        title: Optional[str] = None,
        url: Optional[str] = None,
        authors: Optional[str] = None,
        license_str: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Canonical delegator to app.ingestion.fetcher.ingest_source."""
        from app.ingestion.fetcher import ingest_source as _ingest_source

        return await _ingest_source(
            payload=payload,
            source_type=source_type,
            title=title,
            url=url,
            authors=authors,
            license_str=license_str,
        )

    def default_question_policy(self):
        from app.loop.policy import LoopPolicy

        return LoopPolicy.from_settings(
            required_evaluator_ids=(
                "eval_question_structure",
                "eval_answer_verbatim_length",
            ),
        )

    async def evaluate_paper_async(
        self,
        paper_artifact: ArtifactEnvelope,
        run_id: Optional[str] = None,
        lease_owner: Optional[UUID] = None,
        epoch: int = 1,
    ) -> List[EvaluationResult]:
        """Executes all registered ReadingPaper evaluators against the paper envelope."""
        from app.contracts.issue import IssueScope
        from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
        owner_str = str(lease_owner) if lease_owner else str(uuid4())
        rid = run_id or paper_artifact.run_id
        context = LoopContext(
            runId=rid,
            scope=IssueScope.PAPER,
            targetArtifactId=paper_artifact.artifact_id,
            targetArtifactType=ArtifactType.READING_PAPER,
            authority=AuthorityGrant(leaseOwner=owner_str, epoch=epoch),
            budgetTracker=BudgetTracker(),
            inputDependencies=paper_artifact.parent_refs,
        )
        t0 = time.perf_counter()
        try:
            eval_results = await self._evaluator_registry.evaluate_pipeline(
                context=context,
                artifact=paper_artifact,
                intent_id=f"eval_paper_{uuid4().hex[:8]}",
            )
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.AUDIT,
                StatusKind.COMPLETED,
            )
            for ev_res in eval_results:
                get_metrics_recorder().record_evaluator(
                    evaluator_kind=ev_res.evaluator_id,
                    verdict=VerdictKind.PASS if ev_res.is_pass() else VerdictKind.FAIL,
                    duration=getattr(ev_res, "elapsed_ms", 0.0) / 1000.0 if getattr(ev_res, "elapsed_ms", None) else 0.0,
                )
            return eval_results
        except Exception:
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.AUDIT,
                StatusKind.FAILED,
            )
            raise

    async def repair_paper_async(
        self,
        paper_artifact: ArtifactEnvelope,
        directive: PaperRepairDirective,
    ) -> PaperRepairResult:
        """Executes a surgical repair directive on a ReadingPaper artifact."""
        repairer = PaperSurgicalRepairer()
        return repairer.repair_paper(paper_artifact, directive)

    async def generate_paper_v2(
        self,
        blueprint_ref: ArtifactRef,
        section_artifacts: List[ArtifactEnvelope],
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        title: Optional[str] = None,
        paper_id: Optional[str] = None,
        parent_operation_id: Optional[str] = None,
        persistence_client: Optional[CheckpointClient] = None,
        policy: Optional[LoopPolicy] = None,
        is_benchmark: Optional[bool] = None,
        evaluator_registry: Optional[EvaluatorRegistry] = None,
    ) -> LoopResult:
        """Executes V2 PaperLoop through configured DI composition."""
        benchmark_mode = (
            is_benchmark is True
            or (is_benchmark is None and run_id.lower().startswith("bench_"))
        )
        resolved_policy = policy or LoopPolicy.from_settings(is_benchmark=benchmark_mode)

        client = persistence_client or self.get_persistence_client()
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = client

        # Build per-request benchmark-aware evaluator registry without mutating the shared registry
        if evaluator_registry is None:
            reg = EvaluatorRegistry()
            reg.register(PaperStructureEvaluator(timeout_seconds=resolved_policy.evaluator_stage_timeout_seconds))
            reg.register(PaperCrossSectionEvaluator(timeout_seconds=resolved_policy.evaluator_stage_timeout_seconds))
            reg.register(PaperLeakageEvaluator(timeout_seconds=resolved_policy.evaluator_stage_timeout_seconds))
            reg.register(PaperMonotonyEvaluator(timeout_seconds=resolved_policy.evaluator_stage_timeout_seconds))
            evaluator_reg = reg
        else:
            evaluator_reg = evaluator_registry

        paper_loop = PaperLoop(
            persistence_client=client,
            evaluator_registry=evaluator_reg,
            policy=resolved_policy,
            is_benchmark=benchmark_mode,
        )
        t0 = time.perf_counter()
        try:
            res = await paper_loop.run(
                run_id=run_id,
                blueprint_ref=blueprint_ref,
                section_envelopes=section_artifacts,
                title=title,
                paper_id=paper_id,
                parent_operation_id=parent_operation_id,
                owner=str(lease_owner),
                epoch=epoch,
                is_benchmark=benchmark_mode,
            )
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.COMPLETED if res.decision.value == "PASS" else StatusKind.FAILED,
            )
            seq = getattr(res, "total_iterations", 1) or 1
            get_decision_lineage().record_decision(
                decision_id=f"dec_paper_{run_id}_{seq}",
                run_id=run_id,
                sequence=seq,
                decision_type=res.decision.value,
                reason=res.terminal_reason,
            )
            return res
        except Exception:
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.FAILED,
            )
            raise
_default_facade: Optional[GenerationFacade] = None


def get_generation_facade() -> GenerationFacade:
    """Returns the shared singleton instance of GenerationFacade."""
    global _default_facade
    if _default_facade is None:
        _default_facade = GenerationFacade()
    return _default_facade
