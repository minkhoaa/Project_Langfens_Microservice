#!/usr/bin/env python3
"""Offline-only preflight; this command never contacts providers or starts services."""

import os
import hashlib
import json
from pathlib import Path
import re

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAPS_PROFILE_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "loop-caps.env")


def local_source_sha() -> str:
    """Read Git metadata without subprocesses, service startup, or connectivity."""
    directory = Path(REPO_ROOT) / ".git"
    if directory.is_file():
        directory = (directory.parent / directory.read_text().strip().removeprefix("gitdir: ")).resolve()
    try:
        head = (directory / "HEAD").read_text().strip()
        if head.startswith("ref: "):
            ref = head[5:]
            if (directory / ref).exists():
                head = (directory / ref).read_text().strip()
            else:
                head = next(line.split()[0] for line in (directory / "packed-refs").read_text().splitlines()
                    if line.endswith(" " + ref))
        return head if re.fullmatch(r"[0-9a-f]{40}", head) else "UNVERIFIED"
    except (OSError, StopIteration):
        return "UNVERIFIED"


def configured_caps() -> dict:
    """Local configuration facts only; never inferred to be running/pinned state."""
    path = os.path.join(REPO_ROOT, "deploy", "envs", "loop-caps.env")
    with open(path, "rb") as stream:
        raw = stream.read()
    fields = dict(line.split("=", 1) for line in raw.decode().splitlines() if line and not line.startswith("#"))
    keys = ("LOOP_OPERATION_WALL_RESERVATION_SECONDS", "LOOP_MAX_TOTAL_CALLS", "LOOP_MAX_TOTAL_TOKENS",
        "LOOP_MAX_WALL_TIME_SECONDS", "READING_PAPER_RUN_BUDGET_MAX_CALLS", "READING_PAPER_RUN_BUDGET_MAX_TOKENS",
        "READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS", "BENCHMARK_CHILD_RUN_MAX_CALLS",
        "BENCHMARK_CHILD_RUN_MAX_TOKENS", "BENCHMARK_CHILD_RUN_MAX_WALL_TIME_SECONDS")
    caps = {key: int(fields[key]) for key in keys}
    if any(v <= 0 for v in caps.values()) or caps["LOOP_OPERATION_WALL_RESERVATION_SECONDS"] != 60:
        raise ValueError("Invalid approved finite 60s profile")
    return {"profile_version": fields["LOOP_CAPS_PROFILE_VERSION"], "profile_source": fields["LOOP_CAPS_PROFILE_SOURCE"],
        "caps_file_sha256": hashlib.sha256(raw).hexdigest(), "configured_caps": caps,
        "local_source_sha": local_source_sha(),
        "runtime_source_sha": "UNVERIFIED", "worker_count": "UNVERIFIED", "pinned_run_profile": "UNVERIFIED"}


def main() -> int:
    """Report local preflight facts without claiming live execution readiness."""
    profile_present = os.path.isfile(CAPS_PROFILE_PATH)
    print("Offline preflight only; no providers or services were contacted.")
    print("provider_dispatches=0")
    print(f"acceptance_caps_profile_present={str(profile_present).lower()}")
    print(json.dumps(configured_caps(), sort_keys=True))
    print("NOT A LIVE READINESS VERDICT")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
