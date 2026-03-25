import warnings
warnings.filterwarnings("ignore")

import pytest
from unittest.mock import AsyncMock, patch
from app.schemas import CompareRequest, SearchResult
from app.services.compare_service import (
    validate_sentence_comparisons_response,
    _parse_sentence_comparisons,
    compare_essay,
    _compare_exemplar,
)


MOCK_SEARCH_RESULTS = [
    SearchResult(id="r1", text="Band 9 essay about education...", score=0.92, metadata={"band_overall": 9.0, "task_type": "TASK_2", "word_count": 280}),
    SearchResult(id="r2", text="Another Band 8.5 essay...", score=0.88, metadata={"band_overall": 8.5, "task_type": "TASK_2", "word_count": 300}),
]


class TestValidateSentenceComparisonsResponse:
    """Tests for validate_sentence_comparisons_response function."""

    def test_sentence_comparisons_present_and_valid(self):
        """Happy path with valid data - key exists with valid list."""
        result = {
            "overall_analysis": "Good essay",
            "sentence_comparisons": [
                {"original": "I think", "improved": "I believe", "explanation": "More formal", "category": "vocabulary"}
            ]
        }
        validated = validate_sentence_comparisons_response(result)
        assert validated == result

    def test_sentence_comparisons_present_but_empty_list(self):
        """Key exists but value is empty list - should be accepted."""
        result = {
            "overall_analysis": "Good essay",
            "sentence_comparisons": []
        }
        validated = validate_sentence_comparisons_response(result)
        assert validated == result
        assert validated["sentence_comparisons"] == []

    def test_sentence_comparisons_missing_from_response(self):
        """Key is completely missing - should raise ValueError."""
        result = {
            "overall_analysis": "Good essay"
        }
        with pytest.raises(ValueError) as exc_info:
            validate_sentence_comparisons_response(result)
        assert "LLM response missing required field: sentence_comparisons" in str(exc_info.value)

    def test_sentence_comparisons_null_value(self):
        """Key exists but value is None - should handle gracefully since key is present."""
        result = {
            "overall_analysis": "Good essay",
            "sentence_comparisons": None
        }
        # Key exists, so validation passes - the parsing function handles the None case
        validated = validate_sentence_comparisons_response(result)
        assert validated == result


class TestParseSentenceComparisons:
    """Tests for _parse_sentence_comparisons function."""

    def test_sentence_comparisons_all_categories_valid(self):
        """All valid categories should be accepted."""
        raw_comparisons = [
            {"original": "good", "improved": "excellent", "explanation": "More precise", "category": "vocabulary"},
            {"original": "I thinks", "improved": "I think", "explanation": "Grammar fix", "category": "grammar"},
            {"original": "First... Then... Finally", "improved": "Firstly... Secondly... Finally", "explanation": "Better transitions", "category": "coherence"},
            {"original": "intro", "improved": "introduction", "explanation": "More formal", "category": "structure"},
        ]
        parsed = _parse_sentence_comparisons(raw_comparisons)
        assert len(parsed) == 4
        categories = [p.category for p in parsed]
        assert "vocabulary" in categories
        assert "grammar" in categories
        assert "coherence" in categories
        assert "structure" in categories

    def test_sentence_comparisons_malformed_items_filtered_out(self):
        """Items missing required fields should be filtered out."""
        raw_comparisons = [
            {"original": "valid item", "improved": "better", "explanation": "Good", "category": "vocabulary"},
            {"original": "", "improved": "better", "explanation": "Missing original"},
            {"original": "original", "improved": "", "explanation": "Missing improved"},
            {"original": "original", "improved": "improved", "explanation": "", "category": "vocabulary"},
            {"original": "no explanation field", "improved": "improved", "category": "vocabulary"},
            None,  # Non-dict item
            "not a dict",  # String item
        ]
        parsed = _parse_sentence_comparisons(raw_comparisons)
        assert len(parsed) == 1
        assert parsed[0].original == "valid item"

    def test_sentence_comparisons_invalid_category_defaults_to_vocabulary(self):
        """Invalid category values should default to vocabulary."""
        raw_comparisons = [
            {"original": "test", "improved": "TEST", "explanation": "Uppercase", "category": "invalid_category"},
        ]
        parsed = _parse_sentence_comparisons(raw_comparisons)
        assert len(parsed) == 1
        assert parsed[0].category == "vocabulary"

    def test_parse_empty_raw_comparisons(self):
        """Empty list should return empty list."""
        parsed = _parse_sentence_comparisons([])
        assert parsed == []

    def test_parse_none_raw_comparisons(self):
        """None should return empty list."""
        parsed = _parse_sentence_comparisons(None)
        assert parsed == []


class TestCompareEssayValidationIntegration:
    """Integration tests for validation in compare_essay."""

    @pytest.mark.asyncio
    async def test_compare_essay_missing_sentence_comparisons_logs_warning(self):
        """When sentence_comparisons is missing, ValueError is caught and logged."""
        req = CompareRequest(essay_text="A" * 100, topic="Education", task_type="TASK_2", student_band=6.0)
        
        llm_result_without_field = {
            "overall_analysis": "Analysis without sentence comparisons",
            "vocabulary_feedback": "Some feedback",
        }

        with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=MOCK_SEARCH_RESULTS), \
             patch("app.services.compare_service.gemini_service.generate", new_callable=AsyncMock, return_value=llm_result_without_field):
            result = await compare_essay(req)

        assert "LLM response validation failed" in result.overall_analysis
        assert result.sentence_comparisons == []

    @pytest.mark.asyncio
    async def test_compare_essay_present_sentence_comparisons_accepted(self):
        """When sentence_comparisons is present (even empty), result is accepted."""
        req = CompareRequest(essay_text="A" * 100, topic="Education", task_type="TASK_2", student_band=6.0)
        
        llm_result_with_field = {
            "overall_analysis": "Analysis with sentence comparisons",
            "vocabulary_feedback": "Some feedback",
            "sentence_comparisons": [
                {"original": "I think", "improved": "I believe", "explanation": "More formal", "category": "vocabulary"}
            ]
        }

        with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=MOCK_SEARCH_RESULTS), \
             patch("app.services.compare_service.gemini_service.generate", new_callable=AsyncMock, return_value=llm_result_with_field):
            result = await compare_essay(req)

        assert result.overall_analysis == "Analysis with sentence comparisons"
        assert len(result.sentence_comparisons) == 1


class TestCompareExemplarValidationIntegration:
    """Integration tests for validation in _compare_exemplar."""

    @pytest.mark.asyncio
    async def test_compare_exemplar_missing_sentence_comparisons_logs_warning(self):
        """When sentence_comparisons is missing in exemplar mode, ValueError is caught."""
        req = CompareRequest(essay_text="A" * 100, topic="Education", task_type="TASK_2", student_band=6.0)
        
        llm_result_without_field = {
            "overall_analysis": "Exemplar analysis without sentence comparisons",
            "vocabulary_feedback": "Some feedback",
        }

        with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=MOCK_SEARCH_RESULTS), \
             patch("app.services.compare_service.gemini_service.generate", new_callable=AsyncMock, return_value=llm_result_without_field):
            result = await _compare_exemplar(req, 8.5)

        assert "LLM response validation failed" in result.overall_analysis
        assert result.sentence_comparisons == []

    @pytest.mark.asyncio
    async def test_compare_exemplar_present_sentence_comparisons_accepted(self):
        """When sentence_comparisons is present in exemplar mode, result is accepted."""
        req = CompareRequest(essay_text="A" * 100, topic="Education", task_type="TASK_2", student_band=6.0)
        
        llm_result_with_field = {
            "overall_analysis": "Exemplar analysis with sentence comparisons",
            "vocabulary_feedback": "Some feedback",
            "sentence_comparisons": [
                {"original": "I think", "improved": "I believe", "explanation": "More formal", "category": "vocabulary"}
            ]
        }

        with patch("app.services.compare_service.search_service.search", new_callable=AsyncMock, return_value=MOCK_SEARCH_RESULTS), \
             patch("app.services.compare_service.gemini_service.generate", new_callable=AsyncMock, return_value=llm_result_with_field):
            result = await _compare_exemplar(req, 8.5)

        assert result.overall_analysis == "Exemplar analysis with sentence comparisons"
        assert len(result.sentence_comparisons) == 1