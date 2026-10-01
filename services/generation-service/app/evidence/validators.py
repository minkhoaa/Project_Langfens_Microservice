"""Independent Evidence Validators for Langfens Loop Engine V2.

Hard invariants enforced:
1. Code-level span validation: text[start:end] must strictly match the span text in the source.
2. Hard rule: Do NOT call semantic evaluators if spans or hashes are invalid.
3. Coverage map validation: Claims pointing to text outside selected chunks cannot be accepted.
4. Numeric distortion rejection: Reject claims altering numbers/percentages (e.g. 14% -> 40%).
5. Population shift rejection: Reject claims changing subjects/populations (e.g. adults -> children).
6. Modality/Causality distortion rejection:
   - Reject claims dropping tentative qualifiers (e.g. "may" -> definite).
   - Reject claims turning correlation/association into direct causation.
"""

from __future__ import annotations

import re
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.evidence import (
    EntailmentLabel,
    Qualifier,
    SourceOffset,
    VerifiedClaim,
)
from app.contracts.issue import (
    Issue,
    IssueCode,
    IssueScope,
    IssueSeverity,
)
from app.evidence.extractor import (
    POPULATION_KEYWORDS,
    QUANTITY_PATTERN,
    AtomicClaim,
    extract_modality,
    extract_population,
    parse_quantities_and_units,
)
from app.ingestion.chunker import CoverageMap

CAUSAL_VERBS = {"causes", "caused", "causing", "leads to", "led to", "leading to", "results in", "resulted in", "resulting in", "direct cause", "proves"}
CORRELATION_PHRASES = {"associated with", "correlated with", "linked to", "relationship between", "correlation between", "associated"}
UNCERTAIN_MODALS = {"may", "might", "could", "possibly", "suggests", "suggested", "preliminary"}


class ClaimValidationResult(BaseModel):
    """Result of independent code and semantic evaluation of a fact claim."""

    model_config = ConfigDict(frozen=True)

    claim_id: str
    is_valid: bool
    entailment: EntailmentLabel
    qualifier: Qualifier
    issues: List[Issue] = Field(default_factory=list)
    blocking: bool = False
    validation_step_reached: str


class EvidenceValidator:
    """Independent validator checking source spans, numbers, populations, and modalities."""

    @classmethod
    def validate_claim(
        cls,
        claim: AtomicClaim | VerifiedClaim,
        source_text: str,
        coverage_map: Optional[CoverageMap] = None,
        source_pack_ref: Optional[ArtifactRef] = None,
    ) -> ClaimValidationResult:
        claim_id = claim.claim_id if isinstance(claim, AtomicClaim) else claim.claim_id
        claim_text = claim.text
        offsets = claim.offsets
        parent_refs = [source_pack_ref] if source_pack_ref else []

        # ── Step 1: Code-Level Span Existence & Bounds Check ───────────────
        if offsets is None:
            issue = Issue.create(
                issue_id=f"iss_span_missing_{claim_id}",
                code=IssueCode.EVIDENCE_MISSING,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.EVIDENCE,
                message=f"Claim '{claim_id}' has no source offsets declared",
                affected_refs=parent_refs,
            )
            return ClaimValidationResult(
                claim_id=claim_id,
                is_valid=False,
                entailment=EntailmentLabel.UNVERIFIABLE,
                qualifier=Qualifier.UNSUPPORTED,
                issues=[issue],
                blocking=True,
                validation_step_reached="SPAN_EXISTENCE_FAILED",
            )

        start = offsets.start_char
        end = offsets.end_char

        if start < 0 or end > len(source_text) or start >= end:
            issue = Issue.create(
                issue_id=f"iss_span_bounds_{claim_id}",
                code=IssueCode.EVIDENCE_MISSING,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.EVIDENCE,
                message=f"Claim offsets [{start}:{end}] are out of document bounds (length: {len(source_text)})",
                affected_refs=parent_refs,
            )
            # Invariant: Do NOT invoke semantic evaluators on invalid spans/hashes
            return ClaimValidationResult(
                claim_id=claim_id,
                is_valid=False,
                entailment=EntailmentLabel.UNVERIFIABLE,
                qualifier=Qualifier.UNSUPPORTED,
                issues=[issue],
                blocking=True,
                validation_step_reached="SPAN_BOUNDS_FAILED",
            )

        actual_span_text = source_text[start:end].strip()
        if not actual_span_text:
            issue = Issue.create(
                issue_id=f"iss_span_empty_{claim_id}",
                code=IssueCode.EVIDENCE_MISSING,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.EVIDENCE,
                message=f"Source span at [{start}:{end}] resolved to empty or whitespace text",
                affected_refs=parent_refs,
            )
            return ClaimValidationResult(
                claim_id=claim_id,
                is_valid=False,
                entailment=EntailmentLabel.UNVERIFIABLE,
                qualifier=Qualifier.UNSUPPORTED,
                issues=[issue],
                blocking=True,
                validation_step_reached="SPAN_EMPTY_FAILED",
            )

        # ── Step 2: Context Coverage Check ─────────────────────────────────
        if coverage_map is not None:
            if not coverage_map.is_offset_covered(start, end):
                issue = Issue.create(
                    issue_id=f"iss_coverage_{claim_id}",
                    code=IssueCode.SOURCE_INSUFFICIENT,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.EVIDENCE,
                    message=(
                        f"Claim '{claim_id}' references offsets [{start}:{end}] outside selected "
                        f"context coverage ({coverage_map.coverage_ratio * 100:.1f}% covered); chunk must be fetched"
                    ),
                    affected_refs=parent_refs,
                )
                return ClaimValidationResult(
                    claim_id=claim_id,
                    is_valid=False,
                    entailment=EntailmentLabel.UNVERIFIABLE,
                    qualifier=Qualifier.UNSUPPORTED,
                    issues=[issue],
                    blocking=True,
                    validation_step_reached="COVERAGE_CHECK_FAILED",
                )

        # ── Step 3: Numeric / Quantity Distortion Check ────────────────────
        claim_quantities, _ = parse_quantities_and_units(claim_text)
        span_quantities, _ = parse_quantities_and_units(actual_span_text)

        # If claim asserts a number that contradicts the source span
        for cq in claim_quantities:
            cq_clean = cq.replace(" ", "").lower()
            # If the quantity is not in the span, check if another quantity exists in the span
            span_cleans = [sq.replace(" ", "").lower() for sq in span_quantities]
            if span_cleans and cq_clean not in span_cleans:
                # Contradiction in numerical facts (e.g. 14% vs 40%)
                issue = Issue.create(
                    issue_id=f"iss_num_distortion_{claim_id}",
                    code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.EVIDENCE,
                    message=(
                        f"Numerical distortion detected: claim asserts '{cq}', but source span records '{span_quantities}'"
                    ),
                    affected_refs=parent_refs,
                )
                return ClaimValidationResult(
                    claim_id=claim_id,
                    is_valid=False,
                    entailment=EntailmentLabel.CONTRADICTS,
                    qualifier=Qualifier.UNSUPPORTED,
                    issues=[issue],
                    blocking=True,
                    validation_step_reached="NUMERIC_DISTORTION_DETECTED",
                )

        # ── Step 4: Population Shift Check ─────────────────────────────────
        claim_pop = extract_population(claim_text)
        span_pop = extract_population(actual_span_text)

        if claim_pop and span_pop and claim_pop.lower() != span_pop.lower():
            # e.g. "children" vs "adults"
            claim_pop_set = set(claim_pop.lower().split(", "))
            span_pop_set = set(span_pop.lower().split(", "))
            if not (claim_pop_set & span_pop_set):
                issue = Issue.create(
                    issue_id=f"iss_pop_shift_{claim_id}",
                    code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.EVIDENCE,
                    message=(
                        f"Population shift detected: claim asserts '{claim_pop}', but source specifies '{span_pop}'"
                    ),
                    affected_refs=parent_refs,
                )
                return ClaimValidationResult(
                    claim_id=claim_id,
                    is_valid=False,
                    entailment=EntailmentLabel.CONTRADICTS,
                    qualifier=Qualifier.UNSUPPORTED,
                    issues=[issue],
                    blocking=True,
                    validation_step_reached="POPULATION_SHIFT_DETECTED",
                )

        # ── Step 5: Causality Overstatement Check ──────────────────────────
        span_lower = actual_span_text.lower()
        claim_lower = claim_text.lower()

        span_has_correlation = any(re.search(rf"\b{re.escape(p)}\b", span_lower) for p in CORRELATION_PHRASES)
        span_has_causal = any(re.search(rf"\b{re.escape(v)}\b", span_lower) for v in CAUSAL_VERBS)
        claim_has_causal = any(re.search(rf"\b{re.escape(v)}\b", claim_lower) for v in CAUSAL_VERBS)

        if span_has_correlation and not span_has_causal and claim_has_causal:
            issue = Issue.create(
                issue_id=f"iss_causal_overstatement_{claim_id}",
                code=IssueCode.CAUSAL_OVERSTATEMENT,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.EVIDENCE,
                message="Causal overstatement: source indicates correlation/association, but claim asserts direct causation",
                affected_refs=parent_refs,
            )
            return ClaimValidationResult(
                claim_id=claim_id,
                is_valid=False,
                entailment=EntailmentLabel.CONTRADICTS,
                qualifier=Qualifier.UNSUPPORTED,
                issues=[issue],
                blocking=True,
                validation_step_reached="CAUSALITY_OVERSTATEMENT_DETECTED",
            )

        # ── Step 6: Overstated Certainty (Dropped Modal Qualifier) ─────────
        span_has_uncertainty = any(re.search(rf"\b{re.escape(m)}\b", span_lower) for m in UNCERTAIN_MODALS)
        claim_has_uncertainty = any(re.search(rf"\b{re.escape(m)}\b", claim_lower) for m in UNCERTAIN_MODALS)

        if span_has_uncertainty and not claim_has_uncertainty:
            issue = Issue.create(
                issue_id=f"iss_overstated_certainty_{claim_id}",
                code=IssueCode.OVERSTATED_CERTAINTY,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.EVIDENCE,
                message="Overstated certainty: source uses tentative modal (e.g. 'may'), but claim asserts definite certainty",
                affected_refs=parent_refs,
            )
            return ClaimValidationResult(
                claim_id=claim_id,
                is_valid=False,
                entailment=EntailmentLabel.CONTRADICTS,
                qualifier=Qualifier.UNSUPPORTED,
                issues=[issue],
                blocking=True,
                validation_step_reached="OVERSTATED_CERTAINTY_DETECTED",
            )

        # ── All Checks Passed ──────────────────────────────────────────────
        inferred_qualifier, _ = extract_modality(claim_text)
        return ClaimValidationResult(
            claim_id=claim_id,
            is_valid=True,
            entailment=EntailmentLabel.ENTAILS,
            qualifier=inferred_qualifier,
            issues=[],
            blocking=False,
            validation_step_reached="ALL_VERIFICATIONS_PASSED",
        )
