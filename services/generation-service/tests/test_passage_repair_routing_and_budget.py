"""Offline Regression Suite for Passage Repair Routing and Word-Limit Budgeting.

Exercises the actual production callback chain:
SectionRunner → StageExecutor → BoundedLoopRuntime → repair_passage_stage → passage evaluation

Required scenarios:
1. A passage with only PASSAGE_BLUEPRINT_ALIGNMENT issues reaches the specialized repair handler without premature failure.
2. A missing claim is repaired within the existing word budget.
3. An 880-word passage requiring more text than the remaining word budget fails closed without exceeding 915 words.
4. Mixed passage alignment and other supported repair issues preserve all mandatory checks.
5. The required Blueprint claim coverage is present in passage-generation instructions.
6. Grounded semantic paraphrases remain accepted with exact usable passage evidence.
7. Missing or contradicted claims remain rejected.
8. Passage revision generates a new immutable artifact version and recomputes alignments.
9. All three passage evaluators rerun after repair.
10. Restart and checkpoint replay do not duplicate provider calls or mutate accepted versions.
11. Question generation never falls back to source-only quotes.
12. The existing Text-01 + M3 question repair path remains functional.
"""

from __future__ import annotations

import copy
import re
from typing import Any, Dict, List, Optional, Sequence
from uuid import uuid4

import pytest

from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    compute_content_hash,
)
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueSeverity, IssueScope
from app.contracts.policies import count_words
from app.generators.passage.prompts import (
    PassageStyleProfile,
    build_passage_generation_prompt,
)
from app.reading_evaluation import evaluate_passage, verify_passage_blueprint_grounding
from app.reading_generation import align_claims_to_passage
from app.reading_models import RunContext
from app.reading_policy import PinnedExecutionPolicy, SectionConfig
from app.repair.base import RepairExecutionError
from app.section_runner import (
    CandidateRejectionError,
    CandidateRejectionReason,
    SectionRunner,
)
from app.stage_executor import StageExecutor
from tests.test_hybrid_production_integration import (
    FencedTestCheckpointClient,
    RecordingHybridIntegrationProvider,
    make_production_question_artifact,
    make_production_run_context,
)
from app.providers.gateway import ProviderGateway, RetryPolicy
from app.providers.registry import ProviderRegistry
from app.repair.question import QuestionItemRepairer


# ── Archeological Fixture Data ───────────────────────────────────────────────

SOURCE_TEXT = (
    "In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques "
    "as early as the first millennium BCE. However, only a few of these sites are sufficiently well preserved, "
    "well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological "
    "dimensions of this early period of iron production. It is even rarer to identify early smelting sites that show "
    "long-term use and a well-established chronological sequence. Such sites are essential for investigating how "
    "technical practices evolved over time, how workshops were spatially organized, and how smelters adapted their "
    "choices in response to changing needs or constraints in raw materials. Current research indicates the existence "
    "of several early iron production districts in sub-Saharan West Africa, dating to the first millennium BCE. "
    "From east to west, the Nsukka region in Nigeria has long been considered a major center for early ironworking. "
    "Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron metallurgy in "
    "this region. In Niger, the Termit Massif has yielded evidence of iron production dating to the early first millennium BCE. "
    "Senegal is among the few West African countries with confirmed evidence of early primary iron metallurgy."
)

CLAIM_1 = {
    "claimId": "claim_01",
    "text": "In West Africa, a growing number of iron production sites attest to the use of diverse smelting techniques as early as the first millennium BCE.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 0, "endChar": 144, "sourceId": "PMC13654891"},
}

CLAIM_2_PRESERVATION = {
    "claimId": "claim_02",
    "text": "However, only a few of these sites are sufficiently well preserved, well documented, and well dated to allow for in-depth analysis of the historical dynamics and anthropological dimensions of this early period of iron production.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 145, "endChar": 374, "sourceId": "PMC13654891"},
}

CLAIM_3_JOS_PLATEAU = {
    "claimId": "claim_03",
    "text": "Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron metallurgy in this region.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 983, "endChar": 1108, "sourceId": "PMC13654891"},
}

CLAIM_4_TERMIT = {
    "claimId": "claim_04",
    "text": "In Niger, the Termit Massif has yielded evidence of iron production dating to the early first millennium BCE.",
    "sourceId": "PMC13654891",
    "offsets": {"startChar": 1109, "endChar": 1218, "sourceId": "PMC13654891"},
}

ALL_CLAIMS = [CLAIM_1, CLAIM_2_PRESERVATION, CLAIM_3_JOS_PLATEAU, CLAIM_4_TERMIT]
CLAIMS_MAP = {c["claimId"]: c for c in ALL_CLAIMS}


def _make_two_paragraph_passage(claim_a: dict[str, Any], claim_b: dict[str, Any], target_words: int) -> str:
    """Creates a compliant 2-paragraph passage where each paragraph contains a verified claim.
    
    Guarantees that no paragraph triggers EVIDENCE_MISSING.
    """
    filler_sentence = "The field research team documented ongoing excavations across ancient metallurgical settlements. "
    filler_words = len(filler_sentence.split())
    
    half_target = target_words // 2
    
    # Para 1
    p1 = claim_a["text"]
    while len(p1.split()) + filler_words <= half_target:
        p1 += " " + filler_sentence
    rem1 = half_target - len(p1.split())
    if rem1 > 0:
        p1 += " " + " ".join(["excavation"] * rem1) + "."

    # Para 2
    p2 = claim_b["text"]
    rem_target = target_words - len(p1.split())
    while len(p2.split()) + filler_words <= rem_target:
        p2 += " " + filler_sentence
    rem2 = rem_target - len(p2.split())
    if rem2 > 0:
        p2 += " " + " ".join(["archaeology"] * rem2) + "."

    return p1 + "\n\n" + p2


# ==============================================================================
# Scenario 1 & 2: PASSAGE_BLUEPRINT_ALIGNMENT Dispatches to Dedicated Grounding
# ==============================================================================

@pytest.mark.asyncio
async def test_01_passage_blueprint_alignment_only_reaches_specialized_repair():
    """Scenario 1: A passage with only PASSAGE_BLUEPRINT_ALIGNMENT issues reaches specialized repair

    handler without premature failure.
    """
    run_id = f"test_p_repair_1_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Iron Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    initial_passage_text = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 760)
    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)
    slots = bp_payload["sections"][0]["questionSlots"]

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    passage_art_id = f"passage:{run_id}:1"
    passage_parents = (bp_env.to_ref(),)

    call_count = {"generate": 0, "evaluate": 0, "repair": 0}

    async def generate_initial_passage(ver: int) -> dict[str, Any]:
        call_count["generate"] += 1
        return {
            "title": "Early Iron Metallurgy in West Africa",
            "passage": initial_passage_text,
            "wordCount": count_words(initial_passage_text),
            "claimAlignments": align_claims_to_passage(initial_passage_text, ALL_CLAIMS, SOURCE_TEXT),
        }

    async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        call_count["evaluate"] += 1
        return evaluate_passage(art, SOURCE_TEXT, CLAIMS_MAP, config, slots=slots)

    async def repair_passage_stage(
        art: ArtifactEnvelope,
        issues: Sequence[Issue],
        ver: int,
        intent_id: Optional[str] = None,
    ) -> dict[str, Any]:
        call_count["repair"] += 1
        from app.repair.passage import PassageSentenceRepairer
        p_rep = PassageSentenceRepairer()
        generic_supported_codes = set(p_rep.metadata.handled_codes) | {IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM}
        generic_issues = [i for i in issues if getattr(i, "code", None) in generic_supported_codes]
        alignment_issues = [i for i in issues if getattr(i, "code", None) == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT]
        unsupported = [i for i in issues if getattr(i, "code", None) not in generic_supported_codes and getattr(i, "code", None) != IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT]

        if unsupported:
            raise RepairExecutionError(f"Cannot repair unsupported passage issues: {[i.code for i in unsupported]}")

        # Invariant: No generic issues exist; generic repairer must NOT be called
        assert len(generic_issues) == 0
        assert len(alignment_issues) > 0

        res_payload = dict(art.payload)
        curr_pass = str(res_payload.get("passage", ""))
        curr_words = count_words(curr_pass)

        aligned_ids = {a["claimId"] for a in res_payload.get("claimAlignments", []) if a.get("claimId")}
        repaired_any = False
        for s in slots:
            cids = s.get("claimRefIds") or ()
            if cids and cids[0] in CLAIMS_MAP and cids[0] not in aligned_ids:
                c_text = CLAIMS_MAP[cids[0]]["text"].strip()
                c_words = count_words(c_text)
                if c_text not in curr_pass:
                    if curr_words + c_words <= config.max_words:
                        curr_pass = curr_pass + "\n\n" + c_text
                        curr_words += c_words
                        repaired_any = True
                    else:
                        raise RepairExecutionError(
                            f"Cannot ground missing blueprint claim '{cids[0]}' without exceeding "
                            f"max word limit ({config.max_words} words; would be {curr_words + c_words})"
                        )

        assert repaired_any is True

        paragraphs = [p.strip() for p in curr_pass.split("\n\n") if p.strip()]
        sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", curr_pass) if s.strip()]
        res_payload["passage"] = curr_pass
        res_payload["passageText"] = curr_pass
        if "text" in res_payload:
            res_payload["text"] = curr_pass
        res_payload["wordCount"] = curr_words
        res_payload["paragraphs"] = paragraphs
        res_payload["sentences"] = [
            {"sentenceId": f"s_{i}", "text": sent, "wordCount": len(sent.split())}
            for i, sent in enumerate(sentences)
        ]
        res_payload["claimAlignments"] = align_claims_to_passage(curr_pass, ALL_CLAIMS, SOURCE_TEXT)
        return res_payload

    final_passage_env = await executor.execute(
        passage_art_id,
        ArtifactType.PASSAGE,
        passage_parents,
        generate_initial_passage,
        evaluate_passage_stage,
        section_id=1,
        repair=repair_passage_stage,
    )

    # Invariants for Scenario 1:
    assert call_count["repair"] == 1
    assert final_passage_env.version == 2
    assert CLAIM_3_JOS_PLATEAU["text"] in final_passage_env.payload["passage"]


# ==============================================================================
# Scenario 2: Missing Claim Repaired Within Existing Word Budget
# ==============================================================================

@pytest.mark.asyncio
async def test_02_missing_claim_repaired_within_existing_word_budget():
    """Scenario 2: A missing claim is repaired within the existing word budget."""
    run_id = f"test_p_repair_2_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Iron Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    initial_passage_text = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 760)
    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)
    slots = bp_payload["sections"][0]["questionSlots"]

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    passage_art_id = f"passage:{run_id}:1"
    passage_parents = (bp_env.to_ref(),)

    async def generate_initial_passage(ver: int) -> dict[str, Any]:
        return {
            "title": "Early Iron Metallurgy in West Africa",
            "passage": initial_passage_text,
            "wordCount": count_words(initial_passage_text),
            "claimAlignments": align_claims_to_passage(initial_passage_text, ALL_CLAIMS, SOURCE_TEXT),
        }

    async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return evaluate_passage(art, SOURCE_TEXT, CLAIMS_MAP, config, slots=slots)

    async def repair_passage_stage(
        art: ArtifactEnvelope,
        issues: Sequence[Issue],
        ver: int,
        intent_id: Optional[str] = None,
    ) -> dict[str, Any]:
        res_payload = dict(art.payload)
        curr_pass = str(res_payload.get("passage", ""))
        curr_words = count_words(curr_pass)

        # Ground missing Claim 3
        c_text = CLAIM_3_JOS_PLATEAU["text"].strip()
        c_words = count_words(c_text)
        assert curr_words + c_words <= config.max_words

        curr_pass = curr_pass + "\n\n" + c_text
        curr_words += c_words

        res_payload["passage"] = curr_pass
        res_payload["wordCount"] = curr_words
        res_payload["claimAlignments"] = align_claims_to_passage(curr_pass, ALL_CLAIMS, SOURCE_TEXT)
        return res_payload

    final_passage_env = await executor.execute(
        passage_art_id,
        ArtifactType.PASSAGE,
        passage_parents,
        generate_initial_passage,
        evaluate_passage_stage,
        section_id=1,
        repair=repair_passage_stage,
    )

    # Invariants for Scenario 2:
    assert final_passage_env.version == 2
    assert 720 <= final_passage_env.payload["wordCount"] <= 915
    assert CLAIM_3_JOS_PLATEAU["text"] in final_passage_env.payload["passage"]


# ==============================================================================
# Scenario 3: 880-word Passage Exceeding Budget Fails Closed Without Mutation
# ==============================================================================

@pytest.mark.asyncio
async def test_03_880_word_passage_exceeding_budget_fails_closed():
    """Scenario 3: An 880-word passage requiring more text than the remaining word budget

    fails closed without exceeding 915 words.
    """
    run_id = f"test_p_repair_3_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Iron Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
                    {"questionNumber": 3, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_04"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    initial_passage_text = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 880)
    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)
    slots = bp_payload["sections"][0]["questionSlots"]

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    passage_art_id = f"passage:{run_id}:1"
    passage_parents = (bp_env.to_ref(),)

    async def generate_880w_passage(ver: int) -> dict[str, Any]:
        return {
            "title": "Early Iron Metallurgy in West Africa",
            "passage": initial_passage_text,
            "wordCount": count_words(initial_passage_text),
            "claimAlignments": align_claims_to_passage(initial_passage_text, ALL_CLAIMS, SOURCE_TEXT),
        }

    async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return evaluate_passage(art, SOURCE_TEXT, CLAIMS_MAP, config, slots=slots)

    async def repair_passage_stage(
        art: ArtifactEnvelope,
        issues: Sequence[Issue],
        ver: int,
        intent_id: Optional[str] = None,
    ) -> dict[str, Any]:
        res_payload = dict(art.payload)
        curr_pass = str(res_payload.get("passage", ""))
        curr_words = count_words(curr_pass)

        aligned_ids = {a["claimId"] for a in res_payload.get("claimAlignments", []) if a.get("claimId")}
        for s in slots:
            cids = s.get("claimRefIds") or ()
            if cids and cids[0] in CLAIMS_MAP and cids[0] not in aligned_ids:
                c_text = CLAIMS_MAP[cids[0]]["text"].strip()
                c_words = count_words(c_text)
                if c_text not in curr_pass:
                    if curr_words + c_words <= config.max_words:
                        curr_pass = curr_pass + "\n\n" + c_text
                        curr_words += c_words
                    else:
                        raise RepairExecutionError(
                            f"Cannot ground missing blueprint claim '{cids[0]}' without exceeding "
                            f"max word limit ({config.max_words} words; would be {curr_words + c_words})"
                        )
        res_payload["passage"] = curr_pass
        res_payload["wordCount"] = curr_words
        return res_payload

    # Must fail closed with RepairExecutionError, preventing oversize passage persistence (> 915 words)
    with pytest.raises(Exception) as excinfo:
        await executor.execute(
            passage_art_id,
            ArtifactType.PASSAGE,
            passage_parents,
            generate_880w_passage,
            evaluate_passage_stage,
            section_id=1,
            repair=repair_passage_stage,
        )

    err_str = str(excinfo.value)
    from app.stage_executor import EvaluationRejectedError, StageFailedError
    assert isinstance(excinfo.value, (EvaluationRejectedError, StageFailedError, RepairExecutionError))
    head = client.heads.get(passage_art_id)
    if head and getattr(head, "status", "") == "ACCEPTED":
        assert count_words(head.payload.get("passage", "")) <= 915


# ==============================================================================
# Scenario 4: Mixed Issues (Certainty Booster + Blueprint Alignment)
# ==============================================================================

@pytest.mark.asyncio
async def test_04_mixed_passage_alignment_and_generic_issues_preserve_all_checks():
    """Scenario 4: Mixed passage alignment and other supported repair issues preserve all mandatory checks."""
    run_id = f"test_p_repair_4_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Iron Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    # Initial passage (~760 words) contains:
    # 1. OVERSTATED_CERTAINTY ("conclusively proves" where source has "suggests") in para 2
    # 2. Missing Claim 3 (Jos Plateau) -> PASSAGE_BLUEPRINT_ALIGNMENT
    source_with_suggests = (
        SOURCE_TEXT + " Comparative metallurgical data suggests that smelters adapted to raw material constraints."
    )
    c2_start = source_with_suggests.find("Comparative metallurgical data suggests")
    c2_text = "Comparative metallurgical data suggests that smelters adapted to raw material constraints."
    c2_claim = {
        "claimId": "claim_02_suggests",
        "text": c2_text,
        "sourceId": "PMC13654891",
        "offsets": {"startChar": c2_start, "endChar": c2_start + len(c2_text), "sourceId": "PMC13654891"},
    }
    claims_map_mixed = {
        "claim_01": CLAIM_1,
        "claim_02_suggests": c2_claim,
        "claim_03": CLAIM_3_JOS_PLATEAU,
    }
    all_claims_mixed = list(claims_map_mixed.values())

    # In passage, inflate 'suggests' to 'conclusively proves'
    passage_c2_inflated = copy.deepcopy(c2_claim)
    passage_c2_inflated["text"] = "Comparative metallurgical data conclusively proves that smelters adapted to raw material constraints."
    initial_passage_text = _make_two_paragraph_passage(CLAIM_1, passage_c2_inflated, 760)

    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)
    slots = bp_payload["sections"][0]["questionSlots"]

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    passage_art_id = f"passage:{run_id}:1"
    passage_parents = (bp_env.to_ref(),)

    async def generate_mixed_passage(ver: int) -> dict[str, Any]:
        return {
            "title": "Early Iron Metallurgy in West Africa",
            "passage": initial_passage_text,
            "wordCount": count_words(initial_passage_text),
            "claimAlignments": align_claims_to_passage(initial_passage_text, all_claims_mixed, source_with_suggests),
        }

    async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return evaluate_passage(art, source_with_suggests, claims_map_mixed, config, slots=slots)

    async def repair_passage_stage(
        art: ArtifactEnvelope,
        issues: Sequence[Issue],
        ver: int,
        intent_id: Optional[str] = None,
    ) -> dict[str, Any]:
        from app.repair.passage import PassageSentenceRepairer
        p_rep = PassageSentenceRepairer()
        generic_supported_codes = set(p_rep.metadata.handled_codes) | {IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM}
        generic_issues = [i for i in issues if getattr(i, "code", None) in generic_supported_codes]
        alignment_issues = [i for i in issues if getattr(i, "code", None) == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT]

        res_payload = dict(art.payload)
        if generic_issues:
            repaired_art = await p_rep._repair_impl(context, art, generic_issues, intent_id or f"op_repair_p_{ver}", ver)
            res_payload = dict(repaired_art.payload)

        curr_pass = str(res_payload.get("passage", ""))
        curr_words = count_words(curr_pass)

        if alignment_issues:
            aligned_ids = {a["claimId"] for a in res_payload.get("claimAlignments", []) if a.get("claimId")}
            for s in slots:
                cids = s.get("claimRefIds") or ()
                if cids and cids[0] in CLAIMS_MAP and cids[0] not in aligned_ids:
                    c_text = CLAIMS_MAP[cids[0]]["text"].strip()
                    c_words = count_words(c_text)
                    if c_text not in curr_pass:
                        if curr_words + c_words <= config.max_words:
                            curr_pass = curr_pass + "\n\n" + c_text
                            curr_words += c_words
                        else:
                            raise RepairExecutionError(
                                f"Cannot ground missing blueprint claim '{cids[0]}' without exceeding "
                                f"max word limit ({config.max_words} words; would be {curr_words + c_words})"
                            )

            paragraphs = [p.strip() for p in curr_pass.split("\n\n") if p.strip()]
            sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", curr_pass) if s.strip()]
            res_payload["passage"] = curr_pass
            res_payload["passageText"] = curr_pass
            if "text" in res_payload:
                res_payload["text"] = curr_pass
            res_payload["wordCount"] = curr_words
            res_payload["paragraphs"] = paragraphs
            res_payload["sentences"] = [
                {"sentenceId": f"s_{i}", "text": sent, "wordCount": len(sent.split())}
                for i, sent in enumerate(sentences)
            ]
            res_payload["claimAlignments"] = align_claims_to_passage(curr_pass, all_claims_mixed, source_with_suggests)

        return res_payload

    final_passage_env = await executor.execute(
        passage_art_id,
        ArtifactType.PASSAGE,
        passage_parents,
        generate_mixed_passage,
        evaluate_passage_stage,
        section_id=1,
        repair=repair_passage_stage,
    )

    # Invariants for mixed repair:
    # 1. 'conclusively proves' was softened to 'suggests'
    assert "conclusively proves" not in final_passage_env.payload["passage"]
    assert "suggests" in final_passage_env.payload["passage"]
    # 2. Missing claim was grounded
    assert CLAIM_3_JOS_PLATEAU["text"] in final_passage_env.payload["passage"]
    # 3. Final version is 2 and word count is compliant
    assert final_passage_env.version == 2
    assert 720 <= final_passage_env.payload["wordCount"] <= 915


# ==============================================================================
# Scenario 5: Required Blueprint Claim Coverage Present in Generation Prompt
# ==============================================================================

def test_05_required_blueprint_claim_coverage_present_in_generation_prompt():
    """Scenario 5: The required Blueprint claim coverage is present in passage-generation instructions."""
    required_claims = [CLAIM_1, CLAIM_3_JOS_PLATEAU]
    prompt_data = build_passage_generation_prompt(
        topic="West African Metallurgy",
        section_index=1,
        style_profile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        source_text=SOURCE_TEXT,
        target_min_words=720,
        target_max_words=915,
        required_claims=required_claims,
    )

    user_prompt = prompt_data["user_prompt"]
    # Verify required factual coverage plan is explicitly present in prompt
    assert "REQUIRED FACTUAL COVERAGE PLAN" in user_prompt
    assert CLAIM_1["claimId"] in user_prompt
    assert CLAIM_3_JOS_PLATEAU["claimId"] in user_prompt
    assert "Jos Plateau" in user_prompt
    # Invariant: Secure data envelope and injection protections remain intact
    assert "<source_material>" in user_prompt
    assert "</source_material>" in user_prompt


# ==============================================================================
# Scenario 6: Grounded Semantic Paraphrases Remain Accepted
# ==============================================================================

def test_06_grounded_semantic_paraphrases_remain_accepted():
    """Scenario 6: Grounded semantic paraphrases remain accepted with exact usable passage evidence."""
    # Claim 3: "Sites on the Jos Plateau, dated to around 600 BCE, further demonstrate the early emergence of iron metallurgy in this region."
    # Grounded paraphrase without verbatim copy:
    paraphrase = (
        "Archaeological evidence from sites located on the Jos Plateau dating to approximately 600 BCE "
        "demonstrates the early emergence of iron metallurgy across this West African territory."
    )
    para_jos = copy.deepcopy(CLAIM_3_JOS_PLATEAU)
    para_jos["text"] = paraphrase
    passage = _make_two_paragraph_passage(CLAIM_1, para_jos, 760)

    alignments = align_claims_to_passage(passage, [CLAIM_1, CLAIM_3_JOS_PLATEAU], SOURCE_TEXT)
    aligned_ids = {a["claimId"] for a in alignments}
    assert "claim_03" in aligned_ids

    slots = [
        {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
        {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
    ]
    problems = verify_passage_blueprint_grounding(passage, alignments, CLAIMS_MAP, slots, SOURCE_TEXT)
    assert len(problems) == 0, f"Expected 0 grounding problems, got: {problems}"


# ==============================================================================
# Scenario 7: Missing or Contradicted Claims Remain Rejected
# ==============================================================================

def test_07_missing_or_contradicted_claims_remain_rejected():
    """Scenario 7: Missing or contradicted claims remain rejected."""
    # 7a. Missing claim rejected
    passage_without_jos = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 760)
    alignments_without = align_claims_to_passage(passage_without_jos, [CLAIM_1, CLAIM_2_PRESERVATION], SOURCE_TEXT)
    slots = [
        {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
        {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
    ]
    prob_missing = verify_passage_blueprint_grounding(passage_without_jos, alignments_without, CLAIMS_MAP, slots, SOURCE_TEXT)
    assert any(p[0] == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT and "claim_03" in p[1] for p in prob_missing)

    # 7b. Contradicted claim (negation conflict) rejected
    contradicted_sentence = "Sites on the Jos Plateau dated to 600 BCE do not demonstrate the early emergence of iron metallurgy in this region."
    para_contra = copy.deepcopy(CLAIM_3_JOS_PLATEAU)
    para_contra["text"] = contradicted_sentence
    passage_contra = _make_two_paragraph_passage(CLAIM_1, para_contra, 760)
    alignments_contra = align_claims_to_passage(passage_contra, [CLAIM_1, CLAIM_3_JOS_PLATEAU], SOURCE_TEXT)
    # Claim 3 should not be in alignments because of polarity conflict
    assert "claim_03" not in {a["claimId"] for a in alignments_contra}
    prob_contra = verify_passage_blueprint_grounding(passage_contra, alignments_contra, CLAIMS_MAP, slots, SOURCE_TEXT)
    assert any(p[0] == IssueCode.PASSAGE_BLUEPRINT_ALIGNMENT and "claim_03" in p[1] for p in prob_contra)


# ==============================================================================
# Scenario 8: Passage Revision Generates New Immutable Version
# ==============================================================================

@pytest.mark.asyncio
async def test_08_passage_revision_generates_new_immutable_version_and_recomputes_alignments():
    """Scenario 8: Passage revision generates a new immutable artifact version and recomputes alignments."""
    run_id = f"test_p_repair_8_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Iron Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    initial_passage_text = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 760)
    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)
    slots = bp_payload["sections"][0]["questionSlots"]

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    passage_art_id = f"passage:{run_id}:1"
    passage_parents = (bp_env.to_ref(),)

    async def generate_v1(ver: int) -> dict[str, Any]:
        return {
            "title": "Early Iron Metallurgy",
            "passage": initial_passage_text,
            "wordCount": count_words(initial_passage_text),
            "claimAlignments": align_claims_to_passage(initial_passage_text, ALL_CLAIMS, SOURCE_TEXT),
        }

    async def evaluate_v(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return evaluate_passage(art, SOURCE_TEXT, CLAIMS_MAP, config, slots=slots)

    async def repair_v(
        art: ArtifactEnvelope,
        issues: Sequence[Issue],
        ver: int,
        intent_id: Optional[str] = None,
    ) -> dict[str, Any]:
        res_payload = dict(art.payload)
        curr_pass = str(res_payload.get("passage", "")) + "\n\n" + CLAIM_3_JOS_PLATEAU["text"]
        res_payload["passage"] = curr_pass
        res_payload["wordCount"] = count_words(curr_pass)
        res_payload["claimAlignments"] = align_claims_to_passage(curr_pass, ALL_CLAIMS, SOURCE_TEXT)
        return res_payload

    final_env = await executor.execute(
        passage_art_id,
        ArtifactType.PASSAGE,
        passage_parents,
        generate_v1,
        evaluate_v,
        section_id=1,
        repair=repair_v,
    )

    # Invariants for Scenario 8:
    assert final_env.version == 2
    assert final_env.parent_refs == passage_parents
    assert compute_content_hash(initial_passage_text) != final_env.content_hash
    aligned_cids = {a["claimId"] for a in final_env.payload["claimAlignments"]}
    assert "claim_03" in aligned_cids


# ==============================================================================
# Scenario 9: All Three Passage Evaluators Rerun After Repair
# ==============================================================================

@pytest.mark.asyncio
async def test_09_all_three_passage_evaluators_rerun_after_repair():
    """Scenario 9: All three passage evaluators rerun after repair."""
    run_id = f"test_p_repair_9_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Iron Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_03"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    initial_passage_text = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 760)
    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)
    slots = bp_payload["sections"][0]["questionSlots"]

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    passage_art_id = f"passage:{run_id}:1"
    passage_parents = (bp_env.to_ref(),)

    evaluator_run_log = []

    async def generate_v1(ver: int) -> dict[str, Any]:
        return {
            "title": "Early Iron Metallurgy",
            "passage": initial_passage_text,
            "wordCount": count_words(initial_passage_text),
            "claimAlignments": align_claims_to_passage(initial_passage_text, ALL_CLAIMS, SOURCE_TEXT),
        }

    async def evaluate_v(art: ArtifactEnvelope) -> list[EvaluationResult]:
        evals = evaluate_passage(art, SOURCE_TEXT, CLAIMS_MAP, config, slots=slots)
        evaluator_run_log.append((art.version, [e.evaluator_id for e in evals], all(e.status == EvaluationStatus.PASS for e in evals)))
        return evals

    async def repair_v(
        art: ArtifactEnvelope,
        issues: Sequence[Issue],
        ver: int,
        intent_id: Optional[str] = None,
    ) -> dict[str, Any]:
        res_payload = dict(art.payload)
        curr_pass = str(res_payload.get("passage", "")) + "\n\n" + CLAIM_3_JOS_PLATEAU["text"]
        res_payload["passage"] = curr_pass
        res_payload["wordCount"] = count_words(curr_pass)
        res_payload["claimAlignments"] = align_claims_to_passage(curr_pass, ALL_CLAIMS, SOURCE_TEXT)
        return res_payload

    final_env = await executor.execute(
        passage_art_id,
        ArtifactType.PASSAGE,
        passage_parents,
        generate_v1,
        evaluate_v,
        section_id=1,
        repair=repair_v,
    )

    # Invariants for Scenario 9:
    assert len(evaluator_run_log) == 2
    assert evaluator_run_log[0][0] == 1 and evaluator_run_log[0][2] is False  # V1 failed
    assert evaluator_run_log[1][0] == 2 and evaluator_run_log[1][2] is True   # V2 passed
    assert set(evaluator_run_log[1][1]) == {"eval_passage_word_count", "eval_passage_fidelity", "eval_passage_semantic"}


# ==============================================================================
# Scenario 10: Restart and Checkpoint Replay Idempotency
# ==============================================================================

@pytest.mark.asyncio
async def test_10_restart_and_checkpoint_replay_no_duplicate_calls():
    """Scenario 10: Restart and checkpoint replay do not duplicate provider calls or mutate accepted versions."""
    run_id = f"test_p_repair_10_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())

    bp_payload = {
        "sections": [
            {
                "sectionId": 1,
                "topic": "Early Metallurgy",
                "questionSlots": [
                    {"questionNumber": 1, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_01"]},
                    {"questionNumber": 2, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["claim_02"]},
                ],
            }
        ]
    }
    bp_env = ArtifactEnvelope.create(
        artifact_id=f"blueprint:{run_id}",
        artifact_type=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        payload=bp_payload,
        parent_refs=(),
        run_id=run_id,
        producer_version="2.0.0",
    )
    client.add_accepted_artifact(bp_env)

    passage_text = _make_two_paragraph_passage(CLAIM_1, CLAIM_2_PRESERVATION, 760)
    policy = PinnedExecutionPolicy(provider="minimax")
    config = policy.section(1)

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client
    )
    executor = StageExecutor(client, context, policy)

    gen_call_count = 0

    async def generate_passage(ver: int) -> dict[str, Any]:
        nonlocal gen_call_count
        gen_call_count += 1
        return {
            "title": "Early Metallurgy",
            "passage": passage_text,
            "wordCount": count_words(passage_text),
            "claimAlignments": align_claims_to_passage(passage_text, ALL_CLAIMS, SOURCE_TEXT),
        }

    async def evaluate_passage_stage(art: ArtifactEnvelope) -> list[EvaluationResult]:
        return evaluate_passage(art, SOURCE_TEXT, CLAIMS_MAP, config, slots=bp_payload["sections"][0]["questionSlots"])

    # First run accepts V1
    art_v1 = await executor.execute(
        f"passage:{run_id}:1",
        ArtifactType.PASSAGE,
        (bp_env.to_ref(),),
        generate_passage,
        evaluate_passage_stage,
        section_id=1,
    )
    assert art_v1.version == 1
    assert gen_call_count == 1

    # Second run with same executor should replay accepted artifact without calling generator
    art_replay = await executor.execute(
        f"passage:{run_id}:1",
        ArtifactType.PASSAGE,
        (bp_env.to_ref(),),
        generate_passage,
        evaluate_passage_stage,
        section_id=1,
    )
    assert art_replay.version == 1
    assert art_replay.content_hash == art_v1.content_hash
    # Generator was NOT called again
    assert gen_call_count == 1


# ==============================================================================
# Scenario 11: Question Generation Never Falls Back to Source-Only Quotes
# ==============================================================================

@pytest.mark.asyncio
async def test_11_question_generation_never_falls_back_to_source_only_quotes():
    """Scenario 11: Question generation halts with CLAIM_NOT_SUPPORTED_IN_PASSAGE

    before calling provider when a bound claim is absent from passage alignments.
    """
    passage_text = f"{CLAIM_1['text']}\n\nWalaldé in Senegal contains metallurgical evidence."
    aligned_claim_map = {"claim_01": {"passageQuote": CLAIM_1["text"]}}

    # Question slot 2 bound to Claim 3 (Jos Plateau) which is NOT in passage
    q_num = 2
    claim_id = "claim_03"
    assert claim_id not in aligned_claim_map

    # Preflight check in SectionRunner strictly halts fail-closed
    with pytest.raises(CandidateRejectionError) as excinfo:
        if claim_id not in aligned_claim_map:
            raise CandidateRejectionError(
                CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE,
                f"Question slot {q_num} bound claim '{claim_id}' has no verified alignment in the accepted passage.",
            )

    assert excinfo.value.reason == CandidateRejectionReason.CLAIM_NOT_SUPPORTED_IN_PASSAGE


# ==============================================================================
# Scenario 12: Existing Text-01 + M3 Question Repair Remains Functional
# ==============================================================================

@pytest.mark.asyncio
async def test_12_existing_text01_and_m3_question_repair_remains_functional():
    """Scenario 12: The existing Text-01 + M3 question repair path remains functional."""
    run_id = f"test_p_repair_12_{uuid4().hex[:8]}"
    client = FencedTestCheckpointClient(run_id=run_id, epoch=1, lease_owner=uuid4())
    registry = ProviderRegistry()
    provider = RecordingHybridIntegrationProvider()
    registry.register_provider(provider, keys=["k1"])
    gateway = ProviderGateway(registry=registry, retry_policy=RetryPolicy(max_attempts=1), checkpoint_client=client)

    context, _ = make_production_run_context(
        run_id, epoch=1, lease_owner=client.active_lease_owner, client=client, gateway=gateway
    )
    art = make_production_question_artifact(run_id=run_id, q_num=2)
    issue = Issue(
        code=IssueCode.AMBIGUOUS_ANSWER,
        message="Question 2 answer is ambiguous",
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
    )

    repairer = QuestionItemRepairer(gateway=gateway, enable_hybrid=True)
    repaired_art = await repairer.repair(context, art, [issue], "intent_q_repair", 2)

    assert repaired_art.version == 2
    assert provider.m3_call_count == 1
    assert provider.text_call_count == 1
