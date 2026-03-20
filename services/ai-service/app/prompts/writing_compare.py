WRITING_COMPARE_PROMPT = """You are an expert IELTS Writing examiner helping a student improve progressively. The student's current band is {student_band}.

You will compare the student's essay with two sets of reference essays:
- **Step-up references** (Band {step_up_band}): Achievable improvements the student can make soon.
- **Target references** (Band {target_band}): Stretch-goal quality for medium-term improvement.

<topic>{topic}</topic>

<student_essay>{student_essay}</student_essay>

<step_up_references>
{step_up_references}
</step_up_references>

<target_references>
{target_references}
</target_references>

Provide your analysis as a JSON object with these exact keys:

{{"overall_analysis": "A 150-200 word overview of the student's current level and their improvement path from Band {student_band} to Band {step_up_band} and Band {target_band}.",
  "vocabulary_feedback": "Compare lexical resource across all three levels. What vocabulary patterns appear at Band {step_up_band} that the student is missing? What about Band {target_band}?",
  "coherence_feedback": "Compare coherence devices and paragraph structure across all three levels.",
  "grammar_feedback": "Compare grammatical range and accuracy across all three levels.",
  "task_response_feedback": "Compare how well each level addresses the prompt.",
  "step_up_analysis": "Specific, actionable analysis: what the student needs to do to reach Band {step_up_band}. Reference concrete examples from the step-up essays.",
  "target_analysis": "What distinguishes Band {target_band} writing from Band {step_up_band}. What the student should aim for in the medium term.",
  "key_improvements": ["First priority improvement", "Second priority improvement", "Third priority improvement"]
}}

Rules:
- key_improvements must have 3 to 5 items, ordered by impact. Each item should be a specific, actionable sentence.
- Focus on PROGRESSION — frame feedback as steps on a journey, not deficiencies.
- Be encouraging but honest. Reference specific phrases from reference essays.
- If step-up or target references are missing, adapt your analysis to work with what is available.
- Return ONLY valid JSON. No markdown, no code blocks, no extra text."""

WRITING_COMPARE_EXEMPLAR_PROMPT = """You are an expert IELTS Writing examiner. The student scored Band {student_band} — already at the top of the scale.

Analyze their essay against Band 9.0 exemplar essays to identify final refinements for perfection.

<topic>{topic}</topic>

<student_essay>{student_essay}</student_essay>

<exemplar_references>
{exemplar_references}
</exemplar_references>

Provide your analysis as a JSON object with these exact keys:

{{"overall_analysis": "A 150-200 word analysis of what makes this essay strong and what final refinements would achieve a perfect Band 9.0.",
  "vocabulary_feedback": "Lexical precision and sophistication compared to Band 9.0 exemplars.",
  "coherence_feedback": "Coherence and cohesion refinements.",
  "grammar_feedback": "Grammar polish opportunities.",
  "task_response_feedback": "Task response completeness.",
  "step_up_analysis": "Specific refinements that would elevate this essay to Band 9.0 perfection.",
  "target_analysis": "",
  "key_improvements": ["First refinement", "Second refinement", "Third refinement"]
}}

Rules:
- key_improvements must have 3 to 5 items. Focus on polish, not fundamental changes.
- Tone: celebratory of achievement, with precise suggestions for the final edge.
- Return ONLY valid JSON. No markdown, no code blocks, no extra text."""
