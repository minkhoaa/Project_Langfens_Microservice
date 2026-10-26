"""Rebuild orphan capability wrappers without authorizing another provider call.

A completed physical response is authoritative; a reserved wrapper is not. During
reconstruction the gateway may read only the exact completed attempts selected
from that wrapper's durable descendants. Missing/uncertain outcomes stay closed.
"""
from contextlib import contextmanager
from contextvars import ContextVar
from dataclasses import dataclass

from app.providers.errors import ProviderError
from app.providers.models import ProviderResponse

PROVIDER_TYPES = frozenset({"PROVIDER_CALL", "LLM", "LLM_CALL", "LLM_PASSAGE"})


def known_wrapper_responses(operations, parent_id):
    by_id = {op.operationId: op for op in operations}
    parent = by_id.get(parent_id)
    if parent is None or parent.status.upper() != "RESERVED" or parent.operationType not in {"GENERATE", "EVALUATE", "REPAIR"}:
        return None
    selected = {parent_id}
    while True:
        descendants = {op.operationId for op in operations if op.parentOperationId in selected}
        if descendants <= selected:
            break
        selected |= descendants
    physical = set()
    for oid in selected - {parent_id}:
        op = by_id[oid]
        if op.status.upper() != "COMPLETED":
            return None
        if op.operationType in PROVIDER_TYPES:
            if not op.resultRefJson:
                return None
            try:
                ProviderResponse.model_validate_json(op.resultRefJson)
            except Exception:
                return None
            physical.add(oid)
    return frozenset(physical) if physical else None


@dataclass
class ProviderReplayScope:
    allowed: frozenset[str]
    failure: str | None = None

    def reject(self, message):
        self.failure = message
        raise ProviderError("Read-only provider recovery: " + message, is_retryable=False, status_code=409)


_current: ContextVar[ProviderReplayScope | None] = ContextVar("provider_replay_only", default=None)


def current_replay_scope():
    return _current.get()


@contextmanager
def provider_replay_only(allowed=None):
    outer = _current.get()
    if allowed is None:
        yield outer
        return
    scope = ProviderReplayScope(allowed if outer is None else allowed & outer.allowed)
    token = _current.set(scope)
    try:
        yield scope
    finally:
        _current.reset(token)
        if outer is not None and scope.failure:
            outer.failure = scope.failure
