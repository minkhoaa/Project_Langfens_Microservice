"""Stagnation and Oscillation Detectors for Loop Engine V2."""

from __future__ import annotations

from collections.abc import Mapping
from typing import FrozenSet, List, Optional, Sequence, Set, Tuple
from pydantic import ConfigDict, Field
from app.contracts.base import CanonicalBaseModel


# Volatile envelope fields that vary between two attempts that produced semantically
# identical work (provider token accounting, wall-clock timings, per-call scratch ids).
# Including them in a no-progress fingerprint defeats detection: three byte-different
# but semantically identical regenerations would each look like fresh progress.
VOLATILE_OUTCOME_KEYS: FrozenSet[str] = frozenset(
    {
        "tokensused",
        "tokens",
        "walltimeusedseconds",
        "walltimesusedseconds",
        "walltimeseconds",
        "operationid",
        "intentid",
        "parentoperationid",
        "runid",
        "candidateid",
        "candidate_id",
        "score",
        "scores",
    }
)


def normalized_outcome_fingerprint(
    payload: object,
    issue_fingerprints: Sequence[str] = (),
) -> str:
    """Builds a semantic, volatile-field-immune fingerprint of one attempt's outcome.

    The fingerprint is the SHA-256 of the canonical JSON of the artifact payload with
    volatile accounting fields stripped, combined with the sorted unresolved issue
    fingerprints. Two attempts that differ only in token counts or timings collapse to
    the same fingerprint, which is exactly the signal `StagnationDetector` needs: the
    engine produced the same defective artifact again and is not converging.
    """
    import hashlib
    import json

    def _strip(value: object) -> object:
        # Artifact payloads are frozen as MappingProxyType, which is NOT a dict;
        # keying on `dict` alone would serialise the whole envelope via `repr` and
        # silently reintroduce the volatile fields we are trying to drop.
        if isinstance(value, Mapping):
            return {
                k: _strip(v)
                for k, v in sorted(value.items())
                if str(k).replace("_", "").lower() not in VOLATILE_OUTCOME_KEYS
            }
        if isinstance(value, (list, tuple)):
            return [_strip(v) for v in value]
        return value

    try:
        body = json.dumps(_strip(payload), sort_keys=True, separators=(",", ":"), default=str)
    except Exception:
        body = repr(payload)
    joined = body + "|" + "|".join(sorted(str(f) for f in issue_fingerprints))
    return hashlib.sha256(joined.encode("utf-8")).hexdigest()


def semantic_issue_identities(issues: Sequence[object]) -> List[str]:
    """Renders version-independent identities for a set of open issues.

    `Issue.fingerprint` deliberately binds `affected_refs`, which include the artifact
    version. Two attempts at v1 and v2 therefore carry different fingerprints even when
    they report the identical defect, so keying a no-progress fingerprint on
    `fingerprint` is useless for detecting repeated regeneration. The semantic identity
    is (code, scope, normalized message) -- exactly what distinguishes "the same defect
    again" from "a different defect".
    """
    identities: List[str] = []
    for issue in issues:
        code = getattr(issue, "code", "")
        scope = getattr(issue, "scope", "")
        message = str(getattr(issue, "message", "") or "")
        code_v = getattr(code, "value", code)
        scope_v = getattr(scope, "value", scope)
        identities.append(f"{code_v}|{scope_v}|{' '.join(message.lower().split())}")
    return identities


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
    last_outcome_fingerprint: Optional[str] = Field(default=None, alias="lastOutcomeFingerprint")
    consecutive_identical_outcomes: int = Field(
        default=0, alias="consecutiveIdenticalOutcomes"
    )
    total_identical_outcomes: int = Field(default=0, alias="totalIdenticalOutcomes")

    def record_repair(self, current_hash: str) -> int:
        """Records a repaired artifact content hash, returning current consecutive identical count."""
        if self.last_content_hash is not None and self.last_content_hash.lower() == current_hash.lower():
            self.consecutive_identical_count += 1
            self.total_identical_repairs += 1
        else:
            self.consecutive_identical_count = 0
            self.last_content_hash = current_hash
        return self.consecutive_identical_count

    def record_outcome(self, outcome_fingerprint: str) -> int:
        """Records a semantic outcome fingerprint across ANY version (repair or regeneration).

        This is the signal that catches repeated no-progress *regeneration*. The
        previous detector only counted identical repair outputs and explicitly reset
        its counter on every generation, so a slot that regenerated the same defective
        artifact three times looked like three distinct attempts and burned the whole
        version budget before the cap reported MAX_VERSIONS instead of the truthful
        NO_PROGRESS.
        """
        if (
            self.last_outcome_fingerprint is not None
            and self.last_outcome_fingerprint == outcome_fingerprint
        ):
            self.consecutive_identical_outcomes += 1
            self.total_identical_outcomes += 1
        else:
            self.consecutive_identical_outcomes = 0
            self.last_outcome_fingerprint = outcome_fingerprint
        return self.consecutive_identical_outcomes

    def is_stagnated(self, cap: int) -> bool:
        """Returns True if consecutive identical repairs OR outcomes meet or exceed the cap."""
        return (
            self.consecutive_identical_count >= cap
            or self.consecutive_identical_outcomes >= cap
        )

    def reset_counter(self) -> None:
        """Resets the consecutive counter (e.g. after full regeneration)."""
        self.consecutive_identical_count = 0
        self.last_content_hash = None
        self.consecutive_identical_outcomes = 0
        self.last_outcome_fingerprint = None


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
    consecutive_repeats: int = Field(default=0, alias="consecutiveRepeats")

    def record_state(self, content_hash: str, issue_fingerprints: Set[str]) -> bool:
        """Records the current state. Returns True if a repeating cycle is detected.

        Three detections, in order of severity:
        1. *Consecutive repeat* — this exact (hash, issue-set) state already occurred as
           the immediately preceding state. Re-entering an identical state is the
           definition of a non-converging loop, and the original implementation could
           not see it because it required the following state to differ.
        2. *Hash cycle* — this hash was seen before but not immediately before (A -> B -> A).
        3. *Issue-fingerprint cycle* — this issue set was seen before but not immediately before.
        """
        h_norm = content_hash.lower()
        fp_sorted = sorted(issue_fingerprints)

        cycle_detected = False

        # 1. Consecutive identical state (true no-progress repeat)
        if (
            self.hash_history
            and self.hash_history[-1] == h_norm
            and self.issue_history
            and self.issue_history[-1] == fp_sorted
        ):
            self.consecutive_repeats += 1
            cycle_detected = True
        else:
            self.consecutive_repeats = 0

        # 2. Hash cycle detection (e.g., A -> B -> A)
        if not cycle_detected and len(self.hash_history) >= 2:
            for idx in range(len(self.hash_history) - 2, -1, -1):
                if self.hash_history[idx] == h_norm and self.hash_history[idx + 1] != h_norm:
                    cycle_detected = True
                    break

        # 3. Issue fingerprint set cycle detection (e.g., {X} -> {Y} -> {X})
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
        self.consecutive_repeats = 0
