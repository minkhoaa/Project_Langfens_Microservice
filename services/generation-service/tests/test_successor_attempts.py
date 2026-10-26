"""Durable intent, not a cleared marker, authorizes a simulated successor."""
import hashlib
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from uuid import uuid4
import pytest

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))
import scripts.run_hybrid_single_section_live as runner


def inputs(tmp_path):
    marker = tmp_path / "history.json"
    marker.write_text(json.dumps({"status": "TERMINAL", "job_id": str(uuid4()), "terminal_status": "Failed"}))
    payload = {"topic": "offline", "acceptancePolicy": "acceptance_5_4_4_v1"}
    identity = str(uuid4())
    auth = {"action": "SUBMIT_SUCCESSOR", "attempt_id": identity, "authorized_by": "offline-test-operator",
        "expires_at": time.time() + 3600, "historical_marker_sha256": hashlib.sha256(marker.read_bytes()).hexdigest(),
        "payload_sha256": hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
        "source_sha": "offline-test-source", "policy_id": "acceptance_5_4_4_v1"}
    proof = {"job_id": json.loads(marker.read_text())["job_id"], "job_status": "Failed", "run_status": "FAILED",
        "job_epoch": 2, "run_epoch": 2, "job_cancel_version": 0, "run_cancel_version": 0,
        "job_lease_owner": None, "run_lease_owner": None, "job_lease_until": None, "run_lease_until": None,
        "unresolved_operations": 0}
    return marker, payload, identity, auth, proof


def execute(marker, payload, identity, auth, proof, send):
    return runner.submit_successor_intent(marker, identity, auth, payload, "offline-test-source", lambda _: proof, send)


def test_successor_preserves_marker_and_concurrent_reentry_never_reposts(tmp_path):
    marker, payload, identity, auth, proof = inputs(tmp_path)
    before = marker.read_bytes()
    sent = []
    def send(p, attempt):
        sent.append(attempt)
        return "simulated-job"
    def contender(_):
        try:
            return execute(marker, payload, identity, auth, proof, send)
        except RuntimeError:
            return "blocked"
    with ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(contender, range(8)))
    assert "simulated-job" in results
    assert sent == [identity]
    assert execute(marker, payload, identity, auth, proof, send) == "simulated-job"
    assert marker.read_bytes() == before


def test_legacy_initial_intent_is_also_an_atomic_claim(tmp_path, monkeypatch):
    marker = tmp_path / "legacy.json"
    monkeypatch.setattr(runner, "SUBMISSION_MARKER_PATH", str(marker))
    runner.SubmissionMarker.write("SUBMITTING")
    before = marker.read_bytes()
    with pytest.raises(RuntimeError, match="DUPLICATE"):
        runner.SubmissionMarker.write("SUBMITTING")
    assert marker.read_bytes() == before


def test_terminal_historical_marker_cannot_be_rewritten(tmp_path, monkeypatch):
    marker, *_ = inputs(tmp_path)
    before = marker.read_bytes()
    monkeypatch.setattr(runner, "SUBMISSION_MARKER_PATH", str(marker))
    with pytest.raises(RuntimeError, match="immutable"):
        runner.SubmissionMarker.write("RUNNING", job_id="new-job")
    assert marker.read_bytes() == before


@pytest.mark.parametrize("fault", ["authorization", "expiry", "identity", "marker", "payload", "source", "unknown", "running", "epoch", "lease", "cancel_unknown", "zero_epoch", "lease_nan"])
def test_successor_fails_closed_before_intent_or_dispatch(tmp_path, fault):
    marker, payload, identity, auth, proof = inputs(tmp_path)
    if fault == "authorization": auth["action"] = "ANALYZE_ONLY"
    if fault == "expiry": auth["expires_at"] = 0
    if fault == "identity": auth["attempt_id"] = str(uuid4())
    if fault == "marker": auth["historical_marker_sha256"] = "bad"
    if fault == "payload": payload["topic"] = "modified"
    if fault == "source": auth["source_sha"] = "bad"
    if fault == "unknown": proof["unresolved_operations"] = 1
    if fault == "running": proof["run_status"] = "RUNNING"
    if fault == "epoch": proof["run_epoch"] = 1
    if fault == "lease": proof["run_lease_owner"] = str(uuid4())
    if fault == "cancel_unknown": proof["job_cancel_version"] = proof["run_cancel_version"] = None
    if fault == "zero_epoch": proof["job_epoch"] = proof["run_epoch"] = 0
    if fault == "lease_nan": proof["run_lease_until"] = float("nan")
    with pytest.raises((RuntimeError, ValueError)):
        execute(marker, payload, identity, auth, proof, lambda *_: pytest.fail("No dispatch allowed"))


def test_worker_process_inventory_includes_host_and_container_duplicates(tmp_path):
    for pid, command in [(101, b"/usr/bin/dotnet\0/app/exam-service.dll\0"),
                         (202, b"/workspace/exam-service\0"), (303, b"python\0worker.py\0")]:
        directory = tmp_path / str(pid)
        directory.mkdir()
        (directory / "cmdline").write_bytes(command)
    assert runner.observe_exam_processes(tmp_path) == {"candidate_process_pids": [101, 202], "complete": True}
    (tmp_path / "202" / "cmdline").unlink()
    assert runner.observe_exam_processes(tmp_path) == {"candidate_process_pids": [101], "complete": True}


def test_process_death_after_durable_intent_never_redispatches(tmp_path):
    import subprocess
    marker, payload, identity, auth, proof = inputs(tmp_path)
    script = '''import json,os,sys
sys.path.insert(0, sys.argv[1])
from scripts.submission_attempts import submit_successor_intent
marker, identity, auth, payload, proof = json.loads(sys.argv[2])
def send(*_):
    os._exit(86)
submit_successor_intent(marker, identity, auth, payload, "offline-test-source", lambda _: proof, send)
'''
    result = subprocess.run([sys.executable, "-c", script, str(ROOT), json.dumps([str(marker), identity, auth, payload, proof])])
    assert result.returncode == 86
    with pytest.raises(RuntimeError, match="unresolved"):
        execute(marker, payload, identity, auth, proof, lambda *_: pytest.fail("No redispatch after actual process death"))


@pytest.mark.parametrize("crash", [False, True])
def test_uncertain_or_crashed_submission_blocks_reentry_and_all_other_successors(tmp_path, crash):
    marker, payload, identity, auth, proof = inputs(tmp_path)
    def send(*_):
        if crash:
            raise SystemExit("crash after durable intent")
        raise TimeoutError("uncertain outcome")
    with pytest.raises((TimeoutError, SystemExit)):
        execute(marker, payload, identity, auth, proof, send)
    with pytest.raises(RuntimeError):
        execute(marker, payload, identity, auth, proof, lambda *_: pytest.fail("No redispatch"))
    other = str(uuid4()); auth["attempt_id"] = other
    with pytest.raises(RuntimeError):
        execute(marker, payload, other, auth, proof, lambda *_: pytest.fail("No successor to uncertain attempt"))
