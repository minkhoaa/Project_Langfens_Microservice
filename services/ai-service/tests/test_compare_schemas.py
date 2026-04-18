from app.schemas import CompareRequest, CompareResponse, SentenceComparison, ReferenceEssay


def test_compare_request_defaults():
    req = CompareRequest(
        essay_text="A" * 50,
        topic="Describe a chart",
        student_band=6.0,
    )
    assert req.task_type == "TASK_2"
    assert req.student_band == 6.0


def test_compare_request_validation():
    import pytest
    with pytest.raises(Exception):
        CompareRequest(essay_text="short", topic="ok topic here")


def test_compare_request_task_type_literal():
    import pytest
    with pytest.raises(Exception):
        CompareRequest(
            essay_text="A" * 50,
            topic="topic here",
            task_type="TASK_3",
            student_band=6.0,
        )


def test_sentence_comparison():
    sc = SentenceComparison(
        original="I think education is important.",
        improved="Education plays a crucial role in society.",
        explanation="More sophisticated vocabulary",
        category="vocabulary",
    )
    assert sc.category == "vocabulary"


def test_sentence_comparison_invalid_category():
    import pytest
    with pytest.raises(Exception):
        SentenceComparison(original="x", improved="y", explanation="z", category="invalid")


def test_compare_response_defaults():
    resp = CompareResponse(overall_analysis="Good essay", references=[])
    assert resp.vocabulary_feedback == ""
    assert resp.sentence_comparisons == []


def test_reference_essay():
    ref = ReferenceEssay(id="abc", text="Essay text", band=8.5, similarity_score=0.92)
    assert ref.band == 8.5
