"""Canonical Reading Paper Evaluators for Langfens Loop Engine V2 (Phase 12 / P12-02, P12-03).

Evaluators:
1. PaperStructureEvaluator (P12-01, P12-02):
   - Exactly 3 sections.
   - Exactly 40 total questions continuously numbered 1–40 (S1: 1-13, S2: 14-26, S3: 27-40).
   - Section question counts: S1 (13: 7 TFNG + 6 Sentence Completion),
     S2 (13: 6 MCQ Single + 7 Summary Completion), S3 (14: 7 YNNG + 7 Short Answer).
   - Passage length bounds: each section passage in [720, 915] words.
   - Paper total word count: in [2150, 2750] words.
   - Fresh required evaluations and dependency closure check.

2. PaperCrossSectionEvaluator (P12-02, P12-03):
   - Cross-section duplicate question prompts across all 40 questions.
   - 5-word shingle overlap across the 3 passages (> 0.45 threshold).
   - Distinguishes shared domain vocabulary from duplicate passage content.

3. PaperLeakageEvaluator (P12-03):
   - Cross-section prompt and instruction answer leakage.
   - Checks if any instruction or question prompt in Section i reveals answers
     or verbatim evidence quotes for questions in Section j (i != j) or within same section.
   - Type-aware boundaries to avoid false positives on standard grammatical words.

4. PaperMonotonyEvaluator (P12-03):
   - Evaluates answer distribution monotony across the entire paper (e.g. all TRUE or all option A).
"""

from __future__ import annotations

from datetime import datetime, timezone
from collections.abc import Mapping
import re
from typing import Any, Dict, List, Optional, Set
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.blueprint import QuestionType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.policies import (
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
    normalize_prompt,
)
from app.evaluators.base import BaseEvaluator, EvaluationStage, EvaluatorMetadata
from app.evaluators.deterministic import check_prompt_answer_leakage, normalize_text_nfkc
from app.loop.context import LoopContext


# ── P12-03 Type-aware leakage helpers ────────────────────────────────
#
# Spec (P12-03):
#   1. Intra-question self-leakage:
#      check_prompt_answer_leakage(t_prompt, t_ans) → ANSWER_LEAKAGE.
#   2. Cross-section (o_sec != t_sec): any multi-word answer leaked in any
#      other prompt → ANSWER_LEAKAGE.
#   3. Intra-section (o_sec == t_sec):
#      a. Verbatim evidence quote (t_quote in o_prompt) → QUOTE_LEAKAGE.
#      b. Type-aware exact answer leakage: only when type ∈ {COMPLETION,
#         SHORT_ANSWER}, multi-word answer, and predicate(o_prompt) ==
#         predicate(t_prompt), and all answer tokens appear in o_prompt with
#         whole-token boundaries → ANSWER_LEAKAGE.
#   4. Negative control: shared passage subject terminology (topic noun
#      phrases) in non-revealing prompts is permitted.

# Standard choice labels used in fixed-response question types (TFNG, YNNG,
# MCQ single-letter). These are format specifications, not leaked answers, so
# the leakage evaluator must ignore them when scanning prompts / instructions.
STANDARD_CHOICE_LABELS: frozenset[str] = frozenset({
    "TRUE",
    "FALSE",
    "NOT GIVEN",
    "NOT_GIVEN",
    "YES",
    "NO",
    "A",
    "B",
    "C",
    "D",
})

_WHITESPACE_RE = re.compile(r"\s+")
_NON_WORD_RE = re.compile(r"^[^\w]+|[^\w]+$")
_QUOTE_NORMALIZE_RE = re.compile(r"[\s ]+")


def _normalize_for_substring(text: str) -> str:
    """Normalize whitespace and casefold for substring/quote comparison."""
    if not text:
        return ""
    return _QUOTE_NORMALIZE_RE.sub(" ", text).strip().casefold()


# Interrogative / wh-words skipped along with stopwords so questions
# starting with "What", "Which", "How", etc. do not all collide on identical
# predicates.
_INTERROGATIVES: frozenset[str] = frozenset({
    "what", "which", "who", "whom", "whose", "where", "when", "why", "how",
})

# Common leading-function words that carry no question focus of their own.
# Two prompts starting with different content nouns must NOT collide on these.
_STOPWORDS: frozenset[str] = frozenset({
    "the", "a", "an", "in", "on", "at", "to", "for", "with", "by", "from",
    "as", "is", "are", "was", "were", "it", "this", "that", "these", "those",
})


def _extract_question_predicate(prompt: str) -> str:
    """Return a stable question-focus token (lowercased) for the prompt.

    Rules:
      1. Split prompt into whitespace tokens, lowercased, with surrounding
         punctuation stripped.
      2. Skip leading stopwords and interrogatives (``what``, ``which``,
         ``the``, ``a``, ``is``, etc.) and return the first remaining content
         token whose length is ``>= 3``.
      3. Return empty string when the prompt is empty, has no word tokens,
         or only contains stopwords / sub-3-letter tokens.
    """
    if not prompt:
        return ""

    combined_skip = _STOPWORDS | _INTERROGATIVES
    for raw in prompt.split():
        token = _NON_WORD_RE.sub("", raw).casefold()
        if not token or token in combined_skip or len(token) < 3:
            continue
        return token

    return ""


def _answer_tokens_present_in_prompt(answer: str, prompt: str) -> bool:
    """Return True iff every whitespace-token of `answer` appears in `prompt`
    with whole-token boundaries (case-insensitive).

    Empty answer, single-token answer, or any unmatched token → False.
    """
    if not answer or not prompt:
        return False
    tokens = [tok for tok in _WHITESPACE_RE.split(answer.strip()) if tok]
    if len(tokens) < 2:
        return False
    for tok in tokens:
        pattern = r"(?<![\w'-])" + re.escape(tok) + r"(?![\w'-])"
        if not re.search(pattern, prompt, re.IGNORECASE):
            return False
    return True


def _quote_appears_in_prompt(quote: str, prompt: str) -> bool:
    """Return True iff `quote` appears verbatim (whitespace/case-insensitive)
    inside `prompt` at whole-token boundaries.

    Per spec: a verbatim evidence quote must satisfy
    ``len(quote.split()) >= 2 or len(quote) >= 8``; anything below both
    thresholds is treated as not-a-quote. Matching uses whole-token
    boundaries (lookarounds for ``[\\w'-]``) so fragments like ``"sign"``
    do not match inside ``"significant"``.
    """
    if not quote or not prompt:
        return False
    norm_quote = _normalize_for_substring(quote)
    # Spec threshold: at least 2 words OR at least 8 characters.
    if len(norm_quote.split()) < 2 and len(norm_quote) < 8:
        return False
    norm_prompt = _normalize_for_substring(prompt)
    pattern = r"(?<![\w'-])" + re.escape(norm_quote) + r"(?![\w'-])"
    return re.search(pattern, norm_prompt) is not None


def _extract_paper_sections(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    raw_sections = payload.get("sections", [])
    result = []
    for s in raw_sections:
        if isinstance(s, Mapping):
            result.append(dict(s))
        elif hasattr(s, "model_dump"):
            result.append(s.model_dump(mode="json", by_alias=True))
        else:
            result.append(dict(s))
    return result


# ── PaperStructureEvaluator ──────────────────────────────────────────────────


class PaperStructureEvaluator(BaseEvaluator):
    """Evaluates full Reading Paper structure, counts, contiguous 1-40 numbering, and word limits."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_paper_structure",
                evaluator_version="2.0.0",
                name="Reading Paper Structure and Numbering Evaluator",
                description="Enforces 3 sections, 40 questions (1-40 contiguous), word bounds [2150, 2750], and per-section [720, 915]",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[
                    IssueCode.QUESTION_COUNT_MISMATCH,
                    IssueCode.QUESTION_NUMBERING_INVALID,
                    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    IssueCode.SECTION_GROUP_COUNT_MISMATCH,
                    IssueCode.SECTION_GROUP_TYPE_MISMATCH,
                    IssueCode.SECTION_GROUP_SIZE_MISMATCH,
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
        metrics: Dict[str, Any] = {}

        sections = _extract_paper_sections(payload)
        
        # 1. Exactly 3 sections check
        if len(sections) != 3:
            issues.append(
                Issue.create(
                    issue_id=f"iss_paper_seccnt_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_COUNT_MISMATCH,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Reading paper has {len(sections)} sections, expected exactly 3",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        all_q_nums: List[int] = []
        total_words = 0
        section_word_counts: Dict[int, int] = {}
        section_q_counts: Dict[int, int] = {}

        for idx, sec in enumerate(sections):
            sec_num = idx + 1
            pass_text = sec.get("passage", "") or sec.get("passageText", "") or sec.get("text", "")
            w_count = count_words(pass_text)
            total_words += w_count
            section_word_counts[sec_num] = w_count

            # Section word count bounds [720, 915]
            if w_count < PASSAGE_MIN_WORDS or w_count > PASSAGE_MAX_WORDS:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_num}_wc_{uuid4().hex[:8]}",
                        code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_num} passage word count {w_count} is outside policy bounds [{PASSAGE_MIN_WORDS}, {PASSAGE_MAX_WORDS}]",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # Groups and questions inside section
            groups = sec.get("groups", [])
            expected_types = SECTION_GROUP_TYPES.get(sec_num, [])
            expected_sizes = SECTION_GROUP_SIZES.get(sec_num, [])
            sec_q_count = 0

            is_legacy_preset = len(groups) == 2 and all(
                g_idx < len(expected_types) and (
                    str(grp.get("questionType") or grp.get("type") or "").replace("_", "").lower() in (
                        expected_types[g_idx].value.replace("_", "").lower(),
                        expected_types[g_idx].name.replace("_", "").lower()
                    )
                )
                for g_idx, grp in enumerate(groups)
            )

            if is_legacy_preset:
                for g_idx, grp in enumerate(groups):
                    questions = grp.get("questions", [])
                    sec_q_count += len(questions)
                    raw_type = grp.get("questionType") or grp.get("type") or ""
                    type_norm = str(raw_type).replace("_", "").lower()

                    if g_idx < len(expected_types):
                        exp_norm = expected_types[g_idx].value.replace("_", "").lower()
                        if type_norm != exp_norm:
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_sec_{sec_num}_g{g_idx+1}_type_{uuid4().hex[:8]}",
                                    code=IssueCode.SECTION_GROUP_TYPE_MISMATCH,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION_GROUP,
                                    message=f"Section {sec_num} Group {g_idx+1} type '{raw_type}' does not match expected '{expected_types[g_idx].value}'",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )

                    if g_idx < len(expected_sizes):
                        if len(questions) != expected_sizes[g_idx]:
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_sec_{sec_num}_g{g_idx+1}_sz_{uuid4().hex[:8]}",
                                    code=IssueCode.SECTION_GROUP_SIZE_MISMATCH,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION_GROUP,
                                    message=f"Section {sec_num} Group {g_idx+1} has {len(questions)} questions, expected {expected_sizes[g_idx]}",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )

                    for q in questions:
                        num = q.get("questionNumber") or q.get("number")
                        if num is not None:
                            all_q_nums.append(int(num))
            else:
                if not (2 <= len(groups) <= 4):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sec_{sec_num}_grpcnt_{uuid4().hex[:8]}",
                            code=IssueCode.SECTION_GROUP_COUNT_MISMATCH,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.SECTION,
                            message=f"Section {sec_num} has {len(groups)} question groups, expected 2-4",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
                for g_idx, grp in enumerate(groups):
                    questions = grp.get("questions", [])
                    sec_q_count += len(questions)
                    if not questions:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_sec_{sec_num}_g{g_idx+1}_sz_{uuid4().hex[:8]}",
                                code=IssueCode.SECTION_GROUP_SIZE_MISMATCH,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION_GROUP,
                                message=f"Section {sec_num} Group {g_idx+1} has 0 questions",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                    for q in questions:
                        num = q.get("questionNumber") or q.get("number")
                        if num is not None:
                            all_q_nums.append(int(num))

            section_q_counts[sec_num] = sec_q_count
            expected_sec_q_count = SECTION_QUESTION_COUNTS.get(sec_num, 13)
            if sec_q_count != expected_sec_q_count:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_num}_qcnt_{uuid4().hex[:8]}",
                        code=IssueCode.QUESTION_COUNT_MISMATCH,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_num} has {sec_q_count} questions, expected {expected_sec_q_count}",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

        # 2. Total questions check
        if len(all_q_nums) != 40:
            issues.append(
                Issue.create(
                    issue_id=f"iss_paper_qcnt_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_COUNT_MISMATCH,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Reading paper has {len(all_q_nums)} total questions, expected 40",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        # 3. Contiguous 1..40 numbering check
        if all_q_nums != list(range(1, 41)):
            issues.append(
                Issue.create(
                    issue_id=f"iss_paper_numbering_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_NUMBERING_INVALID,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Reading paper questions must be numbered contiguous 1 to 40; found {all_q_nums}",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        # 4. Total word count check [2150, 2750]
        if total_words < PAPER_MIN_WORDS or total_words > PAPER_MAX_WORDS:
            issues.append(
                Issue.create(
                    issue_id=f"iss_paper_total_wc_{uuid4().hex[:8]}",
                    code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Reading paper total word count {total_words} is outside policy bounds [{PAPER_MIN_WORDS}, {PAPER_MAX_WORDS}]",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        metrics["totalWords"] = total_words
        metrics["totalQuestions"] = len(all_q_nums)
        metrics["sectionWordCounts"] = section_word_counts
        metrics["sectionQuestionCounts"] = section_q_counts

        has_critical = any(i.severity == IssueSeverity.CRITICAL for i in issues)
        status = EvaluationStatus.FAIL if has_critical else EvaluationStatus.PASS

        return EvaluationResult(
            evaluation_id=f"eval_{self.evaluator_id}_{uuid4().hex[:8]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            input_dependency_refs=tuple(artifact.parent_refs),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
            evaluated_at=datetime.now(timezone.utc),
        )


# ── PaperCrossSectionEvaluator ───────────────────────────────────────────────


class PaperCrossSectionEvaluator(BaseEvaluator):
    """Evaluates cross-section duplication, 5-word shingle overlaps across passages, and prompt uniqueness."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_paper_cross_section",
                evaluator_version="2.0.0",
                name="Reading Paper Cross-Section Duplication Evaluator",
                description="Validates passage shingle overlap <= 0.45 across sections and prompt uniqueness across 40 questions",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[
                    IssueCode.DUPLICATE_CONTENT,
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
        metrics: Dict[str, Any] = {}

        sections = _extract_paper_sections(payload)
        passages: List[str] = []
        for sec in sections:
            passages.append(sec.get("passage", "") or sec.get("passageText", "") or sec.get("text", ""))

        # 1. Passage shingle overlap across all section pairs (1-2, 1-3, 2-3)
        shingle_matrix: Dict[str, float] = {}
        for i in range(len(passages)):
            for j in range(i + 1, len(passages)):
                pair_key = f"s{i+1}_s{j+1}"
                overlap = calculate_shingle_overlap(passages[i], passages[j])
                shingle_matrix[pair_key] = overlap
                if overlap > MAX_SHINGLE_OVERLAP:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_cross_passage_{i+1}_{j+1}_{uuid4().hex[:8]}",
                            code=IssueCode.DUPLICATE_CONTENT,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.PAPER,
                            message=f"Passage {i+1} and Passage {j+1} have shingle overlap {overlap:.3f} exceeding max threshold {MAX_SHINGLE_OVERLAP}",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        metrics["passageShingleMatrix"] = shingle_matrix

        # 2. Cross-question prompt uniqueness across all 40 questions
        seen_prompts: Dict[str, tuple] = {}
        prompt_shingles: List[tuple[int, str, set[str]]] = []

        SHARED_GROUP_TYPES = {
            "summarycompletion", "summarygroup", "notecompletiongroup",
            "flowchartcompletion", "matchingheadings", "matchingheading",
            "matching_headings", "summary_completion", "matching",
        }
        for sec_idx, sec in enumerate(sections):
            sec_num = sec_idx + 1
            for g_idx, grp in enumerate(sec.get("groups", [])):
                t_raw = grp.get("questionType") or grp.get("question_type") or grp.get("type") or ""
                t_norm = str(t_raw).replace("_", "").lower()
                gid = str(grp.get("groupId") or grp.get("group_id") or f"grp_s{sec_num}_{g_idx + 1}")
                is_shared_group = t_norm in SHARED_GROUP_TYPES and bool(gid)
                for q in grp.get("questions", []):
                    q_num = q.get("questionNumber") or q.get("number") or 0
                    prompt = q.get("prompt") or q.get("statement") or ""
                    norm_p = normalize_prompt(prompt)

                    if norm_p:
                        if norm_p in seen_prompts:
                            prev_q, prev_sec, prev_gid = seen_prompts[norm_p]
                            if not (is_shared_group and prev_gid and gid and prev_gid == gid and prev_sec == sec_num):
                                issues.append(
                                    Issue.create(
                                        issue_id=f"iss_dup_q_{q_num}_{prev_q}_{uuid4().hex[:8]}",
                                        code=IssueCode.DUPLICATE_CONTENT,
                                        severity=IssueSeverity.CRITICAL,
                                        scope=IssueScope.QUESTION,
                                        message=f"Question {q_num} in Section {sec_num} has identical prompt text to Question {prev_q}",
                                        affected_refs=[artifact.to_ref()],
                                        evaluator_id=self.evaluator_id,
                                    )
                                )
                        else:
                            seen_prompts[norm_p] = (q_num, sec_num, gid)
        has_critical = any(i.severity == IssueSeverity.CRITICAL for i in issues)
        status = EvaluationStatus.FAIL if has_critical else EvaluationStatus.PASS

        return EvaluationResult(
            evaluation_id=f"eval_{self.evaluator_id}_{uuid4().hex[:8]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            input_dependency_refs=tuple(artifact.parent_refs),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
            evaluated_at=datetime.now(timezone.utc),
        )


# ── PaperLeakageEvaluator ────────────────────────────────────────────────────


class PaperLeakageEvaluator(BaseEvaluator):
    """Evaluates cross-section and whole-paper prompt / instruction answer leakage."""

    def __init__(
        self,
        required: bool = True,
        timeout_seconds: Optional[float] = None,
        version: str = "2.1.0",
        strict_substring: bool = False,
    ):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        self.strict_substring = strict_substring or (version == "2.1.0")
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_paper_leakage",
                evaluator_version=version,
                name="Reading Paper Cross-Section Leakage Evaluator",
                description="Checks if instructions or question prompts leak answers or evidence across the full paper",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[
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
        metrics: Dict[str, Any] = {}

        sections = _extract_paper_sections(payload)

        # Collect all questions with their answers and evidence quotes across all 3 sections
        all_questions: List[Dict[str, Any]] = []
        for sec_idx, sec in enumerate(sections):
            sec_id = sec.get("sectionId") or sec.get("section_id") or (sec_idx + 1)
            for g_idx, grp in enumerate(sec.get("groups", [])):
                grp_type = grp.get("questionType") or grp.get("type") or ""
                grp_inst = grp.get("instructions") or grp.get("instruction") or ""
                grp_id = str(grp.get("groupId") or grp.get("group_id") or f"grp_s{sec_id}_{g_idx + 1}")
                for q in grp.get("questions", []):
                    q_copy = dict(q)
                    q_copy["_sectionId"] = sec_id
                    q_copy["_groupType"] = grp_type
                    q_copy["_groupInstructions"] = grp_inst
                    q_copy["_groupId"] = grp_id
                    all_questions.append(q_copy)
        # Check intra-question leakage and cross-question leakage
        for target_q in all_questions:
            t_num = target_q.get("questionNumber") or target_q.get("number")
            t_type = str(target_q.get("_groupType") or target_q.get("questionType") or "").upper().replace("_", "")
            t_ans = str(target_q.get("answer") or target_q.get("correctOption") or "").strip()
            if "MULTIPLECHOICE" in t_type:
                m = re.match(r"^([A-Da-d])[\.\:]\s*", t_ans)
                if m:
                    t_ans = m.group(1).upper()
            t_quote = str(target_q.get("evidenceQuote") or target_q.get("evidence") or "").strip()
            t_sec = target_q.get("_sectionId")

            t_prompt = target_q.get("prompt") or target_q.get("statement") or ""

            # 1. Intra-question self-leakage (P12-03)
            if (
                t_ans.upper().strip() not in STANDARD_CHOICE_LABELS
                and "TRUEFALSENOTGIVEN" not in t_type
                and "YESNONOTGIVEN" not in t_type
            ):
                if check_prompt_answer_leakage(t_prompt, t_ans):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_leak_self_{t_num}_{uuid4().hex[:8]}",
                            code=IssueCode.ANSWER_LEAKAGE,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {t_num} prompt verbatim reveals its own expected answer '{t_ans}'",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

            # Per P12-02/P12-03 + T12-04: distinguish shared passage topic
            # vocabulary from real leakage.
            #   (a) cross-section leakage (o_sec != t_sec): any other prompt
            #       leaking target's multi-word answer (>=2 words)
            #   (b) intra-section leakage (o_sec == t_sec):
            #       - verbatim evidence quote in another prompt
            #       - type-aware exact answer leakage for COMPLETION/SHORT_ANSWER
            #         when prompt predicates match

            ans_words = t_ans.split()
            is_completion_or_short_answer = (
                "COMPLETION" in t_type or "SHORTANSWER" in t_type or "SHORT_ANSWER" in t_type
            )

            SHARED_GROUP_TYPES = {
                "summarycompletion", "summarygroup", "notecompletiongroup",
                "flowchartcompletion", "matchingheadings", "matchingheading",
                "matching_headings", "summary_completion", "matching",
            }
            t_type_norm = str(t_type).replace("_", "").lower()
            t_gid = str(target_q.get("_groupId") or "")

            for other_q in all_questions:
                o_num = other_q.get("questionNumber") or other_q.get("number")
                if o_num == t_num:
                    continue
                o_sec = other_q.get("_sectionId")
                o_gid = str(other_q.get("_groupId") or "")
                if t_type_norm in SHARED_GROUP_TYPES and o_sec == t_sec and o_gid and t_gid and o_gid == t_gid:
                    continue
                o_prompt = other_q.get("prompt") or other_q.get("statement") or ""

                flagged = False
                leakage_kind = ""

                if o_sec != t_sec:
                    # Cross-section: any prompt leaking target answer (>= 2 words)
                    is_leak = False
                    if t_ans.upper().strip() not in STANDARD_CHOICE_LABELS and len(ans_words) >= 2:
                        is_leak = _answer_tokens_present_in_prompt(t_ans, o_prompt) or check_prompt_answer_leakage(o_prompt, t_ans)
                    if is_leak:
                        flagged = True
                        leakage_kind = "cross-section"
                else:
                    # Intra-section:
                    # (1) Verbatim evidence quote leakage
                    if t_quote and (len(t_quote.split()) >= 2 or len(t_quote) >= 8) and _quote_appears_in_prompt(t_quote, o_prompt):
                        flagged = True
                        leakage_kind = "intra-section evidence"
                    # (2) Type-aware exact answer leakage for completion/short answer
                    elif is_completion_or_short_answer and t_ans.upper().strip() not in STANDARD_CHOICE_LABELS and len(ans_words) >= 2:
                        t_predicate = _extract_question_predicate(t_prompt)
                        o_predicate = _extract_question_predicate(o_prompt)
                        if t_predicate and o_predicate and t_predicate == o_predicate:
                            is_leak = _answer_tokens_present_in_prompt(t_ans, o_prompt) or check_prompt_answer_leakage(o_prompt, t_ans)
                            if is_leak:
                                flagged = True
                                leakage_kind = "intra-section exact answer"
                if flagged:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_leak_{leakage_kind.replace(' ', '_')}_{o_num}_{t_num}_{uuid4().hex[:8]}",
                            code=IssueCode.ANSWER_LEAKAGE,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=(
                                f"Question {o_num} prompt {leakage_kind} leaks answer "
                                f"'{t_ans}' for Question {t_num}"
                            ),
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
            if self.strict_substring:
                # Check group instructions for answer leakage under strict mode (v2.1.0)
                # Standard choice labels (TRUE/FALSE/NOT GIVEN/YES/NO) in instructions are format specifications, not answer leakage.
                if t_ans.upper().strip() not in STANDARD_CHOICE_LABELS:
                    for o_inst in {q.get("_groupInstructions", "") for q in all_questions if q.get("_groupInstructions")}:
                        if len(ans_words) >= 2 and check_prompt_answer_leakage(o_inst, t_ans):
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_leak_inst_{t_num}_{uuid4().hex[:8]}",
                                    code=IssueCode.ANSWER_LEAKAGE,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION,
                                    message=f"Group instruction leaks answer '{t_ans}' for Question {t_num}",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )
        metrics["evaluatedQuestionsCount"] = len(all_questions)
        has_critical = any(i.severity == IssueSeverity.CRITICAL for i in issues)
        status = EvaluationStatus.FAIL if has_critical else EvaluationStatus.PASS

        return EvaluationResult(
            evaluation_id=f"eval_{self.evaluator_id}_{uuid4().hex[:8]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            input_dependency_refs=tuple(artifact.parent_refs),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
            evaluated_at=datetime.now(timezone.utc),
        )


# ── PaperMonotonyEvaluator ───────────────────────────────────────────────────


class PaperMonotonyEvaluator(BaseEvaluator):
    """Evaluates full-paper answer distribution diversity and monotony."""

    def __init__(self, required: bool = False, timeout_seconds: Optional[float] = None):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_paper_monotony",
                evaluator_version="2.0.0",
                name="Reading Paper Answer Monotony Evaluator",
                description="Checks answer distribution diversity across True/False, Yes/No, and Multiple Choice questions",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.READING_PAPER],
                required=required,
                hard_checks=[],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []
        metrics: Dict[str, Any] = {}

        sections = _extract_paper_sections(payload)
        mcq_answers: List[str] = []
        tf_answers: List[str] = []
        yn_answers: List[str] = []

        for sec in sections:
            for grp in sec.get("groups", []):
                grp_type = grp.get("questionType") or grp.get("type") or ""
                type_norm = str(grp_type).replace("_", "").upper()
                for q in grp.get("questions", []):
                    ans = str(q.get("answer") or q.get("correctOption") or "").strip().upper()
                    if "MULTIPLECHOICE" in type_norm:
                        m = re.match(r"^([A-Da-d])[\.\:]\s*", ans)
                        if m:
                            ans = m.group(1).upper()
                    if "TRUEFALSE" in type_norm:
                        tf_answers.append(ans)
                    elif "YESNO" in type_norm:
                        yn_answers.append(ans)
                    elif "MULTIPLECHOICE" in type_norm:
                        mcq_answers.append(ans)

        # Evaluate TF monotony
        if tf_answers and len(set(tf_answers)) == 1 and len(tf_answers) >= 5:
            issues.append(
                Issue.create(
                    issue_id=f"iss_monotony_tf_{uuid4().hex[:8]}",
                    code=IssueCode.ANSWER_CONCENTRATION_DETECTED,
                    severity=IssueSeverity.MINOR,
                    scope=IssueScope.PAPER,
                    message=f"All {len(tf_answers)} True/False/Not Given questions have identical answer '{tf_answers[0]}'",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        # Evaluate YN monotony
        if yn_answers and len(set(yn_answers)) == 1 and len(yn_answers) >= 5:
            issues.append(
                Issue.create(
                    issue_id=f"iss_monotony_yn_{uuid4().hex[:8]}",
                    code=IssueCode.ANSWER_CONCENTRATION_DETECTED,
                    severity=IssueSeverity.MINOR,
                    scope=IssueScope.PAPER,
                    message=f"All {len(yn_answers)} Yes/No/Not Given questions have identical answer '{yn_answers[0]}'",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        # Evaluate MCQ monotony
        if mcq_answers and len(set(mcq_answers)) == 1 and len(mcq_answers) >= 5:
            issues.append(
                Issue.create(
                    issue_id=f"iss_monotony_mcq_{uuid4().hex[:8]}",
                    code=IssueCode.ANSWER_CONCENTRATION_DETECTED,
                    severity=IssueSeverity.MINOR,
                    scope=IssueScope.PAPER,
                    message=f"All {len(mcq_answers)} Multiple Choice questions have identical correct option '{mcq_answers[0]}'",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        metrics["tfDistribution"] = {ans: tf_answers.count(ans) for ans in set(tf_answers)}
        metrics["ynDistribution"] = {ans: yn_answers.count(ans) for ans in set(yn_answers)}
        metrics["mcqDistribution"] = {ans: mcq_answers.count(ans) for ans in set(mcq_answers)}

        has_critical = any(i.severity == IssueSeverity.CRITICAL for i in issues)
        status = EvaluationStatus.FAIL if has_critical else EvaluationStatus.PASS

        return EvaluationResult(
            evaluation_id=f"eval_{self.evaluator_id}_{uuid4().hex[:8]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            input_dependency_refs=tuple(artifact.parent_refs),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
            evaluated_at=datetime.now(timezone.utc),
        )
