import importlib.util
import subprocess
import urllib.request
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[3] / "scripts" / "benchmark_preflight_check.py"


def _load_preflight():
    spec = importlib.util.spec_from_file_location("benchmark_preflight_check", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_preflight_is_offline_and_never_dispatches_or_starts_compose(monkeypatch, capsys):
    module = _load_preflight()
    calls = []
    monkeypatch.setattr(urllib.request, "urlopen", lambda *a, **k: calls.append((a, k)))
    monkeypatch.setattr(subprocess, "run", lambda *a, **k: calls.append((a, k)))

    result = module.main()

    assert result == 0
    assert calls == []
    output = capsys.readouterr().out
    assert "provider_dispatches=0" in output
    assert "NOT A LIVE READINESS VERDICT" in output
