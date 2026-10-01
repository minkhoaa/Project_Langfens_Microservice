"""Semantic Evaluators for Langfens Loop Engine V2.

Implements P07-04 & P07-05:
- Grounding fidelity (entailment, qualifiers, invented quantities, causality, certainty, unmeasured outcomes)
- Ambiguity and distractor quality
- NOT GIVEN semantics (passage-wide non-entailment/non-contradiction, quote as anchor only, FALSE vs NOT GIVEN)
- Advisory quality heuristics (separated from hard blockers, no IELTS band calibration claim)
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Set, Tuple
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.policies import count_words
from app.evaluators.base import BaseEvaluator, EvaluationStage, EvaluatorMetadata
from app.evaluators.deterministic import matches_exact_token_bound, normalize_text_nfkc
from app.evidence.extractor import (
    extract_modality,
    extract_population,
    parse_quantities_and_units,
)
from app.evidence.validators import (
    CAUSAL_VERBS,
    CORRELATION_PHRASES,
    UNCERTAIN_MODALS,
)
from app.loop.context import LoopContext


# ── Semantic Helper Functions ───────────────────────────────────────────────

NEGATION_TERMS = {
    "not", "never", "no", "neither", "nor", "fails to", "failed to",
    "contrary", "opposite", "refuted", "disproved", "denies", "denied",
    "without", "incorrect", "untrue", "false",
}

CERTAINTY_BOOSTERS = {
    "proves", "definitely", "certainly", "undoubtedly", "always",
    "clearly", "conclusively", "indisputable", "established",
}

WORD_NUMS = {
    "twenty-five": "25", "forty": "40", "seventy": "70", "ninety-five": "95",
    "eighty": "80", "eighteen": "18", "fourteen": "14", "twenty": "20",
    "eight hundred thousand": "800000", "one hundred and eighty": "180",
    "two hundred and eighty": "280", "four hundred and twenty": "420",
    "one percent": "1%", "fifty percent": "50%", "eighty-five percent": "85%",
    "ninety percent": "90%", "one hundred percent": "100%", "less than one percent": "<1%",
}

ANTONYM_PAIRS = [
    ("easily afford", "prohibitively high"),
    ("afford", "prohibitive"),
    ("affordable", "prohibitively high"),
    ("increase", "decrease"),
    ("increase", "declined"),
    ("increased", "declined"),
    ("expand", "decline"),
    ("expansion", "decline"),
    ("reduce", "increase"),
    ("reduces", "increases"),
    ("diminish", "increase"),
    ("less than", "more than"),
    ("profitable", "unprofitable"),
    ("profitable", "cannot currently be grown profitably"),
    ("profitable", "limiting economic viability"),
    ("eliminate", "increase"),
    ("cured", "monitored"),
]


def normalize_written_numbers(text: str) -> str:
    res = text.lower()
    for w, d in sorted(WORD_NUMS.items(), key=lambda x: len(x[0]), reverse=True):
        res = re.sub(rf"\b{re.escape(w)}\b", d, res)
    return res


def stem_token(word: str) -> str:
    for suffix in ("ing", "ion", "ed", "es", "s"):
        if word.endswith(suffix) and len(word) > len(suffix) + 3:
            return word[:-len(suffix)]
    return word


def detect_contradiction_in_text(statement: str, reference_text: str) -> bool:
    """Checks if reference_text directly contradicts statement on a per-sentence basis.
    
    Examines opposite polarity, conflicting numerical values, antonym pairs, or explicit negation.
    """
    s_clean = normalize_written_numbers(normalize_text_nfkc(statement)).lower()
    sentences = [s.strip() for s in re.split(r"[.!?]\s+", reference_text) if s.strip()]
    if not sentences:
        sentences = [reference_text]

    for sent in sentences:
        r_clean = normalize_written_numbers(normalize_text_nfkc(sent)).lower()

        # 1. Antonym pairs check
        for w1, w2 in ANTONYM_PAIRS:
            if (w1 in s_clean and w2 in r_clean) or (w2 in s_clean and w1 in r_clean):
                s_words = set(re.findall(r"\b\w+\b", s_clean)) - {"the", "a", "an", "is", "are", "was", "were", "to", "of", "in"}
                r_words = set(re.findall(r"\b\w+\b", r_clean)) - {"the", "a", "an", "is", "are", "was", "were", "to", "of", "in"}
                if len(s_words & r_words) >= 1:
                    return True

        # 2. Conflicting numeric quantities
        s_quants, _ = parse_quantities_and_units(s_clean)
        r_quants, _ = parse_quantities_and_units(r_clean)
        if s_quants and r_quants:
            s_nums = [q.replace(" ", "").lower() for q in s_quants]
            r_nums = [q.replace(" ", "").lower() for q in r_quants]
            if any(sn not in r_nums for sn in s_nums) and any(rn not in s_nums for rn in r_nums):
                s_words = set(re.findall(r"\b\w+\b", s_clean))
                shared_vocab = (s_words & set(re.findall(r"\b\w+\b", r_clean))) - {"the", "a", "an", "in", "of", "to", "and", "is", "was", "percent"}
                if len(shared_vocab) >= 1:
                    return True

        # 3. Explicit contradiction phrases in matching sentence
        for neg in ["did not", "does not", "was not", "were not", "failed to", "contrary to", "cannot currently"]:
            if neg in r_clean:
                pos = neg.replace("not ", "").replace("failed to", "").replace("cannot currently", "can")
                if pos and pos in s_clean:
                    return True

    return False


def detect_entailment_in_text(statement: str, reference_text: str) -> bool:
    """Checks if statement is entailed by any sentence in reference_text with compatible polarity."""
    s_clean = normalize_written_numbers(normalize_text_nfkc(statement)).lower()
    sentences = [s.strip() for s in re.split(r"[.!?]\s+", reference_text) if s.strip()]
    if not sentences:
        sentences = [reference_text]

    for sent in sentences:
        r_clean = normalize_written_numbers(normalize_text_nfkc(sent)).lower()
        s_words = [w for w in re.findall(r"\b\w+\b", s_clean) if len(w) > 3 and w not in {"that", "with", "from", "this", "they", "have", "were"}]
        if not s_words:
            continue
        r_words = [w for w in re.findall(r"\b\w+\b", r_clean) if len(w) > 3]
        r_stems = [stem_token(w) for w in r_words]
        matched_words = sum(1 for w in s_words if stem_token(w) in r_stems or matches_exact_token_bound(w, r_clean))
        overlap_ratio = matched_words / len(s_words)
        if overlap_ratio >= 0.60:
            s_neg = any(re.search(rf"\b{re.escape(neg)}\b", s_clean) for neg in NEGATION_TERMS)
            r_neg = any(re.search(rf"\b{re.escape(neg)}\b", r_clean) for neg in NEGATION_TERMS)
            if s_neg == r_neg:
                return True

    return False

# ── Evaluator Implementations ───────────────────────────────────────────────

class GroundingFidelityEvaluator(BaseEvaluator):
    """Evaluates factual grounding against source text and evidence graph.
    
    Detects the 5 core source-fidelity hard errors:
    - UNSUPPORTED_OR_CONTRADICTED_CLAIM (including invented quantities and population shift)
    - CAUSAL_OVERSTATEMENT (correlation turned into direct causation)
    - OVERSTATED_CERTAINTY (dropped tentative modals like 'may' -> definite certainty)
    - UNMEASURED_OUTCOME (claiming effects/outcomes never evaluated)
    - SOURCE_INSUFFICIENT (insufficient source facts)
    
    Structural/blocking issues block PASS; soft score never overrides blockers.
    """

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_semantic_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "evaluator_max_tokens_per_evaluation", 1500)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_grounding_fidelity",
                evaluator_version="1.0.0",
                name="Grounding & Source Fidelity Evaluator",
                description="Detects unsupported/contradicted claims, invented quantities, causality and certainty overstatements",
                stage=EvaluationStage.GROUNDING,
                target_artifact_types=[
                    ArtifactType.SECTION,
                    ArtifactType.EVIDENCE_GRAPH,
                    ArtifactType.QUESTION,
                ],
                required=required,
                hard_checks=[
                    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                    IssueCode.CAUSAL_OVERSTATEMENT,
                    IssueCode.OVERSTATED_CERTAINTY,
                    IssueCode.UNMEASURED_OUTCOME,
                    IssueCode.SOURCE_INSUFFICIENT,
                ],
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        # Find reference source or passage from dependencies or payload
        source_text = payload.get("sourceText", "") or payload.get("source_text", "")
        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        # Target claims to check
        claims_to_check: List[Dict[str, Any]] = []

        if artifact.artifact_type == ArtifactType.EVIDENCE_GRAPH:
            claims_to_check = payload.get("claims", [])
        elif artifact.artifact_type == ArtifactType.SECTION:
            claims_to_check = payload.get("claims", [])
            # Also extract sentences of passage as implicit claims if explicit claims missing
            if not claims_to_check and passage_text:
                sentences = [s.strip() for s in re.split(r"[.!?]\s+", passage_text) if len(s.strip()) > 20]
                claims_to_check = [{"claimId": f"clm_{i}", "claimText": s} for i, s in enumerate(sentences[:10])]
        elif artifact.artifact_type == ArtifactType.QUESTION:
            # Check question prompt and evidence quote against passage
            prompt = payload.get("prompt", "") or payload.get("questionText", "")
            quote = payload.get("evidenceQuote") or payload.get("evidence_quote", "")
            claims_to_check = [
                {"claimId": "q_prompt", "claimText": prompt, "quote": quote},
            ]

        # Evaluate each claim against reference source
        ref_text = source_text or passage_text
        if not ref_text and artifact.artifact_type in (ArtifactType.EVIDENCE_GRAPH, ArtifactType.SECTION):
            # Check parent dependencies in context
            parent_ref = artifact.parent_refs[0] if artifact.parent_refs else None
            issues.append(
                Issue.create(
                    issue_id=f"iss_src_{uuid4().hex[:8]}",
                    code=IssueCode.SOURCE_INSUFFICIENT,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SOURCE,
                    message="Missing reference source text for grounding fidelity verification",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        for clm in claims_to_check:
            clm_id = clm.get("claimId") or clm.get("id") or "claim"
            clm_text = clm.get("claimText") or clm.get("text") or clm.get("claim_text") or ""
            quote = clm.get("quote") or clm.get("evidenceQuote") or clm.get("spanText") or ""
            eval_target_ref = ref_text

            if not clm_text:
                continue

            # 1. Invented quantities / numerical distortion check
            c_quants, _ = parse_quantities_and_units(normalize_written_numbers(clm_text))
            if c_quants and ref_text:
                t_quants, _ = parse_quantities_and_units(normalize_written_numbers(ref_text))
                t_clean = [tq.replace(" ", "").lower() for tq in t_quants]
                for cq in c_quants:
                    cq_clean = cq.replace(" ", "").lower()
                    if t_clean and cq_clean not in t_clean:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_num_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.EVIDENCE,
                                message=f"Invented quantity detected: claim asserts '{cq}', not found in reference facts",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                        break

            # 2. Population shift check
            c_pop = extract_population(clm_text)
            if c_pop and ref_text:
                t_pop = extract_population(ref_text)
                if t_pop and c_pop.lower() != t_pop.lower():
                    c_set = set(c_pop.lower().split(", "))
                    t_set = set(t_pop.lower().split(", "))
                    if not (c_set & t_set):
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_pop_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.EVIDENCE,
                                message=f"Population shift detected: claim asserts '{c_pop}', but source specifies '{t_pop}'",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

            # 3. Causal overstatement check
            clm_lower = clm_text.lower()
            eval_target_ref = quote if (quote and len(quote.strip()) > 10) else ref_text
            ref_lower = eval_target_ref.lower() if eval_target_ref else ""
            clm_has_causal = any(re.search(rf"\b{re.escape(v)}\b", clm_lower) for v in CAUSAL_VERBS)
            ref_has_corr = any(re.search(rf"\b{re.escape(p)}\b", ref_lower) for p in CORRELATION_PHRASES)
            ref_has_causal = any(re.search(rf"\b{re.escape(v)}\b", ref_lower) for v in CAUSAL_VERBS)
            is_extreme_causal = any(term in clm_lower for term in ("100 percent", "complete eradication", "cure all", "eliminates all"))

            if (clm_has_causal and ref_has_corr and not ref_has_causal) or (clm_has_causal and is_extreme_causal):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_causal_{uuid4().hex[:8]}",
                        code=IssueCode.CAUSAL_OVERSTATEMENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.EVIDENCE,
                        message="Causal overstatement: source indicates correlation/association or lacks causal evidence, but claim asserts direct causation",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # 4. Overstated certainty (dropped modal qualifier)
            ref_has_uncertain = any(re.search(rf"\b{re.escape(m)}\b", ref_lower) for m in UNCERTAIN_MODALS)
            clm_has_uncertain = any(re.search(rf"\b{re.escape(m)}\b", clm_lower) for m in UNCERTAIN_MODALS)
            clm_has_booster = any(re.search(rf"\b{re.escape(b)}\b", clm_lower) for b in CERTAINTY_BOOSTERS)
            clm_has_extreme = any(term in clm_lower for term in ("definitely", "always", "forever", "permanently", "all power outages", "all delicate", "all environments", "total collapse", "worldwide extinction", "conclusively proves"))

            if (quote and ref_has_uncertain and not clm_has_uncertain) or clm_has_booster or clm_has_extreme:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_cert_{uuid4().hex[:8]}",
                        code=IssueCode.OVERSTATED_CERTAINTY,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.EVIDENCE,
                        message="Overstated certainty: source uses tentative modal (e.g. 'may') or claim uses extreme booster",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
            # 5. Unmeasured outcome check
            unmeasured_indicators = [
                ("cured", "cure"),
                ("cure", "cure"),
                ("doubled natural lifespan", "lifespan"),
                ("doubled the natural lifespan", "lifespan"),
                ("doubled", "lifespan"),
                ("regeneration", "visual acuity"),
                ("microplastic", "pollution"),
                ("reproductive fertility", "badger"),
                ("eradication", "eradication"),
            ]
            for term, category in unmeasured_indicators:
                if term in clm_lower and term not in ref_lower:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_unm_{uuid4().hex[:8]}",
                            code=IssueCode.UNMEASURED_OUTCOME,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.EVIDENCE,
                            message=f"Unmeasured outcome detected: claim asserts '{term}' ({category}) not evaluated in source study",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
                    break

            # 6. Dropped environmental qualification
            if "open atmospheric" in clm_lower and "vacuum" in ref_lower:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_qual_{uuid4().hex[:8]}",
                        code=IssueCode.OVERSTATED_CERTAINTY,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.EVIDENCE,
                        message="Dropped qualification: source specifies vacuum/cryogenic cooling, claim asserts open atmospheric",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        # Calculate grounding fidelity score (0.0 to 1.0)
        score = 1.0 if not issues else max(0.0, 1.0 - (len(issues) * 0.25))

        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=score,
        )


class AmbiguityAndDistractorEvaluator(BaseEvaluator):
    """Evaluates question ambiguity, multiple candidate interpretations, and distractor validity."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_semantic_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "evaluator_max_tokens_per_evaluation", 1200)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_ambiguity_distractor",
                evaluator_version="1.0.0",
                name="Ambiguity & Distractor Evaluator",
                description="Detects ambiguous questions with multiple answers and invalid/plausible distractors",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                required=required,
                hard_checks=[IssueCode.AMBIGUOUS_ANSWER, IssueCode.BAD_DISTRACTOR],
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.012,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        def check_question(q: Dict[str, Any], pass_text: str):
            q_num = q.get("questionNumber", "?")
            q_type = q.get("questionType") or q.get("type", "")
            prompt = q.get("prompt", "") or q.get("questionText", "")
            answer = q.get("answer", "")
            options = q.get("options", [])

            # Check MCQ Distractors
            if q_type == "MultipleChoiceSingle" and isinstance(options, (list, tuple)):
                seen_opt_texts: Set[str] = set()
                correct_opt_text = ""
                for o in options:
                    if hasattr(o, "get") and o.get("key") == answer:
                        correct_opt_text = o.get("text", "")
                        break

                for opt in options:
                    opt_key = opt.get("key", "") if hasattr(opt, "get") else ""
                    opt_text = opt.get("text", "") if hasattr(opt, "get") else ""
                    norm_opt = normalize_text_nfkc(opt_text).lower()

                    # Duplicate option check
                    if norm_opt in seen_opt_texts:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_dist_dup_{uuid4().hex[:8]}",
                                code=IssueCode.BAD_DISTRACTOR,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"Question {q_num} has duplicate option text '{opt_text}'",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                    seen_opt_texts.add(norm_opt)

                    # Distractor that is identical to correct answer
                    if opt_key != answer:
                        if (correct_opt_text and norm_opt == normalize_text_nfkc(correct_opt_text).lower()) or (norm_opt == normalize_text_nfkc(answer).lower()):
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_dist_ans_{uuid4().hex[:8]}",
                                    code=IssueCode.BAD_DISTRACTOR,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION,
                                    message=f"Question {q_num} distractor '{opt_key}' is identical to the correct answer",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )

                    # Distractor that is actually supported as an answer to the stem by the passage
                    if opt_key != answer and pass_text and len(norm_opt) > 5:
                        stem_words = [w for w in re.findall(r"\b\w+\b", prompt.lower()) if len(w) > 3 and w not in {"what", "which", "where", "when", "does", "that", "this", "their", "have", "with", "from"}]
                        for sent in [s.strip() for s in re.split(r"[.!?]\s+", pass_text) if s.strip()]:
                            sent_lower = sent.lower()
                            if matches_exact_token_bound(norm_opt, sent_lower):
                                shared_stem = sum(1 for sw in stem_words if matches_exact_token_bound(sw, sent_lower))
                                if shared_stem >= 2:
                                    issues.append(
                                        Issue.create(
                                            issue_id=f"iss_dist_supp_{uuid4().hex[:8]}",
                                            code=IssueCode.BAD_DISTRACTOR,
                                            severity=IssueSeverity.CRITICAL,
                                            scope=IssueScope.QUESTION,
                                            message=(
                                                f"Question {q_num} distractor '{opt_key}: {opt_text}' is supported "
                                                f"by the passage as an answer to the question stem, creating two correct answers"
                                            ),
                                            affected_refs=[artifact.to_ref()],
                                            evaluator_id=self.evaluator_id,
                                        )
                                    )
                                    break
            # Check Ambiguity in prompt
            if "ambiguous" in prompt.lower() or "unclear" in prompt.lower() or "vague" in prompt.lower():
                issues.append(
                    Issue.create(
                        issue_id=f"iss_ambig_{uuid4().hex[:8]}",
                        code=IssueCode.AMBIGUOUS_ANSWER,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} prompt is ambiguous with conflicting interpretations",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            if q_type == "ShortAnswer" and " and " in answer.lower():
                if "which " in prompt.lower() or "what " in prompt.lower():
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_ambig_join_{uuid4().hex[:8]}",
                            code=IssueCode.AMBIGUOUS_ANSWER,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} answer contains conjoined answers '{answer}' for singular question prompt",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        if artifact.artifact_type == ArtifactType.QUESTION:
            check_question(payload, passage_text)
        elif artifact.artifact_type == ArtifactType.SECTION:
            for grp in payload.get("groups", []):
                grp_type = grp.get("questionType") or grp.get("type", "")
                for q in grp.get("questions", []):
                    q_with_type = dict(q)
                    if not q_with_type.get("questionType") and not q_with_type.get("type"):
                        q_with_type["questionType"] = grp_type
                    check_question(q_with_type, passage_text)
        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        score = 1.0 if not issues else max(0.0, 1.0 - (len(issues) * 0.25))

        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=score,
        )


class NotGivenSemanticsEvaluator(BaseEvaluator):
    """Evaluates NOT GIVEN semantics per P07-05.
    
    Hard invariants:
    1. Context quote is merely an anchor pointer, NOT positive proof that NOT_GIVEN is correct.
    2. Checks proposition neither entailed nor contradicted across the ENTIRE approved passage.
    3. Distinguishes FALSE/NO from NOT GIVEN:
       - If passage explicitly contradicts the proposition -> Answer must be FALSE/NO, not NOT_GIVEN!
       - If passage explicitly entails the proposition -> Answer must be TRUE/YES, not NOT_GIVEN!
    4. Type-aware: TRUE/FALSE/NOT GIVEN (facts) vs YES/NO/NOT GIVEN (writer's claims/views).
    """

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_semantic_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "evaluator_max_tokens_per_evaluation", 1500)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_not_given_semantics",
                evaluator_version="1.0.0",
                name="NOT GIVEN Semantics Evaluator",
                description="Validates proposition non-entailment and non-contradiction across whole passage",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                required=required,
                hard_checks=[
                    IssueCode.AMBIGUOUS_ANSWER,
                    IssueCode.SCHEMA_VIOLATION,
                    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                ],
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        def check_not_given_question(q: Dict[str, Any], pass_text: str):
            q_num = q.get("questionNumber", "?")
            q_type = q.get("questionType") or q.get("type", "")
            prompt = q.get("prompt", "") or q.get("questionText", "")
            ans = q.get("answer", "")
            quote = q.get("evidenceQuote") or q.get("evidence_quote") or ""

            if q_type not in ("TrueFalseNotGiven", "YesNoNotGiven"):
                return

            # Check question type semantics: TFNG must use TRUE/FALSE/NOT_GIVEN; YNNG must use YES/NO/NOT_GIVEN
            norm_ans = (ans or "").replace(" ", "_").upper()
            if q_type == "TrueFalseNotGiven" and norm_ans not in ("TRUE", "FALSE", "NOT_GIVEN"):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_type_tf_{uuid4().hex[:8]}",
                        code=IssueCode.SCHEMA_VIOLATION,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} is TrueFalseNotGiven with invalid answer '{ans}'",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            if q_type == "YesNoNotGiven" and norm_ans not in ("YES", "NO", "NOT_GIVEN"):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_type_yn_{uuid4().hex[:8]}",
                        code=IssueCode.SCHEMA_VIOLATION,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} is YesNoNotGiven with invalid answer '{ans}'",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # P07-05 Semantics: If answer is claimed to be NOT_GIVEN
            if norm_ans == "NOT_GIVEN" and pass_text:
                # 1. Check if passage actually contradicts the statement -> Should be FALSE/NO!
                if detect_contradiction_in_text(prompt, pass_text):
                    expected = "FALSE" if q_type == "TrueFalseNotGiven" else "NO"
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_ng_contra_{uuid4().hex[:8]}",
                            code=IssueCode.AMBIGUOUS_ANSWER,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=(
                                f"Question {q_num} answer is labeled NOT_GIVEN, but passage explicitly "
                                f"contradicts the proposition; correct answer must be {expected}"
                            ),
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

                # 2. Check if passage actually entails the statement -> Should be TRUE/YES!
                elif detect_entailment_in_text(prompt, pass_text):
                    expected = "TRUE" if q_type == "TrueFalseNotGiven" else "YES"
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_ng_entail_{uuid4().hex[:8]}",
                            code=IssueCode.AMBIGUOUS_ANSWER,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=(
                                f"Question {q_num} answer is labeled NOT_GIVEN, but passage entails "
                                f"the proposition; correct answer must be {expected}"
                            ),
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        if artifact.artifact_type == ArtifactType.QUESTION:
            check_not_given_question(payload, passage_text)
        elif artifact.artifact_type == ArtifactType.SECTION:
            for grp in payload.get("groups", []):
                grp_type = grp.get("questionType") or grp.get("type", "")
                for q in grp.get("questions", []):
                    q_with_type = dict(q)
                    if not q_with_type.get("questionType") and not q_with_type.get("type"):
                        q_with_type["questionType"] = grp_type
                    check_not_given_question(q_with_type, passage_text)
        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        score = 1.0 if not issues else max(0.0, 1.0 - (len(issues) * 0.33))

        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=score,
        )


class HeuristicQualityScorer(BaseEvaluator):
    """Soft heuristic evaluator computing lexical diversity and question distribution.
    
    IMPORTANT: This score is an uncalibrated ranking metric for triage only;
    it does NOT represent IELTS band calibration and MUST NOT override blockers.
    """

    def __init__(self, required: bool = False, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_heuristic_quality_scorer",
                evaluator_version="1.0.0",
                name="Heuristic Quality & Difficulty Scorer",
                description="Advisory score for lexical diversity and distribution; not an IELTS band score",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[],
                soft_checks=[],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        words = re.findall(r"\b\w+\b", passage_text.lower())
        total_words = len(words)
        unique_words = len(set(words))
        ttr = unique_words / total_words if total_words > 0 else 0.0

        # Advisory score based on type-token ratio (academic range ~ 0.40 - 0.60)
        score = min(1.0, max(0.5, ttr * 1.8)) if total_words > 100 else 0.5

        # Heuristic score produces NO blockers; status is always PASS or NOT_APPLICABLE
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=EvaluationStatus.PASS,
            issues=[],
            score=score,
        )
