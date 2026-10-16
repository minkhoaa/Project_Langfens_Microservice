"""Explicit synthetic provider responses for research tests, never a live adapter."""
from __future__ import annotations

import json
from typing import Any

from app.experiment.runners import DefaultRecordingExperimentClient, LLMDispatchResponse


class DeterministicExperimentClient:
    """Produces fixture JSON from the declared task, with estimated telemetry only."""
    is_live = False

    def __init__(self) -> None:
        self.recorded_dispatches: list[dict[str, Any]] = []

    @staticmethod
    def _answer(kind: str) -> str:
        return {"TFNG": "TRUE", "YNNG": "YES", "MCQ_SINGLE": "A",
                "GRAMMAR_MCQ": "A", "GRAMMAR_GAP": "had", "GRAMMAR_CORRECTION": "had"}.get(kind, "wetland")

    def _candidate(self, payload: dict[str, Any]) -> dict[str, Any]:
        task = payload["task"]
        if task["task_type"] == "READING_SINGLE_PASSAGE":
            kinds = task["requested_groups"]
            context = payload["context_text"]
        else:
            kinds = [{"MCQ_SINGLE": "GRAMMAR_MCQ", "GAP_FILL": "GRAMMAR_GAP",
                      "ERROR_CORRECTION": "GRAMMAR_CORRECTION"}[task["exercise_type"]]]
            context = f"Fixture exercise about {payload['rule_pack']['topic']}."
        questions = []
        for index in range(task["requested_question_count"]):
            kind = kinds[index % len(kinds)]
            is_mcq = kind in ("MCQ_SINGLE", "GRAMMAR_MCQ")
            questions.append({
                "question_id": f"q_{index + 1}", "question_type": kind,
                "text": f"Fixture question {index + 1}: {context.split('.')[0]} ____.",
                "instructions": "Choose A, B, C or D." if is_mcq else "Complete the response according to the source.",
                "options": ["First fixture option", "Second fixture option", "Third fixture option", "Fourth fixture option"] if is_mcq else [],
                "proposed_answer": self._answer(kind),
            })
        return {"context_text": context, "questions": questions,
                "question_groups": [
                    {"group_id": f"group_{index + 1}",
                     "question_ids": [q["question_id"] for q in questions if q["question_type"] == kind]}
                    for index, kind in enumerate(kinds)
                ]}

    def dispatch(self, prompt: str, model_id: str, system_prompt: str = "",
                 stage: str = "GENERATION", raw_output_override: str | None = None,
                 simulate_failure: str | None = None) -> LLMDispatchResponse:
        self.recorded_dispatches.append({"prompt": prompt, "system_prompt": system_prompt,
                                         "model_id": model_id, "stage": stage})
        if simulate_failure is not None or raw_output_override is not None:
            return DefaultRecordingExperimentClient().dispatch(prompt=prompt, model_id=model_id,
                system_prompt=system_prompt, stage=stage, raw_output_override=raw_output_override,
                simulate_failure=simulate_failure)
        payload = json.loads(prompt)
        if stage in ("DIRECT_GENERATION_A", "DRAFT_GENERATION", "GENERATOR", "BOUNDED_REVISION", "REPAIR"):
            output = self._candidate(payload)
        elif stage == "SELF_CRITIQUE":
            output = {"verdict": "REVISION_NEEDED", "score": 3.8, "issues": ["Fixture asks for one explicit revision."]}
        elif stage == "REVIEWER":
            output = {"status": "APPROVED", "issues": []}
        elif stage == "BLIND_SOLVER":
            output = {"answers": [{"question_id": q["question_id"], "answer": self._answer(q["question_type"]),
                                    "ambiguous": False} for q in payload["candidate"]["questions"]]}
        elif stage == "VALIDATOR":
            output = {"accepted": True, "issues": []}
        else:
            raise AssertionError(f"Unexpected fixture stage: {stage}")
        raw = json.dumps(output)
        prompt_tokens, completion_tokens = len((prompt + system_prompt).encode()) // 4, len(raw.encode()) // 4
        return LLMDispatchResponse(raw_text=raw, prompt_tokens=prompt_tokens,
                                   completion_tokens=completion_tokens,
                                   total_tokens=prompt_tokens + completion_tokens,
                                   latency_ms=1.0, confidence="ESTIMATED", token_source="ESTIMATED",
                                   response_origin="OFFLINE", model_id=model_id)
