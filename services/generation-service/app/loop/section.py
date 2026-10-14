"""Section Loop Engine for Langfens V2 (Phase 11 / P11-01..P11-08).

Orchestrates passage synthesis, question group candidate generation, immutable section assembly,
section-wide quality evaluation (structure, duplicates, span concentration, editorial),
and authoritative checkpoint persistence on top of BoundedLoopRuntime.

Invariants:
- Section acceptance MUST NOT create an exam or complete the full paper/job (P11-08).
- Minimal scoped repairs with exact descendant closure invalidation (P11-05).
- Student payload isolation strictly enforced without internal answer/evaluation leakage (P11-01).
- Durable cursor resumption preserves already accepted section and question heads (P11-07).
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List, Mapping, Optional, Sequence, Union
from uuid import UUID, uuid4

from app.config import settings
from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.contracts.blueprint import QuestionType
from app.contracts.issue import Issue, IssueCode, IssueLedger, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.contracts.policies import (
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    count_words,
)
from app.contracts.section import (
    SectionPayload,
    SectionSnapshot,
    SectionSourceInfo,
    SectionStatus,
    StudentVisibleSection,
    assemble_immutable_section,
    assert_student_visible_payload_isolated,
    to_student_visible_section,
)
from app.evaluators.base import BaseEvaluator
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.coverage import SectionCoverageEvaluator
from app.evaluators.section import (
    SectionDuplicateAndConcentrationEvaluator,
    SectionEditorialEvaluator,
    SectionStructureEvaluator,
)
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator
from app.generators.question.generator import QuestionCandidateGenerator
from app.loop.capabilities import GeneratorCapability, RepairerCapability
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.journal import OperationIntent, StepJournal
from app.loop.passage import PassageLoop
from app.loop.policy import LoopPolicy
from app.loop.question import QuestionCandidateLoop
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.persistence.client import CheckpointClient
from app.persistence.models import (
    CheckpointCommitRequest,
    DraftCheckpointRequest,
    LoopCursorCheckpointRequest,
    OperationGrantRequest,
    OperationReconcileRequest,
)
from app.repair.section import (
    SectionRepairActionType,
    SectionRepairRoute,
    SectionRepairRouter,
    SectionSurgicalRepairer,
)

logger = logging.getLogger(__name__)


class SectionGeneratorAdapter(GeneratorCapability):
    """Adapts Section assembly to the BoundedLoopRuntime GeneratorCapability protocol."""

    def __init__(
        self,
        section_index: int,
        title: str,
        passage_envelope: ArtifactEnvelope,
        blueprint_ref: ArtifactRef,
        question_envelopes: List[ArtifactEnvelope],
        source_info: Optional[SectionSourceInfo] = None,
        template_section_payload: Optional[Dict[str, Any]] = None,
        persistence_client: Optional[CheckpointClient] = None,
    ):
        self.section_index = section_index
        self.title = title
        self.passage_envelope = passage_envelope
        self.blueprint_ref = blueprint_ref
        self.question_envelopes = question_envelopes
        self.source_info = source_info
        self.template_section_payload = template_section_payload
        self.persistence_client = persistence_client
    @property
    def name(self) -> str:
        return "SectionAssemblyGenerator"

    @property
    def version(self) -> str:
        return "2.0.0"

    async def generate(
        self,
        context: LoopContext,
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        eval_summary = None
        if self.persistence_client is not None and hasattr(self.persistence_client, "resume_state"):
            try:
                res_state = self.persistence_client.resume_state(context.run_id)
                res_evals = getattr(res_state, "evaluations", None) or []
                p_ref = self.passage_envelope.to_ref()
                bp_ref = self.blueprint_ref
                sec_child_refs = [p_ref] + [q.to_ref() for q in self.question_envelopes]

                def _ev_id(ev: Any) -> str:
                    return getattr(ev, "evaluation_id", getattr(ev, "evaluationId", ""))

                def _ev_target(ev: Any) -> Optional[ArtifactRef]:
                    t = getattr(ev, "target_ref", getattr(ev, "targetRef", None))
                    return ArtifactRef.model_validate(t) if t is not None else None

                def _ev_status(ev: Any) -> str:
                    s = getattr(ev, "status", "")
                    return s.value if hasattr(s, "value") else str(s)

                def _ev_evaluator(ev: Any) -> str:
                    return getattr(ev, "evaluator_id", getattr(ev, "evaluatorId", ""))

                def _ev_issues(ev: Any) -> list:
                    return list(getattr(ev, "issues", []) or [])

                def _ev_deps(ev: Any) -> Set[ArtifactRef]:
                    raw_deps = (
                        getattr(ev, "input_dependency_refs", getattr(ev, "inputDependencyRefs", []))
                        or []
                    )
                    return {ArtifactRef.model_validate(r) for r in raw_deps}

                all_children_have_fresh_pass = True
                matching_eval_ids: List[str] = []
                solver_covered = False
                adversary_covered = False

                for dep_ref in sec_child_refs:
                    expected_deps = (
                        {p_ref, bp_ref}
                        if dep_ref.artifact_type == ArtifactType.QUESTION
                        else {bp_ref}
                    )

                    def _deps_match(ev: Any) -> bool:
                        ev_dep_set = _ev_deps(ev)
                        if dep_ref.artifact_type == ArtifactType.QUESTION:
                            return ev_dep_set == expected_deps
                        return bp_ref in ev_dep_set

                    dep_pass_evals = [
                        ev
                        for ev in res_evals
                        if _ev_target(ev) == dep_ref
                        and _deps_match(ev)
                        and _ev_status(ev) in ("PASS", EvaluationStatus.PASS)
                        and not any(
                            getattr(i, "status", getattr(i, "status_value", "OPEN")) in ("OPEN", IssueStatus.OPEN)
                            and getattr(i, "severity", None) in (
                                IssueSeverity.CRITICAL,
                                IssueSeverity.MAJOR,
                                "CRITICAL",
                                "MAJOR",
                            )
                            for i in _ev_issues(ev)
                        )
                    ]
                    if not dep_pass_evals:
                        all_children_have_fresh_pass = False
                    else:
                        for ev in dep_pass_evals:
                            eid = _ev_id(ev)
                            if eid:
                                matching_eval_ids.append(eid)
                            ev_name = _ev_evaluator(ev).lower()
                            if "solver" in ev_name:
                                solver_covered = True
                            if "adversary" in ev_name:
                                adversary_covered = True

                all_accepted_refs = list(dict.fromkeys(matching_eval_ids))
                if (
                    all_children_have_fresh_pass
                    and all_accepted_refs
                    and solver_covered
                    and adversary_covered
                ):
                    eval_summary = {
                        "freshEvaluations": True,
                        "hasStaleDependencies": False,
                        "solverCovered": True,
                        "adversaryCovered": True,
                        "acceptedEvaluationRefs": all_accepted_refs,
                        "passageHash": self.passage_envelope.content_hash,
                        "blueprintHash": self.blueprint_ref.content_hash,
                        "questionCount": len(self.question_envelopes),
                        "assembledFromAcceptedRefs": True,
                    }
            except Exception:
                pass

        if self.template_section_payload is not None:
            from app.repair.question import unwrap_payload

            sec_dict = unwrap_payload(self.template_section_payload)
            if eval_summary is not None:
                sec_dict["evaluationsSummary"] = eval_summary
            q_refs = [q.to_ref() for q in self.question_envelopes]
            q_by_num: Dict[int, Dict[str, Any]] = {}
            for q_env in self.question_envelopes:
                qp = unwrap_payload(q_env.payload)
                qn = qp.get("questionNumber") or qp.get("number")
                if qn is not None:
                    q_by_num[int(qn)] = qp
            for grp in sec_dict.get("groups", []):
                if isinstance(grp, dict) and isinstance(grp.get("questions"), list):
                    new_qs = []
                    for q in grp["questions"]:
                        if isinstance(q, dict):
                            qn = q.get("questionNumber") or q.get("number")
                            if qn is not None and int(qn) in q_by_num:
                                q_rep = dict(q_by_num[int(qn)])
                                if "statement" in q and "prompt" not in q:
                                    q_rep.pop("prompt", None)
                                elif "prompt" in q and "statement" not in q:
                                    q_rep.pop("statement", None)
                                if "correctOption" in q and "answer" not in q:
                                    q_rep.pop("answer", None)
                                new_qs.append(q_rep)
                            else:
                                new_qs.append(q)
                        else:
                            new_qs.append(q)
                    grp["questions"] = new_qs
            if sec_dict.get("questionRefs"):
                q_override_by_id = {q.artifact_id: q.to_ref() for q in self.question_envelopes}
                merged_q_refs = [
                    q_override_by_id.get(
                        ArtifactRef.model_validate(qr).artifact_id,
                        ArtifactRef.model_validate(qr),
                    )
                    for qr in sec_dict["questionRefs"]
                ]
            else:
                merged_q_refs = q_refs
            if merged_q_refs:
                sec_dict["questionRefs"] = [
                    qr.model_dump(mode="json", by_alias=True) for qr in merged_q_refs
                ]
            parent_refs = [self.passage_envelope.to_ref(), self.blueprint_ref] + merged_q_refs
            return ArtifactEnvelope.create(
                artifact_id=context.target_artifact_id,
                artifact_type=ArtifactType.SECTION,
                run_id=context.run_id,
                payload=sec_dict,
                producer_version="2.0.0",
                version=version,
                section_id=self.section_index,
                parent_refs=parent_refs,
                schema_version="2.0.0",
            )
        source_info = self.source_info
        if source_info is None and context.current_artifact is not None:
            current_payload = context.current_artifact.payload
            if isinstance(current_payload, Mapping):
                current_source = current_payload.get("source")
            else:
                current_source = getattr(current_payload, "source", None)
            if isinstance(current_source, SectionSourceInfo):
                source_info = current_source
            elif current_source is not None:
                source_info = SectionSourceInfo.model_validate(current_source)

        envelope = assemble_immutable_section(
            section_index=self.section_index,
            title=self.title,
            passage_envelope=self.passage_envelope,
            blueprint_ref=self.blueprint_ref,
            question_envelopes=self.question_envelopes,
            source_info=source_info,
            evaluations_summary=eval_summary,
            run_id=context.run_id,
            version=version,
        )
        if envelope.artifact_id != context.target_artifact_id:
            envelope = envelope.model_copy(update={"artifact_id": context.target_artifact_id})
        return envelope

class SectionRepairerAdapter(RepairerCapability):
    """Adapts SectionSurgicalRepairer to the BoundedLoopRuntime RepairerCapability protocol."""

    def __init__(self, repairer: SectionSurgicalRepairer):
        self._repairer = repairer

    @property
    def name(self) -> str:
        return self._repairer.name

    @property
    def version(self) -> str:
        return "2.0.0"

    async def repair(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        target_version: int,
    ) -> ArtifactEnvelope:
        repaired = await self._repairer._repair_impl(context, artifact, issues, intent_id, target_version)
        if repaired.version != target_version:
            repaired = repaired.model_copy(update={"version": target_version})
        return repaired


class SectionLoop:
    """Bounded loop orchestrator for Section assembly, quality evaluation, and durable acceptance."""

    def __init__(
        self,
        persistence_client: CheckpointClient,
        evaluators: Optional[Sequence[BaseEvaluator]] = None,
        repairer: Optional[SectionSurgicalRepairer] = None,
        policy: Optional[LoopPolicy] = None,
        passage_loop: Optional[PassageLoop] = None,
        question_loop: Optional[QuestionCandidateLoop] = None,
        is_benchmark: bool = False,
    ):
        self.persistence_client = persistence_client
        self.passage_loop = passage_loop
        self.question_loop = question_loop
        self.is_benchmark = is_benchmark

        if policy is not None:
            self.policy = policy
        else:
            self.policy = LoopPolicy.from_settings(
                is_benchmark=is_benchmark,
                generate_reservation_cap="generateTokenReservation",
            )

        self.repairer = repairer or SectionSurgicalRepairer()

        if evaluators is None:
            self.evaluators: List[BaseEvaluator] = [
                # Coverage (fresh Blind Solver / Adversary) is NOT enforced here: this
                # constructor is the generic assembly primitive whose section is derived
                # from caller-supplied already-accepted children, and it binds no
                # coverage evidence of its own. The coverage guarantee is owned and
                # enforced by the callers that actually compute it from the durable
                # evaluation ledger -- the facade section request path and the paper
                # loop -- which register SectionCoverageEvaluator explicitly.
                SectionStructureEvaluator(required=True, timeout_seconds=self.policy.evaluator_stage_timeout_seconds),
                SectionDuplicateAndConcentrationEvaluator(required=True, timeout_seconds=self.policy.evaluator_stage_timeout_seconds),
                SectionEditorialEvaluator(required=False, timeout_seconds=self.policy.evaluator_semantic_timeout_seconds),
            ]
        else:
            self.evaluators = list(evaluators)

        required_ids = tuple(ev.evaluator_id for ev in self.evaluators if ev.metadata.required)
        if self.policy.required_evaluator_ids != required_ids:
            self.policy = self.policy.model_copy(update={"required_evaluator_ids": required_ids})
    async def run(
        self,
        section_index: int,
        title: str,
        passage_artifact: ArtifactEnvelope,
        blueprint_ref: ArtifactRef,
        question_artifacts: List[ArtifactEnvelope],
        run_id: str,
        lease_owner: UUID,
        epoch: int,
        source_info: Optional[SectionSourceInfo] = None,
        timeout_seconds: float = 300.0,
        target_artifact_id: Optional[str] = None,
        template_section_payload: Optional[Dict[str, Any]] = None,
        prior_section_envelope: Optional[ArtifactEnvelope] = None,
        parent_operation_id: Optional[str] = None,
    ) -> LoopResult:
        """Executes Section assembly, evaluation, scoped repair, and durable acceptance."""
        # 1. Authority & Fencing validation against persistence client
        if hasattr(self.persistence_client, "epoch") and hasattr(self.persistence_client, "owner"):
            if epoch < self.persistence_client.epoch or lease_owner != self.persistence_client.owner:
                raise ValueError(
                    f"Stale writer lease or fencing conflict (client epoch {self.persistence_client.epoch}, requested {epoch})"
                )

        # 2. Verify Passage artifact type & immutability
        if passage_artifact.artifact_type != ArtifactType.PASSAGE:
            raise ValueError(f"Expected ArtifactType.PASSAGE, got {passage_artifact.artifact_type}")

        # 3. Assemble immutable section envelope
        generator_adapter = SectionGeneratorAdapter(
            section_index=section_index,
            title=title,
            passage_envelope=passage_artifact,
            blueprint_ref=blueprint_ref,
            question_envelopes=question_artifacts,
            source_info=source_info,
            template_section_payload=template_section_payload,
            persistence_client=self.persistence_client,
        )
        repairer_adapter = SectionRepairerAdapter(self.repairer)

        eval_registry = EvaluatorRegistry()
        for ev in self.evaluators:
            eval_registry.register(ev)

        effective_target_id = target_artifact_id or f"art_section_s{section_index}"
        if (
            template_section_payload is not None
            and isinstance(template_section_payload, dict)
            and template_section_payload.get("questionRefs")
        ):
            q_override_by_id = {q.artifact_id: q.to_ref() for q in question_artifacts}
            merged_q_refs = [
                q_override_by_id.get(
                    ArtifactRef.model_validate(qr).artifact_id,
                    ArtifactRef.model_validate(qr),
                )
                for qr in template_section_payload["questionRefs"]
            ]
            all_input_deps = [passage_artifact.to_ref(), blueprint_ref] + merged_q_refs
        else:
            all_input_deps = [passage_artifact.to_ref(), blueprint_ref] + [q.to_ref() for q in question_artifacts]

        # 4. Check for existing durable checkpoint to resume idempotently
        stored_state = self.persistence_client.resume_state(run_id)
        if hasattr(stored_state, "artifacts") and stored_state.artifacts:
            for art_info in stored_state.artifacts:
                art_id = getattr(art_info, "artifactId", None) or getattr(art_info, "artifact_id", None)
                if art_id == effective_target_id:
                    acc_ver = getattr(art_info, "acceptedVersion", 1) or getattr(art_info, "accepted_version", 1)
                    acc_hash = getattr(art_info, "acceptedHash", "") or getattr(art_info, "accepted_hash", "")

                    raw_payload = getattr(art_info, "payloadJson", "{}") or getattr(art_info, "payload_json", "{}")
                    import json
                    p_dict = json.loads(raw_payload) if isinstance(raw_payload, str) else raw_payload

                    stored_parent_refs: tuple[ArtifactRef, ...] = ()
                    if getattr(art_info, "envelopeJson", None):
                        try:
                            stored_env = ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                            stored_parent_refs = tuple(stored_env.parent_refs)
                        except Exception:
                            pass
                    if not stored_parent_refs and isinstance(p_dict, dict) and p_dict.get("passageRef") and p_dict.get("blueprintRef") and p_dict.get("questionRefs"):
                        try:
                            stored_parent_refs = tuple(
                                [
                                    ArtifactRef.model_validate(p_dict["passageRef"]),
                                    ArtifactRef.model_validate(p_dict["blueprintRef"]),
                                ]
                                + [ArtifactRef.model_validate(qr) for qr in p_dict["questionRefs"]]
                            )
                        except Exception:
                            pass

                    parents_match_current = (
                        not stored_parent_refs or stored_parent_refs == tuple(all_input_deps)
                    ) and prior_section_envelope is None and template_section_payload is None

                    if parents_match_current:
                        cached_env = ArtifactEnvelope.create(
                            artifact_id=effective_target_id,
                            artifact_type=ArtifactType.SECTION,
                            run_id=run_id,
                            payload=p_dict,
                            producer_version="2.0.0",
                            version=acc_ver,
                            section_id=section_index,
                            parent_refs=all_input_deps,
                            schema_version="2.0.0",
                        )
                        logger.info(f"Resuming already accepted section {effective_target_id} v{acc_ver} ({acc_hash[:8]})")

                        student_payload = to_student_visible_section(cached_env)
                        return LoopResult(
                            runId=run_id,
                            decision=DecisionType.PASS,
                            terminalState=LoopState.COMPLETED,
                            acceptedArtifact=cached_env,
                            terminalReason=f"Resumed already accepted section {effective_target_id}",
                            terminalReasonCode=LoopReason.ACCEPTED,
                            totalIterations=0,
                            versionsCount=1,
                            repairsCount=0,
                            callsCount=0,
                            tokensConsumed=0,
                            wallTimeSeconds=0.0,
                            ledger=IssueLedger(ledgerId=f"led_{run_id}", runId=run_id),
                            latestDecision=LoopDecision(
                                decisionId=f"dec_{uuid4().hex[:8]}",
                                runId=run_id,
                                decision=DecisionType.PASS,
                                currentState=LoopState.EVALUATING,
                                nextState=LoopState.COMPLETED,
                                reason=f"Resumed already accepted section {effective_target_id}",
                                targetScope=IssueScope.SECTION,
                                targetArtifactId=effective_target_id,
                                reasonCode=LoopReason.ACCEPTED,
                            ),
                        )
                    elif prior_section_envelope is None:
                        if getattr(art_info, "envelopeJson", None):
                            try:
                                prior_section_envelope = ArtifactEnvelope.model_validate_json(art_info.envelopeJson)
                            except Exception:
                                pass
                        if prior_section_envelope is None:
                            prior_section_envelope = ArtifactEnvelope.create(
                                artifact_id=effective_target_id,
                                artifact_type=ArtifactType.SECTION,
                                run_id=run_id,
                                payload=p_dict,
                                producer_version="2.0.0",
                                version=acc_ver,
                                section_id=section_index,
                                parent_refs=list(stored_parent_refs) if stored_parent_refs else all_input_deps,
                                schema_version="2.0.0",
                            )
        # 5. Build LoopContext & BoundedLoopRuntime
        authority = AuthorityGrant(leaseOwner=lease_owner, epoch=epoch)
        context = LoopContext(
            runId=run_id,
            scope=IssueScope.SECTION,
            targetArtifactId=effective_target_id,
            targetArtifactType=ArtifactType.SECTION,
            sectionId=section_index,
            authority=authority,
            inputDependencies=tuple(all_input_deps),
            currentArtifact=prior_section_envelope,
            budgetTracker=BudgetTracker(),
            parent_operation_id=parent_operation_id,
        )

        accepted_deps_map = {ref.artifact_id: ref for ref in all_input_deps}
        runtime = BoundedLoopRuntime(
            context=context,
            generator=generator_adapter,
            evaluators=self.evaluators,
            repairer=repairer_adapter,
            persistence_client=self.persistence_client,
            policy=self.policy,
            accepted_dependencies=accepted_deps_map,
        )

        # 6. Execute bounded loop iterations
        loop_result = await runtime.run()

        # 7. Attach StudentVisible payload adapter to final result
        if loop_result.accepted_artifact is not None:
            student_sec = to_student_visible_section(loop_result.accepted_artifact)
            student_dict = student_sec.model_dump(mode="json", by_alias=True)
            assert_student_visible_payload_isolated(student_dict)
            # student visible payload is verified isolated

        return loop_result
