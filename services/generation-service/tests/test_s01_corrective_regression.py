"""Regression tests for 2026-10-21 S01 corrective patch.

Task 1: Policy Bridge & Snapshot Generation Fix (P0-A).

LoopPolicy.from_pinned_execution_policy must:
- Produce a 32-bit positive-integer cap snapshot (.NET-compatible).
- Set cap_profile_sha256 = SHA-256 of that JSON snapshot (not policy.hash).
- Preserve policy.hash as a separate field on LoopPolicy.
- Include .NET MatchesRunBudget keys in the snapshot.
"""

from __future__ import annotations

import pytest

from app.loop.policy import LoopPolicy, cap_snapshot_sha256
from app.reading_policy import (
    PinnedExecutionPolicy,
    MAX_PROVIDER_CALL_SECONDS,
    MAX_SECTION_TOKEN_CAP,
    MAX_SECTION_WALL_SECONDS,
)


def test_scenario_01_policy_bridge_snapshot_and_hash():
    """P0-A: LoopPolicy.from_pinned_execution_policy must produce valid 32-bit int snapshot and separate policy.hash."""
    unified_policy = PinnedExecutionPolicy(provider="minimax")
    sec_policy = LoopPolicy.from_pinned_execution_policy(unified_policy, scope="SECTION")

    # 1. Finite ceilings enforced
    assert not sec_policy.is_unlimited
    assert sec_policy.max_wall_time_seconds <= MAX_SECTION_WALL_SECONDS
    assert sec_policy.max_total_tokens <= MAX_SECTION_TOKEN_CAP
    assert sec_policy.operation_wall_reservation_seconds <= MAX_PROVIDER_CALL_SECONDS

    # 2. Hash separation: cap_profile_sha256 matches snapshot SHA-256, while policy_hash matches unified_policy.hash
    snapshot = sec_policy.cap_profile_snapshot
    expected_snapshot_sha = cap_snapshot_sha256(snapshot)
    assert sec_policy.cap_profile_sha256 == expected_snapshot_sha
    assert sec_policy.cap_profile_sha256 != unified_policy.hash
    assert getattr(sec_policy, "policy_hash", None) == unified_policy.hash

    # 3. .NET CheckpointService MatchesRunBudget keys present and typed as positive 32-bit integers
    caps = snapshot["caps"]
    for k in (
        "standaloneRunBudgetCapCalls",
        "standaloneRunBudgetCapTokens",
        "standaloneRunBudgetCapWallTimeSeconds",
        "loopOperationWallReservationSeconds",
    ):
        assert k in caps
        assert isinstance(caps[k], int)
        assert 0 < caps[k] <= 2_147_483_647

    # 4. LoopPolicy.from_cap_snapshot round-trip and validation both succeed
    restored_policy = LoopPolicy.from_cap_snapshot(snapshot)
    assert restored_policy.cap_profile_sha256 == expected_snapshot_sha
    restored_policy.validate_cap_bounds()
