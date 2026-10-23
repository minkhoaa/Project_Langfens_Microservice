"""Question-level and group-level surgical repairers for Langfens Loop Engine V2."""

from __future__ import annotations
from collections.abc import Mapping
from types import MappingProxyType
from typing import Any, Dict, Optional, Sequence, Set
import copy
import re
from datetime import datetime, timezone
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, compute_content_hash
from app.contracts.issue import Issue, IssueCode
from app.contracts.policies import match_verbatim_in_passage
from app.evaluators.deterministic import check_prompt_answer_leakage
from app.repair.base import (
    BaseRepairer,
    RepairCapabilityMetadata,
    RepairExecutionError,
    RepairJustificationError,
    RepairScope,
)


def unwrap_payload(val: Any) -> Any:
    """Recursively converts MappingProxyType to mutable dict/list structures."""
    if isinstance(val, (dict, MappingProxyType)):
        return {k: unwrap_payload(v) for k, v in val.items()}
    if isinstance(val, (list, tuple)):
        return [unwrap_payload(x) for x in val]
    return val

class QuestionItemRepairer(BaseRepairer):
    """Surgically repairs a single question's prompt, options, or answer length.
    
    P07-08 / T07-03 Invariant: Unaffected questions maintain identical hash and structure.
    P07-08 / T07-08 Invariant: Answer changes must have passage evidence justification.
    """

    def __init__(
        self,
        timeout_seconds: Optional[float] = None,
        estimated_tokens: Optional[int] = None,
        gateway: Optional[Any] = None,
        enable_hybrid: bool = True,
    ):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "repair_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "repair_max_tokens_per_attempt", 1500)
        self.gateway = gateway
        self.enable_hybrid = enable_hybrid
        super().__init__(
            RepairCapabilityMetadata(
                repairer_id="rep_question_item",
                repairer_version="1.0.0",
                name="Question Item Surgical Repairer",
                description="Trims answers to 3 words, replaces bad distractors, clarifies prompts",
                scope=RepairScope.QUESTION,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                handled_codes={
                    IssueCode.WORD_LIMIT_EXCEEDED,
                    IssueCode.BAD_DISTRACTOR,
                    IssueCode.INSUFFICIENT_OPTIONS,
                    IssueCode.AMBIGUOUS_ANSWER,
                    IssueCode.SCHEMA_VIOLATION,
                    IssueCode.ANSWER_LEAKAGE,
                },
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
            )
        )

    async def _repair_impl(
        self,
        context: Any,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        payload = unwrap_payload(artifact.payload)
        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        # Extract target question numbers from issue messages or affected refs
        target_q_nums = set()
        for iss in issues:
            q_num_match = re.search(r"Question\s+(\d+)", iss.message)
            if q_num_match:
                target_q_nums.add(int(q_num_match.group(1)))

        # P15: sibling answers already committed elsewhere in the artifact. A
        # completion / summary group must carry mutually distinct answers, and a
        # summary group's shared stem constrains every one of its blanks. Both are
        # invariants of the GROUP, not of one slot, so salvage has to consult the
        # whole artifact rather than only the slot being repaired. For a
        # single-QUESTION artifact there are no siblings and no shared stem, so the
        # sibling set is empty and only self-leakage applies.
        #
        # Read LIVE from the payload on every call rather than from a snapshot taken
        # before repair began: `repair_single_q` mutates questions one at a time, so
        # an earlier blank repaired in this same pass must be visible to the gates of
        # the next one, otherwise two blanks in one group could both take the same
        # newly-salvaged answer.
        def _sibling_answers_for(q: Dict[str, Any]) -> Set[str]:
            """Case-folded answers of the OTHER blanks in this slot's group."""
            _qn = q.get("questionNumber") or q.get("number")
            if _qn is None or not isinstance(payload, Mapping):
                return set()
            _qn = int(_qn)
            _mine = str(q.get("answer") or "").strip().casefold()
            _others: Set[str] = set()
            for _grp in payload.get("groups", []) or []:
                if not isinstance(_grp, Mapping):
                    continue
                for _q in _grp.get("questions", []) or []:
                    if not isinstance(_q, Mapping):
                        continue
                    _qn2 = _q.get("questionNumber") or _q.get("number")
                    if _qn2 is None or int(_qn2) == _qn:
                        continue
                    _a = str(_q.get("answer") or "").strip()
                    if _a:
                        _others.add(_a.casefold())
            return _others - ({_mine} if _mine else set())

        def _stem_for(q: Dict[str, Any]) -> str:
            """The shared stem this slot belongs to, if the artifact has groups."""
            _qn = q.get("questionNumber") or q.get("number")
            if _qn is None or not isinstance(payload, Mapping):
                return ""
            _qn = int(_qn)
            for _grp in payload.get("groups", []) or []:
                if not isinstance(_grp, Mapping):
                    continue
                if any(
                    isinstance(_q, Mapping) and int(_q.get("questionNumber") or _q.get("number") or 0) == _qn
                    for _q in _grp.get("questions", []) or []
                ):
                    return str(_grp.get("sharedContext") or "")
            return ""

        async def repair_single_q(q: Dict[str, Any]):
            q_type = q.get("questionType") or q.get("type", "")
            q_type_norm = str(q_type).replace("_", "").replace("-", "").lower()
            is_mcq = q_type_norm in ("multiplechoicesingle", "mcq", "multiplechoice")
            is_completion_or_short = q_type_norm in ("sentencecompletion", "summarycompletion", "shortanswer")
            orig_ans = str(q.get("answer") or "")
            orig_prompt = str(q.get("prompt") or q.get("statement") or "")
            ans = orig_ans

            def _try_apply_candidate(cand: Dict[str, Any], require_distinct: bool = False) -> bool:
                if not isinstance(cand, (dict, MappingProxyType)):
                    return False
                cand_ans = str(cand.get("answer") or cand.get("correctOption") or "").strip()
                if not cand_ans:
                    return False
                cand_prompt = str(cand.get("prompt") or cand.get("statement") or q.get("prompt") or "").strip()
                if not cand_prompt:
                    return False
                if require_distinct and cand_ans == orig_ans.strip() and cand_prompt == orig_prompt.strip():
                    return False
                cand_options = cand.get("options")
                if is_mcq:
                    eff_opts = cand_options if isinstance(cand_options, list) and len(cand_options) >= 4 else q.get("options")
                    if not isinstance(eff_opts, list) or len(eff_opts) < 4:
                        return False
                if is_completion_or_short:
                    if len(cand_ans.split()) > 3:
                        return False
                    if passage_text and not match_verbatim_in_passage(cand_ans, passage_text):
                        return False
                cand_quote = str(cand.get("evidenceQuote") or cand.get("evidence_quote") or "").strip()
                if cand_quote and passage_text and cand_quote.casefold() not in passage_text.casefold():
                    return False
                if cand_ans.strip().casefold() != orig_ans.strip().casefold() and orig_ans.strip():
                    eff_quote = cand_quote or str(q.get("evidenceQuote") or "").strip()
                    if passage_text and not match_verbatim_in_passage(cand_ans, passage_text) and (not eff_quote or eff_quote.casefold() not in passage_text.casefold()):
                        return False
                # P15: salvaging a pooled candidate must satisfy EVERY invariant the
                # generator satisfies before a candidate is usable, not just grounding
                # and length. Two gates were missing, and each one let a *rejected*
                # candidate be applied and returned as a repaired artifact:
                #   1. anti-leakage -- a candidate whose answer appears verbatim inside
                #      its own stem is not a usable question. Applying it produced a
                #      "successfully repaired" artifact that the very next evaluation
                #      pass re-flagged as ANSWER_LEAKAGE, so the repair consumed a
                #      version and returned the loop to the same blocker set.
                #   2. group distinctness -- a summary/completion group must carry
                #      mutually distinct answers. A candidate duplicating a sibling
                #      blank's answer violates the group contract even though nothing
                #      local to this slot objects.
                # Both are read from the artifact payload, so the gate is complete
                # without any provider call. A candidate failing either is skipped
                # and the search continues to the next pool member; exhausting the
                # pool still raises RepairJustificationError (fail-closed).
                if check_prompt_answer_leakage(cand_prompt, cand_ans):
                    return False
                # A summary group shares one stem across every blank, so an answer
                # that appears in that stem is leaked for this blank too, whatever
                # this slot's own prompt looks like.
                _stem = _stem_for(q)
                if _stem and check_prompt_answer_leakage(_stem, cand_ans):
                    return False
                if cand_ans.casefold() in _sibling_answers_for(q):
                    return False
                q["answer"] = cand_ans
                q["prompt"] = cand_prompt
                if "statement" in q:
                    q["statement"] = cand_prompt
                if is_mcq and isinstance(cand_options, list) and len(cand_options) >= 4:
                    q["options"] = list(cand_options)[:4]
                cand_quote = cand.get("evidenceQuote") or cand.get("evidence_quote")
                if cand_quote:
                    q["evidenceQuote"] = str(cand_quote)
                    cand_ev = cand.get("passageEvidence")
                    if isinstance(cand_ev, dict):
                        q["passageEvidence"] = cand_ev
                    elif passage_text and str(cand_quote) in passage_text:
                        s_idx = passage_text.find(str(cand_quote))
                        q["passageEvidence"] = {"startChar": s_idx, "endChar": s_idx + len(str(cand_quote)), "text": str(cand_quote)}
                cand_expl = cand.get("explanation")
                if cand_expl:
                    q["explanation"] = str(cand_expl)
                cand_id = cand.get("candidateId") or cand.get("candidate_id")
                if cand_id:
                    q["candidateId"] = str(cand_id)
                if cand.get("score") is not None:
                    q["score"] = cand.get("score")
                existing_cands = q.get("candidates")
                if isinstance(existing_cands, list) and cand in existing_cands:
                    updated_cand = dict(cand)
                    updated_cand["answer"] = cand_ans
                    updated_cand["prompt"] = cand_prompt
                    q["candidates"] = [updated_cand] + [c for c in existing_cands if c is not cand]
                return True

            async def _try_gateway_regeneration(
                q_num_val: int,
                repair_constraints: Optional[List[str]] = None,
                diagnosis: Optional[str] = None,
            ) -> bool:
                gw = self.gateway or getattr(context, "gateway", None)
                if gw is None or not passage_text:
                    return False
                from app.contracts.artifact import ArtifactRef
                from app.generators.question.generator import QuestionCandidateGenerator
                p_ref = next(
                    (r for r in artifact.parent_refs if r.artifact_type == ArtifactType.PASSAGE),
                    ArtifactRef(artifactId="art_passage_s1", artifactType=ArtifactType.PASSAGE, version=1, contentHash="0" * 64),
                )
                bp_ref = next(
                    (r for r in artifact.parent_refs if r.artifact_type == ArtifactType.EXAM_BLUEPRINT),
                    ArtifactRef(artifactId="art_blueprint_01", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64),
                )
                q_gen = QuestionCandidateGenerator(gateway=gw)
                sec_id_str = str(artifact.section_id or getattr(context, "section_id", None) or 1)
                for try_q_type in ([q_type, "SentenceCompletion"] if q_type_norm == "summarycompletion" else [q_type]):
                    try:
                        regen_pool = await q_gen.generate_candidate_pool(
                            passage_text=passage_text,
                            question_type=try_q_type or "SentenceCompletion",
                            question_number=q_num_val,
                            passage_ref=p_ref,
                            blueprint_ref=bp_ref,
                            run_id=artifact.run_id,
                            section_id=sec_id_str,
                            context=context,
                            parent_operation_id=intent_id,
                            repair_constraints=repair_constraints,
                            diagnosis=diagnosis,
                            pinned_model="MiniMax-Text-01",
                        )
                    except (ValueError, RepairExecutionError) as auth_err:
                        if any(term in str(auth_err).lower() for term in ("authority", "epoch", "lease")):
                            raise
                        continue
                    except Exception:
                        continue
                    if regen_pool and regen_pool.candidates:
                        dumped_cands = [c.model_dump(mode="json", by_alias=True) for c in regen_pool.candidates]
                        q["candidates"] = dumped_cands
                        for c_dict in dumped_cands:
                            if _try_apply_candidate(c_dict, require_distinct=True):
                                return True
                return False

            for iss in issues:
                if iss.code == IssueCode.SCHEMA_VIOLATION:
                    if iss.proposed_repair:
                        prop_ans = iss.proposed_repair.strip()
                        if passage_text and is_completion_or_short and not match_verbatim_in_passage(prop_ans, passage_text):
                            raise RepairJustificationError(
                                f"Proposed answer repair '{prop_ans}' is not supported by passage text"
                            )
                    cand_list = q.get("candidates") or []
                    if not isinstance(cand_list, list):
                        cand_list = []
                    replaced = any(_try_apply_candidate(cand) for cand in cand_list)
                    if not replaced:
                        q_num_val = int(q.get("questionNumber") or q.get("number") or 1)
                        replaced = await _try_gateway_regeneration(q_num_val)
                    if not replaced:
                        raise RepairJustificationError(
                            f"Question {q.get('questionNumber')} cannot repair schema violation: no valid candidate available in pool "
                            "and no passage-grounded span found; slot generation must regenerate via gateway"
                        )
                elif iss.code in (IssueCode.AMBIGUOUS_ANSWER, IssueCode.DUPLICATE_PROMPT, IssueCode.DUPLICATE_CONTENT):
                    q_num_val = int(q.get("questionNumber") or q.get("number") or 1)
                    gw = self.gateway or getattr(context, "gateway", None)
                    use_hybrid = self.enable_hybrid and getattr(context, "enable_hybrid_repair", True) and (gw is not None)
                    if use_hybrid:
                        # Invoke M3 for diagnostic repair plan
                        from app.repair.diagnostic_planner import RepairPlanningCapability
                        from app.loop.context import resolve_run_authority
                        auth = resolve_run_authority(context)
                        planner = RepairPlanningCapability(gateway=gw, model_id="MiniMax-M3")
                        lease_owner = auth.lease_owner
                        epoch = auth.epoch
                        sec_id_raw = str(artifact.section_id or getattr(context, "section_id", None) or 1)
                        sec_id_str = sec_id_raw if str(sec_id_raw).startswith("section_") else f"section_{sec_id_raw}"
                        art_id_str = f"questions_{sec_id_str}"
                        auth_claim_ref = (
                            q.get("evidenceClaimRef")
                            or q.get("claimRef")
                            or (artifact.payload.get("evidenceClaimRef") if isinstance(artifact.payload, dict) else None)
                            or (artifact.payload.get("claimRef") if isinstance(artifact.payload, dict) else None)
                        )
                        if not auth_claim_ref or not str(auth_claim_ref).strip():
                            raise RepairJustificationError(
                                f"Question {q_num_val} has no verified blueprint-bound claim reference. "
                                "Fallback claim fabrication is strictly prohibited."
                            )
                        auth_claim_ref = str(auth_claim_ref).strip()
                        plan = await planner.plan_repair(
                            question_payload=q,
                            passage_text=passage_text,
                            authoritative_claim_ref=auth_claim_ref,
                            issues=[iss],
                            run_id=artifact.run_id,
                            section_id=sec_id_str,
                            artifact_id=art_id_str,
                            lease_owner=lease_owner,
                            epoch=epoch,
                            parent_operation_id=intent_id,
                        )
                        # Feed approved M3 constraints to Text-01 for bounded regeneration
                        replaced = await _try_gateway_regeneration(
                            q_num_val,
                            repair_constraints=plan.repair_constraints,
                            diagnosis=plan.diagnosis,
                        )
                        if not replaced:
                            raise RepairJustificationError(
                                f"Question {q_num_val} M3-assisted repair regeneration failed to produce compliant candidate"
                            )
                    elif iss.proposed_repair:
                        if not iss.evidence or len(iss.evidence.strip()) < 5 or (passage_text and iss.evidence.strip() not in passage_text):
                            raise RepairJustificationError(
                                f"Ambiguous answer repair for Question {q.get('questionNumber')} rejected: missing or unsupported passage evidence justification"
                            )
                        prop_ans = iss.proposed_repair.strip()
                        if passage_text and is_completion_or_short and not match_verbatim_in_passage(prop_ans, passage_text):
                            raise RepairJustificationError(
                                f"Ambiguous answer repair '{prop_ans}' rejected: not supported by passage text"
                            )
                        q["answer"] = prop_ans
                    else:
                        cand_list = q.get("candidates") or []
                        replaced = any(_try_apply_candidate(cand, require_distinct=True) for cand in (cand_list if isinstance(cand_list, list) else []))
                        if not replaced:
                            replaced = await _try_gateway_regeneration(q_num_val)
                        if not replaced:
                            raise RepairJustificationError(
                                f"Ambiguous answer repair for Question {q.get('questionNumber')} rejected: requires passage evidence justification or valid alternative candidate"
                            )
                elif iss.code == IssueCode.QUOTE_TRUNCATION:
                    # Purely mechanical: expand truncated quote to full sentence from passage
                    cur_quote = str(q.get("evidenceQuote") or "").strip()
                    if passage_text and cur_quote:
                        sentences = re.split(r"(?<=[.!?])\s+", passage_text)
                        matched_sent = next((s for s in sentences if cur_quote in s), None)
                        if matched_sent:
                            q["evidenceQuote"] = matched_sent.strip()
                        else:
                            idx = passage_text.find(cur_quote)
                            if idx != -1:
                                end_idx = passage_text.find(".", idx)
                                if end_idx != -1:
                                    q["evidenceQuote"] = passage_text[idx:end_idx + 1].strip()
                                else:
                                    q["evidenceQuote"] = passage_text[idx:].strip()
                elif iss.code == IssueCode.ANSWER_LEAKAGE:
                    cand_list = q.get("candidates") or []
                    replaced = False
                    for cand in (cand_list if isinstance(cand_list, list) else []):
                        c_ans = str(cand.get("answer") or "").strip()
                        c_prompt = str(cand.get("prompt") or "").strip()
                        if c_ans and c_prompt and c_ans.lower() not in c_prompt.lower():
                            if _try_apply_candidate(cand, require_distinct=True):
                                replaced = True
                                break
                    if not replaced and orig_ans and orig_prompt and orig_ans.lower() in orig_prompt.lower():
                        sanitized = re.sub(re.escape(orig_ans), "the specified factor", orig_prompt, flags=re.IGNORECASE)
                        if sanitized != orig_prompt:
                            q["prompt"] = sanitized
                            if "statement" in q:
                                q["statement"] = sanitized
                            replaced = True
                    if not replaced:
                        raise RepairJustificationError(
                            f"Answer leakage repair for Question {q.get('questionNumber')} could not sanitize prompt without ungrounded mutation"
                        )
                elif iss.code == IssueCode.WORD_LIMIT_EXCEEDED:
                    words = ans.split()
                    if len(words) > 3:
                        # Identify candidates matching verbatim in passage
                        candidate_spans = [
                            " ".join(words[-3:]),
                            " ".join(words[:3]),
                            " ".join(words[-2:]),
                            " ".join(words[:2]),
                            words[-1],
                            words[0],
                        ]
                        valid_span = None
                        for cand in candidate_spans:
                            if passage_text and match_verbatim_in_passage(cand, passage_text):
                                valid_span = cand
                                break
                        if valid_span is None and passage_text:
                            # Fail closed if no verified span exists
                            raise RepairJustificationError(
                                f"Cannot justify trimmed answer for '{orig_ans}' in passage text; repair aborted"
                            )
                        q["answer"] = valid_span or " ".join(words[:3])

                elif iss.code == IssueCode.BAD_DISTRACTOR and is_mcq:
                    # P07-08 Invariant: Distractor replacement requires verifiable evidence quote + wrongness rationale
                    # proving the option is contradicted/irrelevant to the question stem, followed by uniqueness re-evaluation.
                    if not iss.proposed_repair:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            "requires explicit passage-backed justification and wrongness rationale; "
                            "blind substitution is forbidden"
                        )
                    if not iss.evidence or len(iss.evidence.strip()) < 5:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            "missing mandatory verifiable passage evidence quote"
                        )
                    if passage_text and iss.evidence.strip() not in passage_text:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            f"evidence quote '{iss.evidence[:40]}' not found in passage"
                        )

                    options = q.get("options", [])
                    keys_present = {opt.get("key") for opt in options if hasattr(opt, "get")}

                    parts = iss.proposed_repair.split("|", 1)
                    key_text_part = parts[0].strip()
                    rationale_part = parts[1].strip() if len(parts) > 1 else ""
                    if not rationale_part:
                        raise RepairJustificationError(
                            f"Distractor replacement for Question {q.get('questionNumber')} rejected: "
                            "missing mandatory wrongness rationale proving the option is contradicted/irrelevant to stem"
                        )

                    subparts = key_text_part.split(":", 1)
                    target_key = subparts[0].strip() if len(subparts) > 1 else None
                    replacement_text = subparts[-1].strip()

                    if passage_text and replacement_text.lower() not in passage_text.lower():
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: replacement text '{replacement_text}' is not grounded in passage text"
                        )
                    if iss.evidence and replacement_text.lower() not in iss.evidence.lower():
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: replacement text '{replacement_text}' is not supported by supplied evidence quote"
                        )

                    if target_key and target_key not in keys_present:
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: target key '{target_key}' not among options {keys_present}"
                        )
                    if target_key == ans:
                        raise RepairJustificationError(
                            f"Distractor replacement rejected: cannot replace the correct answer key '{ans}' as a distractor"
                        )
                    for opt in options:
                        if target_key and opt.get("key") == target_key:
                            opt["text"] = replacement_text
                        elif not target_key and opt.get("key") != ans and opt.get("text", "").lower() == ans.lower():
                            opt["text"] = replacement_text

                    # Post-repair uniqueness re-evaluation
                    all_opt_texts = [o.get("text", "").lower() for o in options]
                    if len(all_opt_texts) != len(set(all_opt_texts)):
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: duplicate option text detected among options"
                        )
                    correct_text = next((o.get("text", "") for o in options if o.get("key") == ans), ans)
                    if replacement_text.lower() == correct_text.lower():
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: replacement option is identical to correct answer"
                        )

                    # Post-repair evaluator check: verify replacement option does not answer the stem or violate uniqueness
                    from app.evaluators.semantic import AmbiguityAndDistractorEvaluator
                    q_eval_payload = dict(q)
                    if "passage" not in q_eval_payload and passage_text:
                        q_eval_payload["passage"] = passage_text
                    temp_env = ArtifactEnvelope.create(
                        artifact_id=f"temp_q_{q.get('questionNumber', 1)}",
                        artifact_type=ArtifactType.QUESTION,
                        run_id=artifact.run_id,
                        payload=q_eval_payload,
                        producer_version="2.0.0",
                    )
                    post_eval = AmbiguityAndDistractorEvaluator(gateway=self.gateway or getattr(context, "gateway", None), required=False)
                    post_res = await post_eval.evaluate(context, temp_env, intent_id="post_rep_unique")
                    if any(iss.code in (IssueCode.BAD_DISTRACTOR, IssueCode.AMBIGUOUS_ANSWER) for iss in post_res.issues):
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: replacement option is supported by passage as an answer, "
                            "violating single-answer uniqueness"
                        )
                elif iss.code == IssueCode.INSUFFICIENT_OPTIONS and is_mcq:
                    if not iss.proposed_repair:
                        raise RepairJustificationError(
                            f"Adding options to Question {q.get('questionNumber')} rejected: "
                            "requires explicit passage-backed justification; blind phrase substitution is forbidden"
                        )
                    if not iss.evidence or len(iss.evidence.strip()) < 5:
                        raise RepairJustificationError(
                            f"Adding options to Question {q.get('questionNumber')} rejected: "
                            "missing mandatory verifiable passage evidence quote"
                        )
                    if passage_text and iss.evidence.strip() not in passage_text:
                        raise RepairJustificationError(
                            f"Adding options to Question {q.get('questionNumber')} rejected: "
                            f"evidence quote '{iss.evidence[:40]}' not found in passage"
                        )
                    parts = iss.proposed_repair.split("|", 1)
                    key_text_part = parts[0].strip()
                    rationale_part = parts[1].strip() if len(parts) > 1 else ""
                    if not rationale_part:
                        raise RepairJustificationError(
                            f"Adding option to Question {q.get('questionNumber')} rejected: "
                            "missing mandatory wrongness rationale proving the option is contradicted/irrelevant to stem"
                        )
                    subparts = key_text_part.split(":", 1)
                    if len(subparts) <= 1:
                        raise RepairJustificationError(
                            "Adding option rejected: proposed repair must specify 'KEY: TEXT | Rationale: ...'"
                        )
                    new_key = subparts[0].strip()
                    new_text = subparts[1].strip()

                    if passage_text and new_text.lower() not in passage_text.lower():
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' is not grounded in passage text"
                        )
                    if iss.evidence and new_text.lower() not in iss.evidence.lower():
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' is not supported by supplied evidence quote"
                        )

                    options = q.get("options", [])
                    keys_present = {opt.get("key") for opt in options if hasattr(opt, "get")}
                    if new_key in keys_present:
                        raise RepairJustificationError(
                            f"Adding option rejected: key '{new_key}' is already present among options {keys_present}"
                        )
                    correct_text = next((o.get("text", "") for o in options if o.get("key") == ans), ans)
                    if new_key == ans:
                        raise RepairJustificationError(
                            f"Adding option rejected: cannot add new option with correct answer key '{ans}'"
                        )
                    if new_text.lower() == correct_text.lower():
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' is identical to correct answer"
                        )

                    existing_texts = {o.get("text", "").lower() for o in options if hasattr(o, "get")}
                    if new_text.lower() in existing_texts:
                        raise RepairJustificationError(
                            f"Adding option rejected: new option text '{new_text}' duplicates an existing option"
                        )

                    options.append({"key": new_key, "text": new_text})
                    q["options"] = sorted(options, key=lambda o: o.get("key", ""))

                    if len(q["options"]) != 4:
                        raise RepairJustificationError(
                            f"Post-repair option check failed: MultipleChoiceSingle must have exactly 4 options, found {len(q['options'])}"
                        )
                    # Post-repair evaluator check for added options
                    from app.evaluators.semantic import AmbiguityAndDistractorEvaluator
                    q_eval_payload = dict(q)
                    if "passage" not in q_eval_payload and passage_text:
                        q_eval_payload["passage"] = passage_text
                    temp_env = ArtifactEnvelope.create(
                        artifact_id=f"temp_q_{q.get('questionNumber', 1)}",
                        artifact_type=ArtifactType.QUESTION,
                        run_id=artifact.run_id,
                        payload=q_eval_payload,
                        producer_version="2.0.0",
                    )
                    post_eval = AmbiguityAndDistractorEvaluator(gateway=self.gateway or getattr(context, "gateway", None), required=False)
                    post_res = await post_eval.evaluate(context, temp_env, intent_id="post_rep_unique")
                    if any(iss.code in (IssueCode.BAD_DISTRACTOR, IssueCode.INSUFFICIENT_OPTIONS, IssueCode.AMBIGUOUS_ANSWER) for iss in post_res.issues):
                        raise RepairJustificationError(
                            "Post-repair uniqueness failed: added option violates single-answer uniqueness or option rules"
                        )

            # Invariant: Item/option/answer repair must have passage evidence justification
            final_ans = q.get("answer", "")
            if final_ans != orig_ans and passage_text and is_completion_or_short:
                if not match_verbatim_in_passage(final_ans, passage_text):
                    raise RepairJustificationError(
                        f"Repaired answer '{final_ans}' lacks passage evidence justification (not verbatim in passage)"
                    )
        if artifact.artifact_type == ArtifactType.QUESTION:
            await repair_single_q(payload)
        elif artifact.artifact_type == ArtifactType.SECTION:
            # T07-03: Only repair questions in target_q_nums; all other questions untouched!
            for grp in payload.get("groups", []):
                for q in grp.get("questions", []):
                    q_num = q.get("questionNumber")
                    if not target_q_nums or q_num in target_q_nums:
                        await repair_single_q(q)
        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")


class SummaryGroupRepairer(BaseRepairer):
    """Surgically repairs summary completion groups (blanks, shared context coherence).
    
    P07-08 / T07-04 Invariant: Re-evaluates entire shared group when shared context changes.
    """

    def __init__(self, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "repair_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "repair_max_tokens_per_attempt", 1500)
        super().__init__(
            RepairCapabilityMetadata(
                repairer_id="rep_summary_group",
                repairer_version="1.0.0",
                name="Summary Group Coherence Repairer",
                description="Aligns summary blank placeholders and re-evaluates the shared group",
                scope=RepairScope.GROUP,
                target_artifact_types=[ArtifactType.SECTION],
                handled_codes={
                    IssueCode.SCHEMA_VIOLATION,
                    IssueCode.AMBIGUOUS_ANSWER,
                },
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
            )
        )
    async def _repair_impl(
        self,
        context: Any,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        payload = unwrap_payload(artifact.payload)

        # Identify which summary group is affected (by group number in issue message)
        target_group_idx = None
        for iss in issues:
            m = re.search(r"[Gg]roup\s+(\d+)", iss.message)
            if m:
                target_group_idx = int(m.group(1)) - 1
                break

        repaired_any = False
        for g_idx, grp in enumerate(payload.get("groups", [])):
            g_type = grp.get("questionType") or grp.get("type", "")
            if g_type != "SummaryCompletion":
                continue

            # Only target the affected group if target_group_idx is specified
            if target_group_idx is not None and g_idx != target_group_idx:
                continue

            questions = grp.get("questions", [])
            num_qs = len(questions)
            shared_ctx = grp.get("sharedContext", "") or ""

            # Check if any issue supplied a verified proposed_repair
            matching_issue = next((iss for iss in issues if iss.proposed_repair), None)
            if matching_issue and matching_issue.proposed_repair:
                grp["sharedContext"] = matching_issue.proposed_repair
                repaired_any = True
                continue

            # Try in-place blank normalization preserving existing wording
            blank_pattern = re.compile(r"\[BLANK(?:_\d+)?\]|_{3,}")
            matches = list(blank_pattern.finditer(shared_ctx))
            if len(matches) == num_qs:
                # Sequentially normalize placeholders into [BLANK_1], ..., [BLANK_N]
                parts = []
                last_idx = 0
                for b_idx, m in enumerate(matches):
                    parts.append(shared_ctx[last_idx:m.start()])
                    parts.append(f"[BLANK_{b_idx + 1}]")
                    last_idx = m.end()
                parts.append(shared_ctx[last_idx:])
                new_ctx = "".join(parts)
                if new_ctx != shared_ctx:
                    grp["sharedContext"] = new_ctx
                    repaired_any = True
            else:
                # Cannot reconcile blank count without destroying text coherence; fail closed
                raise RepairExecutionError(
                    f"Cannot reconcile summary group {g_idx+1} blanks ({len(matches)} blanks for {num_qs} questions) "
                    "without destroying text coherence; requires full group regeneration"
                )

        if not repaired_any:
            raise RepairExecutionError(
                "No evidence-backed summary group repair could be applied; requires regeneration"
            )

        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")


def format_diagnostic_feedback(
    issue: object,
    adversary_claim: Optional[str] = None,
    conflicting_span: Optional[str] = None,
    question_text: Optional[str] = None,
    suggested_fix: Optional[str] = None,
) -> str:
    """Formats structured diagnostic feedback for surgical LLM question item repair.

    Supplies the repair prompt with adversary counter-claims, conflicting spans,
    and exact ambiguity context so the model can resolve the defect with high precision.
    """
    lines: list[str] = []
    code = getattr(issue, "code", "")
    code_val = getattr(code, "value", str(code))
    msg = getattr(issue, "message", "")
    target = getattr(issue, "artifact_ref", None) or getattr(issue, "location", None) or "question"

    lines.append(f"## Diagnostic Defect Report: {code_val}")
    lines.append(f"- **Target Artifact**: {target}")
    lines.append(f"- **Issue Code**: {code_val}")
    lines.append(f"- **Diagnostic Message**: {msg}")

    if question_text:
        lines.append(f"\n### Defective Question Under Repair\n{question_text.strip()}")

    if adversary_claim:
        lines.append(f"\n### Adversary Counter-Claim\n{adversary_claim.strip()}")

    if conflicting_span:
        lines.append(f"\n### Conflicting Text Span in Passage\n\"{conflicting_span.strip()}\"")

    if suggested_fix:
        lines.append(f"\n### Recommended Surgical Correction\n{suggested_fix.strip()}")

    lines.append(
        "\n### Repair Instructions\n"
        "1. Surgically modify ONLY the defective question prompt, options, or answer key.\n"
        "2. Ensure the correct answer is strictly and unambiguously grounded in the passage text.\n"
        "3. Eliminate any second defensible interpretation or misleading distractor."
    )

    return "\n".join(lines)
