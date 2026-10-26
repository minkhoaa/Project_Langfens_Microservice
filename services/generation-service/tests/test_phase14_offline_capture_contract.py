"""Safety checks for replaying an explicitly exported disposable-DB event."""
import hashlib
import json

import pytest

from tests.test_t14_harness_integration import execute_and_fetch_generated_draft_edit_outbox_event


def test_phase14_requires_explicit_database_before_any_subprocess(monkeypatch):
    monkeypatch.delenv("PHASE14_OUTBOX_EVENT_FILE", raising=False)
    monkeypatch.delenv("READING_TEST_POSTGRES", raising=False)
    monkeypatch.setattr("subprocess.run", lambda *a, **k: pytest.fail("Unselected database must not be probed"))
    with pytest.raises(AssertionError, match="Explicit disposable"):
        execute_and_fetch_generated_draft_edit_outbox_event()


@pytest.mark.parametrize("tamper", [False, True])
def test_phase14_capture_integrity_without_subprocess(tmp_path, monkeypatch, tamper):
    payload = {"idempotencyKey": "synthetic-capture-contract-test", "targetEntityType": "QUESTION"}
    capture = {
        "source_mode": "DISPOSABLE_POSTGRES_OUTBOX",
        "dotnet_test": "T14_01_EditGeneratedExam_CapturesExactLineageDiffHashesAndOutbox",
        "payload": payload,
        "payload_sha256": hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
    }
    if tamper:
        payload["targetEntityType"] = "MODIFIED"
    path = tmp_path / "synthetic-capture.json"
    path.write_text(json.dumps(capture))
    monkeypatch.setenv("PHASE14_OUTBOX_EVENT_FILE", str(path))
    monkeypatch.setattr("subprocess.run", lambda *a, **k: pytest.fail("Replay must not invoke external tools"))
    if tamper:
        with pytest.raises(AssertionError, match="was modified"):
            execute_and_fetch_generated_draft_edit_outbox_event()
    else:
        assert execute_and_fetch_generated_draft_edit_outbox_event() == payload
