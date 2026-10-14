"""Evaluation Cache with Student-Visible Keying and Key-Swap Invariance (P10-08).

Invariants:
- Cache key is computed strictly from student-visible inputs:
  passage text, student-visible question JSON, prompt version, model name, evaluator config.
- Expected answer key is NEVER part of the cache key.
- Swapping the expected answer does NOT change the cache key or the cached solver response.
- Comparison service always re-evaluates cached solver output against current expected answer.
- Payload or dependency changes automatically yield a different cache key (invalidation).
"""

from __future__ import annotations

from collections import OrderedDict
import hashlib
import json
import logging
from typing import Any, Dict, Optional

from app.contracts.solver import (
    BlindSolverInput,
    SolverOutput,
    StudentVisibleQuestion,
)

logger = logging.getLogger(__name__)


def compute_solver_cache_key(
    passage_text: str,
    question: StudentVisibleQuestion,
    prompt_version: str,
    model_name: str,
    evaluator_config: str = "default",
) -> str:
    """Computes a collision-resistant cache key strictly from student-visible data.

    CRITICAL INVARIANT: The expected answer key is NEVER included here.
    """
    options_data = (
        [{"key": o.key, "text": o.text} for o in question.options]
        if question.options
        else None
    )
    sv_repr = {
        "questionNumber": question.question_number,
        "questionType": question.question_type,
        "prompt": question.prompt,
        "instructions": question.instructions,
        "options": options_data,
        "sharedContext": question.shared_context,
    }
    canonical_sv_json = json.dumps(sv_repr, sort_keys=True)

    tokens = [
        hashlib.sha256(passage_text.strip().encode("utf-8")).hexdigest(),
        canonical_sv_json,
        prompt_version.strip(),
        model_name.strip(),
        evaluator_config.strip(),
    ]
    raw_key = "\n---\n".join(tokens)
    return hashlib.sha256(raw_key.encode("utf-8")).hexdigest()


class BlindSolverCache:
    """In-memory bounded LRU cache for blind solver and adversary results."""

    def __init__(self, max_entries: int = 500):
        self._max_entries = max_entries
        self._solver_cache: OrderedDict[str, SolverOutput] = OrderedDict()
        self._hits = 0
        self._misses = 0

    @property
    def hits(self) -> int:
        return self._hits

    @property
    def misses(self) -> int:
        return self._misses

    def get_solver_output(self, cache_key: str) -> Optional[SolverOutput]:
        if cache_key in self._solver_cache:
            self._hits += 1
            self._solver_cache.move_to_end(cache_key)
            return self._solver_cache[cache_key]
        self._misses += 1
        return None

    def put_solver_output(self, cache_key: str, output: SolverOutput) -> None:
        if cache_key in self._solver_cache:
            self._solver_cache.move_to_end(cache_key)
        self._solver_cache[cache_key] = output
        if len(self._solver_cache) > self._max_entries:
            self._solver_cache.popitem(last=False)

    def invalidate(self) -> None:
        """Clears all cached solver outputs."""
        self._solver_cache.clear()
        self._hits = 0
        self._misses = 0


# Shared singleton cache instance
solver_cache = BlindSolverCache()
