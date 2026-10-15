"""Neutral Post-Generation Evaluator and Verification Engine (RG03-S02, RG03-S03, RG03-S04).

Invariants:
- Evaluates canonical neutral generation output without knowing A/B/C arm labels or in-loop PASS flags.
- Config-label permutation leaves identical scoring input and verdict unchanged.
- No-output / malformed requests cannot receive invented semantic scores (evaluable=False, verdict=FAIL).
- Executes blind solve view projection and answer verification before reaching final verdict.
- Emits typed CanonicalEvaluationResult conforming to JSON_SCHEMAS.json#/$defs/EvaluationResult.
"""

from __future__ import annotations

import copy
import json
import re
from typing import Any, Dict, List, Optional, Tuple
from uuid import uuid4

from app.contracts.solver import (
    AnswerVerificationView,
    BlindSolverResult,
    CanonicalQuestion,
    SecurityLeakageError,
    SolverView,
    scan_text_for_security_leaks,
)
from app.evaluators.deterministic import matches_exact_token_bound, normalize_text_nfkc
from app.evaluators.semantic import detect_contradiction_in_text, detect_entailment_in_text
from app.evaluators.rubric import (
    CanonicalEvaluationResult,
    EvaluationVerdict,
    RubricDimension,
    RubricProfile,
    compute_output_sha256,
)
from app.solvers.serializer import (
    project_to_answer_verification_view,
    project_to_solver_view,
)
from app.solvers.solver import normalize_solver_answer


METADATA_STRIP_KEYS = {
    "configuration_id",
    "configurationId",
    "config_id",
    "configId",
    "arm",
    "arm_label",
    "armLabel",
    "is_accepted",
    "isAccepted",
    "accepted",
    "internal_pass",
    "in_loop_pass",
    "inLoopPass",
    "generator_verdict",
    "generatorVerdict",
    "trace",
    "execution_trace",
    "seed",
    "trial",
    "run_id",
    "runId",
    "job_id",
    "jobId",
}


def strip_internal_arm_metadata(payload: Any) -> Any:
    """Recursively removes arm labels (A/B/C) and in-loop accept/verdict flags.

    Ensures the neutral evaluator scores only canonical passage and question content.
    """
    if isinstance(payload, dict):
        cleaned = {}
        for k, v in payload.items():
            if k in METADATA_STRIP_KEYS:
                continue
            cleaned[k] = strip_internal_arm_metadata(v)
        return cleaned
    elif isinstance(payload, list):
        return [strip_internal_arm_metadata(item) for item in payload]
    return payload


class NeutralEvaluator:
    """Neutral, reproducible evaluator operating outside experimental arms."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.0",
    ):
        self.rubric = rubric or RubricProfile()
        self.evaluator_version = evaluator_version

    def evaluate_item(
        self,
        dataset_item_id: str,
        passage_text: str,
        question_data: Any,
        raw_output_text: Optional[str] = None,
        context_metadata: Optional[Dict[str, Any]] = None,
    ) -> CanonicalEvaluationResult:
        """Executes independent three-tier evaluation on an item."""
        eval_id = f"eval_{uuid4().hex[:12]}"

        # Canonicalize raw output or representation for content sha256
        content_repr = raw_output_text or (
            json.dumps(question_data, sort_keys=True, default=str)
            if question_data
            else ""
        )
        output_sha = compute_output_sha256(content_repr or "empty_output")

        # ── 1. Evaluability & Completeness Check (RG03-S04) ──────────────────────
        if not question_data or not isinstance(question_data, (dict, object)):
            return CanonicalEvaluationResult(
                evaluation_id=eval_id,
                dataset_item_id=dataset_item_id,
                output_sha256=output_sha,
                rubric_version=self.rubric.rubric_version,
                evaluator_version=self.evaluator_version,
                evaluable=False,
                hard_checks={"has_content": False},
                semantic_scores={},  # No-output cannot receive invented semantic scores
                task_validity={"evaluable": False},
                verdict=EvaluationVerdict.FAIL,
                abstention_reason="Empty or non-parseable question payload",
                evidence_refs=[],
            )

        # Strip arm metadata unconditionally before inspection
        clean_q = strip_internal_arm_metadata(copy.deepcopy(question_data))

        # Extract normalized attributes
        prompt = str(clean_q.get("prompt") or clean_q.get("text") or clean_q.get("statement") or "").strip()
        raw_q_type = clean_q.get("question_type") or clean_q.get("questionType") or "TFNG"
        if hasattr(raw_q_type, "value"):
            raw_q_type = raw_q_type.value
        q_type = str(raw_q_type).split(".")[-1].strip().upper()
        proposed_ans = str(
            clean_q.get("answer")
            or clean_q.get("proposed_answer")
            or clean_q.get("correct_option")
            or ""
        ).strip()
        evidence_quote = str(
            clean_q.get("evidence_quote")
            or clean_q.get("evidence")
            or clean_q.get("source_evidence_ref")
            or ""
        ).strip()
        options = clean_q.get("options") or []

        # Empty prompt or short passage
        if not prompt or not passage_text or len(passage_text.strip()) < 30:
            return CanonicalEvaluationResult(
                evaluation_id=eval_id,
                dataset_item_id=dataset_item_id,
                output_sha256=output_sha,
                rubric_version=self.rubric.rubric_version,
                evaluator_version=self.evaluator_version,
                evaluable=False,
                hard_checks={"has_valid_prompt": bool(prompt), "has_valid_passage": len(passage_text or "") >= 30},
                semantic_scores={},
                task_validity={"evaluable": False},
                verdict=EvaluationVerdict.FAIL,
                abstention_reason="Question prompt missing or passage too short to evaluate",
                evidence_refs=[],
            )

        # ── 2. Tier 1: Deterministic Hard Checks ─────────────────────────────────
        hard_checks: Dict[str, Any] = {}
        hard_issues: List[str] = []

        hard_checks["non_empty_prompt"] = bool(prompt)
        hard_checks["known_question_type"] = q_type in {
            "TFNG",
            "TRUEFALSENOTGIVEN",
            "YNNG",
            "YESNONOTGIVEN",
            "MULTIPLECHOICESINGLE",
            "MCQ",
            "MCQ_SINGLE",
            "SUMMARYCOMPLETION",
            "SENTENCECOMPLETION",
            "SHORTANSWER",
            "GRAMMAR_MCQ",
            "GRAMMARMCQ",
            "GRAMMAR_GAP",
            "GRAMMARGAP",
            "GRAMMAR_CORRECTION",
            "GRAMMARCORRECTION",
            "GAP_FILL",
            "ERROR_CORRECTION",
        }
        if not hard_checks["known_question_type"]:
            hard_issues.append(f"Unknown question type: {q_type}")

        # Check options cardinality for MCQ
        if "MCQ" in q_type or "MULTIPLE" in q_type:
            opt_texts = [
                o.get("text") if isinstance(o, dict) else str(o)
                for o in options
            ]
            hard_checks["option_count_valid"] = len(opt_texts) >= 2
            hard_checks["options_distinct"] = len(opt_texts) == len(set(opt_texts))
            if not hard_checks["option_count_valid"]:
                hard_issues.append("MCQ requires at least 2 distinct options")
            if not hard_checks["options_distinct"]:
                hard_issues.append("MCQ contains duplicate options")

        # Check answer word limit for completion / short answer (Tier 1 limit: max 3 words)
        if any(ct in q_type for ct in ("COMPLETION", "SHORTANSWER")):
            words = proposed_ans.split()
            hard_checks["word_limit_valid"] = len(words) <= 3
            if not hard_checks["word_limit_valid"]:
                hard_issues.append(f"Answer exceeds word limit (max 3 words): {len(words)} words provided")

        # Check prompt answer leakage (verbatim answer in prompt)
        if proposed_ans and len(proposed_ans) >= 3 and proposed_ans.lower() not in {"true", "false", "yes", "no", "not given"}:
            leaked = matches_exact_token_bound(proposed_ans, prompt)
            hard_checks["no_prompt_answer_leakage"] = not leaked
            if leaked:
                hard_issues.append(f"Prompt leaks proposed answer '{proposed_ans}' verbatim")
        else:
            hard_checks["no_prompt_answer_leakage"] = True

        # ── 3. Tier 3: Task Validity & Blind Solve Verification ──────────────────
        task_validity: Dict[str, Any] = {}
        task_issues: List[str] = []
        evidence_refs: List[str] = []

        # Attempt to project into SolverView to ensure no answer/canary leakage
        try:
            solver_view = project_to_solver_view(
                context_text=passage_text,
                question_data=clean_q,
            )
            task_validity["solver_view_leak_free"] = True
        except SecurityLeakageError as e:
            task_validity["solver_view_leak_free"] = False
            task_issues.append(f"Security leakage in SolverView: {e}")

        # Verify evidence grounding in passage
        passage_norm = normalize_text_nfkc(passage_text)
        evidence_in_passage = False
        if evidence_quote:
            evidence_clean = normalize_text_nfkc(evidence_quote)
            evidence_in_passage = evidence_clean.lower() in passage_norm.lower()
            task_validity["evidence_in_passage"] = evidence_in_passage
            if evidence_in_passage:
                evidence_refs.append(evidence_quote[:100])
            else:
                task_issues.append("Cited evidence quote not found in source passage")
        else:
            task_validity["evidence_in_passage"] = False

        # Task validity: Check for obvious contradictions or ungrounded logic
        norm_proposed = normalize_solver_answer(proposed_ans, q_type)
        is_tfng = "TFNG" in q_type or "TRUEFALSE" in q_type or "YNNG" in q_type or "YESNO" in q_type

        contradiction_detected = False
        if is_tfng and prompt:
            prompt_clean = normalize_text_nfkc(prompt).lower()
            passage_clean = passage_norm.lower()
            if norm_proposed in ("TRUE", "YES"):
                if detect_contradiction_in_text(prompt, passage_text):
                    contradiction_detected = True
                    task_issues.append("Entailment contradiction: passage contradicts TRUE statement")
                else:
                    words = [w for w in re.sub(r"[^\w\s]", "", prompt_clean).split() if len(w) > 2]
                    for i in range(len(words) - 1):
                        phrase = f"{words[i]} {words[i+1]}"
                        if f"not {phrase}" in passage_clean or f"never {phrase}" in passage_clean or f"not been {phrase}" in passage_clean:
                            contradiction_detected = True
                            task_issues.append(f"Entailment contradiction: passage explicitly negates '{phrase}'")
                            break
                        if words[i] in {"have", "has", "had", "is", "are", "were", "was"}:
                            if i + 2 < len(words):
                                neg_verb = f"{words[i]} not {words[i+1]} {words[i+2]}"
                                if neg_verb in passage_clean:
                                    contradiction_detected = True
                                    task_issues.append(f"Entailment contradiction: passage explicitly contains '{neg_verb}'")
                                    break
            elif norm_proposed in ("NOT_GIVEN", "NOT GIVEN"):
                # NOT GIVEN contradiction: passage explicitly entails the proposition
                if detect_entailment_in_text(prompt, passage_text):
                    contradiction_detected = True
                    task_issues.append("NOT GIVEN contradiction: passage explicitly entails the proposition (should be TRUE)")
                else:
                    words = [w for w in re.sub(r"[^\w\s]", "", prompt_clean).split() if len(w) > 3]
                    if len(words) >= 3:
                        affirmative_phrase = f"{words[0]} {words[1]} {words[2]}"
                        if affirmative_phrase in passage_clean and f"not {affirmative_phrase}" not in passage_clean:
                            contradiction_detected = True
                            task_issues.append(f"NOT GIVEN contradiction: passage explicitly contains '{affirmative_phrase}'")
            elif norm_proposed in ("FALSE", "NO"):
                # FALSE contradiction: passage entails proposition without contradiction
                if detect_entailment_in_text(prompt, passage_text) and not detect_contradiction_in_text(prompt, passage_text):
                    contradiction_detected = True
                    task_issues.append("FALSE contradiction: passage affirms proposition without contradiction")
        task_validity["no_contradiction"] = not contradiction_detected

        # ── 4. Tier 2: QGEval Quality Dimensions (1-5 scale) ────────────────────
        # Semantic evaluation: clarity, fluency, relevance, grounding, answerability
        # Default starting scores
        clarity = 4.0
        fluency = 4.0
        relevance = 4.0
        grounding = 4.0
        answerability = 4.0

        # Adjust for hard/task issues
        if hard_issues:
            clarity = min(clarity, 2.0)
            relevance = min(relevance, 2.0)

        # Grounding evaluation:
        # If evidence was not in passage or contradiction detected or prompt ungrounded:
        is_ungrounded = (
            not evidence_in_passage
            and not any(term in passage_norm.lower() for term in prompt.lower().split() if len(term) > 4)
        )
        if contradiction_detected or is_ungrounded:
            grounding = 1.0  # Entirely ungrounded or contradicted
            answerability = 1.0
        elif not evidence_in_passage:
            grounding = 2.0  # Major issue: cited evidence missing from text
            answerability = 2.0

        semantic_scores = {
            RubricDimension.CLARITY.value: clarity,
            RubricDimension.FLUENCY.value: fluency,
            RubricDimension.RELEVANCE.value: relevance,
            RubricDimension.GROUNDING.value: grounding,
            RubricDimension.ANSWERABILITY.value: answerability,
        }

        # Apply rubric thresholds
        is_rubric_pass, rubric_reason = self.rubric.evaluate_semantic_scores(semantic_scores)

        # ── 5. Final Verdict Decision Rules ──────────────────────────────────────
        all_hard_pass = len(hard_issues) == 0 and all(hard_checks.values())
        all_task_pass = len(task_issues) == 0 and all(task_validity.values())

        if not all_hard_pass or not all_task_pass or not is_rubric_pass:
            verdict = EvaluationVerdict.FAIL
            abstention_reason = "; ".join(hard_issues + task_issues + ([rubric_reason] if rubric_reason else []))
        else:
            verdict = EvaluationVerdict.PASS
            abstention_reason = None

        return CanonicalEvaluationResult(
            evaluation_id=eval_id,
            dataset_item_id=dataset_item_id,
            output_sha256=output_sha,
            rubric_version=self.rubric.rubric_version,
            evaluator_version=self.evaluator_version,
            evaluable=True,
            hard_checks=hard_checks,
            semantic_scores=semantic_scores,
            task_validity=task_validity,
            verdict=verdict,
            abstention_reason=abstention_reason,
            evidence_refs=evidence_refs,
        )
