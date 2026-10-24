"""Canonical Reading Paper Policy Specifications and Code-Enforced Validators.

All invariants are enforced in code, never delegated to LLM prompt instructions.
"""

from __future__ import annotations

import re
from typing import List, Optional, Set

from .blueprint import QuestionType
from .issue import Issue, IssueCode, IssueScope, IssueSeverity
from .questions import (
    MultipleChoiceSingleQuestion,
    QuestionGroup,
    QuestionUnion,
    ReadingPaper,
    ReadingSection,
    SentenceCompletionQuestion,
    ShortAnswerQuestion,
    SummaryCompletionQuestion,
    TrueFalseAnswer,
    TrueFalseNotGivenQuestion,
    YesNoAnswer,
    YesNoNotGivenQuestion,
)

POLICY_VERSION = "1.0.0"

# Word count boundaries
PASSAGE_MIN_WORDS = 720
PASSAGE_MAX_WORDS = 915
PAPER_MIN_WORDS = 2150
PAPER_MAX_WORDS = 2750
MAX_ANSWER_WORDS = 3
MAX_SHINGLE_OVERLAP = 0.45

# Section & Question distributions
SECTION_QUESTION_COUNTS = {1: 13, 2: 13, 3: 14}
SECTION_GROUP_SIZES = {1: [7, 6], 2: [6, 7], 3: [7, 7]}
SECTION_GROUP_TYPES = {
    1: [QuestionType.TRUE_FALSE_NOT_GIVEN, QuestionType.SENTENCE_COMPLETION],
    2: [QuestionType.MULTIPLE_CHOICE_SINGLE, QuestionType.SUMMARY_COMPLETION],
    3: [QuestionType.YES_NO_NOT_GIVEN, QuestionType.SHORT_ANSWER],
}

WORD_REGEX = re.compile(r"\b[\w'-]+\b")


def count_words(text: str) -> int:
    """Standardized word count matching IELTS Academic baseline regex."""
    if not text:
        return 0
    return len(WORD_REGEX.findall(text))


def normalize_prompt(prompt: str) -> str:
    """Normalizes question prompt by stripping non-word characters and lowercasing."""
    return re.sub(r"\W+", "", prompt or "").lower()


def get_5word_shingles(text: str) -> Set[str]:
    """Generates 5-word overlapping shingles for plagiarism and redundancy checking."""
    words = [w.lower() for w in WORD_REGEX.findall(text or "")]
    if len(words) < 5:
        return set()
    return {" ".join(words[i : i + 5]) for i in range(len(words) - 4)}


def calculate_shingle_overlap(text1: str, text2: str) -> float:
    """Calculates Jaccard overlap of 5-word shingles: Intersect / Union."""
    s1 = get_5word_shingles(text1)
    s2 = get_5word_shingles(text2)
    if not s1 or not s2:
        return 0.0
    union = s1.union(s2)
    if not union:
        return 0.0
    return len(s1.intersection(s2)) / len(union)


def validate_answer_length(answer: str) -> bool:
    """Validates that completion or short answer is at most 3 words and/or 1 number."""
    words = WORD_REGEX.findall(answer or "")
    if not words or len(words) > MAX_ANSWER_WORDS:
        return False
    return True


# A hyphen or an apostrophe after a span continues the same token, so an answer
# ending in a word character must not match inside 'huntingtin-like' or "don'ts".
# This is the single source of truth for what continues a token: the boundary
# regexes and the "is this answer self-delimited?" test both read it.
_TOKEN_CONTINUATION = r"[\w'-]"

# What a trailing token-continuation character must NOT be. A successor word
# character is the only thing that can turn a span into a prefix of a longer
# word; punctuation and whitespace cannot.
_WORD_CHAR = r"\w"

_TOKEN_CONTINUATION_RE = re.compile(_TOKEN_CONTINUATION)


def match_verbatim_in_passage(answer: str, passage: str) -> bool:
    """Verifies that the answer appears as a full-token verbatim span in the passage.

    Rejects partial-word matches (e.g. 'rat' inside 'strata').

    The leading guard is always the full token-continuation class: nothing may
    precede the span that would make it the tail of a longer token. The
    trailing guard depends on the answer itself:

    * An answer ending in a token-continuation character (word character,
      apostrophe or hyphen) is not self-delimited, so the successor must not
      continue the token -- otherwise 'huntingtin' would match inside
      'huntingtin-like'.
    * An answer ending in punctuation (e.g. 'mutant huntingtin (mHTT)') is
      already delimited by its own final character. Only a successor word
      character could make it a prefix of a longer word, so demanding a
      non-continuation character here would reject a genuinely verbatim span
      every time the passage went on to hyphenate or inflect a compound
      ('(mHTT)-related', "(mHTT)'s").
    """
    if not answer or not passage:
        return False
    clean_ans = answer.strip()
    if not clean_ans:
        return False
    leading = rf"(?<!{_TOKEN_CONTINUATION})"
    body = re.escape(clean_ans)
    self_delimited = _TOKEN_CONTINUATION_RE.fullmatch(clean_ans[-1]) is None
    trailing = rf"(?!{_WORD_CHAR})" if self_delimited else rf"(?!{_TOKEN_CONTINUATION})"
    return bool(re.search(leading + body + trailing, passage, re.IGNORECASE))


def match_boundary_aware(needle: str, haystack: str) -> bool:
    """Matches a word or phrase in haystack ensuring token/word boundary awareness."""
    needle = needle.strip()
    haystack = haystack.strip()
    if not needle or not haystack:
        return False
    tokens = [re.escape(t) for t in needle.split()]
    if not tokens:
        return False
    inner = r"\s+".join(tokens)
    prefix = r"\b" if re.match(r"^\w", needle, flags=re.UNICODE) else r"(?:\s|^)"
    suffix = r"\b" if re.search(r"\w$", needle, flags=re.UNICODE) else r"(?:\s|$)"
    pattern = prefix + inner + suffix
    return bool(re.search(pattern, haystack, flags=re.IGNORECASE))


def validate_reading_section_policies(
    section: ReadingSection,
    section_index: int,
    expected_start_number: int,
) -> List[Issue]:
    """Validates structural policies for a single section."""
    issues: List[Issue] = []
    sec_id = section.section_id

    # 1. Passage word count policy
    actual_words = count_words(section.passage)
    if not (PASSAGE_MIN_WORDS <= actual_words <= PASSAGE_MAX_WORDS):
        issues.append(
            Issue.create(
                issue_id=f"iss_sec_{sec_id}_wc",
                code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.SECTION,
                message=f"Section {sec_id} passage word count {actual_words} is outside policy range [{PASSAGE_MIN_WORDS}, {PASSAGE_MAX_WORDS}]",
            )
        )

    # 2. Question count policy
    expected_count = SECTION_QUESTION_COUNTS.get(sec_id, 13)
    all_questions = [q for g in section.groups for q in g.questions]
    if len(all_questions) != expected_count:
        issues.append(
            Issue.create(
                issue_id=f"iss_sec_{sec_id}_qc",
                code=IssueCode.QUESTION_COUNT_MISMATCH,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.SECTION,
                message=f"Section {sec_id} has {len(all_questions)} questions; policy requires exactly {expected_count}",
            )
        )

    # 3. Question numbering policy
    current_num = expected_start_number
    for q in all_questions:
        if q.question_number != current_num:
            issues.append(
                Issue.create(
                    issue_id=f"iss_q_{q.question_number}_seq",
                    code=IssueCode.QUESTION_NUMBERING_INVALID,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.QUESTION,
                    message=f"Question numbering out of sequence: expected {current_num}, found {q.question_number}",
                )
            )
        current_num += 1

    # 4. Group structure & question types
    expected_types = SECTION_GROUP_TYPES.get(sec_id, [])
    expected_sizes = SECTION_GROUP_SIZES.get(sec_id, [])
    if len(section.groups) != len(expected_types):
        issues.append(
            Issue.create(
                issue_id=f"iss_sec_{sec_id}_groups",
                code=IssueCode.SCHEMA_VIOLATION,
                severity=IssueSeverity.MAJOR,
                scope=IssueScope.SECTION,
                message=f"Section {sec_id} has {len(section.groups)} groups; expected {len(expected_types)}",
            )
        )
    else:
        for idx, (grp, exp_type, exp_size) in enumerate(zip(section.groups, expected_types, expected_sizes)):
            if grp.question_type != exp_type:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_grp_{sec_id}_{idx}_type",
                        code=IssueCode.SCHEMA_VIOLATION,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION_GROUP,
                        message=f"Section {sec_id} Group {idx+1} type is {grp.question_type.value}; expected {exp_type.value}",
                    )
                )
            if len(grp.questions) != exp_size:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_grp_{sec_id}_{idx}_size",
                        code=IssueCode.QUESTION_COUNT_MISMATCH,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION_GROUP,
                        message=f"Section {sec_id} Group {idx+1} has {len(grp.questions)} questions; expected {exp_size}",
                    )
                )

    # 5. Question content validation against passage
    for q in all_questions:
        if isinstance(q, (SentenceCompletionQuestion, SummaryCompletionQuestion, ShortAnswerQuestion)):
            # Answer length
            if not validate_answer_length(q.answer):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_q_{q.question_number}_len",
                        code=IssueCode.WORD_LIMIT_EXCEEDED,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q.question_number} answer '{q.answer}' exceeds limit of {MAX_ANSWER_WORDS} words",
                    )
                )
            # Answer must appear as full verbatim token span in passage
            if not match_verbatim_in_passage(q.answer, section.passage):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_q_{q.question_number}_verbatim",
                        code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q.question_number} answer '{q.answer}' does not appear verbatim in passage (partial-word matches rejected)",
                    )
                )

        if isinstance(q, (TrueFalseNotGivenQuestion, YesNoNotGivenQuestion)):
            is_not_given = q.answer in (TrueFalseAnswer.NOT_GIVEN, YesNoAnswer.NOT_GIVEN)
            if is_not_given:
                # NOT_GIVEN must have confirmed AbsenceAssessment and no evidenceQuote
                if q.absence_assessment is None or not q.absence_assessment.absence_confirmed:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_q_{q.question_number}_absence",
                            code=IssueCode.EVIDENCE_MISSING,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q.question_number} is NOT_GIVEN but lacks confirmed absenceAssessment",
                        )
                    )
                if q.evidence_quote is not None:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_q_{q.question_number}_spurious_quote",
                            code=IssueCode.SCHEMA_VIOLATION,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q.question_number} is NOT_GIVEN but contains spurious evidenceQuote",
                        )
                    )
            else:
                # TRUE / FALSE / YES / NO must have evidenceQuote found verbatim in passage
                if not q.evidence_quote or not match_verbatim_in_passage(q.evidence_quote, section.passage):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_q_{q.question_number}_quote",
                            code=IssueCode.EVIDENCE_MISSING,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q.question_number} evidence quote not found in passage",
                        )
                    )
                if q.absence_assessment is not None:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_q_{q.question_number}_spurious_absence",
                            code=IssueCode.SCHEMA_VIOLATION,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q.question_number} is {q.answer.value} but contains spurious absenceAssessment",
                        )
                    )

    return issues


def validate_reading_paper_policies(paper: ReadingPaper) -> List[Issue]:
    """Validates complete Reading Paper policies."""
    issues: List[Issue] = []

    # 1. Total sections & questions check
    total_sections = len(paper.sections)
    if total_sections == 3:
        if paper.total_questions != 40:
            issues.append(
                Issue.create(
                    issue_id="iss_paper_qc",
                    code=IssueCode.QUESTION_COUNT_MISMATCH,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Full paper total questions is {paper.total_questions}; expected 40",
                )
            )
        total_words = sum(count_words(sec.passage) for sec in paper.sections)
        if not (PAPER_MIN_WORDS <= total_words <= PAPER_MAX_WORDS):
            issues.append(
                Issue.create(
                    issue_id="iss_paper_wc",
                    code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                    severity=IssueSeverity.CRITICAL,
                    scope=IssueScope.PAPER,
                    message=f"Full paper total word count {total_words} is outside policy range [{PAPER_MIN_WORDS}, {PAPER_MAX_WORDS}]",
                )
            )

    # 2. Check each section policies
    current_q_num = 1
    for sec_idx, section in enumerate(paper.sections):
        sec_issues = validate_reading_section_policies(section, sec_idx + 1, current_q_num)
        issues.extend(sec_issues)
        current_q_num += sum(len(g.questions) for g in section.groups)

    # 3. Anti-duplication: Question prompt uniqueness across whole paper
    seen_prompts: dict[str, int] = {}
    for section in paper.sections:
        for group in section.groups:
            for q in group.questions:
                prompt_text = ""
                if isinstance(q, (TrueFalseNotGivenQuestion, YesNoNotGivenQuestion)):
                    prompt_text = q.statement
                elif isinstance(q, (MultipleChoiceSingleQuestion, SentenceCompletionQuestion, SummaryCompletionQuestion, ShortAnswerQuestion)):
                    prompt_text = q.prompt
                norm = normalize_prompt(prompt_text)
                if norm:
                    if norm in seen_prompts:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_q_{q.question_number}_dup",
                                code=IssueCode.DUPLICATE_CONTENT,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"Question {q.question_number} has duplicate prompt with Question {seen_prompts[norm]}",
                            )
                        )
                    else:
                        seen_prompts[norm] = q.question_number

    # 4. Anti-duplication: Shingle overlap across passages
    for i in range(len(paper.sections)):
        for j in range(i + 1, len(paper.sections)):
            overlap = calculate_shingle_overlap(paper.sections[i].passage, paper.sections[j].passage)
            if overlap > MAX_SHINGLE_OVERLAP:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_overlap_{paper.sections[i].section_id}_{paper.sections[j].section_id}",
                        code=IssueCode.DUPLICATE_CONTENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.PAPER,
                        message=f"Passage {paper.sections[i].section_id} and Passage {paper.sections[j].section_id} have shingle overlap {overlap:.3f} > {MAX_SHINGLE_OVERLAP}",
                    )
                )

    return issues
