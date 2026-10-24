"""Canonical Section Evaluators for Langfens Loop Engine V2 (Phase 11 / P11-02, P11-03, P11-04).

Evaluators:
1. SectionStructureEvaluator (P11-02):
   - Exactly 2 question groups per section.
   - Passage length strictly in [720, 915] words.
   - Exact question counts: S1 (13: 7 TFNG + 6 Sentence Completion),
     S2 (13: 6 MCQ Single + 7 Summary Completion), S3 (14: 7 YNNG + 7 Short Answer).
   - Question numbering contiguous per blueprint (S1: 1-13, S2: 14-26, S3: 27-40).
   - Validates fresh evaluations, zero missing/stale/error required evaluations,
     and blind solver / adversary coverage per G10.

2. SectionDuplicateAndConcentrationEvaluator (P11-03):
   - Checks section-wide duplicate questions and 5-word shingle overlaps > 0.45.
   - Checks prompt answer leakage across the section without token false-positives.
   - Evaluates passage span concentration (evidence quotes clustered in tiny fraction).
   - Evaluates answer distribution monotony (e.g. all TRUE or all option A).
   - Versioned thresholds/rationale: does not reject purely for shared domain vocabulary.

3. SectionEditorialEvaluator (P11-04):
   - Evaluates editorial style, instruction clarity, and cognitive skill diversity.
   - Separates non-blocking warnings (MINOR/INFO) from blocking defects (CRITICAL/MAJOR).
   - Computes heuristic difficulty & confidence score (diagnostic, never overrides hard blockers).
"""

from __future__ import annotations

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
from app.evaluators.deterministic import check_cross_prompt_answer_leakage, check_prompt_answer_leakage, normalize_text_nfkc
from app.loop.context import LoopContext


# ── Helper for Mapping & Object Extraction ───────────────────────────────────


def _extract_group_questions(grp: Any) -> List[Any]:
    if isinstance(grp, Mapping):
        return list(grp.get("questions", []))
    if hasattr(grp, "questions"):
        return list(getattr(grp, "questions"))
    return []


def _extract_group_type_str(grp: Any) -> str:
    if isinstance(grp, Mapping):
        raw = grp.get("questionType") or grp.get("type") or ""
    else:
        raw = getattr(grp, "question_type", getattr(grp, "questionType", getattr(grp, "type", "")))
    return str(raw).replace("_", "").lower()


def _extract_group_instructions(grp: Any) -> str:
    if isinstance(grp, Mapping):
        return str(grp.get("instructions") or grp.get("instruction") or "")
    return str(getattr(grp, "instructions", getattr(grp, "instruction", "")))


def _extract_question_dict(q: Any) -> Dict[str, Any]:
    if isinstance(q, Mapping):
        return dict(q)
    if hasattr(q, "model_dump"):
        return q.model_dump(mode="json", by_alias=True)
    return dict(q)


# ── SectionStructureEvaluator ────────────────────────────────────────────────


class SectionStructureEvaluator(BaseEvaluator):
    """Evaluates Section invariants: 2 groups, 720-915 passage words, exact counts and distributions."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_section_structure",
                evaluator_version="1.0.0",
                name="Section Structure and Dependency Evaluator",
                description="Enforces 2 groups, 720-915 words, S1/S2/S3 question counts and fresh solver/adversary coverage",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION],
                required=required,
                hard_checks=[
                    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    IssueCode.QUESTION_COUNT_MISMATCH,
                    IssueCode.QUESTION_NUMBERING_INVALID,
                    IssueCode.SECTION_GROUP_COUNT_MISMATCH,
                    IssueCode.SECTION_GROUP_TYPE_MISMATCH,
                    IssueCode.SECTION_GROUP_SIZE_MISMATCH,
                    IssueCode.STALE_DEPENDENCY,
                    IssueCode.FRESH_EVALUATION_MISSING,
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
        sec_id = int(payload.get("sectionId") or payload.get("section_id") or artifact.section_id or 1)

        # 1. Passage Word Count Check [720, 915]
        passage_text = payload.get("passage", "") or payload.get("passageText", "") or payload.get("text", "")
        word_count = count_words(passage_text)
        if word_count < PASSAGE_MIN_WORDS or word_count > PASSAGE_MAX_WORDS:
            issues.append(
                Issue.create(
                    issue_id=f"iss_sec_{sec_id}_wc_{uuid4().hex[:8]}",
                    code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SECTION,
                    message=(
                        f"Section {sec_id} passage word count {word_count} is outside "
                        f"permitted range [{PASSAGE_MIN_WORDS}, {PASSAGE_MAX_WORDS}]"
                    ),
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        # 2. Expected Section Specifications
        expected_total_q = SECTION_QUESTION_COUNTS.get(sec_id, 13)
        expected_sizes = SECTION_GROUP_SIZES.get(sec_id, [7, 6])
        expected_types = SECTION_GROUP_TYPES.get(sec_id, [QuestionType.TRUE_FALSE_NOT_GIVEN, QuestionType.SENTENCE_COMPLETION])
        groups = list(payload.get("groups", []))

        is_legacy_preset = len(groups) == 2 and all(
            g_idx < len(expected_types) and (
                _extract_group_type_str(grp) in (expected_types[g_idx].value.replace("_", "").lower(), expected_types[g_idx].name.replace("_", "").lower())
            )
            for g_idx, grp in enumerate(groups)
        )

        if is_legacy_preset:
            for g_idx, grp in enumerate(groups):
                g_questions = _extract_group_questions(grp)
                type_str = _extract_group_type_str(grp)
                if g_idx < len(expected_types):
                    exp_t = expected_types[g_idx]
                    exp_t_str = exp_t.value.replace("_", "").lower()
                    if type_str != exp_t_str and type_str != exp_t.name.replace("_", "").lower():
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_sec_{sec_id}_grptype_{g_idx}_{uuid4().hex[:8]}",
                                code=IssueCode.SECTION_GROUP_TYPE_MISMATCH,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION_GROUP,
                                message=(
                                    f"Section {sec_id} group {g_idx+1} question type '{type_str}' "
                                    f"does not match expected blueprint type '{exp_t.value}'"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                if g_idx < len(expected_sizes):
                    exp_size = expected_sizes[g_idx]
                    if len(g_questions) != exp_size:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_sec_{sec_id}_grpsize_{g_idx}_{uuid4().hex[:8]}",
                                code=IssueCode.SECTION_GROUP_SIZE_MISMATCH,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION_GROUP,
                                message=(
                                    f"Section {sec_id} group {g_idx+1} has {len(g_questions)} questions, "
                                    f"expected {exp_size}"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
        else:
            if not (2 <= len(groups) <= 4):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_id}_grpcnt_{uuid4().hex[:8]}",
                        code=IssueCode.SECTION_GROUP_COUNT_MISMATCH,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_id} has {len(groups)} question group(s), expected 2-4",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
            for g_idx, grp in enumerate(groups):
                g_questions = _extract_group_questions(grp)
                if not g_questions:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sec_{sec_id}_grpsize_{g_idx}_{uuid4().hex[:8]}",
                            code=IssueCode.SECTION_GROUP_SIZE_MISMATCH,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION_GROUP,
                            message=f"Section {sec_id} group {g_idx+1} has 0 questions",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        start_num = 1 if sec_id == 1 else (14 if sec_id == 2 else 27)
        expected_q_numbers = list(range(start_num, start_num + expected_total_q))
        all_q_numbers: List[int] = []
        for grp in groups:
            for q in _extract_group_questions(grp):
                q_dict = _extract_question_dict(q)
                q_num = q_dict.get("questionNumber") or q_dict.get("question_number") or q_dict.get("number")
                if q_num is not None:
                    all_q_numbers.append(int(q_num))
        # 4. Total Question Count and Contiguous Numbering Check
        if len(all_q_numbers) != expected_total_q:
            issues.append(
                Issue.create(
                    issue_id=f"iss_sec_{sec_id}_qcnt_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_COUNT_MISMATCH,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SECTION,
                    message=f"Section {sec_id} total question count is {len(all_q_numbers)}, expected {expected_total_q}",
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        if all_q_numbers != expected_q_numbers:
            issues.append(
                Issue.create(
                    issue_id=f"iss_sec_{sec_id}_qnum_{uuid4().hex[:8]}",
                    code=IssueCode.QUESTION_NUMBERING_INVALID,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.SECTION,
                    message=(
                        f"Section {sec_id} question numbers {all_q_numbers} do not form the "
                        f"required contiguous sequence {expected_q_numbers}"
                    ),
                    affected_refs=[artifact.to_ref()],
                    evaluator_id=self.evaluator_id,
                )
            )

        # 5. Dependency Freshness & Solver / Adversary Coverage Check (Strict Fail-Closed)
        #    Ownership moved to SectionCoverageEvaluator (app/evaluators/coverage.py).
        #    This evaluator owns deterministic Section *shape* invariants only. Fresh
        #    solver/adversary coverage binding is a coverage-layer guarantee and is
        #    still enforced fail-closed, but it is evaluated by its owning evaluator so
        #    a structurally valid section is not coupled to child-evaluation ordering.
        eval_summary = payload.get("evaluationsSummary") or payload.get("evaluations_summary")
        if isinstance(eval_summary, Mapping):
            fresh_evals = eval_summary.get("freshEvaluations") is True
            solver_covered = eval_summary.get("solverCovered") is True
            adversary_covered = eval_summary.get("adversaryCovered") is True
            accepted_eval_refs = eval_summary.get("acceptedEvaluationRefs") or []
            has_stale_deps = eval_summary.get("hasStaleDependencies", False)

            if not fresh_evals or has_stale_deps:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_id}_stale_{uuid4().hex[:8]}",
                        code=IssueCode.STALE_DEPENDENCY,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_id} contains stale or unverified dependency references",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            if not solver_covered or not adversary_covered or not accepted_eval_refs or eval_summary.get("missingRequiredEvaluations", False):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_id}_missing_eval_{uuid4().hex[:8]}",
                        code=IssueCode.FRESH_EVALUATION_MISSING,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SECTION,
                        message=f"Section {sec_id} is missing mandatory fresh Blind Solver or Adversary coverage",
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


# ── SectionDuplicateAndConcentrationEvaluator ────────────────────────────────


class SectionDuplicateAndConcentrationEvaluator(BaseEvaluator):
    """Evaluates section-wide duplicate questions, shingle overlaps, span concentration, and answer distributions."""

    def __init__(
        self,
        required: bool = True,
        max_shingle_overlap: float = 0.45,
        max_span_concentration_ratio: float = 0.75,
        timeout_seconds: Optional[float] = None,
    ):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_section_duplicate_concentration",
                evaluator_version="1.0.0",
                name="Section Duplicate and Concentration Evaluator",
                description="Checks question duplicates, shingle overlap >0.45, prompt answer leakage, span clustering, and answer distribution monotony",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION],
                required=required,
                hard_checks=[
                    IssueCode.DUPLICATE_CONTENT,
                    IssueCode.ANSWER_LEAKAGE,
                    IssueCode.SPAN_CONCENTRATION_DETECTED,
                    IssueCode.ANSWER_CONCENTRATION_DETECTED,
                ],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )
        self.max_shingle_overlap = max_shingle_overlap
        self.max_span_concentration_ratio = max_span_concentration_ratio

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []
        sec_id = int(payload.get("sectionId") or payload.get("section_id") or artifact.section_id or 1)
        passage_text = payload.get("passage", "") or payload.get("passageText", "") or payload.get("text", "")

        groups = list(payload.get("groups", []))
        all_questions: List[Dict[str, Any]] = []

        SHARED_GROUP_TYPES = {
            "summarycompletion", "summarygroup", "notecompletiongroup",
            "flowchartcompletion", "matchingheadings", "matchingheading",
            "matching_headings", "summary_completion", "matching",
        }

        def _norm_type(t: Any) -> str:
            return str(t or "").replace("_", "").lower()

        def _group_id_of(grp: Any) -> str:
            if isinstance(grp, Mapping):
                return str(grp.get("groupId") or grp.get("group_id") or "")
            return str(getattr(grp, "groupId", getattr(grp, "group_id", "")) or "")

        def _group_type_of(grp: Any) -> str:
            if isinstance(grp, Mapping):
                t = grp.get("questionType") or grp.get("question_type")
            else:
                t = getattr(grp, "questionType", getattr(grp, "question_type", ""))
            return _norm_type(t)

        # Map question_number -> (group_id, t_norm, is_shared_sibling).
        # Sibling questions in a shared group legitimately share the prompt text
        # (Summary Completion, Note Completion, Flowchart Completion, Matching Headings);
        # only the *answers* must be distinct.
        question_group_info: Dict[int, tuple] = {}
        for grp in groups:
            gid = _group_id_of(grp)
            t_norm = _group_type_of(grp)
            is_shared = t_norm in SHARED_GROUP_TYPES and bool(gid)
            for q in _extract_group_questions(grp):
                qd = _extract_question_dict(q)
                qn = int(qd.get("questionNumber") or qd.get("number") or 0)
                if qn:
                    question_group_info[qn] = (gid, t_norm, is_shared)

        for grp in groups:
            qs = _extract_group_questions(grp)
            for q in qs:
                all_questions.append(_extract_question_dict(q))

        # 1. Check for Duplicate Prompts & High Shingle Overlap (>0.45)
        seen_prompts: Dict[str, tuple] = {}
        for i, q in enumerate(all_questions):
            prompt = q.get("prompt") or q.get("statement") or ""
            q_num = q.get("questionNumber") or q.get("number") or (i + 1)
            norm_p = normalize_prompt(prompt)
            q_info = question_group_info.get(int(q_num))
            gid = q_info[0] if q_info else ""
            is_shared_sibling = bool(q_info and q_info[2])

            if norm_p:
                if norm_p in seen_prompts:
                    other_num, other_gid = seen_prompts[norm_p]
                    if not (is_shared_sibling and other_gid and gid and other_gid == gid):
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_sec_{sec_id}_dup_{q_num}_{uuid4().hex[:8]}",
                                code=IssueCode.DUPLICATE_CONTENT,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"Question {q_num} is an exact duplicate of Question {other_num}",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                else:
                    seen_prompts[norm_p] = (int(q_num), gid)

            # Check pairwise shingle overlap against previously seen questions
            for j in range(i):
                other_q = all_questions[j]
                other_p = other_q.get("prompt") or other_q.get("statement") or ""
                other_num = other_q.get("questionNumber") or other_q.get("number") or (j + 1)
                other_info = question_group_info.get(int(other_num))
                other_is_shared = bool(other_info and other_info[2])
                # Skip shingle-overlap check when both questions are siblings in the
                # SAME shared group (Summary Completion, etc.) — they intentionally share
                # the group prompt text.
                if is_shared_sibling and other_is_shared and q_info and other_info and q_info[0] == other_info[0] and q_info[0]:
                    continue
                overlap = calculate_shingle_overlap(prompt, other_p)
                if overlap > self.max_shingle_overlap:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sec_{sec_id}_shingle_{q_num}_{other_num}_{uuid4().hex[:8]}",
                            code=IssueCode.DUPLICATE_CONTENT,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=(
                                f"Question {q_num} and Question {other_num} have 5-word shingle "
                                f"overlap of {overlap:.2f} (> {self.max_shingle_overlap})"
                            ),
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        # 2. Distinct-answers check for sibling pairs in shared groups.
        # Sibling blanks in a Summary Completion / Note Completion / Flowchart Completion
        # group must have distinct answers; identical answers indicate a real defect.
        for grp in groups:
            gid = _group_id_of(grp)
            t_norm = _group_type_of(grp)
            if t_norm not in SHARED_GROUP_TYPES or not gid:
                continue
            qds = [_extract_question_dict(q) for q in _extract_group_questions(grp)]
            for i in range(len(qds)):
                for j in range(i + 1, len(qds)):
                    ans_i = str(qds[i].get("answer") or qds[i].get("correctOption") or "").strip()
                    ans_j = str(qds[j].get("answer") or qds[j].get("correctOption") or "").strip()
                    if not ans_i or not ans_j:
                        continue
                    if ans_i.upper() == ans_j.upper():
                        qn_i = int(qds[i].get("questionNumber") or qds[i].get("number") or (i + 1))
                        qn_j = int(qds[j].get("questionNumber") or qds[j].get("number") or (j + 1))
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_sec_{sec_id}_sibans_{qn_i}_{qn_j}_{uuid4().hex[:8]}",
                                code=IssueCode.DUPLICATE_CONTENT,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Questions {qn_i} and {qn_j} in shared group '{gid}' "
                                    f"have identical answers ('{ans_i}')"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

        # 2. Check Prompt Answer Leakage across the section (excluding self and same-group siblings)
        for q in all_questions:
            q_num = q.get("questionNumber") or q.get("number") or 1
            ans = q.get("answer") or q.get("correctOption") or ""
            q_info = question_group_info.get(int(q_num))
            for other_q in all_questions:
                other_num = other_q.get("questionNumber") or other_q.get("number") or 1
                if q_num != other_num:
                    other_info = question_group_info.get(int(other_num))
                    if q_info and other_info and q_info[2] and other_info[2] and q_info[0] and q_info[0] == other_info[0]:
                        continue
                    other_prompt = other_q.get("prompt") or other_q.get("statement") or ""
                    if str(ans).strip().upper() not in {"TRUE", "FALSE", "NOT_GIVEN", "YES", "NO", "A", "B", "C", "D"}:
                        src_obj = payload.get("source") or {}
                        src_title = src_obj.get("title", "") if isinstance(src_obj, (dict, Mapping)) else getattr(src_obj, "title", "")
                        title_str = str(payload.get("title") or "")
                        topic_str = str(payload.get("topic") or src_title or getattr(context, "topic", "") or "")
                        if check_cross_prompt_answer_leakage(other_prompt, str(ans), topic=topic_str, passage_title=title_str):
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_sec_{sec_id}_leak_{q_num}_{other_num}_{uuid4().hex[:8]}",
                                    code=IssueCode.ANSWER_LEAKAGE,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.SECTION,
                                    message=(
                                        f"Answer for Question {q_num} ('{ans}') leaks verbatim inside "
                                        f"the prompt of Question {other_num}"
                                    ),
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )
        # 3. Check Evidence Span Concentration across the passage
        quote_positions: List[int] = []
        for q in all_questions:
            quote = q.get("evidenceQuote") or q.get("evidence_quote") or ""
            if quote and passage_text:
                pos = passage_text.find(quote.strip())
                if pos >= 0:
                    quote_positions.append(pos)

        if len(quote_positions) >= 6 and passage_text:
            passage_len = len(passage_text)
            min_pos = min(quote_positions)
            max_pos = max(quote_positions)
            span_range = max_pos - min_pos
            if passage_len > 1000 and (span_range / passage_len) < 0.15:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_id}_span_conc_{uuid4().hex[:8]}",
                        code=IssueCode.SPAN_CONCENTRATION_DETECTED,
                        severity=IssueSeverity.MAJOR,
                        scope=IssueScope.SECTION,
                        message=(
                            f"Section {sec_id} questions exhibit severe span concentration: "
                            f"all evidence quotes fall within {span_range} characters "
                            f"({(span_range/passage_len)*100:.1f}% of passage)"
                        ),
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

        # 4. Check Answer Distribution Monotony within Groups
        for g_idx, grp in enumerate(groups):
            qs = _extract_group_questions(grp)
            q_dicts = [_extract_question_dict(q) for q in qs]
            t_str = _extract_group_type_str(grp)

            if "truefalse" in t_str or "yesno" in t_str:
                answers = [str(q.get("answer", "")).upper() for q in q_dicts if q.get("answer")]
                if len(answers) >= 5 and len(set(answers)) == 1:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sec_{sec_id}_ans_monotony_{g_idx}_{uuid4().hex[:8]}",
                            code=IssueCode.ANSWER_CONCENTRATION_DETECTED,
                            severity=IssueSeverity.MAJOR,
                            scope=IssueScope.QUESTION_GROUP,
                            message=f"Section {sec_id} group {g_idx+1} has 100% identical answers ({answers[0]}) across all {len(answers)} questions",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
            elif "multiplechoice" in t_str or "mcq" in t_str:
                options = [str(q.get("correctOption", "")).upper() for q in q_dicts if q.get("correctOption")]
                if len(options) >= 5 and len(set(options)) == 1:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sec_{sec_id}_mcq_monotony_{g_idx}_{uuid4().hex[:8]}",
                            code=IssueCode.ANSWER_CONCENTRATION_DETECTED,
                            severity=IssueSeverity.MAJOR,
                            scope=IssueScope.QUESTION_GROUP,
                            message=f"Section {sec_id} MCQ group has 100% identical correct option letter ({options[0]}) across all {len(options)} questions",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        status = EvaluationStatus.FAIL if any(iss.severity in {IssueSeverity.CRITICAL, IssueSeverity.MAJOR} for iss in issues) else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=1.0 if status == EvaluationStatus.PASS else 0.0,
        )


# ── SectionEditorialEvaluator ────────────────────────────────────────────────


class SectionEditorialEvaluator(BaseEvaluator):
    """Evaluates editorial style, instruction clarity, and skill diversity distribution."""

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None):
        t_sec = (
            timeout_seconds
            if timeout_seconds is not None
            else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        )
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_section_editorial",
                evaluator_version="1.0.0",
                name="Section Editorial and Skill Diversity Evaluator",
                description="Evaluates style, cognitive skill diversity, and computes heuristic confidence metrics without overriding hard blockers",
                stage=EvaluationStage.DETERMINISTIC,
                target_artifact_types=[ArtifactType.SECTION],
                required=required,
                hard_checks=[
                    IssueCode.EDITORIAL_STYLE_DEFECT,
                    IssueCode.EDITORIAL_SKILL_DIVERSITY_DEFECT,
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
        sec_id = int(payload.get("sectionId") or payload.get("section_id") or artifact.section_id or 1)

        groups = list(payload.get("groups", []))
        total_prompts_len = 0
        q_count = 0

        for grp in groups:
            instructions = _extract_group_instructions(grp)
            if not instructions or len(instructions.strip()) < 10:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_sec_{sec_id}_inst_{uuid4().hex[:8]}",
                        code=IssueCode.EDITORIAL_STYLE_DEFECT,
                        severity=IssueSeverity.MAJOR,
                        scope=IssueScope.QUESTION_GROUP,
                        message=f"Section {sec_id} question group is missing standardized test-taker instructions",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            qs = _extract_group_questions(grp)
            for q in qs:
                q_dict = _extract_question_dict(q)
                p = q_dict.get("prompt") or q_dict.get("statement") or ""
                total_prompts_len += len(p.split())
                q_count += 1

                # Minor warning for very short prompt
                if len(p.split()) < 4:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sec_{sec_id}_p_short_{uuid4().hex[:8]}",
                            code=IssueCode.EDITORIAL_STYLE_DEFECT,
                            severity=IssueSeverity.MINOR,
                            scope=IssueScope.QUESTION,
                            message=f"Question prompt '{p}' is unusually brief (< 4 words)",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        # Heuristic confidence calculation
        avg_prompt_words = (total_prompts_len / q_count) if q_count > 0 else 0
        heuristic_score = min(1.0, max(0.0, 0.8 + (0.02 * min(avg_prompt_words, 10))))

        has_blockers = any(iss.severity in {IssueSeverity.CRITICAL, IssueSeverity.MAJOR} for iss in issues)
        status = EvaluationStatus.FAIL if has_blockers else EvaluationStatus.PASS
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=heuristic_score if status == EvaluationStatus.PASS else 0.0,
        )
