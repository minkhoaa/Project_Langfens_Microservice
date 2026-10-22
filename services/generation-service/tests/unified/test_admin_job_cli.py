import subprocess
import sys
from pathlib import Path

def test_cli_help_displays_modes():
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    res = subprocess.run([sys.executable, str(script), "--help"], capture_output=True, text=True)
    assert res.returncode == 0
    assert "--mode" in res.stdout
    assert "new" in res.stdout
    assert "resume" in res.stdout
    assert "monitor" in res.stdout

def test_cli_new_mode_rejected_in_offline_mode():
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    # Attempting to submit a new job when offline must fail-closed with clear diagnostic
    res = subprocess.run([sys.executable, str(script), "--mode", "new", "--offline"], capture_output=True, text=True)
    assert res.returncode != 0
    assert "OFFLINE" in res.stdout or "OFFLINE" in res.stderr

def test_cli_resume_mode_requires_valid_job_id():
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    res = subprocess.run([sys.executable, str(script), "--mode", "resume", "--job-id", "invalid-uuid-format"], capture_output=True, text=True)
    assert res.returncode != 0
    assert "invalid" in (res.stdout + res.stderr).lower() or "uuid" in (res.stdout + res.stderr).lower()
