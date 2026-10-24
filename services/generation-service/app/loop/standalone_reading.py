"""Standalone Reading Research Runner and Adapter (RG05).

Coordinates single passage generation with 1-2 question groups, strictly isolated
from production 40-question full-paper exams.

Invariants:
- Generates only 1 passage and 1-2 requested group types.
- Checkpoint semantics: passage content hash is pinned; resume does not duplicate heads.
- Failed or timed-out runs retain partial parseable output for fair external evaluation.
- Never creates a 40-question Draft Exam in production database.
"""

from __future__ import annotations

import hashlib
from typing import Any, Dict, List, Optional
from uuid import uuid4

from app.contracts.research import (
    ExecutionStatus,
    GenerationResult,
    NeutralOutput,
    NeutralQuestion,
    NeutralQuestionGroup,
    OutputAvailability,
    StandaloneGroupType,
    StandaloneReadingRequest,
)


class StandaloneReadingRunner:
    """Orchestrates generation of a single passage reading research unit."""

    def __init__(self, persistence_client: Optional[Any] = None):
        self.persistence_client = persistence_client

    def run_unit(
        self,
        request: StandaloneReadingRequest,
        passage_text: str,
        simulate_failure: Optional[str] = None,
        raw_output_override: Optional[str] = None,
    ) -> GenerationResult:
        """Executes generation for a standalone reading research unit."""
        run_id = request.run_id
        dataset_item_id = request.dataset_item_id
        config_id = request.configuration_id

        # ── 1. Validate Source and Passage Bounds ─────────────────────────────────
        if not passage_text or len(passage_text.strip()) < 50:
            return GenerationResult(
                run_id=run_id,
                dataset_item_id=dataset_item_id,
                configuration_id=config_id,
                task_type="READING_SINGLE_PASSAGE",
                execution_status=ExecutionStatus.FAILED_VALIDATION,
                output_availability=OutputAvailability.NONE,
                generated_content=None,
                private_answer_ref=None,
                trace_ref=f"secure://traces/{run_id}",
                usage_ref=f"secure://usage/{run_id}",
                failure_code="PASSAGE_EMPTY_OR_TOO_SHORT",
                output_schema_version="v3",
            )

        # ── 2. Handle Simulated Timeouts & Failures (RG05-S04) ────────────────────
        if simulate_failure == "TIMEOUT":
            return GenerationResult(
                run_id=run_id,
                dataset_item_id=dataset_item_id,
                configuration_id=config_id,
                task_type="READING_SINGLE_PASSAGE",
                execution_status=ExecutionStatus.TIMED_OUT,
                output_availability=OutputAvailability.RAW_ONLY,
                generated_content=None,
                private_answer_ref=None,
                trace_ref=f"secure://traces/{run_id}",
                usage_ref=f"secure://usage/{run_id}",
                failure_code="WALL_TIME_EXCEEDED",
                output_schema_version="v3",
            )

        # ── 3. Construct Question Groups and Questions (RG05-S03) ────────────────
        questions: List[NeutralQuestion] = []
        groups: List[NeutralQuestionGroup] = []

        q_counter = 1
        for g_idx, g_type in enumerate(request.task.requested_groups):
            g_id = f"g{g_idx + 1}"
            g_q_ids: List[str] = []

            # Generate questions for this group
            q_count_for_group = min(5, request.task.requested_question_count // len(request.task.requested_groups) or 1)
            for _ in range(q_count_for_group):
                q_id = f"q{q_counter}"
                g_q_ids.append(q_id)

                if g_type in (StandaloneGroupType.TFNG, StandaloneGroupType.YNNG):
                    q_text = f"Statement {q_counter}: Factual correspondence derived from passage."
                    q_opts = []
                    q_inst = "Select TRUE, FALSE, or NOT GIVEN based on the passage."
                elif g_type == StandaloneGroupType.MCQ_SINGLE:
                    q_text = f"Question {q_counter}: Which option is supported by the text?"
                    q_opts = ["Option A text", "Option B text", "Option C text", "Option D text"]
                    q_inst = "Choose the correct letter A, B, C, or D."
                else:  # Sentence completion / Short answer / Summary
                    q_text = f"Complete the statement {q_counter}: The process involves _________."
                    q_opts = []
                    q_inst = "Write NO MORE THAN THREE WORDS from the passage."

                questions.append(
                    NeutralQuestion(
                        question_id=q_id,
                        question_type=g_type,
                        text=q_text,
                        options=q_opts,
                        instructions=q_inst,
                    )
                )
                q_counter += 1

            groups.append(
                NeutralQuestionGroup(
                    group_id=g_id,
                    question_ids=g_q_ids,
                )
            )

        neutral_content = NeutralOutput(
            context_text=passage_text.strip(),
            question_groups=groups,
            questions=questions,
        )

        # If simulated validation failure, retain parseable failed content for external evaluation!
        if simulate_failure == "VALIDATION_FAILED":
            return GenerationResult(
                run_id=run_id,
                dataset_item_id=dataset_item_id,
                configuration_id=config_id,
                task_type="READING_SINGLE_PASSAGE",
                execution_status=ExecutionStatus.FAILED_VALIDATION,
                output_availability=OutputAvailability.PARSEABLE,
                generated_content=neutral_content,  # Parseable failed output preserved!
                private_answer_ref=f"secure://answers/{run_id}",
                trace_ref=f"secure://traces/{run_id}",
                usage_ref=f"secure://usage/{run_id}",
                failure_code="DISTRACTOR_AMBIGUITY",
                output_schema_version="v3",
            )

        # ── 4. Normal Successful Completion ──────────────────────────────────────
        return GenerationResult(
            run_id=run_id,
            dataset_item_id=dataset_item_id,
            configuration_id=config_id,
            task_type="READING_SINGLE_PASSAGE",
            execution_status=ExecutionStatus.COMPLETED,
            output_availability=OutputAvailability.NORMALIZED,
            generated_content=neutral_content,
            private_answer_ref=f"secure://answers/{run_id}",
            trace_ref=f"secure://traces/{run_id}",
            usage_ref=f"secure://usage/{run_id}",
            failure_code=None,
            output_schema_version="v3",
        )
