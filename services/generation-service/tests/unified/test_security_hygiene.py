import os
import re
import subprocess
import sys
from pathlib import Path
import pytest

REDACTED_LEAK_TARGET = "bTNGPmniBGyINHPdsmONct16TIqqb1bZ"

def test_no_hardcoded_jwt_secret_in_tracked_scripts():
    repo_root = Path(__file__).resolve().parents[4]
    scripts_to_check = [
        repo_root / "run_e2e_admin_job.py",
        repo_root / "scripts/test_live_section1_job.py",
        repo_root / "restart_services.sh",
    ]
    for script in scripts_to_check:
        assert script.exists(), f"Expected script {script} to exist"
        content = script.read_text(encoding="utf-8")
        assert REDACTED_LEAK_TARGET not in content, (
            f"Plaintext secret {REDACTED_LEAK_TARGET} must NOT appear in {script.name}"
        )


def test_test_live_section1_job_imports_os_and_handles_missing_key():
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "scripts/test_live_section1_job.py"
    clean_env = {k: v for k, v in os.environ.items() if k not in ("JWT_SIGNING_KEY", "JwtSettings__SignKey")}

    # Test that importing / running without key fails closed without NameError: name 'os' is not defined
    res = subprocess.run(
        [sys.executable, "-c", "import sys; sys.path.insert(0, 'scripts'); import test_live_section1_job; test_live_section1_job.create_admin_jwt()"],
        cwd=str(repo_root),
        capture_output=True,
        text=True,
        env=clean_env,
        timeout=5,
    )
    assert res.returncode != 0
    assert "NameError: name 'os' is not defined" not in res.stderr
    assert "required" in res.stderr.lower() or "valueerror" in res.stderr.lower() or "error" in res.stderr.lower()


def test_test_live_section1_job_explicit_key_works():
    repo_root = Path(__file__).resolve().parents[4]
    test_key = "test-custom-key-12345"
    res = subprocess.run(
        [sys.executable, "-c", f"import sys; sys.path.insert(0, 'scripts'); import test_live_section1_job; print(test_live_section1_job.create_admin_jwt('{test_key}'))"],
        cwd=str(repo_root),
        capture_output=True,
        text=True,
        timeout=5,
    )
    assert res.returncode == 0
    token = res.stdout.strip()
    assert token.count(".") == 2, f"Expected valid JWT structure, got: {token}"


def test_gitignore_ignores_raw_reports():
    repo_root = Path(__file__).resolve().parents[4]
    gitignore = repo_root / ".gitignore"
    assert gitignore.exists()
    content = gitignore.read_text(encoding="utf-8")
    assert "reports/job_*.json" in content or "reports/" in content
    assert "current_fresh_job_id.txt" in content
