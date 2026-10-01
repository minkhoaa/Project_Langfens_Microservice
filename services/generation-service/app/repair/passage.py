"""Passage-level surgical repairers for Langfens Loop Engine V2."""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Sequence
from datetime import datetime, timezone

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactType, compute_content_hash
from app.contracts.issue import Issue, IssueCode
from app.repair.base import (
    BaseRepairer,
    RepairCapabilityMetadata,
    RepairExecutionError,
    RepairScope,
)
from app.repair.question import unwrap_payload


class PassageSentenceRepairer(BaseRepairer):
    """Surgically repairs passage sentences to resolve certainty/causal overstatements or word bounds.
    
    Hard invariant: Does NOT fabricate facts or pad short passages with ungrounded claims.
    If no evidence-backed transformation is available, raises RepairExecutionError to fail/escalate.
    """

    def __init__(
        self,
        timeout_seconds: Optional[float] = None,
        estimated_tokens: Optional[int] = None,
    ):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "repair_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "repair_max_tokens_per_attempt", 2000)
        super().__init__(
            RepairCapabilityMetadata(
                repairer_id="rep_passage_sentence",
                repairer_version="1.0.0",
                name="Passage Sentence & Fidelity Repairer",
                description="Softens over-certain modals, corrects causal overstatements, and trims excessive word counts",
                scope=RepairScope.PASSAGE,
                target_artifact_types=[ArtifactType.SECTION],
                handled_codes={
                    IssueCode.OVERSTATED_CERTAINTY,
                    IssueCode.CAUSAL_OVERSTATEMENT,
                    IssueCode.UNMEASURED_OUTCOME,
                    IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
                },
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.02,
            )
        )

    async def _repair_impl(
        self,
        context: Any,
        artifact: ArtifactEnvelope,
        issues: Sequence[Issue],
        intent_id: str,
        version: int,
    ) -> ArtifactEnvelope:
        payload = unwrap_payload(artifact.payload)
        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        repaired_text = passage_text

        for iss in issues:
            if iss.code == IssueCode.OVERSTATED_CERTAINTY:
                # Soften certainty terms into tentative academic modals
                repaired_text = re.sub(r"\bproves\b", "suggests", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bwill definitely\b", "may", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bclearly established\b", "indicated", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bindisputable\b", "plausible", repaired_text, flags=re.IGNORECASE)

            elif iss.code == IssueCode.CAUSAL_OVERSTATEMENT:
                # Soften direct causation into correlation/association
                repaired_text = re.sub(r"\bcauses\b", "is associated with", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bcaused\b", "was associated with", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bleads to\b", "is linked to", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bled to\b", "was linked to", repaired_text, flags=re.IGNORECASE)
                repaired_text = re.sub(r"\bresults in\b", "correlates with", repaired_text, flags=re.IGNORECASE)

            elif iss.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS:
                words = repaired_text.split()
                if len(words) > 915:
                    # Trim excessive concluding words back to 900
                    repaired_text = " ".join(words[:900]).rstrip(".") + "."
                elif len(words) < 720:
                    # Invariant: Never pad passage with generic fabricated facts
                    raise RepairExecutionError(
                        f"Cannot pad short passage ({len(words)} words < 720) without verified source evidence; requires regeneration"
                    )

        if repaired_text == passage_text:
            raise RepairExecutionError(
                "No evidence-backed transformation could be applied to passage; no ungrounded mutation permitted"
            )

        if "passage" in payload:
            payload["passage"] = repaired_text
        if "passageText" in payload:
            payload["passageText"] = repaired_text

        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")
