import pytest
from pydantic import ValidationError

from app.schemas.rag_feedback import (
    Evidence,
    CriterionScore,
    Suggestion,
    RagFeedbackEnvelope,
)

def test_envelope_minimal_valid():
    env = RagFeedbackEnvelope(
        item_id="x1",
        domain="reading",
        criteria=[CriterionScore(name="comprehension", band=6.5, comment="ok")],
    )
    assert env.domain == "reading"
    assert env.criteria[0].band == 6.5
    assert env.evidence == []
    assert env.suggestions == []
    assert env.overall_band is None
    assert env.raw_llm_json == ""

def test_evidence_validates_relevance_range():
    with pytest.raises(ValidationError):
        Evidence(id="e1", text="x", source="passage:inline", relevance=1.5)

def test_criterion_score_band_range():
    with pytest.raises(ValidationError):
        CriterionScore(name="x", band=10.0, comment="bad")

def test_suggestion_requires_target():
    s = Suggestion(text="do this", target="vocabulary")
    assert s.target == "vocabulary"

def test_envelope_rejects_empty_criteria():
    with pytest.raises(ValidationError):
        RagFeedbackEnvelope(item_id="x", domain="writing", criteria=[])

def test_envelope_accepts_all_domains():
    for d in ("writing", "reading", "listening", "speaking", "grammar"):
        env = RagFeedbackEnvelope(
            item_id="x",
            domain=d,
            criteria=[CriterionScore(name="x", band=6.0, comment="c")],
        )
        assert env.domain == d
