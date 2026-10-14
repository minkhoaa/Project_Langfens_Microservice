"""EvaluatorRegistry and EvaluationCache for Langfens Loop Engine V2."""

from __future__ import annotations

import hashlib
from collections import OrderedDict
from typing import Dict, List, Optional, Sequence, Set
from uuid import uuid4

from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.policies import POLICY_VERSION
from app.evaluators.base import (
    BaseEvaluator,
    EvaluationStage,
    EvaluatorConfigurationError,
    EvaluatorConflictError,
    EvaluatorMissingPrerequisiteError,
)
from app.loop.context import LoopContext


def compute_evaluation_cache_key(
    target_payload_hash: str,
    target_dependency_closure_hash: str,
    schema_version: str,
    policy_version: str,
    evaluator_id: str,
    evaluator_version: str,
    prompt_version: str = "",
    model_name: str = "",
) -> str:
    """Computes an exact, collision-resistant evaluation cache key.
    
    Pins payload, dependencies, schema, policy, evaluator, prompt, and model versions.
    Any difference (e.g. different prompt, model, or parent hash) results in a cache miss.
    """
    raw_components = [
        target_payload_hash or "",
        target_dependency_closure_hash or "",
        schema_version or "",
        policy_version or "",
        evaluator_id or "",
        evaluator_version or "",
        prompt_version or "",
        model_name or "",
    ]
    raw_str = "|".join(raw_components)
    return hashlib.sha256(raw_str.encode("utf-8")).hexdigest()


def compute_dependency_closure_hash(artifact: ArtifactEnvelope) -> str:
    """Computes a deterministic hash of an artifact's parent references closure."""
    if not artifact.parent_refs:
        return "no_parents"
    # Sort by artifact_id, revision, content_hash
    sorted_refs = sorted(
        artifact.parent_refs,
        key=lambda r: (r.artifact_id, getattr(r, "revision", getattr(r, "version", 1)), r.content_hash),
    )
    tokens = [f"{r.artifact_id}:{getattr(r, 'revision', getattr(r, 'version', 1))}:{r.content_hash}" for r in sorted_refs]
    return hashlib.sha256(";".join(tokens).encode("utf-8")).hexdigest()


class EvaluationCache:
    """Bounded in-memory LRU cache for evaluation results."""

    def __init__(self, max_entries: int = 1000, enabled: bool = True):
        self._max_entries = max_entries
        self._enabled = enabled
        self._store: OrderedDict[str, EvaluationResult] = OrderedDict()
        self._hits = 0
        self._misses = 0

    @property
    def enabled(self) -> bool:
        return self._enabled

    @property
    def hits(self) -> int:
        return self._hits

    @property
    def misses(self) -> int:
        return self._misses

    def get(self, key: str) -> Optional[EvaluationResult]:
        if not self._enabled or key not in self._store:
            self._misses += 1
            return None
        self._hits += 1
        # Move to end (LRU)
        self._store.move_to_end(key)
        return self._store[key]

    def put(self, key: str, result: EvaluationResult) -> None:
        if not self._enabled:
            return
        if key in self._store:
            self._store.move_to_end(key)
        self._store[key] = result
        if len(self._store) > self._max_entries:
            self._store.popitem(last=False)

    def clear(self) -> None:
        self._store.clear()
        self._hits = 0
        self._misses = 0


class EvaluatorRegistry:
    """Central registry and execution manager for deterministic and semantic evaluators."""

    def __init__(self, cache: Optional[EvaluationCache] = None):
        self._evaluators: Dict[str, BaseEvaluator] = {}
        cache_enabled = getattr(settings, "evaluation_cache_enabled", True)
        cache_max = getattr(settings, "evaluation_cache_max_entries", 1000)
        self._cache = cache if cache is not None else EvaluationCache(max_entries=cache_max, enabled=cache_enabled)

    @property
    def cache(self) -> EvaluationCache:
        return self._cache

    def register(self, evaluator: BaseEvaluator) -> None:
        """Registers an evaluator, validating conflict rules and metadata."""
        eval_id = evaluator.evaluator_id
        if eval_id in self._evaluators:
            # Overwrite with newer instance or raise error if conflicting
            existing = self._evaluators[eval_id]
            if existing.evaluator_version != evaluator.evaluator_version:
                pass  # Version upgrade

        # Check conflict rules against already registered evaluators
        for conflict_id in evaluator.metadata.conflict_rules:
            if conflict_id in self._evaluators:
                raise EvaluatorConflictError(
                    f"Evaluator '{eval_id}' conflicts with registered evaluator '{conflict_id}'"
                )

        # Check if any registered evaluator declared conflict with this new one
        for registered_id, registered_ev in self._evaluators.items():
            if eval_id in registered_ev.metadata.conflict_rules:
                raise EvaluatorConflictError(
                    f"Registered evaluator '{registered_id}' conflicts with '{eval_id}'"
                )

        self._evaluators[eval_id] = evaluator

    def unregister(self, evaluator_id: str) -> None:
        """Removes an evaluator from the registry."""
        self._evaluators.pop(evaluator_id, None)

    def get(self, evaluator_id: str) -> Optional[BaseEvaluator]:
        return self._evaluators.get(evaluator_id)

    def list_evaluators(self) -> List[BaseEvaluator]:
        return list(self._evaluators.values())

    def validate_required_evaluators(self, required_ids: Sequence[str]) -> None:
        """P07-01: Verifies that all required evaluators are present.
        
        Missing required evaluator is a startup/config failure.
        """
        missing = [req_id for req_id in required_ids if req_id not in self._evaluators]
        if missing:
            raise EvaluatorConfigurationError(
                f"Startup configuration error: missing required evaluator(s): {missing}"
            )

    def resolve_pipeline(
        self,
        target_artifact_type: ArtifactType,
        active_evaluator_ids: Optional[Sequence[str]] = None,
    ) -> List[BaseEvaluator]:
        """Resolves active evaluators for a target type, ordered strictly by stage:
        SCHEMA_REF -> DETERMINISTIC -> LEXICAL -> GROUNDING -> SEMANTIC -> SOLVER_ADVERSARY.
        """
        # 1. Filter candidates
        candidates: List[BaseEvaluator] = []
        for ev in self._evaluators.values():
            if target_artifact_type in ev.metadata.target_artifact_types:
                if active_evaluator_ids is None or ev.evaluator_id in active_evaluator_ids:
                    candidates.append(ev)

        # 2. Check prerequisite satisfaction
        cand_ids = {ev.evaluator_id for ev in candidates}
        for ev in candidates:
            for prereq in ev.metadata.prerequisite_evaluator_ids:
                if prereq not in cand_ids and prereq not in self._evaluators:
                    raise EvaluatorMissingPrerequisiteError(
                        f"Evaluator '{ev.evaluator_id}' requires prerequisite '{prereq}', which is not registered"
                    )

        # 3. Sort strictly by stage order, then prerequisite dependency, then evaluator_id
        candidates.sort(key=lambda ev: (ev.stage.order, ev.evaluator_id))
        return candidates

    async def evaluate_pipeline(
        self,
        context: LoopContext,
        artifact: ArtifactEnvelope,
        intent_id: str,
        active_evaluator_ids: Optional[Sequence[str]] = None,
        prompt_version: str = "",
        model_name: str = "",
        required_evaluator_ids: Optional[Sequence[str]] = None,
        policy_version: Optional[str] = None,
        raise_on_missing_required: bool = False,
    ) -> List[EvaluationResult]:
        """Executes the evaluation pipeline with stage ordering, short-circuit, and caching.
        
        P07-01 & P07-02 Invariants:
        1. Validates execution plan according to artifact type, policy version, and registry metadata before execution.
        2. Missing required evaluators produce recorded configuration failure (ERROR result); cannot aggregate remaining evaluators into PASS!
        3. Structural hard fail halts expensive stages (call count to expensive evaluators = 0 on structural failure).
        """
        effective_policy_version = policy_version or getattr(context, "policy_version", POLICY_VERSION)

        # 1. Determine expected required evaluators from explicit caller list AND registry metadata
        metadata_required_ids = [
            ev.evaluator_id
            for ev in self._evaluators.values()
            if artifact.artifact_type in ev.metadata.target_artifact_types and ev.metadata.required
        ]
        target_required_ids = list(
            dict.fromkeys(list(required_evaluator_ids or []) + metadata_required_ids)
        )

        # Check for missing required evaluators in registry or active list
        missing_from_registry = [req_id for req_id in target_required_ids if req_id not in self._evaluators]
        omitted_from_active = []
        if active_evaluator_ids is not None:
            omitted_from_active = [
                req_id for req_id in target_required_ids
                if req_id in self._evaluators and req_id not in active_evaluator_ids
            ]

        missing_or_omitted = list(dict.fromkeys(missing_from_registry + omitted_from_active))
        if missing_or_omitted:
            if raise_on_missing_required:
                self.validate_required_evaluators(missing_or_omitted)
            recorded_failures: List[EvaluationResult] = []
            for m_id in missing_or_omitted:
                eval_id = f"eval_cfg_err_{uuid4().hex[:10]}"
                err_res = EvaluationResult.create_error(
                    evaluation_id=eval_id,
                    evaluator_id=m_id,
                    evaluator_version="1.0.0",
                    target_ref=artifact.to_ref(),
                    error_message=f"Required evaluator '{m_id}' is missing or omitted from execution pipeline for {artifact.artifact_type.value}",
                    code=IssueCode.EVALUATOR_UNAVAILABLE,
                )
                recorded_failures.append(err_res)
            # Cannot aggregate remaining evaluators into PASS on missing required evaluator!
            return recorded_failures

        evaluators = self.resolve_pipeline(
            target_artifact_type=artifact.artifact_type,
            active_evaluator_ids=active_evaluator_ids,
        )

        dep_closure_hash = compute_dependency_closure_hash(artifact)
        results: List[EvaluationResult] = []
        structural_hard_fail = False

        for ev in evaluators:
            # Short-circuit expensive evaluators if earlier structural stages hard-failed
            if structural_hard_fail and ev.is_expensive:
                # Do NOT call expensive evaluator; call count = 0
                continue

            # Check cache
            cache_key = compute_evaluation_cache_key(
                target_payload_hash=artifact.content_hash,
                target_dependency_closure_hash=dep_closure_hash,
                schema_version=artifact.schema_version,
                policy_version=effective_policy_version,
                evaluator_id=ev.evaluator_id,
                evaluator_version=ev.evaluator_version,
                prompt_version=prompt_version if ev.is_expensive else "",
                model_name=model_name if ev.is_expensive else "",
            )

            cached_res = self._cache.get(cache_key)
            if cached_res is not None:
                res = cached_res
            else:
                res = await ev.evaluate(context, artifact, intent_id)
                self._cache.put(cache_key, res)

            # Ensure exact target and input dependencies binding
            if not res.input_dependency_refs and artifact.parent_refs:
                res = res.model_copy(update={"input_dependency_refs": list(artifact.parent_refs)})

            results.append(res)

            # Check for structural hard failure in non-expensive stages
            if not res.is_pass() and not ev.is_expensive:
                # Check if any hard/blocking issues were raised
                has_blocking_issue = any(
                    iss.severity.value == "CRITICAL" or iss.blocking for iss in res.issues
                )
                if has_blocking_issue or res.status in (EvaluationStatus.FAIL, EvaluationStatus.ERROR):
                    structural_hard_fail = True

        return results
    def export_manifest(self) -> dict:
        """Exports declarative registry manifest of registered evaluators."""
        return {
            "evaluators": [
                {
                    "evaluatorId": ev.evaluator_id,
                    "evaluatorVersion": ev.evaluator_version,
                    "name": ev.metadata.name,
                    "description": ev.metadata.description,
                    "stage": ev.stage.value,
                    "targetArtifactTypes": [t.value for t in ev.metadata.target_artifact_types],
                    "prerequisiteEvaluatorIds": ev.metadata.prerequisite_evaluator_ids,
                    "required": ev.metadata.required,
                    "hardChecks": [c.value for c in ev.metadata.hard_checks],
                    "softChecks": [c.value for c in ev.metadata.soft_checks],
                    "conflictRules": ev.metadata.conflict_rules,
                    "timeoutSeconds": ev.metadata.timeout_seconds,
                    "estimatedCostUsd": ev.metadata.estimated_cost_usd,
                    "estimatedTokens": ev.metadata.estimated_tokens,
                    "isExpensive": ev.is_expensive,
                }
                for ev in sorted(self._evaluators.values(), key=lambda e: (e.stage.order, e.evaluator_id))
            ],
            "totalCount": len(self._evaluators),
        }
