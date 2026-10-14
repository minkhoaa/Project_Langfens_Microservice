"""Provider Diversity and Model Correlation Tracking (P10-06).

Invariants:
- Accurately traces actual provider and model versions for solver and adversary.
- Disallows claiming "independent review" when the same model is used across prompts.
- Explicitly flags correlated_review = True and records limitations when single-model setup is used.
- Prohibits fabricating or mocking external reviewers.
"""

from __future__ import annotations

import logging
from typing import Optional, Tuple

from app.config import settings
from app.contracts.solver import DiversityProfile

logger = logging.getLogger(__name__)


def build_diversity_profile(
    solver_provider: str,
    solver_model: str,
    adversary_provider: str,
    adversary_model: str,
) -> DiversityProfile:
    """Builds a verified diversity profile and assesses statistical independence."""
    s_prov = solver_provider.strip().lower()
    s_mod = solver_model.strip().lower()
    a_prov = adversary_provider.strip().lower()
    a_mod = adversary_model.strip().lower()

    # Same model identification: provider and model matches
    if s_prov == a_prov and s_mod == a_mod:
        is_independent = False
        correlated = True
        note = (
            f"Correlated review limitation: solver and adversary share model '{solver_model}' "
            f"on provider '{solver_provider}'. Statistical independence is not achieved."
        )
        logger.info("Diversity profile: %s", note)
    else:
        is_independent = True
        correlated = False
        note = None
        logger.info(
            "Diversity profile: independent models configured (solver=%s/%s, adversary=%s/%s)",
            solver_provider,
            solver_model,
            adversary_provider,
            adversary_model,
        )

    return DiversityProfile(
        solver_provider=solver_provider,
        solver_model=solver_model,
        adversary_provider=adversary_provider,
        adversary_model=adversary_model,
        is_independent_model=is_independent,
        correlated_review=correlated,
        limitation_note=note,
    )


def resolve_model_diversity_config() -> Tuple[Tuple[str, str], Tuple[str, str]]:
    """Inspects configured provider credentials and returns the best diversity pairing.

    Returns:
        ((solver_provider, solver_model), (adversary_provider, adversary_model))
    """
    has_minimax = bool(getattr(settings, "minimax_api_key", None) or getattr(settings, "minimax_api_keys", None))
    has_groq = bool(getattr(settings, "groq_api_key", None) or getattr(settings, "groq_api_keys", None))
    minimax_mod = getattr(settings, "minimax_model", "MiniMax-Text-01")
    groq_mod = getattr(settings, "groq_model", "openai/gpt-oss-20b")

    # Prefer distinct providers if multiple are configured
    if has_minimax and has_groq:
        return (("minimax", minimax_mod), ("groq", groq_mod))
    if has_minimax:
        return (("minimax", minimax_mod), ("minimax", minimax_mod))
    if has_groq:
        return (("groq", groq_mod), ("groq", groq_mod))

    # Fallback to mock provider for offline / test double environments
    return (("mock", "mock-default"), ("mock", "mock-default"))
