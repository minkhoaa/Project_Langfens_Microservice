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
import os
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
from app.evaluators.semantic import (
    COMMON_BASE_VERBS,
    IRREGULAR_PAST_PARTICIPLES,
    IRREGULAR_PAST_VERBS,
    NegativeInversionValidationResult,
    check_content_aware_novelty,
    compute_substantive_grounding_ratio,
    detect_cleft_distractor_ambiguity,
    detect_comparison_inversion,
    detect_contradiction_in_text,
    detect_contracted_negative_inversion,
    detect_entailment_in_text,
    detect_it_cleft_syntax,
    detect_negation_polarity_conflict,
    detect_negative_inversion_structural,
    detect_negative_inversion_syntax,
    detect_unsupported_generalization,
    validate_negative_inversion_grammaticality,
)
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

BASE_EED_VERBS = {
    "need", "feed", "bleed", "proceed", "succeed", "exceed", "breed", "speed"
}



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


def parse_evaluator_version_tuple(version_str: str) -> tuple[int, int]:
    """Parses numeric (major, minor) version tuple from version string."""
    m = re.search(r"v?(\d+)\.(\d+)", version_str)
    if m:
        return int(m.group(1)), int(m.group(2))
    return (2, 0)


class NeutralEvaluator:
    """Neutral, reproducible evaluator operating outside experimental arms."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.0",
    ):
        self.rubric = rubric or RubricProfile()
        self.evaluator_version = evaluator_version
        self.version_tuple = parse_evaluator_version_tuple(evaluator_version)

    @property
    def is_v2_1_plus(self) -> bool:
        return self.version_tuple >= (2, 1)

    @property
    def is_v2_2_plus(self) -> bool:
        return self.version_tuple >= (2, 2)

    @property
    def is_v2_3_plus(self) -> bool:
        return self.version_tuple >= (2, 3)

    @property
    def is_v2_4_plus(self) -> bool:
        return self.version_tuple >= (2, 4)
    @property
    def is_v2_5_plus(self) -> bool:
        return self.version_tuple >= (2, 5)

    @property
    def is_v2_6_plus(self) -> bool:
        return self.version_tuple >= (2, 6)

    @property
    def is_v2_7_plus(self) -> bool:
        return self.version_tuple >= (2, 7)


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
            or (context_metadata.get("evidence_quote") if context_metadata else "")
            or (context_metadata.get("evidence_span") if context_metadata else "")
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

        # Check proposed answer availability (v2.3+ fails closed if proposed answer is missing)
        if not proposed_ans:
            if self.is_v2_3_plus:
                hard_checks["has_proposed_answer"] = False
                hard_issues.append("UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key")
        else:
            hard_checks["has_proposed_answer"] = True

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
        if self.is_v2_3_plus and not proposed_ans:
            task_validity["has_proposed_answer"] = False
            task_issues.append("UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key")
        elif self.is_v2_3_plus:
            task_validity["has_proposed_answer"] = True
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

        is_v2_2 = self.is_v2_2_plus
        is_v2_3 = self.is_v2_3_plus
        norm_proposed = normalize_solver_answer(proposed_ans, q_type)
        is_tfng = "TFNG" in q_type or "TRUEFALSE" in q_type or "YNNG" in q_type or "YESNO" in q_type
        contradiction_detected = False

        # Verify evidence grounding in passage
        passage_norm = normalize_text_nfkc(passage_text)
        evidence_in_passage = False
        is_grammar = (
            "GRAMMAR" in q_type
            or (context_metadata and ("rule_pack" in context_metadata or context_metadata.get("is_grammar")))
            or "grammar" in dataset_item_id.lower()
        )
        if evidence_quote:
            evidence_clean = normalize_text_nfkc(evidence_quote)
            evidence_in_passage = evidence_clean.lower() in passage_norm.lower()
            task_validity["evidence_in_passage"] = evidence_in_passage
            if evidence_in_passage:
                evidence_refs.append(evidence_quote[:100])
                if is_v2_2:
                    if not is_grammar:
                        # Verify evidence quote relevance: prompt must share substantive content with cited quote
                        prompt_words = {w.lower() for w in re.findall(r"\b[a-zA-Z]{4,}\b", prompt)} - {
                            "statement", "according", "passage", "which", "following", "true", "false", "given"
                        }
                        quote_words = {w.lower() for w in re.findall(r"\b[a-zA-Z]{4,}\b", evidence_quote)}
                        if self.is_v2_5_plus and options:
                            opt_words = {
                                w.lower()
                                for opt in options
                                for w in re.findall(r"\b[a-zA-Z]{4,}\b", opt.get("text", "") if isinstance(opt, dict) else str(opt))
                            }
                            target_words = prompt_words | opt_words
                        else:
                            target_words = prompt_words
                        if target_words and not (target_words & quote_words):
                            task_issues.append("Irrelevant evidence citation: cited evidence quote shares no substantive content with question prompt")
                    if norm_proposed in ("TRUE", "YES"):
                        has_neg_conflict, neg_msg = detect_negation_polarity_conflict(prompt, evidence_quote)
                        has_comp_inversion = detect_comparison_inversion(prompt, evidence_quote)
                        has_contra = detect_contradiction_in_text(prompt, evidence_quote, enable_contrastive_exclusion=is_v2_3, enable_refined_contrastive_clause=self.is_v2_4_plus)
                        if has_neg_conflict or has_comp_inversion or has_contra:
                            contradiction_detected = True
                            task_issues.append(f"Entailment contradiction: cited evidence quote contradicts TRUE statement ({neg_msg or 'polarity/comparison conflict'})")
            else:
                task_issues.append("Cited evidence quote not found in source passage")
        elif is_grammar:
            rule_pack = context_metadata.get("rule_pack") if context_metadata else None
            if rule_pack is None:
                # Fails grounding verification closed: cannot verify grammar grounding without authoritative rule pack
                evidence_in_passage = False
                task_validity["evidence_in_passage"] = False
                task_issues.append("GrammarRulePack required for grammar grounding verification but not provided in context")
            else:
                # Real verification against the GrammarRulePack: check rule IDs, examples, or structural cues
                rp_id = getattr(rule_pack, "rule_pack_id", "")
                rule_ids = set(getattr(rule_pack, "rule_ids", []))
                examples = [normalize_text_nfkc(ex).lower() for ex in getattr(rule_pack, "examples", [])]
                topic = getattr(rule_pack, "topic", "").lower()
                q_rule_ids = set(clean_q.get("rule_ids") or ([clean_q["rule_id"]] if "rule_id" in clean_q else []))
                prompt_norm = normalize_text_nfkc(prompt).lower()
                # In v2.2, also inspect options text for rule cues and examples
                all_text_to_check = [prompt_norm]
                if is_v2_2 and options:
                    for opt in options:
                        opt_str = opt.get("text") if isinstance(opt, dict) else str(opt)
                        all_text_to_check.append(normalize_text_nfkc(opt_str).lower())

                matches_rule_ids = bool(q_rule_ids and q_rule_ids.issubset(rule_ids))
                matches_example = any(
                    any(ex in txt or txt in ex for ex in examples)
                    for txt in all_text_to_check
                )
                prompt_words = [w for w in re.sub(r"[^\w\s]", "", prompt_norm).split() if len(w) > 2]
                matches_example_phrase = any(
                    " ".join(prompt_words[i:i+3]) in ex
                    for ex in examples
                    for i in range(len(prompt_words) - 2)
                ) if len(prompt_words) >= 3 else False
                
                # Inversion, cleft, and conditional cues from topic
                topic_cues = []
                if "inversion" in topic:
                    topic_cues = [
                        "seldom", "never", "under no circumstances", "rarely", "not only", "hardly", "scarcely",
                        "at no point", "on no account", "were the", "had the", "should you", "not until",
                        "at no time", "in no way", "little did", "only when", "only after", "should we", "were they", "had they"
                    ]
                elif "cleft" in topic:
                    topic_cues = ["it was", "it is", "what ", "the reason why", "the thing that", "all that"]
                elif "conditional" in topic:
                    topic_cues = ["if ", "had the", "were the", "should the", "provided that", "unless"]
                elif "passive" in topic or "reporting" in topic:
                    topic_cues = ["is believed to", "are believed to", "is reported to", "are reported to", "is thought to", "are thought to", "is considered to"]
                elif "modal" in topic:
                    topic_cues = ["must have", "could have", "should have", "might have", "would have", "cannot have"]
                elif "subjunctive" in topic:
                    topic_cues = ["mandate", "mandates", "insist", "insists", "demand", "demands", "require", "requires", "recommend", "recommends", "propose", "proposes", "suggest", "suggests", "subjunctive"]
                elif "participle" in topic:
                    topic_cues = ["having ", "being ", "ed by", "ing the", "participle"]
                matches_topic_cue = any(
                    any(cue in txt for cue in topic_cues)
                    for txt in all_text_to_check
                ) if topic_cues else False
                
                if matches_rule_ids or matches_example or matches_example_phrase or matches_topic_cue:
                    evidence_in_passage = True
                    task_validity["evidence_in_passage"] = True
                    evidence_refs.append(f"rule_pack:{rp_id}")
                else:
                    evidence_in_passage = False
                    task_validity["evidence_in_passage"] = False
                    task_issues.append(f"Question prompt does not exercise GrammarRulePack '{rp_id}'")

                # In v2.2: Distractor validity and answer uniqueness check for Grammar MCQ
                if is_v2_2 and options and "MCQ" in q_type:
                    opt_texts = [
                        o.get("text") if isinstance(o, dict) else str(o)
                        for o in options
                    ]
                    # Duplicate option check
                    norm_opts = [re.sub(r"^[A-Da-d][\).:]\s*", "", ot.strip()).lower() for ot in opt_texts]
                    if len(set(norm_opts)) < len(norm_opts):
                        task_issues.append("Defective MCQ: options contain duplicate choices")
                        task_validity["unique_correct_answer"] = False

                    if "inversion" in topic:
                        if self.is_v2_6_plus:
                            validation_results = [
                                validate_negative_inversion_grammaticality(
                                    opt_t,
                                    allow_contracted=False,
                                    allow_ss_base_verbs=self.is_v2_7_plus,
                                )
                                for opt_t in opt_texts
                            ]
                            valid_inversion_opts = [
                                idx + 1 for idx, r in enumerate(validation_results)
                                if r.verdict == "VALID"
                            ]
                            uncertain_inversion_opts = [
                                idx + 1 for idx, r in enumerate(validation_results)
                                if r.verdict == "UNCERTAIN"
                            ]
                            contracted_inversion_opts = [
                                idx + 1 for idx, opt_t in enumerate(opt_texts)
                                if detect_contracted_negative_inversion(opt_t)
                            ]
                            is_neg_polarity_q = any(term in prompt_norm for term in ["incorrect", "does not", "fails to", "wrong"])
                            if not is_neg_polarity_q:
                                if uncertain_inversion_opts:
                                    task_issues.append(
                                        f"Inconclusive MCQ: option(s) {uncertain_inversion_opts} could not be conclusively validated: {validation_results[uncertain_inversion_opts[0]-1].rejection_reason or 'uncertain linguistic judgment'}"
                                    )
                                    task_validity["unique_correct_answer"] = False
                                elif len(valid_inversion_opts) > 1:
                                    task_issues.append(
                                        f"Ambiguous MCQ: multiple options {valid_inversion_opts} exhibit valid negative inversion (distractor validity failure)"
                                    )
                                    task_validity["unique_correct_answer"] = False
                                elif len(valid_inversion_opts) == 1 and contracted_inversion_opts:
                                    extra_contracted = set(contracted_inversion_opts) - set(valid_inversion_opts)
                                    if extra_contracted:
                                        task_issues.append(
                                            f"Contested MCQ: option {list(extra_contracted)} exhibits contracted negative auxiliary inversion syntax, creating distractor ambiguity"
                                        )
                                        task_validity["unique_correct_answer"] = False
                                    else:
                                        task_validity["unique_correct_answer"] = True
                                elif len(valid_inversion_opts) == 0:
                                    task_issues.append("Defective MCQ: no options exhibit valid negative inversion")
                                    task_validity["unique_correct_answer"] = False
                                else:
                                    valid_idx = valid_inversion_opts[0] - 1
                                    valid_res = validation_results[valid_idx]
                                    stem_conflict = False
                                    if "uses 'do'" in prompt_norm or 'uses "do"' in prompt_norm or "using 'do'" in prompt_norm or 'using "do"' in prompt_norm:
                                        if valid_res.auxiliary not in ("do", "does", "did"):
                                            task_issues.append(
                                                f"Stem-answer constraint conflict: question stem specifically requests 'do' inversion, but unique valid option uses auxiliary '{valid_res.auxiliary}'"
                                            )
                                            task_validity["unique_correct_answer"] = False
                                            stem_conflict = True
                                    if not stem_conflict:
                                        norm_prop = normalize_solver_answer(proposed_ans, q_type)
                                        prop_idx = ord(norm_prop) - ord("A") if norm_prop in ["A", "B", "C", "D"] else -1
                                        if prop_idx >= 0 and prop_idx != valid_idx:
                                            task_issues.append(
                                                f"Proposed answer key discord: proposed answer points to option {norm_prop} (index {prop_idx+1}), but unique grammatically valid option is {chr(ord('A') + valid_idx)} (index {valid_idx+1})"
                                            )
                                            task_validity["unique_correct_answer"] = False
                                        else:
                                            task_validity["unique_correct_answer"] = True
                        else:
                            valid_inversion_opts = [
                                idx + 1 for idx, opt_t in enumerate(opt_texts)
                                if detect_negative_inversion_syntax(opt_t, allow_contracted=False)
                            ]
                            contracted_inversion_opts = [
                                idx + 1 for idx, opt_t in enumerate(opt_texts)
                                if detect_contracted_negative_inversion(opt_t)
                            ]
                            is_neg_polarity_q = any(term in prompt_norm for term in ["incorrect", "does not", "fails to", "wrong"])
                            if not is_neg_polarity_q:
                                if len(valid_inversion_opts) > 1:
                                    task_issues.append(
                                        f"Ambiguous MCQ: multiple options {valid_inversion_opts} exhibit valid negative inversion (distractor validity failure)"
                                    )
                                    task_validity["unique_correct_answer"] = False
                                elif len(valid_inversion_opts) == 1 and contracted_inversion_opts:
                                    extra_contracted = set(contracted_inversion_opts) - set(valid_inversion_opts)
                                    if extra_contracted:
                                        task_issues.append(
                                            f"Contested MCQ: option {list(extra_contracted)} exhibits contracted negative auxiliary inversion syntax, creating distractor ambiguity"
                                        )
                                        task_validity["unique_correct_answer"] = False
                                    else:
                                        task_validity["unique_correct_answer"] = True
                                elif len(valid_inversion_opts) == 0:
                                    task_issues.append("Defective MCQ: no options exhibit valid negative inversion")
                                    task_validity["unique_correct_answer"] = False
                                else:
                                    task_validity["unique_correct_answer"] = True
                    elif "cleft" in topic:
                        is_ambig, ambig_reason = detect_cleft_distractor_ambiguity(opt_texts)
                        if is_ambig:
                            task_issues.append(ambig_reason)
                            task_validity["unique_correct_answer"] = False
                        else:
                            # Verify proposed answer validity and tense consistency
                            proposed_text = ""
                            norm_prop = normalize_solver_answer(proposed_ans, q_type)
                            if norm_prop in ["A", "B", "C", "D"]:
                                idx = ord(norm_prop) - ord("A")
                                if 0 <= idx < len(opt_texts):
                                    proposed_text = opt_texts[idx]
                            else:
                                proposed_text = proposed_ans

                            cleft_info = detect_it_cleft_syntax(proposed_text)
                            if cleft_info.get("has_tense_discord"):
                                task_issues.append(f"Tense agreement discord: {cleft_info['tense_discord_reason']}")
                                task_validity["unique_correct_answer"] = False
                            elif not cleft_info.get("is_valid_cleft"):
                                task_issues.append("Defective cleft MCQ: proposed answer is not a valid it-cleft construction")
                                task_validity["unique_correct_answer"] = False
                            else:
                                task_validity["unique_correct_answer"] = True
                    elif "subjunctive" in topic and self.is_v2_6_plus:
                        if self.is_v2_7_plus:
                            mandative_triggers = [
                                "mandate", "mandates", "insist", "insists", "demand", "demands",
                                "require", "requires", "recommend", "recommends", "propose", "proposes",
                                "stipulate", "stipulates", "vital", "crucial", "important", "essential",
                                "mandative", "subjunctive", "formulaic", "decree", "statute", "order", "rule"
                            ]
                            is_mandative = any(mt in prompt_norm for mt in mandative_triggers) or any(
                                mt in getattr(rule_pack, "applicability", [""])[0].lower() for mt in mandative_triggers
                            ) or any(
                                any(mt in opt_t.lower() for mt in mandative_triggers) for opt_t in opt_texts
                            )
                            if is_mandative:
                                def _extract_subjunctive_verb_v27(ot: str) -> str | None:
                                    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", ot.strip())
                                    m_that = re.search(r"\bthat\s+([a-zA-Z\s]+)", clean, re.IGNORECASE)
                                    if not m_that:
                                        return None
                                    words = m_that.group(1).split()
                                    if not words:
                                        return None
                                    first = words[0].lower()
                                    if first in {"she", "he", "it", "they", "we", "you", "i", "one"}:
                                        return words[1].lower().strip(",.") if len(words) > 1 else None
                                    start_idx = 1 if first in {"the", "a", "an", "each", "every", "this", "that", "these", "those", "all", "any", "both", "no"} else 0
                                    if len(words) > start_idx + 2 and words[start_idx].lower() in {
                                        "expert", "chief", "lead", "senior", "authorized", "commercial", "certified", "external", "special"
                                    }:
                                        return words[start_idx + 2].lower().strip(",.")
                                    if len(words) > start_idx + 1:
                                        return words[start_idx + 1].lower().strip(",.")
                                    elif len(words) > start_idx:
                                        return words[start_idx].lower().strip(",.")
                                    return None

                                def _is_base_subjunctive_verb_v27(verb: str | None) -> bool:
                                    if not verb:
                                        return False
                                    v = verb.lower()
                                    if v in {"will", "has", "had", "must", "should", "would", "could", "can", "is", "was", "are", "were", "being", "been"}:
                                        return False
                                    if v in ("be", "have"):
                                        return True
                                    if v.endswith("s") and not v.endswith("ss") and v not in {"pass", "miss", "discuss", "process", "address", "express", "stress", "cross"}:
                                        return False
                                    if v.endswith("ing") and v != "bring":
                                        return False
                                    if v.endswith("ed") and v not in BASE_EED_VERBS:
                                        return False
                                    if v in IRREGULAR_PAST_VERBS:
                                        return False
                                    return True

                                extracted_verbs = [_extract_subjunctive_verb_v27(ot) for ot in opt_texts]
                                if any(v is None for v in extracted_verbs):
                                    unparsed_idx = [idx + 1 for idx, v in enumerate(extracted_verbs) if v is None]
                                    task_issues.append(f"Inconclusive subjunctive MCQ: option(s) {unparsed_idx} could not be conclusively parsed into mandative subjunctive subordinate clause")
                                    task_validity["unique_correct_answer"] = False
                                else:
                                    base_opts = [idx + 1 for idx, v in enumerate(extracted_verbs) if _is_base_subjunctive_verb_v27(v)]
                                    is_neg_polarity_q = any(term in prompt_norm for term in ["incorrect", "does not", "fails to", "wrong"])
                                    if is_neg_polarity_q:
                                        norm_prop = normalize_solver_answer(proposed_ans, q_type)
                                        prop_idx = ord(norm_prop) - ord("A") + 1 if norm_prop in ["A", "B", "C", "D"] else -1
                                        if prop_idx > 0 and prop_idx in base_opts:
                                            task_issues.append(f"Proposed answer {norm_prop} uses valid base subjunctive form in negative-polarity question")
                                            task_validity["unique_correct_answer"] = False
                                        else:
                                            task_validity["unique_correct_answer"] = True
                                    else:
                                        if len(base_opts) == 1:
                                            valid_idx = base_opts[0] - 1
                                            norm_prop = normalize_solver_answer(proposed_ans, q_type)
                                            prop_idx = ord(norm_prop) - ord("A") if norm_prop in ["A", "B", "C", "D"] else -1
                                            if prop_idx >= 0 and prop_idx != valid_idx:
                                                task_issues.append(
                                                    f"Proposed answer key discord: proposed answer points to option {norm_prop} (index {prop_idx+1}), but unique grammatically valid subjunctive option is {chr(ord('A') + valid_idx)} (index {valid_idx+1})"
                                                )
                                                task_validity["unique_correct_answer"] = False
                                            else:
                                                task_validity["unique_correct_answer"] = True
                                        elif len(base_opts) > 1:
                                            task_issues.append(f"Ambiguous subjunctive MCQ: multiple options {base_opts} use base subjunctive form")
                                            task_validity["unique_correct_answer"] = False
                                        elif len(base_opts) == 0:
                                            task_issues.append("Defective subjunctive MCQ: no options use base subjunctive form")
                                            task_validity["unique_correct_answer"] = False
                                        else:
                                            task_validity["unique_correct_answer"] = True
                            else:
                                task_validity["unique_correct_answer"] = True
                        else:
                            mandative_triggers = [
                                "mandate", "mandates", "insist", "insists", "demand", "demands",
                                "require", "requires", "recommend", "recommends", "propose", "proposes",
                                "stipulate", "stipulates", "vital", "crucial", "important", "essential"
                            ]
                            is_mandative = any(mt in prompt_norm for mt in mandative_triggers) or any(
                                mt in getattr(rule_pack, "applicability", [""])[0].lower() for mt in mandative_triggers
                            )
                            if is_mandative:
                                def _extract_subjunctive_verb(ot: str) -> str | None:
                                    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", ot.strip())
                                    m_that = re.search(r"\bthat\s+([a-zA-Z\s]+)", clean, re.IGNORECASE)
                                    if not m_that:
                                        return None
                                    words = m_that.group(1).split()
                                    if not words:
                                        return None
                                    first = words[0].lower()
                                    if first in {"she", "he", "it", "they", "we", "you", "i", "one"}:
                                        return words[1].lower().strip(",.") if len(words) > 1 else None
                                    start_idx = 1 if first in {"the", "a", "an", "each", "every", "this", "that", "these", "those", "all", "any", "both"} else 0
                                    subject_nouns = {
                                        "supplier", "student", "technician", "researcher", "container", "employee",
                                        "applicant", "candidate", "party", "doctor", "patient", "person", "individual",
                                        "staff", "team", "committee", "board", "protocol", "member", "members",
                                        "students", "suppliers", "researchers", "technicians", "device", "system",
                                        "laboratory", "waste", "hazardous", "authorized", "new", "contractor"
                                    }
                                    idx = start_idx
                                    while idx < len(words):
                                        w = words[idx].lower().strip(",.")
                                        if w in subject_nouns:
                                            idx += 1
                                            continue
                                        return w
                                    return None
                                def _extract_all_subjunctive_verbs(opts: list[str]) -> list[str | None]:
                                    that_tails = []
                                    for ot in opts:
                                        clean = re.sub(r"^[A-Da-d][\).:]\s*", "", ot.strip())
                                        m_that = re.search(r"\bthat\s+([a-zA-Z\s]+)", clean, re.IGNORECASE)
                                        that_tails.append(m_that.group(1).split() if m_that else [])

                                    if all(that_tails):
                                        min_len = min(len(t) for t in that_tails)
                                        common_len = 0
                                        while common_len < min_len:
                                            w0 = that_tails[0][common_len].lower()
                                            if all(t[common_len].lower() == w0 for t in that_tails):
                                                common_len += 1
                                            else:
                                                break
                                        if common_len > 0 and all(len(t) > common_len for t in that_tails):
                                            return [t[common_len].lower().strip(",.") for t in that_tails]

                                    return [_extract_subjunctive_verb(ot) for ot in opts]

                                def _is_base_subjunctive_verb(verb: str | None) -> bool:
                                    if not verb:
                                        return False
                                    v = verb.lower()
                                    if v in {"will", "has", "had", "must", "should", "would", "could", "can", "is", "was", "are", "were", "being", "been"}:
                                        return False
                                    if v in ("be", "have"):
                                        return True
                                    if v.endswith("s") and v not in {"pass", "miss", "discuss", "process", "address", "express", "stress", "cross"}:
                                        return False
                                    if v.endswith("ing") and v != "bring":
                                        return False
                                    if v.endswith("ed") and v not in {"need", "feed", "bleed", "proceed", "succeed"}:
                                        return False
                                    if v in IRREGULAR_PAST_VERBS:
                                        return False
                                    return True
                                extracted_verbs = _extract_all_subjunctive_verbs(opt_texts)
                                base_opts = [idx + 1 for idx, v in enumerate(extracted_verbs) if _is_base_subjunctive_verb(v)]
                                is_neg_polarity_q = any(term in prompt_norm for term in ["incorrect", "does not", "fails to", "wrong"])
                                if is_neg_polarity_q:
                                    norm_prop = normalize_solver_answer(proposed_ans, q_type)
                                    prop_idx = ord(norm_prop) - ord("A") + 1 if norm_prop in ["A", "B", "C", "D"] else -1
                                    if prop_idx > 0 and prop_idx in base_opts:
                                        task_issues.append(f"Proposed answer {norm_prop} uses valid base subjunctive form in negative-polarity question")
                                        task_validity["unique_correct_answer"] = False
                                    else:
                                        task_validity["unique_correct_answer"] = True
                                else:
                                    if len(base_opts) == 1:
                                        valid_idx = base_opts[0] - 1
                                        norm_prop = normalize_solver_answer(proposed_ans, q_type)
                                        prop_idx = ord(norm_prop) - ord("A") if norm_prop in ["A", "B", "C", "D"] else -1
                                        if prop_idx >= 0 and prop_idx != valid_idx:
                                            task_issues.append(
                                                f"Proposed answer key discord: proposed answer points to option {norm_prop} (index {prop_idx+1}), but unique grammatically valid subjunctive option is {chr(ord('A') + valid_idx)} (index {valid_idx+1})"
                                            )
                                            task_validity["unique_correct_answer"] = False
                                        else:
                                            task_validity["unique_correct_answer"] = True
                                    elif len(base_opts) > 1:
                                        task_issues.append(f"Ambiguous subjunctive MCQ: multiple options {base_opts} use base subjunctive form")
                                        task_validity["unique_correct_answer"] = False
                                    elif len(base_opts) == 0:
                                        task_issues.append("Defective subjunctive MCQ: no options use base subjunctive form")
                                        task_validity["unique_correct_answer"] = False
                                    else:
                                        task_validity["unique_correct_answer"] = True
                            else:
                                task_validity["unique_correct_answer"] = True
                    elif "conditional" in topic and self.is_v2_6_plus:
                        if self.is_v2_7_plus:
                            prompt_norm = normalize_text_nfkc(prompt).lower()
                            is_inverted_req = bool(re.search(r"\binvert(?:ed|ion)?\b", prompt_norm))
                            valid_cond_opts = []
                            inconclusive_cond_opts = []
                            for idx, ot in enumerate(opt_texts):
                                clean = re.sub(r"^[A-Da-d][\).:]\s*", "", ot.strip())
                                clean_l = clean.lower()
                                words = clean_l.split()
                                if not words:
                                    inconclusive_cond_opts.append(idx + 1)
                                    continue
                                first = words[0]
                                if first in ("had", "were", "should"):
                                    protasis_part = clean_l.split(",")[0] if "," in clean_l else clean_l
                                    p_words = protasis_part.split()
                                    if first == "had":
                                        has_participle = any((w.endswith("ed") and w not in BASE_EED_VERBS) for w in p_words[2:]) or any(w in {"seen", "known", "been", "done", "gone", "found", "checked"} for w in p_words[2:])
                                        has_main = bool(re.search(r"\b(?:would|could|might)\s+have\s+[a-z]+", clean_l))
                                        if has_participle and has_main:
                                            valid_cond_opts.append(idx + 1)
                                    elif first == "were":
                                        m = re.search(r"\bwere\s+[a-z\s]+?\s+to\s+([a-z]+)", protasis_part)
                                        has_main = bool(re.search(r"\b(?:would|could|might)\s+[a-z]+", clean_l))
                                        if m and has_main:
                                            v = m.group(1)
                                            if not (v.endswith("s") and not v.endswith("ss")) and not (v.endswith("ed") and v not in BASE_EED_VERBS) and not (v.endswith("ing") and v != "bring"):
                                                valid_cond_opts.append(idx + 1)
                                    elif first == "should":
                                        has_past = any(w in {"arose", "did", "was", "were", "had"} or (w.endswith("ed") and w not in BASE_EED_VERBS) for w in p_words[1:])
                                        has_base = any(w in {"arise", "occur", "happen", "fail", "detect", "observe", "need", "find"} for w in p_words[1:])
                                        has_main = bool(re.search(r",\s*(?:notify|inform|contact|call|please|report|\w+\s+(?:will|would|can|should))", clean_l))
                                        if not has_past and (has_base or not any(w.endswith(("s", "ing")) for w in p_words[2:])) and has_main:
                                            valid_cond_opts.append(idx + 1)
                                elif first == "if":
                                    if is_inverted_req:
                                        # Distractor: non-inverted conditional where stem specifies inversion
                                        pass
                                    else:
                                        has_third = bool(re.search(r"^if\s+[a-z\s]+?\s+had\s+[a-z]+.*?\b(?:would|could|might)\s+have\s+[a-z]+", clean_l))
                                        has_second = bool(re.search(r"^if\s+[a-z\s]+?\s+(?:were|did|[a-z]+ed).*?\b(?:would|could|might)\s+[a-z]+", clean_l))
                                        if has_third or has_second:
                                            valid_cond_opts.append(idx + 1)

                            if inconclusive_cond_opts:
                                task_issues.append(f"Inconclusive conditional MCQ: option(s) {inconclusive_cond_opts} could not be conclusively validated")
                                task_validity["unique_correct_answer"] = False
                            elif len(valid_cond_opts) == 1:
                                valid_idx = valid_cond_opts[0] - 1
                                norm_prop = normalize_solver_answer(proposed_ans, q_type)
                                prop_idx = ord(norm_prop) - ord("A") if norm_prop in ["A", "B", "C", "D"] else -1
                                if prop_idx >= 0 and prop_idx != valid_idx:
                                    task_issues.append(
                                        f"Proposed answer key discord: proposed answer points to option {norm_prop} (index {prop_idx+1}), but unique grammatically valid conditional option is {chr(ord('A') + valid_idx)} (index {valid_idx+1})"
                                    )
                                    task_validity["unique_correct_answer"] = False
                                else:
                                    task_validity["unique_correct_answer"] = True
                            elif len(valid_cond_opts) > 1:
                                task_issues.append(f"Ambiguous conditional MCQ: multiple options {valid_cond_opts} are defensible conditional sentences")
                                task_validity["unique_correct_answer"] = False
                            elif len(valid_cond_opts) == 0:
                                task_issues.append("Defective conditional MCQ: no options exhibit valid conditional structure")
                                task_validity["unique_correct_answer"] = False
                            else:
                                task_validity["unique_correct_answer"] = True
                        else:
                            valid_cond_opts = []
                            for idx, ot in enumerate(opt_texts):
                                ot_l = ot.lower()
                                if re.search(r"^(?:[A-Da-d][\).:]\s*)?(?:had\s+\w+|were\s+\w+|should\s+\w+)", ot_l):
                                    if any(m in ot_l for m in ["would have", "could have", "might have", "would be", "could be"]):
                                        valid_cond_opts.append(idx + 1)
                                elif re.search(r"^(?:[A-Da-d][\).:]\s*)?if\s+", ot_l):
                                    valid_cond_opts.append(idx + 1)
                            if len(valid_cond_opts) == 1:
                                task_validity["unique_correct_answer"] = True
                            elif len(valid_cond_opts) > 1:
                                task_issues.append(f"Ambiguous conditional MCQ: multiple options {valid_cond_opts} are defensible conditional sentences")
                                task_validity["unique_correct_answer"] = False
                            elif len(valid_cond_opts) == 0:
                                task_issues.append("Defective conditional MCQ: no options exhibit valid conditional structure")
                                task_validity["unique_correct_answer"] = False
                            else:
                                task_validity["unique_correct_answer"] = True
                    elif "modal" in topic and self.is_v2_6_plus:
                        valid_modal_opts = []
                        for idx, ot in enumerate(opt_texts):
                            ot_l = ot.lower()
                            m_mod = re.search(r"\b(must|could|cannot|might|should)\s+(?:not\s+)?have\s+([a-z]+)\b", ot_l)
                            if m_mod:
                                part = m_mod.group(2)
                                if part.endswith("ed") or part in IRREGULAR_PAST_PARTICIPLES:
                                    valid_modal_opts.append(idx + 1)
                        if len(valid_modal_opts) == 1:
                            task_validity["unique_correct_answer"] = True
                        elif len(valid_modal_opts) > 1:
                            task_issues.append(f"Ambiguous modal MCQ: multiple options {valid_modal_opts} exhibit valid modal deduction")
                            task_validity["unique_correct_answer"] = False
                        elif len(valid_modal_opts) == 0:
                            task_issues.append("Defective modal MCQ: no options exhibit valid past modal deduction")
                            task_validity["unique_correct_answer"] = False
                        else:
                            task_validity["unique_correct_answer"] = True
                    elif ("passive" in topic or "reporting" in topic) and self.is_v2_6_plus:
                        valid_pass_opts = []
                        for idx, ot in enumerate(opt_texts):
                            ot_l = ot.lower()
                            if re.search(r"\b(is|are|was|were)\s+(believed|considered|thought|reported|said|estimated)\s+to\b", ot_l):
                                valid_pass_opts.append(idx + 1)
                        if len(valid_pass_opts) == 1:
                            task_validity["unique_correct_answer"] = True
                        elif len(valid_pass_opts) > 1:
                            task_issues.append(f"Ambiguous passive MCQ: multiple options {valid_pass_opts} exhibit valid reporting passive")
                            task_validity["unique_correct_answer"] = False
                        elif len(valid_pass_opts) == 0:
                            task_issues.append("Defective passive MCQ: no options exhibit valid reporting passive")
                            task_validity["unique_correct_answer"] = False
                        else:
                            task_validity["unique_correct_answer"] = True
                    else:
                        task_validity["unique_correct_answer"] = True
        else:
            # For reading tasks without explicit evidence_quote, verify source grounding via passage spans
            clean_words = [w for w in re.sub(r"[^\w\s]", "", prompt).split() if len(w) > 2]
            matched_span = None
            for n in range(min(5, len(clean_words)), 1, -1):
                for i in range(len(clean_words) - n + 1):
                    phrase = " ".join(clean_words[i:i+n])
                    if phrase.lower() in passage_norm.lower():
                        matched_span = phrase
                        break
                if matched_span:
                    break
            if not matched_span and options:
                for opt in options:
                    opt_text = opt.get("text") if isinstance(opt, dict) else str(opt)
                    opt_words = [w for w in re.sub(r"[^\w\s]", "", opt_text).split() if len(w) > 3]
                    for ow in opt_words:
                        if ow.lower() in passage_norm.lower():
                            matched_span = ow
                            break
                    if matched_span:
                        break
            substantive_matches = [w for w in clean_words if len(w) > 3 and w.lower() in passage_norm.lower()]
            if matched_span or len(substantive_matches) >= 2:
                evidence_in_passage = True
                task_validity["evidence_in_passage"] = True
                evidence_refs.append((matched_span or " ".join(substantive_matches[:3]))[:100])
            elif self.is_v2_5_plus and norm_proposed in ("NOT_GIVEN", "NOT GIVEN"):
                # In v2.5+, valid NOT GIVEN items by definition assert unentailed/absent propositions.
                # They require only a topical anchor in the passage (at least 1 word of len >= 3 present in passage).
                anchor_words = [w for w in clean_words if len(w) >= 3 and w.lower() in passage_norm.lower()]
                acronym_match = False
                upper_words = [w for w in clean_words if w.isupper() and 2 <= len(w) <= 5]
                for acr in upper_words:
                    acr_letters = list(acr.lower())
                    p_words = [w.lower() for w in re.findall(r"\b[a-zA-Z]+\b", passage_norm)]
                    for i in range(len(p_words) - len(acr_letters) + 1):
                        if [w[0] for w in p_words[i:i+len(acr_letters)]] == acr_letters:
                            acronym_match = True
                            break
                    if acronym_match:
                        break
                if anchor_words or acronym_match:
                    evidence_in_passage = True
                    task_validity["evidence_in_passage"] = True
                    evidence_refs.append(f"Topical anchor: {anchor_words[0] if anchor_words else 'acronym_expansion'}")
                else:
                    evidence_in_passage = False
                    task_validity["evidence_in_passage"] = False
                    task_issues.append("Question content not grounded in source passage text")
            else:
                evidence_in_passage = False
                task_validity["evidence_in_passage"] = False
                task_issues.append("Question content not grounded in source passage text")
        # Task validity: Check for obvious contradictions or ungrounded logic
        # norm_proposed and is_tfng initialized above
        if is_tfng and prompt:
            prompt_clean = normalize_text_nfkc(prompt).lower()
            passage_clean = passage_norm.lower()
            if is_v2_2 and not is_grammar:
                if detect_comparison_inversion(prompt, passage_text):
                    contradiction_detected = True
                    task_issues.append("Comparison inversion contradiction: passage asserts opposite comparison")
                has_neg_conflict, neg_msg = detect_negation_polarity_conflict(prompt, passage_text)
                if has_neg_conflict and norm_proposed in ("TRUE", "YES"):
                    contradiction_detected = True
                    task_issues.append(f"Entailment contradiction: {neg_msg}")
                if norm_proposed in ("TRUE", "YES"):
                    ratio, ungrounded_words = compute_substantive_grounding_ratio(prompt, passage_text, is_v2_2=is_v2_2)
                    if ratio < 0.50 and len(ungrounded_words) >= 2:
                        contradiction_detected = True
                        task_issues.append(f"Ungrounded claim: statement asserts unsupported facts {ungrounded_words} not in source text")
                    has_gen, gen_msg = detect_unsupported_generalization(prompt, passage_text)
                    if has_gen:
                        contradiction_detected = True
                        task_issues.append(gen_msg)
            if norm_proposed in ("TRUE", "YES"):
                if detect_contradiction_in_text(prompt, passage_text, enable_contrastive_exclusion=is_v2_3, enable_refined_contrastive_clause=self.is_v2_4_plus):
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
                # NOT GIVEN contradiction: in v2.3+, passage explicitly contradicts the proposition
                if is_v2_3 and detect_contradiction_in_text(prompt, passage_text, enable_contrastive_exclusion=True, enable_refined_contrastive_clause=self.is_v2_4_plus):
                    contradiction_detected = True
                    task_issues.append("NOT GIVEN contradiction: passage explicitly contradicts the proposition (should be FALSE)")
                elif detect_entailment_in_text(prompt, passage_text, enable_contrastive_exclusion=is_v2_3, enable_refined_contrastive_clause=self.is_v2_4_plus, enable_contrastive_entailment=self.is_v2_5_plus):
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
                # FALSE contradiction
                if is_v2_3:
                    if evidence_quote and detect_entailment_in_text(prompt, evidence_quote, enable_contrastive_exclusion=True, enable_refined_contrastive_clause=self.is_v2_4_plus, enable_contrastive_entailment=self.is_v2_5_plus) and not detect_contradiction_in_text(prompt, evidence_quote, enable_contrastive_exclusion=True, enable_refined_contrastive_clause=self.is_v2_4_plus):
                        contradiction_detected = True
                        task_issues.append("FALSE contradiction: cited evidence affirms statement (should be TRUE)")
                    elif detect_entailment_in_text(prompt, passage_text, enable_contrastive_exclusion=True, enable_refined_contrastive_clause=self.is_v2_4_plus, enable_contrastive_entailment=self.is_v2_5_plus) and not detect_contradiction_in_text(prompt, passage_text, enable_contrastive_exclusion=True, enable_refined_contrastive_clause=self.is_v2_4_plus):
                        contradiction_detected = True
                        task_issues.append("FALSE contradiction: passage affirms proposition without contradiction")
                else:
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
        if (is_v2_3 and not proposed_ans) or contradiction_detected or is_ungrounded:
            grounding = 1.0  # Entirely ungrounded, contradicted, or missing answer key
            answerability = 1.0
        elif not evidence_in_passage or (is_v2_2 and task_validity.get("unique_correct_answer") is False):
            grounding = 2.0  # Major issue: cited evidence missing from text or distractor failure
            answerability = min(answerability, 2.0)

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

        inconclusive_issues = [
            iss for iss in task_issues
            if "Inconclusive" in iss or "could not be conclusively validated" in iss or "could not be conclusively parsed" in iss or "UNCERTAIN" in iss
        ]
        if self.is_v2_7_plus and inconclusive_issues:
            verdict = EvaluationVerdict.UNCERTAIN
            abstention_reason = f"INCONCLUSIVE_LINGUISTIC_JUDGMENT: {'; '.join(inconclusive_issues)}"
        elif not all_hard_pass or not all_task_pass or not is_rubric_pass:
            verdict = EvaluationVerdict.FAIL
            if is_v2_3 and not proposed_ans:
                abstention_reason = "UNSCORABLE_MISSING_ANSWER: Question provides no proposed answer key"
            else:
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


class NeutralEvaluatorV2(NeutralEvaluator):
    """Remediated neutral evaluator with verified evidence contracts (RG10 remediation)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.1",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.1"),
            evaluator_version=evaluator_version,
        )


class NeutralEvaluatorV2_2(NeutralEvaluatorV2):
    """Calibrated neutral evaluator with robust semantic grounding and distractor verification (v2.2)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.2",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.2"),
            evaluator_version=evaluator_version,
        )


class NeutralEvaluatorV2_3(NeutralEvaluatorV2_2):
    """Calibrated neutral evaluator with robust contradiction discrimination and distractor verification (v2.3)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.3",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.3"),
            evaluator_version=evaluator_version,
        )


class NeutralEvaluatorV2_4(NeutralEvaluatorV2_3):
    """Calibrated neutral evaluator with refined contrastive clause boundary parsing (v2.4)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.4",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.4"),
            evaluator_version=evaluator_version,
        )


class NeutralEvaluatorV2_5(NeutralEvaluatorV2_4):
    """Calibrated neutral evaluator with refined clause entailment, distractor relevancy, and topical anchoring (v2.5)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.5",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.5"),
            evaluator_version=evaluator_version,
        )


class NeutralEvaluatorV2_6(NeutralEvaluatorV2_5):
    """Calibrated neutral evaluator with robust negative inversion validation, content-aware novelty, and multi-family distractor verification (v2.6)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.6",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.6"),
            evaluator_version=evaluator_version,
        )


class NeutralEvaluatorV2_7(NeutralEvaluatorV2_6):
    """Calibrated neutral evaluator with remediated verb-inflection filter (-ss base verbs),
    inverted conditional distractor discrimination, robust mandative subjunctive parsing,
    and explicit UNCERTAIN classification for inconclusive grammar structures (v2.7)."""

    def __init__(
        self,
        rubric: Optional[RubricProfile] = None,
        evaluator_version: str = "neutral-eval-v2.7",
    ):
        super().__init__(
            rubric=rubric or RubricProfile(rubric_version="rubric-qgeval-v2.7"),
            evaluator_version=evaluator_version,
        )
