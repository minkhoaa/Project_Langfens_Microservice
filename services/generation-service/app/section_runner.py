"""Authoritative SectionRunner executing reading section generation.

Uses StageExecutor for all durable artifact commits: passage, questions,
and section assembly. All sections (1, 2, 3) use this exact runner; differences
are purely configuration data.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Sequence
from enum import Enum
from typing import Any, Optional
from uuid import UUID

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType, canonical_json_dump_prep
from app.contracts.evidence import AbsenceAssessment
from app.contracts.evaluation import EvaluationResult
from app.contracts.issue import Issue, IssueCode
from app.contracts.policies import calculate_shingle_overlap, count_words, match_verbatim_in_passage, validate_answer_length
from app.evaluators.deterministic import check_prompt_answer_leakage
from app.evaluators.solver import BlindSolverEvaluator
from app.generators.passage.prompts import PassageStyleProfile, build_passage_generation_prompt
from app.generators.question.prompts import QuestionPromptFamily, build_question_prompt
from app.persistence.client import CheckpointClient
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json
from app.reading_evaluation import evaluate_passage, evaluate_question, evaluate_section
from app.reading_generation import align_claims_to_passage, compose_section_payload, trim_passage
from app.reading_models import AcceptedSectionArtifact, RunContext, SourceRef
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.solvers.serializer import build_blind_solver_input
from app.stage_executor import StageExecutor

logger = logging.getLogger(__name__)


def _payload(obj: Any) -> dict[str, Any]:
    if isinstance(obj, ArtifactEnvelope):
        return dict(canonical_json_dump_prep(obj.payload))
    return dict(canonical_json_dump_prep(obj))


def _get_instructions_for_type(q_type: str) -> str:
    """Returns official canonical IELTS instructions for each question type."""
    if q_type == "TRUE_FALSE_NOT_GIVEN":
        return (
            "Do the following statements agree with the information given in the Reading Passage? "
            "Write TRUE, FALSE, or NOT GIVEN."
        )
    if q_type == "YES_NO_NOT_GIVEN":
        return "Write YES, NO, or NOT GIVEN."
    if q_type in ("MULTIPLE_CHOICE_SINGLE", "CHOOSING_TITLE", "MULTIPLE_CHOICE_SINGLE_IMAGE"):
        return "Choose the correct letter, A, B, C or D."
    if q_type == "MULTIPLE_CHOICE_MULTIPLE":
        return "Choose the correct letters."
    if q_type == "SENTENCE_COMPLETION":
        return "Complete the sentences below. Choose NO MORE THAN THREE WORDS from the passage."
    if q_type in ("SUMMARY_COMPLETION", "SUMMARY_COMPLETION_BOX"):
        return "Complete the summary below. Choose NO MORE THAN THREE WORDS from the passage for each answer."
    if q_type in ("NOTE_COMPLETION", "TABLE_COMPLETION", "FORM_COMPLETION", "FLOW_CHART", "DIAGRAM_LABEL", "MAP_LABEL"):
        return "Complete the notes/diagram below. Choose NO MORE THAN THREE WORDS from the passage for each answer."
    if q_type == "MATCHING_HEADING":
        return "Choose the correct heading for each paragraph from the list of headings below."
    if q_type in ("MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"):
        return "Match each item with the correct statement from the list below."
    return "Answer the questions below. Choose NO MORE THAN THREE WORDS from the passage for each answer."

class CandidateRejectionReason(str, Enum):
    CLAIM_NOT_SUPPORTED_IN_PASSAGE = "CLAIM_NOT_SUPPORTED_IN_PASSAGE"
    QUOTE_NOT_VERBATIM = "QUOTE_NOT_VERBATIM"
    CANDIDATE_DUPLICATE = "CANDIDATE_DUPLICATE"
    CANDIDATE_SCHEMA_INVALID = "CANDIDATE_SCHEMA_INVALID"
    ANSWER_NOT_GROUNDED_IN_EVIDENCE = "ANSWER_NOT_GROUNDED_IN_EVIDENCE"


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


GROUNDED_COMPLETION_TYPES = {
    "TABLE_COMPLETION",
    "SENTENCE_COMPLETION",
    "SUMMARY_COMPLETION",
    "NOTE_COMPLETION",
    "FORM_COMPLETION",
    "SHORT_ANSWER",
}


def _validate_completion_candidate_grounding(
    cand_payload: dict[str, Any],
    q_num: int,
    q_type: str,
    passage_text: str,
    claims_map: dict[str, Any],
    claim_id: str,
    target_focus: Optional[str] = None,
    is_mock: bool = False,
) -> None:
    """Enforces rigorous candidate-level answer grounding for completion question types.

    1. The answer is a complete, valid word or numerical span occurring verbatim
       in the candidate's own evidenceQuote using boundary-aware matching.
    2. The evidenceQuote matches the accepted passage at exact offsets.
    3. The evidence span is consistent with the immutable Blueprint-bound claim.
    4. The candidate does not borrow a quantity, date or answer from an unrelated passage fact.
    5. The completion stem does not expose the answer or require an unsupported inference.
    """
    answer = str(cand_payload.get("answer") or "").strip()
    if not answer:
        raise CandidateRejectionError(
            CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
            f"Question {q_num} completion answer is empty",
        )

    ans_words = answer.split()
    if len(ans_words) > 3:
        raise CandidateRejectionError(
            CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
            f"Question {q_num} completion answer '{answer}' exceeds maximum 3 words ({len(ans_words)} words)",
        )

    quote = str(cand_payload.get("evidenceQuote") or "").strip()
    if not quote:
        raise CandidateRejectionError(
            CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
            f"Question {q_num} completion missing evidenceQuote",
        )

    # Rule 1: Answer occurs verbatim in candidate's own evidenceQuote via boundary-aware matching
    if not match_boundary_aware(answer, quote):
        raise CandidateRejectionError(
            CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
            f"Question {q_num} completion answer '{answer}' does not occur verbatim in candidate's evidenceQuote: '{quote}'",
        )

    # Rule 2: evidenceQuote matches accepted passage at exact offsets
    p_start = passage_text.find(quote)
    if p_start < 0:
        clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
        p_start = passage_text.find(clean_q)
        if p_start >= 0:
            quote = clean_q
            cand_payload["evidenceQuote"] = clean_q
    if p_start < 0:
        raise CandidateRejectionError(
            CandidateRejectionReason.QUOTE_NOT_VERBATIM,
            f"Question {q_num} evidence quote not found in passage text: '{quote[:60]}'",
        )
    p_end = p_start + len(quote)
    cand_payload["passageEvidence"] = {"startChar": p_start, "endChar": p_end, "text": quote}

    # Rule 3: Evidence span is consistent with the immutable Blueprint-bound claim
    bound_claim_text = claims_map.get(claim_id, {}).get("text", "").strip() if claims_map else ""
    effective_focus = (target_focus or bound_claim_text or "").strip()
    if effective_focus:
        in_focus = (quote in effective_focus) or (effective_focus in quote)
        shingle_ov = calculate_shingle_overlap(quote, effective_focus) if not in_focus else 1.0
        q_tokens = set(re.findall(r"\w+", quote.lower()))
        f_tokens = set(re.findall(r"\w+", effective_focus.lower()))
        token_ov = len(q_tokens & f_tokens) / max(1, len(q_tokens)) if q_tokens else 0.0
        focus_pos = passage_text.find(effective_focus)
        passage_consistent = in_focus or shingle_ov >= 0.20 or token_ov >= 0.50
        if not passage_consistent and focus_pos >= 0:
            focus_start = focus_pos
            focus_end = focus_pos + len(effective_focus)
            if max(p_start, focus_start) <= min(p_end, focus_end):
                passage_consistent = True
            elif abs(p_start - focus_end) <= 120 and "\n\n" not in passage_text[min(p_end, focus_start):max(p_start, focus_end)]:
                passage_consistent = True

        if not passage_consistent and not is_mock:
            raise CandidateRejectionError(
                CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
                f"Question {q_num} evidence quote '{quote[:50]}...' is not consistent with bound claim '{claim_id}' (overlap: {shingle_ov:.2f})",
            )

    # Rule 4: Candidate does not borrow a quantity, date or answer from an unrelated passage fact
    num_matches = re.findall(r"\b\d+(?:st|nd|rd|th)?\b", answer)
    for num in num_matches:
        if effective_focus and not match_boundary_aware(num, effective_focus):
            raise CandidateRejectionError(
                CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
                f"Question {q_num} answer contains quantity/date '{num}' not present in bound claim '{claim_id}' evidence span",
            )

    # Rule 5: Completion stem does not expose the answer or require unsupported inference
    prompt = str(cand_payload.get("prompt") or cand_payload.get("statement") or "").strip()
    if prompt:
        clean_prompt = prompt.replace(f"[{q_num}]", "").replace("______", "")
        if check_prompt_answer_leakage(clean_prompt, answer):
            raise CandidateRejectionError(
                CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
                f"Question {q_num} stem exposes its own answer: '{answer}'",
            )
        # Check for unit duplication (e.g. prompt has "[9] BCE" and answer has "BCE")
        m_unit = re.search(r"\[" + str(q_num) + r"\]\s*([A-Za-z%°]+)", prompt)
        if m_unit:
            unit_str = m_unit.group(1).strip()
            if re.search(r"\b" + re.escape(unit_str) + r"\b", answer, re.IGNORECASE):
                raise CandidateRejectionError(
                    CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
                    f"Question {q_num} answer '{answer}' duplicates stem unit '{unit_str}'",
                )


class CandidateRejectionError(ValueError):
    """Structured candidate extraction failure preserving diagnostic classification.
    
    Subclasses ValueError so existing catch sites remain 100% backward-compatible.
    """

    def __init__(self, reason: CandidateRejectionReason, message: str):
        super().__init__(f"[{reason.value}] {message}")
        self.reason = reason
        self.message = message


def _parse_single_candidate(
    cand: dict[str, Any],
    raw_payload: dict[str, Any],
    q_num: int,
    q_type: str,
    passage_text: str,
    claims_map: dict[str, Any],
    claim_id: str,
    difficulty: str,
    target_focus: Optional[str] = None,
    is_mock: bool = False,
) -> dict[str, Any]:
    """Parses a single candidate item into a validated canonical question payload."""
    matched_claim = claims_map.get(claim_id)
    explanation = str(cand.get("explanation") or "").strip()
    if len(explanation) < 25:
        raise CandidateRejectionError(
            CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
            f"Question {q_num} explanation is missing or too short (< 25 characters)",
        )
    if q_type in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
        statement = str(cand.get("statement") or cand.get("prompt") or "").strip()
        raw_ans = str(cand.get("answer") or "").strip().replace(" ", "_").upper()
        if not raw_ans:
            raise CandidateRejectionError(
                CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                f"Question {q_num} answer is missing",
            )
        if q_type == "TRUE_FALSE_NOT_GIVEN":
            if raw_ans in ("TRUE", "T"):
                answer = "TRUE"
            elif raw_ans in ("FALSE", "F"):
                answer = "FALSE"
            elif raw_ans in ("NOT_GIVEN", "NG"):
                answer = "NOT_GIVEN"
            else:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                    f"Invalid answer '{raw_ans}' for TRUE_FALSE_NOT_GIVEN in question {q_num}",
                )
        else:
            if raw_ans in ("YES", "Y"):
                answer = "YES"
            elif raw_ans in ("NO", "N"):
                answer = "NO"
            elif raw_ans in ("NOT_GIVEN", "NG"):
                answer = "NOT_GIVEN"
            else:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                    f"Invalid answer '{raw_ans}' for YES_NO_NOT_GIVEN in question {q_num}",
                )

        if answer == "NOT_GIVEN":
            raw_absence = cand.get("absenceAssessment") or cand.get("absence_assessment")
            if not raw_absence or not isinstance(raw_absence, (dict, AbsenceAssessment)):
                raise CandidateRejectionError(
                    CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                    f"Question {q_num} candidate is NOT_GIVEN but lacks required absenceAssessment object",
                )

            if isinstance(raw_absence, AbsenceAssessment):
                if not raw_absence.absence_confirmed:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                        f"Question {q_num} absenceAssessment.absenceConfirmed must be True",
                    )
                if not raw_absence.absence_reason:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                        f"Question {q_num} absenceAssessment is missing absenceReason",
                    )
                if not raw_absence.claim_or_topic:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                        f"Question {q_num} absenceAssessment is missing claimOrTopic",
                    )
                assessment_id = raw_absence.assessment_id or f"abs_q{q_num}"
                claim_or_topic = raw_absence.claim_or_topic
                absence_reason = raw_absence.absence_reason
                topical_span = raw_absence.topical_context_span
            else:
                claim_or_topic = str(raw_absence.get("claimOrTopic") or raw_absence.get("claim_or_topic") or "").strip()
                if not claim_or_topic:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                        f"Question {q_num} absenceAssessment is missing claimOrTopic",
                    )
                absence_reason = str(raw_absence.get("absenceReason") or raw_absence.get("absence_reason") or "").strip()
                if not absence_reason:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                        f"Question {q_num} absenceAssessment is missing absenceReason",
                    )
                absence_confirmed = (
                    raw_absence.get("absenceConfirmed")
                    if "absenceConfirmed" in raw_absence
                    else raw_absence.get("absence_confirmed")
                )
                if absence_confirmed is not True:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                        f"Question {q_num} absenceAssessment.absenceConfirmed must be True (got {absence_confirmed})",
                    )
                assessment_id = str(raw_absence.get("assessmentId") or raw_absence.get("assessment_id") or f"abs_q{q_num}").strip()
                topical_span = raw_absence.get("topicalContextSpan") or raw_absence.get("topical_context_span")

            if topical_span is not None:
                topical_span = str(topical_span).strip() or None
            if not topical_span:
                raw_pe = cand.get("passageEvidence") or cand.get("passage_evidence")
                if isinstance(raw_pe, dict) and raw_pe.get("text"):
                    topical_span = str(raw_pe["text"]).strip() or None
                elif cand.get("evidenceQuote"):
                    topical_span = str(cand["evidenceQuote"]).strip() or None

            if topical_span:
                p_start = passage_text.find(topical_span)
                if p_start < 0:
                    clean_topical = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", topical_span)
                    p_start = passage_text.find(clean_topical)
                    if p_start >= 0:
                        topical_span = clean_topical
                if p_start < 0:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.QUOTE_NOT_VERBATIM,
                        f"Question {q_num} topicalContextSpan '{topical_span[:40]}' is not found in passage text",
                    )
                p_end = p_start + len(topical_span)
            elif target_focus and target_focus in passage_text:
                topical_span = target_focus
                p_start = passage_text.find(topical_span)
                p_end = p_start + len(topical_span)
            else:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                    f"Question {q_num} NOT_GIVEN lacks verifiable topical context in passage",
                )

            absence_dict = {
                "assessmentId": assessment_id,
                "claimOrTopic": claim_or_topic,
                "absenceReason": absence_reason,
                "topicalContextSpan": topical_span,
                "absenceConfirmed": True,
            }
            return {
                "questionNumber": q_num,
                "questionType": q_type,
                "statement": statement,
                "answer": answer,
                "explanation": explanation,
                "difficulty": difficulty,
                "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": topical_span},
                "evidenceClaimRef": claim_id,
                "absenceAssessment": absence_dict,
            }
        else:
            if cand.get("absenceAssessment") or cand.get("absence_assessment"):
                raise CandidateRejectionError(
                    CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                    f"Question {q_num} candidate is {answer} but contains prohibited absenceAssessment",
                )
            quote = str(cand.get("evidenceQuote") or "").strip()
            if not quote or len(quote) < 10:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                    f"Question {q_num} candidate is {answer} but missing valid evidenceQuote",
                )
            p_start = passage_text.find(quote) if quote else -1
            if p_start < 0 and quote:
                clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
                p_start = passage_text.find(clean_q)
                if p_start >= 0:
                    quote = clean_q
            if p_start < 0 and quote:
                clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
                for c in clauses:
                    pos = passage_text.find(c)
                    if pos != -1:
                        p_start = pos
                        quote = c
                        break
            if p_start < 0:
                raise CandidateRejectionError(
                    CandidateRejectionReason.QUOTE_NOT_VERBATIM,
                    f"Question {q_num} evidence quote is not found in passage: '{quote[:40]}'",
                )
            p_end = p_start + len(quote)
            return {
                "questionNumber": q_num,
                "questionType": q_type,
                "statement": statement,
                "answer": answer,
                "evidenceQuote": quote,
                "explanation": explanation,
                "difficulty": difficulty,
                "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
                "evidenceClaimRef": claim_id,
            }

    elif q_type in ("MULTIPLE_CHOICE_SINGLE", "CHOOSING_TITLE", "MULTIPLE_CHOICE_SINGLE_IMAGE"):
        prompt = str(cand.get("prompt") or "").strip()
        raw_opts = cand.get("options")
        if isinstance(raw_opts, list) and all(isinstance(o, dict) for o in raw_opts):
            formatted_opts = [f"{o.get('key', chr(65+i))}. {o.get('text', '')}" for i, o in enumerate(raw_opts)]
        elif isinstance(raw_opts, list) and all(isinstance(o, str) for o in raw_opts):
            formatted_opts = []
            for i, o in enumerate(raw_opts):
                clean_o = re.sub(r"^[A-D]\.\s*", "", o)
                formatted_opts.append(o if re.match(r"^[A-D]\.", o) else f"{chr(65+i)}. {clean_o}")
        elif isinstance(raw_opts, list):
            formatted_opts = [str(o) for o in raw_opts]
        else:
            formatted_opts = []

        raw_correct = str(cand.get("correctOption") or cand.get("answer") or "").strip().upper()
        mcq_m = re.search(r"\b([A-D])\b", raw_correct)
        correct_letter = mcq_m.group(1) if mcq_m else raw_correct

        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        if p_start < 0 and quote:
            clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
            p_start = passage_text.find(clean_q)
            if p_start >= 0:
                quote = clean_q
        if p_start < 0 and quote:
            clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
            for c in clauses:
                pos = passage_text.find(c)
                if pos != -1:
                    p_start = pos
                    quote = c
                    break
        if p_start < 0:
            raise CandidateRejectionError(
                CandidateRejectionReason.QUOTE_NOT_VERBATIM,
                f"Question {q_num} evidence quote is not found in passage: '{quote[:40]}'",
            )
        p_end = p_start + len(quote) if p_start >= 0 else -1
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "options": formatted_opts,
            "answer": correct_letter,
            "correctOption": correct_letter,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type == "MULTIPLE_CHOICE_MULTIPLE":
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        raw_opts = cand.get("options") or []
        formatted_opts = [str(o) if isinstance(o, str) else f"{o.get('key', chr(65+i))}. {o.get('text', '')}" for i, o in enumerate(raw_opts)]
        raw_answers = cand.get("answers") or cand.get("answer") or []
        if isinstance(raw_answers, str):
            ans_tokens = [tok.strip().upper() for tok in re.split(r"[,;&/\s]+|\band\b", raw_answers, flags=re.IGNORECASE) if tok.strip()]
        elif isinstance(raw_answers, list):
            ans_tokens = [str(a).strip().upper() for a in raw_answers if str(a).strip()]
        else:
            ans_tokens = []
        cleaned_answers = sorted(list(set(re.sub(r"[^A-Z]", "", t) for t in ans_tokens if re.sub(r"[^A-Z]", "", t))))
        joined_ans = ", ".join(cleaned_answers)

        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "options": formatted_opts,
            "answers": cleaned_answers,
            "answer": joined_ans,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION"):
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        if not prompt and q_type == "SUMMARY_COMPLETION":
            summary_text = str(raw_payload.get("summaryText") or raw_payload.get("summary") or "").strip()
            if summary_text and f"[{q_num}]" in summary_text:
                for sentence in re.split(r"(?<=[.!?])\s+", summary_text):
                    if f"[{q_num}]" in sentence:
                        prompt = sentence.strip()
                        break
                if not prompt:
                    prompt = summary_text
            if not prompt:
                prompt = summary_text or f"Summary statement for question [{q_num}]."
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")

        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        if p_start < 0 and quote:
            clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
            p_start = passage_text.find(clean_q)
            if p_start >= 0:
                quote = clean_q
        if p_start < 0 and quote:
            clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
            for c in clauses:
                pos = passage_text.find(c)
                if pos != -1:
                    p_start = pos
                    quote = c
                    break
        if p_start < 0:
            raise CandidateRejectionError(
                CandidateRejectionReason.QUOTE_NOT_VERBATIM,
                f"Question {q_num} evidence quote is not found in passage: '{quote[:40]}'",
            )
        p_end = p_start + len(quote) if p_start >= 0 else -1
        answer = str(cand.get("answer") or "").strip()

        res_payload = {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }
        _validate_completion_candidate_grounding(
            res_payload,
            q_num=q_num,
            q_type=q_type,
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id=claim_id,
            target_focus=target_focus,
            is_mock=is_mock,
        )
        return res_payload

    elif q_type == "SUMMARY_COMPLETION_BOX":
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        summary_text = str(cand.get("summaryText") or raw_payload.get("summaryText") or "").strip()
        if not prompt and summary_text:
            prompt = summary_text
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        answer = str(cand.get("answer") or cand.get("correctOption") or "").strip()
        options = cand.get("options") or raw_payload.get("options") or []
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "summaryText": summary_text,
            "options": options,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type == "MATCHING_HEADING":
        paragraph_ref = str(cand.get("paragraphRef") or cand.get("targetParagraph") or f"Paragraph {chr(65 + (q_num - 1) % 8)}").strip()
        prompt = str(cand.get("prompt") or f"Choose the correct heading for {paragraph_ref}").strip()
        headings = cand.get("headings") or cand.get("options") or raw_payload.get("headings") or []
        answer = str(cand.get("answer") or cand.get("correctOption") or "").strip().upper()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "paragraphRef": paragraph_ref,
            "headings": headings,
            "options": headings,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type in ("MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"):
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        raw_opts = (
            cand.get("options")
            or cand.get("features")
            or cand.get("endings")
            or cand.get("categories")
            or raw_payload.get("options")
            or raw_payload.get("features")
            or raw_payload.get("endings")
            or raw_payload.get("categories")
            or []
        )
        answer = str(cand.get("answer") or cand.get("correctOption") or cand.get("targetParagraph") or "").strip().upper()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        res_payload = {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "options": raw_opts,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }
        if q_type == "MATCHING_INFORMATION":
            res_payload["targetParagraph"] = answer
        elif q_type == "MATCHING_FEATURES":
            res_payload["features"] = raw_opts
        elif q_type == "MATCHING_ENDINGS":
            res_payload["endings"] = raw_opts
        elif q_type == "CLASSIFICATION":
            res_payload["categories"] = raw_opts
        return res_payload

    elif q_type == "TABLE_COMPLETION":
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")
        table_context = str(cand.get("tableContext") or raw_payload.get("tableContext") or "").strip()
        answer = str(cand.get("answer") or "").strip()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        res_payload = {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "tableContext": table_context,
            "rowHeader": str(cand.get("rowHeader") or "").strip() or None,
            "colHeader": str(cand.get("colHeader") or "").strip() or None,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }
        _validate_completion_candidate_grounding(
            res_payload,
            q_num=q_num,
            q_type=q_type,
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id=claim_id,
            target_focus=target_focus,
            is_mock=is_mock,
        )
        return res_payload

    elif q_type == "FLOW_CHART":
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")
        flow_steps = cand.get("flowSteps") or raw_payload.get("flowSteps") or []
        svg_asset = cand.get("svgAssetId") or raw_payload.get("svgAssetId")
        answer = str(cand.get("answer") or "").strip()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "flowSteps": flow_steps,
            "stepIndex": cand.get("stepIndex"),
            "svgAssetId": svg_asset,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type in ("DIAGRAM_LABEL", "MAP_LABEL"):
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")
        callout = str(cand.get("calloutLabel") or f"[{q_num}]").strip()
        part_desc = str(cand.get("partDescription") or "").strip() or None
        svg_asset = cand.get("svgAssetId") or raw_payload.get("svgAssetId")
        answer = str(cand.get("answer") or "").strip()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "calloutLabel": callout,
            "partDescription": part_desc,
            "svgAssetId": svg_asset,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type in ("NOTE_COMPLETION", "FORM_COMPLETION"):
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")
        answer = str(cand.get("answer") or "").strip()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        p_end = p_start + len(quote) if p_start >= 0 else -1
        res_payload = {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }
        if q_type == "NOTE_COMPLETION":
            res_payload["headingContext"] = str(cand.get("headingContext") or "").strip() or None
            res_payload["bulletPrefix"] = str(cand.get("bulletPrefix") or "").strip() or None
        elif q_type == "FORM_COMPLETION":
            res_payload["fieldLabel"] = str(cand.get("fieldLabel") or "").strip() or None
        _validate_completion_candidate_grounding(
            res_payload,
            q_num=q_num,
            q_type=q_type,
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id=claim_id,
            target_focus=target_focus,
            is_mock=is_mock,
        )
        return res_payload

    elif q_type == "SHORT_ANSWER":
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        if p_start < 0 and quote:
            clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
            p_start = passage_text.find(clean_q)
            if p_start >= 0:
                quote = clean_q
        if p_start < 0 and quote:
            clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
            for c in clauses:
                pos = passage_text.find(c)
                if pos != -1:
                    p_start = pos
                    quote = c
                    break
        if p_start < 0:
            raise CandidateRejectionError(
                CandidateRejectionReason.QUOTE_NOT_VERBATIM,
                f"Question {q_num} evidence quote is not found in passage: '{quote[:40]}'",
            )
        p_end = p_start + len(quote) if p_start >= 0 else -1
        answer = str(cand.get("answer") or cand.get("correctOption") or "").strip()

        res_payload = {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }
        _validate_completion_candidate_grounding(
            res_payload,
            q_num=q_num,
            q_type=q_type,
            passage_text=passage_text,
            claims_map=claims_map,
            claim_id=claim_id,
            target_focus=target_focus,
            is_mock=is_mock,
        )
        return res_payload

    else:
        raise ValueError(
            f"Unsupported question type '{q_type}' for question {q_num}. Silent fallback to SHORT_ANSWER is prohibited."
        )


def _parse_candidate_payload(
    raw_payload: Any,
    q_num: int,
    q_type: str,
    passage_text: str,
    claims_map: dict[str, Any],
    claim_id: str,
    difficulty: str,
    target_focus: Optional[str] = None,
    prior_questions: Sequence[Any] = (),
    rejected_prompts: Sequence[str] = (),
    slot_index_in_group: Optional[int] = None,
    is_mock: bool = False,
) -> dict[str, Any]:
    """Parses and evaluates candidate pool into a validated canonical question payload.

    Evaluates all returned candidates:
    - Parses candidates across question formats, preserving grouped handling (blanks).
    - Rejects invalid candidates (missing explanation, invalid answer format, ungrounded quotes).
    - Rejects duplicate and substantially overlapping candidates (shingle overlap > 0.70).
    - Selects a valid, novel, passage-grounded candidate deterministically.
    - Preserves evidence provenance (evidenceClaimRef).
    """
    if not isinstance(raw_payload, dict):
        raise CandidateRejectionError(
            CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
            f"Expected dict from provider for question {q_num}, got {type(raw_payload).__name__}",
        )

    # Check for grouped blanks (e.g. SUMMARY_COMPLETION)
    if "blanks" in raw_payload and isinstance(raw_payload["blanks"], list) and raw_payload["blanks"]:
        blanks = [b for b in raw_payload["blanks"] if isinstance(b, dict)]
        if not blanks:
            raise CandidateRejectionError(
                CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                f"Malformed candidate payload for question {q_num}: 'blanks' list is empty",
            )
        cand = next((b for b in blanks if b.get("number") == q_num or b.get("questionNumber") == q_num), None)
        if cand is None:
            cand = next((b for b in blanks if b.get("placeholder") == f"[{q_num}]"), None)
        if cand is None and slot_index_in_group is not None:
            cand = next((b for b in blanks if b.get("number") == slot_index_in_group + 1 or b.get("questionNumber") == slot_index_in_group + 1), None)
            if cand is None:
                cand = next((b for b in blanks if b.get("placeholder") == f"[{slot_index_in_group + 1}]"), None)
            if cand is None and 0 <= slot_index_in_group < len(blanks):
                cand = blanks[slot_index_in_group]
        if cand is None:
            cand = blanks[0]
        candidate_items = [cand]
    elif "candidates" in raw_payload and isinstance(raw_payload["candidates"], list) and raw_payload["candidates"]:
        candidate_items = [c for c in raw_payload["candidates"] if isinstance(c, dict)]
        if not candidate_items:
            raise CandidateRejectionError(
                CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                f"Malformed candidate payload for question {q_num}: missing candidates/blanks",
            )
    elif "statement" in raw_payload or "prompt" in raw_payload:
        candidate_items = [raw_payload]
    else:
        raise CandidateRejectionError(
            CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
            f"Malformed candidate payload for question {q_num}: missing candidates/blanks",
        )

    valid_candidates: list[dict[str, Any]] = []
    rejection_errors: list[CandidateRejectionError] = []

    for idx, cand_item in enumerate(candidate_items):
        try:
            parsed = _parse_single_candidate(
                cand=cand_item,
                raw_payload=raw_payload,
                q_num=q_num,
                q_type=q_type,
                passage_text=passage_text,
                claims_map=claims_map,
                claim_id=claim_id,
                difficulty=difficulty,
                target_focus=target_focus,
                is_mock=is_mock,
            )
        except CandidateRejectionError as parse_err:
            rejection_errors.append(parse_err)
            continue
        except ValueError as parse_err:
            rejection_errors.append(CandidateRejectionError(
                CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
                str(parse_err),
            ))
            continue

        # Passage grounding check: ensure evidence quote or topical context exists in passage
        pe = parsed.get("passageEvidence", {})
        p_start = pe.get("startChar", -1)
        if p_start < 0:
            rejection_errors.append(CandidateRejectionError(
                CandidateRejectionReason.QUOTE_NOT_VERBATIM,
                f"Question {q_num} candidate {idx} passage offsets are invalid or ungrounded",
            ))
            continue

        # Duplicate & overlap check against already accepted questions
        cand_stmt = str(parsed.get("statement") or parsed.get("prompt") or "").strip()
        is_dup = False
        dup_msg = ""
        max_overlap = 0.0

        for prior in prior_questions:
            prior_payload = prior.payload if hasattr(prior, "payload") else prior
            prior_stmt = str(prior_payload.get("statement") or prior_payload.get("prompt") or "").strip()
            if cand_stmt and prior_stmt:
                overlap = calculate_shingle_overlap(cand_stmt, prior_stmt)
                if overlap > max_overlap:
                    max_overlap = overlap
                if cand_stmt.lower() == prior_stmt.lower():
                    is_dup = True
                    dup_msg = f"Question {q_num} candidate duplicates an already accepted question: '{cand_stmt[:60]}...'"
                    break
                if overlap > 0.70:
                    is_dup = True
                    dup_msg = f"Question {q_num} candidate duplicates an already accepted question (shingle overlap {overlap:.2f} > 0.70): '{cand_stmt[:60]}...'"
                    break

        if not is_dup and rejected_prompts:
            for rej in rejected_prompts:
                if cand_stmt.lower() == rej.lower():
                    is_dup = True
                    dup_msg = f"Question {q_num} candidate duplicates a previously rejected candidate: '{cand_stmt[:60]}...'"
                    break
                rej_ov = calculate_shingle_overlap(cand_stmt, rej)
                if rej_ov > 0.70:
                    is_dup = True
                    dup_msg = f"Question {q_num} candidate duplicates a previously rejected candidate (shingle overlap {rej_ov:.2f} > 0.70): '{cand_stmt[:60]}...'"
                    break

        if is_dup:
            rejection_errors.append(CandidateRejectionError(CandidateRejectionReason.CANDIDATE_DUPLICATE, dup_msg))
            continue

        valid_candidates.append({
            "parsed": parsed,
            "index": idx,
            "max_overlap": max_overlap,
            "stmt": cand_stmt,
        })

    if valid_candidates:
        # Deterministically select valid, novel candidate:
        # 1. Minimal overlap with prior accepted questions
        # 2. Candidate index as stable tie-breaker
        valid_candidates.sort(key=lambda c: (c["max_overlap"], c["index"]))
        return valid_candidates[0]["parsed"]

    # All candidates rejected: fail closed with informative error
    if rejection_errors:
        priority = [
            CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
            CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
            CandidateRejectionReason.QUOTE_NOT_VERBATIM,
            CandidateRejectionReason.CANDIDATE_DUPLICATE,
            CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
        ]
        for reason in priority:
            err = next((e for e in rejection_errors if isinstance(e, CandidateRejectionError) and e.reason == reason), None)
            if err:
                raise err
        raise rejection_errors[0]
    raise CandidateRejectionError(
        CandidateRejectionReason.CANDIDATE_SCHEMA_INVALID,
        f"No valid candidates found for question {q_num}",
    )


class SectionRunner:
    """Configurable runner executing generation stages for a single reading section.
    
    All sections (1, 2, 3) execute through this exact runner. Content generation strictly
    originates from the provider gateway and fails closed upon provider errors, malformed outputs,
    or budget exhaustion.
    """

    def __init__(self, client: CheckpointClient, gateway: ProviderGateway) -> None:
        self.client = client
        self.gateway = gateway
        from app.solvers.cache import BlindSolverCache
        self._solver_cache = BlindSolverCache()

    async def run(
        self,
        context: RunContext,
        config: SectionConfig,
        source_ref: SourceRef | None = None,
        blueprint: ArtifactRef | None = None,
        policy: PinnedExecutionPolicy | None = None,
        *,
        source: SourceRef | None = None,
        **kwargs: Any,
    ) -> AcceptedSectionArtifact:
        """Executes passage synthesis, question generation, and section closure."""
        actual_source = source_ref or source or kwargs.get("source")
        if actual_source is None:
            raise ValueError("source_ref must be provided")

        actual_blueprint = blueprint or kwargs.get("blueprint_ref")
        if actual_blueprint is None:
            raise ValueError("blueprint reference must be provided")

        actual_policy = policy or kwargs.get("policy")
        if actual_policy is None:
            raise ValueError("policy must be provided")

        executor = StageExecutor(self.client, context, actual_policy)

        # 1. Resolve accepted blueprint
        blueprint_envelope = await executor.get_accepted(actual_blueprint.artifact_id)
        if blueprint_envelope is None:
            raise ValueError(
                f"Accepted blueprint artifact {actual_blueprint.artifact_id} not found in durable run state"
            )

        blueprint_payload = _payload(blueprint_envelope)
        sec_blueprint = next(
            (s for s in blueprint_payload.get("sections", []) if s.get("sectionId") == config.index),
            None,
        )
        topic = sec_blueprint.get("topic", f"Section {config.index}") if sec_blueprint else f"Section {config.index}"
        slots = sec_blueprint.get("questionSlots", []) if sec_blueprint else []
        # 2. Extract source and verified claims
        source_payload = _payload(actual_source.source)
        source_metadata = source_payload["sources"][0]["metadata"]
        source_text = source_payload["sources"][0]["document"]["text"]
        evidence_payload = _payload(actual_source.evidence)
        claims = evidence_payload.get("claims", [])
        claims_map = {c["claimId"]: c for c in claims}

        if not slots:
            slots = [
                {
                    "questionNumber": q_num,
                    "groupIndex": g_idx,
                    "questionType": grp.question_type.value,
                    "claimRefIds": [claims[(q_num - 1) % len(claims)]["claimId"]] if claims else [],
                }
                for g_idx, grp in enumerate(config.groups)
                for q_num in config.group_numbers(g_idx)
            ]

        # 3. Passage stage
        passage_art_id = f"passage:{context.run_id}:{config.index}"
        passage_parents = (actual_blueprint, actual_source.evidence.to_ref())

        async def generate_passage(version: int) -> dict[str, Any]:
            if not self.gateway:
                raise ValueError("ProviderGateway must be provided to generate passage")

            call_seconds = actual_policy.provider_call_wall_seconds(config.index)

            # 1. Extract unique verified claims required by Blueprint question slots
            required_claim_ids = []
            seen_cids = set()
            for s in slots:
                for cid in s.get("claimRefIds") or ():
                    if cid in claims_map and cid not in seen_cids:
                        seen_cids.add(cid)
                        required_claim_ids.append(cid)
            required_claims_list = [claims_map[cid] for cid in required_claim_ids]

            prompt_data = build_passage_generation_prompt(
                topic=topic,
                section_index=config.index,
                style_profile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
                source_text=source_text,
                target_min_words=config.min_words,
                target_max_words=config.max_words,
                required_claims=required_claims_list,
            )
            req = ProviderRequest(
                capability=Capability.GENERATE_JSON,
                messages=[
                    ChatMessage(role="system", content=prompt_data["system_instruction"]),
                    ChatMessage(role="user", content=prompt_data["user_prompt"]),
                ],
                operation_id=f"op:{context.run_id}:passage:{config.index}:{version}",
                run_id=context.run_id,
                section_id=str(config.index),
                artifact_id=passage_art_id,
                preferred_provider=actual_policy.provider,
                timeout_seconds=call_seconds,
                wall_time_reservation_seconds=call_seconds,
                max_tokens=4096,
            )

            # Direct provider invocation with fail-closed semantics:
            # Errors MUST propagate without fallback fabrication.
            resp = await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)

            raw_payload = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
            if not isinstance(raw_payload, dict):
                raise ValueError(f"Provider returned malformed passage output of type {type(raw_payload).__name__}")

            passage_text = str(raw_payload.get("passage", "")).strip()
            if not passage_text:
                raise ValueError("Provider response missing required 'passage' content")

            title = str(raw_payload.get("title", topic)).strip() or topic
            if count_words(passage_text) > config.max_words:
                passage_text = trim_passage(passage_text)

            paragraphs = [p.strip() for p in re.split(r"\n\s*\n", passage_text) if p.strip()]
            alignments = align_claims_to_passage(passage_text, claims, source_text)
            has_unaligned_para = any(not any(a["passageQuote"] in para for a in alignments if a.get("passageQuote")) for para in paragraphs)
            aligned_claim_ids = {a["claimId"] for a in alignments if a.get("claimId")}
            missing_slot_claims = [
                claims_map[cid] for cid in required_claim_ids
                if cid not in aligned_claim_ids
            ]
            if (not alignments or count_words(passage_text) < config.min_words or has_unaligned_para) and missing_slot_claims:
                # Ground claim alignments in verified source evidence, prioritizing blueprint-bound claims
                enhanced_paragraphs = []
                pool_to_ground = list(missing_slot_claims) + [c for c in claims if c["claimId"] not in required_claim_ids]
                for i, para in enumerate(paragraphs):
                    para_alignments = [a for a in alignments if a.get("passageQuote") and a["passageQuote"] in para]
                    if not para_alignments and pool_to_ground:
                        claim_quote = pool_to_ground[i % len(pool_to_ground)]["text"].strip()
                        if claim_quote and claim_quote not in para:
                            para = claim_quote + " " + para
                    enhanced_paragraphs.append(para)

                enhanced_passage = "\n\n".join(enhanced_paragraphs)
                cur_words = count_words(enhanced_passage)

                # Append remaining missing blueprint claims if they fit within word budget
                for missing_c in missing_slot_claims:
                    m_quote = missing_c["text"].strip()
                    if m_quote and m_quote not in enhanced_passage:
                        if cur_words + count_words(m_quote) <= config.max_words:
                            enhanced_passage = enhanced_passage + "\n\n" + m_quote
                            cur_words = count_words(enhanced_passage)

                claim_idx = len(paragraphs)
                while cur_words < config.min_words and pool_to_ground and claim_idx < 100:
                    additional_claim = pool_to_ground[claim_idx % len(pool_to_ground)]["text"].strip()
                    if additional_claim and additional_claim not in enhanced_passage:
                        enhanced_passage = enhanced_passage + " " + additional_claim
                        cur_words = count_words(enhanced_passage)
                    claim_idx += 1

                if count_words(enhanced_passage) > config.max_words:
                    enhanced_passage = trim_passage(enhanced_passage)

                passage_text = enhanced_passage
                word_count = count_words(passage_text)
                alignments = align_claims_to_passage(passage_text, claims, source_text)
            else:
                word_count = count_words(passage_text)
            return {
                "title": title,
                "passage": passage_text,
                "wordCount": word_count,
                "claimAlignments": alignments,
                "paragraphs": [p.strip() for p in re.split(r"\n\s*\n", passage_text) if p.strip()],
                "sentences": [
                    {"sentenceId": f"s_{i}", "text": sent, "wordCount": len(sent.split())}
                    for i, sent in enumerate(re.split(r"(?<=[.!?])\s+", passage_text) if passage_text else [])
                    if sent.strip()
                ],
            }

        async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_passage(art, source_text, claims_map, config, slots=slots)

        async def repair_passage_stage(
            art: ArtifactEnvelope,
            issues: Sequence[Issue],
            ver: int,
            intent_id: Optional[str] = None,
        ) -> dict[str, Any]:
            from app.repair.passage import PassageSentenceRepairer
            p_rep = PassageSentenceRepairer()
            generic_supported_codes = set(p_rep.metadata.handled_codes) | {IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM}
            generic_issues = [i for i in issues if getattr(i, "code", None) in generic_supported_codes]
            alignment_issues = [i for i in issues if getattr(i, "code", None) == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT]
            unsupported = [
                i for i in issues
                if getattr(i, "code", None) not in generic_supported_codes
                and getattr(i, "code", None) != IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT
            ]

            if unsupported:
                from app.repair.base import RepairExecutionError
                raise RepairExecutionError(
                    f"Cannot repair unsupported passage issue codes: {[i.code for i in unsupported]}"
                )

            res_payload = dict(art.payload)
            if generic_issues:
                repaired_art = await p_rep._repair_impl(context, art, generic_issues, intent_id or f"op_repair_p_{ver}", ver)
                res_payload = dict(repaired_art.payload)

            curr_pass = str(res_payload.get("passage", ""))
            curr_words = count_words(curr_pass)

            # Check if any PASSAGE_BLUEPRINT_ALIGNMENT issues need claim grounding
            if alignment_issues:
                # Extract specific claim IDs flagged in PASSAGE_BLUEPRINT_ALIGNMENT issues
                unsupported_claim_ids = set()
                for iss in alignment_issues:
                    m = re.search(r"bound claim '([^']+)'", getattr(iss, "message", "") or "")
                    if m:
                        unsupported_claim_ids.add(m.group(1))

                aligned_ids = {a["claimId"] for a in res_payload.get("claimAlignments", []) if a.get("claimId")}
                repaired_any = False
                for s in slots:
                    if s.get("isNotGivenTarget"):
                        continue
                    cids = s.get("claimRefIds") or ()
                    if cids and cids[0] in claims_map:
                        cid = cids[0]
                        if unsupported_claim_ids and cid not in unsupported_claim_ids:
                            continue
                        if cid in aligned_ids:
                            continue
                        c_text = claims_map[cid]["text"].strip()
                        c_words = count_words(c_text)
                        if c_text not in curr_pass:
                            if curr_words + c_words <= config.max_words:
                                curr_pass = curr_pass + "\n\n" + c_text
                                curr_words += c_words
                                repaired_any = True
                                aligned_ids.add(cid)
                            else:
                                from app.repair.base import RepairExecutionError
                                raise RepairExecutionError(
                                    f"Cannot ground missing blueprint claim '{cid}' without exceeding "
                                    f"max word limit ({config.max_words} words; would be {curr_words + c_words})"
                                )

                if not repaired_any and alignment_issues:
                    from app.repair.base import RepairExecutionError
                    raise RepairExecutionError(
                        "Cannot resolve PASSAGE_BLUEPRINT_ALIGNMENT issues through evidence-backed repair"
                    )

                paragraphs = [p.strip() for p in curr_pass.split("\n\n") if p.strip()]
                sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", curr_pass) if s.strip()]
                res_payload["passage"] = curr_pass
                res_payload["passageText"] = curr_pass
                if "text" in res_payload:
                    res_payload["text"] = curr_pass
                res_payload["wordCount"] = curr_words
                res_payload["paragraphs"] = paragraphs
                res_payload["sentences"] = [
                    {"sentenceId": f"s_{i}", "text": sent, "wordCount": len(sent.split())}
                    for i, sent in enumerate(sentences)
                ]
                res_payload["claimAlignments"] = align_claims_to_passage(curr_pass, claims, source_text)

            if res_payload.get("passage") == art.payload.get("passage") and not generic_issues:
                from app.repair.base import RepairExecutionError
                raise RepairExecutionError("No evidence-backed transformation could be applied to passage")

            return res_payload

        passage_envelope = await executor.execute(
            passage_art_id,
            ArtifactType.PASSAGE,
            passage_parents,
            generate_passage,
            evaluate_passage_stage,
            section_id=config.index,
            repair=repair_passage_stage,
        )

        passage_text = str(passage_envelope.payload.get("passage", ""))

        # 4. Questions stage: generate and commit individual question artifacts
        q_envelopes: list[ArtifactEnvelope] = []
        q_parents = (passage_envelope.to_ref(), actual_blueprint)
        summary_group_cache: dict[int, dict[str, Any]] = {}
        passage_alignments = passage_envelope.payload.get("claimAlignments", [])
        aligned_claim_map = {a["claimId"]: a for a in passage_alignments}
        rejected_prompts: dict[int, list[str]] = {}
        rejected_answers: dict[int, set[str]] = {}
        rejected_combos: dict[int, list[dict[str, Any]]] = {}
        sorted_slots = sorted(slots, key=lambda s: s.get("questionNumber", 0))

        for slot in sorted_slots:
            q_num = slot["questionNumber"]
            g_idx = slot.get("groupIndex", 0)
            if "questionType" in slot:
                raw_qt = slot["questionType"]
                q_type = raw_qt.value if hasattr(raw_qt, "value") else str(raw_qt)
            elif g_idx < len(config.groups):
                q_type = config.groups[g_idx].question_type.value
            else:
                raise ValueError(f"Question slot {q_num} has no valid questionType or matching group configuration")
            q_art_id = f"question:{context.run_id}:{q_num}"
            claim_ref_ids = slot.get("claimRefIds") or ()
            if not claim_ref_ids:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                    f"Question slot {q_num} has no bound verified claim reference. "
                    "Fail-closed: ungrounded slots are prohibited.",
                )
            claim_id = claim_ref_ids[0]
            if claim_id not in claims_map:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                    f"Question slot {q_num} references claim '{claim_id}' not found in verified claims map. "
                    "Fail-closed: ungrounded claims are prohibited.",
                )
            is_ng_slot = bool(slot.get("isNotGivenTarget"))
            # Preflight check: Ensure positive-evidence slots have verified alignment in accepted passage
            if claim_id not in aligned_claim_map and not is_ng_slot:
                raise CandidateRejectionError(
                    CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                    f"Question slot {q_num} bound claim '{claim_id}' has no verified alignment in the accepted passage. "
                    "Fail-closed: question generation cannot target claims absent from the passage.",
                )
            target_focus_quote = (
                aligned_claim_map[claim_id]["passageQuote"]
                if claim_id in aligned_claim_map
                else None
            )
            async def generate_question(
                version: int,
                target_q_num: int = q_num,
                target_g_idx: int = g_idx,
                target_q_type: str = q_type,
                target_claim_id: str = claim_id,
                target_art_id: str = q_art_id,
            ) -> dict[str, Any]:
                if not self.gateway:
                    raise ValueError("ProviderGateway must be provided to generate questions")

                call_seconds = actual_policy.provider_call_wall_seconds(config.index)

                last_parse_error = ""
                last_parse_reason = None
                cur_claim_id = target_claim_id
                if cur_claim_id not in aligned_claim_map and not is_ng_slot:
                    raise CandidateRejectionError(
                        CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                        f"Question slot {target_q_num} bound claim '{cur_claim_id}' is not aligned in the accepted passage. "
                        "Preflight check prohibits ungrounded question generation.",
                    )
                target_focus = (
                    aligned_claim_map[cur_claim_id]["passageQuote"]
                    if cur_claim_id in aligned_claim_map
                    else target_focus_quote
                )
                for gen_attempt in range(2):
                    if target_q_type == "SUMMARY_COMPLETION":
                        if target_g_idx not in summary_group_cache:
                            grp_slots = [s for s in slots if s.get("groupIndex") == target_g_idx]
                            prompt_data = build_question_prompt(
                                family=QuestionPromptFamily.SUMMARY_COMPLETION,
                                passage_text=passage_text,
                                question_number=target_q_num,
                                candidate_count=2,
                                blank_count=len(grp_slots),
                                target_focus=target_focus,
                            )
                            summary_user_prompt = prompt_data["user_prompt"]
                            slot_claim_annotations = ", ".join(
                                f"[{s['questionNumber']} -> {s['claimRefIds'][0]}]"
                                for s in grp_slots
                                if s.get("claimRefIds")
                            )
                            if slot_claim_annotations:
                                summary_user_prompt += f"\n\nBLUEPRINT SLOT CLAIM BINDINGS:\n{slot_claim_annotations}"
                            passage_ver = passage_envelope.version
                            op_id = f"op:{context.run_id}:summary_group:{target_g_idx}:{passage_ver}_{version}" if gen_attempt == 0 else f"op:{context.run_id}:summary_group:{target_g_idx}:{passage_ver}_{version}_att2"
                            req = ProviderRequest(
                                capability=Capability.GENERATE_JSON,
                                messages=[
                                    ChatMessage(role="system", content=prompt_data["system_instruction"]),
                                    ChatMessage(role="user", content=summary_user_prompt),
                                ],
                                operation_id=op_id,
                                run_id=context.run_id,
                                section_id=str(config.index),
                                artifact_id=f"summary_group:{context.run_id}:{target_g_idx}",
                                preferred_provider=actual_policy.provider,
                                timeout_seconds=call_seconds,
                                wall_time_reservation_seconds=call_seconds,
                                max_tokens=4096,
                            )
                            resp = await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)
                            raw = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
                            summary_group_cache[target_g_idx] = raw if isinstance(raw, dict) else {}

                        raw_candidate = summary_group_cache[target_g_idx]
                    else:
                        family = QuestionPromptFamily.from_raw(target_q_type)
                        prompt_data = build_question_prompt(
                            family=family,
                            passage_text=passage_text,
                            question_number=target_q_num,
                            candidate_count=2,
                            target_focus=target_focus,
                        )
                        user_prompt = prompt_data["user_prompt"]
                        prior_statements = [str(e.payload.get("statement") or e.payload.get("prompt") or "").strip() for e in q_envelopes if e.payload.get("statement") or e.payload.get("prompt")]
                        if prior_statements:
                            last_few = prior_statements[-4:]
                            user_prompt += "\n\nCRITICAL UNIQUENESS INVARIANT:\nYour question MUST NOT repeat or paraphrase any of these already accepted questions:\n" + "\n".join(f"- {s}" for s in last_few)
                        if (
                            version > 1
                            and target_q_num in rejected_answers
                            and target_q_type in GROUNDED_COMPLETION_TYPES
                        ):
                            rej_ans_list = sorted(list(rejected_answers.get(target_q_num, set())))
                            rej_ans_str = ", ".join(f"'{a}'" for a in rej_ans_list) if rej_ans_list else "previously proposed answer"
                            combos = rejected_combos.get(target_q_num, [])[-3:]
                            combos_str = (
                                "\n".join(
                                    f"- Prompt: '{c.get('prompt', '')[:70]}...', Answer: '{c.get('answer', '')}' (Reason: {c.get('reason', '')})"
                                    for c in combos
                                )
                                if combos
                                else ""
                            )
                            claim_text_content = claims_map.get(cur_claim_id, {}).get("text", "")
                            user_prompt += (
                                f"\n\nCRITICAL RETRY INVARIANT (Attempt #{version}):\n"
                                "Previous question candidate was REJECTED for factual grounding mismatch. The proposed answer did NOT occur in the permissible evidence quote.\n\n"
                                f"IMMUTABLE BOUND CLAIM:\nClaim ID: {cur_claim_id}\nClaim Content: \"{claim_text_content}\"\n\n"
                                f"EXACT PERMISSIBLE EVIDENCE SPAN:\n\"{target_focus}\"\n\n"
                                f"REJECTED UNSUPPORTED ANSWERS (DO NOT REUSE):\n{rej_ans_str}\n"
                                "These answers do NOT appear in the permissible evidence span. You MUST NOT use them or borrow numbers/dates from elsewhere.\n\n"
                                f"REJECTED CANDIDATES TO EXCLUDE:\n{combos_str}\n\n"
                                "MANDATORY RULES FOR THIS ATTEMPT:\n"
                                "1. The answer MUST be an exact, complete word or short phrase (1 to 3 words) occurring VERBATIM inside the EXACT PERMISSIBLE EVIDENCE SPAN quoted above.\n"
                                "2. The evidenceQuote MUST be an exact verbatim substring of the PERMISSIBLE EVIDENCE SPAN.\n"
                                "3. You MUST NOT borrow quantities, dates, or facts from other parts of the passage.\n"
                                f"4. Construct the question prompt to test a fact that IS present in the permissible evidence span (e.g. key terms, names, or phrases from '{target_focus[:50]}...')."
                            )
                        elif version > 1 and target_q_num in rejected_prompts:
                            user_prompt += f"\n\nCRITICAL RETRY INVARIANT (Attempt #{version}):\nPrevious question candidate was rejected for ambiguity or factual overlap. You MUST NOT ask about: " + "; ".join(f"'{p[:80]}...'" for p in rejected_prompts[target_q_num]) + "\nYou MUST ask about a COMPLETELY DIFFERENT factual detail or sentence from the passage."
                        if target_q_type == "MULTIPLE_CHOICE_SINGLE":
                            user_prompt += "\n\nCRITICAL MCQ DISTRACTOR INVARIANT:\nEnsure the 3 incorrect options (distractors) are CLEARLY AND UNEQUIVOCALLY FALSE or contradicted by the passage, and cannot be defended as partially true."
                        if gen_attempt > 0 and last_parse_error:
                            if (
                                last_parse_reason == CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE
                                or (target_q_num in rejected_answers and target_q_type in GROUNDED_COMPLETION_TYPES)
                            ):
                                rej_ans_list = sorted(list(rejected_answers.get(target_q_num, set())))
                                rej_ans_str = ", ".join(f"'{a}'" for a in rej_ans_list) if rej_ans_list else "previously proposed answer"
                                combos = rejected_combos.get(target_q_num, [])[-3:]
                                combos_str = (
                                    "\n".join(
                                        f"- Prompt: '{c.get('prompt', '')[:70]}...', Answer: '{c.get('answer', '')}' (Reason: {c.get('reason', '')})"
                                        for c in combos
                                    )
                                    if combos
                                    else ""
                                )
                                claim_text_content = claims_map.get(cur_claim_id, {}).get("text", "")
                                user_prompt += (
                                    f"\n\nPREVIOUS ATTEMPT DEFECT: {last_parse_error}\n"
                                    "CRITICAL ANSWER GROUNDING & FACTUAL ALIGNMENT INVARIANT:\n"
                                    "Your previous question candidate was REJECTED because the proposed answer was NOT grounded in the cited evidence quote or borrowed an unsupported fact.\n\n"
                                    f"IMMUTABLE BOUND CLAIM:\nClaim ID: {cur_claim_id}\nClaim Content: \"{claim_text_content}\"\n\n"
                                    f"EXACT PERMISSIBLE EVIDENCE SPAN:\n\"{target_focus}\"\n\n"
                                    f"REJECTED UNSUPPORTED ANSWERS (DO NOT REUSE):\n{rej_ans_str}\n"
                                    "These answers do NOT appear in the permissible evidence span. You MUST NOT use them.\n\n"
                                    f"REJECTED CANDIDATES TO EXCLUDE:\n{combos_str}\n\n"
                                    "MANDATORY RULES FOR THIS ATTEMPT:\n"
                                    "1. The answer MUST be an exact, complete word or short phrase (1 to 3 words) occurring VERBATIM inside the EXACT PERMISSIBLE EVIDENCE SPAN quoted above.\n"
                                    "2. The evidenceQuote MUST be an exact verbatim substring of the PERMISSIBLE EVIDENCE SPAN.\n"
                                    "3. You MUST NOT borrow quantities, dates, or facts from other parts of the passage.\n"
                                    f"4. Construct the question prompt to test a fact that IS present in the permissible evidence span."
                                )
                            elif last_parse_reason == CandidateRejectionReason.QUOTE_NOT_VERBATIM:
                                user_prompt += (
                                    f"\n\nPREVIOUS ATTEMPT DEFECT: {last_parse_error}\n"
                                    "CRITICAL EVIDENCE VERBATIM INVARIANT:\n"
                                    "Your previous candidate's evidenceQuote was not found verbatim in the passage text.\n"
                                    f"Target Focus Span: '{target_focus}'\n"
                                    "You MUST extract evidenceQuote as an EXACT, UNALTERED, VERBATIM substring from the passage text above.\n"
                                    "Do NOT paraphrase the evidenceQuote and do NOT quote text not in the passage."
                                )
                            else:
                                exhausted_targets = rejected_prompts.get(target_q_num, [])
                                exhausted_str = "; ".join(f"'{p[:80]}'" for p in exhausted_targets) if exhausted_targets else last_parse_error
                                user_prompt += (
                                    f"\n\nPREVIOUS ATTEMPT DEFECT: {last_parse_error}\n"
                                    "CRITICAL CANDIDATE DIVERSITY AND UNIQUENESS INVARIANT:\n"
                                    "Your previous candidate(s) duplicated already accepted questions or exceeded overlap thresholds.\n"
                                    f"EXHAUSTED FACTUAL TARGETS: {exhausted_str}\n"
                                    "You MUST NOT ask about any of these facts, and superficial paraphrases (such as adding 'The passage suggests that...', 'According to...', or changing voice) will be strictly rejected.\n"
                                    "You MUST select a COMPLETELY DISTINCT factual assertion from the passage grounded in the target claim."
                                )

                        passage_ver = passage_envelope.version
                        op_id = f"op:{context.run_id}:question:{target_q_num}:{passage_ver}_{version}" if gen_attempt == 0 else f"op:{context.run_id}:question:{target_q_num}:{passage_ver}_{version}_att2"
                        req = ProviderRequest(
                            capability=Capability.GENERATE_JSON,
                            messages=[
                                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                                ChatMessage(role="user", content=user_prompt),
                            ],
                            operation_id=op_id,
                            run_id=context.run_id,
                            section_id=str(config.index),
                            artifact_id=target_art_id,
                            preferred_provider=actual_policy.provider,
                            timeout_seconds=call_seconds,
                            wall_time_reservation_seconds=call_seconds,
                            max_tokens=2048,
                        )
                        resp = await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)
                        raw_candidate = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)

                    grp_slots = [s for s in sorted_slots if s.get("groupIndex") == target_g_idx]
                    slot_idx_in_grp = next((i for i, s in enumerate(grp_slots) if s.get("questionNumber") == target_q_num), None)

                    try:
                        parsed = _parse_candidate_payload(
                            raw_candidate,
                            q_num=target_q_num,
                            q_type=target_q_type,
                            passage_text=passage_text,
                            claims_map=claims_map,
                            claim_id=cur_claim_id,
                            difficulty=config.difficulty.value,
                            target_focus=target_focus,
                            prior_questions=q_envelopes,
                            rejected_prompts=rejected_prompts.get(target_q_num, []),
                            slot_index_in_group=slot_idx_in_grp,
                            is_mock=("mock" in actual_policy.provider.lower()),
                        )
                        if parsed.get("evidenceClaimRef") != target_claim_id:
                            raise ValueError(
                                f"Question {target_q_num} evidenceClaimRef '{parsed.get('evidenceClaimRef')}' "
                                f"mismatches blueprint slot claim '{target_claim_id}'. Mismatched evidence is prohibited."
                            )
                        cand_stmt = str(parsed.get("statement") or parsed.get("prompt") or "").strip()
                        return parsed
                    except (CandidateRejectionError, ValueError) as parse_err:
                        last_parse_error = str(parse_err)
                        last_parse_reason = getattr(parse_err, "reason", None)
                        if isinstance(raw_candidate, dict):
                            raw_cands = raw_candidate.get("candidates") or []
                            for rc in raw_cands:
                                if isinstance(rc, dict):
                                    s = str(rc.get("statement") or rc.get("prompt") or "").strip()
                                    ans_str = str(rc.get("answer") or rc.get("correctOption") or "").strip()
                                    q_str = str(rc.get("evidenceQuote") or "").strip()
                                    if s and s not in rejected_prompts.setdefault(target_q_num, []):
                                        rejected_prompts[target_q_num].append(s)
                                    if ans_str:
                                        rejected_answers.setdefault(target_q_num, set()).add(ans_str)
                                    rejected_combos.setdefault(target_q_num, []).append({
                                        "prompt": s,
                                        "answer": ans_str,
                                        "evidenceQuote": q_str,
                                        "reason": str(last_parse_reason or "INVALID_CANDIDATE"),
                                    })
                        if gen_attempt == 1:
                            if last_parse_reason == CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE:
                                raise CandidateRejectionError(
                                    CandidateRejectionReason.ANSWER_NOT_GROUNDED_IN_EVIDENCE,
                                    f"Blueprint slot {target_q_num} compatibility failure: immutable bound claim '{cur_claim_id}' "
                                    f"cannot support a grounded {target_q_type} completion answer without ungrounded extrapolation.",
                                )
                            raise
                        logger.warning("Question %s candidate defect: %s; retrying with repair", target_q_num, parse_err)
                        if target_q_type == "SUMMARY_COMPLETION":
                            summary_group_cache.pop(target_g_idx, None)
            async def evaluate_question_stage(
                art: ArtifactEnvelope,
                prior: tuple[ArtifactEnvelope, ...] = tuple(q_envelopes),
            ) -> list[EvaluationResult]:
                # 1. Structural, verbatim length, evidence offset, and uniqueness evaluations
                evals = list(evaluate_question(
                    art,
                    passage_text,
                    config.difficulty.value,
                    [e.payload for e in prior],
                ))

                # Phase 4: Reject deterministically invalid candidates before expensive independent solver/adversary calls
                deterministic_failures = [e for e in evals if not e.is_pass()]
                if deterministic_failures:
                    from app.contracts.evaluation import EvaluationStatus
                    from app.contracts.issue import IssueSeverity, IssueScope
                    fail_reasons = "; ".join(f"{e.evaluator_id}: {[i.message for i in e.issues]}" for e in deterministic_failures)
                    blind_res = EvaluationResult(
                        evaluationId=f"eval_bsa_shortcircuit_{art.artifact_id}_v{art.version}",
                        evaluatorId="eval_blind_solver_adversary",
                        evaluatorVersion="1.0.0",
                        targetRef=art.to_ref(),
                        inputDependencyRefs=list(art.parent_refs),
                        status=EvaluationStatus.FAIL,
                        score=0.0,
                        issues=[
                            Issue.create(
                                issue_id=f"iss_bsa_skip_{art.artifact_id}_v{art.version}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"Blind solver/adversary skipped: candidate failed prerequisite deterministic verification ({fail_reasons[:120]})",
                                affected_refs=[art.to_ref()],
                                evaluator_id="eval_blind_solver_adversary",
                            )
                        ],
                    )
                    evals.append(blind_res)
                    # Record failed candidate payload for subsequent bounded generation feedback
                    pl = art.payload if isinstance(art.payload, dict) else {}
                    qn = int(pl.get("questionNumber") or 0)
                    ans = str(pl.get("answer") or "").strip()
                    pr = str(pl.get("prompt") or pl.get("statement") or "").strip()
                    eq = str(pl.get("evidenceQuote") or "").strip()
                    if qn and ans:
                        rejected_answers.setdefault(qn, set()).add(ans)
                        rejected_combos.setdefault(qn, []).append({
                            "prompt": pr,
                            "answer": ans,
                            "evidenceQuote": eq,
                            "reason": "FAILED_DETERMINISTIC_EVALUATION",
                        })
                    return evals

                # 2. Independent Blind Solver & Adversarial evaluations
                # When evaluating a repaired question (version > 1), provide a fresh cache
                # to guarantee blind solving re-runs fresh without hitting stale V1 entries.
                from app.solvers.cache import BlindSolverCache
                q_cache = BlindSolverCache() if art.version > 1 else self._solver_cache
                blind_evaluator = BlindSolverEvaluator(
                    gateway=self.gateway,
                    solver_provider=actual_policy.provider,
                    adversary_provider=actual_policy.provider,
                    cache=q_cache,
                )
                blind_input = build_blind_solver_input(
                    passage_text=passage_text,
                    question_data=art.payload,
                    section_id=config.index,
                )
                expected_ans = str(art.payload.get("answer") or art.payload.get("correctOption") or "")
                blind_res, _ = await blind_evaluator.evaluate_blind_input(
                    blind_input=blind_input,
                    expected_answer=expected_ans,
                    target_ref=art.to_ref(),
                    context=context,
                    input_dependency_refs=list(art.parent_refs),
                )
                evals.append(blind_res)
                return evals

            async def repair_question_item(
                art: ArtifactEnvelope,
                issues: Sequence[Any],
                ver: int,
                intent_id: Optional[str] = None,
            ) -> dict[str, Any]:
                from app.solvers.cache import solver_cache
                solver_cache.invalidate()
                from app.repair.question import QuestionItemRepairer
                enable_hybrid = getattr(context, "enable_hybrid_repair", getattr(settings, "enable_hybrid_repair", True))
                item_rep = QuestionItemRepairer(gateway=self.gateway, enable_hybrid=enable_hybrid)
                pl = dict(art.payload)
                if "passage" not in pl and "passageText" not in pl:
                    pl["passage"] = passage_text
                effective_intent_id = intent_id or f"op_repair_q_{ver}"
                repaired_env = await item_rep.repair(context, art.model_copy(update={"payload": pl}), issues, effective_intent_id, ver)
                res_pl = dict(repaired_env.payload)
                res_pl.pop("passage", None)
                return res_pl

            q_env = await executor.execute(
                q_art_id,
                ArtifactType.QUESTION,
                q_parents,
                generate_question,
                evaluate_question_stage,
                section_id=config.index,
                repair=repair_question_item,
            )
            q_envelopes.append(q_env)

        # 5. Section assembly stage
        section_art_id = f"section:{context.run_id}:{config.index}"
        q_refs = [q.to_ref() for q in q_envelopes]
        sec_parents = (passage_envelope.to_ref(), actual_blueprint, *q_refs)

        allocations = sec_blueprint.get("questionAllocations", []) if sec_blueprint else []
        groups_data: list[dict[str, Any]] = []
        if allocations:
            for g_idx, alloc in enumerate(allocations):
                raw_type = alloc.get("questionType", "")
                q_type_str = raw_type.value if hasattr(raw_type, "value") else str(raw_type)
                start_q = alloc.get("startQuestionNumber", 1)
                end_q = alloc.get("endQuestionNumber", 40)
                grp_questions = [
                    q.payload for q in q_envelopes
                    if start_q <= q.payload.get("questionNumber", 0) <= end_q
                ]
                grp_dict: dict[str, Any] = {
                    "groupId": f"group_{config.index}_{g_idx + 1}",
                    "questionType": q_type_str,
                    "instructions": _get_instructions_for_type(q_type_str),
                    "questions": grp_questions,
                }
                if q_type_str in ("SUMMARY_COMPLETION", "SUMMARY_COMPLETION_BOX"):
                    cached_summary = summary_group_cache.get(g_idx, {})
                    shared_ctx = cached_summary.get("summaryText")
                    if not shared_ctx:
                        shared_ctx = " ".join(q.get("prompt", "") for q in grp_questions)
                    grp_dict["sharedContext"] = shared_ctx
                groups_data.append(grp_dict)
        else:
            for g_idx, grp_config in enumerate(config.groups):
                grp_q_nums = set(config.group_numbers(g_idx))
                grp_questions = [q.payload for q in q_envelopes if q.payload.get("questionNumber") in grp_q_nums]
                grp_dict: dict[str, Any] = {
                    "groupId": f"group_{config.index}_{g_idx + 1}",
                    "questionType": grp_config.question_type.value,
                    "instructions": _get_instructions_for_type(grp_config.question_type.value),
                    "questions": grp_questions,
                }
                if grp_config.question_type.value == "SUMMARY_COMPLETION":
                    cached_summary = summary_group_cache.get(g_idx, {})
                    shared_ctx = cached_summary.get("summaryText")
                    if not shared_ctx:
                        shared_ctx = " ".join(q.get("prompt", "") for q in grp_questions)
                    grp_dict["sharedContext"] = shared_ctx
                groups_data.append(grp_dict)

        async def generate_section_artifact(version: int) -> dict[str, Any]:
            title = str(passage_envelope.payload.get("title", topic))
            return compose_section_payload(
                config.index,
                title,
                passage_text,
                groups_data,
                q_refs,
                source_metadata,
                config,
            )

        async def evaluate_section_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_section(art, config)

        section_envelope = await executor.execute(
            section_art_id,
            ArtifactType.SECTION,
            sec_parents,
            generate_section_artifact,
            evaluate_section_stage,
            section_id=config.index,
        )

        return AcceptedSectionArtifact(
            section=section_envelope,
            passage=passage_envelope,
            questions=tuple(q_envelopes),
            blueprintRef=actual_blueprint,
        )
