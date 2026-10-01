"""Deterministic Evaluators for Langfens Loop Engine V2.

Implements P07-03: Word counts, numbering, groups/types, options cardinality,
exact answer span/length, evidence offsets, blank count, graph refs, exact/shingle duplicates.
Strict word boundary normalization prevents substring leakage (e.g. 'he' in 'the').
"""

from __future__ import annotations

import re
import unicodedata
from typing import Any, Dict, List, Optional, Set
from uuid import uuid4
from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.policies import (
    MAX_ANSWER_WORDS,
    MAX_SHINGLE_OVERLAP,
    PAPER_MAX_WORDS,
    PAPER_MIN_WORDS,
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    calculate_shingle_overlap,
    count_words,
    match_verbatim_in_passage,
    normalize_prompt,
    validate_answer_length,
)
from app.evaluators.base import BaseEvaluator, EvaluationStage, EvaluatorMetadata
from app.loop.context import LoopContext


# ── Strict Token Boundary Matching ──────────────────────────────────────────

def normalize_text_nfkc(text: str) -> str:
    """Normalizes text using Unicode NFKC, strip whitespace, and normalize spaces."""
    if not text:
        return ""
    normalized = unicodedata.normalize("NFKC", text)
    return " ".join(normalized.split())


def matches_exact_token_bound(needle: str, haystack: str) -> bool:
    """Checks if `needle` appears as a complete token sequence in `haystack`.
    
    Prevents false positive substring leakage (e.g. 'he' inside 'the', 'rat' in 'strata').
    """
    if not needle or not haystack:
        return False
    needle_clean = normalize_text_nfkc(needle)
    pattern = r"(?<![\w'-])" + re.escape(needle_clean) + r"(?![\w'-])"
    return bool(re.search(pattern, haystack, re.IGNORECASE))


def check_prompt_answer_leakage(prompt: str, answer: str) -> bool:
    """Checks whether the answer text leaks verbatim inside the question prompt.
    
    Uses whole-word token boundaries so that words like 'the' in prompt do not trigger
    leakage for an answer like 'he'.
    """
    if not prompt or not answer:
        return False
    clean_ans = answer.strip()
    if len(clean_ans) < 2:
        return False
    return matches_exact_token_bound(clean_ans, prompt)


# ── Evaluator Implementations ───────────────────────────────────────────────

class PassageWordCountEvaluator(BaseEvaluator):
    """Evaluates passage text word count boundaries (720 to 915 words)."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_passage_word_count",
                evaluator_version="1.0.0",
                name="Passage Word Count Evaluator",
                description="Enforces passage length within IELTS Academic limits (720-915 words)",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION],
                required=required,
                hard_checks=[IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        passage_text = payload.get("passage", "") or payload.get("passageText", "")
        word_count = count_words(passage_text)

        issues: List[Issue] = []
        if word_count < PASSAGE_MIN_WORDS or word_count > PASSAGE_MAX_WORDS:
            issue = Issue.create(
                issue_id=f"iss_wc_{uuid4().hex[:8]}",
                code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.PASSAGE,
                message=(
                    f"Passage word count {word_count} is outside permitted bounds "
                    f"[{PASSAGE_MIN_WORDS}, {PASSAGE_MAX_WORDS}]"
                ),
                affected_refs=[artifact.to_ref()],
                evaluator_id=self.evaluator_id,
            )
            issues.append(issue)

        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )


class QuestionStructureEvaluator(BaseEvaluator):
    """Evaluates question numbering, counts, option cardinality, and blank consistency."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_question_structure",
                evaluator_version="1.0.0",
                name="Question Structure & Numbering Evaluator",
                description="Validates question counts, contiguous numbering, MCQ cardinality, and blanks",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                required=required,
                hard_checks=[
                    IssueCode.QUESTION_NUMBERING_INVALID,
                    IssueCode.QUESTION_COUNT_MISMATCH,
                    IssueCode.INSUFFICIENT_OPTIONS,
                    IssueCode.SCHEMA_VIOLATION,
                ],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        if artifact.artifact_type == ArtifactType.QUESTION:
            # Single question evaluation
            q_num = payload.get("questionNumber") or payload.get("question_number")
            q_type = payload.get("questionType") or payload.get("question_type") or payload.get("type")
            options = payload.get("options")

            if q_num is not None and int(q_num) < 1:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_num_{uuid4().hex[:8]}",
                        code=IssueCode.QUESTION_NUMBERING_INVALID,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Invalid question number {q_num}; must be >= 1",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            if q_type == "MultipleChoiceSingle":
                if not isinstance(options, (list, tuple)) or len(options) != 4:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_opt_{uuid4().hex[:8]}",
                            code=IssueCode.INSUFFICIENT_OPTIONS,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"MultipleChoiceSingle must have exactly 4 options; found {len(options) if isinstance(options, (list, tuple)) else 0}",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
                ans_key = payload.get("answer")
                if ans_key and options and isinstance(options, (list, tuple)):
                    keys = {opt.get("key") for opt in options if hasattr(opt, "get")}
                    if ans_key not in keys:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_opt_key_{uuid4().hex[:8]}",
                                code=IssueCode.SCHEMA_VIOLATION,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"MultipleChoiceSingle answer key '{ans_key}' not among options {keys}",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
            elif q_type in ("TrueFalseNotGiven", "YesNoNotGiven"):
                if options is not None and (not isinstance(options, (list, tuple)) or len(options) != 3):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_opt_{uuid4().hex[:8]}",
                            code=IssueCode.INSUFFICIENT_OPTIONS,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"{q_type} must have exactly 3 options; found {len(options) if isinstance(options, (list, tuple)) else 0}",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
        elif artifact.artifact_type == ArtifactType.SECTION:
            sec_idx = payload.get("sectionIndex") or payload.get("index") or 1
            groups = payload.get("groups", [])
            expected_total = SECTION_QUESTION_COUNTS.get(sec_idx, 13)

            all_questions = []
            for g_idx, grp in enumerate(groups):
                g_type = grp.get("questionType") or grp.get("type")
                g_qs = grp.get("questions", [])
                all_questions.extend(g_qs)

                # Check MCQ options
                if g_type == "MultipleChoiceSingle":
                    for q in g_qs:
                        opts = q.get("options", [])
                        if len(opts) != 4:
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_opt_{uuid4().hex[:8]}",
                                    code=IssueCode.INSUFFICIENT_OPTIONS,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION,
                                    message=f"MCQ Question {q.get('questionNumber')} has {len(opts)} options, expected 4",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )

                # Check summary completion blanks in shared context
                if g_type == "SummaryCompletion":
                    shared_ctx = grp.get("sharedContext", "") or ""
                    # Count blank placeholders like [BLANK], [BLANK_X], or ___
                    blank_matches = re.findall(r"\[BLANK(?:_\d+)?\]|_{3,}", shared_ctx)
                    if len(blank_matches) != len(g_qs):
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_blank_{uuid4().hex[:8]}",
                                code=IssueCode.SCHEMA_VIOLATION,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION_GROUP,
                                message=(
                                    f"Summary group {g_idx+1} has {len(blank_matches)} blank placeholders "
                                    f"in sharedContext, but contains {len(g_qs)} questions"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

            # Check total count
            if len(all_questions) != expected_total:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_cnt_{uuid4().hex[:8]}",
                        code=IssueCode.QUESTION_COUNT_MISMATCH,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_idx} has {len(all_questions)} questions, expected {expected_total}",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # Check numbering sequence
            start_num = 1 if sec_idx == 1 else (14 if sec_idx == 2 else 27)
            expected_seq = list(range(start_num, start_num + len(all_questions)))
            actual_seq = [q.get("questionNumber") for q in all_questions if q.get("questionNumber") is not None]
            if actual_seq != expected_seq:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_seq_{uuid4().hex[:8]}",
                        code=IssueCode.QUESTION_NUMBERING_INVALID,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_idx} question numbering {actual_seq} is not contiguous {expected_seq}",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )


class AnswerVerbatimAndLengthEvaluator(BaseEvaluator):
    """Evaluates answer length (max 3 words / 1 number), verbatim passage occurrence,
    and prompt answer leakage without substring false-positives.
    """

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_answer_verbatim_length",
                evaluator_version="1.0.0",
                name="Answer Verbatim & Length Evaluator",
                description="Checks answer word count, verbatim presence in passage, and prompt leakage",
                stage=EvaluationStage.LEXICAL,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                required=required,
                hard_checks=[
                    IssueCode.WORD_LIMIT_EXCEEDED,
                    IssueCode.EVIDENCE_MISSING,
                    IssueCode.ANSWER_LEAKAGE,
                ],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        def check_question(q: Dict[str, Any], pass_text: str):
            ans = q.get("answer", "")
            prompt = q.get("prompt", "") or q.get("questionText", "")
            q_type = q.get("questionType") or q.get("type", "")
            q_num = q.get("questionNumber", "?")

            # Check prompt leakage (answer text explicitly written inside question prompt)
            if q_type not in ("TrueFalseNotGiven", "YesNoNotGiven") and check_prompt_answer_leakage(prompt, ans):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_leak_{uuid4().hex[:8]}",
                        code=IssueCode.ANSWER_LEAKAGE,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} answer '{ans}' leaks inside prompt '{prompt[:60]}...'",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # Completion and ShortAnswer require max 3 words and verbatim passage presence
            if q_type in ("SentenceCompletion", "SummaryCompletion", "ShortAnswer"):
                if not validate_answer_length(ans):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_len_{uuid4().hex[:8]}",
                            code=IssueCode.WORD_LIMIT_EXCEEDED,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} answer '{ans}' exceeds maximum 3 words limit",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

                if pass_text and not match_verbatim_in_passage(ans, pass_text):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_verb_{uuid4().hex[:8]}",
                            code=IssueCode.EVIDENCE_MISSING,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=(
                                f"Question {q_num} completion answer '{ans}' does not appear "
                                f"as a full-token verbatim span in passage"
                            ),
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
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )


class EvidenceOffsetEvaluator(BaseEvaluator):
    """Evaluates evidence offsets and quote alignment with the source / passage text."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_evidence_offsets",
                evaluator_version="1.0.0",
                name="Evidence Offset & Span Evaluator",
                description="Validates that evidence quotes and offsets match Unicode codepoints in passage text",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION],
                required=required,
                hard_checks=[IssueCode.EVIDENCE_MISSING, IssueCode.SCHEMA_VIOLATION],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        passage_text = payload.get("passage", "") or payload.get("passageText", "")
        issues: List[Issue] = []

        def check_evidence(q: Dict[str, Any], pass_text: str):
            q_num = q.get("questionNumber", "?")
            quote = q.get("evidenceQuote") or q.get("evidence_quote") or ""
            start = q.get("evidenceStart") or q.get("evidence_start")
            end = q.get("evidenceEnd") or q.get("evidence_end")

            # Non-empty quote check (except for verified NOT_GIVEN questions where quote is optional anchor)
            ans = q.get("answer", "")
            if ans != "NOT_GIVEN" and len(quote.strip()) < 10:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_evq_{uuid4().hex[:8]}",
                        code=IssueCode.EVIDENCE_MISSING,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} evidence quote '{quote}' is missing or too short (< 10 chars)",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )


            # Verify that quote actually occurs in passage text
            if pass_text and quote and len(quote.strip()) >= 10:
                if quote.strip() not in pass_text:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_ev_missing_{uuid4().hex[:8]}",
                            code=IssueCode.EVIDENCE_MISSING,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} evidence quote '{quote[:40]}' does not occur in passage text",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
            # Offset verification if offsets are supplied
            if start is not None and end is not None and pass_text:
                if start < 0 or end > len(pass_text) or start >= end:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_ev_bound_{uuid4().hex[:8]}",
                            code=IssueCode.SCHEMA_VIOLATION,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} evidence offsets [{start}:{end}] are out of bounds (len={len(pass_text)})",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
                else:
                    span_in_passage = pass_text[start:end]
                    if quote and quote.strip() != span_in_passage.strip():
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_ev_mismatch_{uuid4().hex[:8]}",
                                code=IssueCode.EVIDENCE_MISSING,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Question {q_num} evidence quote '{quote[:40]}' does not match "
                                    f"passage span at [{start}:{end}] ('{span_in_passage[:40]}')"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

        if artifact.artifact_type == ArtifactType.QUESTION:
            check_evidence(payload, passage_text)
        elif artifact.artifact_type == ArtifactType.SECTION:
            for grp in payload.get("groups", []):
                grp_type = grp.get("questionType") or grp.get("type", "")
                for q in grp.get("questions", []):
                    q_with_type = dict(q)
                    if not q_with_type.get("questionType") and not q_with_type.get("type"):
                        q_with_type["questionType"] = grp_type
                    check_evidence(q_with_type, passage_text)
        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )


class DuplicateAndShingleEvaluator(BaseEvaluator):
    """Evaluates question prompts for exact duplicates and 5-word shingle overlaps."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_duplicate_shingle",
                evaluator_version="1.0.0",
                name="Duplicate & Shingle Overlap Evaluator",
                description="Detects identical prompts and high Jaccard 5-word shingle overlaps (> 0.45)",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[IssueCode.DUPLICATE_CONTENT],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        all_questions: List[Dict[str, Any]] = []
        if artifact.artifact_type == ArtifactType.SECTION:
            for grp in payload.get("groups", []):
                all_questions.extend(grp.get("questions", []))
        elif artifact.artifact_type == ArtifactType.READING_PAPER:
            for sec in payload.get("sections", []):
                for grp in sec.get("groups", []):
                    all_questions.extend(grp.get("questions", []))

        # Check for duplicates across questions
        seen_prompts: Dict[str, int] = {}
        for q in all_questions:
            prompt = q.get("prompt", "") or q.get("questionText", "")
            q_num = q.get("questionNumber", 0)
            norm = normalize_prompt(prompt)
            if not norm:
                continue

            if norm in seen_prompts:
                prior_num = seen_prompts[norm]
                issues.append(
                    Issue.create(
                        issue_id=f"iss_dup_{uuid4().hex[:8]}",
                        code=IssueCode.DUPLICATE_CONTENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} has identical normalized prompt to Question {prior_num}",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
            else:
                seen_prompts[norm] = q_num

        # Check pair-wise shingle overlap
        for i in range(len(all_questions)):
            for j in range(i + 1, len(all_questions)):
                q1 = all_questions[i]
                q2 = all_questions[j]
                p1 = q1.get("prompt", "") or q1.get("questionText", "")
                p2 = q2.get("prompt", "") or q2.get("questionText", "")
                if count_words(p1) >= 5 and count_words(p2) >= 5:
                    overlap = calculate_shingle_overlap(p1, p2)
                    if overlap > MAX_SHINGLE_OVERLAP:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_shingle_{uuid4().hex[:8]}",
                                code=IssueCode.DUPLICATE_CONTENT,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Questions {q1.get('questionNumber')} and {q2.get('questionNumber')} "
                                    f"have excessive 5-word shingle overlap ({overlap:.2f} > {MAX_SHINGLE_OVERLAP})"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )


class PaperStructureEvaluator(BaseEvaluator):
    """Evaluates ReadingPaper invariants: 3 sections, 40 total questions (1-40),
    and total word count within [2150, 2750].
    """

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_paper_structure",
                evaluator_version="1.0.0",
                name="Reading Paper Structure Evaluator",
                description="Validates 3 sections, 40 questions (1-40 contiguous), and 2150-2750 words",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[
                    IssueCode.QUESTION_COUNT_MISMATCH,
                    IssueCode.QUESTION_NUMBERING_INVALID,
                    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                ],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        sections = payload.get("sections", [])
        if len(sections) != 3:
            issues.append(
                Issue.create(
                    issue_id=f"iss_p_sec_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_COUNT_MISMATCH,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Reading paper has {len(sections)} sections, expected 3",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        all_q_nums: List[int] = []
        total_words = 0
        for sec in sections:
            pass_text = sec.get("passage", "") or sec.get("passageText", "")
            total_words += count_words(pass_text)
            for grp in sec.get("groups", []):
                for q in grp.get("questions", []):
                    num = q.get("questionNumber")
                    if num is not None:
                        all_q_nums.append(int(num))

        if len(all_q_nums) != 40:
            issues.append(
                Issue.create(
                    issue_id=f"iss_p_qcnt_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_COUNT_MISMATCH,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Reading paper has {len(all_q_nums)} questions, expected 40",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        if all_q_nums != list(range(1, 41)):
            issues.append(
                Issue.create(
                    issue_id=f"iss_p_num_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_NUMBERING_INVALID,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message="Paper question numbers do not form a contiguous 1-40 sequence",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        if total_words < PAPER_MIN_WORDS or total_words > PAPER_MAX_WORDS:
            issues.append(
                Issue.create(
                    issue_id=f"iss_p_wc_{uuid4().hex[:8]}",
                    code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Paper total word count {total_words} is outside [{PAPER_MIN_WORDS}, {PAPER_MAX_WORDS}]",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )
