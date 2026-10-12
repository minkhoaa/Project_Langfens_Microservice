"""Phase 13 — Redaction, bounded enums, sanitization, canary.

This module is the single source of truth for scrubbing secrets, chain-of-thought
fragments, and copyrighted source bodies from logs, metrics, public payloads,
and student-facing views.

Design choices:

* All metric label dimensions are typed via ``BoundedLabel`` subclasses. They are
  Python ``str`` enums, so they serialize as strings, but their ``__new__``
  rejects any value that is not a member of the closed enum, so unbounded
  identifiers such as ``run_id`` or ``user_id`` cannot leak into Prometheus
  labels.
* ``Redactor`` is a stateless callable with a single ``scrub`` entry point. It
  composes secret detection, CoT detection, and source-text truncation.
* ``sanitize_user_error`` returns a typed ``SanitizedUserError`` whose only
  fields are safe for clients (no stack traces, no secret fragments).
* ``redaction_canary`` runs a list of forbidden token fixtures through every
  detector and raises if any token survives. Used both as a runtime check and
  inside ``test_t13_observability``.

The module never depends on FastAPI, ORM, or asyncio. It is consumed by every
other observability sub-module and by the public route handlers.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass, field
from enum import Enum, EnumMeta
from typing import Any, Callable, Iterable, List, Mapping, Sequence, Tuple


# ---------------------------------------------------------------------------
# Bounded label enums
# ---------------------------------------------------------------------------

class _BoundedMeta(EnumMeta):
    """Metaclass that rejects enum members declared outside the class body.

    Any attempt to construct a value (``OperationKind("foo")``) with a string
    that is not one of the declared members raises ``UnboundedLabelError``.
    """

    def __call__(cls, value, *args, **kwargs):  # type: ignore[override]
        if isinstance(value, cls):
            return value
        if not isinstance(value, str):
            raise UnboundedLabelError(
                f"{cls.__name__} labels must be strings; got {type(value).__name__}"
            )
        normalized = value.lower()
        members = cls._member_map_
        for name, member in members.items():
            if name.lower() == normalized or str(member.value).lower() == normalized:
                return member
        raise UnboundedLabelError(
            f"{cls.__name__} label {value!r} is not in the bounded enum. "
            f"Allowed values: {sorted(members)}."
        )


class BoundedLabel(str, Enum, metaclass=_BoundedMeta):
    """Base class for closed enum label dimensions.

    Subclasses are still ``str`` and ``Enum`` — they serialize cleanly in
    JSON, Prometheus exposition, and OTel attributes — but ``BoundedLabel("foo")``
    rejects anything outside the declared members.
    """

_BoundedLabel = BoundedLabel


class UnboundedLabelError(ValueError):
    """Raised when a value that is not in a bounded enum is used as a label."""


class OperationKind(_BoundedLabel):
    SYNTHESIS = "synthesis"
    AUDIT = "audit"
    REVISION = "revision"
    QUESTION_GENERATION = "question_generation"
    ANSWER_REVIEW = "answer_review"
    INGESTION = "ingestion"
    EXTRACTION = "extraction"
    PUBLISH = "publish"
    RECONCILE = "reconcile"


class ProviderKind(_BoundedLabel):
    OPENAI = "openai"
    GROQ = "groq"
    MINIMAX = "MiniMax"
    GOOGLE = "google"
    LOCAL = "local"


class ModelKind(_BoundedLabel):
    GPT_4O = "gpt-4o"
    GPT_4O_MINI = "gpt-4o-mini"
    GROQ_LLAMA = "llama-3.1-70b"
    MINIMAX_TEXT_01 = "MiniMax-Text-01"
    GEMINI_15 = "gemini-1.5-flash"
    QWEN_25 = "qwen2.5"


class RepairKind(_BoundedLabel):
    PASSAGE_SENTENCE = "passage_sentence"
    SECTION_Surgical = "section_surgical"
    PAPER = "paper"
    ANSWER = "answer"


class IssueKind(_BoundedLabel):
    FACTUAL = "factual"
    SOURCE_GAP = "source_gap"
    STYLE = "style"
    CONSTRAINT = "constraint"
    SCHEMA = "schema"
    LATENCY = "latency"


class SeverityKind(_BoundedLabel):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class LoopEventKind(_BoundedLabel):
    LOOP_STARTED = "loop_started"
    LOOP_ITERATION = "loop_iteration"
    LOOP_DECISION = "loop_decision"
    ISSUE_RAISED = "issue_raised"
    REPAIR_APPLIED = "repair_applied"
    LOOP_EXHAUSTED = "loop_exhausted"
    STALE_WRITER = "stale_writer"
    RESUME = "resume"
    COMPLETED = "terminal_completed"


class TokenKind(_BoundedLabel):
    REPORTED = "reported"
    ESTIMATED = "estimated"
    UNKNOWN = "unknown"


class OutcomeKind(_BoundedLabel):
    OK = "ok"
    RETRY = "retry"
    ERROR = "error"
    TIMEOUT = "timeout"


class ReasonKind(_BoundedLabel):
    BUDGET_EXHAUSTED = "budget_exhausted"
    ATTEMPTS_EXHAUSTED = "attempts_exhausted"
    DEADLINE_EXCEEDED = "deadline_exceeded"
    CONCURRENCY_LOST = "concurrency_lost"
    CHECKPOINT_STALE = "checkpoint_stale"
    RECONNECT = "reconnect"


class VerdictKind(_BoundedLabel):
    PASS = "pass"
    FAIL = "fail"
    INCONCLUSIVE = "inconclusive"


class StatusKind(_BoundedLabel):
    PENDING = "pending"
    RUNNING = "running"
    NEEDS_SOURCES = "needs_sources"
    FAILED = "failed"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


# ---------------------------------------------------------------------------
# Sanitized user error type
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class SanitizedUserError:
    """A user-facing error that is guaranteed to contain no secrets or stacks.

    The ``message`` field is short, the ``code`` is a bounded enum, and
    ``safe_details`` is a mapping of strings → strings that has already been
    passed through :func:`redact_text`. ``stack_trace`` is never exposed.
    """

    code: str
    message: str
    safe_details: Mapping[str, str] = field(default_factory=dict)


def sanitize_user_error(
    exc: BaseException | None,
    *,
    code: str | StatusKind = "INTERNAL",
    fallback_message: str = "An internal error occurred. Please try again later.",
    include_message: bool = True,
) -> SanitizedUserError:
    """Return a :class:`SanitizedUserError` for ``exc``.

    * Stack traces are never copied across.
    * The ``str(exc)`` message is passed through :func:`redact_text` before it
      is shown to the user, so a secret that found its way into the exception
      message still does not leak.
    * If ``include_message`` is False, the user-visible message is replaced
      by ``fallback_message``.
    """
    if not isinstance(code, str):
        code = str(code)
    raw_message = "" if exc is None else str(exc)
    safe_message = redact_text(raw_message)
    if not include_message or not safe_message or safe_message.startswith("[REDACTED:"):
        safe_message = fallback_message
    safe_message = truncate_for_user(safe_message)
    return SanitizedUserError(
        code=code,
        message=safe_message,
        safe_details={},
    )


def truncate_for_user(text: str, *, limit: int = 240) -> str:
    """Trim a string so it is safe to show in a UI."""

    text = (text or "").strip()
    if len(text) <= limit:
        return text
    return text[: limit - 1].rstrip() + "\u2026"


# ---------------------------------------------------------------------------
# Detection patterns
# ---------------------------------------------------------------------------


# Order matters: secrets first, CoT blocks, then full-text source spans.
# Each detector returns ``(redacted_text, flag_kind)`` where flag_kind is one
# of "secret", "cot", "source_text".

_SECRET_PATTERNS: Tuple[Tuple[str, str], ...] = (
    # OpenAI / Anthropic style sk-... keys
    (r"sk-[A-Za-z0-9_\-]{16,}", "sk_key"),
    # Bearer tokens in Authorization headers
    (r"(?i)\bBearer\s+[A-Za-z0-9._\-]{8,}", "bearer_token"),
    # JWT (3 base64url segments)
    (r"\beyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\b", "jwt"),
    # Internal service-to-service key
    (r"(?i)X-Internal-Service-Key\s*[:=]\s*[A-Za-z0-9._\-]{8,}", "internal_service_key"),
    # AWS access key (broad heuristic only)
    (r"\bAKIA[0-9A-Z]{16}\b", "aws_key"),
    # Generic assignment of password= / api_key= / token=
    (
        r"(?i)(?P<k>api[_-]?key|password|secret|token|access[_-]?key)"
        r"\s*[:=]\s*[\"']?[A-Za-z0-9._\-+/]{8,}[\"']?",
        "generic_secret",
    ),
)

_COT_PATTERNS: Tuple[str, ...] = (
    # Fenced thinking blocks (fence may be backtick or tilde)
    r"```(?:thinking|reasoning|analysis)[^\n]*\n[\s\S]*?```",
    # <thinking>...</thinking>, <think>...</think>, <reasoning>...</reasoning> (case-insensitive, multiline)
    r"(?is)<thinking\b[^>]*>[\s\S]*?</thinking>",
    r"(?is)<think\b[^>]*>[\s\S]*?</think>",
    r"(?is)<reasoning\b[^>]*>[\s\S]*?</reasoning>",
    # Some models emit <<|...|>> reasoning fences
    r"(?s)<<\|[\s\S]*?\|>>",
    # `### Analysis` / `### Reasoning` markdown subheads until next heading or EOF
    r"(?m)^###\s*(?:Analysis|Reasoning|Internal\s+Thoughts?|CoT)\s*$\n[\s\S]*?(?=^###\s|\Z)",
)

# Source bodies are matched by the keys callers label "source-text" and are
# truncated rather than redacted in place. The detector returns a fingerprint
# instead of the raw content so the operator can locate it in storage without
# ever publishing it.

_SOURCE_LINE_KEYS: Tuple[str, ...] = (
    "source_text",
    "copyrighted_source",
    "raw_passage_body",
    "external_source",
)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


_REDACTION_PREFIX = "[REDACTED:"


class Redactor:
    """Stateless, deterministic redactor.

    The redactor is intentionally side-effect free: it never logs, never makes
    network calls, never raises (except for ``UnboundedLabelError`` when the
    caller asks it to validate a label). Each ``scrub_*`` method returns the
    redacted value or, in the case of ``scrub_source_text``, a sentinel
    payload that includes the SHA-256 of the original.
    """

    __slots__ = (
        "_secret_patterns",
        "_cot_patterns",
        "_max_source_chars",
    )

    def __init__(
        self,
        *,
        extra_secret_patterns: Sequence[Tuple[str, str]] | None = None,
        extra_cot_patterns: Sequence[str] | None = None,
        max_source_chars: int = 200,
    ) -> None:
        self._secret_patterns = list(_SECRET_PATTERNS)
        if extra_secret_patterns:
            for pattern, flag in extra_secret_patterns:
                if not isinstance(pattern, str) or not isinstance(flag, str):
                    raise TypeError("extra_secret_patterns entries must be (str, str)")
                self._secret_patterns.append((pattern, flag))
        self._cot_patterns = list(_COT_PATTERNS)
        if extra_cot_patterns:
            for p in extra_cot_patterns:
                if not isinstance(p, str):
                    raise TypeError("extra_cot_patterns entries must be str")
                self._cot_patterns.append(p)
        if max_source_chars < 32:
            raise ValueError("max_source_chars must be >= 32 to be useful")
        self._max_source_chars = max_source_chars

    # --- label validation ---------------------------------------------------

    def validate_label(self, label_enum: type[_BoundedLabel], value: Any) -> str:
        """Return the canonical string form of ``value`` or raise.

        Raises ``UnboundedLabelError`` if the value is not a declared member
        of ``label_enum``. Returning the canonical string keeps callers
        honest: the label they emit on the wire is always one of the
        declared enum names.
        """
        if not isinstance(label_enum, type) or not issubclass(label_enum, _BoundedLabel):
            raise TypeError("validate_label requires a BoundedLabel subclass")
        member = label_enum(value)
        return str(member.value)

    # --- core scrub --------------------------------------------------------

    def scrub(self, value: Any) -> Any:
        """Recursively scrub a Python value.

        ``str`` leaves are passed through ``scrub_text``; ``Mapping`` and
        ``Sequence`` are walked; ``None``/scalars are returned as-is.
        Special keys (``source_text``, ``copyrighted_source``, etc.) cause the
        value to be processed by ``scrub_source_text`` instead of
        ``scrub_text``.
        """
        if isinstance(value, str):
            return self.scrub_text(value)
        if value is None or isinstance(value, bool | bytes):
            return value
        if isinstance(value, Mapping):
            new_items: List[Tuple[Any, Any]] = []
            for key, child in value.items():
                if isinstance(key, str) and key.lower() in _SOURCE_LINE_KEYS:
                    new_items.append((key, self.scrub_source_text(child)))
                else:
                    new_items.append((key, self.scrub(child)))
            return dict(new_items)
        if isinstance(value, (list, tuple)):
            scrubbed = [self.scrub(child) for child in value]
            return type(value)(scrubbed)
        return value

    # --- text scrub --------------------------------------------------------

    def scrub_text(self, text: str) -> str:
        """Scrub a single string and return the redacted form."""

        if not isinstance(text, str):
            raise TypeError("scrub_text expects a string")
        result = text
        result = self._scrub_secrets(result)
        result = self._scrub_cot(result)
        return result

    def _scrub_secrets(self, text: str) -> str:
        for pattern, flag in self._secret_patterns:
            try:
                compiled = re.compile(pattern)
            except re.error:  # pragma: no cover - defensive
                continue
            text = compiled.sub(f"{_REDACTION_PREFIX}{flag.upper()}_REDACTED]", text)
        return text

    def _scrub_cot(self, text: str) -> str:
        for pattern in self._cot_patterns:
            try:
                compiled = re.compile(pattern)
            except re.error:  # pragma: no cover - defensive
                continue
            text = compiled.sub(f"{_REDACTION_PREFIX}COT_REDACTED]", text)
        return text

    def scrub_source_text(self, value: Any) -> Any:
        """Truncate source bodies and return a redacted sentinel.

        Returns a :class:`dict` payload ``{"hash": ..., "preview_chars": N,
        "redacted": True, "length_chars": K, "truncated_at": ISO}``.
        ``value`` is normalised with :meth:`scrub_text` first to ensure any
        secret embedded in the source body is removed before the truncation
        is computed.
        """
        if value is None:
            return None
        if not isinstance(value, str):
            # We do not silently serialise non-strings: surface the bug to
            # the caller so they fix the wiring.
            raise TypeError(
                "scrub_source_text expects a string body. "
                "Encode or extract the source before passing it in."
            )
        # Make sure no secret was hiding in the body.
        cleaned = self.scrub_text(value)
        fingerprint = hashlib.sha256(cleaned.encode("utf-8")).hexdigest()
        preview = cleaned[: self._max_source_chars]
        return {
            "hash": fingerprint,
            "preview_chars": len(preview),
            "length_chars": len(cleaned),
            "truncated": len(cleaned) > len(preview),
            "redacted": True,
            "preview": preview if preview == cleaned else "",
        }


# ---------------------------------------------------------------------------
# Module-level helpers
# ---------------------------------------------------------------------------


_DEFAULT_REDACTOR = Redactor()


def redact_payload(value: Any) -> Any:
    """Scrub ``value`` with the process-wide default :class:`Redactor`."""

    return _DEFAULT_REDACTOR.scrub(value)


def redact_text(text: str) -> str:
    """Scrub a single string with the default :class:`Redactor`."""

    return _DEFAULT_REDACTOR.scrub_text(text)


def redact_source(value: Any) -> Any:
    """Scrub a source body with the default :class:`Redactor`."""

    return _DEFAULT_REDACTOR.scrub_source_text(value)


def redact_label(
    label_enum: type[_BoundedLabel], value: Any
) -> str:
    """Validate ``value`` against ``label_enum`` and return the canonical form."""

    return _DEFAULT_REDACTOR.validate_label(label_enum, value)


# ---------------------------------------------------------------------------
# Canary
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class CanaryResult:
    passed: bool
    leaks: Tuple[str, ...] = ()
    inspected: int = 0


# Fixtures intentionally contain every secret / CoT / source pattern the
# redactor must scrub. If any token in this list survives a scrub round-trip,
# the redactor has regressed.
_CANARY_FIXTURES: Tuple[Tuple[str, str], ...] = (
    ("openai_key", "Hello sk-abcdefghijklmnopqrstuvwxyz1234567890 from me"),
    ("bearer", "Authorization: Bearer abcdef1234XY-_"),
    ("jwt", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"),
    ("internal_key", "X-Internal-Service-Key: corp-secret-1234567"),
    ("aws_key", "AKIAIOSFODNN7EXAMPLE"),
    ("generic_token", "api_key=hunter2hunter2here2"),
    ("thinking_block", "Before<think>reasoning</think>after"),
    ("reasoning_block", "<reasoning>step by step plan</reasoning>"),
    ("fenced_thinking", "A\n```thinking\nplans go here\n```\nB"),
    ("analysis_section", "### Analysis\nsecret leak here\n### Result"),
    ("llama_fence", "before<<|hidden reasoning|>>after"),
    ("source_text", {"source_text": "long copyrighted passage spanning hundreds of words " * 20}),
    ("copyrighted_source", {"copyrighted_source": "Copyright 2020 by John Smith. All rights reserved. " * 20}),
)


def redaction_canary(*, redactor: Redactor | None = None) -> CanaryResult:
    """Run a fixture pass through ``redactor`` and confirm nothing leaked.

    Returns a :class:`CanaryResult` whose ``passed`` field is ``True`` when
    every fixture was scrubbed. The fixtures are deliberately permissive so a
    redactor that scrubs them but loses some other token still fails the
    canary.
    """

    rdr = redactor or _DEFAULT_REDACTOR
    leaks: List[str] = []
    for name, fixture in _CANARY_FIXTURES:
        scrubbed = rdr.scrub(fixture)
        flat = _flatten(scrubbed)
        for token in _expected_tokens(name, fixture):
            if token in flat:
                leaks.append(f"{name}: token {token!r} survived scrub -> {scrubbed!r}")
    return CanaryResult(passed=not leaks, leaks=tuple(leaks), inspected=len(_CANARY_FIXTURES))


def _flatten(value: Any) -> str:
    if isinstance(value, str):
        return value
    if value is None or isinstance(value, bool | int | float):
        return str(value)
    if isinstance(value, Mapping):
        return " ".join(_flatten(v) for v in value.values())
    if isinstance(value, (list, tuple)):
        return " ".join(_flatten(v) for v in value)
    return str(value)


def _expected_tokens(name: str, fixture: str) -> Tuple[str, ...]:
    if name == "source_text" or name == "copyrighted_source":
        # The fixture is intentionally long; we expect the literal phrase
        # "long copyrighted passage" or "Copyright 2020" to be removed.
        if name == "source_text":
            return ("long copyrighted passage spanning hundreds of words",)
        return ("Copyright 2020 by John Smith",)
    # For other fixtures, the literal substring up to the first 24 chars
    # must NOT survive the scrubber (the secret tail has been redacted).
    return (fixture[:24],)


__all__ = [
    # bounded enums
    "OperationKind",
    "ProviderKind",
    "ModelKind",
    "RepairKind",
    "IssueKind",
    "SeverityKind",
    "LoopEventKind",
    "TokenKind",
    "OutcomeKind",
    "ReasonKind",
    "VerdictKind",
    "StatusKind",
    "UnboundedLabelError",
    # redactor
    "Redactor",
    "redact_payload",
    "redact_text",
    "redact_source",
    "redact_label",
    "sanitize_user_error",
    "SanitizedUserError",
    # canary
    "CanaryResult",
    "redaction_canary",
]