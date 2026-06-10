"""Reading item explainer prompt.

One prompt builder that branches on question_type. The LLM must
quote the exact passage span that supports the correct answer;
that span becomes an Evidence with source 'passage:inline'.
"""
from typing import Literal

QuestionType = Literal["MCQ", "MATCHING", "TRUE_FALSE_NOT_GIVEN", "SUMMARY_COMPLETE", "SHORT_ANSWER"]

QUESTION_TYPE_BRANCHES: dict[str, str] = {
    "MCQ": (
        "- Explain why each distractor fails. "
        "Quote the passage span that supports the correct answer."
    ),
    "MATCHING": (
        "- State which paragraph/section label is the correct match. "
        "- Quote the passage sentence that anchors the match."
    ),
    "TRUE_FALSE_NOT_GIVEN": (
        "- State which exact passage sentence resolves TRUE/FALSE/NOT GIVEN. "
        "- If the answer is TRUE or FALSE, quote that sentence. "
        "- If the answer is NOT GIVEN, state what the passage does NOT say."
    ),
    "SUMMARY_COMPLETE": (
        "- For SUMMARY_COMPLETE, identify the gap and the exact span of text "
        "in the passage (or earlier in the summary) that fills it."
    ),
    "SHORT_ANSWER": (
        "- For SHORT_ANSWER, quote the passage span that contains the answer "
        "and explain why the user's written form is correct or off."
    ),
}

def build_reading_prompt(
    question_type: str,
    passage: str,
    question: str,
    options: list[str],
    user_answer: str,
    correct_answer: str,
) -> str:
    branch = QUESTION_TYPE_BRANCHES.get(question_type, QUESTION_TYPE_BRANCHES["MCQ"])
    options_block = "\n".join(options) if options else "(no options)"
    return f"""You are an IELTS Reading examiner explaining a single item to a learner.

ITEM TYPE: {question_type}
PASSAGE:
{passage}

QUESTION:
{question}

OPTIONS:
{options_block}

STUDENT'S ANSWER: {user_answer}
CORRECT ANSWER: {correct_answer}

Your job:
- Use {branch}
- Produce a JSON object with these fields:
  {{
    "criterion_band": 6.5,
    "explanation": "2-4 sentence explanation of why the correct answer is correct.",
    "passage_quote": "The exact passage sentence(s) that support the answer.",
    "distractor_analysis": "For MCQ: 1 sentence per distractor explaining why it fails. For other types, empty string.",
    "suggestions": ["One actionable tip", "Another tip"]
  }}

Rules:
- `criterion_band` is a float 0.0-9.0 in 0.5 increments reflecting comprehension quality for this item.
- `passage_quote` MUST be a verbatim substring of PASSAGE.
- `suggestions` MUST be 1-3 items.
- Return ONLY valid JSON.
"""
