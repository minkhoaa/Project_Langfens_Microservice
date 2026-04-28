"""Idempotent test-user seeder.

Creates (or no-ops) the dedicated E2E user via the auth-service public
registration endpoint. Designed to run against a freshly booted local stack.

Usage:
    python -m scripts.e2e.seed_user [--gateway http://localhost:5000]
"""
from __future__ import annotations

import argparse
import sys

import httpx

DEFAULT_GATEWAY = "http://localhost:5000"
EMAIL = "e2e+writing@langfens.test"
PASSWORD = "E2eTest!2026"


def seed(gateway: str) -> int:
    base = gateway.rstrip("/")
    register_url = f"{base}/api-auth/auth/register"
    login_url = f"{base}/api-auth/auth/login"

    with httpx.Client(timeout=15.0) as client:
        login_resp = client.post(login_url, json={"email": EMAIL, "password": PASSWORD})
        if login_resp.status_code == 200:
            print(f"[seed] User {EMAIL} already exists — login OK", file=sys.stderr)
            return 0

        reg_resp = client.post(register_url, json={"email": EMAIL, "password": PASSWORD})
        if reg_resp.status_code not in (200, 201):
            print(
                f"[seed] Register failed: {reg_resp.status_code} {reg_resp.text[:300]}",
                file=sys.stderr,
            )
            return 1

        print(f"[seed] Registered {EMAIL}", file=sys.stderr)
        login2 = client.post(login_url, json={"email": EMAIL, "password": PASSWORD})
        if login2.status_code != 200:
            print(
                f"[seed] Login after register failed: {login2.status_code} {login2.text[:300]}",
                file=sys.stderr,
            )
            return 2

        print(f"[seed] Login confirmed for {EMAIL}", file=sys.stderr)
        return 0


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--gateway", default=DEFAULT_GATEWAY)
    args = parser.parse_args()
    sys.exit(seed(args.gateway))


if __name__ == "__main__":
    main()
