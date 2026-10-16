"""Response-originated A/B/C research arms, isolated from production V2 loops.

A dispatches once; B critiques its real draft and makes bounded revisions; C uses
fresh answer-blind reviewer/solver calls and validates each actual candidate.
Internal decisions never substitute for independent downstream rubric scoring.
"""
from __future__ import annotations

import hashlib
from dataclasses import dataclass
from typing import Any, Literal

from app.contracts.artifact import canonical_json_dump
from app.contracts.research import (
    ExecutionStatus, GenerationResult, OutputAvailability,
    StandaloneGrammarRequest, StandaloneReadingRequest,
)
from app.experiment.parsing import (
    CritiqueResponse, ParsedCandidate, ResearchRequest, ReviewResponse,
    SolverResponse, ValidatorResponse, parse_candidate, parse_control, solver_failure,
)
from app.providers.errors import (
    CancelledError, InvalidJsonError, ProviderError, TruncatedOutputError,
    TimeoutError as ProviderTimeoutError,
)


class HiddenRepairForbiddenError(RuntimeError):
    """Configuration A cannot self-review, retry, or repair."""


class InternalScoreAsExternalVerdictForbiddenError(RuntimeError):
    """B self-scores are not independent rubric verdicts."""


class AcceptedHeadAsQualityMetricForbiddenError(RuntimeError):
    """C acceptance is not an independent rubric verdict."""


@dataclass(frozen=True)
class LLMDispatchResponse:
    """One actual dispatch, with missing telemetry/cost explicitly unknown.

    EXACT applies only to provider-reported token counts, not inferred billing.
    request_config contains non-secret parameters that actually reached transport.
    """
    raw_text: str
    prompt_tokens: int | None = None
    completion_tokens: int | None = None
    total_tokens: int | None = None
    latency_ms: float | None = None
    confidence: Literal["EXACT", "ESTIMATED", "UNKNOWN"] = "UNKNOWN"
    cost_usd: float | None = None
    model_id: str | None = None
    token_source: Literal["PROVIDER", "ESTIMATED", "UNKNOWN"] | None = None
    cost_source: Literal["PROVIDER", "BILLING", "ESTIMATED", "UNKNOWN"] = "UNKNOWN"
    estimated_cost_usd: float | None = None
    provider_request_id: str | None = None
    response_origin: Literal["PROVIDER", "OFFLINE", "UNKNOWN"] = "UNKNOWN"
    request_config: dict[str, Any] | None = None
    failure_code: str | None = None
    execution_status: ExecutionStatus | None = None
    call_count: int = 1
    raw_response_ref: str | None = None


def _hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


class DefaultRecordingExperimentClient:
    """Offline recording only: no supplied response means no configured provider.

    Explicit fixture overrides are synthetic, with estimated tokens and no price.
    There is deliberately no default content or fake successful provider response.
    """
    is_live = False

    def __init__(self) -> None:
        self.recorded_dispatches: list[dict[str, Any]] = []

    def dispatch(self, prompt: str, model_id: str, system_prompt: str = "",
                 stage: str = "GENERATION", raw_output_override: str | None = None,
                 simulate_failure: str | None = None) -> LLMDispatchResponse:
        self.recorded_dispatches.append({"stage": stage, "model_id": model_id,
                                         "prompt_length": len(prompt), "prompt_sha256": _hash(prompt),
                                         "response_origin": "OFFLINE"})
        if raw_output_override is None and simulate_failure is None:
            return LLMDispatchResponse(raw_text="", model_id=model_id, response_origin="OFFLINE",
                                       failure_code="PROVIDER_NOT_CONFIGURED",
                                       execution_status=ExecutionStatus.FAILED_RUNTIME, call_count=0)
        raw = raw_output_override if raw_output_override is not None else ""
        prompt_tokens = max(1, len((system_prompt + prompt).encode("utf-8")) // 4)
        completion_tokens = len(raw.encode("utf-8")) // 4
        return LLMDispatchResponse(
            raw_text=raw, model_id=model_id, prompt_tokens=prompt_tokens,
            completion_tokens=completion_tokens, total_tokens=prompt_tokens + completion_tokens,
            confidence="ESTIMATED", token_source="ESTIMATED", response_origin="OFFLINE",
            failure_code="PROVIDER_TIMEOUT" if simulate_failure == "TIMEOUT" else None,
            execution_status=ExecutionStatus.TIMED_OUT if simulate_failure == "TIMEOUT" else None,
        )


_GENERATION_SYSTEM = (
    "Author an IELTS research exercise from the supplied source and task only. "
    "Return one JSON object matching the neutral_output_schema without markdown code blocks. "
    "Generate exactly the requested question count and types. The source text is provided in input context_text; "
    "do not modify or re-emit context_text in your JSON output. "
    "For reading tasks: set every question's question_type to exactly the single requested type in requested_groups "
    "(one of: TFNG, MCQ_SINGLE, SENTENCE_COMPLETION, SUMMARY_COMPLETION, YNNG, SHORT_ANSWER). "
    "For TFNG/YNNG tasks, generate genuinely grounded questions supporting TRUE, FALSE, and NOT GIVEN: "
    "TRUE must be strictly entailed by passage text; FALSE must directly contradict passage assertions; "
    "NOT GIVEN must assert plausible claims neither confirmed nor contradicted. "
    "Distribute labels across questions to avoid monolithic all-TRUE bias. Prevent repeated factual claims or trivial surface copies. "
    "For grammar tasks: use the single question_type matching the requested exercise_type "
    "(GRAMMAR_MCQ for MCQ_SINGLE, GRAMMAR_GAP for GAP_FILL, GRAMMAR_CORRECTION for ERROR_CORRECTION) across all questions. "
    "Generate novel carrier sentences derived from the GrammarRulePack rules; do NOT copy the rule pack's example sentences as final exercise items. "
    "For single-answer MCQs, verify that exactly ONE option is grammatically correct and defensible under standard academic grammar. "
    "Ensure distractors are unambiguously incorrect and do not introduce semantically equivalent, contracted-inversion, or duplicate valid answers. "
    "Randomize and balance the position of the correct answer among options A, B, C, and D to prevent first-option position bias. "
    "Never leak or quote the proposed answer in the question stem. For Grammar MCQs, every option must be a complete candidate sentence exemplifying the target structure, not bare noun phrases or fragments. "
    "Include proposed_answer privately on each question. Do not claim any proposed answer is verified gold. Do not emit scores or metadata."
)
_SYSTEMS = {
    "DIRECT_GENERATION_A": _GENERATION_SYSTEM,
    "DRAFT_GENERATION": _GENERATION_SYSTEM,
    "GENERATOR": _GENERATION_SYSTEM,
    "BOUNDED_REVISION": _GENERATION_SYSTEM + " Revise the actual supplied draft using the critique. Ensure rule pack novelty, distractor validity, and strict factual grounding.",
    "REPAIR": _GENERATION_SYSTEM + " Repair the actual supplied candidate using the listed issues. Ensure novel carrier sentences, exactly one valid MCQ option, and strict source grounding.",
    "SELF_CRITIQUE": (
        'Critique the actual draft. Check for rule pack example copying, distractor ambiguity (e.g. that/which cleft variants), tense discord, and Reading polarity balance. Return raw JSON without markdown or code blocks: {"verdict":"APPROVED|REVISION_NEEDED|REJECTED",'
        '"score":0.0,"issues":["blocking issue"]}. A self-score is not an external rubric verdict.'
    ),
    "REVIEWER": (
        'Independently review source grounding, clarity, distractor validity, and answer uniqueness without a proposed answer key. '
        'Reject any question where the prompt leaks the answer verbatim or where distractors contain multiple defensible choices. '
        'For Grammar, verify that carrier sentences are novel (not copied from rule pack examples), that every option is a complete candidate sentence (not bare noun phrases), and that exactly one option is grammatically defensible. '
        'For Reading, verify that TRUE/FALSE/NOT GIVEN statements are strictly grounded without unsupported generalizations. '
        'Return raw JSON without markdown or code blocks: {"status":"APPROVED|REJECTED","issues":["blocking issue"]}. '
        'Use APPROVED only if no blocking issue remains.'
    ),
    "BLIND_SOLVER": (
        'Solve every supplied question independently using only its visible context. For MCQ provide option letter (or option text); for TFNG/YNNG use standard labels TRUE/FALSE/NOT GIVEN or YES/NO/NOT GIVEN; for fill-in-the-blank provide target words without full sentence repeats or discursive explanations. '
        'If multiple options are grammatically defensible or if question is ambiguous/unsupported, flag ambiguous: true. '
        'Return raw JSON without markdown or code blocks: '
        '{"answers":[{"question_id":"id","answer":"answer","ambiguous":false}]}. '
        'No proposed answers or gold are provided.'
    ),
    "VALIDATOR": (
        'Check the source, candidate, independent review and blinded solve. Proposed answers are '
        'unverified generator proposals, not gold. Reject disagreement, ambiguity, prompt answer leaks, bare non-sentence options for grammar MCQs, duplicate defensible MCQ options, '
        'ungrounded Reading generalizations, or unresolved review issues. Return raw JSON without markdown or code blocks: {"accepted":true,"issues":["blocking issue"]}.'
    ),
}


def _sum_known(values: list[Any]) -> Any:
    return sum(values) if values and all(value is not None for value in values) else None


def _aggregate(responses: list[LLMDispatchResponse], repairs: int) -> dict[str, Any]:
    confidence = "UNKNOWN" if not responses or any(r.confidence == "UNKNOWN" for r in responses) else (
        "ESTIMATED" if any(r.confidence == "ESTIMATED" for r in responses) else "EXACT")
    sources = [r.token_source or {"EXACT": "PROVIDER", "ESTIMATED": "ESTIMATED", "UNKNOWN": "UNKNOWN"}[r.confidence]
               for r in responses]
    cost_sources = {r.cost_source for r in responses}
    cost_source = next(iter(cost_sources)) if len(cost_sources) == 1 else "UNKNOWN"
    actual_costs = [r.cost_usd if r.cost_source in ("PROVIDER", "BILLING") else None for r in responses]
    return {
        "call_count": sum(r.call_count for r in responses), "repair_count": repairs,
        "prompt_tokens": _sum_known([r.prompt_tokens for r in responses]),
        "completion_tokens": _sum_known([r.completion_tokens for r in responses]),
        "total_tokens": _sum_known([r.total_tokens for r in responses]),
        "latency_ms": _sum_known([r.latency_ms for r in responses]), "confidence": confidence,
        "token_source": "UNKNOWN" if "UNKNOWN" in sources or not sources else (
            "ESTIMATED" if "ESTIMATED" in sources else "PROVIDER"),
        "cost_usd": _sum_known(actual_costs), "cost_source": cost_source,
        "estimated_cost_usd": _sum_known([r.estimated_cost_usd for r in responses]),
        "provider_cost_usd": _sum_known([r.cost_usd if r.cost_source == "PROVIDER" else None for r in responses]),
        "billed_cost_usd": _sum_known([r.cost_usd if r.cost_source == "BILLING" else None for r in responses]),
    }


def _exception_response(error: Exception) -> LLMDispatchResponse:
    """Keep attached response/usage evidence without recording exception text."""
    status, code = ExecutionStatus.FAILED_RUNTIME, "PROVIDER_RUNTIME_ERROR"
    if isinstance(error, (TimeoutError, ProviderTimeoutError)):
        status, code = ExecutionStatus.TIMED_OUT, "PROVIDER_TIMEOUT"
    elif isinstance(error, CancelledError):
        status, code = ExecutionStatus.CANCELLED, "PROVIDER_CANCELLED"
    elif isinstance(error, TruncatedOutputError):
        status, code = ExecutionStatus.FAILED_VALIDATION, "PROVIDER_OUTPUT_TRUNCATED"
    elif isinstance(error, InvalidJsonError):
        status, code = ExecutionStatus.FAILED_VALIDATION, "RAW_OUTPUT_UNPARSEABLE"
    elif isinstance(error, ProviderError):
        code = "PROVIDER_UNAUTHORIZED" if error.status_code in (401, 403) else "PROVIDER_ERROR"
    usage = getattr(error, "usage", None)
    accounting = getattr(getattr(usage, "accounting_type", None), "value", "unknown")
    confidence = {"reported": "EXACT", "estimated": "ESTIMATED"}.get(accounting, "UNKNOWN")
    counts = [getattr(usage, key, None) if confidence != "UNKNOWN" else None
              for key in ("prompt_tokens", "completion_tokens", "total_tokens")]
    return LLMDispatchResponse(
        raw_text=getattr(error, "raw_text", None) or "",
        model_id=getattr(error, "model_id", None),
        prompt_tokens=counts[0], completion_tokens=counts[1], total_tokens=counts[2],
        confidence=confidence, token_source={"EXACT": "PROVIDER", "ESTIMATED": "ESTIMATED",
                                             "UNKNOWN": "UNKNOWN"}[confidence],
        failure_code=code, execution_status=status,
    )


class _Run:
    """One call-local execution; earlier assessable candidates survive later failures."""
    def __init__(self, client: Any, request: ResearchRequest, arm: str, prompt_version: str,
                 model_id: str, passage_text: str | None, **limits: int) -> None:
        self.client, self.request, self.arm = client, request, arm
        self.prompt_version, self.model_id, self.passage_text = prompt_version, model_id, passage_text
        self.limits = limits
        self.responses: list[LLMDispatchResponse] = []
        self.steps: list[dict[str, Any]] = []
        self.candidate: ParsedCandidate | None = None
        self.candidate_stage: str | None = None
        self.candidate_response_hash: str | None = None
        self.output_response_hash: str | None = None
        self.last_parsed: ParsedCandidate | None = None
        self.repairs = 0
        self.accepted = False

    def source(self) -> dict[str, Any]:
        if isinstance(self.request, StandaloneReadingRequest):
            return {"context_text": self.passage_text}
        return {"rule_pack": self.request.rule_pack.model_dump(mode="json")}

    def visible(self) -> dict[str, Any] | None:
        if not self.candidate or not self.candidate.content:
            return None
        dump = self.candidate.content.model_dump(mode="json")
        dump.pop("context_text", None)
        return dump

    def identity_failure(self) -> str | None:
        if self.request.configuration_id != self.arm:
            return "CONFIGURATION_IDENTITY_MISMATCH"
        if not self.request.is_research_mode:
            return "RESEARCH_MODE_REQUIRED"
        if not self.prompt_version.strip() or not self.model_id.strip():
            return "GENERATION_IDENTITY_MISSING"
        return None

    def invoke(self, stage: str, payload: dict[str, Any], *, raw_output_override: str | None = None,
               simulate_failure: str | None = None) -> tuple[LLMDispatchResponse, str | None]:
        prompt = canonical_json_dump({
            "configuration_id": self.arm, "prompt_version": self.prompt_version, "stage": stage,
            "task": self.request.task.model_dump(mode="json"), **payload,
        })
        system = _SYSTEMS[stage]
        try:
            response = self.client.dispatch(prompt=prompt, model_id=self.model_id, system_prompt=system,
                                            stage=stage, raw_output_override=raw_output_override,
                                            simulate_failure=simulate_failure)
            if not isinstance(response, LLMDispatchResponse):
                response = LLMDispatchResponse(raw_text="", failure_code="PROVIDER_RESPONSE_INVALID")
        except Exception as error:
            response = _exception_response(error)
        self.responses.append(response)
        config = {"configuration_id": self.arm, "prompt_version": self.prompt_version,
                  "requested_model_id": self.model_id, "stage": stage, "limits": self.limits,
                  "provider_config": response.request_config}
        step = {
            "stage": stage, "agent_role": stage, "call_index": len(self.responses),
            "model_id": response.model_id, "actual_model_id": response.model_id,
            "requested_model_id": self.model_id, "prompt_sha256": _hash(prompt),
            "system_prompt_sha256": _hash(system), "config_sha256": _hash(canonical_json_dump(config)),
            "response_sha256": _hash(response.raw_text), "provider_request_id": response.provider_request_id,
            "response_origin": response.response_origin, "prompt_tokens": response.prompt_tokens,
            "completion_tokens": response.completion_tokens, "total_tokens": response.total_tokens,
            "confidence": response.confidence, "latency_ms": response.latency_ms,
            "cost_usd": response.cost_usd, "cost_source": response.cost_source,
            "request_config": response.request_config,
            "model_revision": "UNKNOWN",
            "raw_response_ref": getattr(response, "raw_response_ref", None),
        }
        self.steps.append(step)
        failure = response.failure_code
        if failure is None and response.model_id != self.model_id:
            failure = "MODEL_IDENTITY_MISMATCH" if response.model_id else "MODEL_IDENTITY_UNKNOWN"
        if failure == "PROVIDER_TIMEOUT" and self.arm != "A":
            label = {"GENERATOR": "GENERATION", "REVIEWER": "REVIEW"}.get(stage, stage)
            failure = f"TIMEOUT_DURING_{label}"
        if failure:
            self.steps[-1] = {**step, "failure_code": failure}
        return response, failure

    def generate(self, stage: str, extra: dict[str, Any] | None = None, **kwargs: Any) -> tuple[str | None, ExecutionStatus | None]:
        response, failure = self.invoke(stage, {**self.source(), "neutral_output_schema": self.output_schema(),
                                                **(extra or {})}, **kwargs)
        if response.raw_text:
            parsed = parse_candidate(response.raw_text, self.request, self.passage_text)
            self.last_parsed = parsed
            if parsed.content is not None or self.candidate is None:
                self.candidate = parsed
                self.candidate_stage = stage
                self.candidate_response_hash = _hash(response.raw_text)
                self.output_response_hash = self.candidate_response_hash
        else:
            parsed = ParsedCandidate(None, OutputAvailability.NONE, "RAW_OUTPUT_UNPARSEABLE")
            self.last_parsed = parsed
        if failure:
            return failure, response.execution_status or ExecutionStatus.FAILED_RUNTIME
        return parsed.failure_code, ExecutionStatus.FAILED_VALIDATION if parsed.failure_code else None

    @staticmethod
    def output_schema() -> dict[str, Any]:
        from app.contracts.research import NeutralOutput
        return NeutralOutput.model_json_schema()

    def finish(self, failure: str | None = None, status: ExecutionStatus | None = None) -> tuple[GenerationResult, dict[str, Any], dict[str, Any]]:
        content = self.candidate.content if self.candidate else None
        failure = failure or (self.candidate.failure_code if self.candidate else "OUTPUT_MISSING")
        status = status or (ExecutionStatus.FAILED_VALIDATION if failure else ExecutionStatus.COMPLETED)
        availability = self.candidate.availability if self.candidate else (
            self.last_parsed.availability if self.last_parsed else OutputAvailability.NONE)
        candidate_stage = self.candidate_stage or (self.steps[0]["stage"] if self.steps else "UNKNOWN")
        response_hash = self.candidate_response_hash or (self.steps[0]["response_sha256"] if self.steps else None)
        proposed_map = dict(self.candidate.proposed_answers) if self.candidate else {}
        authoritative_answers = []
        if content and content.questions:
            for q in content.questions:
                qid = str(q.question_id)
                ans = proposed_map.get(qid)
                ans_str = str(ans).strip() if ans is not None else ""
                is_missing = not bool(ans_str)
                authoritative_answers.append({
                    "campaign_id": getattr(self.request, "campaign_id", "RG10_DEV"),
                    "assignment_id": getattr(self.request, "assignment_id", self.request.run_id),
                    "attempt_id": getattr(self.request, "attempt_id", self.request.run_id),
                    "stage": candidate_stage,
                    "question_id": qid,
                    "output_response_sha256": response_hash,
                    "proposed_answer": ans_str if not is_missing else None,
                    "status": "AVAILABLE" if not is_missing else "UNSCORABLE_MISSING_ANSWER",
                })
        provenance = {
            "configuration_id": self.arm, "prompt_version": self.prompt_version,
            "requested_model_id": self.model_id,
            "terminal_candidate_stage": candidate_stage,
            "terminal_candidate_response_sha256": response_hash,
            "authoritative_answer_provenance": authoritative_answers,
            "dispatches": [dict(step) for step in self.steps],
            "normalized_output_sha256": _hash(canonical_json_dump(content.model_dump(mode="json"))) if content else None,
            "output_response_sha256": self.output_response_hash if content else None,
            "trace_ref": f"secure://traces/{self.request.run_id}",
            "max_repairs": self.limits.get("max_repairs", 0),
            "repair_config_version": self.limits.get("repair_config_version", "v1.0" if self.arm == "C" else None),
        }
        usage = {**_aggregate(self.responses, self.repairs), "model_id": self.model_id,
                 "prompt_version": self.prompt_version, "provenance": provenance}
        trace = {"run_id": self.request.run_id, "configuration_id": self.arm,
                 "steps": [dict(step) for step in self.steps], "provenance": provenance,
                 "authoritative_answer_provenance": authoritative_answers}
        if self.arm == "C":
            trace["internal_accepted_head"] = self.accepted and failure is None
        result = GenerationResult(run_id=self.request.run_id, dataset_item_id=self.request.dataset_item_id,
                                  configuration_id=self.arm, task_type=self.request.task.task_type,
                                  execution_status=status, output_availability=availability,
                                  generated_content=content, failure_code=failure,
                                  private_answer_ref=f"secure://answers/{self.request.run_id}",
                                  trace_ref=f"secure://traces/{self.request.run_id}", usage_ref=None)
        return result, trace, usage


def _direct(run: _Run, raw_output_override: str | None, simulate_failure: str | None) -> tuple[Any, ...]:
    failure = run.identity_failure()
    status = ExecutionStatus.FAILED_RUNTIME if failure else None
    if not failure:
        failure, status = run.generate("DIRECT_GENERATION_A", raw_output_override=raw_output_override,
                                       simulate_failure=simulate_failure)
    result, _, usage = run.finish(failure, status)
    return result, usage


def _sequential(run: _Run, max_revisions: int, simulate_stage: str | None) -> tuple[Any, ...]:
    failure = run.identity_failure()
    if failure:
        return run.finish(failure, ExecutionStatus.FAILED_RUNTIME)
    failure, status = run.generate("DRAFT_GENERATION", simulate_failure="TIMEOUT" if simulate_stage == "DRAFT_GENERATION" else None)
    if failure:
        return run.finish(failure, status)
    for revision in range(max_revisions + 1):
        response, failure = run.invoke("SELF_CRITIQUE", {**run.source(), "candidate": run.visible()},
                                       simulate_failure="TIMEOUT" if simulate_stage == "SELF_CRITIQUE" else None)
        if failure:
            return run.finish(failure, response.execution_status or ExecutionStatus.FAILED_RUNTIME)
        critique = parse_control(response.raw_text, CritiqueResponse)
        if critique is None or critique.verdict not in ("APPROVED", "REVISION_NEEDED", "REJECTED"):
            return run.finish("SELF_CRITIQUE_OUTPUT_UNPARSEABLE")
        run.steps[-1] = {**run.steps[-1], "internal_verdict": critique.verdict,
                         "internal_score": critique.score, "critique_notes": list(critique.issues)}
        if critique.verdict == "APPROVED" and not critique.issues:
            return run.finish()
        if revision == max_revisions:
            return run.finish("SELF_CRITIQUE_REJECTED")
        run.repairs += 1
        failure, status = run.generate("BOUNDED_REVISION", {"candidate": run.visible(),
                                                           "critique": critique.model_dump(mode="json")},
                                      simulate_failure="TIMEOUT" if simulate_stage == "BOUNDED_REVISION" else None)
        if failure:
            return run.finish(failure, status)
        # A bounded B revision is the arm's final candidate; no hidden extra review.
        if revision + 1 == max_revisions:
            return run.finish()
    raise AssertionError("Finite revision loop must return")


def _coordinated_checks(run: _Run, simulate_stage: str | None) -> tuple[str | None, ExecutionStatus | None, list[str]]:
    for stage, model in (("REVIEWER", ReviewResponse), ("BLIND_SOLVER", SolverResponse), ("VALIDATOR", ValidatorResponse)):
        payload = {"candidate": run.visible(), **run.source()}
        if stage == "VALIDATOR":
            payload = {**payload, "review": review.model_dump(mode="json"),
                       "blinded_solve": solved.model_dump(mode="json"),
                       "generator_proposed_answers": dict(run.candidate.proposed_answers)}
        response, failure = run.invoke(stage, payload, simulate_failure="TIMEOUT" if simulate_stage == stage else None)
        if failure:
            return failure, response.execution_status or ExecutionStatus.FAILED_RUNTIME, []
        control = parse_control(response.raw_text, model)
        if control is None:
            return f"{stage}_OUTPUT_UNPARSEABLE", ExecutionStatus.FAILED_VALIDATION, []
        if stage == "REVIEWER":
            review = control
            run.steps[-1] = {**run.steps[-1], "status": review.status, "issues_flagged": len(review.issues)}
            if review.status not in ("APPROVED", "REJECTED"):
                return "REVIEWER_OUTPUT_UNPARSEABLE", ExecutionStatus.FAILED_VALIDATION, []
            if review.status != "APPROVED" or review.issues:
                return "REVIEW_REJECTED", ExecutionStatus.FAILED_VALIDATION, list(review.issues)
        elif stage == "BLIND_SOLVER":
            solved = control
            failure = solver_failure(solved, run.candidate)
            run.steps[-1] = {**run.steps[-1], "solved_unambiguously": failure is None}
            if failure:
                return failure, ExecutionStatus.FAILED_VALIDATION, [failure]
        else:
            accepted = control.accepted and not control.issues
            run.steps[-1] = {**run.steps[-1], "internal_accepted_head": accepted}
            if not accepted:
                return "VALIDATOR_REJECTED", ExecutionStatus.FAILED_VALIDATION, list(control.issues)
    return None, None, []


def _coordinated(run: _Run, max_repairs: int, simulate_stage: str | None) -> tuple[Any, ...]:
    failure = run.identity_failure()
    if failure:
        return run.finish(failure, ExecutionStatus.FAILED_RUNTIME)
    failure, status = run.generate("GENERATOR", simulate_failure="TIMEOUT" if simulate_stage == "GENERATOR" else None)
    for repair in range(max_repairs + 1):
        issues = [failure] if failure else []
        if not failure:
            failure, status, issues = _coordinated_checks(run, simulate_stage)
        if not failure:
            run.accepted = True
            return run.finish()
        can_repair = failure in {"REVIEW_REJECTED", "VALIDATOR_REJECTED", "BLIND_SOLVE_REJECTED",
                                 "BLIND_SOLVE_INCOMPLETE", "ANSWER_VERIFICATION_DISAGREEMENT", "PROPOSED_ANSWERS_MISSING",
                                 "QUESTION_COUNT_MISMATCH", "QUESTION_TYPE_MISMATCH", "QUESTION_GROUP_MISMATCH",
                                 "QUESTION_OPTIONS_INVALID", "OUTPUT_SCHEMA_INVALID", "CONTEXT_MISMATCH",
                                 "PROMPT_LEAKS_ANSWER"}
        if repair == max_repairs or not can_repair:
            return run.finish(failure, status)
        run.repairs += 1
        failure, status = run.generate("REPAIR", {"candidate": run.visible(), "issues": issues},
                                       simulate_failure="TIMEOUT" if simulate_stage == "REPAIR" else None)
    raise AssertionError("Finite repair loop must return")


def _bound(value: int, name: str) -> None:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise ValueError(f"{name} must be a finite nonnegative integer")


class ConfigurationARunner:
    """Direct single-response generation, with no model review/retry/repair."""
    def __init__(self, client: Any = None) -> None:
        self.client = client if client is not None else DefaultRecordingExperimentClient()

    def generate_reading(self, request: StandaloneReadingRequest, passage_text: str, prompt_version: str,
                         foundation_model_id: str, raw_output_override: str | None = None,
                         simulate_failure: str | None = None, attempt_repair: bool = False,
                         max_repairs: int = 0) -> tuple[GenerationResult, dict[str, Any]]:
        if attempt_repair or max_repairs > 0:
            raise HiddenRepairForbiddenError("Hidden repair or self-review is forbidden for Configuration A (strictly single-call direct generation).")
        return _direct(_Run(self.client, request, "A", prompt_version, foundation_model_id, passage_text), raw_output_override, simulate_failure)

    def generate_grammar(self, request: StandaloneGrammarRequest, prompt_version: str, foundation_model_id: str,
                         raw_output_override: str | None = None, simulate_failure: str | None = None,
                         attempt_repair: bool = False, max_repairs: int = 0) -> tuple[GenerationResult, dict[str, Any]]:
        if attempt_repair or max_repairs > 0:
            raise HiddenRepairForbiddenError("Hidden repair or self-review is forbidden for Configuration A (strictly single-call direct generation).")
        return _direct(_Run(self.client, request, "A", prompt_version, foundation_model_id, None), raw_output_override, simulate_failure)


class ConfigurationBRunner:
    """Same-model sequential critique, with actual bounded revision responses."""
    def __init__(self, client: Any = None) -> None:
        self.client = client if client is not None else DefaultRecordingExperimentClient()

    def certify_external_verdict(self, internal_verdict: str | None = None, internal_score: float | None = None,
                                source: str = "B_INTERNAL") -> None:
        if source == "B_INTERNAL" or internal_score is not None or internal_verdict is not None:
            raise InternalScoreAsExternalVerdictForbiddenError("B self-score cannot be accepted as external rubric verdict (must be scored by downstream independent judge).")

    def generate_reading(self, request: StandaloneReadingRequest, passage_text: str, prompt_version: str,
                         foundation_model_id: str, max_revisions: int = 1,
                         simulate_failure_at_stage: str | None = None) -> tuple[GenerationResult, dict[str, Any], dict[str, Any]]:
        _bound(max_revisions, "max_revisions")
        return _sequential(_Run(self.client, request, "B", prompt_version, foundation_model_id, passage_text,
                                max_revisions=max_revisions), max_revisions, simulate_failure_at_stage)

    def generate_grammar(self, request: StandaloneGrammarRequest, prompt_version: str, foundation_model_id: str,
                         max_revisions: int = 1, simulate_failure_at_stage: str | None = None) -> tuple[GenerationResult, dict[str, Any], dict[str, Any]]:
        _bound(max_revisions, "max_revisions")
        return _sequential(_Run(self.client, request, "B", prompt_version, foundation_model_id, None,
                                max_revisions=max_revisions), max_revisions, simulate_failure_at_stage)


# Versioned Arm C repair configuration profiles
# v1.0: Historical frozen campaign configuration (0 repairs, immediate termination on rejection)
ARM_C_REPAIR_CONFIG_HISTORICAL_V1: int = 0

# v2.0: Bounded multi-agent repair configuration for DEV and future research (1 repair)
ARM_C_REPAIR_CONFIG_DEV_V2: int = 1

# Maximum ceiling permitted by scientific protocol to prevent unbounded loops
ARM_C_MAX_REPAIR_CEILING: int = 2


class ConfigurationCRunner:
    """Separated generation/review/solve/validation; each repair repeats fresh checks."""
    def __init__(
        self,
        client: Any = None,
        default_max_repairs: int = 0,
        repair_config_version: str = "v1.0",
    ) -> None:
        self.client = client if client is not None else DefaultRecordingExperimentClient()
        if repair_config_version == "v2.0" and default_max_repairs == 0:
            self.default_max_repairs = ARM_C_REPAIR_CONFIG_DEV_V2
        else:
            self.default_max_repairs = default_max_repairs
        self.repair_config_version = repair_config_version
    def certify_external_verdict(self, internal_accepted: bool = False, source: str = "C_INTERNAL",
                                use_internal_accepted_head: bool = False) -> None:
        if internal_accepted or use_internal_accepted_head or source == "C_INTERNAL":
            raise AcceptedHeadAsQualityMetricForbiddenError("Configuration C internal accepted-head predicate cannot be used as an A/B/C quality metric (independent rubric judge required).")

    def generate_reading(self, request: StandaloneReadingRequest, passage_text: str, prompt_version: str,
                         foundation_model_id: str, simulate_failure_at_stage: str | None = None,
                         max_repairs: int | None = None) -> tuple[GenerationResult, dict[str, Any], dict[str, Any]]:
        repairs = self.default_max_repairs if max_repairs is None else max_repairs
        _bound(repairs, "max_repairs")
        return _coordinated(_Run(self.client, request, "C", prompt_version, foundation_model_id, passage_text,
                                 max_repairs=repairs, repair_config_version=self.repair_config_version), repairs, simulate_failure_at_stage)

    def generate_grammar(self, request: StandaloneGrammarRequest, prompt_version: str, foundation_model_id: str,
                         simulate_failure_at_stage: str | None = None,
                         max_repairs: int | None = None) -> tuple[GenerationResult, dict[str, Any], dict[str, Any]]:
        repairs = self.default_max_repairs if max_repairs is None else max_repairs
        _bound(repairs, "max_repairs")
        return _coordinated(_Run(self.client, request, "C", prompt_version, foundation_model_id, None,
                                 max_repairs=repairs, repair_config_version=self.repair_config_version), repairs, simulate_failure_at_stage)
