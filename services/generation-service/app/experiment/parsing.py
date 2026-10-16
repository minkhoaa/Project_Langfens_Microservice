"""Response-only normalization for research arms; never creates question content."""
from __future__ import annotations

from dataclasses import dataclass
import json
import re
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, ValidationError

from app.contracts.research import (
    GrammarExerciseType, GrammarQuestionType, NeutralOutput, NeutralQuestion,
    NeutralQuestionGroup, OutputAvailability, StandaloneGrammarRequest,
    StandaloneReadingRequest,
)
from app.contracts.solver import StudentVisibleOption
from app.providers.errors import InvalidJsonError, SchemaMismatchError, TruncatedOutputError
from app.providers.parser import parse_defensive_json
from app.solvers.comparison import compare_answers

ResearchRequest = StandaloneReadingRequest | StandaloneGrammarRequest


@dataclass(frozen=True)
class ParsedCandidate:
    content: NeutralOutput | None
    availability: OutputAvailability
    failure_code: str | None = None
    proposed_answers: tuple[tuple[str, str], ...] = ()


def extract_fenced_or_braced_json(text: str) -> str:
    cleaned = text.strip()
    m = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", cleaned)
    if m:
        candidate = m.group(1).strip()
        try:
            json.loads(candidate)
            return candidate
        except Exception:
            pass
    if "{" in cleaned:
        start = cleaned.find("{")
        depth = 0
        in_str = False
        escape = False
        for i in range(start, len(cleaned)):
            c = cleaned[i]
            if escape:
                escape = False
                continue
            if c == "\\":
                escape = True
                continue
            if c == '"':
                in_str = not in_str
                continue
            if not in_str:
                if c == '{':
                    depth += 1
                elif c == '}':
                    depth -= 1
                    if depth == 0:
                        candidate = cleaned[start:i+1]
                        try:
                            json.loads(candidate)
                            return candidate
                        except Exception:
                            break
    return cleaned


def response_object(raw_text: str, max_response_bytes: int = 500_000) -> dict[str, Any] | None:
    """Reuse strict bounded JSON extraction, with robust code fence / braced object extraction."""
    extracted = extract_fenced_or_braced_json(raw_text)
    try:
        value = parse_defensive_json(extracted, max_response_bytes=max_response_bytes, allow_repair=False)
    except (InvalidJsonError, SchemaMismatchError, TruncatedOutputError, ValueError, TypeError):
        try:
            value = json.loads(extracted)
        except Exception:
            return None
    return value if isinstance(value, dict) else None


def _question(data: Any) -> NeutralQuestion | None:
    if not isinstance(data, dict):
        return None
    fields = ("question_id", "question_type", "text", "options", "instructions")
    projected = {key: data[key] for key in fields if key in data}
    projected = {key: value.strip() if isinstance(value, str) else value for key, value in projected.items()}
    try:
        return NeutralQuestion.model_validate(projected)
    except ValidationError:
        return None


def _groups(data: Any, question_ids: set[str]) -> tuple[list[NeutralQuestionGroup], bool]:
    if not isinstance(data, list):
        return [], False
    groups = []
    valid = True
    for row in data:
        if not isinstance(row, dict):
            valid = False
            continue
        try:
            group = NeutralQuestionGroup.model_validate({
                key: row[key] for key in ("group_id", "question_ids") if key in row
            })
        except ValidationError:
            valid = False
            continue
        retained = [qid for qid in group.question_ids if qid in question_ids]
        valid = valid and retained == group.question_ids
        if retained:
            groups.append(group.model_copy(update={"question_ids": retained}))
    mapped = [qid for group in groups for qid in group.question_ids]
    valid = valid and len(mapped) == len(set(mapped)) and set(mapped) == question_ids
    valid = valid and len({group.group_id for group in groups}) == len(groups)
    return groups, valid


def _task_failure(content: NeutralOutput, request: ResearchRequest, passage_text: str | None) -> str | None:
    if isinstance(request, StandaloneReadingRequest):
        if content.context_text != passage_text:
            return "CONTEXT_MISMATCH"
        allowed = {group.value for group in request.task.requested_groups}
        if any(q.question_type.value not in allowed for q in content.questions):
            return "QUESTION_TYPE_MISMATCH"
        if {q.question_type.value for q in content.questions} != allowed:
            return "QUESTION_GROUP_MISMATCH"
        if len(content.question_groups) != len(request.task.requested_groups):
            return "QUESTION_GROUP_MISMATCH"
        by_id = {q.question_id: q for q in content.questions}
        if any(len({by_id[qid].question_type for qid in group.question_ids}) != 1
               for group in content.question_groups):
            return "QUESTION_GROUP_MISMATCH"
    else:
        expected = {
            GrammarExerciseType.MCQ_SINGLE: GrammarQuestionType.GRAMMAR_MCQ,
            GrammarExerciseType.GAP_FILL: GrammarQuestionType.GRAMMAR_GAP,
            GrammarExerciseType.ERROR_CORRECTION: GrammarQuestionType.GRAMMAR_CORRECTION,
        }[request.task.exercise_type]
        if any(q.question_type != expected for q in content.questions):
            return "QUESTION_TYPE_MISMATCH"
    if len(content.questions) != request.task.requested_question_count:
        return "QUESTION_COUNT_MISMATCH"
    for question in content.questions:
        is_mcq = question.question_type.value in ("MCQ_SINGLE", "GRAMMAR_MCQ")
        if is_mcq:
            if len(question.options) != 4 or len(set(question.options)) != 4 or any(not str(option).strip() for option in question.options):
                return "QUESTION_OPTIONS_INVALID"
        else:
            if question.options and any(not str(option).strip() for option in question.options):
                return "QUESTION_OPTIONS_INVALID"
    return None


def parse_candidate(raw_text: str, request: ResearchRequest, passage_text: str | None) -> ParsedCandidate:
    payload = response_object(raw_text)
    if payload is None:
        return ParsedCandidate(None, OutputAvailability.RAW_ONLY if raw_text else OutputAvailability.NONE,
                               "RAW_OUTPUT_UNPARSEABLE")
    rows = payload.get("questions")
    if not isinstance(rows, list):
        return ParsedCandidate(None, OutputAvailability.PARSEABLE, "OUTPUT_SCHEMA_INVALID")
    parsed = [_question(row) for row in rows]
    questions = [question for question in parsed if question is not None]
    ids = {question.question_id for question in questions}
    schema_valid = len(questions) == len(rows) and len(ids) == len(questions)
    # Retain the first real occurrence of a duplicate ID, never rewrite identifiers/content.
    questions = [question for index, question in enumerate(questions)
                 if question.question_id not in {q.question_id for q in questions[:index]}]
    if isinstance(request, StandaloneReadingRequest) and passage_text is not None and passage_text.strip():
        context = passage_text
    else:
        context = payload.get("context_text")
        if (not context or not isinstance(context, str) or not context.strip()) and passage_text is not None:
            context = passage_text
    if not isinstance(context, str) or not context.strip() or not questions:
        return ParsedCandidate(None, OutputAvailability.PARSEABLE, "OUTPUT_SCHEMA_INVALID")
    groups, groups_valid = _groups(payload.get("question_groups"), ids)
    content = NeutralOutput(context_text=context, questions=questions, question_groups=groups)
    failure = None if schema_valid and groups_valid else "OUTPUT_SCHEMA_INVALID"
    failure = failure or _task_failure(content, request, passage_text)
    proposed_items = []
    for row in rows:
        if isinstance(row, dict) and row.get("question_id") in ids:
            ans = row.get("proposed_answer") or row.get("answer")
            if isinstance(ans, str) and ans.strip():
                proposed_items.append((str(row["question_id"]), ans.strip()))
    proposed = tuple(proposed_items)
    if not failure:
        prop_map = dict(proposed)
        if any(q.question_id not in prop_map or not prop_map[q.question_id].strip() for q in content.questions):
            failure = "PROPOSED_ANSWERS_MISSING"
        else:
            for q in content.questions:
                ans = prop_map.get(q.question_id, "")
                if ans and len(ans) >= 3 and ans.lower() not in {"true", "false", "yes", "no", "not given", "not_given"}:
                    if re.search(rf"\b{re.escape(ans)}\b", q.text, re.IGNORECASE):
                        failure = "PROMPT_LEAKS_ANSWER"
                        break
    return ParsedCandidate(content, OutputAvailability.PARSEABLE if failure else OutputAvailability.NORMALIZED,
                           failure, proposed)


class ReviewResponse(BaseModel):
    model_config = ConfigDict(frozen=True, extra="ignore")
    status: str
    issues: tuple[str, ...]


class CritiqueResponse(BaseModel):
    model_config = ConfigDict(frozen=True, extra="ignore")
    verdict: str
    issues: tuple[str, ...]
    score: float | None = Field(default=None, ge=0, le=5)


class SolverAnswer(BaseModel):
    model_config = ConfigDict(frozen=True, extra="ignore")
    question_id: str = Field(min_length=1)
    answer: str = Field(min_length=1)
    ambiguous: bool = Field(strict=True)


class SolverResponse(BaseModel):
    model_config = ConfigDict(frozen=True, extra="ignore")
    answers: tuple[SolverAnswer, ...]


class ValidatorResponse(BaseModel):
    model_config = ConfigDict(frozen=True, extra="ignore")
    accepted: bool = Field(strict=True)
    issues: tuple[str, ...]


def parse_control(raw_text: str, model: type[BaseModel]) -> Any:
    payload = response_object(raw_text)
    if payload is None:
        return None
    try:
        return model.model_validate(payload)
    except ValidationError:
        return None


def solver_failure(solved: SolverResponse, candidate: ParsedCandidate) -> str | None:
    expected = {q.question_id for q in candidate.content.questions} if candidate.content else set()
    received = [answer.question_id for answer in solved.answers]
    if set(received) != expected or len(received) != len(expected):
        return "BLIND_SOLVE_INCOMPLETE"
    if any(answer.ambiguous or not answer.answer.strip() for answer in solved.answers):
        return "BLIND_SOLVE_REJECTED"
    proposed = dict(candidate.proposed_answers)
    if set(proposed) != expected:
        return "PROPOSED_ANSWERS_MISSING"

    questions_by_id = {q.question_id: q for q in candidate.content.questions} if candidate.content else {}
    for answer in solved.answers:
        qid = answer.question_id
        if qid not in proposed:
            continue
        q = questions_by_id.get(qid)
        q_type = q.question_type.value if q and hasattr(q.question_type, "value") else (str(q.question_type) if q else "")
        opts = [StudentVisibleOption(key=chr(65+i), text=str(opt)) for i, opt in enumerate(q.options)] if q and q.options else None
        comp = compare_answers(
            expected_answer=proposed[qid],
            solver_answer=answer.answer,
            question_type=q_type,
            options=opts,
        )
        if not comp.is_match:
            return "ANSWER_VERIFICATION_DISAGREEMENT"
    return None
