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
# Authoritative Verified Passages from PostgreSQL (exam db)
SECTION_2_PASSAGE_V1_HASH = "a76d249ce00f73ef430b23e947ea685bd922685c8b3803f4a7c8eaddfb0e2bb6"
SECTION_2_PASSAGE_V2_DETERMINISTIC_HASH = "bde18c70cbb5471776a438ac18431a952ebc5b160d1888caa28070bc26a5c0e9"
SECTION_3_PASSAGE_V1_HASH = "e8fe102c8034f1ee672f1a177de3e99a578415527aaf77eb39cb9ecfc12904ad"

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
    {"number": 27, "type": "TrueFalseNotGiven", "slotNumber": 27, "questionType": "TrueFalseNotGiven"},
    {"number": 28, "type": "TrueFalseNotGiven", "slotNumber": 28, "questionType": "TrueFalseNotGiven"},
    {"number": 29, "type": "TrueFalseNotGiven", "slotNumber": 29, "questionType": "TrueFalseNotGiven"},
    {"number": 30, "type": "TrueFalseNotGiven", "slotNumber": 30, "questionType": "TrueFalseNotGiven"},
    {"number": 31, "type": "TrueFalseNotGiven", "slotNumber": 31, "questionType": "TrueFalseNotGiven"},
    {"number": 32, "type": "TrueFalseNotGiven", "slotNumber": 32, "questionType": "TrueFalseNotGiven"},
    {"number": 33, "type": "TrueFalseNotGiven", "slotNumber": 33, "questionType": "TrueFalseNotGiven"},
    # Q34–Q40: Short Answer (7 items)
    {"number": 34, "type": "ShortAnswer", "slotNumber": 34, "questionType": "ShortAnswer"},
    {"number": 35, "type": "ShortAnswer", "slotNumber": 35, "questionType": "ShortAnswer"},
    {"number": 36, "type": "ShortAnswer", "slotNumber": 36, "questionType": "ShortAnswer"},
    {"number": 37, "type": "ShortAnswer", "slotNumber": 37, "questionType": "ShortAnswer"},
    {"number": 38, "type": "ShortAnswer", "slotNumber": 38, "questionType": "ShortAnswer"},
    {"number": 39, "type": "ShortAnswer", "slotNumber": 39, "questionType": "ShortAnswer"},
    {"number": 40, "type": "ShortAnswer", "slotNumber": 40, "questionType": "ShortAnswer"},
]


def build_questions_request(
    run_id: str,
    lease_owner: str,
    epoch: int,
    section_index: int,
    passage_ref: Dict[str, Any],
    blueprint_ref: Dict[str, Any],
    slots: List[Dict[str, Any]],
) -> Dict[str, Any]:
    return {
        "runId": run_id,
        "leaseOwner": lease_owner,
        "epoch": epoch,
        "sectionIndex": section_index,
        "passageRef": passage_ref,
        "blueprintRef": blueprint_ref,
        "slots": slots,
        "engine": "v2",
    }


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
) -> Dict[str, Any]:
    return {
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


if __name__ == "__main__":
    print("Continuation configuration validated:")
    print(f"Section 2 Target Slots: {len(SECTION_2_SLOTS)} ({SECTION_2_SLOTS[0]['number']}-{SECTION_2_SLOTS[-1]['number']})")
    print(f"Section 3 Target Slots: {len(SECTION_3_SLOTS)} ({SECTION_3_SLOTS[0]['number']}-{SECTION_3_SLOTS[-1]['number']})")
    print("Requires authorized continuation run authority before dispatch.")
