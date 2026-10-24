"""Evidence-aware semantic claim binding for autonomous IELTS reading blueprints.

Binds question slots to verified claims based on genuine semantic suitability
(process/mechanism for flowcharts, attributable entities for matching features,
author stance/opinion for yes/no, factual assertions for completions and TFNG),
replacing legacy positional modulo rotation.
"""

from __future__ import annotations

import hashlib
import json
import re
from typing import Any, Dict, List, Optional, Sequence, Set, Tuple, Union

from app.contracts.blueprint import QuestionSlot
from app.contracts.evidence import EvidenceGraph, VerifiedClaim
from app.contracts.question_type import QuestionPromptFamily


# Semantic keyword clusters for IELTS question families
PROCESS_KEYWORDS = {
    "process", "processes", "mechanism", "mechanisms", "cycle", "cycles",
    "step", "steps", "pathway", "pathways", "produce", "produces", "produced", "producing",
    "production", "convert", "converts", "converted", "converting", "conversion",
    "transform", "transforms", "transformed", "transforming", "transformation",
    "stage", "stages", "phase", "phases", "reaction", "reactions", "trigger", "triggers",
    "triggered", "triggering", "flow", "flows", "flowed", "flowing", "sequence",
    "cause", "causes", "caused", "causing", "leads", "led", "leading",
    "result", "results", "resulted", "resulting", "generate", "generates", "generated",
    "inhibit", "inhibits", "inhibited", "regulate", "regulates", "regulated",
    "input", "output", "absorb", "release", "synthesize", "transfer", "transport",
}

ENTITY_DISTINCTION_KEYWORDS = {
    "researcher", "researchers", "scientist", "scientists", "author", "authors",
    "discover", "discovered", "discovering", "discovery", "identify", "identified",
    "species", "group", "groups", "category", "categories", "population", "populations",
    "institution", "institutions", "university", "universities", "organization",
    "team", "teams", "classify", "classified", "classification", "feature", "features",
    "characteristic", "characteristics", "distinction", "distinctions", "attribute",
    "attributes", "type", "types", "belong", "belongs", "belonged", "found",
    "observed", "reported", "proponent", "critics", "pioneer", "pioneers",
}

STANCE_OPINION_KEYWORDS = {
    "argue", "argues", "argued", "arguing", "argument", "arguments",
    "suggest", "suggests", "suggested", "suggesting", "suggestion",
    "believe", "believes", "believed", "believing", "belief", "beliefs",
    "hypothesize", "hypothesizes", "hypothesized", "hypothesis", "hypotheses",
    "contend", "contends", "contended", "contending", "contention",
    "propose", "proposes", "proposed", "proposing", "proposal",
    "conclude", "concludes", "concluded", "concluding", "conclusion",
    "debate", "debates", "debated", "debating", "view", "views", "viewpoint",
    "perspective", "perspectives", "stance", "stances", "claim", "claims",
    "claimed", "claiming", "theorize", "theorizes", "theorized", "speculate",
    "speculates", "speculated", "dispute", "disputes", "disputed", "attitude",
    "interpret", "interprets", "interpreted", "interpretation", "assertion",
    "opinion", "opinions", "doubt", "doubts", "criticize", "criticized",
}

FACTUAL_QUANTITATIVE_KEYWORDS = {
    "measure", "measured", "measurement", "measurements", "record", "recorded",
    "date", "dated", "dates", "century", "centuries", "year", "years",
    "percent", "percentage", "rate", "rates", "ratio", "ratios", "number",
    "increase", "decrease", "high", "low", "average", "total", "level",
    "levels", "amount", "amounts", "temperature", "concentration", "depth",
    "distance", "period", "duration", "frequency", "density", "volume",
}


def _claim_to_dict(claim: Union[VerifiedClaim, Dict[str, Any]]) -> Dict[str, Any]:
    if isinstance(claim, dict):
        return claim
    return {
        "claimId": claim.claim_id,
        "text": claim.text,
        "sourceId": claim.source_id,
        "confidence": claim.confidence,
        "keywords": claim.keywords,
        "qualifier": claim.qualifier.value if hasattr(claim.qualifier, "value") else str(claim.qualifier),
    }


def score_claim_suitability_for_family(
    claim_dict: Dict[str, Any],
    question_family: str,
    section_id: int,
) -> float:
    """Scores how well a verified claim semantically satisfies a question family.

    Returns a suitability score. Positive scores indicate valid suitability;
    scores <= 0.0 indicate semantic unsuitability.
    """
    text = claim_dict.get("text", "").lower()
    keywords = set(k.lower() for k in claim_dict.get("keywords", []))
    words = set(re.findall(r"\b[a-z]{3,}\b", text)) | keywords

    fam_norm = question_family.upper().replace("-", "_").replace(" ", "_")
    base_score = 1.0

    # Process / Mechanism families
    if any(p in fam_norm for p in ("FLOW_CHART", "DIAGRAM", "PROCESS")):
        proc_overlap = len(words & PROCESS_KEYWORDS)
        if proc_overlap > 0:
            base_score += min(10.0, 3.0 * proc_overlap)
        else:
            base_score -= 2.0

    # Categorization / Matching features / Classification families
    elif any(p in fam_norm for p in ("MATCHING_FEATURES", "CLASSIFICATION", "MATCHING_INFORMATION")):
        entity_overlap = len(words & ENTITY_DISTINCTION_KEYWORDS)
        orig_text = claim_dict.get("text", "")
        cap_entities = len(re.findall(r"\b[A-Z][a-z]{2,}\b", orig_text))
        if entity_overlap > 0 or cap_entities > 0:
            base_score += min(10.0, 2.0 * entity_overlap + 1.5 * cap_entities)
        else:
            base_score -= 2.0

    # Author viewpoint / stance / debate families
    elif any(p in fam_norm for p in ("YES_NO", "MATCHING_ENDINGS", "MATCHING_HEADING", "TITLE")):
        stance_overlap = len(words & STANCE_OPINION_KEYWORDS)
        if stance_overlap > 0:
            base_score += min(10.0, 3.0 * stance_overlap)
        elif section_id == 3 and len(words) >= 8:
            # Section 3 naturally tests arguments; claims with analytical reasoning still get credit
            base_score += 1.0
        else:
            base_score -= 2.0

    # Factual / completion families
    elif any(p in fam_norm for p in ("COMPLETION", "TABLE", "NOTE", "SHORT_ANSWER", "SENTENCE")):
        has_digits = bool(re.search(r"\b\d+\b", text))
        quant_overlap = len(words & FACTUAL_QUANTITATIVE_KEYWORDS)
        if has_digits or quant_overlap > 0:
            base_score += min(8.0, 2.0 * quant_overlap + (3.0 if has_digits else 0.0))
        elif len(words) >= 3:
            base_score += 1.5
        else:
            base_score -= 1.0

    # True / False / Not Given
    elif "TRUE_FALSE" in fam_norm or "TFNG" in fam_norm:
        has_digits = bool(re.search(r"\b\d+\b", text))
        quant_overlap = len(words & FACTUAL_QUANTITATIVE_KEYWORDS)
        if quant_overlap > 0 or has_digits or len(words) >= 3:
            base_score += min(6.0, 1.0 + 1.5 * quant_overlap + (1.0 if has_digits else 0.0))
        else:
            base_score -= 1.0

    # General MCQ
    elif "MULTIPLE_CHOICE" in fam_norm or "MCQ" in fam_norm:
        if section_id == 3:
            stance_overlap = len(words & STANCE_OPINION_KEYWORDS)
            base_score += min(8.0, 2.0 * stance_overlap)
        else:
            base_score += 2.0

    return base_score


def check_claim_eligibility_for_family(
    claim_dict: Dict[str, Any],
    question_family: str,
    section_id: int,
) -> bool:
    """Explicitly checks whether a claim satisfies semantic eligibility criteria for a question family."""
    cid = claim_dict.get("claimId") or ""
    # Reject empty, synthetic, placeholder, or explicitly fake claim IDs
    if not cid or cid.startswith("claim:synthetic:") or cid.startswith("claim:placeholder:") or cid.startswith("claim:None:") or cid.startswith("claim:fake:") or cid.startswith("claim:fake_"):
        return False

    # Grounding check: claim must have non-empty text
    text = str(claim_dict.get("text") or "").strip()
    if not text:
        return False

    # Reject cross-section mismatch if section ID is explicitly recorded
    claim_sec = claim_dict.get("sectionId") or claim_dict.get("section_id")
    if claim_sec is not None and int(claim_sec) != section_id:
        return False

    # Reject cross-section mismatch if encoded in canonical claim:{run_id}:{sec_id}:{idx} format
    parts = cid.split(":")
    if len(parts) >= 4 and parts[0] == "claim":
        try:
            if int(parts[2]) != section_id:
                return False
        except ValueError:
            pass

    score = score_claim_suitability_for_family(claim_dict, question_family, section_id)
    return score > 0.0


def bind_claims_to_slots(
    slots: Sequence[QuestionSlot],
    claims: Sequence[Union[VerifiedClaim, Dict[str, Any]]],
    section_id: int,
    graph_id: str,
    run_id: str,
) -> List[QuestionSlot]:
    """Deterministically binds question slots to verified claims using semantic suitability.

    Guarantees:
    1. Every dynamic slot references an existing claim in the verified graph.
    2. Enforces explicit eligibility check before ranking: fails closed if no claim is eligible.
    3. Rejects cross-section and synthetic claims.
    4. Deterministic tie-breaking for identical scores.
    """
    if not claims:
        raise ValueError(
            f"Section {section_id} EvidenceGraph '{graph_id}' contains zero verified claims. "
            "Cannot bind question slots to non-existent evidence."
        )

    norm_claims = [_claim_to_dict(c) for c in claims]
    claim_id_set = {c["claimId"] for c in norm_claims}
    if not claim_id_set:
        raise ValueError(f"Section {section_id} EvidenceGraph '{graph_id}' has no valid claim IDs.")

    # Strict check: reject cross-section claims and fabricated claim IDs
    valid_section_claims = []
    for c in norm_claims:
        cid = c.get("claimId") or ""
        if not cid or cid.startswith("claim:synthetic:") or cid.startswith("claim:placeholder:") or cid.startswith("claim:None:") or cid.startswith("claim:fake:") or cid.startswith("claim:fake_"):
            continue
        c_sec = c.get("sectionId") or c.get("section_id")
        if c_sec is not None and int(c_sec) != section_id:
            continue
        parts = cid.split(":")
        if len(parts) >= 4 and parts[0] == "claim":
            try:
                if int(parts[2]) != section_id:
                    continue
            except ValueError:
                pass
        valid_section_claims.append(c)

    if not valid_section_claims:
        raise ValueError(
            f"Section {section_id} EvidenceGraph '{graph_id}' contains only cross-section claims from other sections. "
            "Fail-closed: cross-section claim binding is prohibited."
        )

    updated_slots: List[QuestionSlot] = []
    group_claim_usage: Dict[int, Dict[str, int]] = {}
    section_claim_usage: Dict[str, int] = {}

    for slot in slots:
        grp_idx = slot.group_index
        if grp_idx not in group_claim_usage:
            group_claim_usage[grp_idx] = {}

        raw_type = slot.question_type
        type_str = raw_type.value if hasattr(raw_type, "value") else str(raw_type)

        # 1. Filter by explicit eligibility
        eligible_candidates: List[Dict[str, Any]] = [
            c for c in valid_section_claims
            if check_claim_eligibility_for_family(c, type_str, section_id)
        ]

        if not eligible_candidates:
            raise ValueError(
                f"Section {section_id} EvidenceGraph '{graph_id}' has no eligible verified claims for family '{type_str}' "
                f"(slot {slot.question_number}). Fail-closed: cannot force unsuitable evidence binding."
            )

        # 2. Score eligible candidates with strict diversity-first ordering
        # Prioritize:
        #   a) group_usage: strictly prefer claims not yet used in this question group
        #   b) section_usage: prefer claims with lower usage across the section
        #   c) -quality_score: maximize semantic suitability with deterministic tie-breaker
        #   d) cid: lexicographical tie-breaker for 100% deterministic reproducibility
        scored_candidates: List[Tuple[int, int, float, str, Dict[str, Any]]] = []
        for c in eligible_candidates:
            cid = c["claimId"]
            semantic_score = score_claim_suitability_for_family(c, type_str, section_id)
            grp_usage = group_claim_usage[grp_idx].get(cid, 0)
            sec_usage = section_claim_usage.get(cid, 0)

            # Deterministic, reproducible pseudo-random tie-breaker
            tie_seed = f"{graph_id}:{slot.question_number}:{type_str}:{cid}"
            tie_hash = int(hashlib.sha256(tie_seed.encode("utf-8")).hexdigest()[:6], 16)
            tie_breaker = (tie_hash % 1000) / 10000.0

            quality_score = semantic_score + tie_breaker
            scored_candidates.append((grp_usage, sec_usage, quality_score, cid, c))

        scored_candidates.sort(key=lambda x: (x[0], x[1], -x[2], x[3]))
        best_grp_u, best_sec_u, best_score, best_cid, best_claim = scored_candidates[0]

        # Record usage
        group_claim_usage[grp_idx][best_cid] = group_claim_usage[grp_idx].get(best_cid, 0) + 1
        section_claim_usage[best_cid] = section_claim_usage.get(best_cid, 0) + 1

        updated_slot = slot.model_copy(update={"claim_ref_ids": [best_cid]})
        updated_slots.append(updated_slot)

    return updated_slots
