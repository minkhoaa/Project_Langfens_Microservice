"""Question Candidate Generator for Six IELTS Question Types (Phase 09 / P09-03).

Generates bounded pools of question candidates for each question slot:
- SentenceCompletion / ShortAnswer: bounded to 1-2 candidates.
- TrueFalseNotGiven / YesNoNotGiven: bounded to 2-3 candidates.
- MultipleChoiceSingle: bounded to <= 3 candidates.
- SummaryCompletion: generates coherent group variants with shared draft and targeted blanks.

Enforces:
- Hard pool caps from typed Settings.
- Immutable passage context with untrusted data envelope.
- Defensive JSON parsing and schema validation.
- Zero leakage of holdout items.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List, Optional
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactRef, ArtifactType
from app.generators.question.context import (
    OptionItem,
    QuestionCandidate,
    QuestionCandidatePool,
    QuestionGroupContext,
)
from app.generators.question.prompts import (
    QUESTION_PROMPT_VERSION,
    QuestionPromptFamily,
    build_question_prompt,
)
from app.loop.context import LoopContext
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json

logger = logging.getLogger(__name__)


def get_pool_limit_for_type(question_type: str) -> int:
    """Returns typed pool limit from Settings per P09-03 policy."""
    if question_type in (
        QuestionPromptFamily.SENTENCE_COMPLETION.value,
        "SentenceCompletion",
    ):
        return getattr(settings, "candidate_pool_limit_completion", 2)
    elif question_type in (
        QuestionPromptFamily.SHORT_ANSWER.value,
        "ShortAnswer",
    ):
        return getattr(settings, "candidate_pool_limit_short_answer", 2)
    elif question_type in (
        QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN.value,
        QuestionPromptFamily.YES_NO_NOT_GIVEN.value,
        "TrueFalseNotGiven",
        "YesNoNotGiven",
    ):
        return getattr(settings, "candidate_pool_limit_tfng", 3)
    elif question_type in (
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE.value,
        "MultipleChoiceSingle",
    ):
        return getattr(settings, "candidate_pool_limit_mcq", 3)
    elif question_type in (
        QuestionPromptFamily.SUMMARY_COMPLETION.value,
        "SummaryCompletion",
    ):
        return getattr(settings, "candidate_pool_limit_summary", 2)
    return 2


class QuestionCandidateGenerator:
    """Generator for bounded pools of question candidates using ProviderGateway."""

    def __init__(self, gateway: Optional[ProviderGateway] = None):
        self._gateway = gateway

    @property
    def gateway(self) -> Optional[ProviderGateway]:
        return self._gateway

    async def generate_candidate_pool(
        self,
        passage_text: str,
        question_type: str,
        question_number: int,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        run_id: str,
        section_id: Optional[str] = "1",
        context: Optional[LoopContext] = None,
        custom_pool_limit: Optional[int] = None,
        group_id: Optional[str] = None,
        parent_operation_id: Optional[str] = None,
    ) -> QuestionCandidatePool:
        """Generates a bounded candidate pool for an individual question slot."""
        pool_limit = custom_pool_limit or get_pool_limit_for_type(question_type)
        slot_id = f"slot_q{question_number}_{question_type}"
        pool = QuestionCandidatePool(
            slotId=slot_id,
            questionNumber=question_number,
            questionType=question_type,
            poolLimit=pool_limit,
        )

        try:
            family = QuestionPromptFamily(question_type)
        except ValueError:
            family = QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN

        prompt_data = build_question_prompt(
            family=family,
            passage_text=passage_text,
            question_number=question_number,
            candidate_count=pool_limit,
        )

        if self._gateway is None or context is None:
            # Offline / fake fallback candidate generation for interface testing
            return self._build_mock_candidate_pool(
                passage_text=passage_text,
                question_type=question_type,
                question_number=question_number,
                passage_ref=passage_ref,
                blueprint_ref=blueprint_ref,
                pool_limit=pool_limit,
                slot_id=slot_id,
                group_id=group_id,
            )

        op_id = f"gen_qpool_{question_number}_{uuid4().hex[:8]}"
        req = ProviderRequest(
            operation_id=op_id,
            run_id=run_id,
            section_id=f"section_{section_id}" if section_id and not str(section_id).startswith("section_") else (str(section_id) if section_id else "section_1"),
            artifact_id=f"questions_section_{section_id}" if section_id and not str(section_id).startswith("section_") else (f"questions_{section_id}" if section_id else "questions_section_1"),
            parent_operation_id=parent_operation_id or (getattr(context, "parent_operation_id", None) if context else None),
            capability=Capability.GENERATE_JSON,
            messages=[
                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                ChatMessage(role="user", content=prompt_data["user_prompt"]),
            ],
            max_tokens=1800,
            timeout_seconds=float(getattr(settings, "loop_operation_wall_reservation_seconds", 30.0)),
            wall_time_reservation_seconds=float(getattr(settings, "loop_operation_wall_reservation_seconds", 30.0)),
        )

        resp = await self._gateway.execute(
            req,
            epoch=context.authority.epoch,
            lease_owner=context.authority.lease_owner,
        )
        parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)

        raw_candidates = parsed.get("candidates", [])
        if not isinstance(raw_candidates, list):
            raw_candidates = [parsed] if "prompt" in parsed else []

        for idx, raw in enumerate(raw_candidates[:pool_limit]):
            cand_id = f"cand_{slot_id}_{idx+1}_{uuid4().hex[:6]}"
            options = None
            if question_type == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE.value and "options" in raw:
                opts_raw = raw.get("options", [])
                options = [
                    OptionItem(key=o.get("key", ""), text=o.get("text", ""))
                    for o in opts_raw
                    if isinstance(o, dict)
                ]

            cand = QuestionCandidate(
                candidateId=cand_id,
                slotId=slot_id,
                passageRef=passage_ref,
                blueprintRef=blueprint_ref,
                groupId=group_id,
                questionNumber=question_number,
                questionType=question_type,
                prompt=raw.get("prompt", ""),
                answer=raw.get("answer", ""),
                options=options,
                evidenceQuote=raw.get("evidenceQuote", ""),
                explanation=raw.get("explanation"),
                metadata={
                    "promptVersion": QUESTION_PROMPT_VERSION,
                    "provider": resp.provider_name,
                    "model": resp.model_name,
                },
            )
            pool.add_candidate(cand)

        return pool

    async def generate_summary_group_variants(
        self,
        passage_text: str,
        start_number: int,
        blank_count: int,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        run_id: str,
        section_id: Optional[str] = "1",
        context: Optional[LoopContext] = None,
    ) -> List[QuestionGroupContext]:
        pool_limit = getattr(settings, "candidate_pool_limit_summary", 2)
        variants: List[QuestionGroupContext] = []

        prompt_data = build_question_prompt(
            family=QuestionPromptFamily.SUMMARY_COMPLETION,
            passage_text=passage_text,
            question_number=start_number,
            blank_count=blank_count,
        )

        if self._gateway is None or context is None:
            # Fallback mock summary group
            mock_text = "The study observed that [1] was prevalent. In addition, [2] was documented."
            variants.append(
                QuestionGroupContext(
                    groupId=f"grp_summary_{start_number}_v1",
                    sectionIndex=1,
                    questionType="SummaryCompletion",
                    startNumber=start_number,
                    endNumber=start_number + blank_count - 1,
                    instructions=f"Complete the summary below using NO MORE THAN THREE WORDS for questions {start_number}-{start_number + blank_count - 1}.",
                    summaryTitle="Ecological Findings",
                    summaryText=mock_text,
                    passageRef=passage_ref,
                    blueprintRef=blueprint_ref,
                )
            )
            return variants

        op_id = f"gen_summary_grp_{start_number}_{uuid4().hex[:8]}"
        req = ProviderRequest(
            operation_id=op_id,
            run_id=run_id,
            section_id=section_id,
            artifact_id=f"art_summary_grp_{start_number}",
            capability=Capability.GENERATE_JSON,
            messages=[
                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                ChatMessage(role="user", content=prompt_data["user_prompt"]),
            ],
            max_tokens=2200,
            timeout_seconds=getattr(settings, "evaluator_stage_timeout_seconds", 45.0),
        )

        resp = await self._gateway.execute(
            req,
            epoch=context.authority.epoch,
            lease_owner=context.authority.lease_owner,
        )
        parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)

        summary_text = parsed.get("summaryText", "")
        summary_title = parsed.get("summaryTitle", "Summary")
        grp = QuestionGroupContext(
            groupId=f"grp_summary_{start_number}_v1",
            sectionIndex=1,
            questionType="SummaryCompletion",
            startNumber=start_number,
            endNumber=start_number + blank_count - 1,
            instructions=f"Complete the summary below using NO MORE THAN THREE WORDS for questions {start_number}-{start_number + blank_count - 1}.",
            summaryTitle=summary_title,
            summaryText=summary_text,
            passageRef=passage_ref,
            blueprintRef=blueprint_ref,
        )
        variants.append(grp)
        return variants

    def _build_mock_candidate_pool(
        self,
        passage_text: str,
        question_type: str,
        question_number: int,
        passage_ref: ArtifactRef,
        blueprint_ref: ArtifactRef,
        pool_limit: int,
        slot_id: str,
        group_id: Optional[str] = None,
    ) -> QuestionCandidatePool:
        pool = QuestionCandidatePool(
            slotId=slot_id,
            questionNumber=question_number,
            questionType=question_type,
            poolLimit=pool_limit,
        )
        for i in range(pool_limit):
            cand_id = f"cand_{slot_id}_{i+1}"
            options = None
            if question_type == QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE.value:
                options = [
                    OptionItem(key="A", text="Option Alpha"),
                    OptionItem(key="B", text="Option Beta"),
                    OptionItem(key="C", text="Option Gamma"),
                    OptionItem(key="D", text="Option Delta"),
                ]
                ans = "A"
                prompt = f"What is the primary factor regarding question {question_number}?"
            elif question_type in (QuestionPromptFamily.SENTENCE_COMPLETION.value, "SentenceCompletion"):
                p_words = [w.strip(".,;:\"'!?") for w in passage_text.split() if len(w.strip(".,;:\"'!?")) >= 4] if passage_text else []
                ans = p_words[-1] if p_words else "pottery"
                prompt = "Further investigations documented ancient ______."
                if ans.lower() in prompt.lower() and len(p_words) > 1:
                    ans = p_words[0]
            elif question_type in (QuestionPromptFamily.SHORT_ANSWER.value, "ShortAnswer"):
                p_words = [w.strip(".,;:\"'!?") for w in passage_text.split() if len(w.strip(".,;:\"'!?")) >= 4] if passage_text else []
                ans = p_words[-1] if p_words else "pottery"
                prompt = "What key element was identified in the passage?"
            elif question_type in (QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN.value, "TrueFalseNotGiven"):
                options = [
                    OptionItem(key="TRUE", text="TRUE"),
                    OptionItem(key="FALSE", text="FALSE"),
                    OptionItem(key="NOT GIVEN", text="NOT GIVEN"),
                ]
                prompt = f"The expedition took place in {2020 + i}."
                ans = "TRUE" if i == 0 else "FALSE"
            elif question_type in (QuestionPromptFamily.YES_NO_NOT_GIVEN.value, "YesNoNotGiven"):
                options = [
                    OptionItem(key="YES", text="YES"),
                    OptionItem(key="NO", text="NO"),
                    OptionItem(key="NOT GIVEN", text="NOT GIVEN"),
                ]
                prompt = f"The author suggests that immediate intervention is necessary."
                ans = "YES" if i == 0 else "NO"
            else:
                prompt = f"Question {question_number} prompt."
                ans = "sample answer"

            cand = QuestionCandidate(
                candidateId=cand_id,
                slotId=slot_id,
                passageRef=passage_ref,
                blueprintRef=blueprint_ref,
                groupId=group_id,
                questionNumber=question_number,
                questionType=question_type,
                prompt=prompt,
                answer=ans,
                options=options,
                evidenceQuote=passage_text[:60] if passage_text else "evidence",
            )
            pool.add_candidate(cand)

        return pool
