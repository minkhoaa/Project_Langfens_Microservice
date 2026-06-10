"""Pre-LLM band estimator.

Used by `grade_service._estimate_band` to obtain a deterministic, LLM-derived
band for the student's essay BEFORE the full grading prompt runs. The estimate
is then used to:
  1. Scope the RAG band_overall filter (so the LLM sees references near the
     student's level, not the corpus top).
  2. Clamp the full-grader LLM's `ob` to within +1.0 of this estimate, so a
     Band 3 essay cannot be inflated to Band 6 via RAG anchoring.

This prompt is intentionally minimal: no reference essays, no rubric prose,
no per-criterion breakdown. Just "look at the essay, return one number in
[0, 9] on the 0.5 grid." The cleaner the input, the less the estimator is
itself anchored to high-band context — which is the exact failure mode we
are guarding against in the full grader.
"""

BAND_ESTIMATE_PROMPT = """You are an IELTS Writing examiner.

Score the essay below on the official IELTS Writing band scale (0.0 to 9.0, in
0.5 increments). Base your score ONLY on the essay text. Do not assume the
student's level from any other context.

Return ONLY a JSON object of this exact shape (no markdown, no commentary):
{{"band": <float in [0,9] in 0.5 increments>, "reason": "<one short sentence naming the dominant weakness or strength>"}}

Task: {task}
Essay: {essay}
"""


def build_band_estimate_prompt(task: str, essay: str) -> str:
    return BAND_ESTIMATE_PROMPT.format(task=task, essay=essay)
