"""Phase-14 Dataset Exporter for Curated Gold Sets and Blind Solver Benchmarks.

Provides:
- Full Curated Dataset export (with lineage, ground truth, reasons, source licenses).
- Blind Solver Benchmark export (strips expected answers, answer keys, hidden explanations).
- PII anonymization (deterministic pseudonymization for editor IDs, email redaction).
- Secret / token redaction.
- Bit-for-bit deterministic export with SHA-256 integrity verification.
"""
from __future__ import annotations

import hashlib
import json
import re
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Any, Iterable, Sequence

from app.curation.curation import CurationStatus, FeedbackRecord

# Regex patterns for sensitive data redaction
_EMAIL_RE = re.compile(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+")
_JWT_BEARER_RE = re.compile(r"(?i)\bbearer\s+[a-zA-Z0-9_\-\.]{16,}")
_API_KEY_RE = re.compile(r"(?i)\b(api[_-]?key|secret|token|password)[\"']?\s*[:=]\s*[\"']?([^\"'\s,}{]+)")
_SECRET_KEY_NAMES = frozenset({
    "api_key", "apikey", "secret", "secret_key", "password", "token",
    "access_token", "refresh_token", "private_key", "authorization",
})

# Answer-leaking keys to strip in blind solver exports
BLIND_SOLVER_LEAKY_KEYS = frozenset({
    "expected_answer", "answer", "answer_key", "correct_answer",
    "hidden_explanation", "explanation", "target_answer", "ground_truth",
    "after_payload", "before_payload", "diff",
})


def _utcnow_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def anonymize_id(raw_id: str, salt: str = "langfens_phase14_salt") -> str:
    """Deterministically pseudonymize an identifier using SHA-256."""
    if not raw_id:
        return "anon_000000000000"
    digest = hashlib.sha256(f"{salt}:{raw_id}".encode("utf-8")).hexdigest()
    return f"usr_anon_{digest[:12]}"


def redact_pii_and_secrets(data: Any, salt: str = "langfens_phase14_salt") -> Any:
    """Recursively redact emails, API keys/tokens, and anonymize user IDs."""
    if isinstance(data, dict):
        cleaned: dict[str, Any] = {}
        for k, v in data.items():
            k_lower = str(k).lower()
            if k_lower in _SECRET_KEY_NAMES:
                cleaned[k] = "[REDACTED_SECRET]"
            elif "editor_id" in k_lower or "user_id" in k_lower or "author_id" in k_lower:
                cleaned[k] = anonymize_id(str(v), salt=salt) if v else v
            else:
                cleaned[k] = redact_pii_and_secrets(v, salt=salt)
        return cleaned
    if isinstance(data, list):
        return [redact_pii_and_secrets(item, salt=salt) for item in data]
    if isinstance(data, str):
        # Redact email
        val = _EMAIL_RE.sub("[EMAIL_REDACTED]", data)
        # Redact Bearer tokens
        val = _JWT_BEARER_RE.sub("Bearer [TOKEN_REDACTED]", val)
        return val
    return data


def compute_deterministic_sha256(records: Sequence[dict[str, Any]]) -> str:
    """Calculate SHA-256 over stable JSON representation of sorted records."""
    canonical_json = json.dumps(records, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
    return hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class CuratedDatasetExport:
    """Full curated dataset export including ground-truth answers and audit lineage."""

    dataset_version: str
    dataset_sha256: str
    record_count: int
    created_at: str
    manifest: dict[str, Any]
    records: list[dict[str, Any]]

    def to_dict(self) -> dict[str, Any]:
        return {
            "dataset_version": self.dataset_version,
            "dataset_sha256": self.dataset_sha256,
            "record_count": self.record_count,
            "created_at": self.created_at,
            "manifest": self.manifest,
            "records": self.records,
        }

    def to_canonical_json(self) -> str:
        return json.dumps(self.to_dict(), sort_keys=True, separators=(",", ":"), ensure_ascii=True)


@dataclass(frozen=True)
class BlindSolverBenchmarkExport:
    """Benchmark export stripped of answers, answer keys, and hidden explanations."""

    benchmark_version: str
    benchmark_sha256: str
    record_count: int
    created_at: str
    manifest: dict[str, Any]
    records: list[dict[str, Any]]

    def to_dict(self) -> dict[str, Any]:
        return {
            "benchmark_version": self.benchmark_version,
            "benchmark_sha256": self.benchmark_sha256,
            "record_count": self.record_count,
            "created_at": self.created_at,
            "manifest": self.manifest,
            "records": self.records,
        }

    def to_canonical_json(self) -> str:
        return json.dumps(self.to_dict(), sort_keys=True, separators=(",", ":"), ensure_ascii=True)


class DatasetExporter:
    """Exporter creating deterministic curated datasets and blind solver views."""

    def __init__(self, salt: str = "langfens_phase14_salt") -> None:
        self._salt = salt

    def export_curated(
        self,
        records: Iterable[FeedbackRecord | dict[str, Any]],
        *,
        version: str = "v1.0.0",
        manifest_meta: dict[str, Any] | None = None,
        only_curated: bool = True,
    ) -> CuratedDatasetExport:
        """Export full curated dataset with ground-truth and sanitized lineage."""
        raw_items: list[dict[str, Any]] = []
        for r in records:
            if isinstance(r, FeedbackRecord):
                if only_curated and r.status != CurationStatus.CURATED:
                    continue
                item = {
                    "feedback_id": r.feedback_id,
                    "editor_id": r.editor_id,
                    "editor_role": r.editor_role,
                    "action_type": r.action_type.value,
                    "status": r.status.value,
                    "reasons": sorted(r.reasons),
                    "comment": r.comment,
                    "artifact_id": r.artifact_id,
                    "artifact_version": r.artifact_version,
                    "target_entity_type": r.target_entity_type,
                    "target_entity_id": r.target_entity_id,
                    "before_payload": r.before_payload,
                    "after_payload": r.after_payload,
                    "diff": r.diff,
                    "idempotency_key": r.idempotency_key,
                    "created_at": r.created_at,
                    "curated_at": r.curated_at,
                }
            elif isinstance(r, dict):
                if only_curated and r.get("status") not in ("CURATED", CurationStatus.CURATED):
                    continue
                item = dict(r)
                if "reasons" in item and isinstance(item["reasons"], list):
                    item["reasons"] = sorted(item["reasons"])
            else:
                continue

            # Apply PII / secret redaction
            sanitized = redact_pii_and_secrets(item, salt=self._salt)
            raw_items.append(sanitized)

        # Stable sort for deterministic hash
        raw_items.sort(
            key=lambda x: (
                str(x.get("target_entity_type") or ""),
                str(x.get("target_entity_id") or ""),
                str(x.get("feedback_id") or ""),
                str(x.get("artifact_id") or ""),
            )
        )

        dataset_sha256 = compute_deterministic_sha256(raw_items)

        # Build manifest
        reason_counts: dict[str, int] = {}
        for it in raw_items:
            for reason in it.get("reasons", []):
                reason_counts[reason] = reason_counts.get(reason, 0) + 1

        manifest = {
            "version": version,
            "exported_at": _utcnow_iso(),
            "record_count": len(raw_items),
            "reason_distribution": reason_counts,
            "salt_sha256": hashlib.sha256(self._salt.encode("utf-8")).hexdigest()[:16],
            **(manifest_meta or {}),
        }

        return CuratedDatasetExport(
            dataset_version=version,
            dataset_sha256=dataset_sha256,
            record_count=len(raw_items),
            created_at=manifest["exported_at"],
            manifest=manifest,
            records=raw_items,
        )

    def export_blind_solver_benchmark(
        self,
        records: Iterable[FeedbackRecord | dict[str, Any]],
        *,
        version: str = "v1.0.0-blind",
        manifest_meta: dict[str, Any] | None = None,
        only_curated: bool = True,
    ) -> BlindSolverBenchmarkExport:
        """Export blind solver benchmark stripped of answers, keys, and hidden notes."""
        curated_export = self.export_curated(
            records,
            version=version,
            manifest_meta=manifest_meta,
            only_curated=only_curated,
        )

        blind_items: list[dict[str, Any]] = []
        for item in curated_export.records:
            blind_record = self._strip_leaks(item)
            blind_items.append(blind_record)

        # Stable sort
        blind_items.sort(
            key=lambda x: (
                str(x.get("target_entity_type") or ""),
                str(x.get("target_entity_id") or ""),
                str(x.get("feedback_id") or ""),
                str(x.get("artifact_id") or ""),
            )
        )

        benchmark_sha256 = compute_deterministic_sha256(blind_items)

        manifest = {
            "benchmark_version": version,
            "exported_at": _utcnow_iso(),
            "record_count": len(blind_items),
            "answer_keys_excluded": True,
            "hidden_explanations_excluded": True,
            **(manifest_meta or {}),
        }

        return BlindSolverBenchmarkExport(
            benchmark_version=version,
            benchmark_sha256=benchmark_sha256,
            record_count=len(blind_items),
            created_at=manifest["exported_at"],
            manifest=manifest,
            records=blind_items,
        )

    def _strip_leaks(self, data: Any) -> Any:
        """Recursively strip answer keys and explanatory diffs."""
        if isinstance(data, dict):
            cleaned: dict[str, Any] = {}
            for k, v in data.items():
                if k.lower() in BLIND_SOLVER_LEAKY_KEYS:
                    continue
                # If target is option, redact correct-answer indicators
                if k.lower() in ("is_correct", "iscorrect", "correct"):
                    continue
                cleaned[k] = self._strip_leaks(v)
            return cleaned
        if isinstance(data, list):
            return [self._strip_leaks(elem) for elem in data]
        return data
