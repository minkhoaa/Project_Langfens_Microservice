"""Canonical validation models, issue codes, and result schemas.

Defines the contract for the Unified Question Validation Engine across all 19 IELTS question types.
"""
from __future__ import annotations

from enum import Enum
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class ValidationStatus(str, Enum):
    VALID = "VALID"
    INVALID = "INVALID"
    NEEDS_REVIEW = "NEEDS_REVIEW"


class ValidationSeverity(str, Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class Repairability(str, Enum):
    REPAIRABLE_AUTOMATIC = "REPAIRABLE_AUTOMATIC"
    REPAIRABLE_MANUAL = "REPAIRABLE_MANUAL"
    IRREPARABLE = "IRREPARABLE"


class IssueCode(str, Enum):
    # Structural issues
    ERR_MALFORMED_STRUCTURE = "ERR_MALFORMED_STRUCTURE"
    ERR_UNKNOWN_TYPE = "ERR_UNKNOWN_TYPE"
    ERR_SKILL_MISMATCH = "ERR_SKILL_MISMATCH"
    ERR_DIFFICULTY_OUT_OF_RANGE = "ERR_DIFFICULTY_OUT_OF_RANGE"
    ERR_PROMPT_EMPTY = "ERR_PROMPT_EMPTY"
    ERR_FORBIDDEN_ANSWER_FIELD = "ERR_FORBIDDEN_ANSWER_FIELD"
    ERR_IMAGE_URL_MISSING = "ERR_IMAGE_URL_MISSING"

    # Option issues
    ERR_OPTIONS_MISSING = "ERR_OPTIONS_MISSING"
    ERR_OPTIONS_CARDINALITY = "ERR_OPTIONS_CARDINALITY"
    ERR_OPTIONS_INDICES_NON_SEQUENTIAL = "ERR_OPTIONS_INDICES_NON_SEQUENTIAL"
    ERR_OPTIONS_DUPLICATE_CONTENT = "ERR_OPTIONS_DUPLICATE_CONTENT"
    ERR_OPTION_EMPTY_CONTENT = "ERR_OPTION_EMPTY_CONTENT"
    ERR_CORRECT_COUNT_MISMATCH = "ERR_CORRECT_COUNT_MISMATCH"

    # Answer key issues
    ERR_MISSING_ANSWER_KEY = "ERR_MISSING_ANSWER_KEY"
    ERR_PLACEHOLDER_ANSWER = "ERR_PLACEHOLDER_ANSWER"
    ERR_OPTION_REF_INVALID = "ERR_OPTION_REF_INVALID"
    ERR_PROMPT_MARKER_MISSING = "ERR_PROMPT_MARKER_MISSING"
    ERR_BLANK_KEY_INVALID = "ERR_BLANK_KEY_INVALID"
    ERR_EMPTY_ANSWER_VARIANT = "ERR_EMPTY_ANSWER_VARIANT"
    ERR_WORD_LIMIT_EXCEEDED = "ERR_WORD_LIMIT_EXCEEDED"
    ERR_DUPLICATE_MATCHING_KEY = "ERR_DUPLICATE_MATCHING_KEY"
    ERR_DISTRACTOR_MISSING = "ERR_DISTRACTOR_MISSING"
    ERR_FLOW_CHART_SLUG_INVALID = "ERR_FLOW_CHART_SLUG_INVALID"
    ERR_FLOW_CHART_SLUG_DUPLICATE = "ERR_FLOW_CHART_SLUG_DUPLICATE"

    # Grounding & Semantics
    ERR_UNGROUNDED_ANSWER = "ERR_UNGROUNDED_ANSWER"
    ERR_CONTRADICTED_ANSWER = "ERR_CONTRADICTED_ANSWER"
    ERR_AMBIGUOUS_ANSWER = "ERR_AMBIGUOUS_ANSWER"
    ERR_TFNG_LABEL_MISMATCH = "ERR_TFNG_LABEL_MISMATCH"
    ERR_YNNG_LABEL_MISMATCH = "ERR_YNNG_LABEL_MISMATCH"
    ERR_CONJOINED_SHORT_ANSWER = "ERR_CONJOINED_SHORT_ANSWER"

    # Language policy
    ERR_VIETNAMESE_TEXT = "ERR_VIETNAMESE_TEXT"
    ERR_NON_ENGLISH_TEXT = "ERR_NON_ENGLISH_TEXT"

    # Budget & accounting
    ERR_BUDGET_EXHAUSTED = "ERR_BUDGET_EXHAUSTED"
    ERR_EVALUATION_INCONCLUSIVE = "ERR_EVALUATION_INCONCLUSIVE"


class ValidationIssue(BaseModel):
    code: IssueCode
    message: str
    severity: ValidationSeverity = ValidationSeverity.ERROR
    is_blocking: bool = True
    field_path: str = ""
    scored_item_index: Optional[int] = None
    evidence_ref: Optional[str] = None
    repairability: Repairability = Repairability.REPAIRABLE_MANUAL


class ScoredItemValidation(BaseModel):
    item_index: int
    item_key: str
    is_valid: bool
    accepted_answers: Optional[List[str]] = None
    evidence_span: Optional[str] = None
    issues: List[ValidationIssue] = Field(default_factory=list)


class ValidationPolicy(BaseModel):
    schema_version: int = 2
    enforce_language: bool = True
    enforce_grounding: bool = True
    enforce_word_limits: bool = True
    allow_llm_eval: bool = False
    max_word_limit: int = 3
    token_budget: int = 2000
    cost_tracking_enabled: bool = True


class ValidationResult(BaseModel):
    status: ValidationStatus
    question_type: str
    schema_version: int = 2
    structural_valid: bool = False
    semantic_valid: Optional[bool] = None
    grounding_verified: bool = False
    issues: List[ValidationIssue] = Field(default_factory=list)
    scored_items: List[ScoredItemValidation] = Field(default_factory=list)
    is_repairable: bool = False
    reasons: List[str] = Field(default_factory=list)
    evidence_summary: Dict[str, Any] = Field(default_factory=dict)
    tokens_consumed: int = 0
    cost_receipt: Optional[Dict[str, Any]] = None

    @property
    def is_valid(self) -> bool:
        return self.status == ValidationStatus.VALID

    @property
    def has_blocking_issues(self) -> bool:
        return any(issue.is_blocking for issue in self.issues)
