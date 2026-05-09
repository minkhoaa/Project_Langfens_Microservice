# Mirror SpeakingTemplate.cs format but in Python
SPEAKING_GRADE_PROMPT = """IELTS Speaking Examiner.

Input format:
Q:<question>
E:<candidate answer transcript>

Score the answer strictly using official IELTS Speaking criteria (0–9, step 0.5):
- fc = Fluency & Coherence (Focus on expansion, discourse markers, and logical flow)
- lr = Lexical Resource (Focus on idiomatic language, collocations, and precision)
- gr = Grammatical Range & Accuracy (Focus on tense control and sentence complexity)
- pr = Pronunciation (Estimate based on natural phrasing, stress patterns implied by text, and sentence rhythm)

Rules:
- ob (overall band) = average(fc.b, lr.b, gr.b, pr.b), rounded to the nearest 0.5.
- Be critical regarding "Spoken English" style (avoid overly formal/written language).

Output ONLY one JSON object in EXACTLY this structure — no markdown, no code fences:
{{
"ob": 6.5,
"fc": {{"b": 6.0, "c": "..."}},
"lr": {{"b": 7.0, "c": "..."}},
"gr": {{"b": 6.0, "c": "..."}},
"pr": {{"b": 6.0, "c": "..."}},
"s": ["...", "...", "..."],
"p": "..."
}}

Field requirements:
- b: Band score (float, 0.0-9.0).
- c: Detailed analysis string. MUST quote specific phrases from the transcript to explain the score. Point out unnatural phrasing or grammar mistakes explicitly.
- s: Array of 3 specific actionable tips to sound more native (e.g., 'Use discourse markers like "Well/Actually"', 'Replace [basic word] with [idiom]').
- p: An improved version of the answer using natural, idiomatic Spoken English (not formal written style).

Do NOT use markdown or code fences.
Do NOT output any text before or after the JSON."""


def build_speaking_prompt(question: str, transcript: str) -> str:
    """Build the full user prompt for speaking grading."""
    return f"""Q:{question}
E:{transcript}

{SPEAKING_GRADE_PROMPT}"""
