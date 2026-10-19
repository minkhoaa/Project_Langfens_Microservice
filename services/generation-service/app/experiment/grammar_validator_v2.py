"""Production syntactic validator and distractor error taxonomy for RQ2_DATASET_V2 (Sprint V2-S03).

Provides:
- V2_GRAMMAR_ERROR_TAXONOMY: Distractor diagnostic error codes mapping to syntactic defect classes.
- validate_syntactic_construction: Production validator that enforces target syntactic invariants
  and fails closed upon detecting documented negative grammatical defects.
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
        "description": "Spurious auxiliary inversion when 'only' modifies a subject noun phrase rather than an adverbial.",
        "diagnostic": "When 'only' restricts the subject NP, standard declarative word order applies without inversion.",
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


def validate_syntactic_construction(family_id: str, sentence: str) -> Dict[str, Any]:
    """Production validator evaluating whether a sentence obeys target syntactic invariants.

    Fails closed upon detecting documented negative grammatical defects:
    - INV: Missing auxiliary inversion, spurious subject-modifying 'only' inversion
    - COND: Illegal direct lexical inversion without auxiliary operator
    - CLEFT: Demonstrative substitution in it-clefts ('This was X that Y')
    - SUBJ: Inflected 3rd-person verbs in mandative that-clauses, do-periphrasis negation
    - PART: Dangling participles with inanimate matrix subjects
    - MOD: Illicit 'must not have' for impossible past deduction
    - PASS: Illicit personal reporting passives with unpermitted verbs ('suggest', 'explain')
    """
    errors: List[str] = []
    s_clean = sentence.strip()

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
        tokens = s_clean.split()
        if tokens and tokens[0].lower() == "only":
            if len(tokens) > 1 and tokens[1].lower() not in {
                "after", "when", "if", "then", "later", "recently", "rarely", "by", "with", "through",
            }:
                if re.search(r"\bonly\s+[A-Za-z\s]+\b(did|does|do)\s+[a-z]+", s_clean, re.IGNORECASE):
                    errors.append("ERR-INV-02: Spurious operator inversion following subject-modifying 'only'")

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
            r"\b(recommended|demanded|insisted|required|mandated|stipulate[ds]?|essential)\s+that\s+([^,.]+)",
            s_clean,
            re.IGNORECASE,
        )
        if m:
            clause = m.group(2).strip()
            if re.search(r"\b(does|did|do)\s+not\b", clause, re.IGNORECASE):
                errors.append("ERR-SUBJ-02: Invalid do-periphrasis in negative mandative subjunctive (expected 'not + base')")
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
            errors.append("ERR-MOD-01: Illicit 'must not have' used for impossible past deduction (requires 'cannot/could not have')")

    elif family_id == "fam-v2-grammar-passives":
        if re.search(r"\b(is|was|are|were|has been)\s+(suggested|explained|announced)\s+to\s+\w+", s_clean, re.IGNORECASE):
            errors.append("ERR-PASS-01: Unpermitted personal reporting passive with restricted verb (e.g. 'is suggested to')")

    return {
        "family_id": family_id,
        "is_valid": len(errors) == 0,
        "errors": errors,
    }
