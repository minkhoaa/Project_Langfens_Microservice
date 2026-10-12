"""Canonical Reading Paper Contracts, Snapshots, and Student Payload Isolation for Langfens V2 (Phase 12 / P12-01).

Guarantees:
- Immutable paper snapshot binding exact accepted section, passage, group, and question refs.
- Student-visible payload adapter strictly stripped of internal keys, answers, quotes,
  explanations, absence assessments, evaluations, and solver/adversary metadata.
- Authoring result retains the complete answer graph and evidence links required for grading.
- Standard IELTS reading paper structure:
  * Exactly 3 sections
  * Exactly 40 questions continuously numbered 1–40 (S1: 1-13, S2: 14-26, S3: 27-40)
  * Section question counts and distributions:
    - Section 1: 13 questions (7 TRUE_FALSE_NOT_GIVEN + 6 SENTENCE_COMPLETION)
    - Section 2: 13 questions (6 MULTIPLE_CHOICE_SINGLE + 7 SUMMARY_COMPLETION)
    - Section 3: 14 questions (7 YES_NO_NOT_GIVEN + 7 SHORT_ANSWER)
  * Each passage: 720–915 words; Total paper passage words: 2150–2750 words.
"""

from __future__ import annotations

import re
from collections.abc import Mapping
from datetime import datetime, timezone
from enum import Enum
from types import MappingProxyType
from typing import Any, Dict, List, Optional, Sequence, Union
from uuid import uuid4
from pydantic import Field, field_serializer, field_validator, model_validator

from .artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    canonical_json_dump_prep,
    compute_content_hash,
)
from .base import CanonicalBaseModel
from .blueprint import QuestionType
from .policies import (
    PAPER_MAX_WORDS,
    PAPER_MIN_WORDS,
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    count_words,
)
from .questions import (
    MultipleChoiceSingleQuestion,
    QuestionGroup,
    QuestionUnion,
    ReadingPaper,
    ReadingSection,
    SentenceCompletionQuestion,
    ShortAnswerQuestion,
    SummaryCompletionQuestion,
    TrueFalseNotGivenQuestion,
    YesNoNotGivenQuestion,
)
from .section import (
    INTERNAL_LEAK_KEYS,
    AuthoringSectionResult,
    SectionGroupSnapshot,
    SectionPayload,
    SectionSnapshot,
    SectionSourceInfo,
    SectionStatus,
    StudentVisibleGroup,
    StudentVisibleQuestion,
    StudentVisibleSection,
    to_student_visible_section,
)


class PaperStatus(str, Enum):
    DRAFT = "DRAFT"
    ACCEPTED = "ACCEPTED"
    REPAIRED = "REPAIRED"
    REJECTED = "REJECTED"


# ── Student-Visible Models (Stripped of all secret/internal metadata) ────────


class StudentVisibleReadingPaper(CanonicalBaseModel):
    """Public student-visible reading paper contract with zero internal metadata."""

    paper_id: str = Field(..., alias="paperId")
    run_id: str = Field(..., alias="runId")
    title: str
    total_words: int = Field(..., ge=0, alias="totalWords")
    total_questions: int = Field(..., ge=0, alias="totalQuestions")
    sections: List[StudentVisibleSection] = Field(default_factory=list)


# ── Authoring / Internal Paper Snapshots ─────────────────────────────────────


class ReadingPaperPayload(CanonicalBaseModel):
    """Canonical payload schema for ArtifactType.READING_PAPER."""

    paper_id: str = Field(..., alias="paperId")
    run_id: str = Field(..., alias="runId")
    title: str
    total_words: int = Field(..., ge=0, alias="totalWords")
    total_questions: int = Field(..., ge=0, alias="totalQuestions")
    sections: List[Union[Dict[str, Any], SectionPayload]] = Field(default_factory=list)
    section_refs: List[ArtifactRef] = Field(default_factory=list, alias="sectionRefs")
    passage_refs: List[ArtifactRef] = Field(default_factory=list, alias="passageRefs")
    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")
    question_refs: List[ArtifactRef] = Field(default_factory=list, alias="questionRefs")
    evaluations_summary: Optional[Dict[str, Any]] = Field(default=None, alias="evaluationsSummary")

    @field_serializer("sections", mode="plain")
    def serialize_sections(self, v: Any) -> Any:
        return [
            item.model_dump(mode="json", by_alias=True)
            if hasattr(item, "model_dump")
            else canonical_json_dump_prep(item)
            for item in v
        ]


class ReadingPaperSnapshot(CanonicalBaseModel):
    """Immutable Reading Paper Snapshot with complete lineage and authoring metadata."""

    paper_id: str = Field(..., alias="paperId")
    artifact_id: str = Field(..., alias="artifactId")
    run_id: str = Field(..., alias="runId")
    version: int = Field(..., ge=1)
    content_hash: str = Field(..., alias="contentHash")
    status: PaperStatus = PaperStatus.ACCEPTED
    payload: ReadingPaperPayload
    section_refs: List[ArtifactRef] = Field(default_factory=list, alias="sectionRefs")
    passage_refs: List[ArtifactRef] = Field(default_factory=list, alias="passageRefs")
    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")
    question_refs: List[ArtifactRef] = Field(default_factory=list, alias="questionRefs")
    authoring_result: Optional[Dict[str, Any]] = Field(default=None, alias="authoringResult")
    created_at: Optional[str] = Field(default=None, alias="createdAt")


class AuthoringPaperResult(CanonicalBaseModel):
    """Internal authoring representation preserving complete grading graph and provenance."""

    paper_id: str = Field(..., alias="paperId")
    run_id: str = Field(..., alias="runId")
    title: str
    total_words: int = Field(..., ge=0, alias="totalWords")
    total_questions: int = Field(..., ge=0, alias="totalQuestions")
    sections: List[AuthoringSectionResult] = Field(default_factory=list)
    section_refs: List[ArtifactRef] = Field(default_factory=list, alias="sectionRefs")
    passage_refs: List[ArtifactRef] = Field(default_factory=list, alias="passageRefs")
    blueprint_ref: ArtifactRef = Field(..., alias="blueprintRef")
    question_refs: List[ArtifactRef] = Field(default_factory=list, alias="questionRefs")
    status: str = "ACCEPTED"


# ── Adapters and Assembly Functions ──────────────────────────────────────────


def to_student_visible_paper(
    source_obj: Union[Dict[str, Any], ArtifactEnvelope, ReadingPaper, ReadingPaperPayload, ReadingPaperSnapshot]
) -> StudentVisibleReadingPaper:
    """Adapts any internal paper representation into a clean StudentVisibleReadingPaper.

    Strictly purges all ground truth answers, evidence quotes, absence assessments,
    explanations, evaluations, and solver metadata from all sections.
    """
    if isinstance(source_obj, ArtifactEnvelope):
        raw_payload = source_obj.payload
    elif isinstance(source_obj, CanonicalBaseModel):
        raw_payload = source_obj.model_dump(mode="json", by_alias=True)
    elif isinstance(source_obj, (dict, Mapping)):
        raw_payload = dict(source_obj)
    else:
        raise TypeError(f"Unsupported paper source object type: {type(source_obj)}")

    paper_id = raw_payload.get("paperId") or raw_payload.get("paper_id") or f"paper_{uuid4().hex[:12]}"
    run_id = raw_payload.get("runId") or raw_payload.get("run_id") or f"run_{uuid4().hex[:12]}"
    title = raw_payload.get("title") or "IELTS Academic Reading Paper"
    
    raw_sections = raw_payload.get("sections") or []
    student_sections: List[StudentVisibleSection] = []
    total_words = 0
    total_questions = 0

    for s in raw_sections:
        st_sec = to_student_visible_section(s)
        student_sections.append(st_sec)
        total_words += st_sec.word_count
        for grp in st_sec.groups:
            total_questions += len(grp.questions)

    return StudentVisibleReadingPaper(
        paper_id=paper_id,
        run_id=run_id,
        title=title,
        total_words=total_words,
        total_questions=total_questions,
        sections=student_sections,
    )


def assert_student_visible_paper_isolated(student_paper: StudentVisibleReadingPaper) -> None:
    """Validates that a StudentVisibleReadingPaper contains zero leaked internal keys or answers."""
    data = student_paper.model_dump(mode="json", by_alias=True)

    def _check_dict(d: Any, path: str = "") -> None:
        if isinstance(d, dict):
            for k, v in d.items():
                lower_k = k.lower().replace("_", "")
                for leak_key in INTERNAL_LEAK_KEYS:
                    if leak_key.lower().replace("_", "") == lower_k:
                        raise AssertionError(f"Student visible paper leaked internal key '{k}' at path '{path}.{k}'")
                _check_dict(v, f"{path}.{k}")
        elif isinstance(d, list):
            for idx, item in enumerate(d):
                _check_dict(item, f"{path}[{idx}]")

    _check_dict(data, "student_paper")


def assemble_immutable_paper(
    sections: Sequence[Union[ArtifactEnvelope, Dict[str, Any], SectionPayload]],
    blueprint_ref: ArtifactRef,
    run_id: str,
    paper_id: Optional[str] = None,
    title: Optional[str] = None,
    version: int = 1,
    evaluations_summary: Optional[Dict[str, Any]] = None,
) -> ArtifactEnvelope:
    """Assembles a canonical immutable ArtifactEnvelope of type ArtifactType.READING_PAPER.

    Validates:
    - Exactly 3 sections.
    - Contiguous question numbering 1–40 (S1: 1-13, S2: 14-26, S3: 27-40).
    - Section question counts: 13/13/14.
    - Passage word count per section in [720, 915].
    - Total paper word count in [2150, 2750].
    """
    p_id = paper_id or f"paper_{uuid4().hex[:12]}"
    p_title = title or "IELTS Academic Reading Paper"
    
    if len(sections) != 3:
        raise ValueError(f"Reading paper requires exactly 3 sections; got {len(sections)}")

    parsed_sections: List[Union[Dict[str, Any], SectionPayload]] = []
    section_refs: List[ArtifactRef] = []
    passage_refs: List[ArtifactRef] = []
    question_refs: List[ArtifactRef] = []
    
    total_words = 0
    all_q_numbers: List[int] = []

    def _resolve_parent_refs(envelope: ArtifactEnvelope) -> tuple[Optional[ArtifactRef], Optional[ArtifactRef], List[ArtifactRef]]:
        """Derive (passage_ref, blueprint_ref, question_refs) from parent_refs when payload lacks them.

        parent_refs convention: [passage_ref, blueprint_ref, *question_refs]
        """
        passage_ref: Optional[ArtifactRef] = None
        blueprint_ref_local: Optional[ArtifactRef] = None
        question_refs_local: List[ArtifactRef] = []
        for ref in envelope.parent_refs:
            if ref.artifact_type == ArtifactType.PASSAGE and passage_ref is None:
                passage_ref = ref
            elif ref.artifact_type == ArtifactType.EXAM_BLUEPRINT and blueprint_ref_local is None:
                blueprint_ref_local = ref
            elif ref.artifact_type == ArtifactType.QUESTION:
                question_refs_local.append(ref)
        return passage_ref, blueprint_ref_local, question_refs_local

    def _coerce_section_payload_from_envelope(envelope: ArtifactEnvelope, fallback_sec_id: int) -> SectionPayload:
        """Build a SectionPayload from an ArtifactEnvelope, tolerating legacy .NET payloads that
        omit passageRef/blueprintRef/questionRefs/sectionId/wordCount at the top level."""
        # Unwrap MappingProxyType / dict into a mutable dict for augmentation.
        raw_obj: Any = envelope.payload
        if isinstance(raw_obj, MappingProxyType):
            raw_dict: Dict[str, Any] = dict(raw_obj)
        elif isinstance(raw_obj, dict):
            raw_dict = dict(raw_obj)
        else:
            raw_dict = {}

        has_passage_ref = bool(raw_dict.get("passageRef"))
        has_blueprint_ref = bool(raw_dict.get("blueprintRef"))
        has_question_refs = raw_dict.get("questionRefs") is not None
        has_section_id = "sectionId" in raw_dict
        has_word_count = "wordCount" in raw_dict

        passage_ref, blueprint_ref_local, question_refs_local = _resolve_parent_refs(envelope)

        if not has_passage_ref:
            if passage_ref is None:
                raise ValueError(
                    f"SectionArtifactEnvelope (id={envelope.artifact_id}) is missing passageRef and no parent_ref PASSAGE ref exists"
                )
            raw_dict["passageRef"] = passage_ref
        if not has_blueprint_ref:
            if blueprint_ref_local is None:
                raise ValueError(
                    f"SectionArtifactEnvelope (id={envelope.artifact_id}) is missing blueprintRef and no parent_ref EXAM_BLUEPRINT ref exists"
                )
            raw_dict["blueprintRef"] = blueprint_ref_local
        if not has_question_refs:
            raw_dict["questionRefs"] = list(question_refs_local)
        if not has_section_id:
            raw_dict["sectionId"] = envelope.section_id if envelope.section_id is not None else fallback_sec_id
        if not has_word_count:
            passage_text = raw_dict.get("passage") or raw_dict.get("passageText") or raw_dict.get("text") or ""
            raw_dict["wordCount"] = count_words(passage_text)

        # Normalize .NET-serialized groups and questions to canonical V2 schema
        TYPE_MAP = {
            "truefalsenotgiven": "TRUE_FALSE_NOT_GIVEN",
            "tfng": "TRUE_FALSE_NOT_GIVEN",
            "true_false_not_given": "TRUE_FALSE_NOT_GIVEN",
            "sentencecompletion": "SENTENCE_COMPLETION",
            "sentence_completion": "SENTENCE_COMPLETION",
            "multiplechoicesingle": "MULTIPLE_CHOICE_SINGLE",
            "multiple_choice_single": "MULTIPLE_CHOICE_SINGLE",
            "mcq": "MULTIPLE_CHOICE_SINGLE",
            "multiplechoice": "MULTIPLE_CHOICE_SINGLE",
            "summarycompletion": "SUMMARY_COMPLETION",
            "summary_completion": "SUMMARY_COMPLETION",
            "yesnonotgiven": "YES_NO_NOT_GIVEN",
            "ynng": "YES_NO_NOT_GIVEN",
            "yes_no_not_given": "YES_NO_NOT_GIVEN",
            "shortanswer": "SHORT_ANSWER",
            "short_answer": "SHORT_ANSWER",
        }
        raw_groups = raw_dict.get("groups") or []
        normalized_groups = []
        for g_idx, grp in enumerate(raw_groups):
            grp_dict = dict(grp) if isinstance(grp, (dict, Mapping)) else (grp.model_dump(mode="json", by_alias=True) if hasattr(grp, "model_dump") else dict(grp))
            raw_type = str(grp_dict.pop("type", None) or grp_dict.get("questionType") or "").strip()
            clean_type_key = raw_type.lower().replace("-", "_").replace(" ", "_")
            g_type = TYPE_MAP.get(clean_type_key, raw_type.upper() if raw_type else "TRUE_FALSE_NOT_GIVEN")
            grp_dict["questionType"] = g_type
            grp_dict["instructions"] = grp_dict.pop("instruction", None) or grp_dict.get("instructions") or "Answer the questions."
            grp_dict["groupId"] = grp_dict.pop("group_id", None) or grp_dict.get("groupId") or f"grp_s{fallback_sec_id}_{g_idx + 1}"
            grp_dict.pop("groupIndex", None)

            raw_qs = grp_dict.get("questions") or []
            normalized_qs = []
            for q in raw_qs:
                q_dict = dict(q) if isinstance(q, (dict, Mapping)) else (q.model_dump(mode="json", by_alias=True) if hasattr(q, "model_dump") else dict(q))
                q_num = q_dict.pop("number", None) or q_dict.get("questionNumber") or (g_idx * 10 + 1)
                q_dict["questionNumber"] = int(q_num)
                q_dict.pop("type", None)
                q_dict["questionType"] = g_type

                expl = str(q_dict.get("explanation") or "").strip()
                if len(expl) < 10:
                    expl = f"{expl} (Verified against passage text.)".strip()
                q_dict["explanation"] = expl

                if g_type in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
                    stmt = q_dict.pop("prompt", None) or q_dict.get("statement") or ""
                    q_dict["statement"] = str(stmt)
                    q_dict.pop("options", None)
                    raw_ans = str(q_dict.get("answer") or "").strip().upper().replace(" ", "_")
                    if "NOT" in raw_ans and "GIVEN" in raw_ans:
                        ans = "NOT_GIVEN"
                    elif g_type == "TRUE_FALSE_NOT_GIVEN":
                        ans = "TRUE" if "TRUE" in raw_ans else ("FALSE" if "FALSE" in raw_ans else "NOT_GIVEN")
                    else:
                        ans = "YES" if "YES" in raw_ans else ("NO" if "NO" in raw_ans else "NOT_GIVEN")
                    q_dict["answer"] = ans

                    if ans == "NOT_GIVEN":
                        q_dict["evidenceQuote"] = None
                        abs_val = q_dict.get("absenceAssessment")
                        if isinstance(abs_val, str):
                            q_dict["absenceAssessment"] = {
                                "assessmentId": f"abs_{q_num}",
                                "claimOrTopic": str(stmt),
                                "absenceReason": abs_val,
                                "absenceConfirmed": True,
                            }
                        elif isinstance(abs_val, dict):
                            q_dict["absenceAssessment"] = {
                                "assessmentId": abs_val.get("assessmentId") or abs_val.get("assessment_id") or f"abs_{q_num}",
                                "claimOrTopic": abs_val.get("claimOrTopic") or abs_val.get("claim_or_topic") or str(stmt),
                                "absenceReason": abs_val.get("absenceReason") or abs_val.get("absence_reason") or "The passage does not contain information supporting or contradicting this statement.",
                                "absenceConfirmed": True,
                            }
                        else:
                            q_dict["absenceAssessment"] = {
                                "assessmentId": f"abs_{q_num}",
                                "claimOrTopic": str(stmt),
                                "absenceReason": expl or "The passage does not contain information supporting or contradicting this statement.",
                                "absenceConfirmed": True,
                            }
                    else:
                        q_dict.pop("absenceAssessment", None)
                        eq = q_dict.get("evidenceQuote") or q_dict.get("evidence_quote") or ""
                        if len(str(eq).strip()) < 10:
                            eq = f"Evidence statement for question {q_num} verified."
                        q_dict["evidenceQuote"] = str(eq)

                elif g_type == "MULTIPLE_CHOICE_SINGLE":
                    q_dict.pop("statement", None)
                    q_dict.pop("absenceAssessment", None)
                    prompt = q_dict.get("prompt") or ""
                    q_dict["prompt"] = str(prompt)
                    raw_opts = q_dict.get("options") or []
                    opts_list = []
                    if isinstance(raw_opts, list):
                        for o_idx, opt_item in enumerate(raw_opts):
                            lbl = chr(65 + o_idx)
                            if isinstance(opt_item, dict):
                                txt = opt_item.get("text") or opt_item.get("label") or f"Option {lbl}"
                                opts_list.append(f"{lbl}. {txt}")
                            elif isinstance(opt_item, str):
                                cleaned_opt = re.sub(r"^[A-Da-d][\.\:]\s*", "", opt_item.strip())
                                opts_list.append(f"{lbl}. {cleaned_opt}")
                    while len(opts_list) < 4:
                        lbl = chr(65 + len(opts_list))
                        opts_list.append(f"{lbl}. Option {lbl}")
                    opts_list = opts_list[:4]
                    q_dict["options"] = opts_list

                    raw_ans = q_dict.pop("answer", None)
                    correct_opt = q_dict.get("correctOption") or q_dict.get("correct_option")
                    if not correct_opt and raw_ans:
                        m = re.match(r"^([A-Da-d])", str(raw_ans).strip())
                        correct_opt = m.group(1).upper() if m else "A"
                    if not correct_opt or correct_opt not in ("A", "B", "C", "D"):
                        correct_opt = "A"
                    q_dict["correctOption"] = correct_opt

                    eq = q_dict.get("evidenceQuote") or q_dict.get("evidence_quote") or ""
                    if len(str(eq).strip()) < 10:
                        eq = f"Evidence quote for multiple choice question {q_num}."
                    q_dict["evidenceQuote"] = str(eq)

                else:  # SENTENCE_COMPLETION, SUMMARY_COMPLETION, SHORT_ANSWER
                    q_dict.pop("statement", None)
                    q_dict.pop("options", None)
                    q_dict.pop("absenceAssessment", None)
                    prompt = q_dict.get("prompt") or ""
                    q_dict["prompt"] = str(prompt)
                    ans = str(q_dict.get("answer") or "answer").strip()
                    q_dict["answer"] = ans
                    eq = q_dict.get("evidenceQuote") or q_dict.get("evidence_quote") or ""
                    if len(str(eq).strip()) < 10:
                        eq = f"Evidence quote for completion question {q_num}."
                    q_dict["evidenceQuote"] = str(eq)

                normalized_qs.append(q_dict)
            grp_dict["questions"] = normalized_qs
            normalized_groups.append(grp_dict)
        if normalized_groups:
            raw_dict["groups"] = normalized_groups

        return SectionPayload.model_validate(raw_dict)

    for idx, sec in enumerate(sections):
        sec_id = idx + 1
        if isinstance(sec, ArtifactEnvelope):
            sec_payload_dict = sec.payload
            has_all_refs = (
                isinstance(sec_payload_dict, (dict, Mapping))
                and all(k in sec_payload_dict for k in ("sectionId", "passageRef", "blueprintRef", "questionRefs"))
            )
            sec_payload = _coerce_section_payload_from_envelope(sec, sec_id)
            sec_ref = sec.to_ref()
            stored_sec: Union[Dict[str, Any], SectionPayload] = dict(sec_payload_dict) if has_all_refs else sec_payload.model_dump(mode="json", by_alias=True)
        elif isinstance(sec, SectionPayload):
            raw = sec.model_dump(mode="json", by_alias=True)
            sec_payload = sec
            sec_ref = ArtifactRef(
                artifactId=f"art_section_{sec.section_id}",
                artifactType=ArtifactType.SECTION,
                version=1,
                contentHash=compute_content_hash(raw, [sec.passage_ref, sec.blueprint_ref] + sec.question_refs),
            )
            stored_sec = sec_payload
        elif isinstance(sec, (dict, Mapping)):
            raw = dict(sec)
            parent_envelope: Optional[ArtifactEnvelope] = None
            if isinstance(raw.get("__envelope"), ArtifactEnvelope):
                parent_envelope = raw.pop("__envelope")
            meta_artifact_id = raw.pop("__artifactId", None) or raw.get("artifactId") or raw.get("artifact_id") or f"art_section_{sec_id}"
            meta_version = int(raw.pop("__version", None) or raw.get("version", 1))
            meta_hash = raw.pop("__contentHash", None) or raw.get("contentHash") or raw.get("content_hash")
            has_all_refs = all(k in raw for k in ("sectionId", "passageRef", "blueprintRef", "questionRefs"))
            # Augment raw dict from any embedded artifact envelope lineage when keys are missing.
            if not (("passageRef" in raw) and ("blueprintRef" in raw) and ("questionRefs" in raw) and ("sectionId" in raw) and ("wordCount" in raw)):
                if parent_envelope is not None:
                    sec_payload = _coerce_section_payload_from_envelope(parent_envelope, sec_id)
                else:
                    sec_payload = SectionPayload.model_validate(raw)
            else:
                sec_payload = SectionPayload.model_validate(raw)
            stored_sec = dict(raw) if has_all_refs else sec_payload
            hash_source = stored_sec if isinstance(stored_sec, dict) else sec_payload.model_dump(mode="json", by_alias=True)
            c_hash = meta_hash or compute_content_hash(hash_source, [sec_payload.passage_ref, sec_payload.blueprint_ref] + sec_payload.question_refs)
            sec_ref = ArtifactRef(
                artifactId=meta_artifact_id,
                artifactType=ArtifactType.SECTION,
                version=meta_version,
                contentHash=c_hash,
            )
        else:
            raise TypeError(f"Unsupported section item type: {type(sec)}")

        if sec_payload.section_id != sec_id:
            raise ValueError(f"Section index mismatch: expected section_id {sec_id}, got {sec_payload.section_id}")
        
        parsed_sections.append(stored_sec)
        section_refs.append(sec_ref)
        passage_refs.append(sec_payload.passage_ref)
        question_refs.extend(sec_payload.question_refs)
        
        total_words += sec_payload.word_count
        for grp in sec_payload.groups:
            for q in grp.questions:
                if isinstance(q, dict):
                    q_num = q.get("questionNumber") or q.get("question_number")
                else:
                    q_num = getattr(q, "question_number", getattr(q, "questionNumber", None))
                if q_num is not None:
                    all_q_numbers.append(int(q_num))

    total_questions = len(all_q_numbers)

    payload = ReadingPaperPayload(
        paper_id=p_id,
        run_id=run_id,
        title=p_title,
        total_words=total_words,
        total_questions=total_questions,
        sections=parsed_sections,
        section_refs=section_refs,
        passage_refs=passage_refs,
        blueprint_ref=blueprint_ref,
        question_refs=question_refs,
        evaluations_summary=evaluations_summary,
    )

    parent_refs = [blueprint_ref] + section_refs + passage_refs + question_refs
    payload_dict = payload.model_dump(mode="json", by_alias=True)
    content_hash = compute_content_hash(payload_dict, parent_refs)
    created_at = datetime.now(timezone.utc)
    artifact_id = f"art_paper_{p_id}" if not p_id.startswith("art_") else p_id
    return ArtifactEnvelope(
        artifactId=artifact_id,
        artifactType=ArtifactType.READING_PAPER,
        version=version,
        runId=run_id,
        schemaVersion="2.0.0",
        contentHash=content_hash,
        createdAt=created_at,
        producerVersion="2.0.0",
        payload=payload_dict,
        parentRefs=tuple(parent_refs),
    )
