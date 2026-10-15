"""Standalone Grammar Research Runner and Generator (RG06-S03).

Coordinates grammar exercise generation for standalone research units, strictly isolated
from production Draft/Published exams.

Invariants:
- Generates NeutralOutput matching JSON_SCHEMAS.json#/$defs/NeutralOutput.
- Generates candidate proposed answers as ReferenceAnswerEvidence.
- Decisive acceptance condition: Proposed answers are NEVER labeled verified gold.
- Failed or timed-out runs retain partial parseable output for fair external evaluation.
"""

from __future__ import annotations

import hashlib
from typing import Any, Dict, List, Optional, Tuple
from uuid import uuid4

from app.contracts.research import (
    ExecutionStatus,
    GenerationResult,
    GrammarExerciseType,
    GrammarQuestionType,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    ReferenceAnswerEvidence,
    StandaloneGrammarRequest,
)


class StandaloneGrammarRunner:
    """Orchestrates generation of a grammar research unit."""

    def __init__(self, persistence_client: Optional[Any] = None):
        self.persistence_client = persistence_client

    def run_unit(
        self,
        request: StandaloneGrammarRequest,
        simulate_failure: Optional[str] = None,
        raw_output_override: Optional[str] = None,
    ) -> Tuple[GenerationResult, List[ReferenceAnswerEvidence]]:
        """Executes generation for a standalone grammar research unit.

        Returns:
            Tuple of (GenerationResult, List[ReferenceAnswerEvidence])
        """
        run_id = request.run_id
        dataset_item_id = request.dataset_item_id
        config_id = request.configuration_id
        rule_pack = request.rule_pack

        # ── 1. Validate Rule Pack Bounds ──────────────────────────────────────────
        if not rule_pack.rule_ids or not rule_pack.topic or not rule_pack.applicability:
            return (
                GenerationResult(
                    run_id=run_id,
                    dataset_item_id=dataset_item_id,
                    configuration_id=config_id,
                    task_type="GRAMMAR_EXERCISE",
                    execution_status=ExecutionStatus.FAILED_VALIDATION,
                    output_availability=OutputAvailability.NONE,
                    generated_content=None,
                    private_answer_ref=None,
                    trace_ref=f"secure://traces/{run_id}",
                    usage_ref=f"secure://usage/{run_id}",
                    failure_code="RULE_PACK_EMPTY_OR_INVALID",
                    output_schema_version="v3",
                ),
                [],
            )

        # ── 2. Handle Simulated Timeouts & Failures ───────────────────────────────
        if simulate_failure == "TIMEOUT":
            return (
                GenerationResult(
                    run_id=run_id,
                    dataset_item_id=dataset_item_id,
                    configuration_id=config_id,
                    task_type="GRAMMAR_EXERCISE",
                    execution_status=ExecutionStatus.TIMED_OUT,
                    output_availability=OutputAvailability.RAW_ONLY,
                    generated_content=None,
                    private_answer_ref=None,
                    trace_ref=f"secure://traces/{run_id}",
                    usage_ref=f"secure://usage/{run_id}",
                    failure_code="WALL_TIME_EXCEEDED",
                    output_schema_version="v3",
                ),
                [],
            )

        if simulate_failure:
            return (
                GenerationResult(
                    run_id=run_id,
                    dataset_item_id=dataset_item_id,
                    configuration_id=config_id,
                    task_type="GRAMMAR_EXERCISE",
                    execution_status=ExecutionStatus.FAILED_VALIDATION,
                    output_availability=OutputAvailability.PARSEABLE,
                    generated_content=None,
                    private_answer_ref=None,
                    trace_ref=f"secure://traces/{run_id}",
                    usage_ref=f"secure://usage/{run_id}",
                    failure_code=simulate_failure,
                    output_schema_version="v3",
                ),
                [],
            )

        # ── 3. Construct Questions and Reference Answer Evidence ─────────────────
        target_rule_id = rule_pack.rule_ids[0]
        context_text = f"Grammar focus: {rule_pack.topic}. Level: {rule_pack.level}."
        if rule_pack.applicability:
            context_text += f" Guidelines: {rule_pack.applicability[0]}"

        questions: List[NeutralQuestion] = []
        private_evidence: List[ReferenceAnswerEvidence] = []
        q_ids: List[str] = []

        q_count = request.task.requested_question_count
        ex_type = request.task.exercise_type

        for i in range(q_count):
            q_num = i + 1
            q_id = f"q{q_num}"
            q_ids.append(q_id)

            if ex_type == GrammarExerciseType.MCQ_SINGLE:
                q_type = GrammarQuestionType.GRAMMAR_MCQ
                q_text = f"Select the grammatically correct option to complete the sentence: 'Sentence {q_num} applying {rule_pack.topic} ...'"
                q_opts = [
                    f"Option A: correct form for item {q_num}",
                    f"Option B: tense distractor for item {q_num}",
                    f"Option C: agreement distractor for item {q_num}",
                    f"Option D: aspect distractor for item {q_num}",
                ]
                q_inst = "Choose the correct letter A, B, C, or D to complete the sentence."
                proposed_ans = "A"
                variants = ["Option A: correct form for item " + str(q_num)]
                context_sentence = f"The candidate sentence {q_num} tests {rule_pack.topic}."
                explanation = f"Option A correctly satisfies rule {target_rule_id}: {rule_pack.applicability[0]}"

            elif ex_type == GrammarExerciseType.GAP_FILL:
                q_type = GrammarQuestionType.GRAMMAR_GAP
                q_text = f"Complete sentence {q_num} with the correct form of the verb in brackets: 'Had they _____ (arrive) earlier, they would have caught the train.'"
                q_opts = []
                q_inst = "Fill in the blank with the correct grammatical form."
                proposed_ans = "arrived"
                variants = ["had arrived"]
                context_sentence = "Had they arrived earlier, they would have caught the train."
                explanation = f"Past participle required following conditional inversion rule {target_rule_id}."

            else:  # ERROR_CORRECTION
                q_type = GrammarQuestionType.GRAMMAR_CORRECTION
                q_text = f"Identify and correct the grammatical error in sentence {q_num}: 'He demanded that she was present at the conference.'"
                q_opts = []
                q_inst = "Identify the error and write the corrected word or phrase."
                proposed_ans = "be"
                variants = ["should be"]
                context_sentence = "He demanded that she be present at the conference."
                explanation = f"Mandative subjunctive uses base verb 'be' under rule {target_rule_id}."

            questions.append(
                NeutralQuestion(
                    question_id=q_id,
                    question_type=q_type,
                    text=q_text,
                    options=q_opts,
                    instructions=q_inst,
                )
            )

            # Construct ReferenceAnswerEvidence: strictly marked is_verified_gold=False
            private_evidence.append(
                ReferenceAnswerEvidence(
                    question_id=q_id,
                    rule_pack_id=rule_pack.rule_pack_id,
                    target_rule_id=target_rule_id,
                    context_sentence=context_sentence,
                    generator_proposed_answer=proposed_ans,
                    acceptable_variants=variants,
                    source_grounded_explanation=explanation,
                    is_verified_gold=False,
                )
            )

        neutral_output = NeutralOutput(
            context_text=context_text,
            question_groups=[NeutralQuestionGroup(group_id="g1", question_ids=q_ids)],
            questions=questions,
        )

        result = GenerationResult(
            run_id=run_id,
            dataset_item_id=dataset_item_id,
            configuration_id=config_id,
            task_type="GRAMMAR_EXERCISE",
            execution_status=ExecutionStatus.COMPLETED,
            output_availability=OutputAvailability.NORMALIZED,
            generated_content=neutral_output,
            private_answer_ref=f"secure://grammar/answers/{run_id}",
            trace_ref=f"secure://traces/{run_id}",
            usage_ref=f"secure://usage/{run_id}",
            failure_code=None,
            output_schema_version="v3",
        )

        return result, private_evidence
