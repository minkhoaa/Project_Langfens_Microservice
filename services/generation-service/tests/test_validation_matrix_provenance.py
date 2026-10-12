"""Regression checks for the authentic Validation Matrix source binding covering G00 through G15."""

from __future__ import annotations

import hashlib
import re
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[3]
MATRIX_PATH = REPO_ROOT / "docs/refactor/01-validation-matrix.md"
MASTER_PLAN_PATH = REPO_ROOT / "docs/refactor/00-master-plan.md"

EXPECTED_MATRIX_SHA256 = (
    "97710cfff1bcb7f0e7ccf04ee551e3781d2bf8f4fc7b98ed10e27d4940396cfe"
)
EXPECTED_MASTER_PLAN_SHA256 = (
    "44dbfcd50f0bee0c4ff2701ab2f94e6d0c2b308c563adc9d35e1d02643379ebf"
)

GATE_ROW = re.compile(r"^\|\s*G([0-9]{2})\s*\|", re.MULTILINE)


def test_authentic_validation_matrix_sha256_binding() -> None:
    matrix_bytes = MATRIX_PATH.read_bytes()
    actual_hash = hashlib.sha256(matrix_bytes).hexdigest()
    assert actual_hash == EXPECTED_MATRIX_SHA256

    master_plan_bytes = MASTER_PLAN_PATH.read_bytes()
    actual_mp_hash = hashlib.sha256(master_plan_bytes).hexdigest()
    assert actual_mp_hash == EXPECTED_MASTER_PLAN_SHA256


def test_authentic_validation_matrix_structure_and_gate_coverage() -> None:
    matrix_text = MATRIX_PATH.read_text(encoding="utf-8")

    # Verify authentic section headers
    assert "# Ma trận kiểm định và nghiệm thu" in matrix_text
    assert "## 1. Trạng thái và cách ra quyết định" in matrix_text
    assert "## 2. Evidence bundle và runner contract" in matrix_text
    assert "## 3. Traceability của gate" in matrix_text
    assert "## 4. Acceptance thresholds đề xuất" in matrix_text
    assert "## 5. Dataset yêu cầu" in matrix_text
    assert "## 6. Chaos và recovery matrix" in matrix_text
    assert "## 7. Repair locality và invalidation rubric" in matrix_text
    assert "## 8. Release-blocking conditions" in matrix_text

    # Verify all 16 gates G00 through G15 are covered in the traceability table
    gate_matches = GATE_ROW.findall(matrix_text)
    expected_gates = [f"{i:02d}" for i in range(16)]
    assert gate_matches == expected_gates


def test_authentic_validation_matrix_thresholds() -> None:
    matrix_text = MATRIX_PATH.read_text(encoding="utf-8")

    # Hard safety and deterministic invariants: 100%
    assert "100% required fixtures pass; zero accepted invalid graph" in matrix_text

    # Critical fidelity must-reject set: 100%
    assert "100% critical known canaries rejected, tối thiểu 10 canary cases" in matrix_text

    # Semantic blocking recall: >=95% overall, >=90% per type
    assert "≥95% tổng hợp trên labeled invalid items; từng type không dưới 90%" in matrix_text

    # Ambiguity detection: >=90%
    assert "≥90% recall trên ambiguous labeled subset" in matrix_text

    # False rejection: <=10% over >=60 valid questions
    assert "≤10% valid labeled items bị blocking reject" in matrix_text
    assert "Corpus ≥60 valid questions, 6 types" in matrix_text
