"""Focused unit tests for Phase 15 V2 generator, prompt, parser, and selector fixes.

Covers:
1. SummaryCompletion per-blank survival, sub-span verbatim repair, placeholder-only
   leakage scrubbing, and strict target-slot isolation (no sibling answer pollution
   or compressed-list positional shift).
2. Defensive JSON parser tolerance for duplicate 'passage' keys and hybrid
   'candidates' vs 'blanks' SummaryCompletion payloads.
3. SummaryCompletion prompt contract invariants.
4. PassageGenerator length_feedback / evaluator-issue threading and raw text preservation.
5. Passage prompt constraints against certainty boosters, causal overstatement, and invented years.
6. CandidateSelector rejection of self-leakage and predicate-matched cross-prompt answer leakage.
7. CandidateSelector rejection of >0.45 5-word shingle overlap against external_prompts.
8. SentenceCompletion / ShortAnswer verbatim sub-span repair.
"""

from __future__ import annotations

import json
from typing import Any, Dict, List, Optional
from uuid import uuid4

import pytest

from app.contracts.artifact import ArtifactRef, ArtifactType
from app.contracts.issue import IssueScope
from app.generators.passage.context import PassageGenerationContext
from app.generators.passage.generator import PassageGenerator, _merge_duplicate_passage_keys
from app.generators.passage.prompts import (
    PassageStyleProfile,
    build_passage_generation_prompt,
)
from app.generators.question.context import (
    QuestionCandidate,
    QuestionCandidatePool,
)
from app.generators.question.generator import (
    QuestionCandidateGenerator,
    normalize_question_generation_payload,
)
from app.generators.question.prompts import (
    QuestionPromptFamily,
    build_question_prompt,
)
from app.loop.context import AuthorityGrant, LoopContext
from app.providers.models import ProviderRequest, ProviderResponse, UsageReport
from app.providers.parser import parse_defensive_json
from app.selection.selector import CandidateSelector


def _make_refs() -> tuple[ArtifactRef, ArtifactRef]:
    p_ref = ArtifactRef(
        artifactId="art_passage_dev",
        version=1,
        artifactType=ArtifactType.PASSAGE,
        contentHash="1" * 64,
    )
    bp_ref = ArtifactRef(
        artifactId="art_blueprint_dev",
        version=1,
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        contentHash="2" * 64,
    )
    return p_ref, bp_ref


def _make_loop_context(run_id: str = "bench_dev_unit") -> LoopContext:
    return LoopContext(
        runId=run_id,
        targetArtifactId="art_q_slot_20",
        targetArtifactType=ArtifactType.QUESTION,
        scope=IssueScope.QUESTION,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

class _StubGateway:
    """Minimal stub gateway returning a canned raw JSON string."""

    def __init__(self, raw_text: str):
        self.raw_text = raw_text
        self.requests: List[ProviderRequest] = []

    async def execute(
        self,
        req: ProviderRequest,
        epoch: int = 1,
        lease_owner: Optional[Any] = None,
    ) -> ProviderResponse:
        self.requests.append(req)
        return ProviderResponse(
            operation_id=req.operation_id,
            provider_name="stub",
            model_name="stub-model",
            raw_text=self.raw_text,
            usage=UsageReport(prompt_tokens=100, completion_tokens=200, total_tokens=300),
            latency_seconds=0.05,
        )


@pytest.mark.asyncio
async def test_summary_completion_per_blank_survival_and_target_slot_isolation():
    """One invalid/empty blank does not discard valid blanks, and Q20 pool only gets Q20's blank.

    An empty-answer blank with no slot-matched direct candidate is NOT recoverable: the
    evidenceQuote identifies the source SENTENCE, not which words fill that blank, so mining a
    span from it would synthesise an answer rather than recover one. Such a blank is dropped and
    the engine must instead regenerate or fall back at the loop level. What must always hold:
    one bad blank never discards the other valid blanks, and each slot pool contains only that
    slot's own answer (no positional shifting of Q22's answer into Q21).
    """
    passage = (
        "Estuarine wetlands regulate tidal sediment transport through dense root matrices. "
        "Field coring campaigns collected forty-two core profiles across three salinity gradients. "
        "Samples were preserved using cryogenic freezing aboard the survey barge before laboratory assay. "
        "Spectrometric calibration relied on automated optical sensors to quantify suspended particulates."
    )
    summary_payload = {
        "summaryTitle": "Estuarine Wetland Survey",
        "summaryText": (
            "Estuarine wetlands stabilize sediment movement via [1]. "
            "Researchers gathered [2] across distinct zones during the seasonal campaign. "
            "Field teams applied [3] on the vessel, while [4] measured particulate levels."
        ),
        "blanks": [
            {
                "number": 20,
                "placeholder": "[1]",
                "answer": "root matrices",
                "evidenceQuote": "Estuarine wetlands regulate tidal sediment transport through dense root matrices.",
            },
            {
                "number": 21,
                "placeholder": "[2]",
                "answer": "",  # Empty/invalid blank that must be dropped without shifting slot 22 into 21
                "evidenceQuote": "Field coring campaigns collected forty-two core profiles across three salinity gradients.",
            },
            {
                "number": 22,
                "placeholder": "[3]",
                "answer": "cryogenic freezing aboard the survey",  # 5 words -> repaired to <=3 verbatim span
                "evidenceQuote": "Samples were preserved using cryogenic freezing aboard the survey barge before laboratory assay.",
            },
            {
                "number": 23,
                "placeholder": "[4]",
                "answer": "automated optical (AO) sensors",  # parenthetical not in passage -> repaired
                "evidenceQuote": "Spectrometric calibration relied on automated optical sensors to quantify suspended particulates.",
            },
        ],
    }
    p_ref, bp_ref = _make_refs()
    ctx = _make_loop_context()
    gw = _StubGateway(json.dumps(summary_payload))
    gen = QuestionCandidateGenerator(gateway=gw)

    # 1. Request slot Q20: must receive ONLY Q20's candidate ("root matrices"), not Q22/Q23 answers
    pool_q20 = await gen.generate_candidate_pool(
        passage_text=passage,
        question_type="SummaryCompletion",
        question_number=20,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        run_id=ctx.run_id,
        context=ctx,
        group_start_number=20,
        blank_count=4,
    )
    assert len(pool_q20.candidates) == 1
    assert pool_q20.candidates[0].answer == "root matrices"
    assert pool_q20.candidates[0].is_eligible()
    assert "root matrices" not in pool_q20.candidates[0].prompt.lower()
    assert "[1]" in pool_q20.candidates[0].prompt
    assert 21 in pool_q20.dropped_blank_reasons
    assert gen._last_summary_parsed is not None
    kept_nums = [b["number"] for b in gen._last_summary_parsed["blanks"]]
    assert kept_nums == [20, 22, 23]

    # 2. Request the starved slot Q21: it has no defensible answer and must NOT positionally steal
    #    Q22's answer. Recovery at this point belongs to the loop (regenerate / SentenceCompletion
    #    fallback), not to span-mining the evidenceQuote.
    pool_q21 = await gen.generate_candidate_pool(
        passage_text=passage,
        question_type="SummaryCompletion",
        question_number=21,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        run_id=ctx.run_id,
        context=ctx,
        group_start_number=20,
        blank_count=4,
    )
    assert len(pool_q21.candidates) == 0


def test_parser_tolerates_candidates_and_top_level_blanks_and_duplicate_passage_keys():
    """Parser preserves multi-paragraph duplicate 'passage' keys and normalizes wrapped 'blanks' payloads."""
    raw_dup_passage = (
        '{\n'
        '  "title": "Glacial Hydrology",\n'
        '  "passage": "First paragraph on subglacial drainage channels.",\n'
        '  "passage": "Second paragraph on basal water pressure fluctuations.",\n'
        '  "passage": "Third paragraph on seasonal meltwater routing."\n'
        '}'
    )
    parsed_passage = parse_defensive_json(_merge_duplicate_passage_keys(raw_dup_passage))
    assert "First paragraph" in parsed_passage["passage"]
    assert "Second paragraph" in parsed_passage["passage"]
    assert "Third paragraph" in parsed_passage["passage"]
    assert parsed_passage["passage"].count("\n\n") == 2

    wrapped_summary = {
        "candidates": [
            {
                "summaryTitle": "Subglacial Channels",
                "summaryText": "Meltwater flows through [1] under high [2].",
                "blanks": [
                    {"number": 20, "placeholder": "[1]", "text": ["drainage", "channels"]},
                    "malformed_non_dict_entry",
                    {"number": 21, "placeholder": "[2]", "answer": "  basal water pressure  "},
                ],
            },
            {
                "questionNumber": 21,
                "prompt": "Unvalidated sibling candidate that must not pollute Q20",
                "answer": "basal water pressure",
            },
        ]
    }
    norm = normalize_question_generation_payload(wrapped_summary, keep_question_number=20)
    assert norm["summaryTitle"] == "Subglacial Channels"
    assert len(norm["blanks"]) == 2
    assert norm["blanks"][0]["answer"] == "drainage channels"
    assert norm["blanks"][1]["answer"] == "basal water pressure"
    assert norm["candidates"] == []


def test_summary_completion_prompt_contract_constraints():
    """SummaryCompletion prompt explicitly enforces 1-3 words, distinct answers, and anti-leakage."""
    prompt_data = build_question_prompt(
        family=QuestionPromptFamily.SUMMARY_COMPLETION,
        passage_text="Sample passage text on acoustic telemetry.",
        question_number=20,
        blank_count=7,
    )
    sys_inst = prompt_data["system_instruction"].lower()
    user_p = prompt_data["user_prompt"].lower()
    assert "1-3 words maximum" in sys_inst
    assert "never appear anywhere in the summarytext" in sys_inst
    assert "mutually distinct" in user_p
    assert "[7]" in user_p


@pytest.mark.asyncio
async def test_passage_generator_threads_length_and_issue_feedback_without_mutating_prose():
    """PassageGenerator threads length/issue feedback into prompt and preserves raw passage prose."""
    p_ref, bp_ref = _make_refs()
    eg_ref = ArtifactRef(
        artifactId="art_eg_dev",
        version=1,
        artifactType=ArtifactType.EVIDENCE_GRAPH,
        contentHash="3" * 64,
    )
    raw_passage = "Paragraph one states that methods are not always applicable.\n\nParagraph two notes findings in 1998."
    gw = _StubGateway(
        json.dumps(
            {
                "title": "Observatory Calibration",
                "passage": raw_passage,
                "styleProfile": "EXPOSITORY_SCIENTIFIC",
            }
        )
    )
    gen = PassageGenerator(gateway=gw)
    ctx = PassageGenerationContext(
        blueprintRef=bp_ref,
        evidenceGraphRef=eg_ref,
        sectionIndex=3,
        topic="Observatory Calibration",
        sourceText="Verified source text with sufficient length describing observatory detector calibration and spectral extraction.",
        lastAttemptWordCount=640,
        lastAttemptEvaluatorIssues=["OVERSTATED_CERTAINTY: avoid extreme boosters"],
    )
    env = await gen.generate(context=ctx, run_id="bench_dev_passage", version=2)
    sent_user_prompt = gw.requests[0].messages[1].content
    assert "640 words" in sent_user_prompt
    assert "OVERSTATED_CERTAINTY" in sent_user_prompt
    # Raw prose must not be silently rewritten by the generator
    assert "not always applicable" in env.payload["passage"]
    assert "in 1998" in env.payload["passage"]
    assert ctx.last_attempt_word_count == 640
    assert gen._last_attempt_word_count == env.payload["wordCount"]
def test_passage_prompt_forbids_boosters_causal_overstatement_and_invented_years():
    """Passage system instruction forbids certainty boosters, causal overstatements, and inferred years."""
    prompt_data = build_passage_generation_prompt(
        topic="Thermohaline Circulation",
        section_index=2,
        style_profile=PassageStyleProfile.EXPOSITORY_SCIENTIFIC,
        source_text="Source text on ocean salinity gradients.",
    )
    sys_inst = prompt_data["system_instruction"]
    assert "not always" in sys_inst
    assert "inferred calendar years" in sys_inst
    assert "NEVER repeat the 'passage' key" in sys_inst


def test_selector_rejects_self_leakage_and_predicate_matched_cross_prompt_leakage():
    """Selector rejects self-leaking candidates and cross-prompt leakage with shared predicate (e.g. 'in situ')."""
    p_ref, bp_ref = _make_refs()
    selector = CandidateSelector()

    # Self-leaking completion candidate is immediately ineligible
    self_leaking = QuestionCandidate(
        candidateId="cand_self_leak",
        slotId="slot_q8",
        passageRef=p_ref,
        blueprintRef=bp_ref,
        questionNumber=8,
        questionType="SentenceCompletion",
        prompt="The catalytic reaction proceeds in situ under elevated pressure ______.",
        answer="in situ",
        evidenceQuote="The catalytic reaction proceeds in situ under elevated pressure regimes.",
    )
    assert not self_leaking.is_eligible()

    # Cross-prompt leakage against external_prompts (Q7 TFNG prompt leaks Q8's 2-word answer "in situ")
    external_q7_prompt = "The catalytic reaction operates on substrates where the crystal phase is formed in situ."
    pool_q8 = QuestionCandidatePool(slotId="slot_q8", questionNumber=8, questionType="SentenceCompletion", poolLimit=3)
    pool_q8.add_candidate(
        QuestionCandidate(
            candidateId="cand_q8_10_leaking",
            slotId="slot_q8",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=8,
            questionType="SentenceCompletion",
            prompt="The catalytic reaction operates exclusively on substrates where the crystal phase is formed ______.",
            answer="in situ",
            evidenceQuote="The catalytic reaction operates exclusively on substrates where the crystal phase is formed in situ.",
        )
    )
    pool_q8.add_candidate(
        QuestionCandidate(
            candidateId="cand_q8_1_clean",
            slotId="slot_q8",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=8,
            questionType="SentenceCompletion",
            prompt="Thermal annealing suppresses ______ across the polycrystalline film.",
            answer="lattice defects",
            evidenceQuote="Thermal annealing actively suppresses lattice defects across the polycrystalline film.",
        )
    )

    selected = selector.select_joint_group([pool_q8], external_prompts=[external_q7_prompt])
    assert len(selected) == 1
    assert selected[0].candidate_id == "cand_q8_1_clean"


def test_selector_rejects_external_prompt_shingle_overlap_and_duplicate_group_answers():
    """Selector rejects >0.45 5-word shingle overlap with external_prompts and duplicate shared-group answers."""
    p_ref, bp_ref = _make_refs()
    selector = CandidateSelector()

    external_q4_prompt = (
        "Automated acoustic sensors for monitoringcetacean migration rely on detecting anomalous vocalization patterns."
    )
    pool_q13 = QuestionCandidatePool(slotId="slot_q13", questionNumber=13, questionType="SentenceCompletion", poolLimit=3)
    pool_q13.add_candidate(
        QuestionCandidate(
            candidateId="cand_q13_1_overlap",
            slotId="slot_q13",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=13,
            questionType="SentenceCompletion",
            prompt="Automated acoustic sensors for monitoringcetacean migration rely on detecting ______ vocalization patterns.",
            answer="anomalous",
            evidenceQuote="Automated acoustic sensors for monitoringcetacean migration rely on detecting anomalous vocalization patterns.",
        )
    )
    pool_q13.add_candidate(
        QuestionCandidate(
            candidateId="cand_q13_2_distinct",
            slotId="slot_q13",
            passageRef=p_ref,
            blueprintRef=bp_ref,
            questionNumber=13,
            questionType="SentenceCompletion",
            prompt="Deep-water hydrophone arrays operate under high ______ and low ambient light.",
            answer="hydrostatic pressure",
            evidenceQuote="Deep-water hydrophone arrays operate under high hydrostatic pressure and low ambient light.",
        )
    )

    selected = selector.select_joint_group([pool_q13], external_prompts=[external_q4_prompt])
    assert len(selected) == 1
    assert selected[0].candidate_id == "cand_q13_2_distinct"


@pytest.mark.asyncio
async def test_sentence_completion_and_short_answer_subspan_repair():
    """SentenceCompletion salvages 4-word or parenthetical answers into 1-3 word verbatim passage spans."""
    passage = (
        "Geothermal brine injection induced microseismic activity along fault zones. "
        "Researchers monitored dissolved silica (SiO2) concentrations throughout the reservoir."
    )
    raw_payload = {
        "candidates": [
            {
                "prompt": "Fluid injection triggered ______ near preexisting faults.",
                "answer": "induced microseismic activity along",  # 4 words -> shortened to <=3 verbatim words
                "evidenceQuote": "Geothermal brine injection induced microseismic activity along fault zones.",
            },
            {
                "prompt": "Chemical sampling tracked ______ within the geothermal reservoir.",
                "answer": "dissolved silica (SiO2) concentrations",  # 4 tokens -> shortened to <=3 verbatim words
                "evidenceQuote": "Researchers monitored dissolved silica (SiO2) concentrations throughout the reservoir.",
            },
        ]
    }
    p_ref, bp_ref = _make_refs()
    ctx = _make_loop_context()
    gw = _StubGateway(json.dumps(raw_payload))
    gen = QuestionCandidateGenerator(gateway=gw)

    pool = await gen.generate_candidate_pool(
        passage_text=passage,
        question_type="SentenceCompletion",
        question_number=8,
        passage_ref=p_ref,
        blueprint_ref=bp_ref,
        run_id=ctx.run_id,
        context=ctx,
    )
    eligible = pool.get_eligible_candidates()
    assert len(eligible) == 2
    for cand in eligible:
        assert 1 <= len(cand.answer.split()) <= 3
        assert cand.answer in passage
