import json
from unittest.mock import AsyncMock, patch

import pytest

from app.schemas import WritingGradeRequest

@pytest.mark.asyncio
async def test_grade_writing_returns_envelope_with_evidence_ids():
    req = WritingGradeRequest(
        task="Some IELTS task",
        answer="x " * 300,
        word_count=300,
        task_type="TASK_2",
    )

    fake_refs_by_criterion = {
        "ta": [],
        "cc": [],
        "lr": [],
        "gr": [],
    }

    llm_result = {
        "ob": 6.5,
        "ta": {"b": 6.0, "c": "...", "evidence_ids": ["ref-ta-1"]},
        "cc": {"b": 6.0, "c": "...", "evidence_ids": []},
        "lr": {"b": 7.0, "c": "...", "evidence_ids": ["ref-lr-1"]},
        "gr": {"b": 6.0, "c": "...", "evidence_ids": []},
        "s": ["tip"],
        "p": "improved",
    }

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value=fake_refs_by_criterion),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(return_value=llm_result),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    # Existing flat fields still work
    assert resp.ta.b == 6.0
    assert resp.cc.b == 6.0
    assert resp.lr.b == 7.0
    assert resp.gr.b == 6.0
    # Envelope is populated
    assert resp.envelope is not None
    assert resp.envelope.domain == "writing"
    assert resp.envelope.overall_band == 6.5
    crits = {c.name: c for c in resp.envelope.criteria}
    assert crits["task_response"].band == 6.0
    assert crits["task_response"].evidence_ids == ["ref-ta-1"]
    assert crits["lexical_resource"].evidence_ids == ["ref-lr-1"]
    assert crits["grammatical_range"].evidence_ids == []

@pytest.mark.asyncio
async def test_grade_writing_degrades_when_llm_omits_evidence_ids():
    req = WritingGradeRequest(
        task="Some task prompt for IELTS writing",
        answer="x " * 300,
        word_count=300,
        task_type="TASK_2",
    )
    llm_result = {
        "ob": 6.0,
        "ta": {"b": 6.0, "c": "no ids"},
        "cc": {"b": 6.0, "c": "no ids"},
        "lr": {"b": 6.0, "c": "no ids"},
        "gr": {"b": 6.0, "c": "no ids"},
        "s": [],
        "p": "",
    }

    with patch(
        "app.services.per_criterion_rag.retrieve",
        new=AsyncMock(return_value={"ta": [], "cc": [], "lr": [], "gr": []}),
    ), patch(
        "app.services.grade_service.llm_service.generate",
        new=AsyncMock(return_value=llm_result),
    ), patch(
        "app.services.grade_service.get_guardrails"
    ):
        from app.services.grade_service import grade_writing

        resp = await grade_writing(req)

    assert resp.envelope is not None
    for c in resp.envelope.criteria:
        assert c.evidence_ids == []
