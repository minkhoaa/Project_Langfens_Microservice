"""Passage-level surgical repairers for Langfens Loop Engine V2."""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Sequence, Union
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
                    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
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

        def _soften_certainty(txt: str) -> str:
            out = re.sub(r"\b(proves|conclusively proves)\b", "suggests", txt, flags=re.IGNORECASE)
            out = re.sub(r"\b(definitely|certainly|undoubtedly|indisputably|conclusively)\b", "likely", out, flags=re.IGNORECASE)
            out = re.sub(r"\bwill definitely\b", "may", out, flags=re.IGNORECASE)
            out = re.sub(r"\bclearly established\b", "indicated", out, flags=re.IGNORECASE)
            out = re.sub(r"\bindisputable\b", "plausible", out, flags=re.IGNORECASE)
            out = re.sub(r"\balways\b", "frequently", out, flags=re.IGNORECASE)
            out = re.sub(r"\b(permanently|forever)\b", "consistently", out, flags=re.IGNORECASE)
            out = re.sub(r"\bwill\b", "may", out, flags=re.IGNORECASE)
            out = re.sub(r"\bcan be\b", "may be", out, flags=re.IGNORECASE)
            out = re.sub(r"\bis known to\b", "is believed to", out, flags=re.IGNORECASE)
            return out

        def _soften_causality(txt: str) -> str:
            out = re.sub(r"\bcauses\b", "is associated with", txt, flags=re.IGNORECASE)
            out = re.sub(r"\bcaused\b", "was associated with", out, flags=re.IGNORECASE)
            out = re.sub(r"\bleads to\b", "is linked to", out, flags=re.IGNORECASE)
            out = re.sub(r"\bled to\b", "was linked to", out, flags=re.IGNORECASE)
            out = re.sub(r"\bresults in\b", "correlates with", out, flags=re.IGNORECASE)
            return out

        claims_modified = False
        for iss in issues:
            if iss.code == IssueCode.OVERSTATED_CERTAINTY:
                repaired_text = _soften_certainty(repaired_text)
                if isinstance(payload.get("claims"), list):
                    for clm in payload["claims"]:
                        if isinstance(clm, dict):
                            for k in ("claimText", "text", "claim_text"):
                                if k in clm and isinstance(clm[k], str):
                                    new_c = _soften_certainty(clm[k])
                                    if new_c != clm[k]:
                                        clm[k] = new_c
                                        claims_modified = True
            elif iss.code == IssueCode.CAUSAL_OVERSTATEMENT:
                repaired_text = _soften_causality(repaired_text)
                repaired_text = _soften_certainty(repaired_text)
                if isinstance(payload.get("claims"), list):
                    for clm in payload["claims"]:
                        if isinstance(clm, dict):
                            for k in ("claimText", "text", "claim_text"):
                                if k in clm and isinstance(clm[k], str):
                                    new_c = _soften_causality(clm[k])
                                    if new_c != clm[k]:
                                        clm[k] = new_c
                                        claims_modified = True

            elif iss.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM:
                m_inv = re.search(r"Invented quantity detected: claim asserts '([^']+)'", iss.message)
                if m_inv:
                    inv_quant = m_inv.group(1).strip()
                    if inv_quant:
                        repaired_text = re.sub(
                            r"\s*\([^)]*\b" + re.escape(inv_quant) + r"\b[^)]*\)",
                            "",
                            repaired_text,
                        )
                        repaired_text = re.sub(
                            r"\b(?:in\s+)?" + re.escape(inv_quant) + r"\b",
                            "",
                            repaired_text,
                        )
                        repaired_text = re.sub(r"  +", " ", repaired_text)
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
                        if s_ngrams:
                            overlap = len(s_ngrams & repaired_ngrams) / len(s_ngrams)
                            if overlap < 0.40:
                                s_soft = _soften_certainty(s)
                                s_cnt = len(s_soft.split())
                                if curr_words + s_cnt <= 915:
                                    added_sentences.append(s_soft)
                                    curr_words += s_cnt
                                    repaired_ngrams.update(s_ngrams)
                                    if curr_words >= 750:
                                        break

                    if curr_words >= 720 and added_sentences:
                        chunked_paras = [
                            " ".join(added_sentences[i : i + 4])
                            for i in range(0, len(added_sentences), 4)
                        ]
                        repaired_text = _soften_certainty(repaired_text.rstrip()) + "\n\n" + "\n\n".join(chunked_paras)
                    else:
                        raise RepairExecutionError(
                            f"Cannot expand short passage ({words} words < 720): insufficient verified unexpressed material in source"
                        )

            elif iss.code == IssueCode.UNMEASURED_OUTCOME:
                # Invariant: Modal/causal replacement does not validate unmeasured outcomes.
                raise RepairExecutionError(
                    "Unmeasured outcome cannot be repaired without verified source material; requires bounded escalation"
                )
        if repaired_text == passage_text and not claims_modified:
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
        if "text" in payload:
            payload["text"] = repaired_text
        payload["wordCount"] = len(repaired_text.split())
        payload["paragraphs"] = paragraphs
        payload["sentences"] = new_sentences_list
        return artifact.create_next_version(new_payload=payload, producer_version="2.0.0")


def compute_passage_edit_invalidation(
    edited_span: tuple[int, int],
    questions: Sequence[Union[dict[str, Any], Any]],
) -> tuple[list[str], list[str]]:
    """Computes conservative downstream question invalidation closure based on passage edits.

    Compares the edited passage text character range [edit_start, edit_end] against
    each question's evidence spans.
    - Supports both plural (`evidence_spans`, `evidenceSpans`) and singular (`evidence_span`, `evidenceSpan`).
    - Handles single span tuple/list [start, end] and multi-span list [[start, end], ...].
    - Handles both dict and object question formats.
    - Zero-width point insertions inside/at span boundaries (start <= edit_point <= end) are affected.
    - If evidence spans are absent, empty, or cannot be determined, fail-closed conservatism
      requires the question to be treated as invalidated.

    Returns: (invalidated_question_ids, unaffected_question_ids)
    """
    edit_start, edit_end = edited_span
    invalidated: list[str] = []
    unaffected: list[str] = []

    for q in questions:
        if isinstance(q, dict):
            q_id = str(q.get("id") or q.get("questionId") or q.get("number") or "")
            raw_spans = (
                q.get("evidence_spans")
                or q.get("evidenceSpans")
                or q.get("evidence_span")
                or q.get("evidenceSpan")
            )
        else:
            q_id = str(
                getattr(q, "id", None)
                or getattr(q, "questionId", None)
                or getattr(q, "number", "")
                or ""
            )
            raw_spans = (
                getattr(q, "evidence_spans", None)
                or getattr(q, "evidenceSpans", None)
                or getattr(q, "evidence_span", None)
                or getattr(q, "evidenceSpan", None)
            )

        if not raw_spans:
            invalidated.append(q_id)
            continue

        # Normalize raw_spans into list of parsed (start, end) tuples
        parsed_spans: list[tuple[int, int]] = []
        if isinstance(raw_spans, (list, tuple)):
            if len(raw_spans) >= 2 and all(isinstance(x, (int, float)) for x in raw_spans[:2]):
                # Single span tuple/list e.g. (10, 50)
                parsed_spans.append((int(raw_spans[0]), int(raw_spans[1])))
            else:
                for item in raw_spans:
                    if isinstance(item, (list, tuple)) and len(item) >= 2:
                        parsed_spans.append((int(item[0]), int(item[1])))
                    elif isinstance(item, dict):
                        s = item.get("start")
                        e = item.get("end")
                        if s is not None and e is not None:
                            parsed_spans.append((int(s), int(e)))
                    elif hasattr(item, "start") and hasattr(item, "end"):
                        parsed_spans.append((int(getattr(item, "start")), int(getattr(item, "end"))))
        elif isinstance(raw_spans, dict):
            s = raw_spans.get("start")
            e = raw_spans.get("end")
            if s is not None and e is not None:
                parsed_spans.append((int(s), int(e)))
        elif hasattr(raw_spans, "start") and hasattr(raw_spans, "end"):
            parsed_spans.append((int(getattr(raw_spans, "start")), int(getattr(raw_spans, "end"))))

        if not parsed_spans:
            # Spans could not be determined; fail-closed conservative invalidation
            invalidated.append(q_id)
            continue

        is_affected = False
        for s_start, s_end in parsed_spans:
            # Overlap condition:
            # 1. Standard interval overlap: max(edit_start, s_start) < min(edit_end, s_end)
            # 2. Point edit (edit_start == edit_end): point falls inside/at boundary: s_start <= edit_start <= s_end
            # 3. Exact matching boundaries
            if edit_start == edit_end:
                if s_start <= edit_start <= s_end:
                    is_affected = True
                    break
            else:
                if max(edit_start, s_start) < min(edit_end, s_end) or (edit_start == s_start and edit_end == s_end):
                    is_affected = True
                    break

        if is_affected:
            invalidated.append(q_id)
        else:
            unaffected.append(q_id)

    return invalidated, unaffected
