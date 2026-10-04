"""Atomic claim representation and extraction for Langfens Loop Engine V2.

Features:
- Structured atomic claims: Subject, Predicate, Object
- Exact tracking of quantities, units, target populations, time anchors, and modalities
- Source span references with verified character offsets
- Forbidden transform tracking (e.g. correlation_to_causation, quantity_alteration)
"""

from __future__ import annotations

import hashlib
import re
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field

from app.contracts.evidence import (
    EntailmentLabel,
    Qualifier,
    SourceOffset,
    VerifiedClaim,
)
from app.ingestion.chunker import Span

# Patterns for extracting quantities and units
QUANTITY_PATTERN = re.compile(
    r"\b(\d+(?:\.\d+)?)\s*(%|percent|mg|g|kg|ml|l|km|m|cm|mm|centuries?|century|decades?|years?|months?|weeks?|days?|hours?|participants?|patients?|subjects?|cases?|fold)?\b",
    re.IGNORECASE,
)

POPULATION_KEYWORDS = {
    "adults", "children", "infants", "adolescents", "elderly", "seniors",
    "men", "women", "patients", "participants", "subjects", "volunteers",
    "students", "smokers", "non-smokers", "rodents", "mice", "rats",
    "athletes", "healthy athletes",
}

MODALITY_WORDS = {
    "may": (Qualifier.POSSIBLE, "possible"),
    "might": (Qualifier.POSSIBLE, "possible"),
    "could": (Qualifier.POSSIBLE, "possible"),
    "possibly": (Qualifier.POSSIBLE, "possible"),
    "suggests": (Qualifier.PROBABLE, "probable"),
    "likely": (Qualifier.PROBABLE, "probable"),
    "probable": (Qualifier.PROBABLE, "probable"),
    "indicated": (Qualifier.PROBABLE, "probable"),
    "demonstrated": (Qualifier.DEFINITE, "definite"),
    "proved": (Qualifier.DEFINITE, "definite"),
    "shows": (Qualifier.DEFINITE, "definite"),
    "confirmed": (Qualifier.DEFINITE, "definite"),
    "is": (Qualifier.DEFINITE, "definite"),
    "are": (Qualifier.DEFINITE, "definite"),
    "causes": (Qualifier.DEFINITE, "causal"),
    "leads to": (Qualifier.DEFINITE, "causal"),
    "results in": (Qualifier.DEFINITE, "causal"),
    "associated with": (Qualifier.PROBABLE, "correlational"),
    "correlated with": (Qualifier.PROBABLE, "correlational"),
    "linked to": (Qualifier.PROBABLE, "correlational"),
}


class AtomicClaim(BaseModel):
    """Fine-grained atomic claim with structured elements and attribution constraints."""

    model_config = ConfigDict(frozen=True)

    claim_id: str
    source_id: str
    text: str
    subject: str
    predicate: str
    object: str
    quantities: List[str] = Field(default_factory=list)
    units: List[str] = Field(default_factory=list)
    population: Optional[str] = None
    time_anchor: Optional[str] = None
    modality: str = "definite"
    qualifier: Qualifier = Qualifier.DEFINITE
    offsets: Optional[SourceOffset] = None
    source_span_id: Optional[str] = None
    source_text: str = ""
    forbidden_transforms: List[str] = Field(
        default_factory=lambda: [
            "correlation_to_causation",
            "quantity_alteration",
            "population_shift",
            "certainty_inflation",
        ]
    )

    def to_verified_claim(
        self,
        entailment: EntailmentLabel = EntailmentLabel.ENTAILS,
        confidence: float = 1.0,
    ) -> VerifiedClaim:
        """Converts to a canonical VerifiedClaim."""
        return VerifiedClaim(
            claimId=self.claim_id,
            text=self.text,
            sourceId=self.source_id,
            offsets=self.offsets,
            confidence=confidence,
            entailment=entailment,
            qualifier=self.qualifier,
            keywords=[self.subject, self.predicate, self.object] + self.quantities,
        )


def parse_quantities_and_units(text: str) -> tuple[List[str], List[str]]:
    """Extracts numeric quantities and units from text."""
    quantities: List[str] = []
    units: List[str] = []
    for match in QUANTITY_PATTERN.finditer(text):
        val = match.group(1)
        unit = match.group(2) or ""
        full_qty = f"{val}{unit}" if unit == "%" else f"{val} {unit}".strip()
        quantities.append(full_qty)
        if unit:
            units.append(unit.lower())
    return quantities, units


def extract_population(text: str) -> Optional[str]:
    """Identifies target population mentions in text."""
    words = set(re.findall(r"\b[a-zA-Z-]+\b", text.lower()))
    found = words & POPULATION_KEYWORDS
    return ", ".join(sorted(found)) if found else None


def extract_modality(text: str) -> tuple[Qualifier, str]:
    """Infers modality and qualifier strength from text verbs/adverbs."""
    text_lower = text.lower()
    for phrase, (qual, mod_name) in MODALITY_WORDS.items():
        if re.search(rf"\b{re.escape(phrase)}\b", text_lower):
            return qual, mod_name
    return Qualifier.DEFINITE, "definite"


def extract_atomic_claims(
    source_text: str,
    source_id: str,
    spans: List[Span],
) -> List[AtomicClaim]:
    """Extracts atomic fact claims from text spans with exact offsets and structured entities."""
    claims: List[AtomicClaim] = []

    for span in spans:
        raw = span.text.strip()
        if len(raw.split()) < 4:
            continue

        quantities, units = parse_quantities_and_units(raw)
        population = extract_population(raw)
        qualifier, modality = extract_modality(raw)

        # Simple structured entity heuristic for subject/predicate/object
        parts = re.split(r"\s+(?:is|are|was|were|may|causes?|shows?|leads? to|results? in|increases?|decreases?|reduces?)\s+", raw, maxsplit=1, flags=re.IGNORECASE)
        if len(parts) == 2:
            subject = parts[0].strip()[:60]
            obj = parts[1].strip()[:100]
            predicate = raw[len(subject): len(raw) - len(obj)].strip()
        else:
            subject = raw[:40].strip()
            predicate = "states"
            obj = raw[40:].strip()[:100]

        claim_hash = hashlib.sha256(f"{source_id}:{span.start_char}:{raw}".encode()).hexdigest()[:12]
        claim_id = f"claim_{claim_hash}"

        claims.append(
            AtomicClaim(
                claim_id=claim_id,
                source_id=source_id,
                text=raw,
                subject=subject or "Finding",
                predicate=predicate or "reports",
                object=obj or raw,
                quantities=quantities,
                units=units,
                population=population,
                modality=modality,
                qualifier=qualifier,
                offsets=SourceOffset(
                    startChar=span.start_char,
                    endChar=span.end_char,
                    sourceId=source_id,
                ),
                source_span_id=span.span_id,
                source_text=raw,
            )
        )

    return claims
