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
from app.loop.section import SectionLoop
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
            or (is_benchmark is None and (run_id.lower().startswith("bench_") or "benchmark" in run_id.lower() or "test" in run_id.lower()))
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
            or (is_benchmark is None and (run_id.lower().startswith("bench_") or "benchmark" in run_id.lower() or "test" in run_id.lower()))
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

    async def generate_section_v2(
        self,
        section_index: int,
        title: str,
        passage_artifact: ArtifactEnvelope,
        blueprint_ref: ArtifactRef,
        question_artifacts: List[ArtifactEnvelope],
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        source_info: Optional[Any] = None,
        persistence_client: Optional[CheckpointClient] = None,
        policy: Optional[LoopPolicy] = None,
        is_benchmark: Optional[bool] = None,
    ) -> LoopResult:
        """Executes V2 SectionLoop through configured DI composition."""
        client = persistence_client or self.get_persistence_client()
        benchmark_mode = (
            is_benchmark is True
            or (is_benchmark is None and (run_id.lower().startswith("bench_") or "benchmark" in run_id.lower() or "test" in run_id.lower()))
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
            generate_reservation_cap="generateTokenReservation",
        )
        client = persistence_client or self.get_persistence_client()
        if self._gateway.checkpoint_client is None:
            self._gateway.checkpoint_client = client

        # Create per-request evaluators carrying the resolved policy's timeouts
        evaluators = [
            SectionStructureEvaluator(required=True, timeout_seconds=resolved_policy.evaluator_stage_timeout_seconds),
            SectionDuplicateAndConcentrationEvaluator(required=True, timeout_seconds=resolved_policy.evaluator_stage_timeout_seconds),
            SectionEditorialEvaluator(required=False, timeout_seconds=resolved_policy.evaluator_semantic_timeout_seconds),
        ]
        sec_loop = SectionLoop(
            persistence_client=client,
            evaluators=evaluators,
            repairer=SectionSurgicalRepairer(),
            policy=resolved_policy,
            is_benchmark=benchmark_mode,
        )
        t0 = time.perf_counter()
        try:
            res = await sec_loop.run(
                section_index=section_index,
                title=title,
                passage_artifact=passage_artifact,
                blueprint_ref=blueprint_ref,
                question_artifacts=question_artifacts,
                run_id=run_id,
                lease_owner=lease_owner,
                epoch=epoch,
                source_info=source_info,
            )
            get_metrics_recorder().record_operation_latency(
                time.perf_counter() - t0,
                OperationKind.SYNTHESIS,
                StatusKind.COMPLETED if res.decision.value == "PASS" else StatusKind.FAILED,
            )
            seq = getattr(res, "total_iterations", 1) or 1
            get_decision_lineage().record_decision(
                decision_id=f"dec_section_{run_id}_{seq}",
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

    # ----- Source / ingestion pass-throughs (Phase 15 Canonical Ingestion Delegation) -----
    async def search_sources(self, topic: str) -> Dict[str, Any]:
        """Canonical delegator to app.ingestion.fetcher.search_sources."""
        from app.ingestion.fetcher import search_sources as _search_sources

        return await _search_sources(topic)

    async def fetch_source(self, pmcid: str) -> Dict[str, Any]:
        """Canonical delegator to app.ingestion.fetcher.fetch_source with content set to None."""
        from app.ingestion.fetcher import fetch_source as _fetch_source

        res = await _fetch_source(pmcid)
        return {**res, "content": None}

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

    async def generate_section(
        self,
        topic: str,
        index: int,
        source: Dict[str, Any],
        progress: Optional[Any] = None,
        provider: Optional[str] = None,
        *,
        run_id: str,
        epoch: int = 1,
        lease_owner: UUID,
        parent_operation_id: str,
    ) -> Dict[str, Any]:
        """Canonical V2 section generation entrypoint delegating to SectionLoop.

        Maintains full backward-compatible dictionary return signature for legacy callers:
        {"title": str, "passage": str, "groups": list[dict]}.
        """
        from app.blueprint.planner import BlueprintPlanner, SectionPlanInput
        from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
        from app.contracts.blueprint import ExamBlueprint
        from app.evidence.extractor import extract_atomic_claims
        from app.evidence.graph import (
            EvidenceGraphBuilder,
            EvidenceGraphStatus,
            MIN_VERIFIED_CLAIMS_FOR_PASSAGE,
        )
        from app.generators.passage.context import PassageGenerationContext
        from app.ingestion.chunker import extract_spans
        from app.ingestion.source_pack import SourcePackBuilder

        # Strict fail-closed source validation
        source_text_content = source.get("content", "") if isinstance(source, dict) else str(source)
        if not source_text_content or len(source_text_content.strip()) < 50:
            raise ValueError("Source content must contain at least 50 characters of verified text for section generation")

        source_id = source.get("pmcid") if isinstance(source, dict) and source.get("pmcid") else f"SRC_{uuid4().hex[:8]}"
        source_title = source.get("title", f"Source for {topic}") if isinstance(source, dict) else f"Source for {topic}"
        source_url = source.get("url", "https://europepmc.org") if isinstance(source, dict) else "https://europepmc.org"

        # Step 1: Ingestion — Build canonical SourcePack artifact
        spans = extract_spans(source_text_content, source_id)
        source_item = SourcePackBuilder.build_source_item(
            source_id=source_id,
            raw_content=source_text_content,
            normalized_text=source_text_content,
            title=source_title,
            source_url=source_url,
            pmcid=source.get("pmcid") if isinstance(source, dict) else None,
        )
        sec_det_suffix = hashlib.sha256(f"{run_id}:sec_{index}:{source_id}".encode("utf-8")).hexdigest()[:8]
        source_pack = SourcePackBuilder.build_source_pack(
            pack_id=f"sp_sec_{index}_{sec_det_suffix}",
            run_id=run_id,
            sources=[source_item],
            section_id=index,
        )
        sp_env = SourcePackBuilder.to_artifact_envelope(source_pack)

        # Step 2: Evidence — Extract atomic claims and build verified EvidenceGraph
        candidate_claims = extract_atomic_claims(source_text_content, source_id, spans)
        build_res = EvidenceGraphBuilder.build_evidence_graph(
            graph_id=f"eg_sec_{index}_{sec_det_suffix}",
            run_id=run_id,
            candidate_claims=candidate_claims,
            source_text=source_text_content,
            source_pack=source_pack,
            section_id=index,
            fail_closed_on_any_invalid=False,
        )

        if (
            build_res.status != EvidenceGraphStatus.ACCEPTED
            or not build_res.graph
            or len(build_res.graph.claims) < MIN_VERIFIED_CLAIMS_FOR_PASSAGE
        ):
            raise ValueError(
                f"Source evidence verification failed: {build_res.blocking_reason or 'Insufficient verified claims in source text'}"
            )

        eg_env = EvidenceGraphBuilder.to_artifact_envelope(build_res.graph, source_pack_ref=sp_env.to_ref())
        canonical_graph = build_res.graph.model_copy(
            update={
                "content_hash": eg_env.content_hash,
                "source_pack_id": source_pack.pack_id,
            }
        )

        # Step 3: Blueprint — Plan deterministic SectionBlueprint and ExamBlueprint
        planner = BlueprintPlanner()
        sec_plan_input = SectionPlanInput(
            sectionId=index,
            topic=topic,
            evidenceGraph=canonical_graph,
        )
        sec_bp = planner._plan_section(sec_plan_input)
        bp = ExamBlueprint(
            blueprintId=f"bp_sec_{index}_{sec_det_suffix}",
            runId=run_id,
            sections=[sec_bp],
        )
        bp_env = ArtifactEnvelope.create(
            artifact_id=bp.blueprint_id,
            artifact_type=ArtifactType.EXAM_BLUEPRINT,
            run_id=run_id,
            version=1,
            producer_version="BlueprintPlanner:2.0.0",
            payload=bp.model_dump(mode="json", by_alias=True),
            parent_refs=[eg_env.to_ref()],
        )

        q_slots_dicts = [
            {
                "questionNumber": s.question_number,
                "slotNumber": s.question_number,
                "number": s.question_number,
                "questionType": s.question_type.value if hasattr(s.question_type, "value") else str(s.question_type),
                "type": s.question_type.value if hasattr(s.question_type, "value") else str(s.question_type),
                "groupId": f"group_{index}_{s.group_index + 1}",
                "group_id": f"group_{index}_{s.group_index + 1}",
                "claimRefIds": s.claim_ref_ids,
            }
            for s in sec_bp.question_slots
        ]

        # Step 4: Durably commit upstream artifacts (SourcePack, EvidenceGraph, ExamBlueprint) as accepted heads (fail-closed)
        try:
            client = self.get_persistence_client()
        except ValueError:
            client = None

        if client is not None:
            persisted_map = {}
            try:
                state = client.resume_state(run_id)
                for art in getattr(state, "artifacts", []):
                    aid = getattr(art, "artifactId", None) or getattr(art, "artifact_id", None)
                    if aid:
                        persisted_map[aid] = art
            except Exception:
                pass

            if sp_env.artifact_id in persisted_map and eg_env.artifact_id in persisted_map and bp_env.artifact_id in persisted_map:
                sp_stored = persisted_map[sp_env.artifact_id]
                eg_stored = persisted_map[eg_env.artifact_id]
                bp_stored = persisted_map[bp_env.artifact_id]
                try:
                    if getattr(sp_stored, "envelopeJson", None):
                        sp_env = ArtifactEnvelope.model_validate_json(sp_stored.envelopeJson)
                    if getattr(eg_stored, "envelopeJson", None):
                        eg_env = ArtifactEnvelope.model_validate_json(eg_stored.envelopeJson)
                    if getattr(bp_stored, "envelopeJson", None):
                        bp_env = ArtifactEnvelope.model_validate_json(bp_stored.envelopeJson)
                except Exception:
                    pass
            else:
                for upstream_env in [sp_env, eg_env, bp_env]:
                    if upstream_env.artifact_id in persisted_map:
                        continue
                    op_id = f"init:{run_id}:{upstream_env.artifact_id}:{upstream_env.version}"
                    grant = client.grant_operation(OperationGrantRequest(
                        runId=run_id,
                        epoch=epoch,
                        leaseOwner=lease_owner,
                        operationId=op_id,
                        operationType="CHECKPOINT_COMMIT",
                        requestHash=upstream_env.content_hash,
                        tokenReservation=0,
                        wallTimeReservationSeconds=10.0,
                        artifactId=upstream_env.artifact_id,
                    ))
                    if grant.status not in ("RESERVED", "GRANTED") and not getattr(grant, "is_replay", getattr(grant, "isReplay", False)):
                        raise ValueError(f"Failed to grant bootstrap commit for {upstream_env.artifact_id}: status={grant.status}")

                    ack = client.commit_checkpoint(CheckpointCommitRequest(
                        runId=run_id,
                        epoch=epoch,
                        leaseOwner=lease_owner,
                        operationId=op_id,
                        requestHash=upstream_env.content_hash,
                        artifact=upstream_env,
                        expectedHeadVersion=None,
                        decision=None,
                        evaluations=None,
                        tokensUsed=0,
                        costUsedUsd=0.0,
                        wallTimeUsedSeconds=0.1,
                    ))
                    ack_art_id = getattr(ack, "artifact_id", getattr(ack, "artifactId", ""))
                    ack_version = getattr(ack, "version", None)
                    if ack_art_id != upstream_env.artifact_id or ack_version != upstream_env.version:
                        raise ValueError(f"Bootstrap commit ack mismatch for {upstream_env.artifact_id}: expected v{upstream_env.version}, got ack {ack}")
        # Step 5: Run V2 PassageLoop with real artifact references and accepted upstream dependencies
        passage_ctx = PassageGenerationContext(
            blueprintRef=bp_env.to_ref(),
            evidenceGraphRef=eg_env.to_ref(),
            sourcePackRef=sp_env.to_ref(),
            sectionIndex=index,
            topic=topic,
            sourceText=source_text_content,
        )
        upstream_deps = {
            sp_env.artifact_id: sp_env.to_ref(),
            eg_env.artifact_id: eg_env.to_ref(),
            bp_env.artifact_id: bp_env.to_ref(),
        }
        # Determine benchmark/unlimited mode
        is_bench = (
            (provider and provider.strip().lower() == "minimax")
            or run_id.lower().startswith("bench_")
            or "benchmark" in run_id.lower()
            or "test" in run_id.lower()
            or (isinstance(source, dict) and str(source.get("metadata", {}).get("provider", "")).lower() == "minimax")
        )
        if not is_bench and client is not None:
            try:
                state = client.resume_state(run_id)
                if state and state.budgetProfileJson:
                    import json
                    prof = json.loads(state.budgetProfileJson) if isinstance(state.budgetProfileJson, str) else state.budgetProfileJson
                    if prof.get("benchmarkMode") == "UNLIMITED" and prof.get("benchmarkMonetaryCapMode") == "UNLIMITED":
                        is_bench = True
            except Exception:
                pass

        passage_res = await self.generate_passage_v2(
            passage_context=passage_ctx,
            run_id=run_id,
            lease_owner=lease_owner,
            epoch=epoch,
            accepted_dependencies=upstream_deps,
            is_benchmark=is_bench,
            parent_operation_id=parent_operation_id,
        )
        passage_env = passage_res.accepted_artifact
        if passage_env is None:
            raise ValueError(f"Passage generation failed in section {index}: {passage_res.terminal_reason or 'No accepted passage produced'}")
        # Step 5: Run V2 Question Candidate Loop with canonical question slots
        q_res = await self.generate_questions_v2(
            passage_artifact=passage_env,
            blueprint_ref=bp_env.to_ref(),
            question_slots=q_slots_dicts,
            run_id=run_id,
            lease_owner=lease_owner,
            epoch=epoch,
            section_index=index,
            is_benchmark=is_bench,
            parent_operation_id=parent_operation_id,
        )
        sec_start = 1 if index == 1 else (14 if index == 2 else 27)
        sec_end = 13 if index == 1 else (26 if index == 2 else 40)

        def _belongs_to_section(art_obj: Any) -> bool:
            if not art_obj:
                return False
            aid = str(getattr(art_obj, "artifact_id", None) or getattr(art_obj, "artifactId", "") or "")
            if f"_s{index}_" in aid or aid.startswith(f"art_grp_s{index}_") or aid.startswith(f"art_q_s{index}_"):
                return True
            p = getattr(art_obj, "payload", None)
            if isinstance(p, dict):
                qn = p.get("questionNumber") or p.get("number")
                if qn is not None and sec_start <= int(qn) <= sec_end:
                    return True
                qs = p.get("questions")
                if isinstance(qs, (list, tuple)):
                    for sub_q in qs:
                        if isinstance(sub_q, dict):
                            sub_qn = sub_q.get("questionNumber") or sub_q.get("number")
                            if sub_qn is not None and sec_start <= int(sub_qn) <= sec_end:
                                return True
            if aid.startswith("art_q_slot_"):
                slot_str = aid.replace("art_q_slot_", "")
                if slot_str.isdigit() and sec_start <= int(slot_str) <= sec_end:
                    return True
            return False

        if isinstance(q_res, dict):
            if "question_envelopes" in q_res and q_res["question_envelopes"]:
                q_envelopes = [e for e in q_res["question_envelopes"] if _belongs_to_section(e)]
            elif "questions" in q_res and q_res["questions"]:
                questions_map = q_res["questions"]
                if isinstance(questions_map, dict):
                    seen_art_ids = set()
                    q_envelopes = []
                    for art in questions_map.values():
                        if art and not hasattr(art, "payload") and getattr(art, "envelopeJson", None):
                            try:
                                art = ArtifactEnvelope.model_validate_json(art.envelopeJson)
                            except Exception:
                                pass
                        art_id = getattr(art, "artifact_id", getattr(art, "artifactId", None))
                        if art and art_id and art_id not in seen_art_ids and _belongs_to_section(art):
                            seen_art_ids.add(art_id)
                            q_envelopes.append(art)
                elif isinstance(questions_map, list):
                    q_envelopes = []
                    for art in questions_map:
                        if art and not hasattr(art, "payload") and getattr(art, "envelopeJson", None):
                            try:
                                art = ArtifactEnvelope.model_validate_json(art.envelopeJson)
                            except Exception:
                                pass
                        if art and _belongs_to_section(art):
                            q_envelopes.append(art)
            else:
                q_envelopes = []
        else:
            q_envelopes = []
        # Step 6: Run V2 SectionLoop with verified artifacts
        sec_res = await self.generate_section_v2(
            section_index=index,
            title=getattr(passage_env.payload, "title", topic) if passage_env and hasattr(passage_env, "payload") else topic,
            passage_artifact=passage_env,
            blueprint_ref=bp_env.to_ref(),
            question_artifacts=q_envelopes,
            run_id=run_id,
            lease_owner=lease_owner,
            epoch=epoch,
            source_info=source,
            is_benchmark=is_bench,
        )
        # Step 5: Format backward-compatible dictionary output
        final_art = sec_res.accepted_artifact
        if final_art and hasattr(final_art, "payload"):
            payload = final_art.payload
            groups = []
            raw_groups = None
            if hasattr(payload, "groups"):
                raw_groups = payload.groups
            elif hasattr(payload, "get"):
                raw_groups = payload.get("groups")

            if raw_groups:
                for grp in raw_groups:
                    grp_dict = grp.model_dump(by_alias=True) if hasattr(grp, "model_dump") else grp.dict(by_alias=True) if hasattr(grp, "dict") else dict(grp)
                    groups.append(grp_dict)

            title_val = getattr(payload, "title", None) or (payload.get("title") if hasattr(payload, "get") else None) or topic
            passage_val = getattr(payload, "passage", None) or (payload.get("passage") if hasattr(payload, "get") else None) or ""

            return {
                "title": title_val,
                "passage": passage_val,
                "source": source,
                "groups": groups,
            }

        return {
            "title": topic,
            "passage": getattr(passage_env.payload, "text", None) or (passage_env.payload.get("text") if passage_env and hasattr(passage_env.payload, "get") else "") if passage_env else "",
            "source": source,
            "groups": [],
        }

    async def generate_section_legacy(
        self,
        *,
        topic: str,
        index: int,
        source: Dict[str, Any],
        provider: Optional[str] = None,
        run_id: str,
        epoch: int = 1,
        lease_owner: UUID,
        parent_operation_id: str,
    ) -> Dict[str, Any]:
        """Legacy execution alias routing to pipeline.generate_section."""
        from app.pipeline import generate_section as _generate_section

        return await _generate_section(
            topic,
            index,
            source,
            provider=provider,
            run_id=run_id,
            epoch=epoch,
            lease_owner=lease_owner,
            parent_operation_id=parent_operation_id,
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
