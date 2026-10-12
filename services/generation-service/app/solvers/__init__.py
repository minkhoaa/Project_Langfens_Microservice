"""Langfens Blind Solver and Adversary Package (Phase 10)."""

from app.contracts.solver import (
    AdjudicationResult,
    AdjudicationVerdict,
    AdversaryAlternative,
    AdversaryAmbiguityType,
    AdversaryOutput,
    BlindSolverInput,
    ComparisonResult,
    DisagreementSeverity,
    DiversityProfile,
    SecurityLeakageError,
    SolverOutput,
    SolverSpan,
    StudentVisibleOption,
    StudentVisibleQuestion,
)
from app.solvers.adjudication import adjudicate_item
from app.solvers.adversary import parse_and_validate_adversary_output
from app.solvers.cache import BlindSolverCache, compute_solver_cache_key, solver_cache
from app.solvers.comparison import compare_answers
from app.solvers.diversity import build_diversity_profile, resolve_model_diversity_config
from app.solvers.prompts import (
    ADVERSARY_PROMPT_VERSION,
    SOLVER_PROMPT_VERSION,
    build_adversary_messages,
    build_solver_messages,
    get_adversary_asset_info,
    get_solver_asset_info,
    redact_solver_payload,
)
from app.solvers.serializer import (
    build_blind_solver_input,
    build_secure_envelope,
    project_to_student_visible,
)
from app.solvers.solver import (
    normalize_solver_answer,
    parse_and_validate_solver_output,
)

__all__ = [
    "AdjudicationResult",
    "AdjudicationVerdict",
    "AdversaryAlternative",
    "AdversaryAmbiguityType",
    "AdversaryOutput",
    "BlindSolverCache",
    "BlindSolverInput",
    "ComparisonResult",
    "DisagreementSeverity",
    "DiversityProfile",
    "SecurityLeakageError",
    "SolverOutput",
    "SolverSpan",
    "StudentVisibleOption",
    "StudentVisibleQuestion",
    "adjudicate_item",
    "build_adversary_messages",
    "build_blind_solver_input",
    "build_diversity_profile",
    "build_secure_envelope",
    "build_solver_messages",
    "compare_answers",
    "compute_solver_cache_key",
    "get_adversary_asset_info",
    "get_solver_asset_info",
    "normalize_solver_answer",
    "parse_and_validate_adversary_output",
    "parse_and_validate_solver_output",
    "project_to_student_visible",
    "redact_solver_payload",
    "resolve_model_diversity_config",
    "solver_cache",
]
