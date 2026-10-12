"""Phase-14 Prompt & Model Version Registry with In-Flight Run Pinning.

Supports:
- Registering versioned prompt packages / candidate models.
- Active pinned version for new autonomous runs.
- Run-scoped version binding: Once a run begins under version V, subsequent operations
  for that run_id always resolve to V (in-flight run retention), even after promotion.
- Clean rollback to previous active version.
- Version history audit trail.
"""
from __future__ import annotations

import json
import logging
import os
import tempfile
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
logger = logging.getLogger(__name__)


class RegistryError(RuntimeError):
    """Raised on registry errors (e.g. unknown version, illegal rollback)."""


@dataclass(frozen=True)
class VersionMetadata:
    """Metadata recorded for a registered version."""

    version: str
    description: str
    registered_at: str
    registered_by: str
    config: dict[str, Any] = field(default_factory=dict)
    benchmark_report_id: str | None = None


@dataclass(frozen=True)
class PinHistoryEntry:
    """Audit log entry for an active pin change."""

    version: str
    pinned_at: str
    pinned_by: str
    reason: str
    is_rollback: bool = False


class PromptVersionRegistry:
    """Registry maintaining active prompt versions and in-flight run bindings."""

    def __init__(
        self,
        initial_active_version: str = "prompts_v2_0_0",
        persist_path: str | Path | None = None,
    ) -> None:
        self._versions: dict[str, VersionMetadata] = {}
        self._active_pinned_version: str = initial_active_version
        self._pin_history: list[PinHistoryEntry] = []
        self._run_bindings: dict[str, str] = {}  # run_id -> pinned_version
        self.persist_path = Path(persist_path) if persist_path else None
        # Register default baseline
        self.register_version(
            version=initial_active_version,
            description="Baseline Phase 14 generation prompts",
            registered_by="system",
            config={"model": "default", "prompt_strategy": "baseline_v2"},
        )
        self._record_pin(initial_active_version, "system", "Initial system bootstrap", is_rollback=False)

    @property
    def active_pinned_version(self) -> str:
        """Currently active version for new runs."""
        return self._active_pinned_version

    def register_version(
        self,
        *,
        version: str,
        description: str,
        registered_by: str,
        config: dict[str, Any] | None = None,
        benchmark_report_id: str | None = None,
    ) -> VersionMetadata:
        """Register a new candidate or baseline version in the registry."""
        if not version or not version.strip():
            raise RegistryError("Version string cannot be empty")
        meta = VersionMetadata(
            version=version,
            description=description,
            registered_at=datetime.now(timezone.utc).isoformat(),
            registered_by=registered_by,
            config=config or {},
            benchmark_report_id=benchmark_report_id,
        )
        self._versions[version] = meta
        logger.info("Registered version %s in registry", version)
        self._auto_save()
        return meta
    def pin_active_version(
        self,
        version: str,
        *,
        pinned_by: str,
        reason: str,
    ) -> str:
        """Pin a version as the active version for future new runs."""
        if version not in self._versions:
            raise RegistryError(f"Cannot pin unknown version {version!r}")
        old_version = self._active_pinned_version
        self._active_pinned_version = version
        self._record_pin(version, pinned_by, reason, is_rollback=False)
        logger.info("Pinned active version from %s -> %s by %s", old_version, version, pinned_by)
        self._auto_save()
        return version
    def rollback_to_version(
        self,
        target_version: str,
        *,
        rolled_back_by: str,
        reason: str,
    ) -> str:
        """Rollback active version to target_version."""
        if target_version not in self._versions:
            raise RegistryError(f"Cannot rollback to unknown version {target_version!r}")
        prev = self._active_pinned_version
        self._active_pinned_version = target_version
        self._record_pin(target_version, rolled_back_by, f"Rollback from {prev}: {reason}", is_rollback=True)
        logger.warning("Rolled back active version from %s -> %s by %s", prev, target_version, rolled_back_by)
        self._auto_save()
        return target_version
    def get_version_for_run(self, run_id: str) -> str:
        """Get the version bound to a run.

        If the run is new, binds it to the current active pinned version.
        If the run was already started, returns its originally bound version
        (in-flight run retention).
        """
        if run_id in self._run_bindings:
            return self._run_bindings[run_id]
        # Bind new run to current active pinned version
        bound = self._active_pinned_version
        self._run_bindings[run_id] = bound
        self._auto_save()
        return bound
    def is_run_bound_to(self, run_id: str, version: str) -> bool:
        """Check if run is bound to specific version."""
        return self._run_bindings.get(run_id) == version

    def get_version_meta(self, version: str) -> VersionMetadata:
        if version not in self._versions:
            raise RegistryError(f"unknown version {version!r}")
        return self._versions[version]

    def list_versions(self) -> list[VersionMetadata]:
        return list(self._versions.values())

    def get_pin_history(self) -> list[PinHistoryEntry]:
        return list(self._pin_history)

    def _auto_save(self) -> None:
        if self.persist_path:
            try:
                self.save(self.persist_path)
            except Exception as exc:
                logger.debug("PromptVersionRegistry auto-save failed: %s", exc)

    def _record_pin(self, version: str, pinned_by: str, reason: str, is_rollback: bool) -> None:
        self._pin_history.append(
            PinHistoryEntry(
                version=version,
                pinned_at=datetime.now(timezone.utc).isoformat(),
                pinned_by=pinned_by,
                reason=reason,
                is_rollback=is_rollback,
            )
        )

    def to_dict(self) -> dict[str, Any]:
        return {
            "schema_version": "phase14.v1",
            "active_pinned_version": self._active_pinned_version,
            "versions": {
                k: {
                    "version": v.version,
                    "description": v.description,
                    "registered_at": v.registered_at,
                    "registered_by": v.registered_by,
                    "config": v.config,
                    "benchmark_report_id": v.benchmark_report_id,
                }
                for k, v in self._versions.items()
            },
            "pin_history": [
                {
                    "version": p.version,
                    "pinned_at": p.pinned_at,
                    "pinned_by": p.pinned_by,
                    "reason": p.reason,
                    "is_rollback": p.is_rollback,
                }
                for p in self._pin_history
            ],
            "run_bindings": dict(self._run_bindings),
        }

    def save(self, file_path: str | Path) -> None:
        """Atomically persist registry state to disk."""
        p = Path(file_path)
        p.parent.mkdir(parents=True, exist_ok=True)
        payload = json.dumps(self.to_dict(), indent=2, sort_keys=True)
        # Atomic write via tempfile
        temp_path = p.with_suffix(".tmp")
        with open(temp_path, "w", encoding="utf-8") as f:
            f.write(payload)
        temp_path.replace(p)
        logger.info("Persisted PromptVersionRegistry state to %s", p)

    @classmethod
    def load(cls, file_path: str | Path) -> PromptVersionRegistry:
        """Load registry state from disk."""
        p = Path(file_path)
        if not p.exists():
            raise RegistryError(f"Registry file not found: {p}")
        with open(p, "r", encoding="utf-8") as f:
            data = json.load(f)
        active_ver = data.get("active_pinned_version", "prompts_v2_0_0")
        reg = cls(initial_active_version=active_ver)
        reg._versions.clear()
        for k, v in data.get("versions", {}).items():
            reg._versions[k] = VersionMetadata(
                version=v["version"],
                description=v.get("description", ""),
                registered_at=v.get("registered_at", ""),
                registered_by=v.get("registered_by", ""),
                config=v.get("config", {}),
                benchmark_report_id=v.get("benchmark_report_id"),
            )
        reg._pin_history = [
            PinHistoryEntry(
                version=h["version"],
                pinned_at=h["pinned_at"],
                pinned_by=h["pinned_by"],
                reason=h.get("reason", ""),
                is_rollback=h.get("is_rollback", False),
            )
            for h in data.get("pin_history", [])
        ]
        reg._run_bindings = dict(data.get("run_bindings", {}))
        return reg
