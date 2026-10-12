"""Base Evaluator and Metadata abstractions for Langfens Loop Engine V2."""

from __future__ import annotations

import asyncio
import time
from abc import ABC, abstractmethod
from uuid import uuid4
from enum import Enum
from typing import List, Optional, Sequence
from pydantic import Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.loop.capabilities import EvaluatorCapability
from app.loop.context import LoopContext
from app.providers.base import redact_secrets


class EvaluatorConfigurationError(Exception):
    """Raised when an evaluator configuration, requirement, or conflict is invalid."""


class EvaluatorConflictError(EvaluatorConfigurationError):
    """Raised when two mutually conflicting evaluators are registered or activated."""


class EvaluatorMissingPrerequisiteError(EvaluatorConfigurationError):
    """Raised when an evaluator's prerequisite evaluator has not been registered or run."""


class EvaluationStage(str, Enum):
    """Stage ordering in accordance with P07-02:
    SCHEMA_REF -> DETERMINISTIC -> LEXICAL -> GROUNDING -> SEMANTIC -> SOLVER_ADVERSARY.
    """

    SCHEMA_REF = "SCHEMA_REF"
    DETERMINISTIC = "DETERMINISTIC"
    LEXICAL = "LEXICAL"
    GROUNDING = "GROUNDING"
    SEMANTIC = "SEMANTIC"
    SOLVER_ADVERSARY = "SOLVER_ADVERSARY"

    @property
    def order(self) -> int:
        order_map = {
            EvaluationStage.SCHEMA_REF: 1,
            EvaluationStage.DETERMINISTIC: 2,
            EvaluationStage.LEXICAL: 3,
            EvaluationStage.GROUNDING: 4,
            EvaluationStage.SEMANTIC: 5,
            EvaluationStage.SOLVER_ADVERSARY: 6,
        }
        return order_map[self]


class EvaluatorMetadata(CanonicalBaseModel):
    """Declarative metadata for Evaluator registration, lifecycle, and budget reservation."""

    evaluator_id: str = Field(..., alias="evaluatorId")
    evaluator_version: str = Field(default="1.0.0", alias="evaluatorVersion")
    name: str
    description: str = ""
    stage: EvaluationStage
    target_artifact_types: List[ArtifactType] = Field(..., alias="targetArtifactTypes")
    prerequisite_evaluator_ids: List[str] = Field(default_factory=list, alias="prerequisiteEvaluatorIds")
    required: bool = True
    hard_checks: List[IssueCode] = Field(default_factory=list, alias="hardChecks")
    soft_checks: List[IssueCode] = Field(default_factory=list, alias="softChecks")
    conflict_rules: List[str] = Field(default_factory=list, alias="conflictRules")
    timeout_seconds: float = Field(default=30.0, gt=0, alias="timeoutSeconds")
    estimated_cost_usd: float = Field(default=0.0, ge=0, alias="estimatedCostUsd")
    estimated_tokens: int = Field(default=0, ge=0, alias="estimatedTokens")
    is_expensive: bool = Field(default=False, alias="isExpensive")


class BaseEvaluator(ABC, EvaluatorCapability):
    """Base implementation for all deterministic and semantic evaluators."""

    def __init__(self, metadata: EvaluatorMetadata):
        self._metadata = metadata

    @property
    def metadata(self) -> EvaluatorMetadata:
        return self._metadata

    @property
    def evaluator_id(self) -> str:
        return self._metadata.evaluator_id

    @property
    def evaluator_version(self) -> str:
        return self._metadata.evaluator_version

    @property
    def stage(self) -> EvaluationStage:
        return self._metadata.stage

    @property
    def is_expensive(self) -> bool:
        return self._metadata.is_expensive

    async def evaluate(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        intent_id: str,
    ) -> EvaluationResult:
        """Evaluates the target envelope with bounded timeout and fail-closed error handling."""
        start_time = time.perf_counter()
        target_ref = artifact.to_ref()
        scope = getattr(context, "scope", None) or (
            IssueScope.QUESTION if artifact.artifact_type == ArtifactType.QUESTION
            else IssueScope.PASSAGE if artifact.artifact_type == ArtifactType.PASSAGE
            else IssueScope.SECTION
        )
        try:
            raw_result = await asyncio.wait_for(
                self._evaluate_impl(context, artifact, intent_id),
                timeout=self._metadata.timeout_seconds,
            )
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            if not isinstance(raw_result, EvaluationResult):
                eval_id = f"eval_mal_{uuid4().hex[:12]}"
                return EvaluationResult.create_error(
                    evaluation_id=eval_id,
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=target_ref,
                    error_message=(
                        f"Evaluator '{self.evaluator_id}' returned malformed non-EvaluationResult output "
                        f"of type {type(raw_result).__name__}"
                    ),
                    code=IssueCode.SCHEMA_VIOLATION,
                    elapsed_ms=elapsed_ms,
                    scope=scope,
                )
            if raw_result.status == EvaluationStatus.ERROR and not raw_result.issues:
                eval_id = raw_result.evaluation_id or f"eval_err_{uuid4().hex[:12]}"
                return EvaluationResult.create_error(
                    evaluation_id=eval_id,
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=target_ref,
                    error_message=f"Evaluator '{self.evaluator_id}' returned ERROR status with empty issues list",
                    code=IssueCode.EVALUATOR_UNAVAILABLE,
                    elapsed_ms=elapsed_ms,
                    scope=scope,
                )
            updates: Dict[str, Any] = {}
            if raw_result.elapsed_ms is None:
                updates["elapsed_ms"] = elapsed_ms
            updates["input_dependency_refs"] = list(artifact.parent_refs)
            if raw_result.status == EvaluationStatus.PASS and not raw_result.issues and context and getattr(context, "open_issues", None):
                checked_codes = set(self._metadata.hard_checks) | set(self._metadata.soft_checks)
                resolved_fps = list(raw_result.resolved_issue_fingerprints or [])
                for oi in context.open_issues:
                    if oi.evaluator_id == self.evaluator_id and (not checked_codes or oi.code in checked_codes):
                        for ref in oi.affected_refs:
                            if ref.artifact_id == artifact.artifact_id and artifact.version > ref.version:
                                if oi.fingerprint not in resolved_fps:
                                    resolved_fps.append(oi.fingerprint)
                                break
                if resolved_fps != (raw_result.resolved_issue_fingerprints or []):
                    updates["resolved_issue_fingerprints"] = resolved_fps
            if updates:
                return raw_result.model_copy(update=updates)
            return raw_result
        except asyncio.TimeoutError:
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            eval_id = f"eval_tout_{uuid4().hex[:12]}"
            return EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=f"Evaluator '{self.evaluator_id}' timed out after {self._metadata.timeout_seconds:.1f}s",
                code=IssueCode.EVALUATOR_UNAVAILABLE,
                elapsed_ms=elapsed_ms,
                scope=scope,
            )
        except asyncio.CancelledError:
            # Cancellation MUST preserve runtime cancellation semantics: never swallow!
            raise
        except Exception as ex:
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            eval_id = f"eval_ex_{uuid4().hex[:12]}"
            code = (
                IssueCode.SCHEMA_VIOLATION
                if isinstance(ex, (ValueError, KeyError, TypeError))
                else IssueCode.EVALUATOR_UNAVAILABLE
            )
            sanitized_msg = redact_secrets(f"Evaluator '{self.evaluator_id}' raised unexpected exception: {type(ex).__name__}: {ex}")
            return EvaluationResult.create_error(
                evaluation_id=eval_id,
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=target_ref,
                error_message=sanitized_msg,
                code=code,
                elapsed_ms=elapsed_ms,
                scope=scope,
            )

    @abstractmethod
    async def _evaluate_impl(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        intent_id: str,
    ) -> EvaluationResult:
        """Actual evaluation implementation to be overridden by subclasses."""
        ...
