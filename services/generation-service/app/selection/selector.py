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
        if candidate.question_type in ("SentenceCompletion", "ShortAnswer"):
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
                ev_fp = compute_evidence_fingerprint(cand.evidence_quote)

                # Constraint 1: Anti-redundancy (no duplicate evidence facts across questions)
                if not self.criteria.allow_redundant_evidence_spans:
                    if ev_fp in used_evidence_fingerprints:
                        # Check jaccard similarity with existing selections
                        has_high_overlap = any(
                            jaccard_similarity(cand.evidence_quote, prev.evidence_quote) > 0.70
                            for prev in current_selection
                        )
                        if has_high_overlap:
                            continue

                # Constraint 2: MCQ answer distribution (prevent 3 identical consecutive answers)
                if cand.options and cand.answer:
                    if len(mcq_answers) >= 2 and mcq_answers[-1] == mcq_answers[-2] == cand.answer:
                        continue

                # Recursive advance
                new_ev_fps = set(used_evidence_fingerprints)
                if ev_fp:
                    new_ev_fps.add(ev_fp)
                new_mcqs = list(mcq_answers)
                if cand.options and cand.answer:
                    new_mcqs.append(cand.answer)

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
            raise SelectionInfeasibleError(
                "Could not satisfy joint constraints across question pools",
                step_count=steps,
                reason="JOINT_CONSTRAINTS_UNSATISFIABLE",
            )

        # Update selectedCandidateId on pools
        for pool, cand in zip(pools, selected):
            pool.selected_candidate_id = cand.candidate_id

        return selected
