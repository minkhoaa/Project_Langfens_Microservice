from app.services.grade_service import _estimate_band_from_word_count


def test_estimate_band_very_short():
    assert _estimate_band_from_word_count(100) == 4.5


def test_estimate_band_below_minimum():
    assert _estimate_band_from_word_count(200) == 5.5


def test_estimate_band_standard():
    assert _estimate_band_from_word_count(280) == 6.0


def test_estimate_band_long():
    assert _estimate_band_from_word_count(400) == 7.0


def test_estimate_band_boundary_250():
    assert _estimate_band_from_word_count(250) == 6.0


def test_estimate_band_boundary_350():
    assert _estimate_band_from_word_count(350) == 7.0
