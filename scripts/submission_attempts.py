"""Crash-safe successor intents. No network or authorization is implicit here.

The caller supplies read-only authoritative reconciliation and one dispatch
function. A committed intent is never dispatched again, even if the process
crashed before sending. This sacrifices availability rather than risk billing
an uncertain request twice. Historical marker bytes are never rewritten.
"""
from __future__ import annotations

import hashlib
import json
import math
import os
from pathlib import Path
import sqlite3
import time
from uuid import UUID


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def digest(value):
    return hashlib.sha256(canonical(value).encode()).hexdigest()


def submit_successor_intent(marker_path, attempt_id, authorization, payload, source_sha, reconcile, send):
    marker_path = Path(marker_path)
    raw = marker_path.read_bytes()  # missing/corrupt history is NOT permission
    marker_hash = hashlib.sha256(raw).hexdigest()
    marker = json.loads(raw)
    if str(UUID(attempt_id)) != attempt_id:
        raise ValueError("Canonical new attempt UUID required")
    now = time.time()
    if (authorization.get("action") != "SUBMIT_SUCCESSOR" or not authorization.get("authorized_by") or
        authorization.get("attempt_id") != attempt_id or authorization.get("historical_marker_sha256") != marker_hash or
        authorization.get("payload_sha256") != digest(payload) or authorization.get("source_sha") != source_sha or
        authorization.get("policy_id") != "acceptance_5_4_4_v1" or payload.get("acceptancePolicy") != "acceptance_5_4_4_v1" or
        not isinstance(authorization.get("expires_at"), (float, int)) or not now < authorization["expires_at"] < now + 86400):
        raise RuntimeError("Explicit unexpired authorization bound to this attempt, history, payload and source is required")
    if not marker.get("job_id"):
        raise RuntimeError("Uncertain predecessor identity requires authoritative reconciliation; no successor permitted")

    ledger = Path(str(marker_path) + ".attempts.sqlite3")
    with sqlite3.connect(ledger, timeout=30, isolation_level=None) as db:
        db.execute("PRAGMA synchronous=FULL")
        db.execute("CREATE TABLE IF NOT EXISTS attempts (attempt_id TEXT PRIMARY KEY, marker_hash TEXT UNIQUE NOT NULL, authorization TEXT NOT NULL, payload TEXT NOT NULL, proof TEXT NOT NULL, state TEXT NOT NULL, job_id TEXT, created REAL NOT NULL)")
        db.execute("CREATE TABLE IF NOT EXISTS audit (seq INTEGER PRIMARY KEY AUTOINCREMENT, attempt_id TEXT NOT NULL, event TEXT NOT NULL, evidence TEXT NOT NULL, at REAL NOT NULL)")
        # Directory entry durability matters on the first intent, not only SQLite pages.
        directory = os.open(ledger.parent, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
        db.execute("BEGIN IMMEDIATE")
        try:
            if marker_path.read_bytes() != raw:
                raise RuntimeError("Historical marker changed while authorizing successor")
            existing = db.execute("SELECT attempt_id, authorization, payload, state, job_id FROM attempts WHERE marker_hash=? OR attempt_id=?", (marker_hash, attempt_id)).fetchone()
            if existing:
                if existing[:3] != (attempt_id, canonical(authorization), canonical(payload)):
                    raise RuntimeError("A successor already owns this historical intent or attempt identity")
                if existing[3] == "SUBMITTED" and existing[4]:
                    db.execute("COMMIT")
                    return existing[4]
                raise RuntimeError("Submission intent is unresolved; reconcile it, never redispatch or create a successor")
            proof = reconcile(marker["job_id"])
            required = ("job_epoch", "run_epoch", "job_cancel_version", "run_cancel_version", "unresolved_operations",
                "job_lease_owner", "run_lease_owner", "job_lease_until", "run_lease_until")
            if not isinstance(proof, dict) or any(k not in proof for k in required):
                raise RuntimeError("Incomplete authoritative terminal reconciliation")
            expected = {"Failed": "FAILED", "Cancelled": "CANCELLED", "NeedsSources": "NEEDS_SOURCES"}
            if (str(proof.get("job_id")) != marker["job_id"] or proof.get("job_status") not in expected or
                proof.get("run_status") != expected[proof["job_status"]] or
                type(proof["unresolved_operations"]) is not int or proof["unresolved_operations"] != 0 or
                any(type(proof[k]) is not int or proof[k] < 1 for k in ("job_epoch", "run_epoch")) or
                proof["job_epoch"] != proof["run_epoch"] or
                any(type(proof[k]) is not int or proof[k] < 0 for k in ("job_cancel_version", "run_cancel_version")) or
                proof["job_cancel_version"] != proof["run_cancel_version"] or
                proof["job_lease_owner"] is not None or proof["run_lease_owner"] is not None or
                any(v is not None and (not isinstance(v, (int, float)) or not math.isfinite(v) or v >= now) for v in (proof["job_lease_until"], proof["run_lease_until"]))):
                raise RuntimeError("Predecessor is not provably terminal with reconciled operations and matching fences")
            db.execute("INSERT INTO attempts VALUES (?, ?, ?, ?, ?, 'INTENT', NULL, ?)",
                (attempt_id, marker_hash, canonical(authorization), canonical(payload), canonical(proof), now))
            db.execute("INSERT INTO audit(attempt_id,event,evidence,at) VALUES (?, 'INTENT', ?, ?)",
                (attempt_id, canonical({"authorization_sha256": digest(authorization), "proof_sha256": digest(proof), "marker_sha256": marker_hash}), now))
            db.execute("COMMIT")
        except BaseException:
            if db.in_transaction:
                db.execute("ROLLBACK")
            raise
        try:
            job_id = send(payload, attempt_id)
            if not isinstance(job_id, str) or not job_id:
                raise RuntimeError("Missing authoritative submitted job identity")
        except Exception as error:
            db.execute("BEGIN IMMEDIATE")
            db.execute("UPDATE attempts SET state='UNCERTAIN' WHERE attempt_id=? AND state='INTENT'", (attempt_id,))
            db.execute("INSERT INTO audit(attempt_id,event,evidence,at) VALUES (?, 'UNCERTAIN', ?, ?)", (attempt_id, canonical({"error": str(error)}), time.time()))
            db.execute("COMMIT")
            raise
        db.execute("BEGIN IMMEDIATE")
        db.execute("UPDATE attempts SET state='SUBMITTED', job_id=? WHERE attempt_id=? AND state='INTENT'", (job_id, attempt_id))
        db.execute("INSERT INTO audit(attempt_id,event,evidence,at) VALUES (?, 'SUBMITTED', ?, ?)", (attempt_id, canonical({"job_id": job_id}), time.time()))
        db.execute("COMMIT")
        return job_id
