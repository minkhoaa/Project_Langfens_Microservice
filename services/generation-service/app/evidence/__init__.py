"""Evidence package for Langfens Loop Engine V2."""

from app.evidence.extractor import (
    AtomicClaim,
    extract_atomic_claims,
    extract_modality,
    extract_population,
    parse_quantities_and_units,
)
from app.evidence.graph import (
    MIN_VERIFIED_CLAIMS_FOR_PASSAGE,
    EvidenceGraphBuilder,
    EvidenceGraphBuildResult,
    EvidenceGraphStatus,
)
from app.evidence.validators import (
    ClaimValidationResult,
    EvidenceValidator,
)

__all__ = [
    # Extractor
    "AtomicClaim",
    "extract_atomic_claims",
    "extract_modality",
    "extract_population",
    "parse_quantities_and_units",
    # Validators
    "ClaimValidationResult",
    "EvidenceValidator",
    # Graph
    "MIN_VERIFIED_CLAIMS_FOR_PASSAGE",
    "EvidenceGraphBuilder",
    "EvidenceGraphBuildResult",
    "EvidenceGraphStatus",
]
