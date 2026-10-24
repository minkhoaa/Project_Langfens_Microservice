"""Autonomous IELTS Generation — Continuation Flow for Sections 2 & 3.

Executes Question Candidate generation and Section assembly for:
- Section 2 (PMC9640808): Q14–Q26 (6 Multiple Choice + 7 Summary Completion)
- Section 3 (PMC8556156): Q27–Q40 (7 Yes/No/Not Given + 7 Short Answer)

Invariants:
1. Reuses committed academic passages (art_passage_s2:v2, art_passage_s3:v1).
2. Zero passage re-generation.
3. Strict 100,000 tokens/section and 900s/section wall-time limits.
4. Requires active, lease-fenced authority from exam-service CheckpointService.
"""

import asyncio
import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional

# Budget Invariants: Strict 100k tokens and 900s per section
SECTION_MAX_TOKENS = 100_000
SECTION_MAX_WALL_TIME_SECONDS = 900.0

# Authoritative Verified Passages from PostgreSQL (exam db)
SECTION_2_PASSAGE_V1_HASH = "a76d249ce00f73ef430b23e947ea685bd922685c8b3803f4a7c8eaddfb0e2bb6"
SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH = "63d5991ce36d7dba3b956f69fa49ed1401d8cbef18d1f09ac43e537030194e39"
SECTION_3_PASSAGE_V1_HASH = "e8fe102c8034f1ee672f1a177de3e99a578415527aaf77eb39cb9ecfc12904ad"

SECTION_2_BLUEPRINT_V1_HASH = "2a7864200c7e9f524cc5e5602626ab7884017011327e1e8b21955e0278822de9"
SECTION_3_BLUEPRINT_V1_HASH = "2773e562d63310ee148c390b038c666aa7a94ac81ddb9f047f84809031b99a9a"

SECTION_2_SLOTS = [
    # Q14–Q19: Multiple Choice (6 items)
    {"number": 14, "type": "MultipleChoice", "slotNumber": 14, "questionType": "MultipleChoice"},
    {"number": 15, "type": "MultipleChoice", "slotNumber": 15, "questionType": "MultipleChoice"},
    {"number": 16, "type": "MultipleChoice", "slotNumber": 16, "questionType": "MultipleChoice"},
    {"number": 17, "type": "MultipleChoice", "slotNumber": 17, "questionType": "MultipleChoice"},
    {"number": 18, "type": "MultipleChoice", "slotNumber": 18, "questionType": "MultipleChoice"},
    {"number": 19, "type": "MultipleChoice", "slotNumber": 19, "questionType": "MultipleChoice"},
    # Q20–Q26: Summary Completion (7 items)
    {"number": 20, "type": "SummaryCompletion", "slotNumber": 20, "questionType": "SummaryCompletion"},
    {"number": 21, "type": "SummaryCompletion", "slotNumber": 21, "questionType": "SummaryCompletion"},
    {"number": 22, "type": "SummaryCompletion", "slotNumber": 22, "questionType": "SummaryCompletion"},
    {"number": 23, "type": "SummaryCompletion", "slotNumber": 23, "questionType": "SummaryCompletion"},
    {"number": 24, "type": "SummaryCompletion", "slotNumber": 24, "questionType": "SummaryCompletion"},
    {"number": 25, "type": "SummaryCompletion", "slotNumber": 25, "questionType": "SummaryCompletion"},
    {"number": 26, "type": "SummaryCompletion", "slotNumber": 26, "questionType": "SummaryCompletion"},
]

SECTION_3_SLOTS = [
    # Q27–Q33: Yes / No / Not Given (7 items)
    {"number": 27, "type": "YesNoNotGiven", "slotNumber": 27, "questionType": "YesNoNotGiven"},
    {"number": 28, "type": "YesNoNotGiven", "slotNumber": 28, "questionType": "YesNoNotGiven"},
    {"number": 29, "type": "YesNoNotGiven", "slotNumber": 29, "questionType": "YesNoNotGiven"},
    {"number": 30, "type": "YesNoNotGiven", "slotNumber": 30, "questionType": "YesNoNotGiven"},
    {"number": 31, "type": "YesNoNotGiven", "slotNumber": 31, "questionType": "YesNoNotGiven"},
    {"number": 32, "type": "YesNoNotGiven", "slotNumber": 32, "questionType": "YesNoNotGiven"},
    {"number": 33, "type": "YesNoNotGiven", "slotNumber": 33, "questionType": "YesNoNotGiven"},
    # Q34–Q40: Short Answer (7 items)
    {"number": 34, "type": "ShortAnswer", "slotNumber": 34, "questionType": "ShortAnswer"},
    {"number": 35, "type": "ShortAnswer", "slotNumber": 35, "questionType": "ShortAnswer"},
    {"number": 36, "type": "ShortAnswer", "slotNumber": 36, "questionType": "ShortAnswer"},
    {"number": 37, "type": "ShortAnswer", "slotNumber": 37, "questionType": "ShortAnswer"},
    {"number": 38, "type": "ShortAnswer", "slotNumber": 38, "questionType": "ShortAnswer"},
    {"number": 39, "type": "ShortAnswer", "slotNumber": 39, "questionType": "ShortAnswer"},
    {"number": 40, "type": "ShortAnswer", "slotNumber": 40, "questionType": "ShortAnswer"},
]


def validate_cumulative_budget(
    prior_tokens: int,
    prior_wall_time: float,
    requested_tokens: int = 0,
    requested_wall_time: float = 0.0,
) -> bool:
    """Validates that cumulative usage plus requested reservations fit within section budget caps."""
    total_tokens = prior_tokens + requested_tokens
    total_wall_time = prior_wall_time + requested_wall_time
    if total_tokens > SECTION_MAX_TOKENS:
        raise ValueError(
            f"Section cumulative token limit exceeded: {total_tokens} > {SECTION_MAX_TOKENS} "
            f"(prior: {prior_tokens}, requested: {requested_tokens})"
        )
    if total_wall_time > SECTION_MAX_WALL_TIME_SECONDS:
        raise ValueError(
            f"Section cumulative wall time limit exceeded: {total_wall_time:.1f}s > {SECTION_MAX_WALL_TIME_SECONDS}s "
            f"(prior: {prior_wall_time:.1f}s, requested: {requested_wall_time:.1f}s)"
        )
    return True


def get_verified_passage_envelope(section_index: int, version: Optional[int] = None) -> Dict[str, Any]:
    """Loads the immutable, validated passage artifact envelope for the section."""
    v = version or (2 if section_index == 2 else 1)
    artifact_file = Path(__file__).resolve().parent / "artifacts" / "continuation" / f"art_passage_s{section_index}_v{v}.json"
    if not artifact_file.exists():
        raise FileNotFoundError(f"Authoritative passage artifact file missing: {artifact_file}")
    with open(artifact_file, "r", encoding="utf-8") as f:
        data = json.load(f)
    expected_hash = SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH if (section_index == 2 and v == 2) else (
        SECTION_2_PASSAGE_V1_HASH if (section_index == 2 and v == 1) else SECTION_3_PASSAGE_V1_HASH
    )
    if data.get("contentHash") != expected_hash:
        raise ValueError(f"Passage envelope hash mismatch for s{section_index}: expected {expected_hash}, got {data.get('contentHash')}")
    return data


def build_checkpoint_import_request(
    run_id: str,
    lease_owner: str,
    epoch: int,
    artifact: Dict[str, Any],
    source_run_id: Optional[str] = None,
) -> Dict[str, Any]:
    return {
        "runId": run_id,
        "leaseOwner": lease_owner,
        "epoch": epoch,
        "artifact": artifact,
        "sourceRunId": source_run_id,
    }


def build_questions_request(
    run_id: str,
    lease_owner: str,
    epoch: int,
    section_index: int,
    passage_ref: Dict[str, Any],
    blueprint_ref: Dict[str, Any],
    slots: List[Dict[str, Any]],
    passage_envelope: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    payload: Dict[str, Any] = {
        "runId": run_id,
        "leaseOwner": lease_owner,
        "epoch": epoch,
        "sectionIndex": section_index,
        "passageRef": passage_ref,
        "blueprintRef": blueprint_ref,
        "slots": slots,
        "engine": "v2",
    }
    if passage_envelope is not None:
        payload["passageEnvelope"] = passage_envelope
    return payload


def build_section_assembly_request(
    run_id: str,
    lease_owner: str,
    epoch: int,
    section_index: int,
    title: str,
    passage_ref: Dict[str, Any],
    blueprint_ref: Dict[str, Any],
    question_refs: List[Dict[str, Any]],
    source: Dict[str, Any] | None = None,
    passage_envelope: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    payload: Dict[str, Any] = {
        "runId": run_id,
        "leaseOwner": lease_owner,
        "epoch": epoch,
        "sectionIndex": section_index,
        "title": title,
        "passageRef": passage_ref,
        "blueprintRef": blueprint_ref,
        "questionRefs": question_refs,
        "source": source,
        "engine": "v2",
    }
    if passage_envelope is not None:
        payload["passageEnvelope"] = passage_envelope
    return payload


if __name__ == "__main__":
    print("Continuation configuration validated:")
    print(f"Section 2 Target Slots: {len(SECTION_2_SLOTS)} ({SECTION_2_SLOTS[0]['number']}-{SECTION_2_SLOTS[-1]['number']})")
    print(f"Section 3 Target Slots: {len(SECTION_3_SLOTS)} ({SECTION_3_SLOTS[0]['number']}-{SECTION_3_SLOTS[-1]['number']})")
    print("Requires authorized continuation run authority before dispatch.")
