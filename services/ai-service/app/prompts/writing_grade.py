WRITING_GRADE_PROMPT = """IELTS Writing Task 2 Examiner.

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
"p": "..."
}}

Field requirements:
- b: Band score (float).
- c: Detailed analysis string. MUST quote specific errors from the essay to justify the score.
- s: Array of 3 specific actionable improvements (e.g., 'Replace [bad phrase] with [better phrase]').
- p: A rewritten version of one body paragraph (approx 50-80 words) demonstrating band 8.0+ style.

Naturalness MANDATORY:
- Prefer natural, idiomatic English over artificially complex vocabulary.
- "has grown considerably" is better than "witnessed a substantial surge".
- The gold standard: natural, fluent, precise, and appropriate for academic writing."""

def build_rag_context(rag_hints: dict) -> str:
    """Build the <reference_context> block from RAG hints dict."""
    if rag_hints.get("reference_count", 0) == 0:
        return "No reference essays available for comparison."
    return f"""The RAG system found {rag_hints['reference_count']} reference essays similar to this topic.
Band levels: {rag_hints['band_distribution']}
{rag_hints.get('word_count_hints', '')}
Common vocabulary patterns at higher bands: {rag_hints.get('vocab_hints', 'N/A')}
Common structural patterns: {rag_hints.get('structure_hints', 'N/A')}"""

def build_grade_prompt(task: str, essay: str, word_count: int, rag_hints: dict | None = None) -> str:
    """Build the full user prompt for writing grading."""
    rag_context = build_rag_context(rag_hints or {})
    return f"""WC:{word_count}
T:{task}
E:{essay}

<reference_context>
{rag_context}
</reference_context>

{WRITING_GRADE_PROMPT}"""
