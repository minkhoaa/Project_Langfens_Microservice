from app.prompts.reading_explain import build_reading_prompt, QUESTION_TYPE_BRANCHES

def test_all_five_question_types_have_a_branch():
    assert set(QUESTION_TYPE_BRANCHES.keys()) == {
        "MCQ",
        "MATCHING",
        "TRUE_FALSE_NOT_GIVEN",
        "SUMMARY_COMPLETE",
        "SHORT_ANSWER",
    }

def test_mcq_prompt_quotes_passage_and_lists_options():
    prompt = build_reading_prompt(
        question_type="MCQ",
        passage="The library opens at nine. Members may borrow up to five books.",
        question="When does the library open?",
        options=["A) 7am", "B) 9am", "C) noon"],
        user_answer="A) 7am",
        correct_answer="B) 9am",
    )
    assert "library opens at nine" in prompt
    assert "A) 7am" in prompt
    assert "B) 9am" in prompt
    assert "why each distractor fails" in prompt.lower()

def test_t_f_ng_prompt_requires_passage_quote():
    prompt = build_reading_prompt(
        question_type="TRUE_FALSE_NOT_GIVEN",
        passage="The scheme was launched in 2010.",
        question="The scheme ran for 20 years.",
        options=["TRUE", "FALSE", "NOT GIVEN"],
        user_answer="TRUE",
        correct_answer="NOT GIVEN",
    )
    assert "NOT GIVEN" in prompt
    assert "passage sentence" in prompt.lower()
