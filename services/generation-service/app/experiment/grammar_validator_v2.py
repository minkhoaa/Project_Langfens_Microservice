"""Production syntactic validator and distractor error taxonomy for RQ2_DATASET_V2 (Sprint V2-S03).

Provides:
- V2_GRAMMAR_ERROR_TAXONOMY: Distractor diagnostic error codes mapping to syntactic defect classes.
- VALIDATION_STATUS_VALID / INVALID / INCONCLUSIVE: Explicit tri-state decision semantics.
- validate_syntactic_construction: Production validator evaluating positive target-construction
  indicators and failing closed upon detecting documented negative grammatical defects.
- Epistemic boundary disclosure separating automated screening from certified human gold judgment.
"""
from __future__ import annotations

import re
from typing import Any, Dict, List


V2_GRAMMAR_ERROR_TAXONOMY: Dict[str, Dict[str, str]] = {
    "ERR-INV-01": {
        "family_id": "fam-v2-grammar-inversion",
        "target_rule_id": "INV-01",
        "defect_type": "MISSING_AUXILIARY_INVERSION",
        "description": "Failure to invert subject and auxiliary operator following fronted negative adjunct.",
        "diagnostic": "Declarative word order (Subject + Aux) after initial negative adverbial is ungrammatical.",
    },
    "ERR-INV-02": {
        "family_id": "fam-v2-grammar-inversion",
        "target_rule_id": "INV-02",
        "defect_type": "SPURIOUS_INVERSION_SUBJECT_ONLY",
        "description": "Spurious auxiliary inversion fronting an operator before the subject when 'only' modifies a subject noun phrase.",
        "diagnostic": "When 'only' restricts the subject NP, standard declarative word order applies; fronting an operator before the subject (e.g. *'Only did researchers...'*) is ungrammatical.",
    },
    "ERR-COND-01": {
        "family_id": "fam-v2-grammar-conditionals",
        "target_rule_id": "COND-03",
        "defect_type": "ILLEGAL_LEXICAL_INVERSION",
        "description": "Direct fronting of lexical verbs in inverted conditionals without auxiliary operators.",
        "diagnostic": "Inversion in conditional clauses is strictly restricted to operators 'had', 'were', and 'should'.",
    },
    "ERR-CLEFT-01": {
        "family_id": "fam-v2-grammar-clefts",
        "target_rule_id": "CLEFT-01",
        "defect_type": "DEMONSTRATIVE_CLEFT_SUBSTITUTION",
        "description": "Substituting demonstrative pronouns ('this'/'that') for non-referential dummy 'it' in cleft sentences.",
        "diagnostic": "It-clefts require strictly dummy 'it'; demonstratives destroy the information-packaging focus structure.",
    },
    "ERR-SUBJ-01": {
        "family_id": "fam-v2-grammar-subjunctive",
        "target_rule_id": "SUBJ-01",
        "defect_type": "INFLECTED_MANDATIVE_VERB",
        "description": "3rd-person singular inflection on embedded verb in mandative that-clause following suasion predicate.",
        "diagnostic": "Mandative subjunctive requires the invariant base form uninflected for person or tense.",
    },
    "ERR-SUBJ-02": {
        "family_id": "fam-v2-grammar-subjunctive",
        "target_rule_id": "SUBJ-02",
        "defect_type": "DO_PERIPHRASIS_IN_NEGATIVE_SUBJUNCTIVE",
        "description": "Use of do-periphrasis (does/did/do not) in negative mandative subjunctive clauses.",
        "diagnostic": "Negative mandative subjunctive strictly requires 'not + base' without dummy do-support.",
    },
    "ERR-PART-01": {
        "family_id": "fam-v2-grammar-participles",
        "target_rule_id": "PART-01",
        "defect_type": "DANGLING_PARTICIPLE",
        "description": "Participle clause whose implied agent fails to corefer with the matrix clause subject.",
        "diagnostic": "In formal academic English, the covert subject of a non-finite clause must match the matrix subject.",
    },
    "ERR-MOD-01": {
        "family_id": "fam-v2-grammar-modals",
        "target_rule_id": "MOD-02",
        "defect_type": "MUST_NOT_HAVE_IMPOSSIBLE_DEDUCTION",
        "description": "Use of 'must not have' to express impossible past deduction instead of 'cannot/could not have'.",
        "diagnostic": "Strong negative epistemic deduction in academic English requires 'cannot have' or 'could not have'.",
    },
    "ERR-PASS-01": {
        "family_id": "fam-v2-grammar-passives",
        "target_rule_id": "PASS-02",
        "defect_type": "UNPERMITTED_PERSONAL_REPORTING_PASSIVE",
        "description": "Personal reporting passive frame with verbs restricted to impersonal structures (e.g. 'suggest').",
        "diagnostic": "Verbs like 'suggest' and 'explain' strictly prohibit personal reporting passives with to-infinitives.",
    },
}
VALIDATION_STATUS_VALID = "VALID"
VALIDATION_STATUS_INVALID = "INVALID"
VALIDATION_STATUS_INCONCLUSIVE = "INCONCLUSIVE"

SUPPORTED_GRAMMAR_FAMILIES = {
    "fam-v2-grammar-inversion",
    "fam-v2-grammar-conditionals",
    "fam-v2-grammar-clefts",
    "fam-v2-grammar-subjunctive",
    "fam-v2-grammar-participles",
    "fam-v2-grammar-modals",
    "fam-v2-grammar-passives",
}


def check_positive_target_construction(family_id: str, s_clean: str) -> tuple[bool, str]:
    """Evaluates whether the sentence positively exhibits the target syntactic construction."""
    s_lower = s_clean.lower()

    if family_id == "fam-v2-grammar-inversion":
        fronted_neg = [
            "under no circumstances", "on no account", "rarely", "seldom",
            "scarcely", "hardly", "barely", "at no time", "in no way", "little did",
            "neither", "nor", "not only",
        ]
        if any(s_lower.startswith(fn) for fn in fronted_neg):
            has_aux = bool(re.search(r"\b(should|must|can|could|will|would|did|does|do|have|had|has|is|are|were|was)\b", s_clean))
            if has_aux:
                return True, "Fronted negative/restrictive adjunct with inverted auxiliary"
        if re.match(r"^only\s+(after|when|if|then|by|with|through|recently|later|rarely)\b", s_lower):
            has_aux = bool(re.search(r"\b(did|does|do|had|have|has|should|could|would|was|were)\s+[a-z]+", s_lower))
            if has_aux:
                return True, "Fronted restrictive 'only' adjunct with inverted auxiliary"
        return False, "Sentence lacks fronted negative/restrictive adjunct triggering inversion"

    elif family_id == "fam-v2-grammar-conditionals":
        if re.match(r"^(had|were|should)\s+[a-z0-9'\s]+", s_lower):
            if re.search(r"\b(would|could|might)\b", s_lower):
                return True, "Inverted conditional clause with modal apodosis"
        if re.match(r"^if\s+.*,\s+.*", s_lower) or re.search(r"\bif\b.*,\s+.*", s_lower):
            if re.search(r"\b(had|were)\b", s_lower) and re.search(r"\b(would|could|might)\b", s_lower):
                return True, "Mixed conditional construction combining counterfactual condition and outcome"
        return False, "Sentence lacks inverted or mixed conditional syntactic structure"

    elif family_id == "fam-v2-grammar-clefts":
        if re.match(r"^it\s+(is|was)\s+.*\s+(that|who)\s+", s_clean, re.IGNORECASE):
            return True, "Dummy it-cleft construction focusing constituent with that/who"
        if re.match(r"^what\s+.*\s+(is|was)\s+", s_clean, re.IGNORECASE):
            return True, "Wh-pseudo-cleft nominal relative construction"
        if re.search(r"\b(is|was)\s+what\b", s_clean, re.IGNORECASE):
            return True, "Reversed wh-pseudo-cleft construction"
        return False, "Sentence lacks it-cleft, pseudo-cleft, or reversed pseudo-cleft structure"

    elif family_id == "fam-v2-grammar-subjunctive":
        if re.search(r"\b(suffice it to say|be that as it may|come what may|so be it|as it were)\b", s_clean, re.IGNORECASE):
            return True, "Formulaic subjunctive fixed academic expression"
        m = re.search(
            r"\b(?:recommend(?:s|ed)?|demand(?:s|ed)?|insist(?:s|ed)?|require(?:s|d)?|mandate(?:s|d)?|stipulate(?:s|d)?|essential|crucial|vital|imperative|necessary)\s+that\s+([^,.]+)",
            s_clean,
            re.IGNORECASE,
        )
        if m:
            clause = m.group(1).strip()
            if re.search(r"\bshould\s+[a-z]+", clause, re.IGNORECASE):
                return False, "Dialect-sensitive British should-mandative periphrasis (alternative to bare base subjunctive)"
            if re.search(r"\b(was|is|are|were)\b", clause, re.IGNORECASE):
                return False, "Indicative factual complement (not mandative subjunctive base form)"
            tokens = clause.split()
            if len(tokens) >= 2:
                return True, "Mandative subjunctive that-clause governed by suasion/necessity predicate"
        return False, "Sentence lacks mandative suasion trigger or formulaic subjunctive expression"

    elif family_id == "fam-v2-grammar-participles":
        if re.match(r"^(Having\s+[a-z]+|[A-Z][a-z]+ing|[A-Z][a-z]+ed|[A-Z][a-z]+en|[A-Z][a-z]+t)\b.*?,", s_clean):
            return True, "Adverbial non-finite participle clause modifying matrix subject"
        if re.search(r"\b(artifacts|specimens|samples|compounds|materials|data|signals|structures)\s+(discovered|excavated|synthesized|analyzed|treated|tested|developed|recovered)\s+(within|in|by|from|under|at)\b", s_clean, re.IGNORECASE):
            return True, "Reduced relative clause containing passive participle"
        return False, "Sentence lacks fronted adverbial participle or reduced relative construction"

    elif family_id == "fam-v2-grammar-modals":
        if re.search(r"\b(must|cannot|can't|could not|couldn't|may|might|could)\s+have\s+[a-z]+", s_clean, re.IGNORECASE):
            return True, "Modal perfect construction expressing past speculation or logical deduction"
        return False, "Sentence lacks past modal speculation/deduction construction"

    elif family_id == "fam-v2-grammar-passives":
        if re.search(r"\bIt\s+(is|was|has been)\s+(\w+\s+)?(believed|estimated|accepted|reported|thought|claimed|known|understood)\s+that\b", s_clean, re.IGNORECASE):
            return True, "Impersonal reporting passive frame with dummy it and that-clause"
        if re.search(r"\b(is|was|are|were|has been|have been)\s+(\w+\s+)?(reported|believed|thought|estimated|known|understood)\s+to\s+\w+", s_clean, re.IGNORECASE):
            return True, "Personal reporting passive frame with to-infinitive"
        return False, "Sentence lacks impersonal or personal reporting passive construction"

    return False, "Unknown family"


def validate_syntactic_construction(family_id: str, sentence: str) -> Dict[str, Any]:
    """Production validator evaluating whether a sentence obeys target syntactic invariants.

    Operates under strict VALID / INVALID / INCONCLUSIVE decision semantics:
    - VALID: Positive target syntactic construction identified AND zero defects detected.
    - INVALID: Documented negative syntactic defect explicitly detected, or empty input.
    - INCONCLUSIVE: Sentence lacks positive target construction, exhibits dialect/context
      alternatives requiring pragmatic interpretation, or references an unsupported family.
      Absence of a recognized defect is NEVER treated as proof of grammatical validity.

    Epistemic boundary: This is a structural screening tool, NOT a certified human gold oracle.
    """
    errors: List[str] = []
    inconclusive_notes: List[str] = []

    if not isinstance(sentence, str) or not sentence.strip():
        return {
            "family_id": family_id,
            "status": VALIDATION_STATUS_INVALID,
            "is_valid": False,
            "positive_match": False,
            "errors": ["ERR-EMPTY-INPUT: Sentence is empty or contains only whitespace"],
            "details": "Empty sentence cannot be validated",
            "epistemic_disclosure": (
                "Structural screening tool for targeted syntactic invariants; "
                "valid or inconclusive status does not constitute certified human expert validation "
                "(EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD)."
            ),
        }

    s_clean = sentence.strip()

    if family_id not in SUPPORTED_GRAMMAR_FAMILIES:
        return {
            "family_id": family_id,
            "status": VALIDATION_STATUS_INCONCLUSIVE,
            "is_valid": False,
            "positive_match": False,
            "errors": [f"ERR-UNSUPPORTED-FAMILY: Family '{family_id}' is not a recognized grammar family"],
            "details": "Unknown or unsupported grammar family identifier",
            "epistemic_disclosure": (
                "Structural screening tool for targeted syntactic invariants; "
                "valid or inconclusive status does not constitute certified human expert validation "
                "(EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD)."
            ),
        }
    if family_id == "fam-v2-grammar-inversion":
        for fn in ["under no circumstances", "on no account"]:
            if s_clean.lower().startswith(fn):
                remainder = s_clean[len(fn):].strip()
                first_word = remainder.split()[0].lower() if remainder else ""
                modal_aux = {
                    "should", "must", "can", "could", "will", "would",
                    "did", "does", "do", "have", "had", "has", "is", "are", "were", "was",
                }
                if first_word not in modal_aux:
                    errors.append("ERR-INV-01: Missing operator inversion after fronted negative adjunct")

        # True spurious operator inversion: "Only did senior researchers attend..."
        if re.match(r"^only\s+(did|does|do|should|must|can|could|will|would|have|had|has|is|are|were|was)\s+[a-z]+", s_clean, re.IGNORECASE):
            errors.append("ERR-INV-02: Spurious operator inversion fronting auxiliary operator before subject NP following 'only'")
        else:
            # Subject-modifying 'only' with canonical declarative order: "Only senior researchers did attend..."
            # In subject-auxiliary order (Only NP did V), did/does/do can represent emphatic affirmative do-support.
            tokens = s_clean.split()
            if tokens and tokens[0].lower() == "only":
                if len(tokens) > 1 and tokens[1].lower() not in {
                    "after", "when", "if", "then", "later", "recently", "rarely", "by", "with", "through",
                }:
                    if re.search(r"\bonly\s+[A-Za-z\s]+\b(did|does|do)\s+[a-z]+", s_clean, re.IGNORECASE):
                        inconclusive_notes.append("Subject-modifying 'only' with do-support maintains canonical subject-auxiliary order and may represent valid emphatic assertion rather than an inversion defect")
    elif family_id == "fam-v2-grammar-conditionals":
        tokens = s_clean.split()
        if tokens:
            first_word = tokens[0].lower().rstrip(",")
            if first_word in {"knew", "saw", "discovered", "believed", "thought", "analyzed", "realized", "found"}:
                errors.append("ERR-COND-01: Illegal direct lexical inversion without auxiliary operator (had, were, should)")

    elif family_id == "fam-v2-grammar-clefts":
        if re.match(r"^(this|that)\s+(is|was)\s+.*\s+(that|who)\s+", s_clean, re.IGNORECASE):
            errors.append("ERR-CLEFT-01: Demonstrative pronoun substitution ('this'/'that') in it-cleft construction")

    elif family_id == "fam-v2-grammar-subjunctive":
        m = re.search(
            r"\b(?:recommend(?:s|ed)?|demand(?:s|ed)?|insist(?:s|ed)?|require(?:s|d)?|mandate(?:s|d)?|stipulate(?:s|d)?|essential|crucial|vital|imperative|necessary)\s+that\s+([^,.]+)",
            s_clean,
            re.IGNORECASE,
        )
        if m:
            clause = m.group(1).strip()
            if re.search(r"\b(does|did|do)\s+not\b", clause, re.IGNORECASE):
                errors.append("ERR-SUBJ-02: Invalid do-periphrasis in negative mandative subjunctive (expected 'not + base')")
            if re.search(r"\bshould\s+[a-z]+", clause, re.IGNORECASE):
                inconclusive_notes.append("Dialect-sensitive British should-mandative periphrasis (alternative to bare base subjunctive)")
            if re.search(r"\b(was|is|are|were)\b", clause, re.IGNORECASE):
                inconclusive_notes.append("Indicative factual complement following epistemic predicate (not mandative subjunctive suasion)")
            words = [w.lower().rstrip(".,") for w in clause.split()]
            inflected_set = {
                "submits", "remains", "decontaminates", "archives", "demands",
                "provides", "requires", "stipulates", "allows", "recommends", "insists", "unblinds",
            }
            for w_clean in words[1:]:
                if w_clean in inflected_set:
                    errors.append(f"ERR-SUBJ-01: Inflected verb '{w_clean}' violates mandative base form requirement")
    elif family_id == "fam-v2-grammar-participles":
        if s_clean.startswith(("Having synthesized", "Having analyzed", "Analyzing", "Utilizing", "Operating")):
            comma_idx = s_clean.find(",")
            if comma_idx != -1:
                matrix = s_clean[comma_idx + 1:].strip()
                inanimate_nouns = {"spectroscopy", "data", "results", "analysis", "measurements", "readings", "telemetry"}
                if any(noun in matrix.lower().split()[:4] for noun in inanimate_nouns):
                    errors.append("ERR-PART-01: Dangling participle: matrix subject is an inanimate entity incapable of participial action")

    elif family_id == "fam-v2-grammar-modals":
        if "must not have" in s_clean.lower():
            has_epistemic_defect = bool(
                re.search(
                    r"\b(?:depletion|anomaly|readout|signal|specimen|core|furnace|trend|feature|event|loss|collapse)\s+must\s+not\s+have\s+(?:been|resulted|occurred|formed|originated|decayed|precipitated|caused)\b",
                    s_clean,
                    re.IGNORECASE,
                )
                or re.search(
                    r"\bmust\s+not\s+have\s+(?:resulted|originated|occurred|decayed|formed|precipitated)\s+(?:solely\s+)?(?:from|by|in|due)\b",
                    s_clean,
                    re.IGNORECASE,
                )
            )
            if has_epistemic_defect:
                errors.append("ERR-MOD-01: Illicit 'must not have' used for impossible past deduction (requires 'cannot/could not have')")
            else:
                inconclusive_notes.append(
                    "Ambiguous 'must not have': morphology cannot distinguish impossible past deduction from deontic prohibition on prior action (e.g. 'must not have entered'); requires contextual pragmatic adjudication"
                )
    elif family_id == "fam-v2-grammar-passives":
        if re.search(r"\b(is|was|are|were|has been)\s+(suggested|explained|announced)\s+to\s+\w+", s_clean, re.IGNORECASE):
            errors.append("ERR-PASS-01: Unpermitted personal reporting passive with restricted verb (e.g. 'is suggested to')")

    # 2. Positive target construction check
    has_positive_match, positive_reason = check_positive_target_construction(family_id, s_clean)

    # 3. Decision logic: VALID / INVALID / INCONCLUSIVE
    if errors:
        status = VALIDATION_STATUS_INVALID
        details = f"Documented syntactic defect(s) detected: {'; '.join(errors)}"
    elif inconclusive_notes:
        status = VALIDATION_STATUS_INCONCLUSIVE
        details = f"Context-dependent or dialect-sensitive alternative detected: {'; '.join(inconclusive_notes)}"
    elif not has_positive_match:
        status = VALIDATION_STATUS_INCONCLUSIVE
        details = f"Sentence lacks positive target syntactic construction for family '{family_id}': {positive_reason}; absence of defect is not proof of validity."
    else:
        status = VALIDATION_STATUS_VALID
        details = f"Target syntactic construction positively identified ({positive_reason}) with zero detected defects."

    return {
        "family_id": family_id,
        "status": status,
        "is_valid": status == VALIDATION_STATUS_VALID,
        "positive_match": has_positive_match,
        "errors": errors,
        "details": details,
        "epistemic_disclosure": (
            "Structural screening tool for targeted syntactic invariants; "
            "valid or inconclusive status does not constitute certified human expert validation "
            "(EXPLORATORY_AI_AUDIT_NOT_HUMAN_GOLD)."
        ),
    }
