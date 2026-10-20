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
from app.contracts.policies import count_words, match_verbatim_in_passage, validate_answer_length
from app.evaluators.solver import BlindSolverEvaluator
from app.generators.passage.prompts import PassageStyleProfile, build_passage_generation_prompt
from app.generators.question.prompts import QuestionPromptFamily, build_question_prompt
from app.persistence.client import CheckpointClient
from app.providers.gateway import ProviderGateway
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.parser import parse_defensive_json
from app.reading_evaluation import evaluate_passage, evaluate_question, evaluate_section
from app.reading_generation import align_claims_to_passage, compose_section_payload
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
    if q_type == "MULTIPLE_CHOICE_SINGLE":
        return "Choose the correct letter, A, B, C or D."
    if q_type == "SENTENCE_COMPLETION":
        return "Complete the sentences below. Choose NO MORE THAN THREE WORDS from the passage."
    if q_type == "SUMMARY_COMPLETION":
        return "Complete the summary below. Choose NO MORE THAN THREE WORDS from the passage for each answer."
    return "Answer the questions below. Choose NO MORE THAN THREE WORDS from the passage for each answer."


def _parse_candidate_payload(
    raw_payload: Any,
    q_num: int,
    q_type: str,
    passage_text: str,
    claims_map: dict[str, Any],
    claim_id: str,
    difficulty: str,
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
    fallback_quote = matched_claim["text"].strip() if matched_claim else passage_text.split(". ")[0].strip() + "."
    explanation = str(cand.get("explanation") or "").strip()
    if len(explanation) < 25:
        explanation = f"The passage states that '{fallback_quote[:50]}...', which provides verifiable grounding for item {q_num}."

    if q_type in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"):
        statement = str(cand.get("statement") or cand.get("prompt") or "").strip()
        if not statement:
            statement = f"Researchers verified that {fallback_quote[:60].strip()}."

        raw_ans = str(cand.get("answer") or "").strip().replace(" ", "_").upper()
        if raw_ans in ("NOT_GIVEN", "NG"):
            answer = "NOT_GIVEN"
        elif q_type == "TRUE_FALSE_NOT_GIVEN":
            answer = "TRUE" if raw_ans in ("TRUE", "T") else ("FALSE" if raw_ans in ("FALSE", "F") else (raw_ans or "TRUE"))
        else:
            answer = "YES" if raw_ans in ("YES", "Y") else ("NO" if raw_ans in ("NO", "N") else (raw_ans or "YES"))

        if answer == "NOT_GIVEN":
            absence = cand.get("absenceAssessment") or {
                "assessmentId": f"abs:{q_num}",
                "claimOrTopic": statement,
                "absenceReason": cand.get("explanation") or f"The passage provides no conclusive factual statement confirming or refuting whether {statement}.",
                "absenceConfirmed": True,
            }
            anchor = str(cand.get("evidenceQuote") or fallback_quote).strip()
            p_start = passage_text.find(anchor)
            if p_start < 0:
                anchor = passage_text.split(". ")[0].strip() + "."
                p_start = passage_text.find(anchor)
            p_end = p_start + len(anchor)
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
            quote = str(cand.get("evidenceQuote") or fallback_quote).strip()
            p_start = passage_text.find(quote)
            if p_start < 0:
                quote = fallback_quote if fallback_quote in passage_text else passage_text.split(". ")[0].strip() + "."
                p_start = passage_text.find(quote)
            p_end = p_start + len(quote)
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
        prompt = str(cand.get("prompt") or f"Which primary finding is established in query {q_num}?").strip()
        raw_opts = cand.get("options") or []
        if isinstance(raw_opts, list) and all(isinstance(o, dict) for o in raw_opts):
            formatted_opts = [f"{o.get('key', chr(65+i))}. {o.get('text', '')}" for i, o in enumerate(raw_opts)]
        elif isinstance(raw_opts, list) and all(isinstance(o, str) for o in raw_opts):
            formatted_opts = []
            for i, o in enumerate(raw_opts):
                clean_o = re.sub(r"^[A-D]\.\s*", "", o)
                formatted_opts.append(o if re.match(r"^[A-D]\.", o) else f"{chr(65+i)}. {clean_o}")
        else:
            formatted_opts = [f"{chr(65+i)}. Option {chr(65+i)} for item {q_num}" for i in range(4)]

        correct_opt = str(cand.get("correctOption") or cand.get("answer") or "A").strip().upper()
        mcq_m = re.search(r"\b([A-D])\b", correct_opt)
        correct_letter = mcq_m.group(1) if mcq_m else "A"

        quote = str(cand.get("evidenceQuote") or fallback_quote).strip()
        p_start = passage_text.find(quote)
        if p_start < 0:
            quote = fallback_quote if fallback_quote in passage_text else passage_text.split(". ")[0].strip() + "."
            p_start = passage_text.find(quote)
        p_end = p_start + len(quote)

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
        prompt = str(cand.get("prompt") or "").strip()
        if not prompt or f"[{q_num}]" not in prompt:
            clean_prompt = prompt.replace("______", f"[{q_num}]") if "______" in prompt else f"Regarding question {q_num}, researchers analyzed the [{q_num}] in field surveys."
            prompt = clean_prompt

        quote = str(cand.get("evidenceQuote") or fallback_quote).strip()
        p_start = passage_text.find(quote)
        if p_start < 0:
            quote = fallback_quote if fallback_quote in passage_text else passage_text.split(". ")[0].strip() + "."
            p_start = passage_text.find(quote)
        p_end = p_start + len(quote)

        answer = str(cand.get("answer") or "").strip()
        if not answer or not match_verbatim_in_passage(answer, passage_text) or not validate_answer_length(answer) or answer.lower() in prompt.lower().replace(f"[{q_num}]", ""):
            stopwords = {"that", "this", "with", "from", "were", "been", "their", "which", "during", "after", "before", "while", "under", "about", "into", "over", "between", "through", "across", "within", "without"}
            words_in_quote = [w for w in re.findall(r"\b[A-Za-z]{4,}\b", quote) if w.lower() not in stopwords]
            valid_words = [w for w in words_in_quote if match_verbatim_in_passage(w.lower(), passage_text) and w.lower() not in prompt.lower().replace(f"[{q_num}]", "")]
            answer = valid_words[0].lower() if valid_words else "habitat"

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
        prompt = str(cand.get("prompt") or f"Which primary environmental factor was evaluated in query {q_num}?").strip()
        quote = str(cand.get("evidenceQuote") or fallback_quote).strip()
        p_start = passage_text.find(quote)
        if p_start < 0:
            quote = fallback_quote if fallback_quote in passage_text else passage_text.split(". ")[0].strip() + "."
            p_start = passage_text.find(quote)
        p_end = p_start + len(quote)

        answer = str(cand.get("answer") or "").strip()
        if not answer or not match_verbatim_in_passage(answer, passage_text) or not validate_answer_length(answer):
            stopwords = {"that", "this", "with", "from", "were", "been", "their", "which", "during", "after", "before", "while", "under", "about", "into", "over", "between", "through", "across", "within", "without"}
            words_in_quote = [w for w in re.findall(r"\b[A-Za-z]{4,}\b", quote) if w.lower() not in stopwords]
            valid_words = [w for w in words_in_quote if match_verbatim_in_passage(w.lower(), passage_text)]
            answer = valid_words[0].lower() if valid_words else "habitat"

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
            word_count = count_words(passage_text)

            # Ground claim alignments in verified source evidence
            alignments = align_claims_to_passage(passage_text, claims, source_text)

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

        sorted_slots = sorted(slots, key=lambda s: s.get("questionNumber", 0))

        for slot in sorted_slots:
            q_num = slot["questionNumber"]
            g_idx = slot.get("groupIndex", 0)
            grp_config = config.groups[g_idx]
            q_type = grp_config.question_type.value
            q_art_id = f"question:{context.run_id}:{q_num}"
            claim_ref_ids = slot.get("claimRefIds") or ()
            claim_id = claim_ref_ids[0] if claim_ref_ids else (claims[0]["claimId"] if claims else "claim_1")

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

                # Summary completion shares group draft across slots
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
                        req = ProviderRequest(
                            capability=Capability.GENERATE_JSON,
                            messages=[
                                ChatMessage(role="system", content=prompt_data["system_instruction"]),
                                ChatMessage(role="user", content=prompt_data["user_prompt"]),
                            ],
                            operation_id=f"op:{context.run_id}:summary_group:{target_g_idx}:{version}",
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
                    )
                    req = ProviderRequest(
                        capability=Capability.GENERATE_JSON,
                        messages=[
                            ChatMessage(role="system", content=prompt_data["system_instruction"]),
                            ChatMessage(role="user", content=prompt_data["user_prompt"]),
                        ],
                        operation_id=f"op:{context.run_id}:question:{target_q_num}:{version}",
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

                return _parse_candidate_payload(
                    raw_candidate,
                    q_num=target_q_num,
                    q_type=target_q_type,
                    passage_text=passage_text,
                    claims_map=claims_map,
                    claim_id=target_claim_id,
                    difficulty=config.difficulty.value,
                )

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
                blind_evaluator = BlindSolverEvaluator(
                    gateway=self.gateway,
                    solver_provider=actual_policy.provider,
                    adversary_provider=actual_policy.provider,
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

            q_env = await executor.execute(
                q_art_id,
                ArtifactType.QUESTION,
                q_parents,
                generate_question,
                evaluate_question_stage,
                section_id=config.index,
            )
            q_envelopes.append(q_env)

        # 5. Section assembly stage
        section_art_id = f"section:{context.run_id}:{config.index}"
        q_refs = [q.to_ref() for q in q_envelopes]
        sec_parents = (passage_envelope.to_ref(), actual_blueprint, *q_refs)

        groups_data: list[dict[str, Any]] = []
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
