"""Server-side mirror of questionSchemas.ts jsonShape + constraints.

This module loads canonical constraints, shapes, and examples directly from
autogen_contract.json which is locked against the canonical standard exam
(11111111-1111-1111-1111-111111111111).
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

_CONTRACT_PATH = Path(__file__).resolve().parent / "autogen_contract.json"

try:
    with open(_CONTRACT_PATH, "r", encoding="utf-8") as _f:
        _CONTRACT_DATA: dict[str, Any] = json.load(_f)
except Exception as _exc:
    raise RuntimeError(f"Failed to load autogen contract from {_CONTRACT_PATH}: {_exc}") from _exc

GLOBAL_CONSTRAINTS: list[str] = list(_CONTRACT_DATA.get("globalConstraints", []))
CONSTRAINTS: dict[str, list[str]] = {
    str(k): list(v) for k, v in _CONTRACT_DATA.get("constraints", {}).items()
}

_EXAMPLES: list[dict[str, Any]] = _CONTRACT_DATA.get("examples", [])

JSON_SHAPES: dict[str, str] = {}
for _qtype in CONSTRAINTS:
    _matching = [
        _e for _e in _EXAMPLES
        if isinstance(_e, dict) and _e.get("question", {}).get("type") == _qtype
    ]
    if not _matching:
        raise RuntimeError(f"Missing canonical example for constraint type: {_qtype}")
    JSON_SHAPES[_qtype] = json.dumps(
        _matching[0]["question"], ensure_ascii=False, indent=2
    )


def get_json_shape(qtype: str) -> str:
    """Return the canonical JSON shape for a question type."""
    if qtype not in JSON_SHAPES:
        raise KeyError(f"Unknown question type: {qtype}")
    return JSON_SHAPES[qtype]


def get_constraints(qtype: str) -> list[str]:
    """Return the constraint strings for a question type."""
    return CONSTRAINTS.get(qtype, [])
