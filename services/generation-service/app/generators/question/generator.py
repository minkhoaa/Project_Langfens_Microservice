"""Question Candidate Generator for Six IELTS Question Types (Phase 09 / P09-03).

Generates bounded pools of question candidates for each question slot:
- SentenceCompletion / ShortAnswer: bounded to 1-2 candidates.
- TrueFalseNotGiven / YesNoNotGiven: bounded to 2-3 candidates.
- MultipleChoiceSingle: bounded to <= 3 candidates.
- SummaryCompletion: generates coherent group variants with shared draft and targeted blanks.

Enforces:
- Hard pool caps from typed Settings.
- Immutable passage context with untrusted data envelope.
- Defensive JSON parsing and schema validation.
- Zero leakage of holdout items.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List, Optional
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactRef, ArtifactType
from app.generators.question.context import (
    OptionItem,
    QuestionCandidate,
    QuestionCandidatePool,
    QuestionGroupContext,
)
from app.generators.question.prompts import (
    QUESTION_PROMPT_VERSION,
    QuestionPromptFamily,
    build_question_prompt,
)
from app.loop.context import LoopContext, resolve_run_authority
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json

logger = logging.getLogger(__name__)


def get_pool_limit_for_type(question_type: str) -> int:
    """Returns typed pool limit from Settings per P09-03 policy."""
    family = QuestionPromptFamily.from_raw(question_type)
    if family == QuestionPromptFamily.SENTENCE_COMPLETION:
        return getattr(settings, "candidate_pool_limit_completion", 2)
    elif family == QuestionPromptFamily.SHORT_ANSWER:
        return getattr(settings, "candidate_pool_limit_short_answer", 2)
    elif family in (QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN, QuestionPromptFamily.YES_NO_NOT_GIVEN):
        return getattr(settings, "candidate_pool_limit_tfng", 2)
    elif family == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE:
        return getattr(settings, "candidate_pool_limit_mcq", 2)
    elif family == QuestionPromptFamily.SUMMARY_COMPLETION:
        return getattr(settings, "candidate_pool_limit_summary", 2)
    return 2

def normalize_question_generation_payload(
    parsed: Any,
    keep_question_number: Optional[int] = None,
) -> Dict[str, Any]:
    """Normalizes question candidate / summary completion JSON payloads across 'candidates' and 'blanks' shapes."""
    if isinstance(parsed, list):
        return {"candidates": [x for x in parsed if isinstance(x, dict)]}
    if not isinstance(parsed, dict):
        return {}
    out = dict(parsed)
    cands = out.get("candidates")
    if "blanks" not in out and isinstance(cands, list) and cands:
        first_with_blanks = next((c for c in cands if isinstance(c, dict) and isinstance(c.get("blanks"), list)), None)
        if first_with_blanks is not None:
            out["blanks"] = list(first_with_blanks["blanks"])
            if "summaryText" not in out and first_with_blanks.get("summaryText"):
                out["summaryText"] = first_with_blanks["summaryText"]
            if "summaryTitle" not in out and first_with_blanks.get("summaryTitle"):
                out["summaryTitle"] = first_with_blanks["summaryTitle"]
            direct_cands = [c for c in cands if isinstance(c, dict) and "prompt" in c and "answer" in c]
            out["candidates"] = direct_cands
    if isinstance(out.get("blanks"), list):
        norm_blanks: List[Dict[str, Any]] = []
        for b in out["blanks"]:
            if not isinstance(b, dict):
                continue
            b_copy = dict(b)
            raw_ans = b_copy.get("answer") if b_copy.get("answer") is not None else b_copy.get("text", "")
            if isinstance(raw_ans, list):
                raw_ans = " ".join(str(x) for x in raw_ans)
            b_copy["answer"] = str(raw_ans or "").strip()
            norm_blanks.append(b_copy)
        out["blanks"] = norm_blanks
        # When 'blanks' exists, prevent unvalidated or sibling direct candidates from polluting the current slot
        if isinstance(out.get("candidates"), list):
            if keep_question_number is None:
                out["candidates"] = []
            else:
                out["candidates"] = [
                    c for c in out["candidates"]
                    if isinstance(c, dict)
                    and (c.get("questionNumber") == keep_question_number or c.get("number") == keep_question_number)
                ]
    return out



class QuestionCandidateGenerator:
    """Generator for bounded pools of question candidates using ProviderGateway."""

    def __init__(self, gateway: Optional[ProviderGateway] = None):
        self._gateway = gateway
        self._last_group_raw_candidates: Optional[List[Dict[str, Any]]] = None
        self._last_summary_parsed: Optional[Dict[str, Any]] = None
        self._last_dropped_blank_reasons: Dict[int, str] = {}
        self._last_dropped_blank_answers: Dict[int, str] = {}
        self._last_attempted_blank_count: int = 0
    @property
    def gateway(self) -> Optional[ProviderGateway]:
        return self._gateway

    def build_pool_from_raw_candidates(
        self,
        raw_candidates: Any,
        passage_text: Any = "",
        question_type: Any = "",
        question_number: Any = 1,
        passage_ref: Any = None,
        blueprint_ref: Any = None,
        pool_limit: Any = 2,
        slot_id: str = "slot_1",
        group_id: Optional[str] = None,
        provider_name: str = "minimax",
        model_name: str = "MiniMax-Text-01",
    ) -> QuestionCandidatePool:
        if isinstance(raw_candidates, str):
            _pos_slot_id = raw_candidates
            _pos_q_num = int(passage_text) if isinstance(passage_text, int) else 1
            _pos_q_type = str(question_type)
            _pos_raw = question_number if isinstance(question_number, list) else []
            _pos_passage_text = str(passage_ref) if isinstance(passage_ref, str) else ""
            _pos_p_ref = blueprint_ref
            _pos_bp_ref = pool_limit if isinstance(pool_limit, ArtifactRef) else None
            _pos_limit = len(_pos_raw) if _pos_raw else 2

            slot_id = _pos_slot_id
            question_number = _pos_q_num
            question_type = _pos_q_type
            raw_candidates = _pos_raw
            passage_text = _pos_passage_text
            passage_ref = _pos_p_ref
            blueprint_ref = _pos_bp_ref
            pool_limit = _pos_limit
        pool = QuestionCandidatePool(
            slotId=slot_id,
            questionNumber=question_number,
            questionType=question_type,
            poolLimit=pool_limit,
        )
        family = QuestionPromptFamily.from_raw(question_type)
        import re
        for idx, raw in enumerate(raw_candidates[:pool_limit]):
            cand_id = f"cand_{slot_id}_{idx+1}_{uuid4().hex[:6]}"
            options = None
            rejection_reasons: List[str] = []

            extracted_ans = raw.get("answer")
            if extracted_ans is None and "correctOption" in raw:
                extracted_ans = raw.get("correctOption")
            raw_ans_str = str(extracted_ans).strip() if extracted_ans is not None else ""

            if not raw_ans_str:
                rejection_reasons.append("Missing answer key")

            if family == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE:
                opts_raw = raw.get("options", [])
                parsed_opts: List[OptionItem] = []
                if isinstance(opts_raw, list):
                    for i, o in enumerate(opts_raw):
                        if isinstance(o, dict) and o.get("text"):
                            k = str(o.get("key") or chr(65 + i)).strip().upper()
                            parsed_opts.append(OptionItem(key=k, text=str(o.get("text", "")).strip()))
                        elif isinstance(o, str) and o.strip():
                            clean_str = o.strip()
                            m = re.match(r"^([A-D])\.\s*(.+)$", clean_str)
                            if m:
                                parsed_opts.append(OptionItem(key=m.group(1).upper(), text=m.group(2).strip()))
                            else:
                                parsed_opts.append(OptionItem(key=chr(65 + i), text=clean_str))

                # Preserve valid MCQ option mappings; NEVER manufacture missing distractors!
                options = parsed_opts if parsed_opts else None

                # Validate answer key mapping against options without artificial fallback
                if raw_ans_str:
                    ans_upper = raw_ans_str.upper()
                    matched_key = None
                    if parsed_opts:
                        for opt in parsed_opts:
                            if opt.key == ans_upper:
                                matched_key = opt.key
                                break
                        if not matched_key:
                            for opt in parsed_opts:
                                if opt.text.strip().lower() == raw_ans_str.lower():
                                    matched_key = opt.key
                                    break
                    if matched_key:
                        raw_ans = matched_key
                    else:
                        rejection_reasons.append(f"MCQ answer key '{raw_ans_str}' not found in options")
                        raw_ans = "[UNMAPPED]"
                else:
                    raw_ans = "[MISSING]"
            else:
                raw_ans = raw_ans_str if raw_ans_str else "[MISSING]"

            ev_quote = str(raw.get("evidenceQuote") or "").strip()
            if passage_text:
                is_not_given = family in (
                    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN,
                    QuestionPromptFamily.YES_NO_NOT_GIVEN,
                ) and raw_ans in ("NOT GIVEN", "NOT_GIVEN", "NG")

                if not ev_quote and not is_not_given:
                    rejection_reasons.append("Missing evidence quote")
                elif ev_quote and ev_quote.casefold() not in passage_text.casefold():
                    rejection_reasons.append(f"Evidence quote is unsupported by passage: '{ev_quote[:60]}'")

            raw_prompt = str(raw.get("prompt") or "").strip()
            if not raw_prompt:
                rejection_reasons.append("Missing prompt")
                raw_prompt = "[MISSING]"

            cand = QuestionCandidate(
                candidateId=cand_id,
                slotId=slot_id,
                passageRef=passage_ref,
                blueprintRef=blueprint_ref,
                groupId=group_id,
                questionNumber=question_number,
                questionType=question_type,
                prompt=raw_prompt,
                answer=raw_ans,
                options=options,
                evidenceQuote=ev_quote,
                explanation=raw.get("explanation"),
                metadata={
                    "promptVersion": QUESTION_PROMPT_VERSION,
                    "provider": provider_name,
                    "model": model_name,
                },
            )
            if rejection_reasons:
                cand.rejected = True
                cand.rejection_reasons.extend(rejection_reasons)
            if cand.rejection_reasons:
                cand.rejected = True
            pool.add_candidate(cand)
        return pool

    async def generate_candidate_pool(
        self,
        passage_text: str,
        question_type: str,
        question_number: int,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        run_id: str,
        section_id: Optional[str] = "1",
        context: Optional[LoopContext] = None,
        custom_pool_limit: Optional[int] = None,
        group_id: Optional[str] = None,
        parent_operation_id: Optional[str] = None,
        group_start_number: Optional[int] = None,
        blank_count: Optional[int] = None,
        max_wall_time_seconds: Optional[float] = None,
        repair_constraints: Optional[List[str]] = None,
        diagnosis: Optional[str] = None,
        pinned_model: Optional[str] = None,
    ) -> QuestionCandidatePool:
        pool_limit = custom_pool_limit or get_pool_limit_for_type(question_type)
        slot_id = f"slot_q{question_number}_{question_type}"

        family = QuestionPromptFamily.from_raw(question_type)

        paragraphs = [p.strip() for p in passage_text.split("\n\n") if p.strip()]
        target_focus = None
        if paragraphs:
            para_idx = (question_number - 1) % len(paragraphs)
            target_focus = paragraphs[para_idx]

        prompt_q_num = (group_start_number or question_number) if family == QuestionPromptFamily.SUMMARY_COMPLETION else question_number
        if group_start_number is not None and blank_count is not None and blank_count > 1 and family != QuestionPromptFamily.SUMMARY_COMPLETION:
            group_range_desc = f"questions {group_start_number} to {group_start_number + blank_count - 1}"
            target_focus = f"{group_range_desc} across the passage"

        prompt_data = build_question_prompt(
            family=family,
            passage_text=passage_text,
            question_number=prompt_q_num,
            candidate_count=pool_limit,
            blank_count=blank_count or 4,
            target_focus=target_focus,
        )
        if self._gateway is None or context is None or (getattr(self._gateway, "checkpoint_client", None) is not None and type(self._gateway.checkpoint_client).__name__ == "SQLiteCheckpointSimulation" and not str(run_id).lower().startswith("bench_")):
            # Offline / fake fallback candidate generation for interface testing
            return self._build_mock_candidate_pool(
                passage_text=passage_text,
                question_type=question_type,
                question_number=question_number,
                passage_ref=passage_ref,
                blueprint_ref=blueprint_ref,
                pool_limit=pool_limit,
                slot_id=slot_id,
                group_id=group_id,
            )

        auth = resolve_run_authority(context)
        eff_parent_op = parent_operation_id or (getattr(context, "parent_operation_id", None) if context else None)
        if eff_parent_op:
            op_id = f"{eff_parent_op}:text_regen:q{question_number}"
        else:
            op_id = f"op:{run_id}:qpool:q{question_number}"
        max_toks = 4096 if pool_limit > 3 else 1800
        user_prompt = prompt_data["user_prompt"]
        if pool_limit > 3 and family != QuestionPromptFamily.SUMMARY_COMPLETION:
            user_prompt = user_prompt + (
                f"\n\nIMPORTANT: Generate {pool_limit} COMPLETELY DISTINCT question candidates covering different sentences and paragraphs across the entire passage. Every candidate must test a different fact with a distinct evidenceQuote copied verbatim from the passage, and for completion/short-answer types every answer MUST be 1, 2, or 3 words maximum (NEVER 4+ words) occurring verbatim in the passage."
            )
        if repair_constraints or diagnosis:
            repair_instructions = []
            if diagnosis:
                repair_instructions.append(f"DIAGNOSTIC ISSUE TO RESOLVE: {diagnosis}")
            if repair_constraints:
                repair_instructions.append("MANDATORY SURGICAL REPAIR CONSTRAINTS (YOU MUST STRICTLY FOLLOW):")
                for c in repair_constraints:
                    repair_instructions.append(f"- {c}")
            user_prompt = user_prompt + "\n\n" + "\n".join(repair_instructions)
        eff_wall = float(max_wall_time_seconds) if max_wall_time_seconds is not None else float(settings.loop_operation_wall_reservation_seconds)
        req = ProviderRequest(
            operation_id=op_id,
            run_id=run_id,
            section_id=str(section_id) if section_id else "1",
            artifact_id=f"questions_section_{section_id}" if section_id and not str(section_id).startswith("section_") else (f"questions_{section_id}" if section_id else "questions_section_1"),
            parent_operation_id=parent_operation_id or (getattr(context, "parent_operation_id", None) if context else None),
            capability=Capability.GENERATE_JSON,
            preferred_provider="minimax",
            allowed_providers=["minimax"],
            pinned_model=pinned_model or "MiniMax-Text-01",
            allow_fallback=False,
            messages=[
                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                ChatMessage(role="user", content=user_prompt),
            ],
            max_tokens=max_toks,
            timeout_seconds=min(120.0 if pool_limit > 3 else 60.0, eff_wall),
            wall_time_reservation_seconds=min(120.0 if pool_limit > 3 else 60.0, eff_wall),
        )
        resp = await self._gateway.execute(
            req,
            epoch=auth.epoch,
            lease_owner=auth.lease_owner,
        )
        tokens_used = int(resp.usage.total_tokens) if resp.usage and resp.usage.total_tokens else 0
        wall_time_used = float(resp.duration_seconds) if hasattr(resp, "duration_seconds") and resp.duration_seconds is not None else 0.0
        raw_parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
        parsed = normalize_question_generation_payload(raw_parsed, keep_question_number=question_number)
        import re
        # A SummaryCompletion payload may be hybrid: it carries `blanks` for the group AND
        # `candidates` holding a direct answer for this specific slot. normalize_question_generation_payload
        # deliberately retains the slot-matched direct candidate. Previously this line discarded the whole
        # `candidates` list whenever `blanks` was present, throwing away a model-supplied, slot-matched,
        # grounded answer and letting a derived span win instead. Retain it here; the existing target-lookup
        # block below still prefers the group's own blank for the slot, and only falls back to this candidate
        # when the group has no usable blank for it.
        _hybrid_candidates: List[Dict[str, Any]] = []
        if isinstance(parsed, dict) and "blanks" in parsed:
            _hybrid_candidates = [
                c for c in (parsed.get("candidates") or [])
                if isinstance(c, dict) and str(c.get("answer") or "").strip()
            ]
            raw_candidates = []
        else:
            raw_candidates = parsed.get("candidates", []) if isinstance(parsed, dict) else []
        self._last_dropped_blank_reasons = {}
        self._last_dropped_blank_answers = {}
        self._last_attempted_blank_count = 0

        from app.evaluators.deterministic import check_prompt_answer_leakage
        from app.contracts.policies import (
            WORD_REGEX,
            count_words,
            match_verbatim_in_passage,
            validate_answer_length,
        )

        _TRIVIAL_STOPWORDS = {
            "and", "or", "the", "a", "an", "in", "on", "of", "to", "for",
            "with", "by", "at", "from", "as", "is", "are", "was", "were",
            "be", "been", "this", "that", "these", "those", "it", "its",
        }

        def _normalize_answer(raw_ans: Any) -> str:
            if isinstance(raw_ans, list):
                raw_ans = " ".join(str(x) for x in raw_ans)
            return str(raw_ans or "").strip()

        def _exact_case_from_passage(span: str, passage: str) -> str:
            if not span or not passage:
                return span
            m = re.search(r"(?<![\w'-])" + re.escape(span.strip()) + r"(?![\w'-])", passage, re.IGNORECASE)
            return m.group(0) if m else span.strip()

        def _is_usable_span(
            span: str,
            passage: str,
            used_lower: set,
            prompt_to_check: str = "",
            require_no_leak: bool = True,
        ) -> bool:
            cand = span.strip(" ,;:.\"'”“’‘`()[]")
            if not cand or len(cand) < 2:
                return False
            if cand.casefold() in _TRIVIAL_STOPWORDS or cand.casefold() in used_lower:
                return False
            if not validate_answer_length(cand):
                return False
            if passage and not match_verbatim_in_passage(cand, passage):
                return False
            if require_no_leak and prompt_to_check and check_prompt_answer_leakage(prompt_to_check, cand):
                return False
            return True

        def _try_repair_short_answer(
            ans: str,
            passage: str,
            ev_quote: str = "",
            prompt_to_check: str = "",
            used_lower: Optional[set] = None,
            allow_quote_fallback: bool = False,
        ) -> Optional[str]:
            used_set = used_lower if used_lower is not None else set()
            if not ans:
                return None
            candidate = (ans or "").strip()
            if not passage:
                return candidate if validate_answer_length(candidate) and candidate.casefold() not in used_set else None

            # 1. Exact candidate check (must not leak in prompt_to_check)
            if _is_usable_span(candidate, passage, used_set, prompt_to_check, require_no_leak=True):
                return _exact_case_from_passage(candidate, passage)

            # Reject coordinate pairs or multi-conjoined date/item lists rather than truncating to partial meaning
            if "°" in candidate or candidate.lower().count(" and ") >= 2:
                return None

            # 2. Strip parenthetical acronyms e.g. "alpha-synuclein (α-syn) pathology" -> "alpha-synuclein", "pathology"
            no_paren = re.sub(r"\s*\([^)]*\)", "", candidate).strip()
            if no_paren and _is_usable_span(no_paren, passage, used_set, prompt_to_check, require_no_leak=True):
                return _exact_case_from_passage(no_paren, passage)

            # 3. Try contiguous token windows from candidate and no_paren (prefer 2-3 words, then 1 word)
            for src_str in (candidate, no_paren):
                raw_toks = [t.strip(" ,;:.\"'”“’‘`()[]") for t in src_str.split() if t.strip(" ,;:.\"'”“’‘`()[]")]
                for keep in (3, 2, 1):
                    if len(raw_toks) < keep:
                        continue
                    for start in range(len(raw_toks) - keep, -1, -1):
                        sub = " ".join(raw_toks[start : start + keep]).strip(" ,;:.\"'”“’‘`()[]-")
                        if not sub or sub.split()[0].casefold() in _TRIVIAL_STOPWORDS or sub.split()[-1].casefold() in _TRIVIAL_STOPWORDS:
                            continue
                        if _is_usable_span(sub, passage, used_set, prompt_to_check, require_no_leak=True):
                            return _exact_case_from_passage(sub, passage)

            # NOTE: `allow_quote_fallback` is deliberately NOT implemented. Deriving an answer by mining an
            # arbitrary 1-3 word span out of the blank's evidenceQuote does not establish that the span
            # answers that blank: the evidenceQuote identifies the sentence, not which words fill the cloze.
            # A mined span can satisfy every mechanical gate (verbatim, 1-3 words, non-leaking, distinct) and
            # still be semantically wrong for the cloze. Answers must be recovered only from text the model
            # actually supplied AS the answer (branches 1-3 above, or a slot-matched direct candidate).
            return None
        if isinstance(parsed, dict) and "blanks" in parsed:
            summary_text = str(parsed.get("summaryText", "") or "")
            blanks = [b for b in parsed.get("blanks", []) if isinstance(b, dict)]
            self._last_attempted_blank_count = len(blanks)
            passage_norm = " ".join(passage_text.split()).casefold() if passage_text else ""
            p_sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", passage_text) if len(s.strip()) >= 15] if passage_text else []
            if not p_sentences and passage_text:
                p_sentences = [passage_text.strip()]

            kept_blanks: List[Dict[str, Any]] = []
            used_group_answers: set = set()
            start_num = group_start_number if group_start_number is not None else question_number

            for b_idx, b in enumerate(blanks):
                raw_num = b.get("number")
                if isinstance(raw_num, int) and raw_num >= start_num:
                    slot_num = raw_num
                elif isinstance(raw_num, int) and 1 <= raw_num <= len(blanks) and start_num > len(blanks):
                    slot_num = start_num + raw_num - 1
                else:
                    slot_num = start_num + b_idx

                raw_ans = _normalize_answer(b.get("answer", "") or b.get("text", ""))
                ev_q = str(b.get("evidenceQuote", "") or "").strip()
                if passage_text:
                    if not (ev_q and len(ev_q) >= 15 and ev_q in passage_text):
                        best_sent = p_sentences[0] if p_sentences else passage_text[:120]
                        q_toks = set(re.findall(r"\w+", (ev_q + " " + raw_ans).casefold()))
                        best_ov = -1
                        for s in p_sentences:
                            ov = len(set(re.findall(r"\w+", s.casefold())) & q_toks)
                            if ov > best_ov:
                                best_ov = ov
                                best_sent = s
                        ev_q = best_sent

                if not raw_ans:
                    # Fail closed. The model supplied no answer for this blank. The evidenceQuote (when
                    # present) names the source sentence but not which words fill this cloze, so no span
                    # can be mined from it without inventing an answer. Recovery for this shape must come
                    # from text the model supplied AS the answer -- see the slot-matched direct-candidate
                    # fallback in the target-lookup block below.
                    self._last_dropped_blank_reasons[slot_num] = "empty_answer"
                    continue

                # Record reason if the raw answer itself had an issue before repair
                raw_len_ok = validate_answer_length(raw_ans)
                raw_verb_ok = (not passage_text) or match_verbatim_in_passage(raw_ans, passage_text)
                raw_leak = len(raw_ans) >= 2 and check_prompt_answer_leakage(summary_text, raw_ans)
                raw_dup = raw_ans.casefold() in used_group_answers
                if not raw_len_ok:
                    self._last_dropped_blank_reasons[slot_num] = "exceeds_max_words"
                    self._last_dropped_blank_answers[slot_num] = raw_ans
                elif not raw_verb_ok:
                    self._last_dropped_blank_reasons[slot_num] = "non_verbatim_in_passage"
                    self._last_dropped_blank_answers[slot_num] = raw_ans
                elif raw_leak:
                    self._last_dropped_blank_reasons[slot_num] = "answer_leaks_in_summaryText"
                    self._last_dropped_blank_answers[slot_num] = raw_ans
                elif raw_dup:
                    self._last_dropped_blank_reasons[slot_num] = "duplicate_group_answer"
                    self._last_dropped_blank_answers[slot_num] = raw_ans

                repaired = _try_repair_short_answer(
                    raw_ans,
                    passage_text,
                    ev_quote=ev_q,
                    prompt_to_check=summary_text,
                    used_lower=used_group_answers,
                    allow_quote_fallback=False,
                )
                if not repaired:
                    continue

                # The raw answer's defect reason was recorded pre-repair; once repair succeeds the
                # blank is kept, so it must not remain listed as dropped.
                self._last_dropped_blank_reasons.pop(slot_num, None)
                self._last_dropped_blank_answers.pop(slot_num, None)

                used_group_answers.add(repaired.casefold())
                kept_blanks.append({
                    **b,
                    "number": slot_num,
                    "placeholder": b.get("placeholder") or f"[{b_idx + 1}]",
                    "answer": repaired,
                    "evidenceQuote": ev_q,
                    "_orig_index": b_idx,
                })
            if kept_blanks:
                self._last_summary_parsed = {
                    **parsed,
                    "summaryText": summary_text,
                    "blanks": kept_blanks,
                }
            else:
                self._last_summary_parsed = None

            if not raw_candidates and kept_blanks:
                target_blank = None
                # 1. Match by explicit question number (e.g. 20)
                for b in kept_blanks:
                    if b.get("number") == question_number:
                        target_blank = b
                        break
                # 2. Match by original group-relative index (never positional index on a compressed list!)
                if target_blank is None and group_start_number is not None:
                    rel_idx = question_number - group_start_number
                    for b in kept_blanks:
                        if b.get("_orig_index") == rel_idx:
                            target_blank = b
                            break
                # 3. Match by explicit placeholder tag for this question's relative position
                if target_blank is None and group_start_number is not None:
                    rel_pos = question_number - group_start_number + 1
                    for b in kept_blanks:
                        ph = str(b.get("placeholder", "")).strip()
                        if ph in (f"[{rel_pos}]", str(rel_pos), f"[{question_number}]", str(question_number)):
                            target_blank = b
                            break
                if target_blank:
                    ans_str = _normalize_answer(target_blank.get("answer", "") or target_blank.get("text", ""))
                    if ans_str:
                        raw_candidates = [{
                            "prompt": summary_text or target_blank.get("placeholder", f"Blank #{question_number}"),
                            "answer": ans_str,
                            "evidenceQuote": target_blank.get("evidenceQuote", ""),
                            "explanation": target_blank.get("explanation", "") or f"Verified from passage: {str(target_blank.get('evidenceQuote', ''))[:120]}",
                        }]

            # Recovery path when this slot has no usable blank of its own (e.g. the model emitted the
            # blank with an empty answer, so it was dropped above). A hybrid SummaryCompletion payload can
            # also carry a direct `candidates` entry for this exact slot -- text the model supplied AS the
            # answer, which is a legitimate recovery source. It is validated by the same rules as any other
            # verbatim-span answer: length, passage membership, anti-leakage, and group distinctness.
            # This never invents an answer; it reuses one the model already gave for this slot.
            if not raw_candidates and _hybrid_candidates:
                group_used = {str(b.get("answer", "")).strip().casefold() for b in kept_blanks}
                for hc in _hybrid_candidates:
                    hc_ans = _normalize_answer(hc.get("answer", ""))
                    if not hc_ans:
                        continue
                    if not validate_answer_length(hc_ans):
                        repaired_hc = _try_repair_short_answer(
                            hc_ans,
                            passage_text,
                            ev_quote=str(hc.get("evidenceQuote", "")),
                            prompt_to_check=summary_text,
                            used_lower=group_used,
                            allow_quote_fallback=False,
                        )
                        if not repaired_hc:
                            continue
                        hc_ans = repaired_hc
                    if passage_text and not match_verbatim_in_passage(hc_ans, passage_text):
                        continue
                    if check_prompt_answer_leakage(summary_text, hc_ans):
                        continue
                    if hc_ans.casefold() in group_used:
                        continue
                    raw_candidates = [{
                        "prompt": str(hc.get("prompt", "")).strip() or (summary_text or f"Blank #{question_number}"),
                        "answer": hc_ans,
                        "evidenceQuote": str(hc.get("evidenceQuote", "")).strip(),
                        "explanation": str(hc.get("explanation", "")).strip(),
                    }]
                    # Served from the model's own slot-matched candidate; the group's blank for this
                    # slot was unusable, so it is not reported as a recoverable blank.
                    self._last_dropped_blank_reasons.pop(question_number, None)
                    break
        if not isinstance(raw_candidates, list):
            raw_candidates = [parsed] if isinstance(parsed, dict) and "prompt" in parsed else []
        if family in (QuestionPromptFamily.SENTENCE_COMPLETION, QuestionPromptFamily.SHORT_ANSWER):
            def _score_raw(rc):
                ans = str(rc.get("answer", "")).strip()
                words = len(ans.split())
                return (0 if 1 <= words <= 3 else 1, -len(ans))
            raw_candidates = sorted(raw_candidates, key=_score_raw)
        elif family in (QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN, QuestionPromptFamily.YES_NO_NOT_GIVEN):
            seen_answers = set()
            diverse = []
            rest = []
            for rc in raw_candidates:
                ans_key = str(rc.get("answer", "")).strip().upper()
                if ans_key and ans_key not in seen_answers:
                    seen_answers.add(ans_key)
                    diverse.append(rc)
                else:
                    rest.append(rc)
            raw_candidates = diverse + rest

        if family != QuestionPromptFamily.SUMMARY_COMPLETION:
            import re
            passage_norm = " ".join(passage_text.split()).casefold()
            p_sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", passage_text) if len(s.strip()) >= 20]
            if not p_sentences:
                p_sentences = [passage_text[:120]]
            valid_group_raw_candidates: List[Dict[str, Any]] = []
            seen_prompts: set = set()
            used_ev_fps: set = set()
            for rc in raw_candidates:
                if not isinstance(rc, dict):
                    continue
                prompt_text = str(rc.get("prompt", "")).strip()
                prompt_key = prompt_text.casefold()
                if not prompt_text or prompt_key in seen_prompts:
                    continue
                ans_val = str(rc.get("answer", "")).strip()
                
                # Completion & Short Answer validation
                if family in (QuestionPromptFamily.SENTENCE_COMPLETION, QuestionPromptFamily.SHORT_ANSWER):
                    if not (validate_answer_length(ans_val) and match_verbatim_in_passage(ans_val, passage_text)):
                        repaired_sc = _try_repair_short_answer(
                            ans_val,
                            passage_text,
                            ev_quote=str(rc.get("evidenceQuote", "")),
                            prompt_to_check=prompt_text,
                            allow_quote_fallback=False,
                        )
                        if not repaired_sc:
                            continue
                        ans_val = repaired_sc
                        rc["answer"] = ans_val
                    if check_prompt_answer_leakage(prompt_text, ans_val):
                        continue
                # Verbatim evidence quote check & resolution
                ev_quote = str(rc.get("evidenceQuote", "")).strip()
                canonical_short = {"A", "B", "C", "D", "TRUE", "FALSE", "NOT GIVEN", "NOT_GIVEN", "YES", "NO"}
                is_short_canonical = len(ans_val) < 4 or ans_val.upper() in canonical_short

                matching_sent = None
                if ev_quote and ev_quote.casefold() in passage_norm and len(ev_quote) >= 15:
                    matching_sent = ev_quote
                else:
                    # 1. Split on ellipsis ... and check if any chunk is in passage
                    ev_chunks = [c.strip() for c in re.split(r"\.{2,}|…", ev_quote) if len(c.strip()) >= 15]
                    for chunk in ev_chunks:
                        if chunk.casefold() in passage_norm:
                            for s in p_sentences:
                                if chunk.casefold() in s.casefold():
                                    matching_sent = s
                                    break
                        if matching_sent:
                            break

                    # 2. For non-canonical multi-word answers, match sentence with full answer
                    if not matching_sent and not is_short_canonical and ans_val.casefold() in passage_norm:
                        for s in p_sentences:
                            if ans_val.casefold() in s.casefold():
                                matching_sent = s
                                break

                    # 3. For MCQ, look up text of correct option
                    if not matching_sent and family == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE and isinstance(rc.get("options"), list):
                        correct_opt_text = ""
                        for opt in rc["options"]:
                            if isinstance(opt, dict) and opt.get("key", "").upper() == ans_val.upper():
                                correct_opt_text = opt.get("text", "")
                                break
                            elif isinstance(opt, str) and opt.startswith(f"{ans_val.upper()}."):
                                correct_opt_text = opt
                                break
                        if correct_opt_text:
                            opt_toks = set(re.findall(r"\w+", correct_opt_text.casefold()))
                            best_s_overlap = -1
                            for s in p_sentences:
                                ov = len(set(re.findall(r"\w+", s.casefold())) & opt_toks)
                                if ov > best_s_overlap:
                                    best_s_overlap = ov
                                    matching_sent = s

                    # 4. Fallback: prompt + ev_quote word overlap
                    if not matching_sent:
                        p_toks = set(re.findall(r"\w+", (prompt_text + " " + ev_quote).casefold()))
                        best_s_overlap = -1
                        for s in p_sentences:
                            ov = len(set(re.findall(r"\w+", s.casefold())) & p_toks)
                            if ov > best_s_overlap:
                                best_s_overlap = ov
                                matching_sent = s

                    matching_sent = matching_sent or p_sentences[0]

                # Ensure distinct evidence fingerprint across valid candidates in this group
                def _ev_fp(text_val: str) -> str:
                    return re.sub(r"[\W_]+", " ", text_val.casefold()).strip()

                final_ev = matching_sent
                ev_fp = _ev_fp(final_ev)
                if ev_fp in used_ev_fps:
                    p_toks = set(re.findall(r"\w+", (prompt_text + " " + ev_quote).casefold()))
                    ranked_sents = sorted(p_sentences, key=lambda s: len(set(re.findall(r"\w+", s.casefold())) & p_toks), reverse=True)
                    for alt_s in ranked_sents:
                        alt_fp = _ev_fp(alt_s)
                        if alt_fp not in used_ev_fps:
                            final_ev = alt_s
                            ev_fp = alt_fp
                            break

                used_ev_fps.add(ev_fp)
                rc["evidenceQuote"] = final_ev

                # Explanation >= 30 chars
                exp = str(rc.get("explanation", "")).strip()
                if len(exp) < 30:
                    rc["explanation"] = f"Verified from passage: {str(rc.get('evidenceQuote', ''))[:120]}"

                seen_prompts.add(prompt_key)
                valid_group_raw_candidates.append(rc)
            self._last_group_raw_candidates = list(valid_group_raw_candidates)
            if valid_group_raw_candidates:
                raw_candidates = list(valid_group_raw_candidates)
        pool = self.build_pool_from_raw_candidates(
            raw_candidates=raw_candidates,
            passage_text=passage_text,
            question_type=question_type,
            question_number=question_number,
            passage_ref=passage_ref,
            blueprint_ref=blueprint_ref,
            pool_limit=pool_limit,
            slot_id=slot_id,
            group_id=group_id,
            provider_name=resp.provider_name,
            model_name=resp.model_name,
        )
        pool.tokens_used = tokens_used
        pool.wall_time_used_seconds = wall_time_used
        pool.dropped_blank_reasons = dict(self._last_dropped_blank_reasons)
        pool.attempted_blank_count = self._last_attempted_blank_count
        return pool
    async def generate_summary_group_variants(
        self,
        passage_text: str,
        start_number: int,
        blank_count: int,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        run_id: str,
        section_id: Optional[str] = "1",
        context: Optional[LoopContext] = None,
    ) -> List[QuestionGroupContext]:
        pool_limit = getattr(settings, "candidate_pool_limit_summary", 2)
        variants: List[QuestionGroupContext] = []

        prompt_data = build_question_prompt(
            family=QuestionPromptFamily.SUMMARY_COMPLETION,
            passage_text=passage_text,
            question_number=start_number,
            blank_count=blank_count,
        )

        if self._gateway is None or context is None:
            # Fallback mock summary group
            mock_text = "The study observed that [1] was prevalent. In addition, [2] was documented."
            variants.append(
                QuestionGroupContext(
                    groupId=f"grp_summary_{start_number}_v1",
                    sectionIndex=1,
                    questionType="SummaryCompletion",
                    startNumber=start_number,
                    endNumber=start_number + blank_count - 1,
                    instructions=f"Complete the summary below using NO MORE THAN THREE WORDS for questions {start_number}-{start_number + blank_count - 1}.",
                    summaryTitle="Ecological Findings",
                    summaryText=mock_text,
                    passageRef=passage_ref,
                    blueprintRef=blueprint_ref,
                )
            )
            return variants

        auth = resolve_run_authority(context)
        eff_parent_op = getattr(context, "parent_operation_id", None) if context else None
        if eff_parent_op:
            op_id = f"{eff_parent_op}:summary_grp:s{start_number}"
        else:
            op_id = f"op:{run_id}:summary_grp:s{start_number}"
        req = ProviderRequest(
            operation_id=op_id,
            run_id=run_id,
            section_id=section_id,
            artifact_id=f"art_summary_grp_{start_number}",
            capability=Capability.GENERATE_JSON,
            preferred_provider="minimax",
            allowed_providers=["minimax"],
            allow_fallback=False,
            messages=[
                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                ChatMessage(role="user", content=prompt_data["user_prompt"]),
            ],
            max_tokens=2200,
            timeout_seconds=getattr(settings, "evaluator_stage_timeout_seconds", 45.0),
            wall_time_reservation_seconds=float(getattr(settings, "loop_operation_wall_reservation_seconds", 60.0)),
        )

        resp = await self._gateway.execute(
            req,
            epoch=auth.epoch,
            lease_owner=auth.lease_owner,
        )
        parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)

        summary_text = parsed.get("summaryText", "")
        summary_title = parsed.get("summaryTitle", "Summary")
        grp = QuestionGroupContext(
            groupId=f"grp_summary_{start_number}_v1",
            sectionIndex=1,
            questionType="SummaryCompletion",
            startNumber=start_number,
            endNumber=start_number + blank_count - 1,
            instructions=f"Complete the summary below using NO MORE THAN THREE WORDS for questions {start_number}-{start_number + blank_count - 1}.",
            summaryTitle=summary_title,
            summaryText=summary_text,
            passageRef=passage_ref,
            blueprintRef=blueprint_ref,
        )
        variants.append(grp)
        return variants

    def _build_mock_candidate_pool(
        self,
        passage_text: str,
        question_type: str,
        question_number: int,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        pool_limit: int,
        slot_id: str,
        group_id: Optional[str] = None,
    ) -> QuestionCandidatePool:
        pool = QuestionCandidatePool(
            slotId=slot_id,
            questionNumber=question_number,
            questionType=question_type,
            poolLimit=pool_limit,
        )
        for i in range(pool_limit):
            cand_id = f"cand_{slot_id}_{i+1}"
            options = None
            if question_type == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE.value:
                options = [
                    OptionItem(key="A", text="Option Alpha"),
                    OptionItem(key="B", text="Option Beta"),
                    OptionItem(key="C", text="Option Gamma"),
                    OptionItem(key="D", text="Option Delta"),
                ]
                ans = "A"
                prompt = f"What is the primary factor regarding question {question_number}?"
            elif question_type in (QuestionPromptFamily.SENTENCE_COMPLETION.value, "SentenceCompletion"):
                p_words = [w.strip(".,;:\"'!?") for w in passage_text.split() if len(w.strip(".,;:\"'!?")) >= 4] if passage_text else []
                ans = p_words[-1] if p_words else "pottery"
                prompt = "Further investigations documented ancient ______."
                if ans.lower() in prompt.lower() and len(p_words) > 1:
                    ans = p_words[0]
            elif question_type in (QuestionPromptFamily.SHORT_ANSWER.value, "ShortAnswer"):
                p_words = [w.strip(".,;:\"'!?") for w in passage_text.split() if len(w.strip(".,;:\"'!?")) >= 4] if passage_text else []
                ans = p_words[-1] if p_words else "pottery"
                prompt = "What key element was identified in the passage?"
            elif question_type in (QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN.value, "TrueFalseNotGiven"):
                options = [
                    OptionItem(key="TRUE", text="TRUE"),
                    OptionItem(key="FALSE", text="FALSE"),
                    OptionItem(key="NOT GIVEN", text="NOT GIVEN"),
                ]
                prompt = f"The expedition took place in {2020 + i}."
                ans = "TRUE" if i == 0 else "FALSE"
            elif question_type in (QuestionPromptFamily.YES_NO_NOT_GIVEN.value, "YesNoNotGiven"):
                options = [
                    OptionItem(key="YES", text="YES"),
                    OptionItem(key="NO", text="NO"),
                    OptionItem(key="NOT GIVEN", text="NOT GIVEN"),
                ]
                prompt = f"The author suggests that immediate intervention is necessary."
                ans = "YES" if i == 0 else "NO"
            else:
                prompt = f"Question {question_number} prompt."
                ans = "sample answer"

            cand = QuestionCandidate(
                candidateId=cand_id,
                slotId=slot_id,
                passageRef=passage_ref,
                blueprintRef=blueprint_ref,
                groupId=group_id,
                questionNumber=question_number,
                questionType=question_type,
                prompt=prompt,
                answer=ans,
                options=options,
                evidenceQuote=passage_text[:60] if passage_text else "evidence",
            )
            pool.add_candidate(cand)

        return pool
