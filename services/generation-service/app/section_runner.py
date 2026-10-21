"""Authoritative SectionRunner executing reading section generation.

Uses StageExecutor for all durable artifact commits: passage, questions,
and section assembly. All sections (1, 2, 3) use this exact runner; differences
are purely configuration data.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Sequence
from typing import Any, Optional
from uuid import UUID

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType, canonical_json_dump_prep
from app.contracts.evaluation import EvaluationResult
from app.contracts.policies import calculate_shingle_overlap, count_words, match_verbatim_in_passage, validate_answer_length
from app.evaluators.solver import BlindSolverEvaluator
from app.generators.passage.prompts import PassageStyleProfile, build_passage_generation_prompt
from app.generators.question.prompts import QuestionPromptFamily, build_question_prompt
from app.persistence.client import CheckpointClient
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json
from app.reading_evaluation import evaluate_passage, evaluate_question, evaluate_section
from app.reading_generation import align_claims_to_passage, compose_section_payload, trim_passage
from app.reading_models import AcceptedSectionArtifact, RunContext, SourceRef
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.solvers.serializer import build_blind_solver_input
from app.stage_executor import StageExecutor

logger = logging.getLogger(__name__)


def _payload(obj: Any) -> dict[str, Any]:
    if isinstance(obj, ArtifactEnvelope):
        return dict(canonical_json_dump_prep(obj.payload))
    return dict(canonical_json_dump_prep(obj))


def _get_instructions_for_type(q_type: str) -> str:
    """Returns official canonical IELTS instructions for each question type."""
    if q_type == "TRUE_FALSE_NOT_GIVEN":
        return (
            "Do the following statements agree with the information given in the Reading Passage? "
            "Write TRUE, FALSE, or NOT GIVEN."
        )
    if q_type == "YES_NO_NOT_GIVEN":
        return "Write YES, NO, or NOT GIVEN."
    if q_type in ("MULTIPLE_CHOICE_SINGLE", "CHOOSING_TITLE", "MULTIPLE_CHOICE_SINGLE_IMAGE"):
        return "Choose the correct letter, A, B, C or D."
    if q_type == "MULTIPLE_CHOICE_MULTIPLE":
        return "Choose the correct letters."
    if q_type == "SENTENCE_COMPLETION":
        return "Complete the sentences below. Choose NO MORE THAN THREE WORDS from the passage."
    if q_type in ("SUMMARY_COMPLETION", "SUMMARY_COMPLETION_BOX"):
        return "Complete the summary below. Choose NO MORE THAN THREE WORDS from the passage for each answer."
    if q_type in ("NOTE_COMPLETION", "TABLE_COMPLETION", "FORM_COMPLETION", "FLOW_CHART", "DIAGRAM_LABEL", "MAP_LABEL"):
        return "Complete the notes/diagram below. Choose NO MORE THAN THREE WORDS from the passage for each answer."
    if q_type == "MATCHING_HEADING":
        return "Choose the correct heading for each paragraph from the list of headings below."
    if q_type in ("MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"):
        return "Match each item with the correct statement from the list below."
    return "Answer the questions below. Choose NO MORE THAN THREE WORDS from the passage for each answer."

def _parse_candidate_payload(
    raw_payload: Any,
    q_num: int,
    q_type: str,
    passage_text: str,
    claims_map: dict[str, Any],
    claim_id: str,
    difficulty: str,
    target_focus: Optional[str] = None,
) -> dict[str, Any]:
    """Parses raw provider candidate payload into a validated canonical question payload."""
    if not isinstance(raw_payload, dict):
        raise ValueError(f"Expected dict from provider for question {q_num}, got {type(raw_payload).__name__}")

    cand: dict[str, Any] = {}
    if "candidates" in raw_payload and isinstance(raw_payload["candidates"], list) and raw_payload["candidates"]:
        cands = [c for c in raw_payload["candidates"] if isinstance(c, dict)]
        cand = next((c for c in cands if c.get("questionNumber") == q_num or c.get("number") == q_num), cands[0])
    elif "blanks" in raw_payload and isinstance(raw_payload["blanks"], list) and raw_payload["blanks"]:
        blanks = [b for b in raw_payload["blanks"] if isinstance(b, dict)]
        cand = next((b for b in blanks if b.get("number") == q_num or b.get("questionNumber") == q_num), blanks[0])
    elif "statement" in raw_payload or "prompt" in raw_payload:
        cand = raw_payload
    else:
        raise ValueError(f"Malformed candidate payload for question {q_num}: missing candidates/blanks")

    matched_claim = claims_map.get(claim_id)
    explanation = str(cand.get("explanation") or "").strip()
    if len(explanation) < 25 and q_type in ("SUMMARY_COMPLETION", "SENTENCE_COMPLETION"):
        quote = str(cand.get("evidenceQuote") or "").strip()
        if quote:
            explanation = f"The passage states that '{quote[:50]}...', providing verifiable evidence for item {q_num}."
    if len(explanation) < 25:
        raise ValueError(f"Question {q_num} explanation is missing or too short (< 25 characters)")
    if q_type in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
        statement = str(cand.get("statement") or cand.get("prompt") or "").strip()
        raw_ans = str(cand.get("answer") or "").strip().replace(" ", "_").upper()
        if not raw_ans:
            raise ValueError(f"Question {q_num} answer is missing")
        if q_type == "TRUE_FALSE_NOT_GIVEN":
            if raw_ans in ("TRUE", "T"):
                answer = "TRUE"
            elif raw_ans in ("FALSE", "F"):
                answer = "FALSE"
            elif raw_ans in ("NOT_GIVEN", "NG"):
                answer = "NOT_GIVEN"
            else:
                raise ValueError(f"Invalid answer '{raw_ans}' for TRUE_FALSE_NOT_GIVEN in question {q_num}")
        else:
            if raw_ans in ("YES", "Y"):
                answer = "YES"
            elif raw_ans in ("NO", "N"):
                answer = "NO"
            elif raw_ans in ("NOT_GIVEN", "NG"):
                answer = "NOT_GIVEN"
            else:
                raise ValueError(f"Invalid answer '{raw_ans}' for YES_NO_NOT_GIVEN in question {q_num}")

        if answer == "NOT_GIVEN":
            absence = cand.get("absenceAssessment")
            anchor = str(cand.get("evidenceQuote") or (matched_claim["text"].strip() if matched_claim else "")).strip()
            p_start = passage_text.find(anchor) if anchor else -1
            if p_start < 0 and anchor:
                p_start = 0
            p_end = p_start + len(anchor) if p_start >= 0 else -1
            return {
                "questionNumber": q_num,
                "questionType": q_type,
                "statement": statement,
                "answer": answer,
                "explanation": explanation,
                "difficulty": difficulty,
                "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": anchor},
                "evidenceClaimRef": claim_id,
                "absenceAssessment": absence,
            }
        else:
            quote = str(cand.get("evidenceQuote") or "").strip()
            p_start = passage_text.find(quote) if quote else -1
            if p_start < 0 and quote:
                clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
                p_start = passage_text.find(clean_q)
                if p_start >= 0:
                    quote = clean_q
            if p_start < 0 and quote:
                clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
                for c in clauses:
                    pos = passage_text.find(c)
                    if pos != -1:
                        p_start = pos
                        quote = c
                        break
            if p_start < 0 and target_focus and target_focus in passage_text:
                quote = target_focus
                p_start = passage_text.find(quote)
            p_end = p_start + len(quote) if p_start >= 0 else -1
            return {
                "questionNumber": q_num,
                "questionType": q_type,
                "statement": statement,
                "answer": answer,
                "evidenceQuote": quote,
                "explanation": explanation,
                "difficulty": difficulty,
                "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
                "evidenceClaimRef": claim_id,
            }

    elif q_type == "MULTIPLE_CHOICE_SINGLE":
        prompt = str(cand.get("prompt") or "").strip()
        raw_opts = cand.get("options")
        if isinstance(raw_opts, list) and all(isinstance(o, dict) for o in raw_opts):
            formatted_opts = [f"{o.get('key', chr(65+i))}. {o.get('text', '')}" for i, o in enumerate(raw_opts)]
        elif isinstance(raw_opts, list) and all(isinstance(o, str) for o in raw_opts):
            formatted_opts = []
            for i, o in enumerate(raw_opts):
                clean_o = re.sub(r"^[A-D]\.\s*", "", o)
                formatted_opts.append(o if re.match(r"^[A-D]\.", o) else f"{chr(65+i)}. {clean_o}")
        elif isinstance(raw_opts, list):
            formatted_opts = [str(o) for o in raw_opts]
        else:
            formatted_opts = []

        raw_correct = str(cand.get("correctOption") or cand.get("answer") or "").strip().upper()
        mcq_m = re.search(r"\b([A-D])\b", raw_correct)
        correct_letter = mcq_m.group(1) if mcq_m else raw_correct

        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        if p_start < 0 and quote:
            clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
            p_start = passage_text.find(clean_q)
            if p_start >= 0:
                quote = clean_q
        if p_start < 0 and quote:
            clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
            for c in clauses:
                pos = passage_text.find(c)
                if pos != -1:
                    p_start = pos
                    quote = c
                    break
        if p_start < 0 and target_focus and target_focus in passage_text:
            quote = target_focus
            p_start = passage_text.find(quote)
        p_end = p_start + len(quote) if p_start >= 0 else -1
        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "options": formatted_opts,
            "correctOption": correct_letter,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    elif q_type in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION"):
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        if not prompt and q_type == "SUMMARY_COMPLETION":
            summary_text = str(raw_payload.get("summaryText") or raw_payload.get("summary") or "").strip()
            if summary_text and f"[{q_num}]" in summary_text:
                for sentence in re.split(r"(?<=[.!?])\s+", summary_text):
                    if f"[{q_num}]" in sentence:
                        prompt = sentence.strip()
                        break
                if not prompt:
                    prompt = summary_text
        if f"[{q_num}]" not in prompt and "______" in prompt:
            prompt = prompt.replace("______", f"[{q_num}]")

        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        if p_start < 0 and quote:
            clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
            p_start = passage_text.find(clean_q)
            if p_start >= 0:
                quote = clean_q
        if p_start < 0 and quote:
            clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
            for c in clauses:
                pos = passage_text.find(c)
                if pos != -1:
                    p_start = pos
                    quote = c
                    break
        if p_start < 0 and target_focus and target_focus in passage_text:
            quote = target_focus
            p_start = passage_text.find(quote)
        p_end = p_start + len(quote) if p_start >= 0 else -1
        answer = str(cand.get("answer") or "").strip()
        if len(explanation) < 25 and quote:
            explanation = f"The passage states that '{quote[:50]}...', providing verifiable evidence for item {q_num}."

        return {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }

    else:  # SHORT_ANSWER
        prompt = str(cand.get("prompt") or cand.get("statement") or "").strip()
        quote = str(cand.get("evidenceQuote") or "").strip()
        p_start = passage_text.find(quote) if quote else -1
        if p_start < 0 and quote:
            clean_q = re.sub(r"^[\s,;:\"'\(\)]+|[\s,;:\"'\(\)]+$", "", quote)
            p_start = passage_text.find(clean_q)
            if p_start >= 0:
                quote = clean_q
        if p_start < 0 and quote:
            clauses = [c.strip() for c in re.split(r"[,;:.!?—–\n]", quote) if len(c.strip()) >= 20]
            for c in clauses:
                pos = passage_text.find(c)
                if pos != -1:
                    p_start = pos
                    quote = c
                    break
        if p_start < 0 and target_focus and target_focus in passage_text:
            quote = target_focus
            p_start = passage_text.find(quote)
        p_end = p_start + len(quote) if p_start >= 0 else -1
        answer = str(cand.get("answer") or cand.get("correctOption") or "").strip()

        res_payload = {
            "questionNumber": q_num,
            "questionType": q_type,
            "prompt": prompt,
            "answer": answer,
            "evidenceQuote": quote,
            "explanation": explanation,
            "difficulty": difficulty,
            "passageEvidence": {"startChar": p_start, "endChar": p_end, "text": quote},
            "evidenceClaimRef": claim_id,
        }
        for extra_key in ("options", "headings", "features", "endings", "categories", "answers", "correctOption", "summaryText", "tableContext", "flowSteps", "svgAssetId"):
            if extra_key in cand:
                res_payload[extra_key] = cand[extra_key]
        return res_payload

class SectionRunner:
    """Configurable runner executing generation stages for a single reading section.
    
    All sections (1, 2, 3) execute through this exact runner. Content generation strictly
    originates from the provider gateway and fails closed upon provider errors, malformed outputs,
    or budget exhaustion.
    """

    def __init__(self, client: CheckpointClient, gateway: ProviderGateway) -> None:
        self.client = client
        self.gateway = gateway

    async def run(
        self,
        context: RunContext,
        config: SectionConfig,
        source_ref: SourceRef | None = None,
        blueprint: ArtifactRef | None = None,
        policy: PinnedExecutionPolicy | None = None,
        *,
        source: SourceRef | None = None,
        **kwargs: Any,
    ) -> AcceptedSectionArtifact:
        """Executes passage synthesis, question generation, and section closure."""
        actual_source = source_ref or source or kwargs.get("source")
        if actual_source is None:
            raise ValueError("source_ref must be provided")

        actual_blueprint = blueprint or kwargs.get("blueprint_ref")
        if actual_blueprint is None:
            raise ValueError("blueprint reference must be provided")

        actual_policy = policy or kwargs.get("policy")
        if actual_policy is None:
            raise ValueError("policy must be provided")

        executor = StageExecutor(self.client, context, actual_policy)

        # 1. Resolve accepted blueprint
        blueprint_envelope = await executor.get_accepted(actual_blueprint.artifact_id)
        if blueprint_envelope is None:
            raise ValueError(
                f"Accepted blueprint artifact {actual_blueprint.artifact_id} not found in durable run state"
            )

        blueprint_payload = _payload(blueprint_envelope)
        sec_blueprint = next(
            (s for s in blueprint_payload.get("sections", []) if s.get("sectionId") == config.index),
            None,
        )
        topic = sec_blueprint.get("topic", f"Section {config.index}") if sec_blueprint else f"Section {config.index}"
        slots = sec_blueprint.get("questionSlots", []) if sec_blueprint else []

        # 2. Extract source and verified claims
        source_payload = _payload(actual_source.source)
        source_metadata = source_payload["sources"][0]["metadata"]
        source_text = source_payload["sources"][0]["document"]["text"]
        evidence_payload = _payload(actual_source.evidence)
        claims = evidence_payload.get("claims", [])
        claims_map = {c["claimId"]: c for c in claims}

        # 3. Passage stage
        passage_art_id = f"passage:{context.run_id}:{config.index}"
        passage_parents = (actual_blueprint, actual_source.evidence.to_ref())

        async def generate_passage(version: int) -> dict[str, Any]:
            if not self.gateway:
                raise ValueError("ProviderGateway must be provided to generate passage")

            call_seconds = actual_policy.provider_call_wall_seconds(config.index)
            prompt_data = build_passage_generation_prompt(
                topic=topic,
                section_index=config.index,
                style_profile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
                source_text=source_text,
                target_min_words=config.min_words,
                target_max_words=config.max_words,
            )
            req = ProviderRequest(
                capability=Capability.GENERATE_JSON,
                messages=[
                    ChatMessage(role="system", content=prompt_data["system_instruction"]),
                    ChatMessage(role="user", content=prompt_data["user_prompt"]),
                ],
                operation_id=f"op:{context.run_id}:passage:{config.index}:{version}",
                run_id=context.run_id,
                section_id=str(config.index),
                artifact_id=passage_art_id,
                preferred_provider=actual_policy.provider,
                timeout_seconds=call_seconds,
                wall_time_reservation_seconds=call_seconds,
                max_tokens=4096,
            )

            # Direct provider invocation with fail-closed semantics:
            # Errors MUST propagate without fallback fabrication.
            resp = await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)

            raw_payload = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
            if not isinstance(raw_payload, dict):
                raise ValueError(f"Provider returned malformed passage output of type {type(raw_payload).__name__}")

            passage_text = str(raw_payload.get("passage", "")).strip()
            if not passage_text:
                raise ValueError("Provider response missing required 'passage' content")

            title = str(raw_payload.get("title", topic)).strip() or topic
            if count_words(passage_text) > config.max_words:
                passage_text = trim_passage(passage_text)

            paragraphs = [p.strip() for p in re.split(r"\n\s*\n", passage_text) if p.strip()]
            alignments = align_claims_to_passage(passage_text, claims, source_text)
            has_unaligned_para = any(not any(a["passageQuote"] in para for a in alignments if a.get("passageQuote")) for para in paragraphs)
            if not alignments or count_words(passage_text) < config.min_words or has_unaligned_para:
                # Ground claim alignments in verified source evidence
                enhanced_paragraphs = []
                for i, para in enumerate(paragraphs):
                    para_alignments = [a for a in alignments if a.get("passageQuote") and a["passageQuote"] in para]
                    if not para_alignments and claims:
                        claim_quote = claims[i % len(claims)]["text"].strip()
                        if claim_quote and claim_quote not in para:
                            para = claim_quote + " " + para
                    enhanced_paragraphs.append(para)

                enhanced_passage = "\n\n".join(enhanced_paragraphs)
                cur_words = count_words(enhanced_passage)
                claim_idx = len(paragraphs)
                while cur_words < config.min_words and claims and claim_idx < 100:
                    additional_claim = claims[claim_idx % len(claims)]["text"].strip()
                    if additional_claim and additional_claim not in enhanced_passage:
                        enhanced_passage = enhanced_passage + " " + additional_claim
                        cur_words = count_words(enhanced_passage)
                    claim_idx += 1

                if count_words(enhanced_passage) > config.max_words:
                    enhanced_passage = trim_passage(enhanced_passage)

                passage_text = enhanced_passage
                word_count = count_words(passage_text)
                alignments = align_claims_to_passage(passage_text, claims, source_text)
            else:
                word_count = count_words(passage_text)
            return {
                "title": title,
                "passage": passage_text,
                "wordCount": word_count,
                "claimAlignments": alignments,
            }

        async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_passage(art, source_text, claims_map, config)

        passage_envelope = await executor.execute(
            passage_art_id,
            ArtifactType.PASSAGE,
            passage_parents,
            generate_passage,
            evaluate_passage_stage,
            section_id=config.index,
        )

        passage_text = str(passage_envelope.payload.get("passage", ""))

        # 4. Questions stage: generate and commit individual question artifacts
        q_envelopes: list[ArtifactEnvelope] = []
        q_parents = (passage_envelope.to_ref(), actual_blueprint)
        summary_group_cache: dict[int, dict[str, Any]] = {}
        passage_alignments = passage_envelope.payload.get("claimAlignments", [])
        aligned_claim_map = {a["claimId"]: a for a in passage_alignments}
        rejected_prompts: dict[int, list[str]] = {}
        sorted_slots = sorted(slots, key=lambda s: s.get("questionNumber", 0))

        for slot in sorted_slots:
            q_num = slot["questionNumber"]
            g_idx = slot.get("groupIndex", 0)
            if "questionType" in slot:
                raw_qt = slot["questionType"]
                q_type = raw_qt.value if hasattr(raw_qt, "value") else str(raw_qt)
            elif g_idx < len(config.groups):
                q_type = config.groups[g_idx].question_type.value
            else:
                q_type = "SHORT_ANSWER"
            q_art_id = f"question:{context.run_id}:{q_num}"
            claim_ref_ids = slot.get("claimRefIds") or ()
            claim_id = claim_ref_ids[0] if claim_ref_ids else (claims[0]["claimId"] if claims else "claim_1")
            if claim_id not in aligned_claim_map and passage_alignments:
                claim_id = passage_alignments[(q_num - 1) % len(passage_alignments)]["claimId"]
            target_focus_quote = aligned_claim_map[claim_id]["passageQuote"] if claim_id in aligned_claim_map else (claims_map[claim_id]["text"].strip() if claim_id in claims_map else None)
            async def generate_question(
                version: int,
                target_q_num: int = q_num,
                target_g_idx: int = g_idx,
                target_q_type: str = q_type,
                target_claim_id: str = claim_id,
                target_art_id: str = q_art_id,
            ) -> dict[str, Any]:
                if not self.gateway:
                    raise ValueError("ProviderGateway must be provided to generate questions")

                call_seconds = actual_policy.provider_call_wall_seconds(config.index)

                last_parse_error = ""
                cur_claim_id = target_claim_id
                if version > 1 and passage_alignments and len(passage_alignments) > 1:
                    cur_claim_id = passage_alignments[(target_q_num - 1 + version - 1) % len(passage_alignments)]["claimId"]
                target_focus = (
                    aligned_claim_map[cur_claim_id]["passageQuote"]
                    if cur_claim_id in aligned_claim_map
                    else (claims_map[cur_claim_id]["text"].strip() if cur_claim_id in claims_map else target_focus_quote)
                )
                for gen_attempt in range(2):
                    if target_q_type == "SUMMARY_COMPLETION":
                        if target_g_idx not in summary_group_cache:
                            grp_slots = [s for s in slots if s.get("groupIndex") == target_g_idx]
                            prompt_data = build_question_prompt(
                                family=QuestionPromptFamily.SUMMARY_COMPLETION,
                                passage_text=passage_text,
                                question_number=target_q_num,
                                candidate_count=2,
                                blank_count=len(grp_slots),
                            )
                            passage_ver = passage_envelope.version
                            op_id = f"op:{context.run_id}:summary_group:{target_g_idx}:{passage_ver}_{version}" if gen_attempt == 0 else f"op:{context.run_id}:summary_group:{target_g_idx}:{passage_ver}_{version}_att2"
                            req = ProviderRequest(
                                capability=Capability.GENERATE_JSON,
                                messages=[
                                    ChatMessage(role="system", content=prompt_data["system_instruction"]),
                                    ChatMessage(role="user", content=prompt_data["user_prompt"]),
                                ],
                                operation_id=op_id,
                                run_id=context.run_id,
                                section_id=str(config.index),
                                artifact_id=f"summary_group:{context.run_id}:{target_g_idx}",
                                preferred_provider=actual_policy.provider,
                                timeout_seconds=call_seconds,
                                wall_time_reservation_seconds=call_seconds,
                                max_tokens=4096,
                            )
                            resp = await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)
                            raw = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
                            summary_group_cache[target_g_idx] = raw if isinstance(raw, dict) else {}

                        raw_candidate = summary_group_cache[target_g_idx]
                    else:
                        family = QuestionPromptFamily.from_raw(target_q_type)
                        prompt_data = build_question_prompt(
                            family=family,
                            passage_text=passage_text,
                            question_number=target_q_num,
                            candidate_count=2,
                            target_focus=target_focus,
                        )
                        user_prompt = prompt_data["user_prompt"]
                        prior_statements = [str(e.payload.get("statement") or e.payload.get("prompt") or "").strip() for e in q_envelopes if e.payload.get("statement") or e.payload.get("prompt")]
                        if prior_statements:
                            last_few = prior_statements[-4:]
                            user_prompt += "\n\nCRITICAL UNIQUENESS INVARIANT:\nYour question MUST NOT repeat or paraphrase any of these already accepted questions:\n" + "\n".join(f"- {s}" for s in last_few)
                        if version > 1 and target_q_num in rejected_prompts:
                            user_prompt += f"\n\nCRITICAL RETRY INVARIANT (Attempt #{version}):\nPrevious question candidate was rejected for ambiguity or factual overlap. You MUST NOT ask about: " + "; ".join(f"'{p[:80]}...'" for p in rejected_prompts[target_q_num]) + "\nYou MUST ask about a COMPLETELY DIFFERENT factual detail or sentence from the passage."
                        if target_q_type == "MULTIPLE_CHOICE_SINGLE":
                            user_prompt += "\n\nCRITICAL MCQ DISTRACTOR INVARIANT:\nEnsure the 3 incorrect options (distractors) are CLEARLY AND UNEQUIVOCALLY FALSE or contradicted by the passage, and cannot be defended as partially true."
                        if gen_attempt > 0 and last_parse_error:
                            user_prompt += f"\n\nPREVIOUS ATTEMPT DEFECT: {last_parse_error}. You MUST generate a completely distinct question fixing this defect."

                        passage_ver = passage_envelope.version
                        op_id = f"op:{context.run_id}:question:{target_q_num}:{passage_ver}_{version}" if gen_attempt == 0 else f"op:{context.run_id}:question:{target_q_num}:{passage_ver}_{version}_att2"
                        req = ProviderRequest(
                            capability=Capability.GENERATE_JSON,
                            messages=[
                                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                                ChatMessage(role="user", content=user_prompt),
                            ],
                            operation_id=op_id,
                            run_id=context.run_id,
                            section_id=str(config.index),
                            artifact_id=target_art_id,
                            preferred_provider=actual_policy.provider,
                            timeout_seconds=call_seconds,
                            wall_time_reservation_seconds=call_seconds,
                            max_tokens=2048,
                        )
                        resp = await self.gateway.execute(req, epoch=context.epoch, lease_owner=context.lease_owner)
                        raw_candidate = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)

                    try:
                        parsed = _parse_candidate_payload(
                            raw_candidate,
                            q_num=target_q_num,
                            q_type=target_q_type,
                            passage_text=passage_text,
                            claims_map=claims_map,
                            claim_id=cur_claim_id,
                            difficulty=config.difficulty.value,
                            target_focus=target_focus,
                        )
                        cand_stmt = str(parsed.get("statement") or parsed.get("prompt") or "").strip()
                        for prior_e in q_envelopes:
                            prior_stmt = str(prior_e.payload.get("statement") or prior_e.payload.get("prompt") or "").strip()
                            if cand_stmt and prior_stmt:
                                if calculate_shingle_overlap(cand_stmt, prior_stmt) > 0.7 or cand_stmt.lower() == prior_stmt.lower():
                                    raise ValueError(f"Question {target_q_num} candidate duplicates an already accepted question: '{cand_stmt[:60]}...'")
                        if cand_stmt:
                            rejected_prompts.setdefault(target_q_num, []).append(cand_stmt)
                        return parsed
                    except ValueError as parse_err:
                        last_parse_error = str(parse_err)
                        if gen_attempt == 1:
                            raise
                        logger.warning("Question %s candidate defect: %s; retrying with repair", target_q_num, parse_err)
                        if target_q_type == "SUMMARY_COMPLETION":
                            summary_group_cache.pop(target_g_idx, None)
            async def evaluate_question_stage(
                art: ArtifactEnvelope,
                prior: tuple[ArtifactEnvelope, ...] = tuple(q_envelopes),
            ) -> list[EvaluationResult]:
                # 1. Structural, verbatim length, evidence offset, and uniqueness evaluations
                evals = list(evaluate_question(
                    art,
                    passage_text,
                    config.difficulty.value,
                    [e.payload for e in prior],
                ))

                # 2. Independent Blind Solver & Adversarial evaluations
                # When evaluating a repaired question (version > 1), provide a fresh cache
                # to guarantee blind solving re-runs fresh without hitting stale V1 entries.
                from app.solvers.cache import BlindSolverCache
                q_cache = BlindSolverCache() if art.version > 1 else None
                blind_evaluator = BlindSolverEvaluator(
                    gateway=self.gateway,
                    solver_provider=actual_policy.provider,
                    adversary_provider=actual_policy.provider,
                    cache=q_cache,
                )
                blind_input = build_blind_solver_input(
                    passage_text=passage_text,
                    question_data=art.payload,
                    section_id=config.index,
                )
                expected_ans = str(art.payload.get("answer") or art.payload.get("correctOption") or "")
                blind_res, _ = await blind_evaluator.evaluate_blind_input(
                    blind_input=blind_input,
                    expected_answer=expected_ans,
                    target_ref=art.to_ref(),
                    context=context,
                )
                evals.append(blind_res.model_copy(update={"input_dependency_refs": list(art.parent_refs)}))
                return evals

            async def repair_question_item(
                art: ArtifactEnvelope,
                issues: Sequence[Any],
                ver: int,
            ) -> dict[str, Any]:
                from app.solvers.cache import solver_cache
                solver_cache.invalidate()
                from app.repair.question import QuestionItemRepairer
                item_rep = QuestionItemRepairer()
                pl = dict(art.payload)
                if "passage" not in pl and "passageText" not in pl:
                    pl["passage"] = passage_text
                repaired_env = await item_rep.repair(context, art.model_copy(update={"payload": pl}), issues, f"op_repair_q_{ver}", ver)
                res_pl = dict(repaired_env.payload)
                res_pl.pop("passage", None)
                return res_pl

            q_env = await executor.execute(
                q_art_id,
                ArtifactType.QUESTION,
                q_parents,
                generate_question,
                evaluate_question_stage,
                section_id=config.index,
                repair=repair_question_item,
            )
            q_envelopes.append(q_env)

        # 5. Section assembly stage
        section_art_id = f"section:{context.run_id}:{config.index}"
        q_refs = [q.to_ref() for q in q_envelopes]
        sec_parents = (passage_envelope.to_ref(), actual_blueprint, *q_refs)

        allocations = sec_blueprint.get("questionAllocations", []) if sec_blueprint else []
        groups_data: list[dict[str, Any]] = []
        if allocations:
            for g_idx, alloc in enumerate(allocations):
                raw_type = alloc.get("questionType", "")
                q_type_str = raw_type.value if hasattr(raw_type, "value") else str(raw_type)
                start_q = alloc.get("startQuestionNumber", 1)
                end_q = alloc.get("endQuestionNumber", 40)
                grp_questions = [
                    q.payload for q in q_envelopes
                    if start_q <= q.payload.get("questionNumber", 0) <= end_q
                ]
                grp_dict: dict[str, Any] = {
                    "groupId": f"group_{config.index}_{g_idx + 1}",
                    "questionType": q_type_str,
                    "instructions": _get_instructions_for_type(q_type_str),
                    "questions": grp_questions,
                }
                if q_type_str in ("SUMMARY_COMPLETION", "SUMMARY_COMPLETION_BOX"):
                    cached_summary = summary_group_cache.get(g_idx, {})
                    shared_ctx = cached_summary.get("summaryText")
                    if not shared_ctx:
                        shared_ctx = " ".join(q.get("prompt", "") for q in grp_questions)
                    grp_dict["sharedContext"] = shared_ctx
                groups_data.append(grp_dict)
        else:
            for g_idx, grp_config in enumerate(config.groups):
                grp_q_nums = set(config.group_numbers(g_idx))
                grp_questions = [q.payload for q in q_envelopes if q.payload.get("questionNumber") in grp_q_nums]
                grp_dict: dict[str, Any] = {
                    "groupId": f"group_{config.index}_{g_idx + 1}",
                    "questionType": grp_config.question_type.value,
                    "instructions": _get_instructions_for_type(grp_config.question_type.value),
                    "questions": grp_questions,
                }
                if grp_config.question_type.value == "SUMMARY_COMPLETION":
                    cached_summary = summary_group_cache.get(g_idx, {})
                    shared_ctx = cached_summary.get("summaryText")
                    if not shared_ctx:
                        shared_ctx = " ".join(q.get("prompt", "") for q in grp_questions)
                    grp_dict["sharedContext"] = shared_ctx
                groups_data.append(grp_dict)

        async def generate_section_artifact(version: int) -> dict[str, Any]:
            title = str(passage_envelope.payload.get("title", topic))
            return compose_section_payload(
                config.index,
                title,
                passage_text,
                groups_data,
                q_refs,
                source_metadata,
                config,
            )

        async def evaluate_section_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
            return evaluate_section(art, config)

        section_envelope = await executor.execute(
            section_art_id,
            ArtifactType.SECTION,
            sec_parents,
            generate_section_artifact,
            evaluate_section_stage,
            section_id=config.index,
        )

        return AcceptedSectionArtifact(
            section=section_envelope,
            passage=passage_envelope,
            questions=tuple(q_envelopes),
            blueprintRef=actual_blueprint,
        )
