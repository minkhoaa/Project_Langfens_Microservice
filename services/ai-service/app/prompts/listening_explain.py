"""Listening item explainer prompt.

The transcript is supplied in-context. The prompt also accepts an
optional `corpus_hints` block (1-2 retrieved listening_samples) that
the service injects when the corpus collection has data.
"""
from typing import Optional

def build_listening_prompt(
    question_type: str,
    transcript: str,
    question: str,
    options: list[str],
    user_answer: str,
    correct_answer: str,
    section: int,
    corpus_hints: Optional[str] = None,
) -> str:
    options_block = "\n".join(options) if options else "(no options)"
    corpus_block = (
        f"\nCORPUS HINTS (from related listening items):\n{corpus_hints}\n"
        if corpus_hints
        else ""
    )
    return f"""You are an IELTS Listening examiner explaining a single item.

ITEM TYPE: {question_type}
SECTION: {section}
TRANSCRIPT:
{transcript}
{corpus_block}
QUESTION:
{question}

OPTIONS:
{options_block}

STUDENT'S ANSWER: {user_answer}
CORRECT ANSWER: {correct_answer}

Your job:
- Quote the EXACT transcript span that supports the correct answer.
- For MCQ, briefly explain why distractors fail.
- For matching/multi-choice, state the correct match.
- Tag the listening skill being tested (e.g. detail, opinion, purpose, speaker attitude).

Produce JSON with this shape:
{{
  "criterion_band": 6.5,
  "explanation": "2-4 sentence explanation.",
  "transcript_quote": "Verbatim span from TRANSCRIPT.",
  "skill_tags": ["detail", "numbers"],
  "suggestions": ["actionable tip", "..."]
}}

Rules:
- `criterion_band` float 0.0-9.0 in 0.5 increments.
- `transcript_quote` MUST be a verbatim substring of TRANSCRIPT.
- `skill_tags` MUST be 1-3 short strings.
- `suggestions` MUST be 1-3 actionable items.
- Return ONLY valid JSON.
"""
