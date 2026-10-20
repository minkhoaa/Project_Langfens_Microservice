"""Autonomous IELTS Academic Reading Passage Generator (P08-01, P08-03).

Executes generation strictly through the ProviderGateway with budget accounting,
untrusted data encapsulation, and schema validation.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Any, Dict, List, Optional, Sequence, Set
from uuid import UUID, uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, compute_content_hash
from app.contracts.policies import (
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    count_words,
)
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.prompts import (
    PASSAGE_PROMPT_VERSION,
    build_passage_generation_prompt,
)
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.gateway import ProviderGateway
from app.providers.parser import parse_defensive_json
logger = logging.getLogger(__name__)

def _merge_duplicate_keys_hook(pairs: List[tuple]) -> Dict[str, Any]:
    """Preserves multi-paragraph strings when an LLM emits duplicate 'passage' keys in a JSON object."""
    result: Dict[str, Any] = {}
    for k, v in pairs:
        if k in result:
            prev = result[k]
            if k in ("passage", "passageText", "summaryText") and isinstance(prev, str) and isinstance(v, str):
                prev_s = prev.strip()
                next_s = v.strip()
                if next_s and next_s != prev_s:
                    result[k] = f"{prev_s}\n\n{next_s}" if prev_s else next_s
                continue
            if k in ("candidates", "blanks", "questions") and isinstance(prev, list) and isinstance(v, list):
                result[k] = prev + v
                continue
        result[k] = v
    return result


def _merge_duplicate_passage_keys(raw_text: str) -> str:
    """Pre-processes raw LLM JSON text when duplicate 'passage' keys are present."""
    if not raw_text or len(re.findall(r'"(?:passage|passageText|summaryText)"\s*:', raw_text)) < 2:
        return raw_text
    fenced = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", raw_text)
    candidate = fenced.group(1).strip() if fenced else raw_text.strip()
    first_brace = candidate.find("{")
    last_brace = candidate.rfind("}")
    if first_brace != -1 and last_brace > first_brace:
        candidate = candidate[first_brace : last_brace + 1]
    try:
        decoder = json.JSONDecoder(object_pairs_hook=_merge_duplicate_keys_hook, strict=False)
        merged_obj, _ = decoder.raw_decode(candidate)
        if isinstance(merged_obj, dict):
            return json.dumps(merged_obj, ensure_ascii=False)
    except Exception:
        pass
    return raw_text


# A quantity is a *standalone* numeric literal -- "40 samples", "in 1999", "12%".
# It is never a digit run embedded in an identifier ("academicword42", "H1N1",
# "Fig2a", "S2"), so the boundaries are non-alphanumeric on both sides rather
# than merely non-digit.
#
# A period is a continuation character ONLY when a digit follows it (a decimal such
# as "3.5", or a figure reference like "Fig.2"). A sentence-final period is not a
# continuation: "collected in 2005." must still yield 2005. Treating every period
# as a continuation silently dropped every quantity at the end of a sentence, which
# both missed invented quantities written that way and -- worse -- reported a
# passage quantity as invented merely because the SOURCE stated it at a sentence
# end. The right boundary is therefore `\w` or `.\d`; the left boundary keeps `.`
# so the "5" of "3.5" and the "2" of "Fig.2" are not read as standalone tokens.
_QUANTITY_TOKEN_PATTERN = re.compile(
    r"(?<![\w.])(\d{2,4})(?!\w|\.\d)"
)


def _extract_numeric_tokens(text: str) -> List[str]:
    """Return every standalone numeric token (>=2 digits, including 4-digit years).

    General, deterministic helper used by the passage quantity guard. Words like
    "one", "two", "first", "twenty" are NOT captured -- the prompt's rule 6
    forbids invented *quantities*, and the campaign failure mode (1999 in a
    passage whose source never mentioned 1999) is digit-shaped, not word-shaped.
    """
    if not text:
        return []
    return _QUANTITY_TOKEN_PATTERN.findall(text)


def _find_invented_quantities(source_text: str, passage_text: str) -> List[str]:
    """Return passage numeric tokens whose digit string is absent from source tokens.

    Implementation note: matches on the digit-only form (e.g. "1999" -> "1999",
    "20%" -> "20") so formatting differences ("10 percent" vs "10%") do not
    produce false positives. A token is "invented" when no source token yields
    the same digit-only string. Order is stable, deterministic, and not keyed
    on case index, seed, or question number -- this is a general source-vs-passage
    grounding invariant.
    """
    if not passage_text:
        return []
    src_digits = {tok for tok in _extract_numeric_tokens(source_text or "")}
    src_digits_norm = {re.sub(r"\D", "", t) for t in src_digits}
    offending: List[str] = []
    seen: Set[str] = set()
    for tok in _extract_numeric_tokens(passage_text):
        digits = re.sub(r"\D", "", tok)
        if not digits or len(digits) < 2:
            continue
        if digits not in src_digits_norm:
            if digits not in seen:
                seen.add(digits)
                offending.append(tok)
    return offending


def _build_quantity_guard_feedback(offending_tokens: List[str]) -> str:
    """Construct the user-prompt feedback appended when the quantity guard fires."""
    rendered = ", ".join(f"'{t}'" for t in offending_tokens)
    return (
        "GROUNDING GUARD: Your previous draft contained numeric tokens "
        f"({rendered}) that do NOT appear in the verified source material. "
        "Rewrite so every number, percentage, and calendar year in the passage "
        "appears verbatim in <source_material>. Do not paraphrase, approximate, "
        "or substitute related values. If a quantity is not in the source, omit "
        "the claim that requires it."
    )


# The guard re-asks the model at most this many times per artifact draft. This is
# a *generator-internal* bound and deliberately tiny: it is not one of the
# loop policy caps (max_versions / max_generated_versions / max_total_repairs),
# and it must never grow into a de-facto version budget. One grounded re-ask is
# enough to give the model a second chance with the exact offending tokens named.
QUANTITY_GUARD_MAX_RETRIES = 1


# Same posture, same size, same reason: the length band is a prompt-stated
# invariant the generator must therefore enforce at generation time. Keeping the
# bound at 1 keeps the guard from becoming a de-facto version budget. It is NOT a
# loop policy cap.
WORD_COUNT_GUARD_MAX_RETRIES = 1


def _measure_passage_words(passage_text: Optional[str]) -> int:
    """Return the passage length using the *canonical validator* counting rule.

    This is a thin alias over `count_words` from `app.contracts.policies` -- the
    same function the deterministic evaluators and validators use to decide
    SECTION_WORD_COUNT_OUT_OF_BOUNDS. It deliberately introduces no second
    counting rule: a private tokenizer here could disagree with the validator at
    a boundary and silently move the band (accepting a draft the validator then
    rejects, or refusing one it would have accepted). The alias exists so the
    rule the guard enforces is greppable and nameable, not so it can differ.
    """
    return count_words(passage_text or "")


def _build_word_count_guard_feedback(
    measured_words: int,
    band_min: int,
    band_max: int,
) -> str:
    """Construct the user-prompt feedback appended when the word-count guard fires.

    Names the *actual* measured count and the exact deficit or overshoot, so the
    re-ask is a precise instruction rather than a bare restatement of the prompt.
    The directive is always "regenerate at the right length from the source" --
    never truncate and never pad, both of which would be synthesis.
    """
    if measured_words < band_min:
        shape = (
            f"your draft is {measured_words} words; you need at least {band_min} "
            f"(deficit: {band_min - measured_words} words). Extend with source-grounded "
            "detail drawn only from <source_material>"
        )
    else:
        shape = (
            f"your draft is {measured_words} words; the ceiling is {band_max} "
            f"(overshoot: {measured_words - band_max} words). Tighten the prose without "
            "dropping any source-grounded claim, qualifier, or uncertainty"
        )
    return (
        "LENGTH GUARD: The previous draft violated the mandatory passage length "
        f"invariant -- {shape}. Rewrite so the total is strictly between {band_min} "
        f"and {band_max} words. Do NOT pad with filler or invent content, and do NOT "
        "clip sentences; develop or compress only what the verified source supports."
    )


class PassageGenerator:
    """Generates IELTS Academic reading passages with strict source grounding."""

    def __init__(self, gateway: ProviderGateway):
        self.gateway = gateway
        self._last_attempt_word_count: Optional[int] = None

    @staticmethod
    def _build_request(
        context: PassageGenerationContext,
        run_id: str,
        parent_operation_id: Optional[str] = None,
        timeout_seconds: float = 60.0,
        length_feedback: Optional[str] = None,
        target_artifact_id: Optional[str] = None,
    ):
        """Build the (prompt payload, ProviderRequest) pair for one draft attempt."""
        prompt_data = build_passage_generation_prompt(
            topic=context.topic,
            section_index=context.section_index,
            style_profile=context.style_profile,
            source_text=context.source_text,
            target_min_words=context.target_min_words,
            target_max_words=context.target_max_words,
            length_feedback=length_feedback,
        )
        messages = [
            ChatMessage(role="system", content=prompt_data["system_instruction"]),
            ChatMessage(role="user", content=prompt_data["user_prompt"]),
        ]
        req = ProviderRequest(
            capability=Capability.GENERATE_JSON,
            preferred_provider="minimax",
            allowed_providers=["minimax"],
            allow_fallback=False,
            messages=messages,
            operation_id=f"op_pass_gen_{uuid4().hex[:8]}",
            run_id=run_id,
            section_id=f"section_{context.section_index}",
            artifact_id=target_artifact_id or f"art_passage_s{context.section_index}",
            parent_operation_id=parent_operation_id,
            max_tokens=settings.passage_generate_max_tokens,
            timeout_seconds=timeout_seconds,
            response_schema={
                "type": "object",
                "properties": {
                    "title": {"type": "string"},
                    "passage": {"type": "string"},
                    "styleProfile": {"type": "string"},
                    "claimAlignments": {"type": "array"},
                },
                "required": ["title", "passage"],
            },
        )
        return prompt_data, req

    async def _call_gateway(
        self,
        req: ProviderRequest,
        epoch: int = 1,
        lease_owner: Optional[UUID] = None,
    ) -> str:
        """Dispatch exactly one provider call and return the raw response text."""
        if hasattr(self.gateway, "execute"):
            resp = await self.gateway.execute(req, epoch=epoch, lease_owner=lease_owner)
        elif hasattr(self.gateway, "request"):
            resp = await self.gateway.request(req)
        elif hasattr(self.gateway, "call"):
            resp = await self.gateway.call(req)
        else:
            raise AttributeError("Gateway does not have execute, request, or call method")
        toks = int(resp.usage.total_tokens) if getattr(resp, "usage", None) and resp.usage.total_tokens else 0
        self._last_tokens_used = getattr(self, "_last_tokens_used", 0) + toks
        return resp.raw_text.strip()

    async def generate(
        self,
        context: PassageGenerationContext,
        run_id: str,
        version: int = 1,
        target_artifact_id: Optional[str] = None,
        timeout_seconds: float = 60.0,
        lease_owner: Optional[UUID] = None,
        epoch: int = 1,
        parent_operation_id: Optional[str] = None,
        input_dependencies: Optional[Sequence[ArtifactRef]] = None,
        length_feedback: Optional[str] = None,
    ) -> ArtifactEnvelope:
        """Executes passage generation request and returns validated ArtifactEnvelope."""
        self._last_tokens_used = 0
        effective_feedback = length_feedback or context.length_feedback
        if not effective_feedback and context.last_attempt_word_count is not None:
            prev_w = context.last_attempt_word_count
            if 0 < prev_w < context.target_min_words:
                effective_feedback = (
                    f"CRITICAL FEEDBACK: Previous draft had only {prev_w} words, below the strict "
                    f"{context.target_min_words}-word minimum. Expand each paragraph with verified "
                    f"source details so total word count is strictly between {context.target_min_words} and {context.target_max_words} words."
                )
            elif prev_w > context.target_max_words:
                effective_feedback = (
                    f"CRITICAL FEEDBACK: Previous draft had {prev_w} words, exceeding the strict "
                    f"{context.target_max_words}-word maximum. Tighten phrasing so total word count "
                    f"is strictly between {context.target_min_words} and {context.target_max_words} words."
                )
        if context.last_attempt_evaluator_issues:
            issues_note = "AVOID PREVIOUS ISSUES: " + "; ".join(context.last_attempt_evaluator_issues)
            effective_feedback = f"{effective_feedback}\n{issues_note}".strip() if effective_feedback else issues_note

        prompt_data, req = self._build_request(
            context=context,
            run_id=run_id,
            parent_operation_id=parent_operation_id,
            timeout_seconds=timeout_seconds,
            length_feedback=effective_feedback,
            target_artifact_id=target_artifact_id,
        )
        raw_text = await self._call_gateway(req, epoch=epoch, lease_owner=lease_owner)

        # Parse output JSON or fallback to text segmentation
        parsed = self._parse_generation_output(raw_text, context)

        # Quantity grounding guard (prompt rule 6, enforced deterministically).
        # The prompt states the invariant; the model still emits invented years and
        # quantities. Previously that leaked straight into an artifact, consumed a
        # version, and burned the whole repair budget before the semantic evaluator
        # could refuse it. The guard is a general source-vs-passage invariant: any
        # passage numeric token whose digits are absent from the source is invented.
        # It never edits prose (that would be synthesis); it re-asks with the
        # offending tokens named, bounded by QUANTITY_GUARD_MAX_RETRIES so it can
        # never outrun the runtime's own caps.
        offending = _find_invented_quantities(context.source_text, parsed["passage"])
        retries = 0
        while offending and retries < QUANTITY_GUARD_MAX_RETRIES:
            retries += 1
            guard_feedback = _build_quantity_guard_feedback(offending)
            combined_feedback = (
                f"{effective_feedback}\n\n{guard_feedback}" if effective_feedback else guard_feedback
            )
            logger.warning(
                "Passage quantity guard fired (attempt %d/%d): invented numeric tokens %s",
                retries,
                QUANTITY_GUARD_MAX_RETRIES,
                offending,
            )
            guard_prompt_data, guard_req = self._build_request(
                context=context,
                run_id=run_id,
                parent_operation_id=parent_operation_id,
                timeout_seconds=timeout_seconds,
                length_feedback=combined_feedback,
                target_artifact_id=target_artifact_id,
            )
            guard_raw_text = await self._call_gateway(
                guard_req, epoch=epoch, lease_owner=lease_owner
            )
            parsed = self._parse_generation_output(guard_raw_text, context)
            prompt_data = guard_prompt_data
            offending = _find_invented_quantities(context.source_text, parsed["passage"])
        if offending:
            # The re-ask did not produce a grounded draft. The generator does NOT
            # mutate the prose to force compliance (stripping or substituting the
            # token would be synthesis, and would fabricate a different claim), and
            # it does NOT raise: the authoritative GroundingFidelityEvaluator still
            # fails this artifact closed downstream. The guard's whole purpose is to
            # buy one grounded second chance inside the version already being spent;
            # when that chance is refused, the verdict belongs to the evaluator, and
            # the artifact records the attempt so attribution stays truthful.
            logger.warning(
                "Passage quantity guard found ungrounded numeric tokens after %d "
                "re-ask(s): %s; returning draft for authoritative evaluation",
                retries,
                offending,
            )

        # Word-count band guard (prompt rule 1, enforced deterministically).
        #
        # The prompt already states the invariant ("Word count MUST be between 720
        # and 915 words; target 780-840; aim for ~800"), but the generator never
        # checked it at generation time. Measured drafts came out at 921 / 673 /
        # 660 / 682 / 691 -- and every one of those drifts *consumed a whole
        # immutable version slot*: a repair ran out of headroom trying to extend a
        # 682-word draft, or a regeneration ran out of headroom trimming a 921-word
        # one. A purely mechanical miss then ended the paper (case 15, seed 303).
        #
        # This is the quantity guard's pattern applied to the length band. It
        # re-asks once with the real count and the deficit/overshoot named, reusing
        # the existing length-feedback seam, and it counts with the canonical
        # validator rule so it can never disagree with the validator at a boundary.
        #
        # It never truncates, pads, or clamps: an out-of-band draft is REWRITTEN,
        # and if the rewrite is still out of band the draft is returned unchanged
        # for the validators to fail closed, exactly as before. Bounded by
        # WORD_COUNT_GUARD_MAX_RETRIES so it can never outrun the runtime's caps.
        #
        # The band is read from the POLICY constants, never from
        # `context.target_min_words` / `context.target_max_words`. Those context
        # fields are caller-overridable, but the validators enforce the fixed
        # policy band: binding the guard to them would let an overridden context
        # widen the band the guard checks while the validator still rejected at
        # 720/915 -- silently turning this guard off. The guard must police the
        # exact bound that actually rejects the artifact.
        band_min = PASSAGE_MIN_WORDS
        band_max = PASSAGE_MAX_WORDS
        measured_words = _measure_passage_words(parsed["passage"])
        word_count_retries = 0
        while (
            not (band_min <= measured_words <= band_max)
            and word_count_retries < WORD_COUNT_GUARD_MAX_RETRIES
        ):
            word_count_retries += 1
            length_guard_feedback = _build_word_count_guard_feedback(
                measured_words, band_min, band_max
            )
            combined_feedback = (
                f"{effective_feedback}\n\n{length_guard_feedback}"
                if effective_feedback
                else length_guard_feedback
            )
            logger.warning(
                "Passage word-count guard fired (attempt %d/%d): measured %d words, "
                "outside [%d, %d]",
                word_count_retries,
                WORD_COUNT_GUARD_MAX_RETRIES,
                measured_words,
                band_min,
                band_max,
            )
            guard_prompt_data, guard_req = self._build_request(
                context=context,
                run_id=run_id,
                parent_operation_id=parent_operation_id,
                timeout_seconds=timeout_seconds,
                length_feedback=combined_feedback,
                target_artifact_id=target_artifact_id,
            )
            guard_raw_text = await self._call_gateway(
                guard_req, epoch=epoch, lease_owner=lease_owner
            )
            parsed = self._parse_generation_output(guard_raw_text, context)
            prompt_data = guard_prompt_data
            measured_words = _measure_passage_words(parsed["passage"])
        if not (band_min <= measured_words <= band_max):
            # The rewrite is still out of band. The generator does NOT clamp, pad,
            # or truncate to reach the band -- any of those would be synthesis and
            # would fabricate text the source does not support -- and it does NOT
            # raise: the authoritative validators still fail this artifact closed
            # downstream. Recording the measurement keeps the failure attributable
            # to generation rather than looking like an evaluator miss.
            logger.warning(
                "Passage word-count guard found %d words outside [%d, %d] after %d "
                "re-ask(s); returning draft for authoritative evaluation",
                measured_words,
                band_min,
                band_max,
                word_count_retries,
            )

        passage_text = parsed["passage"]
        paragraphs = parsed["paragraphs"]

        # Segment sentences across paragraphs with sequential sentence IDs
        sentences_list = []
        sentence_idx = 0
        for p_idx, para in enumerate(paragraphs):
            para_sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", para) if s.strip()]
            for s in para_sentences:
                sentences_list.append({
                    "sentenceId": f"s_{sentence_idx}",
                    "text": s,
                    "paragraphIndex": p_idx,
                    "wordCount": count_words(s),
                })
                sentence_idx += 1

        payload: Dict[str, Any] = {
            "title": parsed.get("title", f"{context.topic} - Passage {context.section_index}"),
            "passage": passage_text,
            "passageText": passage_text,
            "paragraphs": paragraphs,
            "sentences": sentences_list,
            "wordCount": count_words(passage_text),
            "styleProfile": context.style_profile.value,
            "sourceText": context.source_text,
            "sectionIndex": context.section_index,
            "claimAlignments": parsed.get("claimAlignments", []),
            "promptId": prompt_data["prompt_id"],
            "promptVersion": prompt_data["prompt_version"],
            "promptHash": prompt_data["prompt_hash"],
            # Audit trail for the quantity guard. `ungroundedNumericTokens` is
            # diagnostic only -- it grants no pass and relaxes nothing. It exists so
            # a run that still carried invented quantities after the re-ask is
            # attributable to generation rather than looking like an evaluator miss.
            "quantityGuardReasks": retries,
            "ungroundedNumericTokens": list(offending),
            # Audit trail for the word-count guard, same posture. `measuredWords` is
            # the canonical validator count of the returned draft and
            # `wordCountBand` is the band it was checked against, so a run that
            # still drifted after the re-ask is attributable to generation.
            "wordCountGuardReasks": word_count_retries,
            "measuredWords": measured_words,
            "wordCountBand": [band_min, band_max],
            "tokensUsed": int(getattr(self, "_last_tokens_used", 0)),
        }

        if input_dependencies is not None:
            parent_refs = tuple(input_dependencies)
        else:
            p_refs = [context.blueprint_ref, context.evidence_graph_ref]
            if context.source_pack_ref:
                p_refs.append(context.source_pack_ref)
            parent_refs = tuple(p_refs)

        artifact_id = target_artifact_id or f"art_passage_s{context.section_index}"

        return ArtifactEnvelope.create(
            artifact_id=artifact_id,
            artifact_type=ArtifactType.PASSAGE,
            run_id=run_id,
            version=version,
            payload=payload,
            producer_version="2.0.0",
            parent_refs=parent_refs,
        )

    def _parse_generation_output(
        self,
        raw_text: str,
        context: PassageGenerationContext,
    ) -> Dict[str, Any]:
        """Defensively parses LLM response into structured passage payload, failing closed on invalid JSON."""
        schema = {
            "type": "object",
            "properties": {
                "title": {"type": "string"},
                "passage": {"type": "string"},
                "styleProfile": {"type": "string"},
            },
            "required": ["title", "passage"],
        }
        normalized_raw = _merge_duplicate_passage_keys(raw_text)
        data = parse_defensive_json(normalized_raw, response_schema=schema, allow_repair=True)
        if not isinstance(data, dict) or "passage" not in data or not isinstance(data["passage"], str):
            raise ValueError("Provider output failed defensive JSON validation: missing or invalid 'passage' string")

        pass_str = data["passage"].strip()
        paragraphs = data.get("paragraphs")
        if not paragraphs or not isinstance(paragraphs, list):
            paragraphs = [p.strip() for p in re.split(r"\n\s*\n|\r\n\s*\r\n", pass_str) if p.strip()]
        else:
            paragraphs = [str(p).strip() for p in paragraphs if str(p).strip()]
        if len(paragraphs) <= 2 and len(pass_str.split()) >= 600:
            single_lines = [p.strip() for p in pass_str.split("\n") if len(p.strip().split()) >= 40]
            if len(single_lines) >= 4:
                paragraphs = single_lines

        final_passage = "\n\n".join(paragraphs) if len(paragraphs) > 1 else pass_str
        self._last_attempt_word_count = count_words(final_passage)
        return {
            "title": data.get("title", f"Passage on {context.topic}"),
            "passage": final_passage,
            "paragraphs": paragraphs,
            "styleProfile": data.get("styleProfile", context.style_profile.value),
            "claimAlignments": data.get("claimAlignments", []),
        }
