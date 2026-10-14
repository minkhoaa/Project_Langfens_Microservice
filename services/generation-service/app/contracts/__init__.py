"""Canonical Domain Contracts for Langfens Loop Engine V2.

This module provides the single canonical source of truth for all domain
models, artifact envelopes, policies, evaluations, issues, and events.
"""

from .base import CanonicalBaseModel
from .artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
    canonical_json_dump,
    freeze_container,
)
from .blueprint import (
    ExamBlueprint,
    QuestionType,
    QuestionTypeAllocation,
    SectionBlueprint,
)
from .evaluation import (
    EvaluationResult,
    EvaluationStatus,
    UsageMetrics,
)
from .event import (
    DomainEvent,
    EventType,
)
from .evidence import (
    AbsenceAssessment,
    EntailmentLabel,
    EvidenceGraph,
    Qualifier,
    SourceOffset,
    TopicalContextSpan,
    VerifiedClaim,
)
from .generation import (
    BudgetReservation,
    BudgetStatus,
    GenerationRun,
    OperationGrant,
    OperationStatus,
    RunIdentity,
    SectionSlot,
    SectionSlotStatus,
)
from .issue import (
    Issue,
    IssueCode,
    IssueLedger,
    IssueScope,
    IssueSeverity,
    IssueStatus,
    compute_issue_fingerprint,
)
from .loop import (
    DecisionType,
    LoopDecision,
    LoopState,
    validate_loop_decision,
    validate_transition,
    VALID_TRANSITIONS,
)
from .policies import (
    MAX_ANSWER_WORDS,
    MAX_SHINGLE_OVERLAP,
    PAPER_MAX_WORDS,
    PAPER_MIN_WORDS,
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    POLICY_VERSION,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    calculate_shingle_overlap,
    count_words,
    get_5word_shingles,
    match_verbatim_in_passage,
    normalize_prompt,
    validate_answer_length,
    validate_reading_paper_policies,
    validate_reading_section_policies,
)
from .questions import (
    BaseQuestion,
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
from .source import (
    IngestionResult,
    IngestionStatus,
    SourceDocument,
    SourceItem,
    SourceMetadata,
    SourcePack,
)
from .section import (
    AuthoringSectionResult,
    SectionGroupSnapshot,
    SectionPayload,
    SectionSnapshot,
    SectionSourceInfo,
    SectionStatus,
    StudentVisibleGroup,
    StudentVisibleOption,
    StudentVisibleQuestion,
    StudentVisibleSection,
    assemble_immutable_section,
    assert_student_visible_payload_isolated,
    to_student_visible_section,
)
from .paper import (
    AuthoringPaperResult,
    PaperStatus,
    ReadingPaperPayload,
    ReadingPaperSnapshot,
    StudentVisibleReadingPaper,
    assemble_immutable_paper,
    assert_student_visible_paper_isolated,
    to_student_visible_paper,
)

__all__ = [
    # Base
    "CanonicalBaseModel",
    # Artifact
    "ArtifactEnvelope",
    "ArtifactRef",
    "ArtifactType",
    "compute_content_hash",
    "canonical_json_dump",
    "freeze_container",
    # Blueprint
    "ExamBlueprint",
    "QuestionType",
    "QuestionTypeAllocation",
    "SectionBlueprint",
    # Evaluation
    "EvaluationResult",
    "EvaluationStatus",
    "UsageMetrics",
    # Event
    "DomainEvent",
    "EventType",
    # Evidence
    "AbsenceAssessment",
    "EntailmentLabel",
    "EvidenceGraph",
    "Qualifier",
    "SourceOffset",
    "TopicalContextSpan",
    "VerifiedClaim",
    # Generation
    "BudgetReservation",
    "BudgetStatus",
    "GenerationRun",
    "OperationGrant",
    "OperationStatus",
    "RunIdentity",
    "SectionSlot",
    "SectionSlotStatus",
    # Issue
    "Issue",
    "IssueCode",
    "IssueLedger",
    "IssueScope",
    "IssueSeverity",
    "IssueStatus",
    "compute_issue_fingerprint",
    # Loop
    "DecisionType",
    "LoopDecision",
    "LoopState",
    "validate_loop_decision",
    "validate_transition",
    "VALID_TRANSITIONS",
    # Policies
    "MAX_ANSWER_WORDS",
    "MAX_SHINGLE_OVERLAP",
    "PAPER_MAX_WORDS",
    "PAPER_MIN_WORDS",
    "PASSAGE_MAX_WORDS",
    "PASSAGE_MIN_WORDS",
    "POLICY_VERSION",
    "SECTION_GROUP_SIZES",
    "SECTION_GROUP_TYPES",
    "SECTION_QUESTION_COUNTS",
    "calculate_shingle_overlap",
    "count_words",
    "get_5word_shingles",
    "match_verbatim_in_passage",
    "normalize_prompt",
    "validate_answer_length",
    "validate_reading_paper_policies",
    "validate_reading_section_policies",
    # Questions
    "BaseQuestion",
    "MultipleChoiceSingleQuestion",
    "QuestionGroup",
    "QuestionUnion",
    "ReadingPaper",
    "ReadingSection",
    "SentenceCompletionQuestion",
    "ShortAnswerQuestion",
    "SummaryCompletionQuestion",
    "TrueFalseAnswer",
    "TrueFalseNotGivenQuestion",
    "YesNoAnswer",
    "YesNoNotGivenQuestion",
    # Source
    "IngestionResult",
    "IngestionStatus",
    "SourceDocument",
    "SourceItem",
    "SourceMetadata",
    "SourcePack",
    # Section
    "AuthoringSectionResult",
    "SectionGroupSnapshot",
    "SectionPayload",
    "SectionSnapshot",
    "SectionSourceInfo",
    "SectionStatus",
    "StudentVisibleGroup",
    "StudentVisibleOption",
    "StudentVisibleQuestion",
    "StudentVisibleSection",
    "assemble_immutable_section",
    "assert_student_visible_payload_isolated",
    "to_student_visible_section",
    # Paper
    "AuthoringPaperResult",
    "PaperStatus",
    "ReadingPaperPayload",
    "ReadingPaperSnapshot",
    "StudentVisibleReadingPaper",
    "assemble_immutable_paper",
    "assert_student_visible_paper_isolated",
    "to_student_visible_paper",
]
