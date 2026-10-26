"""Offline verification guard; use PYTHONPATH, preferably with --network none.

Deny TCP and external-service subprocess probes used by the Python suites.
A subprocess test may opt in to one exact literal loopback host:port with
OFFLINE_GUARD_ALLOW_LOOPBACK (IPv6 uses [::1]:port). No hostnames or ranges.
This is test infrastructure, not a production network sandbox or provider adapter.
"""
import os
import socket
import subprocess

_original_connect = socket.socket.connect
_original_connect_ex = socket.socket.connect_ex


def _allowed_loopback(address):
    if not isinstance(address, tuple) or len(address) not in (2, 4):
        return False
    host, port = address[:2]
    if host not in ("127.0.0.1", "::1") or type(port) is not int or not 1 <= port <= 65535:
        return False
    endpoint = f"[{host}]:{port}" if host == "::1" else f"{host}:{port}"
    return os.environ.get("OFFLINE_GUARD_ALLOW_LOOPBACK") == endpoint


def _connect(self, address):
    if self.family in (socket.AF_INET, socket.AF_INET6) and not _allowed_loopback(address):
        raise RuntimeError("OFFLINE_GUARD: TCP connections forbidden")
    return _original_connect(self, address)


def _connect_ex(self, address):
    if self.family in (socket.AF_INET, socket.AF_INET6) and not _allowed_loopback(address):
        raise RuntimeError("OFFLINE_GUARD: TCP connections forbidden")
    return _original_connect_ex(self, address)


socket.socket.connect = _connect
socket.socket.connect_ex = _connect_ex
_original_run = subprocess.run


def _run(args, *pos, **kw):
    command = args[0] if isinstance(args, (list, tuple)) and args else args
    if isinstance(command, str) and os.path.basename(command) in {"docker", "psql", "dotnet"}:
        text = kw.get("text") or kw.get("encoding") or kw.get("universal_newlines")
        return subprocess.CompletedProcess(args, 1, "" if text else b"",
            "OFFLINE_GUARD: external service tools disabled" if text else b"OFFLINE_GUARD: external service tools disabled")
    return _original_run(args, *pos, **kw)


subprocess.run = _run
