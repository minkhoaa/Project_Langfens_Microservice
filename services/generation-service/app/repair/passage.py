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
                repairer_version="2.0.0",
                name="Passage Sentence & Fidelity Repairer",
                description="Softens over-certain modals, corrects causal overstatements, and trims excessive word counts",
                scope=RepairScope.PASSAGE,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.PASSAGE],
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
        passage_text = payload.get("passage", "") or payload.get("passageText", "") or payload.get("text", "")

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
                words = len(repaired_text.split())
                if words > 915:
                    # Sentence-aware trimming (P08-07): never slice mid-sentence!
                    trimmed_candidate = None
                    sentence_matches = list(re.finditer(r"[.!?](?:\s+|$)", repaired_text))
                    for match in reversed(sentence_matches):
                        candidate = repaired_text[:match.end()].strip()
                        cand_words = len(candidate.split())
                        if 750 <= cand_words <= 900:
                            trimmed_candidate = candidate
                            break
                        elif 720 <= cand_words <= 915 and trimmed_candidate is None:
                            trimmed_candidate = candidate
                    if trimmed_candidate is not None:
                        repaired_text = trimmed_candidate
                    else:
                        raise RepairExecutionError(
                            f"Oversize passage ({words} words) cannot be trimmed cleanly at sentence boundaries "
                            "within policy [720, 915]; requires bounded regeneration"
                        )
                elif words < 720:
                    source_text = payload.get("sourceText") or payload.get("source_text") or ""
                    if not source_text and hasattr(context, "input_dependencies"):
                        for dep in getattr(context, "input_dependencies", ()):
                            if hasattr(dep, "payload"):
                                source_text = dep.payload.get("sourceText") or dep.payload.get("source_text") or ""
                                if source_text:
                                    break

                    if not source_text or len(source_text.split()) < 20:
                        raise RepairExecutionError(
                            f"Cannot pad short passage ({words} words < 720) without verified source evidence; requires regeneration"
                        )

                    # Extract verified sentences from source text not yet expressed in repaired_text
                    def _extract_ngrams(text_str: str, n: int = 4) -> set:
                        toks = [w.lower() for w in re.findall(r"\b\w+\b", text_str)]
                        return set(zip(*[toks[i:] for i in range(n)])) if len(toks) >= n else set()

                    repaired_ngrams = _extract_ngrams(repaired_text, 4)

                    src_sentences = [
                        s.strip() for s in re.split(r"(?<=[.!?])\s+", source_text)
                        if 8 <= len(s.strip().split()) <= 50
                        and not s.strip().startswith(("This work", "Júnia", "Alexandre", "Address correspondence", "The authors declare"))
                        and not any(term in s for term in ("http://", "https://", "BioProject", "BioSample", "SRX24", "Zenodo", "Grant number", "contract number", "Email:"))
                    ]
                    added_sentences = []
                    curr_words = words
                    for s in src_sentences:
                        s_ngrams = _extract_ngrams(s, 4)
                        # If 4-grams don't overlap, sentence is unexpressed
                        if s_ngrams and not (s_ngrams & repaired_ngrams):
                            s_cnt = len(s.split())
                            if curr_words + s_cnt <= 915:
                                added_sentences.append(s)
                                curr_words += s_cnt
                                # Update ngrams so we don't add duplicate source content
                                repaired_ngrams.update(s_ngrams)
                                if curr_words >= 750:
                                    break

                    if curr_words >= 720 and added_sentences:
                        repaired_text = repaired_text.rstrip() + "\n\n" + " ".join(added_sentences)
                    else:
                        raise RepairExecutionError(
                            f"Cannot expand short passage ({words} words < 720): insufficient verified unexpressed material in source"
                        )

            elif iss.code == IssueCode.UNMEASURED_OUTCOME:
                # Invariant: Modal/causal replacement does not validate unmeasured outcomes.
                raise RepairExecutionError(
                    "Unmeasured outcome cannot be repaired without verified source material; requires bounded escalation"
                )
        if repaired_text == passage_text:
            raise RepairExecutionError(
                "No evidence-backed transformation could be applied to passage; no ungrounded mutation permitted"
            )

        paragraphs = [p.strip() for p in repaired_text.split("\n\n") if p.strip()]
        sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", repaired_text) if s.strip()]
        new_sentences_list = [
            {"sentenceId": f"s_{i}", "text": sent, "wordCount": len(sent.split())}
            for i, sent in enumerate(sentences)
        ]

        payload["passage"] = repaired_text
        payload["passageText"] = repaired_text
        payload["wordCount"] = len(repaired_text.split())
        payload["paragraphs"] = paragraphs
        payload["sentences"] = new_sentences_list
        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")
