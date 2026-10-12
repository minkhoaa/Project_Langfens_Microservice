"""Legacy Four-phase autonomous pipeline for IELTS Academic Reading paper generation.

DEPRECATION NOTICE (Phase 15 Cutover & Legacy Deletion):
Canonical V2 generation is executed via `app.loop.section.SectionLoop` orchestrated by
`GenerationFacade.generate_section_v2`. This module is retained as a living adapter
and backward-compatibility layer for existing tests and legacy consumers.
"""
from __future__ import annotations

import asyncio
import hashlib
import json
import logging
import re
from typing import Any, Awaitable, Callable
from uuid import UUID, uuid4

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

logger = logging.getLogger(__name__)

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
    """Return a deterministic hash suffix for operation IDs derived from the complete prompt payload."""
    if not payload:
        return ""
    return f"_{hashlib.sha256(payload.encode('utf-8')).hexdigest()[:8]}"


def validate_passage_content(title: str, passage: str) -> None:
    internal_section_heading = re.compile(r"(?im)^\s*Section\s+[1-3]\s*:\s*.+$")
    if internal_section_heading.search(title) or internal_section_heading.search(passage):
        raise ValueError("Passage contains an internal section label")


def trim_passage(passage: str) -> str:
    if _words(passage) <= 900:
        return passage
    for boundary in reversed([m.end() for m in re.finditer(r"[.!?](?=\s|$)", passage)]):
        trimmed = passage[:boundary].strip()
        if 720 <= _words(trimmed) <= 900:
            return trimmed
    return passage


async def generate_json(*, progress: ProgressCallback | None = None, **kwargs: Any) -> Any:
    """Generate LLM output with optional real-time streaming progress logs.

    Transport-level retries and rate limit backoffs are handled authoritatively
    by the provider gateway; no independent retry loop in the generator.
    """
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
    """Add source-grounded paragraphs when a model under-delivers the word target."""
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


_STOPWORDS = frozenset({
    "a", "an", "the", "and", "or", "but", "of", "in", "on", "at", "to", "for",
    "with", "by", "from", "as", "is", "are", "was", "were", "be", "been",
    "being", "have", "has", "had", "do", "does", "did", "this", "that",
    "these", "those", "it", "its", "they", "them", "their", "we", "us",
    "our", "you", "your", "he", "she", "his", "her", "i", "me", "my",
    "not", "no", "so", "if", "than", "then", "also", "such", "which",
    "what", "when", "where", "while", "who", "whom", "whose", "why", "how",
    "can", "could", "may", "might", "must", "shall", "should", "will",
    "would", "about", "into", "over", "under", "between", "among", "very",
})


def _significant_words(text: str) -> set[str]:
    return {tok.casefold() for tok in WORD.findall(text) if len(tok) >= 3 and tok.casefold() not in _STOPWORDS}


def _mcq_option_text(question: dict[str, Any]) -> str:
    """Return the option text matching the MCQ answer (A/B/C/D) or an empty string."""
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
    """Normalize quote whitespace and locate verbatim passage sentence if evidence quote drifts.

    Search strategy per question (fail-closed):
      1. If the (whitespace-normalized) evidence quote is already an exact substring in the
         passage, use it.
      2. For MCQ: resolve letter (e.g. "A", "B", "C", "D") to its corresponding option text from
         question.get("options"). Locate the exact verbatim passage sentence that contains the
         option text / answer text (length >= 4).
      3. Do NOT use arbitrary token overlap that could attach an unrelated sentence. If no
         defensible passage span contains the option text or evidence, leave it untouched for
         validate_group_candidate to reject and regenerate (fail-closed).
    """
    normalized_passage = " ".join(passage.split()).casefold()
    sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", passage) if s.strip()]
    sentence_lc = [s.casefold() for s in sentences]

    for question in questions:
        evidence = " ".join(str(question.get("evidenceQuote", "")).split())
        if evidence and evidence.casefold() in normalized_passage:
            question["evidenceQuote"] = evidence
            continue

        # Step 2: derive candidate answer text — first from MCQ option lookup, else from raw answer.
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

        # Step 3: If no defensible passage span contains option text or evidence, leave untouched.
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
                "Standard academic paraphrasing, contextual framing, domain background, and summary descriptions of documented trends are valid and must NOT be flagged. "
                "If the passage is broadly faithful, accurate, and consistent with the source text, return passed: true and findings: []. "
                "Flag ONLY genuine, unambiguous factual contradictions (contradicted_claim) or completely fabricated, false data/entities with zero basis in the source (unsupported_claim). "
                "Never turn correlation into causation. Never include outcomes the source did not measure. "
                "Return ONLY a single valid JSON object. Do not include any markdown fences, explanations, headers, or commentary before or after the JSON: "
                "{\"passed\":boolean,\"findings\":[{\"claimQuote\":string,\"issue\":string,\"reason\":string}]}. "
                "Use issue codes from: unsupported_claim, contradicted_claim, causal_overstatement, overstated_certainty, unmeasured_outcome, population_or_method_mismatch."
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
    if findings:
        await _progress(
            progress,
            f"Source-fidelity review found {len(findings)} issue(s): "
            + "; ".join(f"{item['issue']}: {item['reason'][:240]}" for item in findings),
            "Warning",
        )
    else:
        await _progress(
            progress, "Source-fidelity review passed; no unsupported or overstated claims found."
        )
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
                "Review every question independently against ONLY the passage and its group instruction. "
                "Assess each group as a set for IELTS Academic Reading fit: items should require useful "
                "paraphrase, inference, or interpretation of relationships, rather than all being direct phrase "
                "lookups. If nearly all items in a group can be answered by copying a nearby phrase without "
                "interpreting it, mark the overly direct items with too_direct. A direct fact can still be valid "
                "when the question requires interpreting or matching its meaning. For completion questions "
                "(SENTENCE_COMPLETION, SUMMARY_COMPLETION, SHORT_ANSWER), the answer must be copied verbatim from the passage; "
                "do not mark completion items as too_direct for containing verbatim passage words. Do not add outside knowledge. "
                "For TRUE/FALSE/NOT GIVEN, TRUE is supported, FALSE is contradicted, and NOT GIVEN is neither "
                "stated nor contradicted; related facts and outside knowledge do not prove a statement. For "
                "YES/NO/NOT GIVEN, judge only the writer's view or claim. Check that the answer is correct and "
                "unique, the exact evidence supports the whole answer, the explanation matches that evidence, "
                "the type and instruction are followed, the answer is not leaked in the prompt, and no multiple "
                "choice has multiple correct options or more than one plausible correct option. Check for answer "
                "leakage. For SUMMARY_COMPLETION, check that the prompts form a connected summary in question "
                "number order. Reject ambiguous, unsupported, duplicate or over-limit items. Return JSON "
                "{\"reviews\":[{\"number\":integer,\"valid\":boolean,"
                "\"issues\":[issue_code],\"reason\":string}]}; give one entry for every question. Allowed "
                "issue codes: unsupported, contradicted, not_given_misused, ambiguous, duplicate, type_mismatch, "
                "wrong_answer, explanation_mismatch, answer_leakage, multiple_correct_options, word_limit, "
                "invalid_evidence, too_direct. A valid item has no issues. An invalid item has at least one issue and a concise "
                "reason. Do not provide internal reasoning."
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
    await _progress(
        progress,
        f"Independent answer review completed: {sum(item['valid'] for item in parsed.values())}/{len(parsed)} passed.",
    )
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
            old_prompt = str(old.get("prompt", "")).strip()
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
                if last_exc is not None:
                    instruction += f" Ensure the question is unique and covers a distinct fact in the passage from previous attempts: {last_exc}."
                await _progress(
                    progress,
                    f"Replacing question {number} after validation or answer review rejection (attempt {rep_attempt + 1}/3).",
                    "Warning",
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
                    await _progress(progress, f"Question {number} replacement passed validation.")
                    return
                except ValueError as err:
                    last_exc = str(err)
            raise ValueError(f"Failed to generate valid replacement for question {number} after 3 attempts: {last_exc}")
    raise ValueError(f"Question {number} is absent from section")


async def _generate_section_once(
    topic: str,
    index: int,
    source: dict[str, Any],
    progress: ProgressCallback | None = None,
    *,
    run_id: str,
    epoch: int = 1,
    lease_owner: UUID,
    parent_operation_id: str,
    provider: str | None = None,
    section_attempt: int = 1,
) -> dict[str, Any]:
    if index not in (1, 2, 3):
        raise ValueError("Section index must be 1–3")
    # `parent_operation_id` is the granted section operation. It must always be
    # forwarded verbatim so the checkpoint service accepts child operations.
    # On outer retries, encode the attempt number into a derived prefix that is
    # used ONLY for child operation_ids (not the parent_operation_id itself).
    parent_op_prefix = (
        parent_operation_id
        if section_attempt <= 1
        else f"{parent_operation_id}_sec_att_{section_attempt}"
    )
    if (
        "content" in source
        and isinstance(source["content"], str)
        and len(WORD.findall(source["content"])) >= 600
    ):
        source_title = source.get("title") or topic
        source_id = source.get("sourceId") or source.get("pmcid") or f"SRC_{index}"
        await _progress(progress, f"Passage {index}: using pre-ingested source '{source_title}'.")
        article = {
            "pmcid": source_id,
            "sourceId": source_id,
            "sourceType": source.get("sourceType", "custom"),
            "title": source_title,
            "authors": source.get("authors") or "",
            "doi": source.get("doi") or None,
            "url": source.get("url") or "",
            "license": source.get("license") or "User Provided",
            "wordCount": len(WORD.findall(source["content"])),
            "content": source["content"][:70_000],
        }
    else:
        pmcid = str(source.get("pmcid") or source.get("sourceId") or "").strip()
        await _progress(progress, f"Passage {index}: fetching and verifying source {pmcid}.")
        article = await fetch_source(pmcid, progress)
        if (
            source.get("doi")
            and article.get("doi")
            and source["doi"].casefold() != article["doi"].casefold()
        ):
            raise SourceError("Source DOI changed")
        if source.get("license") and source["license"] != article["license"]:
            raise SourceError("Source license changed")

    await _progress(
        progress,
        f"Source verified: {article['title']} ({article['wordCount']} source words; {article['license']}).",
    )

    # ── Phase 1: Passage Synthesis ─────────────────────────────────────────────
    await _progress(progress, f"Passage {index}: generating a source-grounded reading passage.")
    section_id = f"section_{index}"
    passage_art_id = f"passage_{section_id}"
    review_art_id = f"review_{section_id}"
    questions_art_id = f"questions_{section_id}"
    solver_art_id = f"solver_{section_id}"

    base_auth = {
        "run_id": run_id,
        "epoch": epoch,
        "lease_owner": lease_owner,
        "parent_operation_id": parent_operation_id,
        "provider": provider,
    }

    passage_result = await generate_json(
        prompt_template="{instruction}\n\n{source}",
        variables={
            "instruction": build_passage_prompt(topic, index, article["title"]),
            "source": source_excerpt(article["content"], 12_000),
        },
        expect_json=False,
        max_tokens=3200,
        progress=progress,
        section_id=section_id,
        artifact_id=passage_art_id,
        operation_id=f"{parent_op_prefix}_synthesis",
        **base_auth,
    )
    if isinstance(passage_result, dict) and "passage" in passage_result:
        passage = str(passage_result.get("passage", "")).strip()
        title = str(passage_result.get("title", "")).strip()
    else:
        raw = str(passage_result.get("text", "") if isinstance(passage_result, dict) else passage_result).strip()
        first, _, remaining = raw.partition("\n")
        first_clean = first.strip("# *\t ")[:180]
        remaining_clean = remaining.strip()
        if remaining_clean and 1 <= _words(first_clean) <= 30:
            title = first_clean
            passage = remaining_clean
        elif remaining_clean:
            title = article["title"][:180]
            passage = raw
        else:
            title = article["title"][:180]
            passage = raw

    if not title:
        title = article["title"][:180]
    if title and 50 <= _words(passage) < 720:
        passage = await extend_passage(
            passage, article["content"], topic, progress, index=index,
            section_id=section_id, artifact_id=passage_art_id,
            operation_id=f"{parent_op_prefix}_extend",
            **base_auth,
        )
    passage = trim_passage(passage)
    if not title or not 720 <= _words(passage) <= 915:
        await _progress(
            progress,
            f"Generated passage failed title or word-count validation ({_words(passage)} words).",
            "Error",
        )
        raise ValueError(
            f"Passage generation returned an invalid title or {_words(passage)} words"
        )
    validate_passage_content(title, passage)

    # ── Phase 2: Source-Fidelity Audit & Revision Loop (max 2 rounds) ──────────
    findings = await review_passage_source(
        article["content"], passage, progress,
        section_id=section_id, artifact_id=review_art_id,
        operation_id=f"{parent_op_prefix}_audit",
        **base_auth,
    )
    revision_round = 0
    while findings and revision_round < 2:
        revision_round += 1
        await _progress(
            progress,
            f"Revising source-fidelity findings (round {revision_round}/2) before generating questions.",
            "Warning",
        )
        revised = await generate_json(
            prompt_template="{instruction}\n\nSOURCE EXCERPTS:\n{source}\n\nPASSAGE TO REVISE:\n{passage}\n\nREVIEW FINDINGS:\n{findings}",
            variables={
                "instruction": build_passage_revision_prompt(topic, index),
                "source": source_excerpt(article["content"], 14_000),
                "passage": passage,
                "findings": json.dumps(findings, ensure_ascii=False),
            },
            expect_json=False,
            max_tokens=3400,
            progress=progress,
            section_id=section_id,
            artifact_id=passage_art_id,
            operation_id=f"{parent_op_prefix}_revision_{revision_round}",
            **base_auth,
        )
        revised_raw = str(revised.get("text") or revised.get("passage") or "").strip()
        revised_title, _, revised_passage = revised_raw.partition("\n")
        first_clean = revised_title.strip("# *\t ")[:180]
        remaining_clean = revised_passage.strip()
        if remaining_clean and 1 <= _words(first_clean) <= 30:
            title = first_clean
            passage = trim_passage(remaining_clean)
        else:
            title = first_clean or title
            passage = trim_passage(remaining_clean or revised_raw)
        if not title:
            title = article["title"][:180]
        if title and 50 <= _words(passage) < 720:
            passage = await extend_passage(
                passage, article["content"], topic, progress, index=index,
                section_id=section_id, artifact_id=passage_art_id,
                operation_id=f"{parent_op_prefix}_extend_rev" if revision_round == 1 else f"{parent_op_prefix}_extend_rev_{revision_round}",
                **base_auth,
            )
        passage = trim_passage(passage)
        findings = await review_passage_source(
            article["content"], passage, progress,
            section_id=section_id, artifact_id=review_art_id,
            operation_id=f"{parent_op_prefix}_audit_rev_{revision_round}",
            **base_auth,
        )

    if findings:
        details = "; ".join(f"{item['issue']}: {item['reason'][:180]}" for item in findings)
        raise ValueError(f"Source-fidelity review rejected the revised passage: {details}")
    await _progress(progress, f"Passage accepted: '{title}' ({_words(passage)} words).")

    # ── Phase 3: Question Group Generation (defensive extraction) ─────────────
    groups = []
    start = sum(sum(c) for c in COUNTS[:index - 1]) + 1
    for group_index, (kind, count) in enumerate(zip(TYPES[index - 1], COUNTS[index - 1])):
        first = start + sum(COUNTS[index - 1][:group_index])
        last = first + count - 1
        instruction = build_question_prompt(kind, count, first, last)
        feedback = ""
        for attempt in range(3):
            await _progress(
                progress,
                f"Generating question group {group_index + 1}/2: {kind}, questions {first}–{last}, attempt {attempt + 1}/3.",
            )
            op_suffix = _attempt_op_id_suffix(f"{instruction + feedback}\n\nPASSAGE:\n{passage}")
            try:
                result = await generate_json(
                    prompt_template="{instruction}\n\nPASSAGE:\n{passage}",
                    variables={"instruction": instruction + feedback, "passage": passage},
                    expect_json=True,
                    max_tokens=5000,
                    progress=progress,
                    section_id=section_id,
                    artifact_id=questions_art_id,
                    operation_id=f"{parent_op_prefix}_group_{group_index + 1}_att_{attempt + 1}{op_suffix}",
                    **base_auth,
                )

                # Defensive extraction: handle bare list, items/questions wrapper, or single item dict
                if isinstance(result, list):
                    questions = result
                elif isinstance(result, dict):
                    questions = (
                        result.get("questions")
                        or result.get("items")
                        or result.get("data")
                        or []
                    )
                    if not questions and ("prompt" in result or "number" in result):
                        questions = [result]
                else:
                    questions = []

                if not isinstance(questions, list):
                    raise ValueError(
                        f"Model returned invalid question shape for group {kind}: {type(result)}"
                    )

                repair_evidence([q for q in questions if isinstance(q, dict)], passage)
                if not questions:
                    raise ValueError(
                        f"Model returned empty or invalid questions list for group {kind}"
                    )
                for pre_attempt in range(3):
                    try:
                        validate_group_candidate(kind, count, first, questions, passage)
                        break
                    except ValueError as candidate_error:
                        match = re.search(r"Question (\d+)", str(candidate_error))
                        if match is None or not isinstance(questions, list):
                            raise
                        number = int(match.group(1))
                        if not first <= number <= last:
                            raise
                        await replace_rejected_question(
                            passage,
                            groups + [{"type": kind, "questions": questions}],
                            number,
                            progress,
                            section_id=section_id,
                            artifact_id=questions_art_id,
                            operation_id=f"{parent_op_prefix}_replace_q{number}_pre_att_{attempt + 1}_{pre_attempt + 1}",
                            **base_auth,
                        )
                validate_group_candidate(kind, count, first, questions, passage)
                await _progress(progress, f"Question group {kind} passed validation.")
                break
            except Exception as exc:
                if attempt == 2:
                    raise
                feedback = f" Previous output was invalid: {exc}. Correct this in the next output."
                await _progress(
                    progress,
                    f"Question group {kind} failed validation: {exc}. Asking the model to correct it.",
                    "Warning",
                )
        groups.append(
            {
                "type": kind,
                "instruction": build_group_instruction(kind, first, last),
                "questions": questions,
            }
        )

    await _progress(
        progress, "Checking section question numbering, evidence, answers and passage rules."
    )
    section = validate_section(
        {
            "title": title,
            "passage": passage,
            "source": {key: value for key, value in article.items() if key != "content"},
            "groups": groups,
        },
        index,
    )
    await _progress(progress, "Section structure and question validation passed.")

    # ── Phase 4: Independent Answer Review & Surgical Replacement ──────────────
    expected_numbers = list(range(start, start + sum(COUNTS[index - 1])))
    reviews = await review_answers(
        passage, groups, progress,
        section_id=section_id, artifact_id=solver_art_id,
        operation_id=f"{parent_op_prefix}_solver",
        **base_auth,
    )
    missing = sorted(number for number in expected_numbers if not reviews[number]["valid"])
    if missing:
        for number in missing:
            review = reviews[number]
            await _progress(
                progress,
                f"Independent review rejected Q{number}: {', '.join(review['issues'])}. {review['reason']}",
                "Warning",
            )
    if missing:
        for number in missing:
            await replace_rejected_question(
                passage, groups, number, progress,
                section_id=section_id, artifact_id=questions_art_id,
                operation_id=f"{parent_op_prefix}_replace_q{number}_post",
                **base_auth,
            )
        validate_section(section, index)
        await _progress(
            progress, "Rechecking the repaired questions with the independent reviewer."
        )
        reviews = await review_answers(
            passage, groups, progress,
            section_id=section_id, artifact_id=solver_art_id,
            operation_id=f"{parent_op_prefix}_solver_recheck",
            **base_auth,
        )

    missing = sorted(number for number in expected_numbers if not reviews[number]["valid"])
    if missing:
        for number in missing:
            review = reviews[number]
            await _progress(
                progress,
                f"Independent review still rejects Q{number}: {', '.join(review['issues'])}. {review['reason']}",
                "Error",
            )
        raise ValueError(f"Independent answer review rejected questions {missing}")

    await _progress(
        progress,
        f"Passage {index} completed: {len(expected_numbers)} questions passed independent review.",
    )
    return section


async def generate_section(
    topic: str,
    index: int,
    source: dict[str, Any],
    progress: ProgressCallback | None = None,
    provider: str | None = None,
    *,
    run_id: str,
    epoch: int = 1,
    lease_owner: UUID,
    parent_operation_id: str,
) -> dict[str, Any]:
    """Retry malformed model output once before the durable job records a failure."""
    for attempt in range(2):
        await _progress(progress, f"Passage {index} generation attempt {attempt + 1}/2 started.")
        try:
            return await _generate_section_once(
                topic,
                index,
                source,
                progress,
                provider=provider,
                run_id=run_id,
                epoch=epoch,
                lease_owner=lease_owner,
                parent_operation_id=parent_operation_id,
                section_attempt=attempt + 1,
            )
        except SourceError:
            raise
        except ValueError as exc:
            await _progress(
                progress, f"Passage {index} generation attempt failed validation: {exc}", "Warning"
            )
            if attempt == 1:
                raise
    raise AssertionError("unreachable")
