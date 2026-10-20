"""Canonical ReadingGenerationPipeline executing fenced, durable multi-stage reading generation.

Executes Stage 0 (validate run), Stage 1 (sources), Stage 2 (evidence),
Stage 3 (blueprint), Stage 4-6 (SectionRunner per selected section, sequential or parallel),
Stage 7 (Paper assembly if all 3 sections present), Stage 8 (CheckpointClient.build_exam if finalize=True).
"""

from __future__ import annotations

import asyncio
import logging
from collections.abc import Callable, Sequence
from typing import Any, Optional
from uuid import UUID

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult
from app.persistence.client import CheckpointClient
from app.persistence.models import BuildExamInternalRequest
from app.providers.gateway import ProviderGateway
from app.reading_evaluation import evaluate_blueprint, evaluate_evidence, evaluate_paper, evaluate_source
from app.reading_generation import build_blueprint, build_evidence, compose_paper_payload, prepare_source
from app.reading_models import (
    AcceptedSectionArtifact, PipelineRequest, PipelineResult, RunContext,
    SourceInput, SourceRef,
)
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.section_runner import SectionRunner
from app.stage_executor import StageExecutor

logger = logging.getLogger(__name__)


class ReadingGenerationPipeline:
    """Authoritative orchestrator for IELTS Reading paper generation."""

    def __init__(
        self,
        client: CheckpointClient,
        gateway: ProviderGateway,
        *,
        executor_factory: Optional[Callable[..., StageExecutor]] = None,
        runner_factory: Optional[Callable[..., SectionRunner]] = None,
    ) -> None:
        self.client = client
        self.gateway = gateway
        self.executor_factory = executor_factory
        self.runner_factory = runner_factory

    def _get_executor(
        self,
        context: RunContext,
        policy: PinnedExecutionPolicy,
        *,
        required_evaluator_ids: tuple[str, ...] = (),
    ) -> StageExecutor:
        if self.executor_factory:
            return self.executor_factory(context, policy, required_evaluator_ids=required_evaluator_ids)
        return StageExecutor(self.client, context, policy, required_evaluator_ids=required_evaluator_ids)

    def _get_runner(self) -> SectionRunner:
        if self.runner_factory:
            return self.runner_factory(self.client, self.gateway)
        return SectionRunner(self.client, self.gateway)

    async def execute(self, request: PipelineRequest) -> PipelineResult:
        """Executes the full generation pipeline across stages 0 through 8."""
        logger.info(
            "Starting ReadingGenerationPipeline run %s (sections=%s, parallel=%s, finalize=%s)",
            request.run_id,
            request.section_indices,
            request.parallel,
            request.finalize,
        )

        # ── Stage 0: Validate run authority and pinned policy ────────────────
        context = RunContext.from_request(request, client=self.client, gateway=self.gateway)
        executor = self._get_executor(context, request.policy)

        # Map sources by section index
        sources_by_section: dict[int, SourceInput] = {s.section_index: s for s in request.sources}
        for sec_idx in request.section_indices:
            if sec_idx not in sources_by_section:
                raise ValueError(f"Missing required source input for selected section {sec_idx}")

        # ── Stage 1: Ingest and verify sources ───────────────────────────────
        source_envelopes: dict[int, ArtifactEnvelope] = {}
        for sec_idx in sorted(request.section_indices):
            src_input = sources_by_section[sec_idx]
            art_id = f"source:{request.run_id}:{sec_idx}"

            async def generate_source(version: int, inp: SourceInput = src_input) -> dict[str, Any]:
                return await prepare_source(inp, request.run_id, request.policy)

            async def evaluate_source_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
                return evaluate_source(art, request.policy)

            env = await executor.execute(
                art_id,
                ArtifactType.SOURCE_PACK,
                (),
                generate_source,
                evaluate_source_stage,
                section_id=sec_idx,
            )
            source_envelopes[sec_idx] = env

        # ── Stage 2: Ground verified evidence claims ─────────────────────────
        evidence_envelopes: dict[int, ArtifactEnvelope] = {}
        for sec_idx in sorted(request.section_indices):
            art_id = f"evidence:{request.run_id}:{sec_idx}"
            src_env = source_envelopes[sec_idx]

            async def generate_evidence(
                version: int,
                s_env: ArtifactEnvelope = src_env,
                s_idx: int = sec_idx,
            ) -> dict[str, Any]:
                return build_evidence(s_env, request.run_id, s_idx, request.policy)

            async def evaluate_evidence_stage(
                art: ArtifactEnvelope,
                s_env: ArtifactEnvelope = src_env,
            ) -> list[EvaluationResult]:
                text_map = {
                    s_env.payload["sources"][0]["sourceId"]: s_env.payload["sources"][0]["document"]["text"]
                }
                return evaluate_evidence(art, text_map, request.policy.min_verified_claims)

            env = await executor.execute(
                art_id,
                ArtifactType.EVIDENCE_GRAPH,
                (src_env.to_ref(),),
                generate_evidence,
                evaluate_evidence_stage,
                section_id=sec_idx,
            )
            evidence_envelopes[sec_idx] = env

        # ── Stage 3: Exam Blueprint ──────────────────────────────────────────
        bp_art_id = f"blueprint:{request.run_id}"
        bp_indices = request.policy.section_indices

        async def generate_blueprint(version: int) -> dict[str, Any]:
            return build_blueprint(
                request.run_id,
                request.topic,
                bp_indices,
                source_envelopes,
                evidence_envelopes,
                request.policy,
            )

        async def evaluate_blueprint_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_blueprint(art, request.policy, bp_indices)

        blueprint_envelope = await executor.execute(
            bp_art_id,
            ArtifactType.EXAM_BLUEPRINT,
            (),
            generate_blueprint,
            evaluate_blueprint_stage,
        )

        # ── Stages 4–6: SectionRunner per selected section ───────────────────
        runner = self._get_runner()

        async def execute_section(sec_idx: int) -> AcceptedSectionArtifact:
            sec_config = request.policy.section(sec_idx)
            sec_source_ref = SourceRef(
                source=source_envelopes[sec_idx],
                evidence=evidence_envelopes[sec_idx],
            )
            return await runner.run(
                context,
                sec_config,
                sec_source_ref,
                blueprint_envelope.to_ref(),
                request.policy,
            )

        if request.parallel and len(request.section_indices) > 1:
            raw_sections = await asyncio.gather(
                *[execute_section(idx) for idx in request.section_indices]
            )
            accepted_sections = sorted(raw_sections, key=lambda s: s.section.section_id or 0)
        else:
            accepted_sections = []
            for sec_idx in sorted(request.section_indices):
                accepted_sections.append(await execute_section(sec_idx))

        # ── Stage 7: Reading Paper Assembly (if all 3 sections present) ─────
        paper_envelope: Optional[ArtifactEnvelope] = None
        if tuple(sorted(request.section_indices)) == (1, 2, 3):
            paper_art_id = f"paper:{request.run_id}"
            section_refs = [s.section.to_ref() for s in accepted_sections]
            passage_refs = [s.passage.to_ref() for s in accepted_sections]
            question_refs = [q.to_ref() for s in accepted_sections for q in s.questions]
            paper_parents = (blueprint_envelope.to_ref(), *section_refs, *passage_refs, *question_refs)

            async def generate_paper(version: int) -> dict[str, Any]:
                return compose_paper_payload(
                    blueprint_envelope.to_ref(),
                    accepted_sections,
                    request.policy,
                )

            async def evaluate_paper_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
                return evaluate_paper(art, request.policy)

            paper_envelope = await executor.execute(
                paper_art_id,
                ArtifactType.READING_PAPER,
                paper_parents,
                generate_paper,
                evaluate_paper_stage,
            )

        # ── Stage 8: CheckpointClient.build_exam (if finalize=True) ──────────
        exam_id: Optional[UUID] = None
        if request.finalize and paper_envelope is not None:
            build_req = BuildExamInternalRequest(
                runId=request.run_id,
                epoch=request.epoch,
                leaseOwner=request.lease_owner,
                jobId=request.job_id,
            )
            build_res = await asyncio.to_thread(self.client.build_exam, build_req)
            exam_id = build_res.examId

        stats = executor.snapshot_stats()
        return PipelineResult(
            runId=request.run_id,
            status="ACCEPTED",
            sections=tuple(s.envelope for s in accepted_sections),
            paper=paper_envelope,
            examId=exam_id,
            metrics={
                "stages_executed": len(request.section_indices),
                "artifacts_reused": stats.artifacts_reused,
                "drafts_persisted": stats.drafts_persisted,
                "acceptances_committed": stats.acceptances_committed,
            },
        )
