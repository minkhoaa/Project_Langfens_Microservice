WRITING_GRADE_PROMPT_TASK2 = """IELTS Writing Task 2 Examiner.

Input:
WC:<int>
T:<task>
E:<essay>

<reference_context>
{rag_context}
</reference_context>

Score the essay strictly using official IELTS criteria (0–9, step 0.5):
- ta = Task Response
- cc = Coherence & Cohesion
- lr = Lexical Resource
- gr = Grammatical Range & Accuracy

Rules:
- ob = average(ta.b, cc.b, lr.b, gr.b), rounded to nearest 0.5.
- Standard IELTS Task 2 requires min 250 words.
- Apply penalty ONLY if WC < 250.
- Be critical but constructive.
- Quote specific phrases from the essay in your comments.

Output ONLY one JSON object with EXACTLY this structure — no markdown, no code fences:
{{
"ob": 6.5,
"ta": {{"b": 6.0, "c": "..."}},
"cc": {{"b": 6.0, "c": "..."}},
"lr": {{"b": 7.0, "c": "..."}},
"gr": {{"b": 6.0, "c": "..."}},
"s": ["...", "...", "..."],
"p": "...",
"errors": [
  {{"quote": "<exact erroneous phrase verbatim from the essay>",
    "fix": "<the corrected phrase>",
    "reason": "<one short sentence explaining why it is wrong, e.g. 'Subject-verb agreement: collective noun "number" takes singular verb.'>"}}
]
}}

Field requirements:
- b: Band score (float).
- c: Detailed analysis string. MUST quote specific errors from the essay to justify the score.
- s: Array of 3 specific actionable improvements (e.g., 'Replace [bad phrase] with [better phrase]').
- p: A rewritten version of one body paragraph (approx 50-80 words) demonstrating band 8.0+ style.
- errors: 2-4 specific grammatical issues you noticed in THIS essay. Each `quote` MUST be a contiguous substring of the essay (never a generic example — copy the exact words from the student's text). Categories: tense, subject-verb, article, preposition, pronoun, word-order, collocation, other. A typical IELTS essay at band 5-7 has 2-4 such issues — do not return [] unless the writing is genuinely flawless.

Naturalness MANDATORY:
- Prefer natural, idiomatic English over artificially complex vocabulary.
- "has grown considerably" is better than "witnessed a substantial surge".
- The gold standard: natural, fluent, precise, and appropriate for academic writing."""

WRITING_GRADE_PROMPT_TASK1 = """IELTS Writing Task 1 Examiner.

Input:
WC:<int>
T:<task>
CD:<chart_description>
E:<essay>

<reference_context>
{rag_context}
</reference_context>

Score the essay strictly using official IELTS Task 1 criteria (0–9, step 0.5):
- ta = Task Achievement (overview accuracy, key feature selection, data reporting accuracy)
- cc = Coherence & Cohesion (logical organisation, cohesive devices, paragraphing)
- lr = Lexical Resource (vocabulary range, precision for describing trends/data)
- gr = Grammatical Range & Accuracy (sentence variety, error frequency)

Rules:
- ob = average(ta.b, cc.b, lr.b, gr.b), rounded to nearest 0.5.
- Standard IELTS Task 1 requires min 150 words.
- Apply penalty ONLY if WC < 150.
- For ta: Check if the student's reported data/trends match the chart description. Penalise factual inaccuracies.
- For ta: A clear overview paragraph identifying main trends/features is essential for bands 6+.
- Be critical but constructive.
- Quote specific phrases from the essay in your comments.

Output ONLY one JSON object with EXACTLY this structure — no markdown, no code fences:
{{
"ob": 6.5,
"ta": {{"b": 6.0, "c": "..."}},
"cc": {{"b": 6.0, "c": "..."}},
"lr": {{"b": 7.0, "c": "..."}},
"gr": {{"b": 6.0, "c": "..."}},
"s": ["...", "...", "..."],
"p": "...",
"errors": [
  {{"quote": "<exact erroneous phrase verbatim from the essay>",
    "fix": "<the corrected phrase>",
    "reason": "<one short sentence explaining why it is wrong>"}}
]
}}

Field requirements:
- b: Band score (float).
- c: Detailed analysis string. MUST quote specific phrases from the essay to justify the score. For ta, compare student's data claims against the chart description.
- s: Array of 3 specific actionable improvements.
- p: A rewritten version of one body paragraph (approx 50-80 words) demonstrating band 8.0+ Task 1 style (accurate data reporting, trend language, comparisons).
- errors: 2-4 specific grammatical issues you noticed in THIS essay. Each `quote` MUST be a contiguous substring of the essay (never a generic example — copy the exact words from the student's text). Categories: tense, subject-verb, article, preposition, pronoun, word-order, collocation, other. A typical IELTS essay at band 5-7 has 2-4 such issues — do not return [] unless the writing is genuinely flawless.

Naturalness MANDATORY:
- Prefer natural, idiomatic English over artificially complex vocabulary.
- Task 1 trend language should be natural: "rose steadily", "peaked at", "remained stable" rather than "experienced a considerable escalation".
- The gold standard: natural, fluent, precise data description."""

def build_rag_context(rag_hints: dict) -> str:
    """Build the <reference_context> block from RAG hints dict."""
    if rag_hints.get("reference_count", 0) == 0:
        return "No reference essays available for comparison."
    return f"""The RAG system found {rag_hints['reference_count']} reference essays similar to this topic.
Band levels: {rag_hints['band_distribution']}
{rag_hints.get('word_count_hints', '')}
Common vocabulary patterns at higher bands: {rag_hints.get('vocab_hints', 'N/A')}
Common structural patterns: {rag_hints.get('structure_hints', 'N/A')}

Actual excerpts retrieved from these band-level reference essays (anchor your band scores
and quoted comparisons to these REAL examples, not assumptions):
{rag_hints.get('reference_excerpts', 'No reference essays were retrieved for grounding.')}"""

def build_grade_prompt(
    task: str,
    essay: str,
    word_count: int,
    rag_hints: dict | None = None,
    task_type: str = "TASK_2",
    chart_description: str | None = None,
) -> str:
    """Build the full user prompt for writing grading."""
    rag_context = build_rag_context(rag_hints or {})
    prompt_template = WRITING_GRADE_PROMPT_TASK1 if task_type == "TASK_1" else WRITING_GRADE_PROMPT_TASK2

    if task_type == "TASK_1":
        cd = chart_description or "No chart description available."
        return f"""WC:{word_count}
T:{task}
CD:{cd}
E:{essay}

<reference_context>
{rag_context}
</reference_context>

{prompt_template}"""
    else:
        return f"""WC:{word_count}
T:{task}
E:{essay}

<reference_context>
{rag_context}
</reference_context>

{prompt_template}"""
