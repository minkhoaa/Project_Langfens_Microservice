GRAMMAR_DETECT_PROMPT = """You are an expert IELTS grammar examiner.

Read the student's essay below. Identify up to {max_errors} GRAMMATICAL errors. Focus on:
- Verb tense (e.g., "He go to school yesterday" -> "He went to school yesterday")
- Subject-verb agreement (e.g., "She have many books" -> "She has many books")
- Articles (a, an, the)
- Prepositions
- Word order
- Pronoun reference and agreement
- Common collocations

Do NOT flag style, vocabulary choice, or punctuation issues - grammar only.
Do NOT flag the same mistake twice (skip duplicates with identical error_text and context).

<essay>
{essay}
</essay>

Return ONLY valid JSON in this exact shape (no markdown, no code fences, no commentary):

{{"errors": [
  {{"error_text": "<exact erroneous phrase verbatim from the essay>",
    "context": "<the full sentence containing the error>",
    "correct_form": "<the corrected phrase>"}}
]}}

If the essay has no grammatical errors, return: {{"errors": []}}
"""
