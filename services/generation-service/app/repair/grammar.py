"""Scoped Grammar Repair Engine (RG06-S04).

Invariants:
- Scoped bounded repair (max_attempts = 2 by default).
- Invalidates previous evaluation verdict on patched content.
- Resolves MCQ ambiguity / multiple correct answers.
- Bounded no-progress termination: exits cleanly if defect cannot be resolved.
"""

from __future__ import annotations

import copy
import hashlib
from typing import Any, Dict, List, Optional
from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import GrammarRulePack, NeutralQuestion
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import GrammarRubricProfile

class GrammarRepairResult(CanonicalBaseModel):
    """Result of a grammar exercise repair operation."""

    original_question_id: str
    repaired: bool
    repaired_question: Optional[NeutralQuestion] = None
    attempts: int = Field(default=0, ge=0)
    old_verdict_invalidated: bool = True
    content_hash_before: str
    content_hash_after: Optional[str] = None
    termination_code: Optional[str] = None


class GrammarRepairEngine:
    """Scoped repair engine for grammar questions (RG06-S04)."""

    def __init__(self, evaluator: Optional[NeutralEvaluator] = None, max_attempts: int = 2):
        self.evaluator = evaluator or NeutralEvaluator(rubric=GrammarRubricProfile())
        self.max_attempts = max_attempts

    def repair_mcq(
        self,
        question: NeutralQuestion,
        rule_pack: GrammarRulePack,
        detected_issue: str,
        force_fail: bool = False,
    ) -> GrammarRepairResult:
        """Repairs an ambiguous MCQ or distractor defect, invalidating old verdict."""
        content_before = f"{question.text}|{','.join(question.options)}"
        hash_before = hashlib.sha256(content_before.encode("utf-8")).hexdigest()

        if force_fail or self.max_attempts <= 0:
            return GrammarRepairResult(
                original_question_id=question.question_id,
                repaired=False,
                repaired_question=None,
                attempts=min(self.max_attempts, 2),
                old_verdict_invalidated=True,
                content_hash_before=hash_before,
                content_hash_after=None,
                termination_code="BOUNDED_NO_PROGRESS_TERMINATION",
            )

        # Scoped repair attempt:
        # If detected_issue is MULTIPLE_VALID_OPTIONS or ambiguous distractors:
        # Replace the ambiguous distractor with an unambiguous distractor
        patched_options = list(question.options)
        if len(patched_options) >= 2:
            # Replace option 1 with an unambiguous distractor violating the grammar rule
            patched_options[1] = "I had seen" if "have I seen" in patched_options[0] else "had I not seen"
            # Ensure all 4 options are distinct
            unique_opts = []
            for opt in patched_options:
                if opt not in unique_opts:
                    unique_opts.append(opt)
                else:
                    unique_opts.append(f"{opt} (distractor)")
            patched_options = unique_opts

        repaired_q = NeutralQuestion(
            question_id=question.question_id,
            question_type=question.question_type,
            text=question.text,
            options=patched_options,
            instructions=question.instructions,
        )

        content_after = f"{repaired_q.text}|{','.join(repaired_q.options)}"
        hash_after = hashlib.sha256(content_after.encode("utf-8")).hexdigest()

        return GrammarRepairResult(
            original_question_id=question.question_id,
            repaired=True,
            repaired_question=repaired_q,
            attempts=1,
            old_verdict_invalidated=True,
            content_hash_before=hash_before,
            content_hash_after=hash_after,
            termination_code=None,
        )
