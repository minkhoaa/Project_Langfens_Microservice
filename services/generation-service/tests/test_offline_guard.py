"""The offline guard permits only a test's explicitly selected loopback socket."""
import importlib.util
from pathlib import Path
import socket
import subprocess

import pytest


@pytest.fixture
def guard(monkeypatch):
    # Loading sitecustomize must not stack wrappers on the running pytest process.
    with monkeypatch.context() as context:
        for owner, name in ((socket.socket, "connect"), (socket.socket, "connect_ex"), (subprocess, "run")):
            context.setattr(owner, name, getattr(owner, name))
        path = Path(__file__).parent / "offline_support" / "sitecustomize.py"
        spec = importlib.util.spec_from_file_location("offline_guard_under_test", path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    monkeypatch.delenv("OFFLINE_GUARD_ALLOW_LOOPBACK", raising=False)
    return module


@pytest.mark.parametrize("method", ["_connect", "_connect_ex"])
@pytest.mark.parametrize("family,address,opt_in,allowed", [
    (socket.AF_INET, ("127.0.0.1", 32123), None, False),
    (socket.AF_INET6, ("::1", 32123, 0, 0), None, False),
    (socket.AF_INET, ("127.0.0.1", 32123), "127.0.0.1:32123", True),
    (socket.AF_INET6, ("::1", 32123, 0, 0), "[::1]:32123", True),
    (socket.AF_INET, ("127.0.0.1", 32124), "127.0.0.1:32123", False),
    (socket.AF_INET, ("127.0.0.2", 32123), "127.0.0.2:32123", False),
    (socket.AF_INET, ("localhost", 32123), "localhost:32123", False),
    (socket.AF_INET, ("127.0.0.1", 32123), "localhost:32123", False),
    (socket.AF_INET, ("203.0.113.1", 32123), "203.0.113.1:32123", False),
    (socket.AF_INET, ("203.0.113.1", 32123), "127.0.0.1:32123", False),
    (socket.AF_INET, ("0.0.0.0", 32123), "0.0.0.0:32123", False),
    (socket.AF_INET6, ("::ffff:127.0.0.1", 32123, 0, 0), "[::ffff:127.0.0.1]:32123", False),
    (socket.AF_INET, ("127.0.0.1", 0), "127.0.0.1:0", False),
    (socket.AF_INET, ("127.0.0.1", 65536), "127.0.0.1:65536", False),
    (socket.AF_INET, ("127.0.0.1", 32123), "*", False),
    (socket.AF_INET, ("127.0.0.1", 32123), "true", False),
    (socket.AF_INET, ("127.0.0.1", 32123), "127.0.0.1:32123,203.0.113.1:32123", False),
])
def test_offline_guard_exact_loopback_only(guard, monkeypatch, method, family, address, opt_in, allowed):
    from unittest.mock import Mock

    original = Mock(return_value=17)
    monkeypatch.setattr(guard, "_original_connect" if method == "_connect" else "_original_connect_ex", original)
    if opt_in is not None:
        monkeypatch.setenv("OFFLINE_GUARD_ALLOW_LOOPBACK", opt_in)
    with socket.socket(family, socket.SOCK_STREAM) as sock:
        if allowed:
            assert getattr(guard, method)(sock, address) == 17
            original.assert_called_once_with(sock, address)
        else:
            with pytest.raises(RuntimeError, match="OFFLINE_GUARD: TCP connections forbidden"):
                getattr(guard, method)(sock, address)
            original.assert_not_called()


def test_offline_guard_unix_sockets_unchanged(guard, monkeypatch):
    from unittest.mock import Mock

    original = Mock(return_value=None)
    monkeypatch.setattr(guard, "_original_connect", original)
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        guard._connect(sock, "/tmp/offline-test-not-opened.sock")
        original.assert_called_once_with(sock, "/tmp/offline-test-not-opened.sock")


@pytest.mark.parametrize("tool", ["docker", "psql", "dotnet"])
def test_offline_guard_loopback_opt_in_does_not_enable_service_tools(guard, monkeypatch, tool):
    monkeypatch.setenv("OFFLINE_GUARD_ALLOW_LOOPBACK", "127.0.0.1:32123")
    result = guard._run([tool, "--version"], capture_output=True, text=True)
    assert result.returncode == 1
    assert result.stderr == "OFFLINE_GUARD: external service tools disabled"
