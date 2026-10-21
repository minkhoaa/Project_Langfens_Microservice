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
from collections.abc import Mapping

import hashlib
import logging
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationStatus
from app.contracts.issue import IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.evaluators.deterministic import (
    AnswerVerbatimAndLengthEvaluator,
    QuestionStructureEvaluator,
)
from app.evaluators.solver import BlindSolverEvaluator
from app.evaluators.registry import EvaluatorRegistry
from app.generators.question.context import (
    CandidateSelectionCriteria,
    QuestionCandidate,
    QuestionCandidatePool,
    QuestionGroupContext,
)
from app.generators.question.generator import QuestionCandidateGenerator, get_pool_limit_for_type
from app.generators.question.prompts import QuestionPromptFamily, QUESTION_PROMPT_VERSION
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
SECTION_MAX_TOKENS = 100_000
SECTION_MAX_WALL_TIME_SECONDS = 900.0


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
            policy = LoopPolicy.from_settings(
                required_evaluator_ids=("eval_question_structure", "eval_answer_verbatim_length"),
            )
        elif not policy.required_evaluator_ids:
            policy = policy.model_copy(update={"required_evaluator_ids": ("eval_question_structure", "eval_answer_verbatim_length")})
        self.policy = policy

    @staticmethod
    def _select_reserved_workflow_operation(stored_state: Any, section_index: int, run_id: str) -> Optional[Any]:
        expected_workflow_op_id = f"op_workflow_qcand_s{section_index}_{run_id[:8]}"
        matching = [
            o for o in (getattr(stored_state, "operations", []) or [])
            if getattr(o, "operationType", None) == "WORKFLOW"
            and getattr(o, "status", None) == "RESERVED"
            and getattr(o, "operationId", None) == expected_workflow_op_id
        ]
        return matching[0] if matching else None

    async def run(
        self,
        passage_artifact: ArtifactEnvelope,
        blueprint_ref: ArtifactRef,
        question_slots: List[Dict[str, Any]],
        run_id: str,
        lease_owner: UUID,
        epoch: int,
        section_index: int = 1,
        parent_operation_id: Optional[str] = None,
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
        raw_snapshot = getattr(stored_state, "budgetProfileJson", None) or getattr(stored_state, "budgetProfileSnapshot", None)
        if raw_snapshot:
            import json
            run_snapshot = json.loads(raw_snapshot) if isinstance(raw_snapshot, str) else raw_snapshot
            if run_snapshot:
                cap_fields = set(LoopPolicy.RESOURCE_CAP_FIELDS) | {
                    "generate_token_reservation", "cap_profile_version", "cap_profile_source",
                    "cap_profile_sha256", "cap_profile_snapshot",
                }
                self.policy = LoopPolicy.from_cap_snapshot(
                    run_snapshot,
                    **self.policy.model_dump(exclude=cap_fields),
                )
        if hasattr(stored_state, "callsUsed") and stored_state.callsUsed:
            budget_tracker.calls_used = int(stored_state.callsUsed)
        if hasattr(stored_state, "tokensUsed") and stored_state.tokensUsed:
            budget_tracker.tokens_used = int(stored_state.tokensUsed)
        if hasattr(stored_state, "wallTimeUsedSeconds") and stored_state.wallTimeUsedSeconds:
            budget_tracker.wall_time_used_seconds = float(stored_state.wallTimeUsedSeconds)

        SECTION_MAX_TOKENS = 100_000
        SECTION_MAX_WALL_TIME_SECONDS = 900.0

        if not self.policy.is_unlimited:
            if budget_tracker.tokens_used >= SECTION_MAX_TOKENS:
                raise SelectionInfeasibleError(
                    f"Cumulative section token budget exhausted before question loop: {budget_tracker.tokens_used} >= {SECTION_MAX_TOKENS}",
                    step_count=1,
                    reason="TOKEN_CAP",
                )
            if budget_tracker.get_elapsed_seconds() >= SECTION_MAX_WALL_TIME_SECONDS:
                raise SelectionInfeasibleError(
                    f"Cumulative section wall time budget exhausted before question loop: {budget_tracker.get_elapsed_seconds():.1f}s >= {SECTION_MAX_WALL_TIME_SECONDS}s",
                    step_count=1,
                    reason="WALL_TIME_CAP",
                )
        # 3. Transactional Step Journal projection
        step_journal = StepJournal(
            run_id=run_id,
            persistence_client=self.persistence_client,
            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
        )

        committed_questions: Dict[int, ArtifactEnvelope] = {}
        slot_nums = [
            int(s.get("questionNumber") or s.get("slotNumber") or s.get("number"))
            for s in question_slots
            if (s.get("questionNumber") or s.get("slotNumber") or s.get("number")) is not None
        ]
        if slot_nums:
            sec_start = min(slot_nums)
            sec_end = max(slot_nums)
        else:
            sec_start = 1 if section_index == 1 else (14 if section_index == 2 else 27)
            sec_end = 13 if section_index == 1 else (26 if section_index == 2 else 40)
        store_accepted_heads: Dict[str, ArtifactRef] = {}
        for art_info in stored_state.artifacts:
            if not getattr(art_info, "isStale", False):
                try:
                    store_accepted_heads[art_info.artifactId] = ArtifactRef(
                        artifactId=art_info.artifactId,
                        artifactType=ArtifactType(art_info.artifactType),
                        version=art_info.acceptedVersion,
                        contentHash=art_info.acceptedHash,
                    )
                except Exception:
                    pass

        for art in stored_state.artifacts:
            if getattr(art, "isStale", False):
                continue
            art_type = getattr(art, "artifact_type", None) or getattr(art, "artifactType", None)
            if art_type in (ArtifactType.QUESTION, "Question", ArtifactType.QUESTION_GROUP, "QuestionGroup"):
                env_json = getattr(art, "envelopeJson", None)
                if not env_json:
                    raise ValueError(f"Corrupt question artifact checkpoint {getattr(art, 'artifactId', '')}: missing envelopeJson")
                try:
                    env_obj = ArtifactEnvelope.model_validate_json(env_json)
                except Exception as e:
                    raise ValueError(f"Corrupt question artifact envelope for {getattr(art, 'artifactId', '')}: {e}") from e

                if env_obj.run_id != run_id:
                    raise ValueError(f"Corrupt checkpoint for {env_obj.artifact_id}: runId mismatch")
                if env_obj.artifact_id != getattr(art, "artifactId", None):
                    raise ValueError(f"Corrupt checkpoint for {env_obj.artifact_id}: artifactId mismatch")
                acc_v = getattr(art, "acceptedVersion", None)
                if acc_v is not None and env_obj.version != acc_v:
                    raise ValueError(f"Corrupt checkpoint for {env_obj.artifact_id}: version mismatch")
                acc_h = getattr(art, "acceptedHash", None)
                if acc_h and env_obj.content_hash != acc_h:
                    raise ValueError(f"Corrupt checkpoint for {env_obj.artifact_id}: contentHash mismatch")
                if not env_obj.verify_integrity():
                    raise ValueError(f"Corrupt checkpoint for {env_obj.artifact_id}: integrity verification failed")

                parents_accepted = bool(env_obj.parent_refs) and all(
                    p.artifact_id in store_accepted_heads
                    and store_accepted_heads[p.artifact_id] == p
                    for p in env_obj.parent_refs
                )
                if not parents_accepted:
                    continue

                if art_type in (ArtifactType.QUESTION, "Question"):
                    payload = env_obj.payload
                    if isinstance(payload, (Mapping, dict)):
                        q_num = payload.get("questionNumber")
                        if q_num is not None and sec_start <= int(q_num) <= sec_end:
                            committed_questions[int(q_num)] = env_obj
                elif art_type in (ArtifactType.QUESTION_GROUP, "QuestionGroup"):
                    payload = env_obj.payload
                    if isinstance(payload, (Mapping, dict)):
                        for q in (payload.get("questions") or []):
                            if isinstance(q, (Mapping, dict)):
                                q_num = q.get("questionNumber")
                                if q_num is not None and sec_start <= int(q_num) <= sec_end:
                                    committed_questions[int(q_num)] = env_obj
        pools: List[QuestionCandidatePool] = []
        newly_selected_candidates: List[QuestionCandidate] = []
        candidate_artifacts: Dict[str, ArtifactEnvelope] = {}
        candidate_evaluations: Dict[str, List[Any]] = {}
        # Determine which slots need generation vs already committed
        slots_to_generate = []
        for slot in question_slots:
            q_num = slot.get("questionNumber") or slot.get("slotNumber") or slot.get("number")
            if q_num in committed_questions:
                c_art = committed_questions[q_num]
                c_id = getattr(c_art, "artifact_id", None) or getattr(c_art, "artifactId", "unknown")
                logger.info("Resuming slot Q%d from committed artifact %s", q_num, c_id)
            else:
                slots_to_generate.append(slot)

        if not slots_to_generate:
            filtered_questions = {k: v for k, v in committed_questions.items() if sec_start <= k <= sec_end}
            return {
                "status": "COMPLETED",
                "totalQuestions": len(filtered_questions),
                "questions": filtered_questions,
                "resumedCount": len(question_slots),
                "generatedCount": 0,
            }
        expected_workflow_op_id = f"op_workflow_qcand_s{section_index}_{run_id[:8]}"
        existing_reserved = [
            o for o in (stored_state.operations or [])
            if o.operationType == "WORKFLOW" and o.status == "RESERVED" and o.operationId == expected_workflow_op_id
        ]
        if existing_reserved:
            workflow_op_id = existing_reserved[0].operationId
        else:
            workflow_op_id = expected_workflow_op_id
            remaining_tokens = max(0, SECTION_MAX_TOKENS - budget_tracker.tokens_used)
            remaining_wall = max(0.0, SECTION_MAX_WALL_TIME_SECONDS - budget_tracker.get_elapsed_seconds())
            token_res = -1 if self.policy.is_unlimited else min(self.policy.max_total_tokens if self.policy.max_total_tokens > 0 else remaining_tokens, remaining_tokens)
            wall_res = -1.0 if self.policy.is_unlimited else min(float(self.policy.max_wall_time_seconds) if self.policy.max_wall_time_seconds > 0 else remaining_wall, remaining_wall)
            workflow_grant = self.persistence_client.grant_operation(OperationGrantRequest(
                runId=run_id,
                epoch=epoch,
                leaseOwner=lease_owner,
                operationId=workflow_op_id,
                operationType="WORKFLOW",
                requestHash=f"workflow:questions:s{section_index}:{run_id}:v1",
                tokenReservation=token_res,
                wallTimeReservationSeconds=wall_res,
                sectionId=str(section_index),
                artifactId=None,
                parentOperationId=parent_operation_id,
            ))
            if workflow_grant.isReplay:
                logger.info("Workflow parent operation %s resumed from replay grant", workflow_op_id)
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
                        tokensUsed=0,
                        accountingType="REPORTED",
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
            def __init__(self, slot_generator, q_num, q_type, passage_text, p_ref, bp_ref, group_start_num=None, group_cache=None, blank_count=None, group_id=None, policy=None):
                self._generator = slot_generator
                self._q_num = q_num
                self._q_type = q_type
                self._passage_text = passage_text
                self._p_ref = p_ref
                self._bp_ref = bp_ref
                self._group_start_num = group_start_num
                self._group_cache = group_cache if group_cache is not None else {}
                self._blank_count = blank_count
                self._group_id = group_id
                self._policy = policy
                self.pool: Optional[QuestionCandidatePool] = None

            @property
            def name(self) -> str:
                return f"SlotCandidateGenerator_Q{self._q_num}"

            @property
            def version(self) -> str:
                return "2.0.0"

            def _group_answers_already_used(self) -> set:
                """Case-folded answers this SummaryCompletion group has already accepted.

                Sourced from the group's surviving blanks in `_group_cache`: the blank
                for this slot was dropped (that is what starved it), while every other
                blank that passed the generator's own gates was kept. Those kept
                answers are the distinctness budget for this slot. Returns an empty set
                when the group cache holds nothing usable, so the gate never
                manufactures a constraint the evidence does not support.
                """
                cached = self._group_cache.get("summary_parsed") or {}
                return {
                    str(b.get("answer", "") or "").strip().casefold()
                    for b in cached.get("blanks", [])
                    if isinstance(b, dict) and str(b.get("answer", "") or "").strip()
                }

            async def _call_generate_pool(self, **kwargs):
                import inspect
                fn = self._generator.generate_candidate_pool
                if "max_wall_time_seconds" not in kwargs and self._policy is not None:
                    kwargs["max_wall_time_seconds"] = self._policy.operation_wall_reservation_seconds
                try:
                    sig = inspect.signature(fn)
                    accepts_var_kw = any(
                        p.kind == inspect.Parameter.VAR_KEYWORD for p in sig.parameters.values()
                    )
                    if not accepts_var_kw:
                        kwargs = {k: v for k, v in kwargs.items() if k in sig.parameters}
                except (ValueError, TypeError):
                    pass
                return await fn(**kwargs)
            async def generate(self, context: LoopContext, intent_id: str, version: int) -> ArtifactEnvelope:
                family = QuestionPromptFamily.from_raw(self._q_type)
                if version > 1:
                    self._group_cache.pop("summary_parsed", None)
                    self._group_cache.pop("group_raw_candidates", None)
                if family == QuestionPromptFamily.SUMMARY_COMPLETION and "summary_parsed" in self._group_cache and version == 1:
                    cached_data = self._group_cache["summary_parsed"]
                    summary_text = cached_data.get("summaryText", "")
                    blanks = [b for b in cached_data.get("blanks", []) if isinstance(b, dict)]
                    rel_idx = self._q_num - (self._group_start_num or self._q_num)
                    target_blank = None
                    for b in blanks:
                        if b.get("number") == self._q_num or b.get("_orig_index") == rel_idx:
                            target_blank = b
                            break
                    if target_blank is None and (0 <= rel_idx < len(blanks)):
                        cand_b = blanks[rel_idx]
                        if cand_b.get("number") is None and cand_b.get("_orig_index") is None:
                            target_blank = cand_b
                    slot_id = f"slot_q{self._q_num}_{self._q_type}"
                    pool = QuestionCandidatePool(
                        slotId=slot_id,
                        questionNumber=self._q_num,
                        questionType=self._q_type,
                        poolLimit=2,
                    )
                    ans_str = (
                        target_blank.get("answer", "")
                        or target_blank.get("text", "")
                        or target_blank.get("correctAnswer", "")
                    ) if target_blank else ""
                    prompt_str = summary_text or (target_blank.get("placeholder", f"Blank #{self._q_num}") if target_blank else f"Blank #{self._q_num}")
                    if str(ans_str).strip():
                        cand = QuestionCandidate(
                            candidateId=f"cand_{slot_id}_1_{uuid4().hex[:6]}",
                            slotId=slot_id,
                            passageRef=self._p_ref,
                            blueprintRef=self._bp_ref,
                            groupId=self._group_id,
                            questionNumber=self._q_num,
                            questionType=self._q_type,
                            prompt=prompt_str,
                            answer=str(ans_str).strip(),
                            evidenceQuote=target_blank.get("evidenceQuote", ""),
                            explanation=target_blank.get("explanation", ""),
                            metadata={"promptVersion": QUESTION_PROMPT_VERSION, "provider": "cached_group"},
                        )
                        pool.add_candidate(cand)
                    self.pool = pool
                    if not self.pool or not self.pool.candidates or not self.pool.get_eligible_candidates():
                        self.pool = await self._call_generate_pool(
                            passage_text=self._passage_text,
                            question_type=self._q_type,
                            question_number=self._q_num,
                            passage_ref=self._p_ref,
                            blueprint_ref=self._bp_ref,
                            run_id=context.run_id,
                            section_id=str(context.section_id or 1),
                            context=context,
                            parent_operation_id=intent_id,
                            group_start_number=self._group_start_num,
                            blank_count=self._blank_count,
                            group_id=self._group_id,
                        )
                        if getattr(self._generator, "_last_summary_parsed", None):
                            self._group_cache["summary_parsed"] = self._generator._last_summary_parsed
                elif family != QuestionPromptFamily.SUMMARY_COMPLETION and self._generator.gateway is not None and "group_raw_candidates" in self._group_cache and version == 1:
                    raw_list = self._group_cache["group_raw_candidates"]
                    rel_idx = max(0, self._q_num - (self._group_start_num or self._q_num))
                    if len(raw_list) >= (self._blank_count or 1) and rel_idx < len(raw_list):
                        rotated = raw_list[rel_idx:] + raw_list[:rel_idx]
                        self.pool = self._generator.build_pool_from_raw_candidates(
                            raw_candidates=rotated,
                            passage_text=self._passage_text,
                            question_type=self._q_type,
                            question_number=self._q_num,
                            passage_ref=self._p_ref,
                            blueprint_ref=self._bp_ref,
                            pool_limit=min(len(rotated), max(get_pool_limit_for_type(self._q_type), 5)),
                            slot_id=f"slot_q{self._q_num}_{self._q_type}",
                            group_id=self._group_id,
                        )
                    if not self.pool or not self.pool.candidates or not self.pool.get_eligible_candidates():
                        self.pool = await self._call_generate_pool(
                            passage_text=self._passage_text,
                            question_type=self._q_type,
                            question_number=self._q_num,
                            passage_ref=self._p_ref,
                            blueprint_ref=self._bp_ref,
                            run_id=context.run_id,
                            section_id=str(context.section_id or 1),
                            context=context,
                            parent_operation_id=intent_id,
                            group_start_number=self._group_start_num,
                            blank_count=self._blank_count,
                            group_id=self._group_id,
                        )
                        if getattr(self._generator, "_last_group_raw_candidates", None):
                            existing = self._group_cache.get("group_raw_candidates", [])
                            self._group_cache["group_raw_candidates"] = existing + [c for c in self._generator._last_group_raw_candidates if c not in existing]
                else:
                    custom_limit = None
                    if family != QuestionPromptFamily.SUMMARY_COMPLETION and self._generator.gateway is not None and "group_raw_candidates" not in self._group_cache:
                        custom_limit = max(get_pool_limit_for_type(self._q_type), (self._blank_count or 1) * 2)

                    self.pool = await self._call_generate_pool(
                        passage_text=self._passage_text,
                        question_type=self._q_type,
                        question_number=self._q_num,
                        passage_ref=self._p_ref,
                        blueprint_ref=self._bp_ref,
                        run_id=context.run_id,
                        section_id=str(context.section_id or 1),
                        context=context,
                        parent_operation_id=intent_id,
                        group_start_number=self._group_start_num,
                        blank_count=self._blank_count,
                        group_id=self._group_id,
                        custom_pool_limit=custom_limit,
                    )
                    if family == QuestionPromptFamily.SUMMARY_COMPLETION and getattr(self._generator, "_last_summary_parsed", None):
                        self._group_cache["summary_parsed"] = self._generator._last_summary_parsed
                    elif family != QuestionPromptFamily.SUMMARY_COMPLETION and getattr(self._generator, "_last_group_raw_candidates", None):
                        raw_cands = getattr(self._generator, "_last_group_raw_candidates", [])
                        if len(raw_cands) >= 2:
                            self._group_cache["group_raw_candidates"] = list(raw_cands)
                if (
                    family == QuestionPromptFamily.SUMMARY_COMPLETION
                    and self._generator.gateway is not None
                    and (not self.pool or not self.pool.candidates or not any(str(c.answer or "").strip() for c in self.pool.candidates))
                ):
                    fallback_pool = await self._call_generate_pool(
                        passage_text=self._passage_text,
                        question_type="SentenceCompletion",
                        question_number=self._q_num,
                        passage_ref=self._p_ref,
                        blueprint_ref=self._bp_ref,
                        run_id=context.run_id,
                        section_id=str(context.section_id or 1),
                        context=context,
                        parent_operation_id=intent_id,
                        # P15 starvation recovery: request ONE plain cloze for this slot.
                        # Passing group_start_number/blank_count here widened the prompt
                        # to "questions 20 to 26", which invited a `blanks`-shaped
                        # group reply; `generate_candidate_pool` zeroes `raw_candidates`
                        # whenever a `blanks` key is present, so the fallback returned an
                        # empty pool and silently no-opped. That is the whole canonical
                        # signature: 3 `gen_qpool_20_*` dispatches then termination with
                        # Q21-Q26 never attempted. Omitting both arguments makes this a
                        # single-slot request the model answers in `candidates` shape.
                        group_start_number=None,
                        blank_count=None,
                        group_id=self._group_id,
                    )
                    if fallback_pool and fallback_pool.candidates:
                        # Mutual distinctness within the group is a correctness gate,
                        # not a nicety: two blanks of one summary must not carry the
                        # same answer. The recovered answer was produced by a per-slot
                        # request that never saw its siblings, so it can collide with
                        # an answer this same group already accepted. The loop holds
                        # those sibling answers in `_group_cache` at exactly this
                        # moment (the starved blank was dropped, the valid ones were
                        # kept), so consult them here. Dropping a colliding candidate
                        # leaves the pool empty, which fails closed with the truthful
                        # SCHEMA_VIOLATION rather than serving a duplicate answer.
                        sibling_answers = self._group_answers_already_used()
                        adapted_cands = [
                            c.model_copy(update={"question_type": self._q_type, "slot_id": f"slot_q{self._q_num}_{self._q_type}"})
                            for c in fallback_pool.candidates
                            if str(c.answer or "").strip() and str(c.answer or "").strip().casefold() not in sibling_answers
                        ]
                        self.pool = QuestionCandidatePool(
                            slotId=f"slot_q{self._q_num}_{self._q_type}",
                            questionNumber=self._q_num,
                            questionType=self._q_type,
                            poolLimit=fallback_pool.pool_limit,
                            candidates=adapted_cands,
                            tokensUsed=fallback_pool.tokens_used,
                            wallTimeUsedSeconds=fallback_pool.wall_time_used_seconds,
                        )
                prev_pair = None
                if version > 1 and getattr(context, "current_artifact", None) is not None:
                    prev_p = context.current_artifact.payload or {}
                    prev_pair = (str(prev_p.get("prompt") or "").strip(), str(prev_p.get("answer") or "").strip())
                eligible_non_empty = [
                    c for c in (self.pool.get_eligible_candidates() if self.pool else [])
                    if str(c.answer or "").strip() and str(c.prompt or "").strip()
                ]
                all_non_empty = [
                    c for c in (self.pool.candidates if self.pool else [])
                    if str(c.answer or "").strip() and str(c.prompt or "").strip()
                ]
                cand_choices = eligible_non_empty or all_non_empty or (list(self.pool.candidates) if self.pool and self.pool.candidates else [])
                if prev_pair and len(cand_choices) > 1:
                    distinct_choices = [
                        c for c in cand_choices
                        if (str(c.prompt or "").strip(), str(c.answer or "").strip()) != prev_pair
                    ]
                    if distinct_choices:
                        cand_choices = distinct_choices
                best_cand = cand_choices[0] if cand_choices else None
                payload = {
                    "questionNumber": self._q_num,
                    "questionType": self._q_type,
                    "prompt": best_cand.prompt if best_cand else "",
                    "answer": best_cand.answer if best_cand else "",
                    "options": [o.model_dump(mode="json", by_alias=True) for o in best_cand.options] if best_cand and best_cand.options else None,
                    "evidenceQuote": best_cand.evidence_quote if best_cand else "",
                    "explanation": best_cand.explanation if best_cand and best_cand.explanation else "",
                    "score": best_cand.score if best_cand else 0.0,
                    "passage": self._passage_text,
                    "candidates": [c.model_dump(mode="json", by_alias=True) for c in (self.pool.candidates if self.pool else [])],
                    "tokensUsed": self.pool.tokens_used if self.pool else 0,
                    "wallTimeUsedSeconds": self.pool.wall_time_used_seconds if self.pool else 0.0,
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
        # Group slots by groupId (or contiguous type)
        grouped_slots: Dict[str, List[Dict[str, Any]]] = {}
        for slot in slots_to_generate:
            gid = slot.get("groupId") or slot.get("group_id") or f"grp_{slot.get('type') or slot.get('questionType', 'default')}"
            if gid not in grouped_slots:
                grouped_slots[gid] = []
            grouped_slots[gid].append(slot)

        for gid, grp_slots in grouped_slots.items():
            grp_pools: List[QuestionCandidatePool] = []
            grp_cache: Dict[str, Any] = {}
            for slot in grp_slots:
                q_num = slot.get("questionNumber") or slot.get("slotNumber") or slot.get("number") or 1
                q_type = slot.get("questionType") or slot.get("type") or "TrueFalseNotGiven"

                if not self.policy.is_unlimited:
                    if budget_tracker.tokens_used >= SECTION_MAX_TOKENS:
                        raise SelectionInfeasibleError(
                            f"Cumulative section token budget exceeded: {budget_tracker.tokens_used} >= {SECTION_MAX_TOKENS}",
                            step_count=1,
                            reason="TOKEN_CAP",
                        )
                    if budget_tracker.get_elapsed_seconds() >= SECTION_MAX_WALL_TIME_SECONDS:
                        raise SelectionInfeasibleError(
                            f"Cumulative section wall time budget exceeded: {budget_tracker.get_elapsed_seconds():.1f}s >= {SECTION_MAX_WALL_TIME_SECONDS}s",
                            step_count=1,
                            reason="WALL_TIME_CAP",
                        )

                grp_start_num = grp_slots[0].get("questionNumber") or grp_slots[0].get("slotNumber") or grp_slots[0].get("number") or 1
                adapter = SlotCandidateGeneratorAdapter(
                    slot_generator=self.generator,
                    q_num=q_num,
                    q_type=q_type,
                    passage_text=passage_text,
                    p_ref=passage_artifact.to_ref(),
                    bp_ref=blueprint_ref,
                    group_start_num=int(grp_start_num),
                    group_cache=grp_cache,
                    blank_count=len(grp_slots),
                    group_id=str(gid),
                    policy=self.policy,
                )

                slot_ctx = LoopContext(
                    runId=run_id,
                    targetArtifactId=f"art_q_slot_{q_num}",
                    targetArtifactType=ArtifactType.QUESTION,
                    scope=IssueScope.QUESTION,
                    sectionId=section_index,
                    authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                    inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                    budgetTracker=BudgetTracker(
                        tokensUsed=budget_tracker.tokens_used,
                        wallTimeUsedSeconds=budget_tracker.get_elapsed_seconds(),
                        callsUsed=budget_tracker.calls_used,
                    ),
                    parent_operation_id=workflow_op_id,
                )

                from app.repair.question import QuestionItemRepairer
                slot_repairer = QuestionItemRepairer(gateway=self.generator.gateway)
                slot_runtime = BoundedLoopRuntime(
                    context=slot_ctx,
                    policy=self.policy,
                    generator=adapter,
                    repairer=slot_repairer,
                    evaluators=[e for e in self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION)
                                if not self.policy.required_evaluator_ids or e.evaluator_id in self.policy.required_evaluator_ids],
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
                new_slot_tokens = max(0, slot_runtime.context.budget_tracker.tokens_used - budget_tracker.tokens_used)
                new_slot_calls = max(0, slot_runtime.context.budget_tracker.calls_used - budget_tracker.calls_used)
                budget_tracker.record_usage(tokens=new_slot_tokens, calls=new_slot_calls)

                slot_art = slot_res.accepted_artifact or slot_runtime.context.current_artifact
                if slot_art and slot_art.payload and "candidates" in slot_art.payload:
                    cands_data = slot_art.payload.get("candidates", [])
                    candidates = [QuestionCandidate.model_validate(c) for c in cands_data]
                    top_ans = str(slot_art.payload.get("answer") or "").strip()
                    top_prompt = str(slot_art.payload.get("prompt") or "").strip()
                    if top_ans and top_prompt and candidates:
                        candidates[0] = candidates[0].model_copy(
                            update={
                                "answer": top_ans,
                                "prompt": top_prompt,
                            }
                        )
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
                                "options": [o.model_dump(mode="json", by_alias=True) for o in self._candidate.options] if self._candidate.options else None,
                                "evidenceQuote": self._candidate.evidence_quote,
                                "explanation": self._candidate.explanation,
                                "score": self._candidate.score,
                                "candidateId": self._candidate.candidate_id,
                            },
                            parent_refs=[self._p_ref, self._bp_ref],
                            run_id=context.run_id,
                            producer_version="2.0.0",
                        )

                if self.generator.gateway is not None:
                    q_evaluators = [e for e in self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION)
                                    if not self.policy.required_evaluator_ids or e.evaluator_id in self.policy.required_evaluator_ids]
                    for cand in pool.candidates:
                        cand_ctx = LoopContext(
                            runId=run_id,
                            targetArtifactId=f"art_q_{cand.question_number}_{cand.candidate_id}",
                            targetArtifactType=ArtifactType.QUESTION,
                            scope=IssueScope.QUESTION,
                            sectionId=section_index,
                            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                            inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                            budgetTracker=BudgetTracker(),
                            parent_operation_id=workflow_op_id,
                        )
                        cand_env = ArtifactEnvelope.create(
                            artifact_id=cand_ctx.target_artifact_id,
                            artifact_type=ArtifactType.QUESTION,
                            version=1,
                            payload={
                                "passage": passage_text,
                                "questionNumber": cand.question_number,
                                "questionType": cand.question_type,
                                "prompt": cand.prompt,
                                "answer": cand.answer,
                                "options": [o.model_dump(mode="json", by_alias=True) for o in cand.options] if cand.options else None,
                                "evidenceQuote": cand.evidence_quote,
                                "explanation": cand.explanation,
                                "score": cand.score,
                                "candidateId": cand.candidate_id,
                            },
                            parent_refs=[passage_artifact.to_ref(), blueprint_ref],
                            run_id=run_id,
                            producer_version="2.0.0",
                        )
                        for ev in q_evaluators:
                            ev_res = await ev.evaluate(cand_ctx, cand_env, intent_id=f"intent_eval_{cand.candidate_id}")
                            if ev_res.status != EvaluationStatus.PASS:
                                cand.rejected = True
                                for iss in ev_res.issues:
                                    cand.rejection_reasons.append(f"{iss.code.value if hasattr(iss.code, 'value') else str(iss.code)}: {iss.message}")
                                if not cand.rejection_reasons:
                                    cand.rejection_reasons.append(f"EVAL_{ev.evaluator_id}")
                else:
                    for cand in pool.candidates:
                        cand_ctx = LoopContext(
                            runId=run_id,
                            targetArtifactId=f"art_q_{cand.question_number}_{cand.candidate_id}",
                            targetArtifactType=ArtifactType.QUESTION,
                            scope=IssueScope.QUESTION,
                            sectionId=section_index,
                            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                            inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                            budgetTracker=BudgetTracker(),
                            parent_operation_id=workflow_op_id,
                        )
                        cand_runtime = BoundedLoopRuntime(
                            context=cand_ctx,
                            policy=self.policy.model_copy(update={"generate_token_reservation": 0, "operation_wall_reservation_seconds": 1.0}),
                            generator=SingleCandidateGenerator(cand, passage_text, passage_artifact.to_ref(), blueprint_ref),
                            evaluators=[e for e in self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION)
                                        if not self.policy.required_evaluator_ids or e.evaluator_id in self.policy.required_evaluator_ids],
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

                filtered_pool = QuestionCandidatePool(
                    slot_id=pool.slot_id,
                    question_number=pool.question_number,
                    question_type=pool.question_type,
                    pool_limit=pool.pool_limit,
                    candidates=eligible,
                )
                grp_pools.append(filtered_pool)

            # Joint Constraint Selection for this group
            if grp_pools:
                committed_prompts: List[str] = []
                for cq in committed_questions.values():
                    c_payload = cq.payload if hasattr(cq, "payload") and isinstance(cq.payload, (Mapping, dict)) else {}
                    for q in (c_payload.get("questions") or [c_payload]):
                        if isinstance(q, (Mapping, dict)):
                            p = q.get("prompt") or q.get("statement")
                            if p:
                                committed_prompts.append(str(p))

                p_payload = passage_artifact.payload if isinstance(passage_artifact.payload, (Mapping, dict)) else {}
                passage_title = p_payload.get("title", "")
                passage_topic = p_payload.get("topic", "") or p_payload.get("sourceTopic", "") or passage_title
                try:
                    selected_grp_candidates = self.selector.select_joint_group(
                        grp_pools,
                        external_prompts=committed_prompts,
                        topic=str(passage_topic or ""),
                        passage_title=str(passage_title or ""),
                    )
                except SelectionInfeasibleError as sel_err:
                    if self.generator.gateway is not None:
                        logger.warning("Joint selection infeasible for group %s, generating supplementary candidates: %s", gid, sel_err)
                        q_evaluators = [e for e in self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION)
                                        if not self.policy.required_evaluator_ids or e.evaluator_id in self.policy.required_evaluator_ids]
                        for slot, p in zip(grp_slots, grp_pools):
                            s_q_num = int(slot.get("questionNumber") or slot.get("slotNumber") or slot.get("number") or 1)
                            s_q_type = slot.get("questionType") or slot.get("type") or "SentenceCompletion"
                            slot_supp_ctx = LoopContext(
                                runId=run_id,
                                targetArtifactId=f"art_q_supp_{s_q_num}_{uuid4().hex[:6]}",
                                targetArtifactType=ArtifactType.QUESTION,
                                scope=IssueScope.QUESTION,
                                sectionId=section_index,
                                authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                                inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                                budgetTracker=BudgetTracker(),
                                parent_operation_id=workflow_op_id,
                            )
                            extra_pool = await self.generator.generate_candidate_pool(
                                passage_text=passage_text,
                                question_type=s_q_type,
                                question_number=s_q_num,
                                passage_ref=passage_artifact.to_ref(),
                                blueprint_ref=blueprint_ref,
                                run_id=run_id,
                                section_id=str(section_index),
                                context=slot_supp_ctx,
                                parent_operation_id=workflow_op_id,
                                custom_pool_limit=3,
                                group_id=str(gid),
                            )
                            for cand in extra_pool.candidates:
                                cand_ctx = LoopContext(
                                    runId=run_id,
                                    targetArtifactId=f"art_q_{cand.question_number}_{cand.candidate_id}",
                                    targetArtifactType=ArtifactType.QUESTION,
                                    scope=IssueScope.QUESTION,
                                    sectionId=section_index,
                                    authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                                    inputDependencies=(passage_artifact.to_ref(), blueprint_ref),
                                    budgetTracker=BudgetTracker(),
                                    parent_operation_id=workflow_op_id,
                                )
                                cand_env = ArtifactEnvelope.create(
                                    artifact_id=cand_ctx.target_artifact_id,
                                    artifact_type=ArtifactType.QUESTION,
                                    version=1,
                                    payload={
                                        "passage": passage_text,
                                        "questionNumber": cand.question_number,
                                        "questionType": cand.question_type,
                                        "prompt": cand.prompt,
                                        "answer": cand.answer,
                                        "options": [o.model_dump(mode="json", by_alias=True) for o in cand.options] if cand.options else None,
                                        "evidenceQuote": cand.evidence_quote,
                                        "explanation": cand.explanation,
                                        "score": cand.score,
                                        "candidateId": cand.candidate_id,
                                    },
                                    parent_refs=[passage_artifact.to_ref(), blueprint_ref],
                                    run_id=run_id,
                                    producer_version="2.0.0",
                                )
                                for ev in q_evaluators:
                                    ev_res = await ev.evaluate(cand_ctx, cand_env, intent_id=f"intent_eval_supp_{cand.candidate_id}")
                                    if ev_res.status != EvaluationStatus.PASS:
                                        cand.rejected = True
                                        for iss in ev_res.issues:
                                            cand.rejection_reasons.append(f"{iss.code.value if hasattr(iss.code, 'value') else str(iss.code)}: {iss.message}")
                                if not cand.rejected:
                                    p.pool_limit = max(p.pool_limit, len(p.candidates) + 1)
                                    p.add_candidate(cand)
                        selected_grp_candidates = self.selector.select_joint_group(
                            grp_pools,
                            external_prompts=committed_prompts,
                            topic=str(passage_topic or ""),
                            passage_title=str(passage_title or ""),
                        )
                    else:
                        raise
                newly_selected_candidates.extend(selected_grp_candidates)
                grp_start = min(c.question_number for c in selected_grp_candidates)
                grp_end = max(c.question_number for c in selected_grp_candidates)
                target_grp_id = f"art_grp_s{section_index}_q{grp_start}_q{grp_end}"
                group_payload = {
                    "sectionIndex": section_index,
                    "groupId": gid,
                    "startNumber": grp_start,
                    "endNumber": grp_end,
                    "questionCount": len(selected_grp_candidates),
                    "questions": [
                        {
                            "questionNumber": c.question_number,
                            "questionType": c.question_type,
                            "prompt": c.prompt,
                            "answer": c.answer,
                            "options": [o.model_dump(mode="json", by_alias=True) for o in c.options] if c.options else None,
                            "evidenceQuote": c.evidence_quote,
                            "explanation": c.explanation,
                            "score": c.score,
                            "candidateId": c.candidate_id,
                        }
                        for c in selected_grp_candidates
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
                    budgetTracker=BudgetTracker(),
                    parent_operation_id=workflow_op_id,
                )

                group_evaluators = self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION_GROUP)
                group_req = [ev for ev in group_evaluators if ev.metadata.required]
                group_req_ids = tuple(ev.evaluator_id for ev in group_req)
                group_policy = self.policy.model_copy(update={"generate_token_reservation": 0, "operation_wall_reservation_seconds": 1.0, "required_evaluator_ids": group_req_ids})
                group_runtime = BoundedLoopRuntime(
                    context=group_ctx,
                    policy=group_policy,
                    generator=WinningGroupGenerator(),
                    evaluators=group_req,
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
                for c in selected_grp_candidates:
                    committed_questions[c.question_number] = accepted_grp
        slot_nums = [
            int(s.get("questionNumber") or s.get("slotNumber") or s.get("number"))
            for s in question_slots
            if (s.get("questionNumber") or s.get("slotNumber") or s.get("number")) is not None
        ]
        if slot_nums:
            sec_start = min(slot_nums)
            sec_end = max(slot_nums)
        else:
            sec_start = 1 if section_index == 1 else (14 if section_index == 2 else 27)
            sec_end = 13 if section_index == 1 else (26 if section_index == 2 else 40)
        filtered_questions = {k: v for k, v in committed_questions.items() if sec_start <= k <= sec_end}
        return {
            "status": "COMPLETED",
            "totalQuestions": len(filtered_questions),
            "questions": filtered_questions,
            "resumedCount": len(question_slots) - len(slots_to_generate),
            "generatedCount": len(newly_selected_candidates),
            "journal": step_journal.entries,
        }

    async def repair_question_artifact(
        self,
        question_envelope: ArtifactEnvelope,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        passage_text: str,
        issues: List[Any],
        run_id: str,
        lease_owner: UUID,
        epoch: int = 1,
        section_index: int = 1,
        parent_operation_id: Optional[str] = None,
        patched_payload: Optional[Dict[str, Any]] = None,
    ) -> LoopResult:
        """Repairs, evaluates, and durably accepts a replacement Question artifact via BoundedLoopRuntime."""
        from app.repair.question import QuestionItemRepairer, unwrap_payload

        q_repairer = QuestionItemRepairer(
            gateway=getattr(self.generator, "gateway", None) if self.generator else None
        )
        if patched_payload is not None:
            repaired_payload = unwrap_payload(patched_payload)
        else:
            base_payload = unwrap_payload(question_envelope.payload)
            had_passage = "passage" in base_payload
            if not had_passage and passage_text:
                base_payload["passage"] = passage_text
            seed_env = question_envelope.model_copy(update={"payload": base_payload})
            temp_ctx = LoopContext(
                runId=run_id,
                targetArtifactId=question_envelope.artifact_id,
                targetArtifactType=ArtifactType.QUESTION,
                scope=IssueScope.QUESTION,
                sectionId=section_index,
                authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                inputDependencies=(passage_ref, blueprint_ref),
                budgetTracker=BudgetTracker(),
                parent_operation_id=parent_operation_id,
            )
            repaired_env = await q_repairer.repair(
                temp_ctx,
                seed_env,
                issues,
                intent_id=f"intent_qrep_{question_envelope.artifact_id}",
                version=question_envelope.version + 1,
            )
            repaired_payload = unwrap_payload(repaired_env.payload)
            if not had_passage:
                repaired_payload.pop("passage", None)

        if "answer" not in repaired_payload and "correctOption" in repaired_payload:
            repaired_payload["answer"] = repaired_payload["correctOption"]

        class RepairedQuestionGeneratorAdapter(GeneratorCapability):
            @property
            def name(self) -> str:
                return f"RepairedQuestionGenerator_{question_envelope.artifact_id}"

            @property
            def version(self) -> str:
                return "2.0.0"

            async def generate(self, context: LoopContext, intent_id: str, version: int) -> ArtifactEnvelope:
                return ArtifactEnvelope.create(
                    artifact_id=context.target_artifact_id,
                    artifact_type=ArtifactType.QUESTION,
                    version=version,
                    payload=dict(repaired_payload),
                    parent_refs=[passage_ref, blueprint_ref],
                    run_id=context.run_id,
                    producer_version="2.0.0",
                    section_id=section_index,
                    schema_version="2.0.0",
                )

        q_ctx = LoopContext(
            runId=run_id,
            targetArtifactId=question_envelope.artifact_id,
            targetArtifactType=ArtifactType.QUESTION,
            scope=IssueScope.QUESTION,
            sectionId=section_index,
            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
            inputDependencies=(passage_ref, blueprint_ref),
            currentArtifact=question_envelope,
            budgetTracker=BudgetTracker(),
            parent_operation_id=parent_operation_id,
        )
        q_evaluators = [e for e in self.evaluator_registry.resolve_pipeline(ArtifactType.QUESTION)
                        if not self.policy.required_evaluator_ids or e.evaluator_id in self.policy.required_evaluator_ids]
        q_policy = self.policy.model_copy(
            update={"generate_token_reservation": 0, "operation_wall_reservation_seconds": 5.0}
        )
        q_runtime = BoundedLoopRuntime(
            context=q_ctx,
            policy=q_policy,
            generator=RepairedQuestionGeneratorAdapter(),
            repairer=q_repairer,
            evaluators=q_evaluators,
            persistence_client=self.persistence_client,
            accepted_dependencies={
                passage_ref.artifact_id: passage_ref,
                blueprint_ref.artifact_id: blueprint_ref,
            },
            accept_head=True,
        )
        return await q_runtime.run()
