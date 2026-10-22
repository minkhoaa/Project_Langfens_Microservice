import os
import re
from pathlib import Path

def test_no_hardcoded_jwt_secret_in_tracked_scripts():
    repo_root = Path(__file__).resolve().parents[4]
    scripts_to_check = [
        repo_root / "run_e2e_admin_job.py",
        repo_root / "scripts/test_live_section1_job.py",
    ]
    for script in scripts_to_check:
        assert script.exists(), f"Expected script {script} to exist"
        content = script.read_text(encoding="utf-8")
        assert "os.getenv(\"JWT_SIGNING_KEY\"" in content or "os.getenv(\"JwtSettings__SignKey\"" in content, (
            f"{script.name} must resolve JWT signing key from environment variables"
        )

def test_gitignore_ignores_raw_reports():
    repo_root = Path(__file__).resolve().parents[4]
    gitignore = repo_root / ".gitignore"
    assert gitignore.exists()
    content = gitignore.read_text(encoding="utf-8")
    assert "reports/job_*.json" in content or "reports/" in content
    assert "current_fresh_job_id.txt" in content
