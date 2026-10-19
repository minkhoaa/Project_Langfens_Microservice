"""Validator for IELTS ordering-family question types (FLOW_CHART)."""
from __future__ import annotations

from typing import Any, Dict, List, Set, Tuple

from app.validation.common import STEP_SLUG_RE
from app.validation.models import (
    IssueCode,
    Repairability,
    ScoredItemValidation,
    ValidationIssue,
    ValidationPolicy,
    ValidationSeverity,
)
from app.validation.registry import BaseQuestionValidator


class FlowChartValidator(BaseQuestionValidator):
    @property
    def question_type(self) -> str:
        return "FLOW_CHART"

    @property
    def allowed_answer_fields(self) -> Set[str]:
        return {"orderCorrects"}

    def validate_answer_key(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> Tuple[List[ValidationIssue], List[ScoredItemValidation]]:
        issues: List[ValidationIssue] = []
        scored_items: List[ScoredItemValidation] = []

        order = question.get("orderCorrects")
        if not isinstance(order, list) or len(order) < 2:
            issues.append(
                ValidationIssue(
                    code=IssueCode.ERR_MISSING_ANSWER_KEY,
                    message="FLOW_CHART: orderCorrects must be an array of at least 2 step slugs",
                    severity=ValidationSeverity.CRITICAL,
                    field_path="orderCorrects",
                    repairability=Repairability.IRREPARABLE,
                )
            )
            return issues, scored_items

        seen_slugs: Set[str] = set()
        valid_slugs: List[str] = []

        for i, slug in enumerate(order):
            if not isinstance(slug, str) or not STEP_SLUG_RE.match(slug.strip()):
                issues.append(
                    ValidationIssue(
                        code=IssueCode.ERR_FLOW_CHART_SLUG_INVALID,
                        message=f"FLOW_CHART: orderCorrects[{i}] '{slug}' must match ^[a-z0-9]+(?:-[a-z0-9]+)*$",
                        field_path=f"orderCorrects[{i}]",
                        scored_item_index=i + 1,
                    )
                )
            else:
                clean_s = slug.strip()
                if clean_s in seen_slugs:
                    issues.append(
                        ValidationIssue(
                            code=IssueCode.ERR_FLOW_CHART_SLUG_DUPLICATE,
                            message=f"FLOW_CHART: duplicate step slug '{clean_s}' in orderCorrects",
                            field_path=f"orderCorrects[{i}]",
                            scored_item_index=i + 1,
                        )
                    )
                seen_slugs.add(clean_s)
                valid_slugs.append(clean_s)

        scored_items.append(
            ScoredItemValidation(
                item_index=1,
                item_key="sequence",
                is_valid=len(issues) == 0,
                accepted_answers=valid_slugs,
            )
        )
        return issues, scored_items

    def validate_type_specific(
        self, question: Dict[str, Any], policy: ValidationPolicy
    ) -> List[ValidationIssue]:
        return []
