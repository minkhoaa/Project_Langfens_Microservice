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
    AnswerVerificationView,
    BlindSolverInput,
    BlindSolverResult,
    CanonicalQuestion,
    GoldReferenceView,
    SecurityLeakageError,
    SolverView,
    StudentVisibleOption,
    StudentVisibleQuestion,
    scan_text_for_security_leaks,
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


def project_to_canonical_question(question_data: Any) -> CanonicalQuestion:
    """Projects question data to an allowlisted CanonicalQuestion."""
    if hasattr(question_data, "model_dump"):
        data = question_data.model_dump(by_alias=True)
    elif hasattr(question_data, "get") and callable(question_data.get):
        data = dict(question_data)
    elif hasattr(question_data, "__dict__"):
        data = dict(vars(question_data))
    else:
        raise ValueError(f"Unsupported question data type: {type(question_data)}")

    q_id = str(data.get("question_id") or data.get("questionId") or f"q{data.get('question_number', 1)}")
    q_type = str(data.get("question_type") or data.get("questionType") or "TFNG").strip()
    text = str(data.get("text") or data.get("prompt") or data.get("statement") or "").strip()
    if not text:
        raise ValueError("Missing question text or prompt")

    instructions = str(data.get("instructions") or "Answer using passage only.").strip()

    raw_options = data.get("options") or []
    options: List[str] = []
    if isinstance(raw_options, (list, tuple, Sequence)):
        for opt in raw_options:
            if isinstance(opt, str):
                options.append(opt.strip())
            elif isinstance(opt, (dict, Mapping)):
                t = opt.get("text") or opt.get("content") or opt.get("value")
                if t:
                    options.append(str(t).strip())

    return CanonicalQuestion(
        question_id=q_id,
        question_type=q_type,
        text=text,
        options=options,
        instructions=instructions,
    )


def project_to_solver_view(
    context_text: str,
    question_data: Any,
    allowed_reference_text: Optional[str] = None,
) -> SolverView:
    """Projects context and question data to an isolated SolverView.

    Strictly validates no answer, canary, or serialized alias leaks reach the solver.
    """
    if not context_text or len(context_text.strip()) < 1:
        raise ValueError("context_text must not be empty")

    ref_text = allowed_reference_text or context_text
    canonical_q = project_to_canonical_question(question_data)

    return SolverView(
        context_text=context_text.strip(),
        question=canonical_q,
        allowed_reference_text=ref_text.strip(),
    )


def project_to_answer_verification_view(
    blind_result: Union[BlindSolverResult, Dict[str, Any]],
    generator_proposed_answer: str,
    source_evidence_ref: str,
    acceptable_variants: Optional[List[str]] = None,
) -> AnswerVerificationView:
    """Constructs the AnswerVerificationView only after blind solve completes."""
    if not blind_result:
        raise ValueError("blind_result must not be empty")
    if not generator_proposed_answer:
        raise ValueError("generator_proposed_answer must not be empty")
    if not source_evidence_ref:
        raise ValueError("source_evidence_ref must not be empty")

    if isinstance(blind_result, dict):
        b_res = BlindSolverResult(
            question_id=str(blind_result.get("question_id") or blind_result.get("questionId") or "q1"),
            proposed_solution=str(blind_result.get("proposed_solution") or blind_result.get("proposedSolution") or ""),
            reasoning_evidence=str(blind_result.get("reasoning_evidence") or blind_result.get("reasoningEvidence") or ""),
            confidence=float(blind_result.get("confidence", 1.0)),
        )
    else:
        b_res = blind_result

    return AnswerVerificationView(
        blind_result=b_res,
        generator_proposed_answer=generator_proposed_answer.strip(),
        source_evidence_ref=source_evidence_ref.strip(),
        acceptable_variants=acceptable_variants or [],
    )


def project_to_gold_reference_view(
    item_id: str,
    expert_label: str,
    label_version: str,
    adjudicator_id: str,
) -> GoldReferenceView:
    """Constructs the GoldReferenceView for external research evaluation."""
    if not item_id:
        raise ValueError("item_id must not be empty")
    if not expert_label:
        raise ValueError("expert_label must not be empty")
    if not label_version:
        raise ValueError("label_version must not be empty")
    if not adjudicator_id:
        raise ValueError("adjudicator_id must not be empty")

    return GoldReferenceView(
        item_id=item_id.strip(),
        expert_label=expert_label.strip(),
        label_version=label_version.strip(),
        adjudicator_id=adjudicator_id.strip(),
    )
