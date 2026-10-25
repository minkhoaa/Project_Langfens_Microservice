from app.evaluators.semantic import detect_entailment_in_text


def test_over_half_is_entailed_by_matching_percentage_above_fifty():
    statement = "The Antarctic ice sheet contains over half of Earth's fresh water."
    passage = "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth."

    assert detect_entailment_in_text(statement, passage) is True


def test_over_half_is_not_entailed_by_percentage_below_fifty():
    statement = "The Antarctic ice sheet contains over half of Earth's fresh water."
    passage = "The Antarctic ice sheet contains roughly 41 percent of all fresh water on Earth."

    assert detect_entailment_in_text(statement, passage) is False


def test_percentage_threshold_requires_matching_topic():
    statement = "The Antarctic ice sheet contains over half of Earth's fresh water."
    passage = "A coastal research station documented 61 percent of annual rainfall in one month."

    assert detect_entailment_in_text(statement, passage) is False
