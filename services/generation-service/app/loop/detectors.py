"""Stagnation and Oscillation Detectors for Loop Engine V2."""

from __future__ import annotations

from typing import FrozenSet, List, Optional, Set
from pydantic import ConfigDict, Field
from app.contracts.base import CanonicalBaseModel


class StagnationDetector(CanonicalBaseModel):
    """Detects consecutive non-progressing repairs where output hash remains identical."""

    model_config = ConfigDict(
        frozen=False,
        populate_by_name=True,
        extra="forbid",
    )

    last_content_hash: Optional[str] = Field(default=None, alias="lastContentHash")
    consecutive_identical_count: int = Field(default=0, alias="consecutiveIdenticalCount")
    total_identical_repairs: int = Field(default=0, alias="totalIdenticalRepairs")

    def record_repair(self, current_hash: str) -> int:
        """Records a repaired artifact content hash, returning current consecutive identical count."""
        if self.last_content_hash is not None and self.last_content_hash.lower() == current_hash.lower():
            self.consecutive_identical_count += 1
            self.total_identical_repairs += 1
        else:
            self.consecutive_identical_count = 0
            self.last_content_hash = current_hash
        return self.consecutive_identical_count

    def is_stagnated(self, cap: int) -> bool:
        """Returns True if consecutive identical repairs meet or exceed the cap."""
        return self.consecutive_identical_count >= cap

    def reset_counter(self) -> None:
        """Resets the consecutive counter (e.g. after full regeneration)."""
        self.consecutive_identical_count = 0
        self.last_content_hash = None


class OscillationDetector(CanonicalBaseModel):
    """Detects cycles and thrashing in artifact hashes or recurring issue fingerprint sets."""

    model_config = ConfigDict(
        frozen=False,
        populate_by_name=True,
        extra="forbid",
    )

    hash_history: List[str] = Field(default_factory=list, alias="hashHistory")
    issue_history: List[List[str]] = Field(default_factory=list, alias="issueHistory")
    cycle_count: int = Field(default=0, alias="cycleCount")

    def record_state(self, content_hash: str, issue_fingerprints: Set[str]) -> bool:
        """Records the current state. Returns True if a repeating cycle is detected."""
        h_norm = content_hash.lower()
        fp_sorted = sorted(issue_fingerprints)

        cycle_detected = False

        # 1. Hash cycle detection (e.g., A -> B -> A)
        if len(self.hash_history) >= 2:
            # Check if this hash was seen before, but not as the immediately preceding element
            # (immediately preceding would be handled by stagnation)
            for idx in range(len(self.hash_history) - 2, -1, -1):
                if self.hash_history[idx] == h_norm and self.hash_history[idx + 1] != h_norm:
                    cycle_detected = True
                    break

        # 2. Issue fingerprint set cycle detection (e.g., {X} -> {Y} -> {X})
        if not cycle_detected and len(self.issue_history) >= 2 and fp_sorted:
            for idx in range(len(self.issue_history) - 2, -1, -1):
                if self.issue_history[idx] == fp_sorted and self.issue_history[idx + 1] != fp_sorted:
                    cycle_detected = True
                    break

        self.hash_history.append(h_norm)
        self.issue_history.append(fp_sorted)

        if cycle_detected:
            self.cycle_count += 1

        return cycle_detected

    def is_oscillating(self, max_cycles: int = 1) -> bool:
        """Returns True if the cycle count meets or exceeds the cap."""
        return self.cycle_count >= max_cycles

    def reset(self) -> None:
        """Resets history after regeneration."""
        self.hash_history.clear()
        self.issue_history.clear()
        self.cycle_count = 0
