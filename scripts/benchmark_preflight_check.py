#!/usr/bin/env python3
"""Offline-only preflight; this command never contacts providers or starts services."""

import os

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAPS_PROFILE_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "loop-caps-acceptance.env")


def main() -> int:
    """Report local preflight facts without claiming live execution readiness."""
    profile_present = os.path.isfile(CAPS_PROFILE_PATH)
    print("Offline preflight only; no providers or services were contacted.")
    print("provider_dispatches=0")
    print(f"acceptance_caps_profile_present={str(profile_present).lower()}")
    print("NOT A LIVE READINESS VERDICT")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
