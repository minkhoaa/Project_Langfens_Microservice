"""R03: explicit production profile resolution and fail-closed configuration."""
from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

from dotenv import dotenv_values
from pydantic import ValidationError
import pytest

from app.config import Settings


PROFILE = Path(__file__).resolve().parents[3] / "deploy/envs/loop-caps.env"
PROFILE_VALUES = dict(dotenv_values(PROFILE))


@pytest.fixture(autouse=True)
def isolated_cap_environment(monkeypatch):
    for name in tuple(os.environ):
        if name.upper() in PROFILE_VALUES or name.upper() == "ENVIRONMENT":
            monkeypatch.delenv(name)


def profile_file(tmp_path, changes=None, omitted=None):
    values = {**PROFILE_VALUES, **(changes or {}), "ENVIRONMENT": "production"}
    path = tmp_path / "caps.env"
    path.write_text("\n".join(f"{key}={value}" for key, value in values.items() if key != omitted))
    return path


@pytest.mark.parametrize("omitted", tuple(PROFILE_VALUES))
def test_production_requires_each_declared_profile_setting(tmp_path, omitted):
    with pytest.raises(ValidationError):
        Settings(_env_file=profile_file(tmp_path, omitted=omitted))


@pytest.mark.parametrize("key,value", [
    ("LOOP_CAPS_PROFILE_VERSION", "development-unpinned"),
    ("LOOP_CAPS_PROFILE_SOURCE", "development defaults"),
    ("LOOP_MAX_VERSIONS", "0"),
    ("LOOP_MAX_TOTAL_TOKENS", "not-an-integer"),
    ("LOOP_MAX_TOTAL_CALLS", ""),
    ("LOOP_MAX_WALL_TIME_SECONDS", "nan"),
    ("LOOP_MAX_WALL_TIME_SECONDS", "inf"),
    ("LOOP_MAX_WALL_TIME_SECONDS", "-inf"),
    ("LOOP_MAX_WALL_TIME_SECONDS", "1.5"),
    ("LOOP_MAX_TOTAL_CALLS", "2147483648"),
    ("LOOP_MAX_GENERATED_VERSIONS", "4"),
    ("READING_PAPER_BENCHMARK_PASSAGE_TOKEN_CAP", "8001"),
    ("LOOP_MIN_SCORE_THRESHOLD", "nan"),
    ("LOOP_MIN_SCORE_THRESHOLD", "1.1"),
])
def test_invalid_profile_fails_closed(tmp_path, key, value):
    with pytest.raises(ValidationError):
        Settings(_env_file=profile_file(tmp_path, {key: value}))


def test_environment_override_reaches_allocation_and_effective_snapshot(tmp_path, monkeypatch):
    path = profile_file(tmp_path)
    monkeypatch.setenv("READING_PAPER_BENCHMARK_PASSAGE_TOKEN_CAP", "7999")
    resolved = Settings(_env_file=path)
    assert resolved.benchmark_passage_token_cap == 7999
    assert resolved.loop_caps_snapshot()["caps"]["benchmarkArtifactPassageTokenCap"] == 7999
    assert resolved.loop_caps_profile_sha256 != Settings(_env_file=path, benchmark_passage_token_cap=7998).loop_caps_profile_sha256


def test_explicit_service_env_file_overrides_repository_profile(tmp_path):
    path = profile_file(tmp_path, {"LOOP_MAX_RESPONSE_BYTES": "4096"})
    result = subprocess.run(
        [sys.executable, "-c", "from app.config import settings; print(settings.loop_max_response_bytes)"],
        env={**os.environ, "GENERATION_SERVICE_ENV_FILE": str(path)},
        cwd=Path(__file__).resolve().parents[1], capture_output=True, text=True,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "4096"


def test_benchmark_isolation_extended_timeouts():
    from app.config import settings
    prod_snapshot = settings.loop_caps_snapshot()
    assert prod_snapshot["benchmarkMode"] == "LIMITED"
    assert prod_snapshot["caps"]["evaluatorSemanticTimeoutSeconds"] == 30
    assert prod_snapshot["caps"]["evaluatorStageTimeoutSeconds"] == 60
    assert prod_snapshot["caps"]["repairTimeoutSeconds"] == 30
    assert prod_snapshot["caps"]["loopOperationWallReservationSeconds"] == settings.loop_operation_wall_reservation_seconds
    assert prod_snapshot["caps"]["benchmarkArtifactSolverWallTimeCapSeconds"] == 15
    assert prod_snapshot["caps"]["benchmarkArtifactReviewWallTimeCapSeconds"] == 15

    bench_snapshot = settings.create_unlimited_benchmark_snapshot()
    assert bench_snapshot["benchmarkMode"] == "UNLIMITED"
    assert bench_snapshot["benchmarkMonetaryCapMode"] == "UNLIMITED"
    assert bench_snapshot["caps"]["evaluatorSemanticTimeoutSeconds"] == 300
    assert bench_snapshot["caps"]["evaluatorStageTimeoutSeconds"] == 300
    assert bench_snapshot["caps"]["repairTimeoutSeconds"] == 120
    assert bench_snapshot["caps"]["loopOperationWallReservationSeconds"] == 300
    assert bench_snapshot["caps"]["benchmarkArtifactSolverWallTimeCapSeconds"] == 180
    assert bench_snapshot["caps"]["benchmarkArtifactReviewWallTimeCapSeconds"] == 180

    # Production snapshot remains pinned and unmodified
    assert prod_snapshot["caps"]["evaluatorSemanticTimeoutSeconds"] == 30
    assert settings.loop_caps_snapshot()["caps"]["evaluatorSemanticTimeoutSeconds"] == 30


def test_benchmark_timeouts_propagate_to_runtime_policy_and_components():
    from unittest.mock import MagicMock
    from app.config import settings
    from app.loop.policy import LoopPolicy
    from app.loop.passage import PassageLoop
    from app.loop.paper import PaperLoop
    from app.evaluators.semantic import GroundingFidelityEvaluator
    from app.repair.passage import PassageSentenceRepairer
    # 1. Policy layer receives isolated timeouts
    prod_policy = LoopPolicy.from_settings(is_benchmark=False)
    assert prod_policy.evaluator_semantic_timeout_seconds == 30.0
    assert prod_policy.evaluator_stage_timeout_seconds == 60.0
    assert prod_policy.repair_timeout_seconds == 30.0
    assert prod_policy.operation_wall_reservation_seconds == float(settings.loop_operation_wall_reservation_seconds)

    bench_policy = LoopPolicy.from_settings(is_benchmark=True)
    assert bench_policy.evaluator_semantic_timeout_seconds == 300.0
    assert bench_policy.evaluator_stage_timeout_seconds == 300.0
    assert bench_policy.repair_timeout_seconds == 120.0
    assert bench_policy.operation_wall_reservation_seconds == 300.0

    # 2. PassageLoop default evaluators & repairer inherit correct timeout values
    mock_gen = MagicMock()
    mock_client = MagicMock()
    prod_loop = PassageLoop(generator=mock_gen, persistence_client=mock_client, is_benchmark=False)
    prod_grounding = next(ev for ev in prod_loop.evaluators if isinstance(ev, GroundingFidelityEvaluator))
    assert prod_grounding.metadata.timeout_seconds == 30.0
    assert isinstance(prod_loop.repairer, PassageSentenceRepairer)
    assert prod_loop.repairer.metadata.timeout_seconds == 30.0

    bench_loop = PassageLoop(generator=mock_gen, persistence_client=mock_client, is_benchmark=True)
    bench_grounding = next(ev for ev in bench_loop.evaluators if isinstance(ev, GroundingFidelityEvaluator))
    assert bench_grounding.metadata.timeout_seconds == 300.0
    assert isinstance(bench_loop.repairer, PassageSentenceRepairer)
    assert bench_loop.repairer.metadata.timeout_seconds == 120.0

    # 3. PaperLoop default evaluators inherit correct timeout values
    prod_paper = PaperLoop(is_benchmark=False)
    assert prod_paper.evaluator_registry.get("eval_paper_structure").metadata.timeout_seconds == 60.0

    bench_paper = PaperLoop(is_benchmark=True)


@pytest.mark.asyncio
async def test_facade_path_routes_benchmark_isolated_timeouts():
    from unittest.mock import AsyncMock, MagicMock, patch
    from uuid import uuid4
    from app.facade import GenerationFacade
    from app.evaluators.semantic import GroundingFidelityEvaluator
    from app.repair.passage import PassageSentenceRepairer
    from app.loop.passage import PassageLoop
    from app.loop.section import SectionLoop
    from app.loop.paper import PaperLoop

    mock_gw = MagicMock()
    mock_gw.checkpoint_client = None
    mock_client = MagicMock()
    facade = GenerationFacade(gateway=mock_gw, persistence_client=mock_client)

    # 1. Passage path: production vs benchmark
    with patch.object(PassageLoop, "run", new_callable=AsyncMock) as mock_p_run:
        mock_p_run.return_value = MagicMock()
        mock_ctx = MagicMock()
        mock_ctx.section_index = 1

        # Production call
        await facade.generate_passage_v2(passage_context=mock_ctx, run_id="run_prod_01", lease_owner=uuid4(), is_benchmark=False)
        prod_loop_instance = mock_p_run.call_args.args[0] if mock_p_run.call_args.args else mock_p_run.mock_calls[0]
        # Find the PassageLoop from the call or patch
        # Let's inspect via spy

    captured_loops = []
    orig_passage_init = PassageLoop.__init__
    def spy_passage_init(self, *args, **kwargs):
        orig_passage_init(self, *args, **kwargs)
        captured_loops.append(self)

    orig_paper_init = PaperLoop.__init__
    def spy_paper_init(self, *args, **kwargs):
        orig_paper_init(self, *args, **kwargs)
        captured_loops.append(self)

    with patch.object(PassageLoop, "__init__", spy_passage_init), \
         patch.object(PassageLoop, "run", new_callable=AsyncMock), \
         patch.object(PaperLoop, "__init__", spy_paper_init), \
         patch.object(PaperLoop, "run", new_callable=AsyncMock):

        mock_ctx = MagicMock()
        mock_env = MagicMock()
        mock_ref = MagicMock()

        # Production calls
        await facade.generate_passage_v2(passage_context=mock_ctx, run_id="run_prod_01", lease_owner=uuid4(), is_benchmark=False)
        prod_passage = captured_loops[-1]
        prod_gf = next(ev for ev in prod_passage.evaluators if isinstance(ev, GroundingFidelityEvaluator))
        assert prod_gf.metadata.timeout_seconds == 30.0
        assert prod_passage.repairer.metadata.timeout_seconds == 30.0

        await facade.generate_paper_v2(blueprint_ref=mock_ref, section_artifacts=[mock_env], run_id="run_prod_01", lease_owner=uuid4(), is_benchmark=False)
        prod_paper = captured_loops[-1]
        assert prod_paper.evaluator_registry.get("eval_paper_structure").metadata.timeout_seconds == 60.0

        # Benchmark calls (by is_benchmark=True or run_id="bench_...")
        await facade.generate_passage_v2(passage_context=mock_ctx, run_id="bench_case_01", lease_owner=uuid4())
        bench_passage = captured_loops[-1]
        bench_gf = next(ev for ev in bench_passage.evaluators if isinstance(ev, GroundingFidelityEvaluator))
        assert bench_gf.metadata.timeout_seconds == 300.0
        assert bench_passage.repairer.metadata.timeout_seconds == 120.0

        await facade.generate_paper_v2(blueprint_ref=mock_ref, section_artifacts=[mock_env], run_id="bench_case_01", lease_owner=uuid4())
        bench_paper = captured_loops[-1]
        assert bench_paper.evaluator_registry.get("eval_paper_structure").metadata.timeout_seconds == 300.0
