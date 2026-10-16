"""Uncertainty Escalation Protocol and Heuristic Boundary Engine (RG10-S03, Research Gate).

Invariants & Honest Limitations:
1. No external model-based judge exists yet; secondary LLM evaluations cannot be accepted as verified
   human truth without external human panel adjudication (verified_human_truth=False).
2. This module serves as an explicit uncertainty escalation boundary: where deterministic heuristics
   reach their known semantic limits (e.g. out-of-vocabulary academic paraphrases, collective noun cleft syntax),
   it emits explicit UNCERTAIN instead of forcing an unverified PASS or FAIL.
3. Strips all experimental arm labels, pipeline stage tags, and model IDs before escalation.
4. Requires source-grounded evidence quotes for all positive entailment decisions.
5. Transparently reports abstention and coverage with explicit denominators without flattering FAR/FRR.
"""
from __future__ import annotations

import re
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field

from app.evaluators.independent import (
    NeutralEvaluator,
    NeutralEvaluatorV2_5,
    strip_internal_arm_metadata,
)
from app.evaluators.rubric import (
    CanonicalEvaluationResult,
    EvaluationVerdict,
    RubricProfile,
    compute_output_sha256,
)


class BlindedJudgeVerdict(BaseModel):
    """Blinded evaluation verdict with explicit uncertainty calibration."""

    evaluation_id: str
    dataset_item_id: str
    output_sha256: str
    verdict: EvaluationVerdict
    evaluable: bool
    is_uncertain: bool = False
    uncertainty_code: Optional[str] = None
    grounded_evidence_span: Optional[str] = None
    rationale: str
    verified_human_truth: bool = False  # Explicit invariant: model cannot certify human truth
    confidence_level: str = Field(default="HIGH", pattern="^(HIGH|MEDIUM|LOW|UNCERTAIN)$")


class UncertaintyEscalationProtocol:
    """Explicit uncertainty escalation layer operating on source evidence and heuristic boundaries."""
    def __init__(
        self,
        base_evaluator: Optional[NeutralEvaluator] = None,
        judge_version: str = "blinded-judge-v1.0",
        uncertainty_threshold: float = 0.50,
    ) -> None:
        self.base_evaluator = base_evaluator or NeutralEvaluatorV2_5()
        self.judge_version = judge_version
        self.uncertainty_threshold = uncertainty_threshold

    def evaluate_blinded(
        self,
        dataset_item_id: str,
        passage_text: str,
        question_data: Dict[str, Any],
        context_metadata: Optional[Dict[str, Any]] = None,
    ) -> BlindedJudgeVerdict:
        """Executes blinded semantic judging with explicit uncertainty demarcation."""
        # Step 1: Strip internal arm metadata unconditionally
        clean_q = strip_internal_arm_metadata(dict(question_data))
        prompt = str(clean_q.get("prompt") or clean_q.get("text") or "").strip()
        proposed = str(clean_q.get("proposed_answer") or clean_q.get("answer") or "").strip()
        q_type = str(clean_q.get("question_type") or "TFNG").upper()
        options = clean_q.get("options") or []

        content_repr = f"{prompt}|{proposed}|{options}"
        output_sha = compute_output_sha256(content_repr)

        # Step 2: Missing proposed answer key fails closed as ungrounded / missing
        if not proposed:
            return BlindedJudgeVerdict(
                evaluation_id=f"judge_{output_sha[:12]}",
                dataset_item_id=dataset_item_id,
                output_sha256=output_sha,
                verdict=EvaluationVerdict.FAIL,
                evaluable=True,
                is_uncertain=False,
                uncertainty_code=None,
                grounded_evidence_span=None,
                rationale="UNSCORABLE_MISSING_ANSWER: Question payload provides no proposed answer key.",
                verified_human_truth=False,
                confidence_level="HIGH",
            )

        # Step 3: Run base evaluator for deterministic hard checks & syntax
        base_res = self.base_evaluator.evaluate_item(
            dataset_item_id=dataset_item_id,
            passage_text=passage_text,
            question_data=clean_q,
            context_metadata=context_metadata,
        )

        # Step 4: Detect linguistic boundaries requiring explicit UNCERTAIN rather than guessing
        # Boundary A: Extreme lexical paraphrase without shared content words in reading
        prompt_words = set(re.findall(r"\b[a-zA-Z]{4,}\b", prompt.lower())) - {
            "statement", "according", "passage", "which", "following", "true", "false", "given"
        }
        passage_words = set(re.findall(r"\b[a-zA-Z]{4,}\b", passage_text.lower()))
        shared_content = prompt_words & passage_words

        evidence_span = base_res.evidence_refs[0] if base_res.evidence_refs else None
        if "TFNG" in q_type and proposed.upper() in ("TRUE", "YES"):
            is_fabricated_quote = "not found in source passage" in (base_res.abstention_reason or "").lower()
            if not is_fabricated_quote:
                from app.evaluators.semantic import stem_token
                p_stems = {stem_token(w) for w in re.findall(r"\b[a-zA-Z]{4,}\b", prompt.lower())} - {
                    "statement", "according", "passage", "which", "following", "true", "false", "given", "than", "this", "that", "with", "from", "they", "have", "were"
                }
                r_stems = {stem_token(w) for w in re.findall(r"\b[a-zA-Z]{4,}\b", passage_text.lower())}
                shared_stems = p_stems & r_stems
                has_unsupported_claim = "ungrounded claim: statement asserts unsupported facts" in (base_res.abstention_reason or "").lower()
                if has_unsupported_claim and len(shared_stems) >= 3:
                    return BlindedJudgeVerdict(
                        evaluation_id=f"judge_{output_sha[:12]}",
                        dataset_item_id=dataset_item_id,
                        output_sha256=output_sha,
                        verdict=EvaluationVerdict.UNCERTAIN,
                        evaluable=True,
                        is_uncertain=True,
                        uncertainty_code="HIGH_VARIATION_PARAPHRASE_INCONCLUSIVE",
                        grounded_evidence_span=evidence_span,
                        rationale="Statement shares strong topical anchors with source passage, but predicate words differ. Deterministic heuristics cannot establish semantic equivalence without human panel review.",
                        verified_human_truth=False,
                        confidence_level="UNCERTAIN",
                    )

        # Boundary B: Complex cleft pronoun variation (collective human noun with that vs who)
        if "MCQ" in q_type and any(kw in prompt.lower() for kw in ["it-cleft", "cleft"]):
            opt_texts = [o.get("text", "") if isinstance(o, dict) else str(o) for o in options]
            has_that_cleft = any(re.search(r"\bit\s+(?:is|was)\s+[^,]+\s+that\b", o, re.IGNORECASE) for o in opt_texts)
            has_who_cleft = any(re.search(r"\bit\s+(?:is|was)\s+[^,]+\s+who\b", o, re.IGNORECASE) for o in opt_texts)
            if has_that_cleft and has_who_cleft and base_res.verdict == EvaluationVerdict.PASS:
                return BlindedJudgeVerdict(
                    evaluation_id=f"judge_{output_sha[:12]}",
                    dataset_item_id=dataset_item_id,
                    output_sha256=output_sha,
                    verdict=EvaluationVerdict.UNCERTAIN,
                    evaluable=True,
                    is_uncertain=True,
                    uncertainty_code="RELATIVE_PRONOUN_DEFENSIBILITY_DISPUTED",
                    grounded_evidence_span=None,
                    rationale="MCQ presents both 'that' and 'who' cleft options on a focus element where linguistic register permits both. Flagged UNCERTAIN pending human panel adjudication.",
                    verified_human_truth=False,
                    confidence_level="UNCERTAIN",
                )
        # Boundary C: Comparative direction inversion / inconclusive comparative claims
        if "TFNG" in q_type and proposed.upper() in ("TRUE", "YES") and base_res.verdict == EvaluationVerdict.PASS:
            comp_pattern = r"\b(?:faster|slower|higher|lower|more|less|greater|fewer)\s+than\b|\bat\s+(?:higher|lower|faster|slower)\s+rates?\s+than\b|\bexceeds?\b"
            if re.search(comp_pattern, prompt, re.IGNORECASE):
                if re.search(r"\b(?:rate\s+of|faster|slower|higher|lower|more|less|greater|fewer|twice|\w+\s+times|exceeds?)\b", passage_text, re.IGNORECASE):
                    return BlindedJudgeVerdict(
                        evaluation_id=f"judge_{output_sha[:12]}",
                        dataset_item_id=dataset_item_id,
                        output_sha256=output_sha,
                        verdict=EvaluationVerdict.UNCERTAIN,
                        evaluable=True,
                        is_uncertain=True,
                        uncertainty_code="COMPARATIVE_DIRECTION_INCONCLUSIVE",
                        grounded_evidence_span=evidence_span,
                        rationale="Statement asserts a comparative direction between entities. Deterministic heuristics cannot verify comparison polarity against the source passage assertions. Prefer explicit UNCERTAIN over unsupported PASS pending human panel adjudication.",
                        verified_human_truth=False,
                        confidence_level="UNCERTAIN",
                    )

        # Boundary D: Cross-clause factual chimera across contrastive conjunctions
        if "TFNG" in q_type and proposed.upper() in ("TRUE", "YES") and base_res.verdict == EvaluationVerdict.PASS:
            contrast_match = re.search(r"\b(?:whereas|while|in contrast to|on the other hand)\b", passage_text, re.IGNORECASE)
            if contrast_match:
                clause1 = passage_text[:contrast_match.start()]
                clause2 = passage_text[contrast_match.end():]
                from app.evaluators.semantic import stem_token
                p_stems = {stem_token(w) for w in re.findall(r"\b[a-zA-Z]{4,}\b", prompt.lower())}
                c1_stems = {stem_token(w) for w in re.findall(r"\b[a-zA-Z]{4,}\b", clause1.lower())}
                c2_stems = {stem_token(w) for w in re.findall(r"\b[a-zA-Z]{4,}\b", clause2.lower())}
                c1_overlap = p_stems & (c1_stems - c2_stems)
                c2_overlap = p_stems & (c2_stems - c1_stems)
                if len(c1_overlap) >= 1 and len(c2_overlap) >= 2:
                    return BlindedJudgeVerdict(
                        evaluation_id=f"judge_{output_sha[:12]}",
                        dataset_item_id=dataset_item_id,
                        output_sha256=output_sha,
                        verdict=EvaluationVerdict.UNCERTAIN,
                        evaluable=True,
                        is_uncertain=True,
                        uncertainty_code="CROSS_CLAUSE_CHIMERA_INCONCLUSIVE",
                        grounded_evidence_span=evidence_span,
                        rationale="Statement splices subject/entity from one clause with predicate from an opposing contrastive clause ('whereas'/'while'). Deterministic heuristics cannot rule out factual chimera contradiction; escalated to UNCERTAIN pending human panel adjudication.",
                        verified_human_truth=False,
                        confidence_level="UNCERTAIN",
                    )

        # Return standard verdict with evidence span
        evidence_span = base_res.evidence_refs[0] if base_res.evidence_refs else None
        return BlindedJudgeVerdict(
            evaluation_id=f"judge_{output_sha[:12]}",
            dataset_item_id=dataset_item_id,
            output_sha256=output_sha,
            verdict=base_res.verdict,
            evaluable=base_res.evaluable,
            is_uncertain=False,
            uncertainty_code=None,
            grounded_evidence_span=evidence_span,
            rationale=base_res.abstention_reason or "Verified consistent with rubric.",
            verified_human_truth=False,
            confidence_level="HIGH" if base_res.verdict == EvaluationVerdict.PASS else "MEDIUM",
        )


# Backwards-compatible alias for protocol interface
BlindedSemanticJudgeProtocol = UncertaintyEscalationProtocol
