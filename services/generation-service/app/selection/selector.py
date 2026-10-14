"""Candidate Selection and Joint Constraint Solver (Phase 09 / P09-07 & P09-08).

Implements:
1. Candidate ranking with normalized weights across grounding, distractors, lexical diversity, and length.
2. Deterministic tie-breaking on (-score, candidate_id, content_hash).
3. Joint group constraints:
   - Anti-redundancy: no two questions test the exact same evidence sentence/fact.
   - Distinct evidence spans.
   - MCQ answer balance (prevents identical key repetition).
4. Bounded backtracking search with finite step caps from Settings.
5. Infeasible escalation with typed SelectionInfeasibleError.
"""

from __future__ import annotations

import hashlib
import logging
import re
from typing import Any, Dict, List, Optional, Set, Tuple

from app.config import settings
from app.contracts.policies import count_words
from app.generators.question.context import (
    CandidateSelectionCriteria,
    QuestionCandidate,
    QuestionCandidatePool,
)

logger = logging.getLogger(__name__)


class SelectionInfeasibleError(Exception):
    """Raised when joint constraints cannot be satisfied within finite search caps."""

    def __init__(self, message: str, step_count: int, reason: str = ""):
        super().__init__(message)
        self.step_count = step_count
        self.reason = reason


def compute_evidence_fingerprint(evidence_quote: str) -> str:
    """Computes a normalized word-level fingerprint to detect duplicate fact targeting."""
    words = [w.lower() for w in re.findall(r"\b\w+\b", evidence_quote) if len(w) > 3]
    if not words:
        return evidence_quote.strip().lower()
    return " ".join(sorted(set(words)))


def jaccard_similarity(s1: str, s2: str) -> float:
    w1 = set(re.findall(r"\b\w+\b", s1.lower()))
    w2 = set(re.findall(r"\b\w+\b", s2.lower()))
    if not w1 or not w2:
        return 0.0
    return len(w1 & w2) / len(w1 | w2)


class CandidateSelector:
    """Ranks and solves joint constraints across candidate pools for a section."""

    def __init__(self, criteria: Optional[CandidateSelectionCriteria] = None):
        self.criteria = criteria or CandidateSelectionCriteria(
            max_search_depth=getattr(settings, "candidate_max_search_depth", 50),
            max_backtracking_steps=getattr(settings, "candidate_max_backtracking_steps", 100),
        )

    def score_candidate(self, candidate: QuestionCandidate) -> float:
        """Calculates a normalized quality score [0.0, 1.0] for a candidate."""
        if not candidate.is_eligible():
            return 0.0

        # 1. Grounding component (evidence presence and length)
        g_score = 1.0 if candidate.evidence_quote and len(candidate.evidence_quote) > 15 else 0.5

        # 2. Distractor component for MCQ
        d_score = 1.0
        if candidate.options:
            opt_texts = [o.text.strip().lower() for o in candidate.options]
            # Penalize if options have severe length disparity or identical wording
            lengths = [len(t) for t in opt_texts]
            if max(lengths) > 3 * min(lengths) and min(lengths) < 5:
                d_score = 0.6
            elif len(set(opt_texts)) < 4:
                d_score = 0.0

        # 3. Length compliance
        l_score = 1.0
        if str(candidate.question_type).replace("_", "").upper() in ("SENTENCECOMPLETION", "SUMMARYCOMPLETION", "SHORTANSWER"):
            w_cnt = count_words(candidate.answer)
            if w_cnt > 3:
                l_score = 0.0
            elif w_cnt == 0:
                l_score = 0.0

        # 4. Lexical diversity in prompt
        prompt_words = re.findall(r"\b\w+\b", candidate.prompt.lower())
        unique_ratio = len(set(prompt_words)) / max(1, len(prompt_words))
        lex_score = min(1.0, unique_ratio * 1.2)

        total_score = (
            self.criteria.grounding_weight * g_score
            + self.criteria.distractor_quality_weight * d_score
            + self.criteria.length_compliance_weight * l_score
            + self.criteria.lexical_diversity_weight * lex_score
        )
        candidate.score = round(total_score, 4)
        return candidate.score

    def sort_pool_deterministically(self, pool: QuestionCandidatePool) -> List[QuestionCandidate]:
        """Sorts candidates by (-score, candidate_id) for deterministic tie-breaking."""
        for c in pool.candidates:
            self.score_candidate(c)

        eligible = pool.get_eligible_candidates()
        # Deterministic ordering: higher score first; tie-break on candidateId
        return sorted(
            eligible,
            key=lambda c: (-c.score, c.candidate_id, hashlib.sha256(c.prompt.encode()).hexdigest()),
        )

    def select_joint_group(
        self,
        pools: List[QuestionCandidatePool],
        external_prompts: Optional[List[str]] = None,
        topic: str = "",
        passage_title: str = "",
    ) -> List[QuestionCandidate]:
        """Solves joint constraints across all question slots in order with finite backtracking."""
        if not pools:
            return []

        sorted_pools: List[List[QuestionCandidate]] = [
            self.sort_pool_deterministically(p) for p in pools
        ]

        # Verify that all pools have at least one eligible candidate
        for idx, candidates in enumerate(sorted_pools):
            if not candidates:
                raise SelectionInfeasibleError(
                    f"Slot {pools[idx].slot_id} has zero eligible candidates",
                    step_count=0,
                    reason="EMPTY_ELIGIBLE_POOL",
                )

        steps = 0
        max_steps = self.criteria.max_backtracking_steps
        from app.evaluators.deterministic import (
            check_cross_prompt_answer_leakage,
            check_prompt_answer_leakage,
        )
        from app.evaluators.paper import (
            STANDARD_CHOICE_LABELS,
            _answer_tokens_present_in_prompt,
            _extract_question_predicate,
            _quote_appears_in_prompt,
        )
        from app.contracts.policies import calculate_shingle_overlap, normalize_prompt

        SHARED_GROUP_TYPES = {
            "summarycompletion", "summarygroup", "notecompletiongroup",
            "flowchartcompletion", "matchingheadings", "matchingheading",
            "matching_headings", "summary_completion", "matching",
        }

        def _are_same_group_siblings(c1: QuestionCandidate, c2: QuestionCandidate) -> bool:
            t1 = str(getattr(c1, "question_type", "")).replace("_", "").lower()
            t2 = str(getattr(c2, "question_type", "")).replace("_", "").lower()
            if t1 not in SHARED_GROUP_TYPES or t1 != t2:
                return False
            g1 = str(c1.group_id or "").strip().lower()
            g2 = str(c2.group_id or "").strip().lower()
            return bool(g1 and g2 and g1 == g2)

        def _leaks_into_prompt(q_cand: QuestionCandidate, other_prompt: str) -> bool:
            if not other_prompt:
                return False
            ans_str = str(q_cand.answer or "").strip()
            if ans_str and ans_str.upper() not in STANDARD_CHOICE_LABELS:
                if check_cross_prompt_answer_leakage(other_prompt, ans_str, topic=topic, passage_title=passage_title):
                    return True
                ans_words = ans_str.split()
                q_pred = _extract_question_predicate(q_cand.prompt)
                o_pred = _extract_question_predicate(other_prompt)
                if len(ans_words) >= 2:
                    if check_prompt_answer_leakage(other_prompt, ans_str):
                        return True
                    if q_pred and o_pred and q_pred == o_pred and _answer_tokens_present_in_prompt(ans_str, other_prompt):
                        return True
                elif len(ans_words) == 1 and len(ans_str) >= 4:
                    if q_pred and o_pred and q_pred == o_pred and check_prompt_answer_leakage(other_prompt, ans_str):
                        return True
            ev_q = str(q_cand.evidence_quote or "").strip()
            if ev_q and (len(ev_q.split()) >= 2 or len(ev_q) >= 8) and _quote_appears_in_prompt(ev_q, other_prompt):
                return True
            return False

        # Backtracking search for combination satisfying joint constraints
        def backtrack(
            pool_idx: int,
            current_selection: List[QuestionCandidate],
            used_evidence_fingerprints: Set[str],
            mcq_answers: List[str],
        ) -> Optional[List[QuestionCandidate]]:
            nonlocal steps
            steps += 1
            if steps > max_steps:
                raise SelectionInfeasibleError(
                    f"Selection exceeded max backtracking steps ({max_steps})",
                    step_count=steps,
                    reason="SEARCH_BUDGET_EXCEEDED",
                )

            if pool_idx == len(sorted_pools):
                return current_selection

            for cand in sorted_pools[pool_idx]:
                c_type_norm = str(getattr(cand, "question_type", "")).replace("_", "").lower()
                is_group_shared_type = c_type_norm in SHARED_GROUP_TYPES

                def is_same_group_sibling(prev_cand: QuestionCandidate) -> bool:
                    return _are_same_group_siblings(cand, prev_cand)

                # Self-leakage guard for non-fixed-choice types
                if cand.answer and str(cand.answer).strip().upper() not in STANDARD_CHOICE_LABELS:
                    if c_type_norm not in ("truefalsenotgiven", "yesnonotgiven") and check_prompt_answer_leakage(cand.prompt, str(cand.answer)):
                        logger.info("Candidate %s rejected: self-leakage of answer %r in prompt", cand.candidate_id, cand.answer)
                        continue
                if external_prompts and any(_leaks_into_prompt(cand, ep) for ep in external_prompts if ep):
                    logger.info("Candidate %s (Q%s %s ans=%r) rejected: leaks in external prompt", cand.candidate_id, cand.question_number, cand.question_type, cand.answer)
                    continue
                if current_selection and any(
                    not is_same_group_sibling(prev)
                    and (_leaks_into_prompt(cand, prev.prompt) or _leaks_into_prompt(prev, cand.prompt))
                    for prev in current_selection
                ):
                    logger.info("Candidate %s (Q%s %s ans=%r) rejected: leaks with current selection prompt", cand.candidate_id, cand.question_number, cand.question_type, cand.answer)
                    continue
                if current_selection:
                    # Group blanks must have distinct answers (e.g. for Summary Completion with explicit matching group ID)
                    if is_group_shared_type and any(
                        is_same_group_sibling(prev)
                        and cand.answer and prev.answer and str(cand.answer).strip().lower() == str(prev.answer).strip().lower()
                        for prev in current_selection
                    ):
                        logger.info("Candidate %s rejected: duplicate group answer %r", cand.candidate_id, cand.answer)
                        continue
                # Constraint 0: Prompt uniqueness & 5-word shingle overlap (<= 0.45) against external and current selection
                cand_p_norm = normalize_prompt(cand.prompt)
                if cand_p_norm:
                    if not is_group_shared_type and external_prompts and any(
                        cand_p_norm == normalize_prompt(ep) or calculate_shingle_overlap(cand.prompt, ep) > 0.45
                        for ep in external_prompts if ep
                    ):
                        logger.info("Candidate %s rejected: duplicate prompt or shingle overlap >0.45 with external", cand.candidate_id)
                        continue
                    if current_selection and any(
                        not is_same_group_sibling(prev)
                        and (cand_p_norm == normalize_prompt(prev.prompt) or calculate_shingle_overlap(cand.prompt, prev.prompt) > 0.45)
                        for prev in current_selection if prev.prompt
                    ):
                        logger.info("Candidate %s rejected: duplicate prompt or shingle overlap >0.45 with current selection", cand.candidate_id)
                        continue
                ev_fp = compute_evidence_fingerprint(cand.evidence_quote)
                # Constraint 1: Anti-redundancy (no duplicate evidence facts across questions)
                if not self.criteria.allow_redundant_evidence_spans:
                    if ev_fp and ev_fp in used_evidence_fingerprints:
                        # Check jaccard similarity with existing selections for non-group questions
                        has_high_overlap = any(
                            not is_same_group_sibling(prev)
                            and (cand.evidence_quote.strip().lower() == prev.evidence_quote.strip().lower()
                                 or jaccard_similarity(cand.evidence_quote, prev.evidence_quote) > 0.85)
                            for prev in current_selection if prev.evidence_quote
                        )
                        if has_high_overlap:
                            logger.info("Candidate %s rejected: high evidence overlap", cand.candidate_id)
                            continue
                # Constraint 2: Answer distribution balance (prevent 4 identical consecutive answers in MCQ, TFNG, YNNG)
                norm_ans = str(cand.answer).strip().upper()
                if norm_ans in {"A", "B", "C", "D", "TRUE", "FALSE", "NOT GIVEN", "NOT_GIVEN", "YES", "NO"}:
                    if len(mcq_answers) >= 3 and mcq_answers[-1] == mcq_answers[-2] == mcq_answers[-3] == norm_ans:
                        continue
                # Recursive advance
                new_ev_fps = set(used_evidence_fingerprints)
                if ev_fp:
                    new_ev_fps.add(ev_fp)
                new_mcqs = list(mcq_answers)
                if norm_ans in {"A", "B", "C", "D", "TRUE", "FALSE", "NOT GIVEN", "NOT_GIVEN", "YES", "NO"}:
                    new_mcqs.append(norm_ans)

                result = backtrack(
                    pool_idx + 1,
                    current_selection + [cand],
                    new_ev_fps,
                    new_mcqs,
                )
                if result is not None:
                    return result

            return None

        selected = backtrack(
            pool_idx=0,
            current_selection=[],
            used_evidence_fingerprints=set(),
            mcq_answers=[],
        )

        if selected is None:
            # Graceful fallback pass: select the top eligible candidate for each pool,
            # ensuring no exact prompt duplicates across the selection or with external prompts
            from app.contracts.policies import normalize_prompt
            logger.warning("Backtracking failed to satisfy joint constraints; executing graceful fallback pass")
            fallback_selection: List[QuestionCandidate] = []
            used_prompts: Set[str] = set()
            used_ev_fps: Set[str] = set()
            if external_prompts:
                for ep in external_prompts:
                    if ep:
                        used_prompts.add(normalize_prompt(ep))

            for p_idx, pool_cands in enumerate(sorted_pools):
                chosen = None
                for relax_ev_redundancy in (False, True):
                    for cand in pool_cands:
                        c_type_norm = str(getattr(cand, "question_type", "")).replace("_", "").lower()
                        is_group_shared_type = c_type_norm in SHARED_GROUP_TYPES
                        if relax_ev_redundancy and not (is_group_shared_type or self.criteria.allow_redundant_evidence_spans):
                            continue
                        c_p_norm = normalize_prompt(cand.prompt) if cand.prompt else ""
                        if not is_group_shared_type and c_p_norm and c_p_norm in used_prompts:
                            continue
                        if not is_group_shared_type and external_prompts and any(
                            calculate_shingle_overlap(cand.prompt, ep) > 0.45 for ep in external_prompts if ep
                        ):
                            continue
                        if not is_group_shared_type and any(
                            not _are_same_group_siblings(cand, prev)
                            and calculate_shingle_overlap(cand.prompt, prev.prompt) > 0.45
                            for prev in fallback_selection if prev.prompt
                        ):
                            continue
                        cand_ans_str = str(getattr(cand, "answer", "") or "").strip()
                        if cand_ans_str and cand_ans_str.upper() not in STANDARD_CHOICE_LABELS:
                            if c_type_norm not in ("truefalsenotgiven", "yesnonotgiven") and check_prompt_answer_leakage(cand.prompt, cand_ans_str):
                                continue
                        if external_prompts and any(_leaks_into_prompt(cand, ep) for ep in external_prompts if ep):
                            continue
                        if any(
                            not _are_same_group_siblings(cand, prev)
                            and (_leaks_into_prompt(cand, prev.prompt) or _leaks_into_prompt(prev, cand.prompt))
                            for prev in fallback_selection
                        ):
                            continue
                        ev_fp = compute_evidence_fingerprint(cand.evidence_quote)
                        if not relax_ev_redundancy and not is_group_shared_type and not self.criteria.allow_redundant_evidence_spans and ev_fp and ev_fp in used_ev_fps:
                            continue
                        # If shared group type and prompt was seen, ensure sibling answer is distinct
                        if is_group_shared_type:
                            cand_ans = cand_ans_str.lower()
                            if cand_ans and any(
                                str(getattr(prev, "answer", "") or "").strip().lower() == cand_ans
                                for prev in fallback_selection
                            ):
                                continue
                        chosen = cand
                        break
                    if chosen is not None:
                        break
                if chosen is not None:
                    fallback_selection.append(chosen)
                    c_p_norm_chosen = normalize_prompt(chosen.prompt) if chosen.prompt else ""
                    if c_p_norm_chosen:
                        used_prompts.add(c_p_norm_chosen)
                    ev_fp_chosen = compute_evidence_fingerprint(chosen.evidence_quote)
                    if ev_fp_chosen:
                        used_ev_fps.add(ev_fp_chosen)
            if len(fallback_selection) == len(sorted_pools):
                selected = fallback_selection
            else:
                raise SelectionInfeasibleError(
                    "Could not satisfy joint constraints across question pools",
                    step_count=steps,
                    reason="JOINT_CONSTRAINTS_UNSATISFIABLE",
                )
        # Update selectedCandidateId on pools
        for pool, cand in zip(pools, selected):
            pool.selected_candidate_id = cand.candidate_id

        return selected
