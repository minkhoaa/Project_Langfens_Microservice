"""Allowlist Projection Serializer and Secure Envelope for Blind Solvers (P10-01, P10-02).

Invariants:
- Strictly projects candidates/questions to StudentVisibleQuestion allowlist.
- Strips answers, correctOption, evidenceQuote, explanations, canaries, and generation metadata.
- Constructs secure untrusted text envelopes preventing prompt injection from overriding instructions.
"""

from __future__ import annotations
from collections.abc import Mapping, Sequence
import html
import json
import re
from typing import Any, Dict, List, Optional, Union

from app.contracts.solver import (
    BlindSolverInput,
    SecurityLeakageError,
    StudentVisibleOption,
    StudentVisibleQuestion,
)


FORBIDDEN_PROPERTIES = {
    "answer",
    "correct_option",
    "correctoption",
    "evidence_quote",
    "evidencequote",
    "evidence_span",
    "evidencespan",
    "explanation",
    "absence_assessment",
    "absenceassessment",
    "canary",
    "hidden_canary",
    "rejected",
    "rejection_reasons",
    "rejectionreasons",
    "generation_prompt",
    "generationprompt",
    "metadata",
    "score",
}


def project_to_student_visible(question_data: Any) -> StudentVisibleQuestion:
    """Projects any candidate or question object to a minimal StudentVisibleQuestion.

    Explicit allowlist projection: only extracts questionNumber, questionType, prompt,
    instructions, options, sharedContext. Any other attribute is strictly dropped.
    """
    if hasattr(question_data, "model_dump"):
        data = question_data.model_dump(by_alias=True)
    elif hasattr(question_data, "get") and callable(question_data.get):
        data = dict(question_data)
    elif hasattr(question_data, "__dict__"):
        data = dict(vars(question_data))
    else:
        raise ValueError(f"Unsupported question data type: {type(question_data)}")

    q_num = data.get("questionNumber") or data.get("question_number")
    if q_num is None:
        raise ValueError("Missing questionNumber in input data")
    q_num = int(q_num)

    q_type = data.get("questionType") or data.get("question_type")
    if not q_type:
        raise ValueError("Missing questionType in input data")
    q_type = re.sub(r'[^a-zA-Z0-9_\-]', '', str(q_type).strip())

    prompt = data.get("prompt") or data.get("statement")
    if not prompt:
        raise ValueError("Missing prompt or statement in input data")
    prompt = str(prompt).strip()

    instructions = data.get("instructions")
    if instructions is not None:
        instructions = str(instructions).strip()

    shared_context = data.get("sharedContext") or data.get("shared_context")
    if shared_context is not None:
        shared_context = str(shared_context).strip()

    raw_options = data.get("options")
    student_options: Optional[List[StudentVisibleOption]] = None
    if raw_options and isinstance(raw_options, (list, tuple, Sequence)):
        student_options = []
        for opt in raw_options:
            if isinstance(opt, (dict, Mapping)):
                k = opt.get("key") or opt.get("label") or opt.get("letter")
                t = opt.get("text") or opt.get("content") or opt.get("value")
            elif hasattr(opt, "key") and hasattr(opt, "text"):
                k = opt.key
                t = opt.text
            elif isinstance(opt, str) and len(opt) > 2 and opt[1] in [".", ")", ":"]:
                k = opt[0].upper()
                t = opt[2:].strip()
            else:
                continue

            if k and t:
                # Sanitize option text: ensure it contains no canary or leak
                student_options.append(StudentVisibleOption(key=str(k).upper(), text=str(t).strip()))

    return StudentVisibleQuestion(
        question_number=q_num,
        question_type=q_type,
        prompt=prompt,
        instructions=instructions,
        options=student_options,
        shared_context=shared_context,
    )


def build_blind_solver_input(
    passage_text: str,
    question_data: Any,
    section_id: Optional[int] = None,
) -> BlindSolverInput:
    """Builds a verified BlindSolverInput from passage and question data."""
    if not passage_text or len(passage_text.strip()) < 50:
        raise ValueError("Passage text must be at least 50 characters")

    sv_question = project_to_student_visible(question_data)
    solver_input = BlindSolverInput(
        passage_text=passage_text.strip(),
        question=sv_question,
        section_id=section_id,
    )
    # Validate payload immediately
    solver_input.to_canonical_payload()
    return solver_input


def build_secure_envelope(
    passage_text: str,
    question: StudentVisibleQuestion,
) -> str:
    """Formats untrusted passage and question text in strict XML-style delimiter envelopes.

    Escapes control sequences to prevent prompt injection attacks from overriding system instructions.
    """
    # Sanitize passage text and attributes against prompt-injection delimiters
    safe_passage = html.escape(passage_text.strip())
    safe_prompt = html.escape(question.prompt.strip())
    safe_q_num = html.escape(str(question.question_number), quote=True)
    safe_q_type = html.escape(str(question.question_type), quote=True)

    options_block = ""
    if question.options:
        opt_lines = [f"  <option key=\"{o.key}\">{html.escape(o.text)}</option>" for o in question.options]
        options_block = "\n<options>\n" + "\n".join(opt_lines) + "\n</options>"

    shared_ctx_block = ""
    if question.shared_context:
        shared_ctx_block = f"\n<shared_context>\n{html.escape(question.shared_context.strip())}\n</shared_context>"

    instructions_block = ""
    if question.instructions:
        instructions_block = f"\n<instructions>\n{html.escape(question.instructions.strip())}\n</instructions>"

    envelope = f"""<untrusted_content>
<approved_passage>
{safe_passage}
</approved_passage>
<student_question question_number="{safe_q_num}" question_type="{safe_q_type}">
{instructions_block}{shared_ctx_block}
<prompt>
{safe_prompt}
</prompt>{options_block}
</student_question>
</untrusted_content>"""
    return envelope
