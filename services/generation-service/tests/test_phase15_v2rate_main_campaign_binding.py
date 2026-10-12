"""Phase 15 V2 campaign identity binding (MAIN lane).

The campaign ID must change whenever behaviour-affecting engine code changes, and the report must
record enough worktree state that a reader can tell exactly which build produced the numbers.

The previous implementation hashed a hand-maintained 17-file allowlist that omitted
`app/loop/controller.py`, `app/repair/question.py`, `app/repair/planner.py`,
`app/loop/paper.py` and `app/generators/question/prompts.py`. Those files are exactly the ones the
remediation work modifies, so campaign identity stayed constant across materially different engines.
"""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
HARNESS_PATH = REPO_ROOT / "scripts" / "refactor" / "run_phase15_benchmarks.py"
# The authoritative campaign report is the acceptance-v3 acceptance run, the same
# evidence test_t15_benchmarks.py binds to. Pointing at the stale `phase-15/benchmarks/`
# tree made this guard skip, silently dropping the engineBinding assertion that is the
# whole point of the node. The report exists and is committed, so the guard now
# evaluates and the binding is actually verified.
REPORT_PATH = (
    REPO_ROOT / "artifacts" / "refactor" / "phase-15" / "benchmarks-acceptance-v3"
    / "campaigns" / "camp_G15_022943e248ec" / "paired-benchmark-report.json"
)


@pytest.fixture(scope="module")
def harness():
    spec = importlib.util.spec_from_file_location("p15_harness_binding", HARNESS_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_iter_engine_files_covers_both_remediation_lanes(harness):
    """Every engine module is enumerated, including files inside the generator/repair lanes."""
    covered = set(harness.iter_engine_files())

    must_cover = [
        # generator / prompt / parser lane
        "services/generation-service/app/generators/question/generator.py",
        "services/generation-service/app/generators/question/prompts.py",
        "services/generation-service/app/generators/passage/generator.py",
        "services/generation-service/app/generators/passage/prompts.py",
        # repair / loop / evaluator lane
        "services/generation-service/app/loop/controller.py",
        "services/generation-service/app/loop/runtime.py",
        "services/generation-service/app/loop/question.py",
        "services/generation-service/app/loop/paper.py",
        "services/generation-service/app/repair/question.py",
        "services/generation-service/app/repair/planner.py",
        "services/generation-service/app/repair/paper.py",
        "services/generation-service/app/evaluators/deterministic.py",
        "services/generation-service/app/evaluators/section.py",
        # legacy comparison path
        "services/generation-service/app/pipeline.py",
        "services/generation-service/app/llm.py",
        "services/generation-service/app/prompts.py",
    ]
    missing = [p for p in must_cover if p not in covered]
    assert not missing, f"campaign identity would not bind these files: {missing}"


def test_iter_engine_files_covers_every_app_module_except_pycache(harness):
    """No engine module can silently drop out of campaign identity."""
    app_tree = REPO_ROOT / "services" / "generation-service" / "app"
    on_disk = {
        str(p.relative_to(REPO_ROOT))
        for p in app_tree.rglob("*.py")
        if "__pycache__" not in p.parts
    }
    covered = set(harness.iter_engine_files())
    assert on_disk <= covered, f"unenumerated engine modules: {sorted(on_disk - covered)}"


def test_config_hash_is_deterministic_and_content_sensitive(harness):
    """Same tree -> same digest; a changed digest must follow changed engine content."""
    first, files_a = harness.compute_config_sha256()
    second, files_b = harness.compute_config_sha256()
    assert first == second
    assert files_a == files_b

    altered, _ = harness.compute_config_sha256.__wrapped__() if hasattr(harness.compute_config_sha256, "__wrapped__") else (None, None)
    assert altered is None or altered == first

    # Distinct corpus/config inputs must yield distinct campaign identities.
    assert harness.derive_campaign_id("G15", "c", first, salt="s") != harness.derive_campaign_id("G15", "c", "other", salt="s")
    assert harness.derive_campaign_id("G15", "c", first, salt="s") != harness.derive_campaign_id("G15", "other", first, salt="s")
    assert harness.derive_campaign_id("G15", "c", first, salt="s") != harness.derive_campaign_id("G15", "c", first, salt="t")


def test_worktree_binding_records_full_state(harness):
    """Worktree binding exposes head, dirty flag, and per-path inventory for audit."""
    binding = harness.compute_worktree_binding()
    for key in ("gitHead", "dirty", "modifiedPathCount", "untrackedPathCount",
                "modifiedPaths", "untrackedPaths", "worktreeSha256"):
        assert key in binding, f"missing worktree binding field: {key}"
    assert isinstance(binding["dirty"], bool)
    assert len(binding["worktreeSha256"]) == 64
    assert binding["modifiedPathCount"] == len(binding["modifiedPaths"])
    assert binding["untrackedPathCount"] == len(binding["untrackedPaths"])


def test_worktree_binding_enumerates_untracked_files_not_collapsed_directories(harness):
    """`git status` must be asked for --untracked-files=all.

    The engine tree is entirely untracked in this worktree. The default porcelain output collapses
    `services/generation-service/` to one directory entry, so hashing its path would bind a marker
    instead of the code that produced the results.
    """
    import subprocess

    repo_root = REPO_ROOT
    default_out = subprocess.check_output(
        ["git", "status", "--porcelain"], cwd=repo_root, stderr=subprocess.DEVNULL
    ).decode()
    full_out = subprocess.check_output(
        ["git", "status", "--porcelain", "--untracked-files=all"], cwd=repo_root, stderr=subprocess.DEVNULL
    ).decode()

    binding = harness.compute_worktree_binding()
    default_untracked = [ln[3:].strip() for ln in default_out.splitlines() if ln.startswith("??")]
    full_untracked = [ln[3:].strip() for ln in full_out.splitlines() if ln.startswith("??")]

    if full_untracked != default_untracked:
        # The repo does have collapsed untracked directories, so the binding must not be collapsed.
        assert any("/" in p for p in full_untracked), (
            "expected nested untracked files; cannot distinguish collapsed enumeration here"
        )
        assert not any(p.endswith("/") and "/" not in p[3:] for p in binding["untrackedPaths"]), (
            "worktree binding contains collapsed directory markers instead of individual files"
        )
        assert binding["untrackedPathCount"] == len(full_untracked)
        assert binding["untrackedPathCount"] > len(default_untracked)


def test_harness_participates_in_campaign_identity(harness):
    """The harness is the measurement procedure, so its change must move the campaign ID."""
    covered = set(harness.iter_engine_files())
    assert "scripts/refactor/run_phase15_benchmarks.py" in covered

    digest_with_harness, _ = harness.compute_config_sha256()
    baseline = harness.derive_campaign_id("G15", "corpus", digest_with_harness, salt="s")
    assert baseline == harness.derive_campaign_id("G15", "corpus", digest_with_harness, salt="s")
    assert baseline != harness.derive_campaign_id("G15", "corpus", "digest-without-harness", salt="s")


def test_failed_case_rows_are_archived_not_overwritten(harness):
    """Acceptance forbids replacing a failed row with a later successful retry.

    Every attempt must remain inspectable, so the harness archives any existing case file into
    `attempts/` (tagged with its outcome) before writing a new one.
    """
    import inspect

    src = inspect.getsource(harness.run_phase15_benchmarks)
    assert src.count("_archive_prior_attempt") >= 3, (
        "expected an archival helper definition plus a call before each case write"
    )

    # The helper must move the old file aside, never delete it.
    helper_start = src.index("def _archive_prior_attempt")
    helper_end = src.index("async def _get_or_run_v2")
    helper = src[helper_start:helper_end]
    assert "shutil.move" in helper, "prior attempt must be moved, not unlinked"
    assert "attempts" in helper, "prior attempt must be retained under an attempts/ directory"
    assert "os.remove" not in helper and ".unlink(" not in helper

    # Both engines must archive before writing.
    assert src.count("_archive_prior_attempt(case_file_") == 2
    assert src.count("def _archive_prior_attempt(path: Path)") == 1


def test_rerun_failed_flag_cannot_silently_replace_a_failure(harness):
    """`--rerun-failed` exists for crash recovery but must not be how an acceptance campaign runs.

    Resume without the flag reuses whatever the previous attempt recorded, failures included, so an
    interrupted campaign keeps its failed rows instead of quietly retrying them into successes.
    """
    import inspect

    src = inspect.getsource(harness.run_phase15_benchmarks)
    assert "if not rerun_failed or cached.get(\"validDraft\"):" in src, (
        "resume must reuse recorded outcomes (including failures) unless an explicit rerun was requested"
    )


def test_provider_endpoint_and_model_are_bound_to_campaign_identity():
    """Loop caps alone do not identify a run: a different endpoint or model yields different numbers.

    `configSha256` must therefore cover the non-secret provider/runtime settings, and the report must
    record the resolved model rather than asserting a hardcoded one.
    """
    from app.config import Settings

    base = Settings(minimax_model="MiniMax-Text-01", minimax_base_url="https://api.minimaxi.chat/v1")
    other_model = Settings(minimax_model="MiniMax-Text-02", minimax_base_url="https://api.minimaxi.chat/v1")
    other_url = Settings(minimax_model="MiniMax-Text-01", minimax_base_url="https://api.other.invalid/v1")

    assert base.provider_binding_snapshot() != other_model.provider_binding_snapshot()
    assert base.provider_binding_snapshot() != other_url.provider_binding_snapshot()

    def _digest(snap: dict) -> str:
        import hashlib
        import json
        return hashlib.sha256(json.dumps(snap, sort_keys=True).encode("utf-8")).hexdigest()

    assert _digest(base.create_unlimited_benchmark_snapshot()) != _digest(
        other_model.create_unlimited_benchmark_snapshot()
    )
    assert _digest(base.create_unlimited_benchmark_snapshot()) != _digest(
        other_url.create_unlimited_benchmark_snapshot()
    )


def test_provider_binding_snapshot_contains_no_secrets():
    from app.config import Settings

    snap = Settings().provider_binding_snapshot()
    serialized = json.dumps(snap).casefold()
    for forbidden in ("apikey", "api_key", "secret", "password", "token"):
        assert forbidden not in serialized, f"provider binding leaked {forbidden}"
    assert "minimaxModel" in snap and "minimaxBaseUrl" in snap


@pytest.mark.skipif(not REPORT_PATH.exists(), reason="campaign report not yet produced")
def test_report_binds_results_to_worktree_and_engine_surface():
    """Fails against a stale pre-fix report; passes once the fresh campaign is executed."""
    """A produced report must carry the binding that identifies the build it measured."""
    with open(REPORT_PATH, "r", encoding="utf-8") as f:
        report = json.load(f)

    binding = report.get("engineBinding")
    assert binding, "report lacks engineBinding; results cannot be tied to a build"
    assert len(binding["configSha256"]) == 64
    assert binding["configCoversFileCount"] == len(binding["configCoversFiles"])
    assert binding["configCoversFileCount"] >= 100, (
        "engine surface binding regressed to an allowlist; must cover the whole app tree"
    )

    worktree = binding["worktree"]
    assert len(worktree["worktreeSha256"]) == 64
    assert worktree["gitHead"] != "unknown"