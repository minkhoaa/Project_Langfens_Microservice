"""Base Evaluator and Metadata abstractions for Langfens Loop Engine V2."""

from __future__ import annotations

import asyncio
import time
from abc import ABC, abstractmethod
from enum import Enum
from typing import List, Optional, Sequence
from pydantic import Field

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.base import CanonicalBaseModel
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.loop.capabilities import EvaluatorCapability
from app.loop.context import LoopContext


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
        try:
            result = await asyncio.wait_for(
                self._evaluate_impl(context, artifact, intent_id),
                timeout=self._metadata.timeout_seconds,
            )
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            if result.elapsed_ms is None:
                # Update elapsed time if not already set by implementation
                return result.model_copy(update={"elapsed_ms": elapsed_ms})
            return result
        except asyncio.TimeoutError:
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            return EvaluationResult.create_error(
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=artifact.to_ref(),
                message=f"Evaluator '{self.evaluator_id}' timed out after {self._metadata.timeout_seconds}s",
                elapsed_ms=elapsed_ms,
            )
        except Exception as ex:
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            return EvaluationResult.create_error(
                evaluator_id=self.evaluator_id,
                evaluator_version=self.evaluator_version,
                target_ref=artifact.to_ref(),
                message=f"Evaluator '{self.evaluator_id}' raised unexpected exception: {type(ex).__name__}: {ex}",
                elapsed_ms=elapsed_ms,
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
