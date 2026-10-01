"""Stable span extraction, Unicode code-point alignment, chunking, and context selection for Langfens Loop Engine V2.

Key guarantees:
- Half-open interval [start, end) on normalized text based on Unicode code points.
- Exact invariant verification: text[start:end] == span.text.
- Bidirectional offset conversions for cross-language compatibility (.NET UTF-16 code units, UTF-8 bytes).
- Context selection with explicit CoverageMap; excerpts are never presented as full source.
- Method to check if a fact or claim's offset falls within selected context coverage.
"""

from __future__ import annotations

import hashlib
import re
from typing import List, Optional, Tuple
from pydantic import BaseModel, ConfigDict, Field


class Span(BaseModel):
    """Stable text span with exact Unicode code-point offsets."""

    model_config = ConfigDict(frozen=True)

    span_id: str
    source_id: str
    start_char: int = Field(..., ge=0)
    end_char: int = Field(..., ge=0)
    text: str
    word_count: int = Field(..., ge=0)


class Chunk(BaseModel):
    """Chunk of text with overlap and span lineage."""

    model_config = ConfigDict(frozen=True)

    chunk_id: str
    index: int
    start_char: int
    end_char: int
    text: str
    word_count: int
    span_ids: List[str] = Field(default_factory=list)


class CoverageMap(BaseModel):
    """Records selected chunks, covered character ranges, and coverage ratio."""

    model_config = ConfigDict(frozen=True)

    total_chars: int
    total_words: int
    covered_ranges: List[Tuple[int, int]]
    selected_span_ids: List[str]
    coverage_ratio: float = Field(..., ge=0.0, le=1.0)
    is_excerpt: bool

    def is_offset_covered(self, start_char: int, end_char: int) -> bool:
        """Returns True if the entire interval [start_char, end_char) falls within covered ranges."""
        if start_char >= end_char:
            return False
        for c_start, c_end in self.covered_ranges:
            if c_start <= start_char and end_char <= c_end:
                return True
        return False


# ── Unicode Cross-Language Offset Conversions ────────────────────────────────

def codepoint_to_utf16_offset(text: str, codepoint_offset: int) -> int:
    """Converts a Unicode code-point index to a UTF-16 code unit offset (.NET string index).

    Characters outside the Basic Multilingual Plane (BMP, code points > 0xFFFF,
    such as emojis and rare CJK symbols) require two 16-bit code units (surrogate pairs).
    """
    if codepoint_offset <= 0:
        return 0
    sub = text[:codepoint_offset]
    # In Python, each code point > 0xFFFF takes 2 UTF-16 code units
    utf16_units = 0
    for ch in sub:
        utf16_units += 2 if ord(ch) > 0xFFFF else 1
    return utf16_units


def utf16_to_codepoint_offset(text: str, utf16_offset: int) -> int:
    """Converts a UTF-16 code unit offset (.NET string index) to a Unicode code-point index."""
    if utf16_offset <= 0:
        return 0
    current_u16 = 0
    for cp_idx, ch in enumerate(text):
        if current_u16 >= utf16_offset:
            return cp_idx
        current_u16 += 2 if ord(ch) > 0xFFFF else 1
    return len(text)


def codepoint_to_utf8_offset(text: str, codepoint_offset: int) -> int:
    """Converts a Unicode code-point index to a UTF-8 byte offset."""
    if codepoint_offset <= 0:
        return 0
    return len(text[:codepoint_offset].encode("utf-8"))


def utf8_to_codepoint_offset(text: str, utf8_offset: int) -> int:
    """Converts a UTF-8 byte offset to a Unicode code-point index."""
    if utf8_offset <= 0:
        return 0
    encoded = text.encode("utf-8")
    sub_bytes = encoded[:utf8_offset]
    return len(sub_bytes.decode("utf-8", errors="ignore"))


# ── Span and Chunk Extraction ───────────────────────────────────────────────

def extract_spans(text: str, source_id: str) -> List[Span]:
    """Splits normalized text into sentences and paragraphs with exact [start, end) offsets.

    Enforces the invariant: text[span.start_char : span.end_char] == span.text.
    """
    spans: List[Span] = []
    if not text:
        return spans

    # Sentence boundary pattern preserving spaces
    sentence_pattern = re.compile(r"([^\n.!?]+(?:[.!?]+|\n+|$))")
    
    current_pos = 0
    for match in sentence_pattern.finditer(text):
        raw_match = match.group(1)
        trimmed = raw_match.strip()
        if not trimmed:
            current_pos = match.end()
            continue

        # Find exact relative start of trimmed text
        start_char = match.start() + raw_match.find(trimmed)
        end_char = start_char + len(trimmed)

        # Invariant assertion
        assert text[start_char:end_char] == trimmed, (
            f"Offset mismatch: expected '{trimmed}', got '{text[start_char:end_char]}'"
        )

        span_id_hash = hashlib.sha256(f"{source_id}:{start_char}:{end_char}:{trimmed}".encode()).hexdigest()[:12]
        spans.append(
            Span(
                span_id=f"span_{span_id_hash}",
                source_id=source_id,
                start_char=start_char,
                end_char=end_char,
                text=trimmed,
                word_count=len(re.findall(r"\b[\w'-]+\b", trimmed)),
            )
        )

    return spans


def create_chunks(
    text: str,
    source_id: str,
    target_words_per_chunk: int = 350,
    overlap_words: int = 50,
) -> List[Chunk]:
    """Chunks normalized text using paragraph and sentence boundaries with defined overlap."""
    spans = extract_spans(text, source_id)
    if not spans:
        return []

    chunks: List[Chunk] = []
    current_spans: List[Span] = []
    current_words = 0
    chunk_index = 0

    idx = 0
    while idx < len(spans):
        span = spans[idx]
        current_spans.append(span)
        current_words += span.word_count

        if current_words >= target_words_per_chunk or idx == len(spans) - 1:
            start_char = current_spans[0].start_char
            end_char = current_spans[-1].end_char
            chunk_text = text[start_char:end_char]

            chunk_id = f"chunk_{source_id}_{chunk_index:03d}"
            chunks.append(
                Chunk(
                    chunk_id=chunk_id,
                    index=chunk_index,
                    start_char=start_char,
                    end_char=end_char,
                    text=chunk_text,
                    word_count=current_words,
                    span_ids=[s.span_id for s in current_spans],
                )
            )
            chunk_index += 1

            if idx == len(spans) - 1:
                break

            # Rewind for overlap
            overlap_accum = 0
            rewind_count = 0
            for s in reversed(current_spans):
                overlap_accum += s.word_count
                rewind_count += 1
                if overlap_accum >= overlap_words:
                    break

            if rewind_count < len(current_spans):
                idx = idx - rewind_count + 1
            else:
                idx += 1

            current_spans = []
            current_words = 0
        else:
            idx += 1

    return chunks


def select_context(
    text: str,
    chunks: List[Chunk],
    selected_chunk_indices: List[int],
) -> CoverageMap:
    """Builds a CoverageMap from selected chunk indices.

    Guarantees:
    - Never presents an excerpt as the full source (is_excerpt is strictly True if any chunk omitted).
    - Records covered ranges and selected span IDs for downstream claim verification.
    """
    total_chars = len(text)
    total_words = len(re.findall(r"\b[\w'-]+\b", text))

    if not chunks:
        return CoverageMap(
            total_chars=total_chars,
            total_words=total_words,
            covered_ranges=[],
            selected_span_ids=[],
            coverage_ratio=0.0,
            is_excerpt=True,
        )

    # Sort and filter indices
    selected_indices = sorted(set(idx for idx in selected_chunk_indices if 0 <= idx < len(chunks)))
    is_excerpt = len(selected_indices) < len(chunks)

    covered_spans: List[str] = []
    raw_ranges: List[Tuple[int, int]] = []

    for idx in selected_indices:
        ch = chunks[idx]
        raw_ranges.append((ch.start_char, ch.end_char))
        covered_spans.extend(ch.span_ids)

    # Merge overlapping or contiguous ranges
    merged_ranges: List[Tuple[int, int]] = []
    if raw_ranges:
        sorted_ranges = sorted(raw_ranges, key=lambda r: r[0])
        curr_start, curr_end = sorted_ranges[0]
        for start, end in sorted_ranges[1:]:
            if start <= curr_end:
                curr_end = max(curr_end, end)
            else:
                merged_ranges.append((curr_start, curr_end))
                curr_start, curr_end = start, end
        merged_ranges.append((curr_start, curr_end))

    covered_chars = sum(end - start for start, end in merged_ranges)
    coverage_ratio = min(1.0, round(covered_chars / max(1, total_chars), 4))

    return CoverageMap(
        total_chars=total_chars,
        total_words=total_words,
        covered_ranges=merged_ranges,
        selected_span_ids=list(dict.fromkeys(covered_spans)),
        coverage_ratio=coverage_ratio,
        is_excerpt=is_excerpt,
    )
