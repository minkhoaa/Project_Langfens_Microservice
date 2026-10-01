"""Capability interfaces for Generator, Evaluator, and Repairer injection.

Runtime injects capabilities via these interfaces; no IELTS prompts or vendor-specific
logic exist inside the loop engine runtime itself.
"""

from __future__ import annotations

from typing import Protocol, Sequence, runtime_checkable

from app.contracts.artifact import ArtifactEnvelope
from app.contracts.evaluation import EvaluationResult
from app.contracts.issue import Issue
from app.loop.context import LoopContext


@runtime_checkable
class GeneratorCapability(Protocol):
    """Capability for generating a new version of an artifact."""

    @property
    def name(self) -> str:
        """Name of the generator capability."""
        ...

    @property
    def version(self) -> str:
        """Version of the generator capability."""
        ...

    async def generate(
        self,
        context: LoopContext,
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        """Generates an artifact envelope at the specified version."""
        ...


@runtime_checkable
class EvaluatorCapability(Protocol):
    """Capability for evaluating an artifact version."""

    @property
    def evaluator_id(self) -> str:
        """Unique ID of this evaluator."""
        ...

    @property
    def evaluator_version(self) -> str:
        """Version of this evaluator."""
        ...

    async def evaluate(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        intent_id: str,
    ) -> EvaluationResult:
        """Evaluates the target artifact envelope, returning an EvaluationResult."""
        ...


@runtime_checkable
class RepairerCapability(Protocol):
    """Capability for surgically repairing an artifact version based on specific issues."""

    @property
    def repairer_id(self) -> str:
        """Unique ID of this repairer."""
        ...

    @property
    def repairer_version(self) -> str:
        """Version of this repairer."""
        ...

    async def repair(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        """Applies targeted surgical repair to the artifact, producing a new envelope version."""
        ...
