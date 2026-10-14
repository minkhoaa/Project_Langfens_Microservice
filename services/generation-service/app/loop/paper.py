"""Reading Paper Loop Engine for Langfens V2 (Phase 12 / P12-01..P12-06).

Orchestrates full IELTS Academic Reading paper composition:
- Section Loop composition for Sections 1, 2, and 3.
- Full paper assembly and student payload isolation (P12-01).
- Whole-paper quality evaluations: structure, 40-question numbering, cross-section
  shingle overlap <= 0.45, prompt uniqueness, and answer leakage (P12-02, P12-03).
- Scoped paper-level repairs with exact closure invalidation (P12-05).
- Integration with authoritative persistence client and BoundedLoopRuntime.
"""

from __future__ import annotations

from collections.abc import Mapping
import logging
import hashlib
from typing import Any, Dict, List, Optional, Sequence, Union
from uuid import UUID, uuid4

from app.config import settings
from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.contracts.blueprint import QuestionType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueLedger, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.contracts.paper import (
    AuthoringPaperResult,
    PaperStatus,
    ReadingPaperPayload,
    ReadingPaperSnapshot,
    StudentVisibleReadingPaper,
    assemble_immutable_paper,
    assert_student_visible_paper_isolated,
    to_student_visible_paper,
)
from app.contracts.policies import (
    PAPER_MAX_WORDS,
    PAPER_MIN_WORDS,
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    count_words,
)
from app.contracts.section import SectionPayload, SectionSnapshot
from app.evaluators.base import BaseEvaluator
from app.evaluators.paper import (
    PaperCrossSectionEvaluator,
    PaperLeakageEvaluator,
    PaperMonotonyEvaluator,
    PaperStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.loop.capabilities import GeneratorCapability, RepairerCapability
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.journal import OperationIntent, StepJournal
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.loop.section import SectionLoop
from app.persistence.client import CheckpointClient
from app.persistence.models import (
    CheckpointCommitRequest,
    DraftCheckpointRequest,
    LoopCursorCheckpointRequest,
    OperationGrantRequest,
    OperationReconcileRequest,
)
from app.repair.paper import (
    PaperRepairActionType,
    PaperRepairDirective,
    PaperRepairResult,
    PaperRepairRoute,
    PaperRepairRouter,
    PaperSurgicalRepairer,
)

logger = logging.getLogger(__name__)

# Section artifact ids are minted in two shapes across the codebase: the canonical
# `art_section_s{index}` produced by `app/contracts/section.py` and `app/loop/section.py`,
# and the `art_section_{index}` fallback synthesised by `app/contracts/paper.py` when a
# paper is assembled from bare payloads. Both exist in live runs, so a head lookup that
# keys on only one of them silently misses and strands the caller on a stale snapshot.
# Resolution therefore accepts either shape rather than branching on a specific id.


def _canonical_section_artifact_id(section_index: int) -> str:
    """The canonical section artifact id for a 1-based section index."""
    return f"art_section_s{section_index}"


def _section_head_candidates(section_envelope: ArtifactEnvelope, section_index: int) -> List[str]:
    """Every artifact id under which this section's accepted head may be recorded.

    Ordered by authority: the envelope's own id first (it is what the caller holds),
    then the canonical id for the slot. Returns a de-duplicated list.
    """
    candidates = [section_envelope.artifact_id, _canonical_section_artifact_id(section_index)]
    seen: List[str] = []
    for candidate in candidates:
        if candidate not in seen:
            seen.append(candidate)
    return seen


def _resolve_live_paper_sections(
    run_id: str,
    sections: List[Any],
    persistence_client: Optional[CheckpointClient],
) -> List[Any]:
    """Rebind every section to its ACCEPTED HEAD immediately before assembly.

    Case 13 of `camp_G15_dde0f9bd38d4` terminated with a truthful
    `INVALID_OUTPUT` because the paper was assembled from the snapshot captured
    before the section sub-loops ran: it named section 2 at v1 while the accepted
    head had already advanced to v3. RC-7's `_deps_resyncable_only` correctly
    refuses a dependency that moves backwards in an append-only chain, so the
    rejection was RIGHT and the producer was wrong. Nothing here relaxes that guard.

    The fix is producer-side and general. The previous code resolved live heads only
    when `version > 1`, so the FIRST draft -- the one this campaign failed on -- was
    built from the stale snapshot. Resolution now happens for every version, for
    both the declared `input_dependencies` and the generator, so the two sides of
    the strict-closure check read the same head instead of disagreeing by
    construction.

    This is a pure READ of `resume_state`. CAS, fencing and epoch checks live on the
    commit path, which this code never touches, so no lease semantics change.

    Fail-closed. Recovery must never degrade into "accept anything", so anything the
    store contradicts raises, and the runtime maps the failure to `INVALID_OUTPUT`:

    * a recorded head that is marked stale is NOT an accepted head;
    * a recorded head whose version is BEHIND the declared one is a chain regression;
    * a same-version head with a different content hash is an impossible mutation of
      an immutable chain;
    * a head the store reports but cannot hand back (no envelope) is unresolvable,
      and falling back to the caller's snapshot here would re-create case 13.

    A section the store knows NOTHING about is left untouched: that is a legitimate
    not-yet-committed section, and the authoritative commit boundary still refuses
    any paper whose parent has no accepted head.
    """
    if persistence_client is None or not hasattr(persistence_client, "resume_state"):
        return sections
    try:
        res_state = persistence_client.resume_state(run_id)
    except Exception:
        logger.debug(
            "paper head resolution: resume_state unavailable; using declared sections",
            exc_info=True,
        )
        return sections

    artifacts_by_id = {
        getattr(a, "artifactId", getattr(a, "artifact_id", "")): a
        for a in (getattr(res_state, "artifacts", None) or [])
    }

    refreshed: List[Any] = []
    for idx, sec in enumerate(sections, start=1):
        candidates = [
            artifacts_by_id.get(candidate_id)
            for candidate_id in _section_head_candidates(sec, idx)
        ]
        present = [c for c in candidates if c is not None]
        if not present:
            refreshed.append(sec)
            continue

        head_info = next(
            (c for c in present if not bool(getattr(c, "isStale", False))), None
        )
        if head_info is None:
            raise ValueError(
                f"section {idx} ({sec.artifact_id}) has no accepted head: every recorded "
                "version is marked stale, so the paper cannot be strictly closed"
            )

        head_version = int(getattr(head_info, "acceptedVersion", 0) or 0)
        head_hash = str(getattr(head_info, "acceptedHash", "") or "")
        declared_version = int(getattr(sec, "version", 0) or 0)
        declared_hash = str(getattr(sec, "content_hash", "") or "")

        if head_version < declared_version:
            raise ValueError(
                f"section {idx} accepted head v{head_version} is behind the declared "
                f"v{declared_version}: the chain regressed"
            )
        if head_version == declared_version and head_hash:
            if head_hash.lower() != declared_hash.lower():
                raise ValueError(
                    f"section {idx} v{head_version} carries a different content hash than "
                    "the declared envelope: impossible mutation of an immutable chain"
                )

        envelope_json = getattr(head_info, "envelopeJson", None)
        if not envelope_json:
            raise ValueError(
                f"section {idx} head v{head_version} is unresolvable: the store reports "
                "no envelope, so binding it would emit a stale reference"
            )
        try:
            head_envelope = ArtifactEnvelope.model_validate_json(envelope_json)
        except Exception as error:
            raise ValueError(
                f"section {idx} head v{head_version} envelope is unreadable: {error}"
            ) from error
        if int(head_envelope.version) < declared_version:
            raise ValueError(
                f"section {idx} head envelope v{head_envelope.version} is behind the "
                f"declared v{declared_version}"
            )
        refreshed.append(head_envelope)
    return refreshed


def _fail_closed_paper_result(run_id: str, target_art_id: str, reason: str) -> LoopResult:
    """A truthful fail-closed terminal for a chain that cannot be strictly closed.

    The paper loop must not emit a paper whose parents it cannot verify, but it must
    also not lose the reason: the caller (and the campaign report) reads the terminal
    to attribute the failure. Returning this instead of raising keeps `INVALID_OUTPUT`
    attached to the actual defect -- a regressed chain, a stale-only record, or an
    unresolvable head -- rather than surfacing as an opaque exception at the facade.
    """
    from app.contracts.issue import IssueLedger

    decision = LoopDecision(
        decisionId=f"dec_{uuid4().hex[:12]}",
        runId=run_id,
        decision=DecisionType.FAIL,
        currentState=LoopState.DRAFTING,
        nextState=LoopState.FAILED,
        reason=reason,
        reasonCode=LoopReason.INVALID_OUTPUT,
        targetScope=IssueScope.PAPER,
        targetArtifactId=target_art_id,
    )
    return LoopResult(
        runId=run_id,
        decision=DecisionType.FAIL,
        terminalState=LoopState.FAILED,
        acceptedArtifact=None,
        terminalReason=reason,
        terminalReasonCode=LoopReason.INVALID_OUTPUT,
        ledger=IssueLedger(ledgerId=f"led_{run_id}", runId=run_id),
        latestDecision=decision,
    )


class PaperGeneratorAdapter(GeneratorCapability):
    """Adapts 3-section reading paper assembly to BoundedLoopRuntime."""

    def __init__(
        self,
        paper_id: str,
        title: str,
        blueprint_ref: ArtifactRef,
        section_envelopes: List[ArtifactEnvelope],
        persistence_client: Optional[CheckpointClient] = None,
        accepted_dependencies: Optional[Dict[str, ArtifactRef]] = None,
    ):
        self.paper_id = paper_id
        self.title = title
        self.blueprint_ref = blueprint_ref
        self.section_envelopes = section_envelopes
        self.persistence_client = persistence_client
        self.accepted_dependencies = accepted_dependencies

    @property
    def name(self) -> str:
        return "ReadingPaperAssemblyGenerator"

    @property
    def version(self) -> str:
        return "2.0.0"

    def _resolve_current_sections(self, context: LoopContext) -> List[Any]:
        return _resolve_live_paper_sections(
            context.run_id, self.section_envelopes, self.persistence_client,
        )

    async def generate(self, context: LoopContext, intent_id: str, version: int = 1) -> ArtifactEnvelope:
        # Resolve for EVERY version, including the first draft. Gating this on
        # `version > 1` is what let case 13 assemble a paper from the pre-loop
        # snapshot and bind a section head that had already moved forward.
        sections_to_use = self._resolve_current_sections(context)
        envelope = assemble_immutable_paper(
            sections=sections_to_use,
            blueprint_ref=self.blueprint_ref,
            run_id=context.run_id,
            paper_id=self.paper_id,
            title=self.title,
            version=version,
            evaluations_summary={"assembledAtIntent": intent_id},
        )
        return envelope

    async def generate_draft(self, context: LoopContext, intent_id: str) -> ArtifactEnvelope:
        return await self.generate(context, intent_id, 1)


class PaperRepairerAdapter(RepairerCapability):
    """Adapts PaperSurgicalRepairer to BoundedLoopRuntime."""

    def __init__(
        self,
        repairer: PaperSurgicalRepairer,
        router: PaperRepairRouter,
        persistence_client: Optional[CheckpointClient] = None,
        accepted_dependencies: Optional[Dict[str, ArtifactRef]] = None,
        generator: Optional["PaperGeneratorAdapter"] = None,
    ):
        self.repairer = repairer
        self.router = router
        self.persistence_client = persistence_client
        self.accepted_dependencies = accepted_dependencies
        self.generator = generator
    @property
    def repairer_id(self) -> str:
        return "PaperSurgicalRepairer"

    @property
    def repairer_version(self) -> str:
        return "2.0.0"

    async def repair(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int = 2,
    ) -> ArtifactEnvelope:
        route = self.router.route_repair(artifact, issues)
        target_sec_id = route.target_section_ids[0] if route.target_section_ids else 1
        target_q_num = route.target_question_numbers[0] if route.target_question_numbers else None
        patch_payload: Optional[Dict[str, Any]] = None
        question_patches: Dict[int, Dict[str, Any]] = {}

        import re
        raw_sections = artifact.payload.get("sections", []) if isinstance(artifact.payload, Mapping) else []
        q_by_num: Dict[int, Dict[str, Any]] = {}
        for sec in raw_sections:
            s_dict = dict(sec) if isinstance(sec, Mapping) else {}
            for grp in s_dict.get("groups", []):
                g_dict = dict(grp) if isinstance(grp, Mapping) else {}
                for q in g_dict.get("questions", []):
                    q_dict = dict(q) if isinstance(q, Mapping) else {}
                    qn = q_dict.get("questionNumber") or q_dict.get("number")
                    if qn is not None:
                        q_by_num[int(qn)] = q_dict

        for iss in issues:
            if iss.code == IssueCode.ANSWER_LEAKAGE:
                m = re.search(
                    r"Question (\d+) prompt(?: [^']*)? leaks answer '([^']+)'(?: for Question (\d+))?",
                    iss.message,
                )
                if not m:
                    m = re.search(
                        r"Question (\d+) prompt verbatim reveals (?:its own expected )?answer '([^']+)'",
                        iss.message,
                    )
                if m:
                    leaking_q_num = int(m.group(1))
                    leaked_ans = m.group(2)
                    other_q_num = int(m.group(3)) if (m.lastindex and m.lastindex >= 3 and m.group(3)) else None
                    for sec in raw_sections:
                        s_dict = dict(sec) if isinstance(sec, Mapping) else {}
                        for grp in s_dict.get("groups", []):
                            g_dict = dict(grp) if isinstance(grp, Mapping) else {}
                            for q in g_dict.get("questions", []):
                                q_dict = dict(q) if isinstance(q, Mapping) else {}
                                q_num = q_dict.get("questionNumber") or q_dict.get("number")
                                if q_num == leaking_q_num:
                                    target_q_num = leaking_q_num
                                    target_sec_id = s_dict.get("sectionId", target_sec_id)
                                    curr_prompt = (
                                        question_patches.get(leaking_q_num, {}).get("prompt")
                                        or q_dict.get("prompt")
                                        or q_dict.get("statement")
                                        or ""
                                    )
                                    new_prompt = re.sub(
                                        re.escape(leaked_ans),
                                        "the relevant formulation",
                                        curr_prompt,
                                        flags=re.IGNORECASE,
                                    )
                                    if "intra-section evidence" in iss.message and other_q_num in q_by_num:
                                        other_quote = str(
                                            q_by_num[other_q_num].get("evidenceQuote")
                                            or q_by_num[other_q_num].get("evidence")
                                            or ""
                                        ).strip()
                                        if other_quote:
                                            new_prompt = re.sub(
                                                re.escape(other_quote),
                                                "the documented observation",
                                                new_prompt,
                                                flags=re.IGNORECASE,
                                            )
                                    if new_prompt == curr_prompt:
                                        for tok in leaked_ans.split():
                                            if len(tok) >= 3:
                                                new_prompt = re.sub(
                                                    r"(?<![\w'-])" + re.escape(tok) + r"(?![\w'-])",
                                                    "relevant",
                                                    new_prompt,
                                                    flags=re.IGNORECASE,
                                                )
                                    q_patch: Dict[str, Any] = {"prompt": new_prompt, "statement": new_prompt}
                                    question_patches[leaking_q_num] = q_patch
                                    break
            elif iss.code == IssueCode.DUPLICATE_CONTENT and "Question " in iss.message:
                m = re.search(r"Question (\d+)", iss.message)
                if m:
                    dup_q_num = int(m.group(1))
                    target_q_num = dup_q_num
                    question_patches[dup_q_num] = {
                        "prompt": f"According to the passage, what key detail is demonstrated regarding the subject in question {dup_q_num}?"
                    }

        if not question_patches and not patch_payload:
            patch_payload = {"prompt": "According to the passage, which statement accurately reflects the author's argument?"}

        directive = PaperRepairDirective(
            affectedRefs=[artifact.to_ref()],
            issues=list(issues),
            targetSectionId=target_sec_id,
            targetQuestionNumber=target_q_num,
            patchPayload=patch_payload,
            questionPatches=question_patches,
        )
        repair_result = self.repairer.repair_paper(artifact, directive)

        if self.persistence_client is not None and context is not None:
            from app.evaluators.deterministic import (
                AnswerVerbatimAndLengthEvaluator,
                QuestionStructureEvaluator,
            )
            from app.evaluators.coverage import SectionCoverageEvaluator
            from app.evaluators.section import (
                SectionDuplicateAndConcentrationEvaluator,
                SectionStructureEvaluator,
            )
            from app.generators.question.generator import QuestionCandidateGenerator
            from app.loop.question import QuestionCandidateLoop
            from app.loop.section import SectionLoop
            from app.repair.question import unwrap_payload

            run_id = context.run_id
            epoch = getattr(context.authority, "epoch", 1)
            lease_owner = getattr(context.authority, "lease_owner", None)
            lease_owner_uuid = (
                lease_owner
                if isinstance(lease_owner, UUID)
                else (UUID(str(lease_owner)) if lease_owner else uuid4())
            )

            if hasattr(self.persistence_client, "resume_state"):
                q_loop = QuestionCandidateLoop(
                    generator=QuestionCandidateGenerator(),
                    persistence_client=self.persistence_client,
                )
                sec_loop = SectionLoop(
                    persistence_client=self.persistence_client,
                    evaluators=[
                        # The paper loop computes the section's coverage summary from
                        # the durable child evaluation ledger before re-running the
                        # section loop (see sec_summary below), so it is the layer that
                        # owns and enforces the fresh solver/adversary guarantee.
                        SectionCoverageEvaluator(required=True),
                        SectionStructureEvaluator(),
                        SectionDuplicateAndConcentrationEvaluator(),
                    ],
                )
                accepted_q_by_id: Dict[str, ArtifactEnvelope] = {}
                accepted_sec_by_idx: Dict[int, ArtifactEnvelope] = {}
                orig_sec_refs = [
                    ArtifactRef.model_validate(sr)
                    for sr in (artifact.payload.get("sectionRefs") or [])
                ]
                orig_q_refs_by_id = {
                    ArtifactRef.model_validate(qr).artifact_id: ArtifactRef.model_validate(qr)
                    for qr in (artifact.payload.get("questionRefs") or [])
                }
                for q_env in repair_result.replacement_question_envelopes:
                    sec_idx = q_env.section_id or 1
                    sec_raw = (
                        unwrap_payload(raw_sections[sec_idx - 1])
                        if 0 <= sec_idx - 1 < len(raw_sections)
                        else {}
                    )
                    sec_pass_text = str(sec_raw.get("passage") or "")
                    p_ref = next(
                        (r for r in q_env.parent_refs if r.artifact_type == ArtifactType.PASSAGE),
                        q_env.parent_refs[0],
                    )
                    bp_ref = next(
                        (r for r in q_env.parent_refs if r.artifact_type == ArtifactType.EXAM_BLUEPRINT),
                        q_env.parent_refs[-1],
                    )
                    q_num_val = int(
                        q_env.payload.get("questionNumber") or q_env.payload.get("number") or 1
                    )
                    orig_q_payload = dict(q_by_num.get(q_num_val) or q_env.payload)
                    orig_q_ref = orig_q_refs_by_id.get(q_env.artifact_id)
                    orig_q_env = ArtifactEnvelope(
                        artifactId=q_env.artifact_id,
                        artifactType=ArtifactType.QUESTION,
                        version=orig_q_ref.version if orig_q_ref else max(1, q_env.version - 1),
                        runId=run_id,
                        sectionId=sec_idx,
                        schemaVersion="2.0.0",
                        contentHash=(
                            orig_q_ref.content_hash
                            if orig_q_ref
                            else compute_content_hash(orig_q_payload, [p_ref, bp_ref])
                        ),
                        createdAt=q_env.created_at,
                        producerVersion="2.0.0",
                        payload=orig_q_payload,
                        parentRefs=(p_ref, bp_ref),
                    )
                    q_res = await q_loop.repair_question_artifact(
                        question_envelope=orig_q_env,
                        passage_ref=p_ref,
                        blueprint_ref=bp_ref,
                        passage_text=sec_pass_text,
                        issues=list(issues),
                        run_id=run_id,
                        lease_owner=lease_owner_uuid,
                        epoch=epoch,
                        section_index=sec_idx,
                        parent_operation_id=intent_id,
                        patched_payload=unwrap_payload(q_env.payload),
                    )
                    if q_res.decision != DecisionType.PASS or q_res.accepted_artifact is None:
                        raise ValueError(
                            f"Question loop failed to accept repaired question {q_env.artifact_id}: {q_res.terminal_reason}"
                        )
                    accepted_q_by_id[q_res.accepted_artifact.artifact_id] = q_res.accepted_artifact
                    if self.accepted_dependencies is not None:
                        self.accepted_dependencies[q_res.accepted_artifact.artifact_id] = (
                            q_res.accepted_artifact.to_ref()
                        )

                for sec_env in repair_result.replacement_section_envelopes:
                    sec_idx = sec_env.section_id or 1
                    sec_raw_orig = (
                        unwrap_payload(raw_sections[sec_idx - 1])
                        if 0 <= sec_idx - 1 < len(raw_sections)
                        else unwrap_payload(sec_env.payload)
                    )
                    orig_sec_ref = (
                        orig_sec_refs[sec_idx - 1]
                        if 0 <= sec_idx - 1 < len(orig_sec_refs)
                        else None
                    )
                    p_ref = next(
                        (r for r in sec_env.parent_refs if r.artifact_type == ArtifactType.PASSAGE),
                        sec_env.parent_refs[0],
                    )
                    bp_ref = next(
                        (r for r in sec_env.parent_refs if r.artifact_type == ArtifactType.EXAM_BLUEPRINT),
                        sec_env.parent_refs[1],
                    )
                    sec_pass_text = str(sec_env.payload.get("passage") or "")
                    passage_env = ArtifactEnvelope(
                        artifactId=p_ref.artifact_id,
                        artifactType=ArtifactType.PASSAGE,
                        version=p_ref.version,
                        runId=run_id,
                        sectionId=sec_idx,
                        schemaVersion="2.0.0",
                        contentHash=p_ref.content_hash,
                        createdAt=sec_env.created_at,
                        producerVersion="2.0.0",
                        payload={"text": sec_pass_text, "passage": sec_pass_text, "wordCount": count_words(sec_pass_text)},
                        parentRefs=(bp_ref,),
                    )
                    orig_sec_q_refs = [
                        ArtifactRef.model_validate(qr)
                        for qr in (sec_raw_orig.get("questionRefs") or [])
                    ]
                    prior_sec_env = ArtifactEnvelope(
                        artifactId=sec_env.artifact_id,
                        artifactType=ArtifactType.SECTION,
                        version=orig_sec_ref.version if orig_sec_ref else max(1, sec_env.version - 1),
                        runId=run_id,
                        sectionId=sec_idx,
                        schemaVersion="2.0.0",
                        contentHash=(
                            orig_sec_ref.content_hash
                            if orig_sec_ref
                            else compute_content_hash(sec_raw_orig, [p_ref, bp_ref] + orig_sec_q_refs)
                        ),
                        createdAt=sec_env.created_at,
                        producerVersion="2.0.0",
                        payload=sec_raw_orig,
                        parentRefs=tuple([p_ref, bp_ref] + orig_sec_q_refs),
                    )
                    sec_q_envs = [
                        q for q in accepted_q_by_id.values() if (q.section_id or 1) == sec_idx
                    ]
                    orig_summary = sec_raw_orig.get("evaluationsSummary") or sec_raw_orig.get("evaluations_summary")
                    sec_summary = dict(orig_summary) if isinstance(orig_summary, Mapping) else {}

                    repaired_q_map = {q.artifact_id: q.to_ref() for q in sec_q_envs}
                    sec_child_refs = [p_ref] + [
                        repaired_q_map.get(qr.artifact_id, qr) for qr in orig_sec_q_refs
                    ]

                    res_state_obj = self.persistence_client.resume_state(run_id)
                    res_evals = getattr(res_state_obj, "evaluations", None) or []
                    res_artifacts = {
                        getattr(a, "artifactId", getattr(a, "artifact_id", "")): a
                        for a in (getattr(res_state_obj, "artifacts", None) or [])
                    }

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
                    has_stale_child = False
                    matching_pass_eval_ids: List[str] = []
                    solver_found = False
                    adversary_found = False

                    for dep_ref in sec_child_refs:
                        acc_ref = (
                            self.accepted_dependencies.get(dep_ref.artifact_id)
                            if self.accepted_dependencies is not None
                            else None
                        )
                        if acc_ref is not None and (
                            acc_ref.version != dep_ref.version
                            or acc_ref.content_hash.lower() != dep_ref.content_hash.lower()
                        ):
                            has_stale_child = True
                        art_info = res_artifacts.get(dep_ref.artifact_id)
                        if art_info is not None and getattr(art_info, "isStale", False):
                            has_stale_child = True

                        expected_deps = (
                            {p_ref, bp_ref}
                            if dep_ref.artifact_type == ArtifactType.QUESTION
                            else {bp_ref}
                        )

                        def _deps_match(ev: Any) -> bool:
                            ev_dep_set = _ev_deps(ev)
                            return ev_dep_set == expected_deps

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
                                    matching_pass_eval_ids.append(eid)
                                ev_id_lower = _ev_evaluator(ev).lower()
                                if "solver" in ev_id_lower:
                                    solver_found = True
                                if "adversary" in ev_id_lower:
                                    adversary_found = True

                    sec_summary["acceptedEvaluationRefs"] = list(dict.fromkeys(matching_pass_eval_ids))
                    sec_summary["solverCovered"] = bool(solver_found)
                    sec_summary["adversaryCovered"] = bool(adversary_found)
                    sec_summary["freshEvaluations"] = (
                        all_children_have_fresh_pass
                        and not has_stale_child
                        and bool(matching_pass_eval_ids)
                        and solver_found
                        and adversary_found
                    )
                    sec_summary["hasStaleDependencies"] = has_stale_child or not all_children_have_fresh_pass

                    sec_template = dict(unwrap_payload(sec_env.payload))
                    sec_template["evaluationsSummary"] = sec_summary
                    sec_res = await sec_loop.run(
                        section_index=sec_idx,
                        title=str(sec_env.payload.get("title") or f"Section {sec_idx}"),
                        passage_artifact=passage_env,
                        blueprint_ref=bp_ref,
                        question_artifacts=sec_q_envs,
                        run_id=run_id,
                        lease_owner=lease_owner_uuid,
                        epoch=epoch,
                        target_artifact_id=sec_env.artifact_id,
                        template_section_payload=sec_template,
                        prior_section_envelope=prior_sec_env,
                        parent_operation_id=intent_id,
                    )
                    if sec_res.decision != DecisionType.PASS or sec_res.accepted_artifact is None:
                        raise ValueError(
                            f"Section loop failed to accept repaired section {sec_env.artifact_id}: {sec_res.terminal_reason}"
                        )
                    accepted_sec_by_idx[sec_idx] = sec_res.accepted_artifact
                    if self.accepted_dependencies is not None:
                        self.accepted_dependencies[sec_res.accepted_artifact.artifact_id] = (
                            sec_res.accepted_artifact.to_ref()
                        )
                if accepted_sec_by_idx:
                    bp_ref_paper = ArtifactRef.model_validate(artifact.payload["blueprintRef"])
                    final_sections: List[Any] = []
                    for idx, raw_s in enumerate(raw_sections):
                        s_num = idx + 1
                        if s_num in accepted_sec_by_idx:
                            final_sections.append(accepted_sec_by_idx[s_num])
                        else:
                            orig_sr = orig_sec_refs[idx]
                            final_sections.append({
                                **unwrap_payload(raw_s),
                                "__artifactId": orig_sr.artifact_id,
                                "__version": orig_sr.version,
                                "__contentHash": orig_sr.content_hash,
                            })
                    rebuilt_paper = assemble_immutable_paper(
                        sections=final_sections,
                        blueprint_ref=bp_ref_paper,
                        run_id=run_id,
                        paper_id=artifact.payload.get("paperId"),
                        title=artifact.payload.get("title"),
                        version=version,
                        evaluations_summary={"repairedAt": directive.directive_id},
                    )
                    repair_result = repair_result.model_copy(
                        update={"repaired_envelope": rebuilt_paper}
                    )
                    if self.generator is not None and accepted_sec_by_idx:
                        self.generator.section_envelopes = [
                            accepted_sec_by_idx.get(idx + 1, self.generator.section_envelopes[idx])
                            for idx in range(len(self.generator.section_envelopes))
                        ]
            else:
                q_evaluators = [QuestionStructureEvaluator(), AnswerVerbatimAndLengthEvaluator()]
                sec_evaluators = [
                    SectionCoverageEvaluator(),
                    SectionStructureEvaluator(),
                    SectionDuplicateAndConcentrationEvaluator(),
                ]

                async def _evaluate_and_commit_child(
                    child_env: ArtifactEnvelope,
                    op_type: str,
                    scope: IssueScope,
                    eval_list: Sequence[BaseEvaluator],
                ) -> None:
                    child_ctx = LoopContext(
                        runId=run_id,
                        scope=scope,
                        targetArtifactId=child_env.artifact_id,
                        targetArtifactType=child_env.artifact_type,
                        sectionId=child_env.section_id,
                        authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
                        inputDependencies=child_env.parent_refs,
                        budgetTracker=BudgetTracker(),
                        parentOperationId=intent_id,
                    )
                    eval_results: List[EvaluationResult] = []
                    for ev in eval_list:
                        ev_res = await ev.evaluate(
                            child_ctx,
                            child_env,
                            intent_id=f"eval_{child_env.artifact_id}_v{child_env.version}_{ev.evaluator_id}",
                        )
                        if ev_res.status != EvaluationStatus.PASS:
                            raise ValueError(
                                f"Evaluator {ev.evaluator_id} rejected replacement {child_env.artifact_id}"
                            )
                        eval_results.append(ev_res)
                    dec = LoopDecision(
                        decisionId=f"dec_{uuid4().hex[:12]}",
                        runId=run_id,
                        decision=DecisionType.PASS,
                        currentState=LoopState.EVALUATING,
                        nextState=LoopState.COMPLETED,
                        reason="ACCEPTED: all required evaluations PASS on fresh dependencies; no open blockers",
                        reasonCode=LoopReason.ACCEPTED,
                        targetScope=scope,
                        targetArtifactId=child_env.artifact_id,
                        expectedVersion=child_env.version,
                        evaluationRef=eval_results[0].evaluation_id if eval_results else None,
                    )
                    op_id = f"op_paper_rep_{child_env.artifact_id}_v{child_env.version}_{child_env.content_hash[:8]}"
                    req_hash = hashlib.sha256(
                        f"{run_id}:{op_id}:{child_env.content_hash}".encode("utf-8")
                    ).hexdigest()
                    self.persistence_client.grant_operation(
                        OperationGrantRequest(
                            runId=run_id,
                            epoch=epoch,
                            leaseOwner=lease_owner,
                            operationId=op_id,
                            operationType=op_type,
                            requestHash=req_hash,
                            tokenReservation=0,
                            wallTimeReservationSeconds=5.0,
                            sectionId=str(child_env.section_id) if child_env.section_id is not None else None,
                            artifactId=child_env.artifact_id,
                            parentOperationId=intent_id,
                        )
                    )
                    self.persistence_client.commit_checkpoint(
                        CheckpointCommitRequest(
                            runId=run_id,
                            epoch=epoch,
                            leaseOwner=lease_owner,
                            operationId=op_id,
                            requestHash=req_hash,
                            artifact=child_env,
                            evaluations=eval_results,
                            decision=dec,
                            expectedHeadVersion=max(1, child_env.version - 1),
                        )
                    )

                for q_env in repair_result.replacement_question_envelopes:
                    await _evaluate_and_commit_child(
                        q_env, "GENERATE_QUESTION", IssueScope.QUESTION, q_evaluators
                    )
                    if self.accepted_dependencies is not None:
                        self.accepted_dependencies[q_env.artifact_id] = q_env.to_ref()
                for sec_env in repair_result.replacement_section_envelopes:
                    await _evaluate_and_commit_child(
                        sec_env, "GENERATE_SECTION", IssueScope.SECTION, sec_evaluators
                    )
                    if self.accepted_dependencies is not None:
                        self.accepted_dependencies[sec_env.artifact_id] = sec_env.to_ref()
        elif self.accepted_dependencies is not None:
            for q_env in repair_result.replacement_question_envelopes:
                self.accepted_dependencies[q_env.artifact_id] = q_env.to_ref()
            for sec_env in repair_result.replacement_section_envelopes:
                self.accepted_dependencies[sec_env.artifact_id] = sec_env.to_ref()

        if context is not None:
            context.input_dependencies = tuple(repair_result.repaired_envelope.parent_refs)

        return repair_result.repaired_envelope

    async def execute_repair(
        self,
        context: LoopContext,
        target_artifact: ArtifactEnvelope,
        open_issues: Sequence[Issue],
        intent_id: str,
    ) -> ArtifactEnvelope:
        return await self.repair(context, target_artifact, open_issues, intent_id, 2)
# ── PaperLoop Controller ─────────────────────────────────────────────────────


class PaperLoop:
    """Full Reading Paper Loop Engine."""

    def __init__(
        self,
        persistence_client: Optional[CheckpointClient] = None,
        evaluator_registry: Optional[EvaluatorRegistry] = None,
        repair_router: Optional[PaperRepairRouter] = None,
        repairer: Optional[PaperSurgicalRepairer] = None,
        policy: Optional[LoopPolicy] = None,
        is_benchmark: bool = False,
    ):
        self.persistence_client = persistence_client
        self.repair_router = repair_router or PaperRepairRouter()
        self.repairer = repairer or PaperSurgicalRepairer()
        self._explicit_policy = policy is not None
        self.is_benchmark = is_benchmark
        self.policy = policy or LoopPolicy.from_settings(is_benchmark=is_benchmark)

        # Register default paper evaluators
        if evaluator_registry is None:
            reg = EvaluatorRegistry()
            reg.register(PaperStructureEvaluator(timeout_seconds=self.policy.evaluator_stage_timeout_seconds))
            reg.register(PaperCrossSectionEvaluator(timeout_seconds=self.policy.evaluator_stage_timeout_seconds))
            reg.register(PaperLeakageEvaluator(timeout_seconds=self.policy.evaluator_stage_timeout_seconds))
            reg.register(PaperMonotonyEvaluator(timeout_seconds=self.policy.evaluator_stage_timeout_seconds))
            self.evaluator_registry = reg
        else:
            self.evaluator_registry = evaluator_registry

    async def run(
        self,
        run_id: str,
        blueprint_ref: ArtifactRef,
        section_envelopes: List[ArtifactEnvelope],
        title: Optional[str] = None,
        paper_id: Optional[str] = None,
        parent_operation_id: Optional[str] = None,
        owner: Optional[str] = None,
        epoch: int = 1,
        is_benchmark: Optional[bool] = None,
    ) -> LoopResult:
        p_id = paper_id or "paper_" + hashlib.sha256(run_id.encode("utf-8")).hexdigest()[:24]
        target_art_id = f"art_paper_{p_id}"
        p_title = title or "IELTS Academic Reading Paper"
        lease_owner = owner or str(uuid4())

        # Extract exact parent refs matching assemble_immutable_paper parent_refs.
        # The declared deps MUST be the same accepted heads the generator will bind,
        # otherwise the runtime's admission check compares the live chain against the
        # caller's stale snapshot and reports a truthful-but-avoidable INVALID_OUTPUT
        # (case 13). Resolve both sides from the same durable head.
        try:
            resolved_sections = _resolve_live_paper_sections(
                run_id, section_envelopes, self.persistence_client,
            )
        except ValueError as error:
            # Strict closure wins: a paper whose parents cannot be verified is never
            # emitted. The reason is preserved on the terminal so the failure stays
            # truthfully attributed instead of surfacing as an opaque exception.
            return _fail_closed_paper_result(
                run_id, target_art_id, f"INVALID_OUTPUT: {error}",
            )

        sec_refs = [s.to_ref() for s in resolved_sections]
        passage_refs: List[ArtifactRef] = []
        for s in resolved_sections:
            if isinstance(s.payload, SectionPayload):
                passage_refs.append(s.payload.passage_ref)
            elif isinstance(s.payload, (dict, Mapping)) and s.payload.get("passageRef"):
                passage_refs.append(ArtifactRef.model_validate(s.payload["passageRef"]))
            else:
                p_ref = next((r for r in s.parent_refs if r.artifact_type == ArtifactType.PASSAGE), None)
                if p_ref is None:
                    raise ValueError(f"Section envelope '{s.artifact_id}' missing passageRef in payload and parent_refs")
                passage_refs.append(p_ref)

        question_refs: List[ArtifactRef] = []
        for s in resolved_sections:
            if isinstance(s.payload, SectionPayload):
                question_refs.extend(s.payload.question_refs)
            elif isinstance(s.payload, (dict, Mapping)) and s.payload.get("questionRefs") is not None:
                question_refs.extend([ArtifactRef.model_validate(qr) for qr in s.payload["questionRefs"]])
            else:
                q_refs = [r for r in s.parent_refs if r.artifact_type == ArtifactType.QUESTION]
                question_refs.extend(q_refs)
        input_deps = [blueprint_ref] + sec_refs + passage_refs + question_refs
        context = LoopContext(
            runId=run_id,
            scope=IssueScope.PAPER,
            targetArtifactId=target_art_id,
            targetArtifactType=ArtifactType.READING_PAPER,
            authority=AuthorityGrant(leaseOwner=lease_owner, epoch=epoch),
            budgetTracker=BudgetTracker(),
            inputDependencies=input_deps,
            parentOperationId=parent_operation_id,
        )
        generator = PaperGeneratorAdapter(
            paper_id=p_id,
            title=p_title,
            blueprint_ref=blueprint_ref,
            section_envelopes=resolved_sections,
            persistence_client=self.persistence_client,
        )

        repairer_adapter = PaperRepairerAdapter(
            self.repairer,
            self.repair_router,
            persistence_client=self.persistence_client,
            generator=generator,
        )
        evaluators = self.evaluator_registry.resolve_pipeline(ArtifactType.READING_PAPER)
        required_ids = tuple(
            e.evaluator_id for e in evaluators
            if getattr(getattr(e, "metadata", None), "required", True)
        )
        effective_benchmark = (
            is_benchmark is True
            or (is_benchmark is None and (self.is_benchmark or run_id.lower().startswith("bench_")))
        )
        base_policy = self.policy
        if effective_benchmark and not self._explicit_policy:
            base_policy = LoopPolicy.from_settings(is_benchmark=True)

        policy = base_policy.model_copy(update={"required_evaluator_ids": required_ids})
        if self.persistence_client is not None:
            accepted_deps: Dict[str, ArtifactRef] = {}
            res_state = self.persistence_client.resume_state(run_id)
            for art in (res_state.artifacts or []):
                if not art.isStale:
                    accepted_deps[art.artifactId] = ArtifactRef(
                        artifactId=art.artifactId, artifactType=art.artifactType,
                        version=art.acceptedVersion, contentHash=art.acceptedHash,
                    )

            repairer_adapter.accepted_dependencies = accepted_deps
            runtime = BoundedLoopRuntime(
                context=context,
                policy=policy,
                generator=generator,
                evaluators=evaluators,
                repairer=repairer_adapter,
                persistence_client=self.persistence_client,
                accepted_dependencies=accepted_deps,
            )
            return await runtime.run()
        current_artifact = await generator.generate_draft(context, f"intent_gen_{uuid4().hex[:8]}")
        iterations = 0
        while iterations < policy.max_versions:
            iterations += 1
            eval_results = await self.evaluator_registry.evaluate_pipeline(
                context=context,
                artifact=current_artifact,
                intent_id=f"intent_eval_{uuid4().hex[:8]}",
            )
            open_issues = [issue for result in eval_results for issue in result.issues
                           if issue.severity in (IssueSeverity.CRITICAL, IssueSeverity.MAJOR)
                           and issue.status.value == "OPEN"]
            by_id = {result.evaluator_id: result for result in eval_results}
            exact_evaluations = (
                bool(required_ids) and set(required_ids).issubset(by_id)
                and len(by_id) == len(eval_results)
                and all(result.status == EvaluationStatus.PASS
                        and result.target_ref == current_artifact.to_ref()
                        and set(result.input_dependency_refs) == set(current_artifact.parent_refs)
                        for result in eval_results)
            )
            if exact_evaluations and not open_issues:
                return LoopResult(
                    runId=run_id,
                    decision=DecisionType.PASS,
                    terminalState=LoopState.COMPLETED,
                    acceptedArtifact=current_artifact,
                    terminalReason="Paper passed all evaluations successfully",
                    terminalReasonCode=LoopReason.ACCEPTED,
                    totalIterations=iterations,
                    versionsCount=iterations,
                    repairsCount=max(0, iterations - 1),
                    ledger=IssueLedger(ledgerId=f"led_{run_id}", runId=run_id),
                )

            # Local execution cannot invent a patch or accept incomplete coverage.
            break

        return LoopResult(
            runId=run_id,
            decision=DecisionType.FAIL,
            terminalState=LoopState.FAILED,
            acceptedArtifact=None,
            terminalReason="Maximum paper repair versions exceeded",
            terminalReasonCode=LoopReason.MAX_REPAIRS,
            totalIterations=iterations,
            versionsCount=iterations,
            repairsCount=iterations,
            ledger=IssueLedger(ledgerId=f"led_{run_id}", runId=run_id),
        )
