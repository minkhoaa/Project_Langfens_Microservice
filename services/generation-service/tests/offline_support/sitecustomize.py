"""Offline verification guard; use PYTHONPATH, preferably with --network none.

Deny TCP and external-service subprocess probes used by the Python suites. This
is test infrastructure, not a production network sandbox or provider adapter.
"""
import os
import socket
import subprocess

_original_connect = socket.socket.connect
_original_connect_ex = socket.socket.connect_ex


def _connect(self, address):
    if self.family in (socket.AF_INET, socket.AF_INET6):
        raise RuntimeError("OFFLINE_GUARD: TCP connections forbidden")
    return _original_connect(self, address)


def _connect_ex(self, address):
    if self.family in (socket.AF_INET, socket.AF_INET6):
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
