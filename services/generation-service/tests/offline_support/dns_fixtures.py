"""Controlled DNS answers for SSRF unit tests; no network lookup or safety bypass."""
import socket

import pytest


@pytest.fixture
def public_dns(monkeypatch):
    resolved = []
    public_hosts = {"example.com", "example.org", "www.nature.com", "nature.com", "europepmc.org"}

    def resolve(host, port, *args, **kwargs):
        assert host in public_hosts, f"Unexpected DNS lookup in offline test: {host}"
        resolved.append(host)
        return [(socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP, "", ("93.184.216.34", port or 0))]

    monkeypatch.setattr("app.ingestion.security.socket.getaddrinfo", resolve)
    return resolved
