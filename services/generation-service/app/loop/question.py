"""Question Candidate Loop Engine (Phase 09 / P09-10).

Orchestrates the candidate generation, evaluation, joint selection, and durable persistence
of IELTS Reading question groups on top of BoundedLoopRuntime and CheckpointClient.

Invariants:
- Passage artifact is strictly IMMUTABLE during question generation.
- Dynamic closure: item/option repair scope is isolated; summary repair invalidates group.
- Exact dependency references to parent Passage and Blueprint.
- Shared persisted budgets and reservations survive crashes and restarts.
- Resumption preserves already committed question heads (e.g. Q14-16 preserved on Q17 crash).
"""

from __future__ import annotations

import hashlib
import logging
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.issue import IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.generators.question.context import (
    CandidateSelectionCriteria,
    QuestionCandidate,
    QuestionCandidatePool,
    QuestionGroupContext,
)
from app.generators.question.generator import QuestionCandidateGenerator
from app.loop.capabilities import GeneratorCapability
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.persistence.client import CheckpointClient
from app.loop.journal import OperationIntent, StepJournal
from app.persistence.models import (
    CheckpointCommitRequest,
    DraftCheckpointRequest,
    LoopCursorCheckpointRequest,
    OperationGrantRequest,
    OperationReconcileRequest,
)
from app.selection.selector import CandidateSelector, SelectionInfeasibleError

logger = logging.getLogger(__name__)

class QuestionCandidateLoop:
    """Bounded loop orchestrator for question candidate generation, evaluation, and selection."""

    def __init__(
        self,
        generator: QuestionCandidateGenerator,
        persistence_client: CheckpointClient,
        evaluator_registry: Optional[EvaluatorRegistry] = None,
        selector: Optional[CandidateSelector] = None,
        policy: Optional[LoopPolicy] = None,
    ):
        self.generator = generator
        self.persistence_client = persistence_client
        if evaluator_registry is None:
            reg = EvaluatorRegistry()
            reg.register(QuestionStructureEvaluator())
            reg.register(AnswerVerbatimAndLengthEvaluator())
            evaluator_registry = reg
        self.evaluator_registry = evaluator_registry
        self.selector = selector or CandidateSelector()

        if policy is None:
            policy = LoopPolicy.from_settings(max_total_tokens=100000, max_wall_time_seconds=600.0, required_evaluator_ids=("eval_question_structure", "eval_answer_verbatim_length"))
        elif not policy.required_evaluator_ids:
            policy = policy.model_copy(update={"required_evaluator_ids": ("eval_question_structure", "eval_answer_verbatim_length")})
        self.policy = policy

    async def run(
        self,
        passage_artifact: ArtifactEnvelope,
        blueprint_ref: ArtifactRef,
        question_slots: List[Dict[str, Any]],
        run_id: str,
        lease_owner: UUID,
        epoch: int,
        section_index: int = 1,
    ) -> Dict[str, Any]:
        """Runs question candidate loop across the specified question slots."""
        # Invariant: Passage artifact must be canonical PASSAGE and immutable
        if passage_artifact.artifact_type != ArtifactType.PASSAGE:
            raise ValueError(f"Expected ArtifactType.PASSAGE, got {passage_artifact.artifact_type}")

        passage_text = passage_artifact.payload.get("text", "") or passage_artifact.payload.get("passage", "")
        if not passage_text:
            raise ValueError("Passage artifact payload missing text")

        # 1. Runtime Authority & Fencing Check against persistence client
        if hasattr(self.persistence_client, "epoch") and hasattr(self.persistence_client, "owner"):
            if epoch < self.persistence_client.epoch or lease_owner != self.persistence_client.owner:
                raise ValueError(f"Stale writer lease or fencing conflict (client epoch {self.persistence_client.epoch}, requested {epoch})")

        # 2. Runtime Budget Tracking - restore persisted counters if available
        budget_tracker = BudgetTracker()
        stored_state = self.persistence_client.resume_state(run_id)
        if hasattr(stored_state, "callsUsed") and stored_state.callsUsed:
            budget_tracker.calls_used = int(stored_state.callsUsed)
        if hasattr(stored_state, "tokensUsed") and stored_state.tokensUsed:
            budget_tracker.tokens_used = int(stored_state.tokensUsed)

        # 3. Transactional Step Journal projection
        step_journal = StepJournal(
            run_id=run_id,
            persistence_client=self.persistence_client,
            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
        )

        committed_questions: Dict[int, ArtifactEnvelope] = {}
        for art in stored_state.artifacts:
            art_type = getattr(art, "artifact_type", None) or getattr(art, "artifactType", None)
            if art_type in (ArtifactType.QUESTION, "Question"):
                payload = getattr(art, "payload", None)
                if not payload and hasattr(art, "payloadJson"):
                    import json
                    try:
                        payload = json.loads(art.payloadJson)
                    except Exception:
                        payload = {}
                elif not payload and hasattr(art, "contentJson"):
                    import json
                    try:
                        payload = json.loads(art.contentJson)
                    except Exception:
                        payload = {}
                q_num = (payload or {}).get("questionNumber")
                if q_num is not None:
                    committed_questions[int(q_num)] = art
            elif art_type in (ArtifactType.QUESTION_GROUP, "QuestionGroup"):
                payload = getattr(art, "payload", None)
                if not payload and hasattr(art, "payloadJson"):
                    import json
                    try:
                        payload = json.loads(art.payloadJson)
                    except Exception:
                        payload = {}
                elif not payload and hasattr(art, "contentJson"):
                    import json
                    try:
                        payload = json.loads(art.contentJson)
                    except Exception:
                        payload = {}
                for q in (payload or {}).get("questions", []):
                    q_num = q.get("questionNumber")
                    if q_num is not None:
                        committed_questions[int(q_num)] = art
        pools: List[QuestionCandidatePool] = []
        newly_selected_candidates: List[QuestionCandidate] = []
        candidate_artifacts: Dict[str, ArtifactEnvelope] = {}
        candidate_evaluations: Dict[str, List[Any]] = {}
        # Determine which slots need generation vs already committed
        slots_to_generate = []
        for slot in question_slots:
            q_num = slot.get("number") or slot.get("questionNumber")
            if q_num in committed_questions:
                c_art = committed_questions[q_num]
                c_id = getattr(c_art, "artifact_id", None) or getattr(c_art, "artifactId", "unknown")
                logger.info("Resuming slot Q%d from committed artifact %s", q_num, c_id)
            else:
                slots_to_generate.append(slot)

        if not slots_to_generate:
            return {
                "status": "COMPLETED",
                "totalQuestions": len(committed_questions),
                "questions": committed_questions,
                "resumedCount": len(question_slots),
                "generatedCount": 0,
            }
        existing_reserved = [
            o for o in (stored_state.operations or [])
            if o.operationType == "WORKFLOW" and o.status == "RESERVED"
        ]
        if existing_reserved:
            workflow_op_id = existing_reserved[0].operationId
        else:
            workflow_op_id = f"op_workflow_qcand_s{section_index}_{uuid4().hex[:8]}"
            try:
                self.persistence_client.grant_operation(OperationGrantRequest(
                    runId=run_id,
                    epoch=epoch,
                    leaseOwner=lease_owner,
                    operationId=workflow_op_id,
                    operationType="WORKFLOW",
                    requestHash=f"workflow:questions:s{section_index}:{run_id}:{workflow_op_id}",
                    tokenReservation=35000,
                    wallTimeReservationSeconds=300.0,
                    sectionId=None,
                    artifactId=None,
                ))
            except Exception as ex:
                logger.warning("Could not grant workflow parent operation: %s", ex)
                workflow_op_id = None
        try:
            return await self._generate_and_commit_slots(
                passage_artifact=passage_artifact,
                passage_text=passage_text,
                blueprint_ref=blueprint_ref,
                question_slots=question_slots,
                slots_to_generate=slots_to_generate,
                committed_questions=committed_questions,
                workflow_op_id=workflow_op_id,
                budget_tracker=budget_tracker,
                step_journal=step_journal,
                run_id=run_id,
                lease_owner=lease_owner,
                epoch=epoch,
                section_index=section_index,
            )
        finally:
            if workflow_op_id:
                try:
                    self.persistence_client.reconcile_operation(OperationReconcileRequest(
                        runId=run_id,
                        epoch=epoch,
                        leaseOwner=lease_owner,
                        operationId=workflow_op_id,
                        tokensUsed=budget_tracker.tokens_used,
                        wallTimeUsedSeconds=budget_tracker.get_elapsed_seconds(),
                    ))
                except Exception as ex:
                    logger.warning("Could not reconcile workflow parent operation: %s", ex)

    async def _generate_and_commit_slots(
        self,
        passage_artifact: ArtifactEnvelope,
        passage_text: str,
        blueprint_ref: ArtifactRef,
        question_slots: List[Dict[str, Any]],
        slots_to_generate: List[Dict[str, Any]],
        committed_questions: Dict[int, ArtifactEnvelope],
        workflow_op_id: Optional[str],
        budget_tracker: BudgetTracker,
        step_journal: StepJournal,
        run_id: str,
        lease_owner: UUID,
        epoch: int,
        section_index: int,
    ) -> Dict[str, Any]:
        pools: List[QuestionCandidatePool] = []
        newly_selected_candidates: List[QuestionCandidate] = []

        # 1. Candidate Generation for uncommitted slots via generic BoundedLoopRuntime
        class SlotCandidateGeneratorAdapter(GeneratorCapability):
            def __init__(self, slot_generator, q_num, q_type, passage_text, p_ref, bp_ref):
                self._generator = slot_generator
                self._q_num = q_num
                self._q_type = q_type
                self._passage_text = passage_text
                self._p_ref = p_ref
                self._bp_ref = bp_ref
                self.pool: Optional[QuestionCandidatePool] = None

            @property
            def name(self) -> str:
                return f"SlotCandidateGenerator_Q{self._q_num}"

            @property
            def version(self) -> str:
                return "2.0.0"

            async def generate(self, context: LoopContext, intent_id: str, version: int) -> ArtifactEnvelope:
                self.pool = await self._generator.generate_candidate_pool(
                    passage_text=self._passage_text,
                    question_type=self._q_type,
                    question_number=self._q_num,
                    passage_ref=self._p_ref,
                    blueprint_ref=self._bp_ref,
                    run_id=context.run_id,
                    section_id=str(context.section_id or 1),
                    context=context,
                    parent_operation_id=workflow_op_id or intent_id,
                )
                best_cand = self.pool.candidates[0] if self.pool and self.pool.candidates else None
                payload = {
                    "questionNumber": self._q_num,
                    "questionType": self._q_type,
                    "prompt": best_cand.prompt if best_cand else "",
                    "answer": best_cand.answer if best_cand else "",
                    "options": [o.model_dump() for o in best_cand.options] if best_cand and best_cand.options else [],
                    "evidenceQuote": best_cand.evidence_quote if best_cand else "",
                    "score": best_cand.score if best_cand else 0.0,
                    "passage": self._passage_text,
                    "candidates": [c.model_dump() for c in (self.pool.candidates if self.pool else [])],
                }
                return ArtifactEnvelope.create(
                    artifact_id=context.target_artifact_id,
                    artifact_type=ArtifactType.QUESTION,
                    version=version,
                    payload=payload,
                    parent_refs=[self._p_ref, self._bp_ref],
                    run_id=context.run_id,
                    producer_version="2.0.0",
                )
        for slot in slots_to_generate:
            q_num = slot.get("number") or slot.get("questionNumber", 1)
            q_type = slot.get("type") or slot.get("questionType", "TrueFalseNotGiven")

            adapter = SlotCandidateGeneratorAdapter(
                slot_generator=self.generator,
                q_num=q_num,
                q_type=q_type,
                passage_text=passage_text,
                p_ref=passage_artifact.to_ref(),
                bp_ref=blueprint_ref,
            )

            slot_ctx = LoopContext(
                runId=run_id,
                targetArtifactId=f"art_q_slot_{q_num}",
                targetArtifactType=ArtifactType.QUESTION,
                scope=IssueScope.QUESTION,
                sectionId=section_index,
                authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                budgetTracker=budget_tracker,
                parent_operation_id=workflow_op_id,
            )

            slot_runtime = BoundedLoopRuntime(
                context=slot_ctx,
                policy=self.policy,
                generator=adapter,
                evaluators=self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION),
                persistence_client=self.persistence_client,
                accepted_dependencies={
                    passage_artifact.artifact_id: passage_artifact.to_ref(),
                    blueprint_ref.artifact_id: blueprint_ref,
                },
                journal=step_journal,
                accept_head=False,
            )

            slot_res = await slot_runtime.run()
            if slot_res.decision != DecisionType.PASS:
                issues_desc = [f"{i.code.value}: {i.message}" for i in slot_res.ledger.issues]
                raise SelectionInfeasibleError(
                    f"Candidate generation/evaluation failed for slot Q{q_num}: {slot_res.terminal_reason} | issues: {issues_desc}",
                    step_count=1,
                    reason="SLOT_RUNTIME_FAILED",
                )
            # Hydrate candidate pool from durable returned/restored artifact (crash resumable)
            slot_art = slot_res.accepted_artifact or slot_runtime.context.current_artifact
            if slot_art and slot_art.payload and "candidates" in slot_art.payload:
                cands_data = slot_art.payload.get("candidates", [])
                candidates = [QuestionCandidate.model_validate(c) for c in cands_data]
                pool = QuestionCandidatePool(
                    slotId=f"slot_q{q_num}_{q_type}",
                    questionNumber=q_num,
                    questionType=q_type,
                    poolLimit=len(candidates) or 3,
                    candidates=candidates,
                )
            else:
                pool = adapter.pool

            if not pool or not pool.candidates:
                raise SelectionInfeasibleError(
                    f"No candidates generated for slot Q{q_num}",
                    step_count=1,
                    reason="GENERATION_EMPTY",
                )

            # Runtime-owned candidate evaluation state transitions via BoundedLoopRuntime
            class SingleCandidateGenerator(GeneratorCapability):
                def __init__(self, candidate: QuestionCandidate, pass_text: str, p_ref: ArtifactRef, bp_ref: ArtifactRef):
                    self._candidate = candidate
                    self._passage_text = pass_text
                    self._p_ref = p_ref
                    self._bp_ref = bp_ref

                @property
                def name(self) -> str:
                    return f"CandidateGenerator_{self._candidate.candidate_id}"

                @property
                def version(self) -> str:
                    return "2.0.0"

                async def generate(self, context: LoopContext, intent_id: str, version: int) -> ArtifactEnvelope:
                    return ArtifactEnvelope.create(
                        artifact_id=context.target_artifact_id,
                        artifact_type=ArtifactType.QUESTION,
                        version=version,
                        payload={
                            "passage": self._passage_text,
                            "questionNumber": self._candidate.question_number,
                            "questionType": self._candidate.question_type,
                            "prompt": self._candidate.prompt,
                            "answer": self._candidate.answer,
                            "options": [o.model_dump() for o in self._candidate.options] if self._candidate.options else [],
                            "evidenceQuote": self._candidate.evidence_quote,
                            "score": self._candidate.score,
                            "candidateId": self._candidate.candidate_id,
                        },
                        parent_refs=[self._p_ref, self._bp_ref],
                        run_id=context.run_id,
                        producer_version="2.0.0",
                    )

            for cand in pool.candidates:
                cand_ctx = LoopContext(
                    runId=run_id,
                    targetArtifactId=f"art_q_{cand.question_number}_{cand.candidate_id}",
                    targetArtifactType=ArtifactType.QUESTION,
                    scope=IssueScope.QUESTION,
                    sectionId=section_index,
                    authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                    inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                    budgetTracker=budget_tracker,
                    parent_operation_id=workflow_op_id,
                )
                cand_runtime = BoundedLoopRuntime(
                    context=cand_ctx,
                    policy=self.policy,
                    generator=SingleCandidateGenerator(cand, passage_text, passage_artifact.to_ref(), blueprint_ref),
                    evaluators=self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION),
                    persistence_client=self.persistence_client,
                    accepted_dependencies={
                        passage_artifact.artifact_id: passage_artifact.to_ref(),
                        blueprint_ref.artifact_id: blueprint_ref,
                    },
                    journal=step_journal,
                    accept_head=False,
                )
                cand_res = await cand_runtime.run()
                if cand_res.decision != DecisionType.PASS:
                    cand.rejected = True
                    for iss in cand_res.ledger.issues:
                        cand.rejection_reasons.append(f"{iss.code.value}: {iss.message}")
                    if not cand.rejection_reasons:
                        cand.rejection_reasons.append(f"RUNTIME_{cand_res.terminal_reason}")
            eligible = pool.get_eligible_candidates()
            if not eligible:
                reasons = [c.rejection_reasons for c in pool.candidates]
                raise SelectionInfeasibleError(
                    f"No eligible candidates survived evaluation for slot Q{q_num}: {reasons}",
                    step_count=1,
                    reason="ALL_CANDIDATES_REJECTED",
                )

            # Pass strictly the filtered eligible pool to the joint selector
            filtered_pool = QuestionCandidatePool(
                slot_id=pool.slot_id,
                question_number=pool.question_number,
                question_type=pool.question_type,
                pool_limit=pool.pool_limit,
                candidates=eligible,
            )
            pools.append(filtered_pool)
        # 2. Joint Constraint Selection across pools
        if pools:
            selected_candidates = self.selector.select_joint_group(pools)
            newly_selected_candidates.extend(selected_candidates)

            # 3. Assemble and commit the selected group atomically through BoundedLoopRuntime
            grp_start = min(c.question_number for c in newly_selected_candidates)
            grp_end = max(c.question_number for c in newly_selected_candidates)
            target_grp_id = f"art_grp_s{section_index}_q{grp_start}_q{grp_end}"
            group_payload = {
                "sectionIndex": section_index,
                "startNumber": grp_start,
                "endNumber": grp_end,
                "questionCount": len(newly_selected_candidates),
                "questions": [
                    {
                        "questionNumber": c.question_number,
                        "questionType": c.question_type,
                        "prompt": c.prompt,
                        "answer": c.answer,
                        "options": [o.model_dump() for o in c.options] if c.options else [],
                        "evidenceQuote": c.evidence_quote,
                        "score": c.score,
                        "candidateId": c.candidate_id,
                    }
                    for c in newly_selected_candidates
                ],
                "text": passage_text,
                "passage": passage_text,
            }

            class WinningGroupGenerator(GeneratorCapability):
                @property
                def name(self) -> str:
                    return "QuestionGroupGenerator"

                @property
                def version(self) -> str:
                    return "2.0.0"

                async def generate(self, context: LoopContext, intent_id: str, version: int) -> ArtifactEnvelope:
                    return ArtifactEnvelope.create(
                        artifact_id=context.target_artifact_id,
                        artifact_type=ArtifactType.QUESTION_GROUP,
                        version=version,
                        payload=group_payload,
                        parent_refs=[passage_artifact.to_ref(), blueprint_ref],
                        run_id=context.run_id,
                        producer_version="2.0.0",
                    )

            group_ctx = LoopContext(
                runId=run_id,
                targetArtifactId=target_grp_id,
                targetArtifactType=ArtifactType.QUESTION_GROUP,
                scope=IssueScope.SECTION,
                sectionId=section_index,
                authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                budgetTracker=budget_tracker,
                parent_operation_id=workflow_op_id,
            )

            group_evaluators = self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION_GROUP)
            group_req_ids = tuple(ev.evaluator_id for ev in group_evaluators if ev.metadata.required)
            group_policy = self.policy.model_copy(update={"required_evaluator_ids": group_req_ids})
            group_runtime = BoundedLoopRuntime(
                context=group_ctx,
                policy=group_policy,
                generator=WinningGroupGenerator(),
                evaluators=group_evaluators,
                persistence_client=self.persistence_client,
                accepted_dependencies={
                    passage_artifact.artifact_id: passage_artifact.to_ref(),
                    blueprint_ref.artifact_id: blueprint_ref,
                },
                journal=step_journal,
            )
            loop_res = await group_runtime.run()
            if loop_res.decision != DecisionType.PASS:
                raise ValueError(f"Question group acceptance failed: {loop_res.terminal_reason}")

            accepted_grp = loop_res.accepted_artifact
            for c in newly_selected_candidates:
                committed_questions[c.question_number] = accepted_grp

        return {
            "status": "COMPLETED",
            "totalQuestions": len(committed_questions),
            "questions": committed_questions,
            "resumedCount": len(question_slots) - len(slots_to_generate),
            "generatedCount": len(newly_selected_candidates),
            "journal": step_journal.entries,
        }
