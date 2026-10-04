"""Autonomous IELTS Academic Reading Passage Generator (P08-01, P08-03).

Executes generation strictly through the ProviderGateway with budget accounting,
untrusted data encapsulation, and schema validation.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Any, Dict, List, Optional, Sequence
from uuid import UUID, uuid4

from app.contracts.artifact import ArtifactEnvelope, ArtifactType, compute_content_hash
from app.contracts.policies import count_words
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.prompts import (
    PASSAGE_PROMPT_VERSION,
    build_passage_generation_prompt,
)
from app.providers.models import Capability, ChatMessage, ProviderRequest
from app.providers.gateway import ProviderGateway
from app.providers.parser import parse_defensive_json
logger = logging.getLogger(__name__)


class PassageGenerator:
    """Generates IELTS Academic reading passages with strict source grounding."""

    def __init__(self, gateway: ProviderGateway):
        self.gateway = gateway

    async def generate(
        self,
        context: PassageGenerationContext,
        run_id: str,
        version: int = 1,
        target_artifact_id: Optional[str] = None,
        timeout_seconds: float = 120.0,
        lease_owner: Optional[UUID] = None,
        epoch: int = 1,
        parent_operation_id: Optional[str] = None,
        input_dependencies: Optional[Sequence[ArtifactRef]] = None,
        length_feedback: Optional[str] = None,
    ) -> ArtifactEnvelope:
        """Executes passage generation request and returns validated ArtifactEnvelope."""
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

        op_id = f"op_pass_gen_{uuid4().hex[:8]}"
        req = ProviderRequest(
            capability=Capability.GENERATE_TEXT,
            messages=messages,
            operation_id=op_id,
            run_id=run_id,
            parent_operation_id=parent_operation_id,
            max_tokens=3000,
            timeout_seconds=timeout_seconds,
        )

        # Call ProviderGateway strictly (no independent SDK retries)
        if hasattr(self.gateway, "execute"):
            resp = await self.gateway.execute(req, epoch=epoch, lease_owner=lease_owner)
        elif hasattr(self.gateway, "request"):
            resp = await self.gateway.request(req)
        elif hasattr(self.gateway, "call"):
            resp = await self.gateway.call(req)
        else:
            raise AttributeError("Gateway does not have execute, request, or call method")
        raw_text = resp.raw_text.strip()

        # Parse output JSON or fallback to text segmentation
        parsed = self._parse_generation_output(raw_text, context)

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
        """Defensively parses LLM response into structured passage payload."""
        # 1. Standard defensive JSON parser
        try:
            data = parse_defensive_json(raw_text)
            if isinstance(data, dict) and "passage" in data and isinstance(data["passage"], str):
                pass_str = data["passage"].strip()
                paragraphs = data.get("paragraphs")
                if not paragraphs or not isinstance(paragraphs, list):
                    paragraphs = [p.strip() for p in pass_str.split("\n\n") if p.strip()]
                return {
                    "title": data.get("title", f"Passage on {context.topic}"),
                    "passage": pass_str,
                    "paragraphs": paragraphs,
                    "styleProfile": data.get("styleProfile", context.style_profile.value),
                    "claimAlignments": data.get("claimAlignments", []),
                }
        except Exception as e:
            logger.warning("parse_defensive_json failed (%s); trying regex passage field extraction", e)

        # 2. Secondary defensive extraction: regex match of "passage": "..." field
        m_pass = re.search(r"\"passage\"\s*:\s*\"((?:[^\"\\]|\\.)*)\"", raw_text, re.DOTALL)
        if m_pass:
            try:
                extracted_raw = m_pass.group(1)
                extracted = json.loads(f'"{extracted_raw}"').strip()
                paragraphs = [p.strip() for p in extracted.split("\n\n") if p.strip()]
                m_title = re.search(r"\"title\"\s*:\s*\"((?:[^\"\\]|\\.)*)\"", raw_text)
                title_str = json.loads(f'"{m_title.group(1)}"') if m_title else f"Passage on {context.topic}"
                return {
                    "title": title_str,
                    "passage": extracted,
                    "paragraphs": paragraphs,
                    "styleProfile": context.style_profile.value,
                    "claimAlignments": [],
                }
            except Exception as ex_regex:
                logger.warning("Regex passage extraction noticed: %s", ex_regex)

        # 3. Clean raw text fallback: strip markdown blocks and JSON artifacts
        clean_text = re.sub(r"^```[a-zA-Z]*\s*", "", raw_text.strip(), flags=re.MULTILINE)
        clean_text = re.sub(r"```$", "", clean_text.strip(), flags=re.MULTILINE)
        clean_text = re.sub(r"^\{\s*\"[a-zA-Z_]+\"\s*:\s*", "", clean_text.strip())
        paragraphs = [p.strip() for p in clean_text.split("\n\n") if p.strip() and not p.strip().startswith(("{", "}", "[", "]"))]
        if not paragraphs:
            paragraphs = [raw_text.strip()]
        full_text = "\n\n".join(paragraphs)

        return {
            "title": f"Academic Reading: {context.topic}",
            "passage": full_text,
            "paragraphs": paragraphs,
            "styleProfile": context.style_profile.value,
            "claimAlignments": [],
        }
