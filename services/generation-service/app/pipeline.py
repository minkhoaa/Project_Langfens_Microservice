"""Canonical ReadingGenerationPipeline executing fenced, durable multi-stage reading generation.

Executes Stage 0 (validate run), Stage 1 (sources), Stage 2 (evidence),
Stage 3 (blueprint), Stage 4-6 (SectionRunner per selected section, sequential or parallel),
Stage 7 (Paper assembly if all 3 sections present), Stage 8 (CheckpointClient.build_exam if finalize=True).
"""

from __future__ import annotations

import asyncio
import hashlib
import json
import re
from uuid import uuid4

from app.extractor import (
    ProgressCallback,
    SourceError,
    SourceNetworkError,
    _progress,
    fetch_source,
    source_excerpt,
)
from app.llm import llm_generate
from app.prompts import (
    build_group_instruction,
    build_passage_extension_prompt,
    build_passage_prompt,
    build_passage_revision_prompt,
    build_question_prompt,
)

import logging
from collections.abc import Callable, Sequence
from typing import Any, Optional
from uuid import UUID

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult
from app.persistence.client import CheckpointClient
from app.persistence.models import BuildExamInternalRequest
from app.providers.gateway import ProviderGateway
from app.reading_evaluation import evaluate_blueprint, evaluate_evidence, evaluate_paper, evaluate_source
from app.reading_generation import build_blueprint, build_evidence, compose_paper_payload, prepare_source, trim_passage
from app.reading_models import (
    AcceptedSectionArtifact, PipelineRequest, PipelineResult, RunContext,
    SourceInput, SourceRef,
)
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.section_runner import SectionRunner
from app.stage_executor import StageExecutor

logger = logging.getLogger(__name__)


class ReadingGenerationPipeline:
    """Authoritative orchestrator for IELTS Reading paper generation."""

    def __init__(
        self,
        client: CheckpointClient,
        gateway: ProviderGateway,
        *,
        executor_factory: Optional[Callable[..., StageExecutor]] = None,
        runner_factory: Optional[Callable[..., SectionRunner]] = None,
    ) -> None:
        self.client = client
        self.gateway = gateway
        self.executor_factory = executor_factory
        self.runner_factory = runner_factory

    def _get_executor(
        self,
        context: RunContext,
        policy: PinnedExecutionPolicy,
        *,
        required_evaluator_ids: tuple[str, ...] = (),
    ) -> StageExecutor:
        if self.executor_factory:
            return self.executor_factory(context, policy, required_evaluator_ids=required_evaluator_ids)
        return StageExecutor(self.client, context, policy, required_evaluator_ids=required_evaluator_ids)

    def _get_runner(self) -> SectionRunner:
        if self.runner_factory:
            return self.runner_factory(self.client, self.gateway)
        return SectionRunner(self.client, self.gateway)

    async def execute(self, request: PipelineRequest) -> PipelineResult:
        """Executes the full generation pipeline across stages 0 through 8."""
        logger.info(
            "Starting ReadingGenerationPipeline run %s (sections=%s, parallel=%s, finalize=%s)",
            request.run_id,
            request.section_indices,
            request.parallel,
            request.finalize,
        )

        # ── Stage 0: Validate run authority and pinned policy ────────────────
        context = RunContext.from_request(request, client=self.client, gateway=self.gateway)
        executor = self._get_executor(context, request.policy)

        # Map sources by section index
        sources_by_section: dict[int, SourceInput] = {s.section_index: s for s in request.sources}
        for sec_idx in request.section_indices:
            if sec_idx not in sources_by_section:
                raise ValueError(f"Missing required source input for selected section {sec_idx}")

        # ── Stage 1: Ingest and verify sources ───────────────────────────────
        source_envelopes: dict[int, ArtifactEnvelope] = {}
        for sec_idx in sorted(request.section_indices):
            src_input = sources_by_section[sec_idx]
            art_id = f"source:{request.run_id}:{sec_idx}"

            async def generate_source(version: int, inp: SourceInput = src_input) -> dict[str, Any]:
                return await prepare_source(inp, request.run_id, request.policy)

            async def evaluate_source_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
                return evaluate_source(art, request.policy)

            env = await executor.execute(
                art_id,
                ArtifactType.SOURCE_PACK,
                (),
                generate_source,
                evaluate_source_stage,
                section_id=sec_idx,
            )
            source_envelopes[sec_idx] = env

        # ── Stage 2: Ground verified evidence claims ─────────────────────────
        evidence_envelopes: dict[int, ArtifactEnvelope] = {}
        for sec_idx in sorted(request.section_indices):
            art_id = f"evidence:{request.run_id}:{sec_idx}"
            src_env = source_envelopes[sec_idx]

            async def generate_evidence(
                version: int,
                s_env: ArtifactEnvelope = src_env,
                s_idx: int = sec_idx,
            ) -> dict[str, Any]:
                return build_evidence(s_env, request.run_id, s_idx, request.policy)

            async def evaluate_evidence_stage(
                art: ArtifactEnvelope,
                s_env: ArtifactEnvelope = src_env,
            ) -> list[EvaluationResult]:
                text_map = {
                    s_env.payload["sources"][0]["sourceId"]: s_env.payload["sources"][0]["document"]["text"]
                }
                return evaluate_evidence(art, text_map, request.policy.min_verified_claims)

            env = await executor.execute(
                art_id,
                ArtifactType.EVIDENCE_GRAPH,
                (src_env.to_ref(),),
                generate_evidence,
                evaluate_evidence_stage,
                section_id=sec_idx,
            )
            evidence_envelopes[sec_idx] = env

        # ── Stage 3: Exam Blueprint ──────────────────────────────────────────
        bp_art_id = f"blueprint:{request.run_id}"
        bp_indices = request.section_indices

        async def generate_blueprint(version: int) -> dict[str, Any]:
            return build_blueprint(
                request.run_id,
                request.topic,
                bp_indices,
                source_envelopes,
                evidence_envelopes,
                request.policy,
            )

        async def evaluate_blueprint_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_blueprint(art, request.policy, bp_indices)

        blueprint_envelope = await executor.execute(
            bp_art_id,
            ArtifactType.EXAM_BLUEPRINT,
            (),
            generate_blueprint,
            evaluate_blueprint_stage,
        )

        # ── Stages 4–6: SectionRunner per selected section ───────────────────
        runner = self._get_runner()

        async def execute_section(sec_idx: int) -> AcceptedSectionArtifact:
            sec_config = request.policy.section(sec_idx)
            sec_source_ref = SourceRef(
                source=source_envelopes[sec_idx],
                evidence=evidence_envelopes[sec_idx],
            )
            return await runner.run(
                context,
                sec_config,
                sec_source_ref,
                blueprint_envelope.to_ref(),
                request.policy,
            )

        if request.parallel and len(request.section_indices) > 1:
            raw_sections = await asyncio.gather(
                *[execute_section(idx) for idx in request.section_indices]
            )
            accepted_sections = sorted(raw_sections, key=lambda s: s.section.section_id or 0)
        else:
            accepted_sections = []
            for sec_idx in sorted(request.section_indices):
                accepted_sections.append(await execute_section(sec_idx))

        # ── Stage 7: Reading Paper Assembly (if all 3 sections present) ─────
        paper_envelope: Optional[ArtifactEnvelope] = None
        if tuple(sorted(request.section_indices)) == (1, 2, 3):
            paper_art_id = f"paper:{request.run_id}"
            section_refs = [s.section.to_ref() for s in accepted_sections]
            passage_refs = [s.passage.to_ref() for s in accepted_sections]
            question_refs = [q.to_ref() for s in accepted_sections for q in s.questions]
            paper_parents = (blueprint_envelope.to_ref(), *section_refs, *passage_refs, *question_refs)

            async def generate_paper(version: int) -> dict[str, Any]:
                return compose_paper_payload(
                    blueprint_envelope.to_ref(),
                    accepted_sections,
                    request.policy,
                )

            async def evaluate_paper_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
                return evaluate_paper(art, request.policy)
            paper_envelope = await executor.execute(
                paper_art_id,
                ArtifactType.READING_PAPER,
                paper_parents,
                generate_paper,
                evaluate_paper_stage,
            )

        # ── Stage 8: CheckpointClient.build_exam (if finalize=True) ──────────
        exam_id: Optional[UUID] = None
        if request.finalize and paper_envelope is not None:
            build_req = BuildExamInternalRequest(
                runId=request.run_id,
                epoch=request.epoch,
                leaseOwner=request.lease_owner,
                jobId=request.job_id,
            )
            build_res = await asyncio.to_thread(self.client.build_exam, build_req)
            exam_id = build_res.examId

        stats = executor.snapshot_stats()
        return PipelineResult(
            runId=request.run_id,
            status="ACCEPTED",
            sections=tuple(s.envelope for s in accepted_sections),
            paper=paper_envelope,
            examId=exam_id,
            metrics={
                "stages_executed": len(request.section_indices),
                "artifacts_reused": stats.artifacts_reused,
                "drafts_persisted": stats.drafts_persisted,
                "acceptances_committed": stats.acceptances_committed,
            },
        )


# ── Backward-Compatibility Adapter Layer for Tests & Legacy Routes ───────────

WORD = re.compile(r"\b[\w'-]+\b")
ANSWER_TOKEN = re.compile(r"\d+(?:[.,]\d+)*(?:%|)?|[^\W\d_]+(?:[-'][^\W\d_]+)*", re.UNICODE)

COUNTS = ((7, 6), (6, 7), (7, 7))
TYPES = (
    ("TRUE_FALSE_NOT_GIVEN", "SENTENCE_COMPLETION"),
    ("MULTIPLE_CHOICE_SINGLE", "SUMMARY_COMPLETION"),
    ("YES_NO_NOT_GIVEN", "SHORT_ANSWER"),
)


def _words(text: str) -> int:
    return len(WORD.findall(text))


def _answer_within_ielts_limit(answer: str) -> bool:
    tokens = ANSWER_TOKEN.findall(answer.strip())
    numbers = [token for token in tokens if token[:1].isdigit()]
    words = [token for token in tokens if not token[:1].isdigit()]
    return bool(tokens) and len(words) <= 3 and len(numbers) <= 1 and len(tokens) <= 4


def _answer_occurs_in_passage(answer: str, passage: str) -> bool:
    return bool(re.search(r"(?<!\w)" + re.escape(answer.strip()) + r"(?!\w)", passage, re.I))


def _attempt_op_id_suffix(payload: str) -> str:
    if not payload:
        return ""
    return f"_{hashlib.sha256(payload.encode('utf-8')).hexdigest()[:8]}"


def validate_passage_content(title: str, passage: str) -> None:
    internal_section_heading = re.compile(r"(?im)^\s*Section\s+[1-3]\s*:\s*.+$")
    if internal_section_heading.search(title) or internal_section_heading.search(passage):
        raise ValueError("Passage contains an internal section label")




async def generate_json(*, progress: ProgressCallback | None = None, **kwargs: Any) -> Any:
    await _progress(
        progress,
        f"LLM request started (JSON={kwargs.get('expect_json', True)}, max tokens={kwargs.get('max_tokens', 'default')})."
    )
    stream_cb = None
    if progress is not None and not kwargs.get("stream_callback"):
        current_tokens: list[str] = []
        word_accumulator = 0

        async def on_token(kind: str, token: str) -> None:
            nonlocal word_accumulator
            if kind != "content":
                return
            current_tokens.append(token)
            word_accumulator += len(WORD.findall(token))
            if "\n\n" in token or word_accumulator >= 35:
                chunk_text = "".join(current_tokens).strip()
                current_tokens.clear()
                word_accumulator = 0
                if chunk_text:
                    preview = chunk_text if len(chunk_text) <= 100 else chunk_text[:97] + "..."
                    await _progress(progress, f"Generated: {preview}")

        stream_cb = on_token

    call_kwargs = dict(kwargs)
    if stream_cb and "stream_callback" not in call_kwargs:
        call_kwargs["stream_callback"] = stream_cb

    try:
        result = await llm_generate(**call_kwargs)
        res_len = len(json.dumps(result, ensure_ascii=False)) if isinstance(result, (dict, list)) else len(str(result))
        await _progress(progress, f"LLM response received ({res_len} characters).")
        return result
    except Exception as exc:
        error = str(exc).lower()
        if "413" in error or "request too large" in error:
            await _progress(progress, f"LLM rejected the request size: {exc}", "Error")
            raise ValueError("LLM request exceeds provider token limit") from exc
        await _progress(progress, f"LLM request failed: {exc}", "Error")
        raise


async def extend_passage(
    passage: str,
    article_content: str,
    topic: str,
    progress: ProgressCallback | None = None,
    *,
    index: int,
    **auth_kwargs: Any,
) -> str:
    base_op_id = auth_kwargs.get("operation_id") or f"op_extend_s{index}"
    for attempt in range(4):
        words = _words(passage)
        if words >= 720:
            break
        await _progress(progress, f"Passage has {words} words; requesting continuation {attempt + 1}/4.")
        requested = min(200, max(50, int((750 - words) * 1.1)))
        call_auth = dict(auth_kwargs)
        call_auth["operation_id"] = base_op_id if attempt == 0 else f"{base_op_id}_{attempt + 1}"
        result = await generate_json(
            prompt_template="{instruction}\n\nSOURCE EXCERPTS:\n{source}\n\nPASSAGE SO FAR:\n{passage}",
            variables={
                "instruction": build_passage_extension_prompt(topic, index, requested),
                "source": source_excerpt(article_content, 8_000),
                "passage": passage[-7_000:],
            },
            expect_json=False,
            max_tokens=3000,
            progress=progress,
            **call_auth,
        )
        addition = str(result.get("text") or result.get("continuation") or "").strip()
        addition = re.sub(r"^(?:(?:Here is the )?continuation:?)\s*", "", addition, flags=re.I).strip()
        if _words(addition) < 25:
            await _progress(progress, "Passage continuation was too short; stopping extension.", "Warning")
            break
        passage += "\n\n" + addition
        await _progress(progress, f"Passage continuation added; current length is {_words(passage)} words.")
    return trim_passage(passage)


def validate_group_candidate(
    kind: str, count: int, first: int, questions: Any, passage: str
) -> None:
    if not isinstance(questions, list) or len(questions) != count:
        raise ValueError(f"Expected {count} separate {kind} question objects")
    passage_norm = " ".join(passage.split()).casefold()
    for offset, question in enumerate(questions):
        number = first + offset
        if not isinstance(question, dict) or question.get("number") != number:
            raise ValueError(f"Question numbers must run from {first} to {first + count - 1}")
        prompt = str(question.get("prompt", ""))
        answer = str(question.get("answer", "")).strip()
        evidence = " ".join(str(question.get("evidenceQuote", "")).split())
        explanation = str(question.get("explanation", ""))
        if not prompt.strip() or not answer or len(explanation) < 25 or len(evidence) < 15:
            raise ValueError(f"Question {number} lacks a grounded prompt, answer or evidence")
        if evidence.casefold() not in passage_norm:
            raise ValueError(f"Question {number} Evidence quote is absent from passage")
        if kind in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE"):
            options = question.get("options")
            expected = (
                ["TRUE", "FALSE", "NOT GIVEN"]
                if kind == "TRUE_FALSE_NOT_GIVEN"
                else ["YES", "NO", "NOT GIVEN"]
                if kind == "YES_NO_NOT_GIVEN"
                else None
            )
            if (
                not isinstance(options, list)
                or len(options) != (4 if expected is None else 3)
                or (
                    answer not in options
                    and not (
                        expected is None
                        and len(answer) == 1
                        and any(str(opt).startswith(f"{answer.upper()}.") for opt in options)
                    )
                )
                or (expected and options != expected)
            ):
                raise ValueError(f"Question {number} has invalid options or answer")
            if expected is None and any(
                not str(option).startswith(f"{letter}.") for letter, option in zip("ABCD", options)
            ):
                raise ValueError(f"Question {number} requires A–D options")
        if kind in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION"):
            if prompt.count(f"[{number}]") != 1 or not _answer_within_ielts_limit(answer):
                raise ValueError(
                    f"Question {number} must have one [{number}] blank and a valid three-word/number answer"
                )
            prompt_without_blank = prompt.replace(f"[{number}]", "", 1)
            if answer.casefold() in " ".join(prompt_without_blank.split()).casefold():
                raise ValueError(f"Question {number} has answer leakage in its completion prompt")
        if kind in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION", "SHORT_ANSWER"):
            if not _answer_within_ielts_limit(answer) or not _answer_occurs_in_passage(answer, passage):
                raise ValueError(f"Question {number} answer must appear in passage")
            if kind == "SHORT_ANSWER" and answer.casefold() in " ".join(prompt.split()).casefold():
                raise ValueError(f"Question {number} has answer leakage in its short-answer prompt")


def _mcq_option_text(question: dict[str, Any]) -> str:
    ans = str(question.get("answer", "")).strip()
    if not ans or ans[0].upper() not in "ABCD" or len(ans) > 1:
        return ""
    options = question.get("options") or []
    if not isinstance(options, list):
        return ""
    prefix = ans.upper() + "."
    for option in options:
        opt = str(option).strip()
        if opt.upper().startswith(prefix):
            return re.sub(r"^[A-D]\.\s*", "", opt, flags=re.IGNORECASE).strip()
        if opt[:2].upper() in {f"{ans.upper()})", f"{ans.upper()}."} and len(opt) > 2:
            return opt[2:].strip()
    idx = ord(ans[0].upper()) - ord("A")
    if 0 <= idx < len(options):
        opt = str(options[idx]).strip()
        return re.sub(r"^[A-D][.)]\s*", "", opt, flags=re.IGNORECASE).strip()
    return ""


def repair_evidence(questions: list[dict[str, Any]], passage: str) -> None:
    normalized_passage = " ".join(passage.split()).casefold()
    sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", passage) if s.strip()]
    sentence_lc = [s.casefold() for s in sentences]

    for question in questions:
        evidence = " ".join(str(question.get("evidenceQuote", "")).split())
        if evidence and evidence.casefold() in normalized_passage:
            question["evidenceQuote"] = evidence
            continue

        ans_text = _mcq_option_text(question)
        if not ans_text:
            ans_text = re.sub(r"^[A-D]\.\s*", "", str(question.get("answer", "")).strip()).strip()
        ans_clean = ans_text.casefold()
        if len(ans_clean) >= 4:
            matched_idx = -1
            for idx, s_lc in enumerate(sentence_lc):
                if ans_clean in s_lc and len(sentences[idx]) >= 15:
                    matched_idx = idx
                    break
            if matched_idx >= 0:
                question["evidenceQuote"] = sentences[matched_idx]
                continue


def validate_section(data: dict[str, Any], index: int) -> dict[str, Any]:
    if index not in (1, 2, 3):
        raise ValueError("Section index must be 1–3")
    passage = str(data.get("passage", "")).strip()
    if not 720 <= _words(passage) <= 915:
        raise ValueError("Passage must contain 720–915 words")
    validate_passage_content(str(data.get("title", "")), passage)
    groups = data.get("groups")
    if not isinstance(groups, list) or len(groups) != 2:
        raise ValueError("Section must have two question groups")
    expected = sum(COUNTS[index - 1])
    seen: set[str] = set()
    number = sum(sum(c) for c in COUNTS[:index - 1]) + 1
    for group_index, group in enumerate(groups):
        if group.get("type") != TYPES[index - 1][group_index]:
            raise ValueError("Wrong question type")
        questions = group.get("questions")
        if not isinstance(questions, list) or len(questions) != COUNTS[index - 1][group_index]:
            raise ValueError("Wrong group question count")
        first = number
        last = first + len(questions) - 1
        if group.get("instruction") != build_group_instruction(group["type"], first, last):
            raise ValueError(f"Question group instruction does not match {group['type']}")
        validate_group_candidate(group["type"], len(questions), first, questions, passage)
        for question in questions:
            if question.get("number") != number:
                raise ValueError("Question numbers must be continuous")
            prompt = str(question.get("prompt", "")).strip()
            key = re.sub(r"\W+", "", prompt.casefold())
            if key in seen:
                raise ValueError("Duplicate question")
            seen.add(key)
            number += 1
    if number != sum(sum(c) for c in COUNTS[:index - 1]) + expected + 1:
        raise ValueError("Wrong section question count")
    return data


SOURCE_REVIEW_ISSUES = {
    "unsupported_claim",
    "contradicted_claim",
    "causal_overstatement",
    "overstated_certainty",
    "unmeasured_outcome",
    "population_or_method_mismatch",
}


def _normalize_source_review_issue(issue: str) -> str:
    cleaned = issue.strip().lower().replace(" ", "_").rstrip(".")
    if cleaned.endswith("s") and cleaned[:-1] in SOURCE_REVIEW_ISSUES:
        return cleaned[:-1]
    if cleaned in SOURCE_REVIEW_ISSUES:
        return cleaned
    mapping = {
        "unsupported": "unsupported_claim",
        "unsupported_claims": "unsupported_claim",
        "contradicted": "contradicted_claim",
        "contradicted_claims": "contradicted_claim",
        "causation": "causal_overstatement",
        "overstatement": "causal_overstatement",
        "certainty": "overstated_certainty",
        "unmeasured": "unmeasured_outcome",
        "population_mismatch": "population_or_method_mismatch",
        "method_mismatch": "population_or_method_mismatch",
    }
    return mapping.get(cleaned, issue)


async def review_passage_source(
    source_text: str, passage: str, progress: ProgressCallback | None = None, **auth_kwargs: Any
) -> list[dict[str, str]]:
    await _progress(progress, "Source-fidelity review started.")
    review = await generate_json(
        prompt_template="{instruction}\n\nSOURCE EXCERPTS:\n{source}\n\nGENERATED PASSAGE:\n{passage}",
        variables={
            "instruction": (
                "Check the generated passage against the supplied source. Verify whether the passage is reasonably faithful to the source's findings, mechanisms, and factual content. "
                "Never turn correlation into causation. Never include outcomes the source did not measure. "
                "Return JSON {\"passed\":boolean,\"findings\":[{\"claimQuote\":string,\"issue\":string,\"reason\":string}]}."
            ),
            "source": source_excerpt(source_text, 14_000),
            "passage": passage,
        },
        expect_json=True,
        temperature=0.1,
        max_tokens=5000,
        progress=progress,
        **auth_kwargs,
    )
    if (
        not isinstance(review, dict)
        or type(review.get("passed")) is not bool
        or not isinstance(review.get("findings"), list)
    ):
        raise ValueError("Source-fidelity review returned malformed output")
    findings = review["findings"]
    for finding in findings:
        if isinstance(finding, dict) and isinstance(finding.get("issue"), str):
            finding["issue"] = _normalize_source_review_issue(finding["issue"])
        if (
            not isinstance(finding, dict)
            or not str(finding.get("claimQuote", "")).strip()
            or finding.get("issue") not in SOURCE_REVIEW_ISSUES
            or not str(finding.get("reason", "")).strip()
        ):
            raise ValueError("Source-fidelity review returned a malformed finding")
    if review["passed"] != (len(findings) == 0):
        raise ValueError("Source-fidelity review result conflicts with its findings")
    return findings


QUESTION_REVIEW_ISSUES = {
    "unsupported",
    "contradicted",
    "not_given_misused",
    "ambiguous",
    "duplicate",
    "type_mismatch",
    "wrong_answer",
    "explanation_mismatch",
    "answer_leakage",
    "multiple_correct_options",
    "word_limit",
    "invalid_evidence",
    "too_direct",
}


async def review_answers(
    passage: str, groups: list[dict[str, Any]], progress: ProgressCallback | None = None, **auth_kwargs: Any
) -> dict[int, dict[str, Any]]:
    await _progress(progress, "Independent answer review started.")
    review = await generate_json(
        prompt_template="{instruction}\n\n{payload}",
        variables={
            "instruction": (
                "Review every question independently against ONLY the passage. "
                "Check for answer leakage, multiple correct options, and ensure connected summary in order. "
                "Do not rely solely on direct phrase lookups without interpretation (flag as too_direct). "
                "Return JSON {\"reviews\":[{\"number\":integer,\"valid\":boolean,\"issues\":[issue_code],\"reason\":string}]}."
            ),
            "payload": json.dumps({"passage": passage, "groups": groups}, ensure_ascii=False),
        },
        expect_json=True,
        temperature=0.1,
        max_tokens=2800,
        progress=progress,
        **auth_kwargs,
    )
    raw = review.get("reviews") if isinstance(review, dict) else None
    expected = [question["number"] for group in groups for question in group["questions"]]
    if not isinstance(raw, list) or len(raw) != len(expected):
        raise ValueError("Independent answer review must return one verdict for every question")
    parsed: dict[int, dict[str, Any]] = {}
    for item in raw:
        if (
            not isinstance(item, dict)
            or type(item.get("number")) is not int
            or type(item.get("valid")) is not bool
        ):
            raise ValueError("Independent answer review returned a malformed question verdict")
        number = item["number"]
        issues = item.get("issues")
        reason = item.get("reason")
        if (
            number not in expected
            or number in parsed
            or not isinstance(issues, list)
            or not all(isinstance(issue, str) and issue in QUESTION_REVIEW_ISSUES for issue in issues)
            or not isinstance(reason, str)
            or (item["valid"] and issues)
            or (not item["valid"] and (not issues or not reason.strip()))
        ):
            raise ValueError("Independent answer review returned an invalid question verdict")
        parsed[number] = {
            "number": number,
            "valid": item["valid"],
            "issues": issues,
            "reason": reason.strip()[:400],
        }
    if set(parsed) != set(expected):
        raise ValueError("Independent answer review must cover every question")
    return parsed


async def replace_rejected_question(
    passage: str,
    groups: list[dict[str, Any]],
    number: int,
    progress: ProgressCallback | None = None,
    **auth_kwargs: Any,
) -> None:
    for group in groups:
        for offset, old in enumerate(group["questions"]):
            if old["number"] != number:
                continue
            kind = group["type"]
            other_prompts = [
                q["prompt"] for g in groups for q in g.get("questions", []) if q.get("number") != number
            ]
            existing_keys = {
                re.sub(r"\W+", "", str(p).casefold())
                for p in other_prompts if p
            }
            last_exc = None
            for rep_attempt in range(3):
                instruction = build_question_prompt(kind, 1, number, number, replacement=True)
                instruction += " Do not duplicate any of these prompts from other questions: " + json.dumps(
                    other_prompts, ensure_ascii=False
                )
                base_op_id = auth_kwargs.get("operation_id") or f"replace_q{number}"
                attempt_auth = dict(auth_kwargs)
                attempt_auth["operation_id"] = f"{base_op_id}_att{rep_attempt + 1}_{uuid4().hex[:6]}"
                try:
                    result = await generate_json(
                        prompt_template="{instruction}\n\nPASSAGE:\n{passage}",
                        variables={"instruction": instruction, "passage": passage},
                        expect_json=True,
                        max_tokens=1700,
                        temperature=0.7,
                        progress=progress,
                        **attempt_auth,
                    )
                except Exception as gen_err:
                    last_exc = f"Model returned invalid JSON syntax: {gen_err}"
                    continue
                if isinstance(result, list) and result:
                    replacement = result[0]
                elif isinstance(result, dict):
                    replacement = result.get("question") or result.get("questions", [None])[0]
                else:
                    replacement = None
                if not isinstance(replacement, dict):
                    last_exc = "Replacement question is malformed"
                    continue
                rep_key = re.sub(r"\W+", "", str(replacement.get("prompt", "")).casefold())
                if rep_key in existing_keys:
                    last_exc = f"Replacement duplicated an existing question prompt: {replacement.get('prompt')}"
                    continue
                repair_evidence([replacement], passage)
                try:
                    validate_group_candidate(kind, 1, number, [replacement], passage)
                    group["questions"][offset] = replacement
                    return
                except ValueError as err:
                    last_exc = str(err)
            raise ValueError(f"Failed to generate valid replacement for question {number} after 3 attempts: {last_exc}")
    raise ValueError(f"Question {number} is absent from section")

