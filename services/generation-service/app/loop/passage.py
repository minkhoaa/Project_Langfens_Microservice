"""Passage Loop composition on BoundedLoopRuntime for Langfens V2 (P08-04, P08-08).

Composes PassageGenerator, EvaluatorRegistry, RepairPlanner, and authoritative CheckpointClient.
Enforces crash resumption without redundant generation, CAS/fencing, and immutability.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List, Optional, Sequence
from uuid import UUID

from app.config import settings

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.policies import POLICY_VERSION, PASSAGE_MAX_WORDS, PASSAGE_MIN_WORDS
from app.evaluators.base import BaseEvaluator
from app.evaluators.deterministic import PassageStyleEvaluator, PassageWordCountEvaluator
from app.evaluators.semantic import GroundingFidelityEvaluator
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.loop.capabilities import GeneratorCapability
from app.loop.context import AuthorityGrant, LoopContext
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.persistence.client import CheckpointClient
from app.repair.passage import PassageSentenceRepairer

logger = logging.getLogger(__name__)


class PassageGeneratorAdapter(GeneratorCapability):
    """Adapts PassageGenerator to the runtime GeneratorCapability protocol."""

    def __init__(self, generator: PassageGenerator, passage_context: PassageGenerationContext):
        self._generator = generator
        self._passage_context = passage_context

    @property
    def name(self) -> str:
        return "PassageGenerator"

    @property
    def version(self) -> str:
        return "2.0.0"

    async def generate(
        self,
        context: LoopContext,
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        lease_owner = getattr(context.authority, "lease_owner", None)
        epoch = getattr(context.authority, "epoch", 1)
        feedback = None
        if version > 1 and hasattr(context, "current_artifact") and context.current_artifact is not None:
            feedback_parts: List[str] = []
            prev_w = context.current_artifact.payload.get("wordCount", 0)
            if 0 < prev_w < self._passage_context.target_min_words:
                feedback_parts.append(
                    f"CRITICAL FEEDBACK FOR VERSION {version}: Your previous draft had only {prev_w} words, "
                    f"which was below the strict {self._passage_context.target_min_words}-word minimum.\n"
                    f"In this revision, expand each of the 5-6 paragraphs with more thorough, substantive academic detail "
                    f"and empirical discussion from the verified source text to ensure the total word count is strictly between 780 and 840 words."
                )
            elif prev_w > self._passage_context.target_max_words:
                feedback_parts.append(
                    f"CRITICAL FEEDBACK FOR VERSION {version}: Your previous draft had {prev_w} words, "
                    f"which exceeded the strict {self._passage_context.target_max_words}-word maximum.\n"
                    f"In this revision, tighten your phrasing while keeping all verified facts to ensure the total word count is strictly between 780 and 840 words."
                )
            open_issues = getattr(context, "open_issues", None) or ()
            if open_issues:
                issue_lines = [
                    f"- [{iss.code.value if hasattr(iss.code, 'value') else iss.code}] {iss.message}"
                    for iss in open_issues
                ]
                feedback_parts.append(
                    f"CRITICAL QUALITY & GROUNDING ISSUES TO RESOLVE IN VERSION {version}:\n"
                    + "\n".join(issue_lines)
                    + "\nStrictly avoid any ungrounded numbers/years not present in the source facts, "
                    "and never use extreme certainty boosters ('always', 'definitely', 'certainly', 'undoubtedly', 'proves', 'conclusively', 'indisputable', 'forever', 'permanently')."
                )
            if feedback_parts:
                feedback = "\n\n".join(feedback_parts)
        envelope = await self._generator.generate(
            context=self._passage_context,
            run_id=context.run_id,
            version=version,
            target_artifact_id=context.target_artifact_id,
            lease_owner=lease_owner,
            epoch=epoch,
            parent_operation_id=intent_id,
            input_dependencies=context.input_dependencies,
            length_feedback=feedback,
            timeout_seconds=60.0,
        )
        if envelope.version != version:
            envelope = envelope.model_copy(update={"version": version})
        return envelope


class PassageLoop:
    """Bounded loop controller for passage synthesis, quality evaluation, and repair."""

    def __init__(
        self,
        generator: PassageGenerator,
        persistence_client: CheckpointClient,
        evaluators: Optional[Sequence[BaseEvaluator]] = None,
        repairer: Optional[PassageSentenceRepairer] = None,
        policy: Optional[LoopPolicy] = None,
        is_benchmark: bool = False,
    ):
        self.generator = generator
        self.persistence_client = persistence_client
        self.is_benchmark = is_benchmark

        if policy is not None:
            self.policy = policy
        else:
            self.policy = LoopPolicy.from_settings(
                is_benchmark=is_benchmark,
                generate_reservation_cap="passageGenerateTokenReservation",
            )

        # Default required evaluators for IELTS Academic Passage
        if evaluators is None:
            self.evaluators: List[BaseEvaluator] = [
                PassageWordCountEvaluator(required=True, timeout_seconds=self.policy.evaluator_deterministic_timeout_seconds),
                PassageStyleEvaluator(required=True, timeout_seconds=self.policy.evaluator_deterministic_timeout_seconds),
                GroundingFidelityEvaluator(
                    required=True,
                    timeout_seconds=self.policy.evaluator_semantic_timeout_seconds,
                    estimated_tokens=self.policy.evaluator_max_tokens_per_evaluation,
                ),
            ]
        else:
            self.evaluators = list(evaluators)

        self.repairer = repairer or PassageSentenceRepairer(
            timeout_seconds=self.policy.repair_timeout_seconds,
            estimated_tokens=self.policy.repair_max_tokens_per_attempt,
        )

        required_ids = tuple(ev.evaluator_id for ev in self.evaluators if ev.metadata.required)
        if self.policy.required_evaluator_ids != required_ids:
            self.policy = self.policy.model_copy(update={"required_evaluator_ids": required_ids})
    async def run(
        self,
        passage_context: PassageGenerationContext,
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        accepted_dependencies: Optional[Dict[str, ArtifactRef]] = None,
        parent_operation_id: Optional[str] = None,
    ) -> LoopResult:
        """Executes the Passage Loop with authoritative persistence and crash resumption."""
        # 1. P08-08 Crash Resumption Check:
        target_art_id = f"art_passage_s{passage_context.section_index}"
        expected_input_deps = [passage_context.blueprint_ref, passage_context.evidence_graph_ref]
        if passage_context.source_pack_ref:
            expected_input_deps.append(passage_context.source_pack_ref)

        try:
            resume_state = self.persistence_client.resume_state(run_id)
            # Query authoritative accepted upstream heads from store
            store_accepted_heads: Dict[str, ArtifactRef] = {}
            for art_info in resume_state.artifacts:
                if not art_info.isStale:
                    try:
                        store_accepted_heads[art_info.artifactId] = ArtifactRef(
                            artifactId=art_info.artifactId,
                            artifactType=ArtifactType(art_info.artifactType),
                            version=art_info.acceptedVersion,
                            contentHash=art_info.acceptedHash,
                        )
                    except Exception:
                        pass

            for art_info in resume_state.artifacts:
                if (
                    art_info.artifactType == ArtifactType.PASSAGE.value
                    and not art_info.isStale
                    and art_info.envelopeJson
                ):
                    accepted_envelope = ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                    # Invariant: Resumed artifact MUST have exact parent_refs matching current input dependencies
                    # AND those parent_refs must be currently accepted and fresh in the durable store!
                    parents_match_input = tuple(accepted_envelope.parent_refs) == tuple(expected_input_deps)
                    parents_accepted_in_store = bool(accepted_envelope.parent_refs) and all(
                        p.artifact_id in store_accepted_heads
                        and store_accepted_heads[p.artifact_id] == p
                        for p in accepted_envelope.parent_refs
                    )

                    if parents_match_input and parents_accepted_in_store:
                        logger.info(
                            "Resuming run %s: reusing previously accepted passage artifact %s (version %d) with verified fresh dependencies",
                            run_id,
                            accepted_envelope.artifact_id,
                            accepted_envelope.version,
                        )
                        from app.contracts.loop import DecisionType, LoopState, LoopReason
                        from app.loop.journal import StepJournal
                        from app.loop.ledger import IssueLedgerManager
                        ledger_mgr = IssueLedgerManager(run_id)
                        return LoopResult(
                            runId=run_id,
                            decision=DecisionType.PASS,
                            terminalState=LoopState.COMPLETED,
                            acceptedArtifact=accepted_envelope,
                            terminalReason=f"Resumed previously accepted passage artifact at version {accepted_envelope.version}",
                            terminalReasonCode=LoopReason.ACCEPTED,
                            totalIterations=0,
                            versionsCount=accepted_envelope.version,
                            repairsCount=0,
                            callsCount=0,
                            tokensConsumed=0,
                            wallTimeSeconds=0.0,
                            ledger=ledger_mgr.to_ledger(),
                            latestDecision=None,
                        )
                    else:
                        logger.info(
                            "Run %s: previously accepted passage artifact %s has stale/unmatched parent dependencies; refusing to reuse",
                            run_id,
                            accepted_envelope.artifact_id,
                        )
        except Exception as exc:
            logger.debug("Crash resumption check encountered notice: %s", exc)

        # 2. Build LoopContext bound to authority and dependencies
        input_deps = list(expected_input_deps)
        context = LoopContext(
            runId=run_id,
            targetArtifactId=target_art_id,
            targetArtifactType=ArtifactType.PASSAGE,
            scope="PASSAGE",
            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
            inputDependencies=tuple(input_deps),
            policyVersion=passage_context.policy_version,
            parent_operation_id=parent_operation_id,
        )

        if accepted_dependencies is None:
            effective_accepted_dependencies: Dict[str, ArtifactRef] = {}
            try:
                res_state = self.persistence_client.resume_state(run_id)
                for art_info in res_state.artifacts:
                    if not art_info.isStale:
                        try:
                            effective_accepted_dependencies[art_info.artifactId] = ArtifactRef(
                                artifactId=art_info.artifactId,
                                artifactType=ArtifactType(art_info.artifactType),
                                version=art_info.acceptedVersion,
                                contentHash=art_info.acceptedHash,
                            )
                        except Exception:
                            pass
            except Exception as exc:
                logger.debug("Querying accepted dependencies from store noticed: %s", exc)
        else:
            effective_accepted_dependencies = dict(accepted_dependencies)
        # Pre-flight check: Required input dependencies must be authoritatively accepted in store
        missing_upstream = [dep.artifact_id for dep in input_deps if dep.artifact_id not in effective_accepted_dependencies]
        if missing_upstream:
            from app.contracts.loop import DecisionType, LoopState, LoopReason
            from app.loop.ledger import IssueLedgerManager
            ledger_mgr = IssueLedgerManager(run_id)
            return LoopResult(
                runId=run_id,
                decision=DecisionType.FAIL,
                terminalState=LoopState.FAILED,
                acceptedArtifact=None,
                terminalReason=f"Cannot start passage synthesis: missing accepted upstream dependencies {missing_upstream}",
                terminalReasonCode=LoopReason.STALE_DEPENDENCY,
                totalIterations=0,
                versionsCount=0,
                repairsCount=0,
                callsCount=0,
                tokensConsumed=0,
                wallTimeSeconds=0.0,
                ledger=ledger_mgr.to_ledger(),
                latestDecision=None,
            )

        adapter = PassageGeneratorAdapter(
            generator=self.generator,
            passage_context=passage_context,
        )

        runtime = BoundedLoopRuntime(
            context=context,
            policy=self.policy,
            generator=adapter,
            evaluators=self.evaluators,
            repairer=self.repairer,
            persistence_client=self.persistence_client,
            accepted_dependencies=effective_accepted_dependencies,
        )
        return await runtime.run()
