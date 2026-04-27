from tests.e2e.fixtures.essays import ALL_ESSAYS, WC_A_BAND9, WC_B_BAND6, WC_C_BAND4


def test_all_essays_distinct():
    ids = {e.id for e in ALL_ESSAYS}
    assert ids == {"WC-A", "WC-B", "WC-C"}


def test_essays_have_required_fields():
    for e in ALL_ESSAYS:
        assert 50 <= len(e.text) <= 3000, f"{e.id} length {len(e.text)} out of bounds"
        assert 5 <= len(e.topic) <= 500
        assert 1.0 <= e.student_band <= 9.0
        assert e.task_type in ("TASK_1", "TASK_2")


def test_band_targets_ordered():
    assert WC_A_BAND9.target_band > WC_B_BAND6.target_band > WC_C_BAND4.target_band
