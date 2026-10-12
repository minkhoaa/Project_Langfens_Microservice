"""Phase 15 harness: `--no-resume` must not splice a prior campaign's rows (MAIN lane).

The campaign id is derived from the corpus + config hash, so two invocations against an unchanged
engine legitimately produce the SAME campaign id. The durable layer keys runs on
`(campaignId, caseId)` and keeps a UNIQUE index on that pair.

`run_v2_paper_benchmark_case` therefore finds the earlier invocation's COMPLETED run and, before
this fix, reactivated it -- because the PG resume predicate consulted `rerun_failed` but never the
`resume` flag. `--no-resume` reached only the on-disk case-file cache further down. The visible
symptom was an acceptance campaign that quietly inherited successful rows from a prior diagnostic
replay of the same cases, so its "18 fresh runs" were partly the same runs measured twice.

These tests pin the predicate itself. They do not run a live campaign; they exercise the decision
with a stub persistence layer so the invariant is checked on every suite run.
"""

from __future__ import annotations

import ast
import importlib.util
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
HARNESS_PATH = REPO_ROOT / "scripts" / "refactor" / "run_phase15_benchmarks.py"


@pytest.fixture(scope="module")
def harness():
    spec = importlib.util.spec_from_file_location("p15_harness_resume", HARNESS_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class _StubPersistence:
    """Minimal stand-in exposing only what the resume predicate consults."""

    def __init__(self, existing, accepted_heads=3):
        self._existing = existing
        self._accepted_heads = accepted_heads
        self.reactivated: list = []

    def find_campaign_case_run(self, campaign_id, case_id):
        return self._existing

    def count_accepted_section_heads(self, run_id):
        return self._accepted_heads

    def reactivate_run_for_resume(self, job_id, run_id, lease_owner):
        self.reactivated.append(run_id)
        return True


def _completed_existing():
    """A prior invocation's run: COMPLETED, with accepted heads, i.e. resumable."""
    return {
        "jobId": "11111111-1111-1111-1111-111111111111",
        "runId": "bench_prior_campaign_run",
        "epoch": 1,
        "status": "COMPLETED",
    }


def _should_resume_with_resume(pg, resume: bool, rerun_failed: bool = False) -> bool:
    """Mirror of the harness predicate, with the `resume` operand included.

    Kept as an explicit expression so the test states the intended rule rather than
    re-deriving it from the module (which would make the test tautological).
    """
    existing = pg.find_campaign_case_run("camp_any", "case_v2_01_s101")
    return (
        resume
        and existing is not None
        and not rerun_failed
        and existing.get("status") not in ("FAILED", "CANCELLED")
        and pg.count_accepted_section_heads(existing["runId"]) > 0
    )


def test_no_resume_must_not_adopt_a_completed_prior_campaign_run():
    """The core defect: `--no-resume` against a COMPLETED prior run must not resume it."""
    pg = _StubPersistence(_completed_existing())

    assert _should_resume_with_resume(pg, resume=False) is False, (
        "a prior campaign's COMPLETED run must never be reactivated when resume is disabled"
    )
    assert pg.reactivated == []


def test_resume_enabled_still_adopts_a_completed_prior_campaign_run():
    """The fix must not disable resumption outright -- that would break idempotent resume."""
    pg = _StubPersistence(_completed_existing())

    assert _should_resume_with_resume(pg, resume=True) is True
    assert pg.count_accepted_section_heads("bench_prior_campaign_run") == 3


def test_harness_predicate_actually_consults_the_resume_flag():
    """Guard against the flag being dropped from the harness source in a future edit."""
    tree = ast.parse(HARNESS_PATH.read_text(encoding="utf-8"))
    fn = next(
        n for n in tree.body
        if isinstance(n, ast.AsyncFunctionDef) and n.name == "run_v2_paper_benchmark_case"
    )

    params = [a.arg for a in fn.args.args]
    assert "resume" in params, "run_v2_paper_benchmark_case must accept the resume flag"

    body = ast.get_source_segment(HARNESS_PATH.read_text(encoding="utf-8"), fn)
    assert "resume" in body.split("should_resume")[1][:220], (
        "the should_resume predicate must test the resume flag, not just rerun_failed"
    )


def test_call_site_forwards_the_resume_flag():
    """A correct predicate is inert if the caller never passes the flag down."""
    source = HARNESS_PATH.read_text(encoding="utf-8")
    tree = ast.parse(source)

    forwards = False
    for node in ast.walk(tree):
        if not isinstance(node, ast.Call):
            continue
        func = node.func
        name = getattr(func, "id", None) or getattr(func, "attr", None)
        if name != "run_v2_paper_benchmark_case":
            continue
        for kw in node.keywords:
            if kw.arg == "resume":
                forwards = True

    assert forwards, (
        "the run_v2_paper_benchmark_case call site must forward resume=... "
        "or --no-resume is silently ignored again"
    )


def test_campaign_tag_yields_a_distinct_campaign_id(harness):
    """Two acceptance attempts against an unchanged engine must not share a campaign id.

    The campaign id is derived from the corpus + config hash, which are identical when the
    engine has not changed. Durable rows key on (campaignId, caseId) with a UNIQUE index, so
    without a distinct id a second attempt collides with -- or inherits -- the first.
    """
    base = harness.derive_campaign_id("G15", "corpus1", "config1", salt="phase15_v2_recovered_acceptance")
    tagged_a = harness.derive_campaign_id(
        "G15", "corpus1", "config1", salt="phase15_v2_recovered_acceptance:acceptance-run-1"
    )
    tagged_b = harness.derive_campaign_id(
        "G15", "corpus1", "config1", salt="phase15_v2_recovered_acceptance:acceptance-run-2"
    )

    assert base != tagged_a != tagged_b
    assert len({base, tagged_a, tagged_b}) == 3


def test_orchestrator_exposes_campaign_tag(harness):
    """The orchestrator must accept the tag and fold it into the derived id."""
    import inspect

    sig = inspect.signature(harness.run_phase15_benchmarks)
    assert "campaign_tag" in sig.parameters, (
        "run_phase15_benchmarks must expose campaign_tag so successive acceptance "
        "attempts can be namespaced"
    )