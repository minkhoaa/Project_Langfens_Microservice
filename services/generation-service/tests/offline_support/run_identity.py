"""Matched offline comparison: stable UUID stream reset by pytest node identity.

Opt in with -p run_identity and this directory on PYTHONPATH. Never load this
plugin in a live service or a provider campaign.
"""
import hashlib
import random
import uuid

_rng = random.Random(0)


def stable_uuid4():
    return uuid.UUID(int=_rng.getrandbits(128), version=4)


uuid.uuid4 = stable_uuid4


def pytest_runtest_setup(item):
    _rng.seed(int.from_bytes(hashlib.sha256(item.nodeid.encode()).digest(), "big"))
