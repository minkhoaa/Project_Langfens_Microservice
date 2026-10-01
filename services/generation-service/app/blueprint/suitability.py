"""Source Suitability Evaluator for Langfens Loop Engine V2.

Evaluates whether an accepted EvidenceGraph contains sufficient diversity,
entities, mechanisms, or opinions to support a specific IELTS Reading section.
"""

from __future__ import annotations

import re
from typing import List, Optional, Set
from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.evidence import EvidenceGraph
from app.blueprint.policies import SECTION_CONFIGURATIONS


# Keywords indicative of causal or process mechanisms (Section 2)
MECHANISM_KEYWORDS = {
    "cause", "caused", "causes", "causing",
    "lead", "leads", "led", "leading",
    "result", "results", "resulted", "resulting",
    "mechanism", "process", "pathway", "function",
    "produce", "produces", "produced", "producing",
    "trigger", "triggers", "triggered", "triggering",
    "inhibit", "inhibits", "inhibited", "inhibiting",
    "increase", "increases", "increased", "increasing",
    "decrease", "decreases", "decreased", "decreasing",
    "regulate", "regulates", "regulated", "regulating",
    "correlate", "correlated", "associated",
}

# Keywords indicative of opinions, hypotheses, debates, viewpoints (Section 3)
OPINION_KEYWORDS = {
    "argue", "argues", "argued", "arguing",
    "believe", "believes", "believed", "believing",
    "suggest", "suggests", "suggested", "suggesting",
    "hypothesize", "hypothesizes", "hypothesized",
    "contend", "contends", "contended", "contending",
    "propose", "proposes", "proposed", "proposing",
    "conclude", "concludes", "concluded", "concluding",
    "debate", "debated", "dispute", "disputed",
    "view", "views", "perspective", "stance",
    "claim", "claims", "claimed", "claiming",
    "theorize", "theorized", "speculate", "speculated",
}


class SourceSuitabilityResult(CanonicalBaseModel):
    """Result of source suitability evaluation for a specific section."""

    is_suitable: bool = Field(..., alias="isSuitable")
    section_id: int = Field(..., ge=1, le=3, alias="sectionId")
    rejection_reason: Optional[str] = Field(default=None, alias="rejectionReason")
    rejection_code: Optional[str] = Field(default=None, alias="rejectionCode")
    diversity_score: float = Field(default=0.0, alias="diversityScore")
    entity_count: int = Field(default=0, alias="entityCount")
    mechanism_count: int = Field(default=0, alias="mechanismCount")
    opinion_count: int = Field(default=0, alias="opinionCount")
    distinct_claims_count: int = Field(default=0, alias="distinctClaimsCount")
    action: str = Field(default="PROCEED")  # PROCEED or NEEDS_SOURCES


def evaluate_source_suitability(
    evidence_graph: EvidenceGraph,
    section_id: int,
) -> SourceSuitabilityResult:
    """Evaluates whether the EvidenceGraph meets suitability criteria for section_id.

    Rejection Codes:
    - GRAPH_NOT_ACCEPTED: EvidenceGraph status is not ACCEPTED.
    - SOURCE_INSUFFICIENT_DIVERSITY: Repetitive or insufficient distinct facts/claims.
    - SOURCE_INSUFFICIENT_ENTITIES: Insufficient distinct entities/populations.
    - SOURCE_INSUFFICIENT_MECHANISMS: Section 2 lacks causal or process mechanisms.
    - SOURCE_INSUFFICIENT_OPINIONS: Section 3 lacks opinions, hypotheses, or arguments.
    """
    if evidence_graph.status != "ACCEPTED":
        return SourceSuitabilityResult(
            is_suitable=False,
            section_id=section_id,
            rejection_code="GRAPH_NOT_ACCEPTED",
            rejection_reason=f"EvidenceGraph status is {evidence_graph.status}; must be ACCEPTED.",
            action="NEEDS_SOURCES",
        )

    claims = evidence_graph.claims or []
    if not claims:
        return SourceSuitabilityResult(
            is_suitable=False,
            section_id=section_id,
            rejection_code="SOURCE_INSUFFICIENT_DIVERSITY",
            rejection_reason="EvidenceGraph has zero verified claims.",
            action="NEEDS_SOURCES",
        )

    # Extract distinct predicates, subjects, objects, and text content
    distinct_claims: Set[str] = set()
    entities: Set[str] = set()
    mechanism_count = 0
    opinion_count = 0

    for c in claims:
        text = getattr(c, "text", "") or getattr(c, "statement", "")
        words = set(re.findall(r"\b\w+\b", text.lower()))

        subject = getattr(c, "subject", "")
        predicate = getattr(c, "predicate", "")
        object_val = getattr(c, "object", "")

        if subject and predicate:
            claim_str = f"{subject.lower()} | {predicate.lower()} | {object_val.lower()}"
        else:
            claim_str = text.strip().lower()
        distinct_claims.add(claim_str)

        if subject:
            entities.add(subject.lower().strip())
        if object_val:
            entities.add(object_val.lower().strip())
        population = getattr(c, "population", None)
        if population:
            entities.add(population.lower().strip())

        # Extract capitalized phrases as named entities if subject/object not separately specified
        for ent in re.findall(r"\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b", text):
            entities.add(ent.lower())

        # Check for mechanisms
        quantities = getattr(c, "quantities", [])
        if words.intersection(MECHANISM_KEYWORDS) or quantities:
            mechanism_count += 1

        # Check for opinions/viewpoints/hypotheses
        modality = getattr(c, "modality", "")
        modality_is_opinion = bool(modality and modality.lower() in ("suggests", "argues", "may", "might", "could", "believes"))
        if words.intersection(OPINION_KEYWORDS) or modality_is_opinion:
            opinion_count += 1
    distinct_count = len(distinct_claims)
    entity_count = len(entities)
    # Simple diversity score = distinct claims / total claims
    diversity_score = distinct_count / len(claims) if claims else 0.0

    rules = SECTION_CONFIGURATIONS[section_id]["suitability_rules"]

    # Rule 1: Diversity check (a 1000-word source with 1 repeated fact fails)
    if distinct_count < rules["min_distinct_claims"]:
        return SourceSuitabilityResult(
            is_suitable=False,
            section_id=section_id,
            rejection_code="SOURCE_INSUFFICIENT_DIVERSITY",
            rejection_reason=(
                f"Source exhibits low diversity: {distinct_count} distinct claims found, "
                f"minimum required for Section {section_id} is {rules['min_distinct_claims']}."
            ),
            diversity_score=diversity_score,
            entity_count=entity_count,
            mechanism_count=mechanism_count,
            opinion_count=opinion_count,
            distinct_claims_count=distinct_count,
            action="NEEDS_SOURCES",
        )

    # Rule 2: Entity richness
    if entity_count < rules["min_entities"]:
        return SourceSuitabilityResult(
            is_suitable=False,
            section_id=section_id,
            rejection_code="SOURCE_INSUFFICIENT_ENTITIES",
            rejection_reason=(
                f"Source lacks entity richness: {entity_count} distinct entities found, "
                f"minimum required is {rules['min_entities']}."
            ),
            diversity_score=diversity_score,
            entity_count=entity_count,
            mechanism_count=mechanism_count,
            opinion_count=opinion_count,
            distinct_claims_count=distinct_count,
            action="NEEDS_SOURCES",
        )

    # Rule 3: Section 2 must have causal/process mechanisms
    if rules.get("requires_mechanisms") and mechanism_count < 3:
        return SourceSuitabilityResult(
            is_suitable=False,
            section_id=section_id,
            rejection_code="SOURCE_INSUFFICIENT_MECHANISMS",
            rejection_reason=(
                f"Section 2 requires analytical mechanisms or causal processes; "
                f"found {mechanism_count} mechanism-oriented claims (minimum 3 required)."
            ),
            diversity_score=diversity_score,
            entity_count=entity_count,
            mechanism_count=mechanism_count,
            opinion_count=opinion_count,
            distinct_claims_count=distinct_count,
            action="NEEDS_SOURCES",
        )

    # Rule 4: Section 3 must have viewpoints/arguments/opinions
    if rules.get("requires_opinions") and opinion_count < 3:
        return SourceSuitabilityResult(
            is_suitable=False,
            section_id=section_id,
            rejection_code="SOURCE_INSUFFICIENT_OPINIONS",
            rejection_reason=(
                f"Section 3 requires viewpoints, arguments, or hypotheses; "
                f"found {opinion_count} opinion-oriented claims (minimum 3 required). "
                f"Engine must not fabricate fake opinion claims."
            ),
            diversity_score=diversity_score,
            entity_count=entity_count,
            mechanism_count=mechanism_count,
            opinion_count=opinion_count,
            distinct_claims_count=distinct_count,
            action="NEEDS_SOURCES",
        )

    return SourceSuitabilityResult(
        is_suitable=True,
        section_id=section_id,
        diversity_score=diversity_score,
        entity_count=entity_count,
        mechanism_count=mechanism_count,
        opinion_count=opinion_count,
        distinct_claims_count=distinct_count,
        action="PROCEED",
    )
