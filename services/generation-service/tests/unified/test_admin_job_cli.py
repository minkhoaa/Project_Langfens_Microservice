import http.server
import json
import os
import subprocess
import sys
import threading
from pathlib import Path
import pytest

TEST_JWT_SECRET = "test-secret-key-for-local-cli-testing-only-12345"

class MockExamHandler(http.server.BaseHTTPRequestHandler):
    requests_log = []
    job_status = "Failed"
    job_id = "00000000-0000-0000-0000-000000000001"

    def do_GET(self):
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else b""
        MockExamHandler.requests_log.append({
            "method": "GET",
            "path": self.path,
            "headers": dict(self.headers),
            "body": body,
        })
        if self.path == f"/api/admin/reading-paper/jobs/{MockExamHandler.job_id}":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            resp = {
                "id": MockExamHandler.job_id,
                "status": MockExamHandler.job_status,
                "completedSections": 1,
                "logs": [{"timestamp": "2026-10-22T10:00:00Z", "level": "Information", "message": "Test log"}],
                "examId": None,
                "error": "Simulated error" if MockExamHandler.job_status == "Failed" else None,
            }
            self.wfile.write(json.dumps(resp).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else b""
        MockExamHandler.requests_log.append({
            "method": "POST",
            "path": self.path,
            "headers": dict(self.headers),
            "body": body,
        })
        if self.path == "/api/admin/reading-paper/jobs":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"id": MockExamHandler.job_id, "status": "Pending"}).encode("utf-8"))
        elif self.path == f"/api/admin/reading-paper/jobs/{MockExamHandler.job_id}/retry":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"id": MockExamHandler.job_id, "status": "Pending"}).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Quiet logging


@pytest.fixture
def mock_exam_server():
    MockExamHandler.requests_log = []
    MockExamHandler.job_status = "Failed"
    server = http.server.HTTPServer(("127.0.0.1", 0), MockExamHandler)
    port = server.server_port
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    yield f"http://127.0.0.1:{port}", MockExamHandler
    server.shutdown()


def test_cli_help_displays_modes():
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    res = subprocess.run([sys.executable, str(script), "--help"], capture_output=True, text=True)
    assert res.returncode == 0
    assert "--mode" in res.stdout
    assert "new" in res.stdout
    assert "resume" in res.stdout
    assert "monitor" in res.stdout


def test_regression_h_no_explicit_mode_creates_no_job(mock_exam_server):
    base_url, handler = mock_exam_server
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    res = subprocess.run([sys.executable, str(script), f"--base-url={base_url}"], capture_output=True, text=True, env=env)
    # Must fail or require explicit mode, and create ZERO network requests to create a job
    post_requests = [r for r in handler.requests_log if r["method"] == "POST"]
    assert len(post_requests) == 0, f"Expected 0 POST requests without explicit mode, got {post_requests}"
    assert res.returncode != 0


def test_regression_a_new_plus_offline_zero_mutating_requests(mock_exam_server):
    base_url, handler = mock_exam_server
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    # Test via --offline flag
    res1 = subprocess.run([sys.executable, str(script), "--mode", "new", "--offline", f"--base-url={base_url}"], capture_output=True, text=True, env=env)
    assert res1.returncode != 0
    assert "OFFLINE" in (res1.stdout + res1.stderr)

    # Test via OFFLINE_MODE env var
    env_offline = {**env, "OFFLINE_MODE": "true"}
    res2 = subprocess.run([sys.executable, str(script), "--mode", "new", f"--base-url={base_url}"], capture_output=True, text=True, env=env_offline)
    assert res2.returncode != 0
    assert "OFFLINE" in (res2.stdout + res2.stderr)

    assert len(handler.requests_log) == 0, f"Expected 0 requests in offline new mode, got {handler.requests_log}"


def test_regression_b_resume_plus_offline_failed_zero_post(mock_exam_server):
    base_url, handler = mock_exam_server
    handler.job_status = "Failed"
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    # Running resume with offline on Failed job must NOT issue POST /retry
    res = subprocess.run(
        [sys.executable, str(script), "--mode", "resume", "--job-id", handler.job_id, "--offline", f"--base-url={base_url}"],
        capture_output=True,
        text=True,
        env=env,
        timeout=5,
    )
    post_requests = [r for r in handler.requests_log if r["method"] == "POST"]
    assert len(post_requests) == 0, f"Expected ZERO POST requests in offline resume on Failed job, got: {post_requests}"


def test_regression_c_resume_plus_offline_needs_sources_zero_post(mock_exam_server):
    base_url, handler = mock_exam_server
    handler.job_status = "NeedsSources"
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    res = subprocess.run(
        [sys.executable, str(script), "--mode", "resume", "--job-id", handler.job_id, "--offline", f"--base-url={base_url}"],
        capture_output=True,
        text=True,
        env=env,
        timeout=5,
    )
    post_requests = [r for r in handler.requests_log if r["method"] == "POST"]
    assert len(post_requests) == 0, f"Expected ZERO POST requests for NeedsSources, got: {post_requests}"


def test_regression_d_monitor_get_only(mock_exam_server):
    base_url, handler = mock_exam_server
    handler.job_status = "Completed"
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    res = subprocess.run(
        [sys.executable, str(script), "--mode", "monitor", "--job-id", handler.job_id, f"--base-url={base_url}"],
        capture_output=True,
        text=True,
        env=env,
        timeout=5,
    )
    assert res.returncode == 0
    assert len(handler.requests_log) > 0
    non_get = [r for r in handler.requests_log if r["method"] != "GET"]
    assert len(non_get) == 0, f"Monitor mode must issue GET only, found: {non_get}"


def test_regression_e_completed_no_retry(mock_exam_server):
    base_url, handler = mock_exam_server
    handler.job_status = "Completed"
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    res = subprocess.run(
        [sys.executable, str(script), "--mode", "resume", "--job-id", handler.job_id, f"--base-url={base_url}"],
        capture_output=True,
        text=True,
        env=env,
        timeout=5,
    )
    assert res.returncode == 0
    post_requests = [r for r in handler.requests_log if r["method"] == "POST"]
    assert len(post_requests) == 0, f"Completed job must never be retried, found: {post_requests}"


def test_regression_f_invalid_uuid_zero_network_mutation(mock_exam_server):
    base_url, handler = mock_exam_server
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    env = {**os.environ, "JWT_SIGNING_KEY": TEST_JWT_SECRET, "EXAM_SERVICE_URL": base_url}

    res = subprocess.run(
        [sys.executable, str(script), "--mode", "resume", "--job-id", "not-a-valid-uuid", f"--base-url={base_url}"],
        capture_output=True,
        text=True,
        env=env,
    )
    assert res.returncode != 0
    assert len(handler.requests_log) == 0, f"Expected 0 requests for invalid UUID, got {handler.requests_log}"


def test_regression_g_missing_config_fails_safely():
    repo_root = Path(__file__).resolve().parents[4]
    script = repo_root / "run_e2e_admin_job.py"
    clean_env = {k: v for k, v in os.environ.items() if k not in ("JWT_SIGNING_KEY", "JwtSettings__SignKey")}
    res = subprocess.run(
        [sys.executable, str(script), "--mode", "monitor", "--job-id", "00000000-0000-0000-0000-000000000001"],
        capture_output=True,
        text=True,
        env=clean_env,
        timeout=5,
    )
    assert res.returncode != 0
    assert "JWT_SIGNING_KEY" in (res.stdout + res.stderr) or "required" in (res.stdout + res.stderr).lower()

