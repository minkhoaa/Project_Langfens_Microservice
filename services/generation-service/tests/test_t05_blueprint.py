"""Tests for Phase 05: ExamBlueprint and Source Suitability (T05-01 to T05-07)."""

import pytest
from typing import List

from app.contracts.evidence import EvidenceGraph, VerifiedClaim, SourceOffset
from app.contracts.blueprint import (
    ExamBlueprint,
    SectionBlueprint,
    QuestionSlot,
    QuestionType,
    DifficultyLevel,
    TargetDifficulty,
    EvidenceGraphRef,
    BudgetAllocation,
)
from app.blueprint.policies import (
    BLUEPRINT_POLICY_VERSION,
    SECTION_CONFIGURATIONS,
    SECTION_QUESTION_COUNTS,
    SECTION_MIN_WORDS,
    SECTION_MAX_WORDS,
    PAPER_MIN_WORDS,
    PAPER_MAX_WORDS,
)
from app.blueprint.suitability import (
    evaluate_source_suitability,
    SourceSuitabilityResult,
)
from app.blueprint.planner import (
    BlueprintPlanner,
    SectionPlanInput,
    BlueprintPlanResult,
)
from app.blueprint.validators import validate_blueprint


def make_claim(
    cid: str,
    subject: str,
    predicate: str,
    obj: str,
    statement: str,
    modality: str = "certain",
    quantities: List[float] = None,
) -> VerifiedClaim:
    return VerifiedClaim(
        claimId=cid,
        text=statement,
        sourceId="src-1",
        offsets=SourceOffset(sourceId="src-1", startChar=0, endChar=len(statement)),
        confidence=1.0,
        keywords=[w.lower() for w in f"{subject} {predicate} {obj}".split() if len(w) > 2],
    )


def create_section1_graph() -> EvidenceGraph:
    """Diverse factual claims for Section 1."""
    claims = [
        make_claim("c1", "Agriculture", "originated in", "Fertile Crescent", "Agriculture originated in the Fertile Crescent around 9000 BCE."),
        make_claim("c2", "Early farmers", "cultivated", "wild emmer wheat", "Early farmers cultivated wild emmer wheat and barley."),
        make_claim("c3", "Archaeological sites", "reveal", "permanent stone dwellings", "Archaeological sites reveal permanent stone dwellings."),
        make_claim("c4", "Domestication", "included", "goats and sheep", "Animal domestication included sheep and goats."),
        make_claim("c5", "Pottery production", "began in", "seventh millennium BCE", "Pottery production began in the seventh millennium BCE."),
        make_claim("c6", "Irrigation canals", "diverted", "Euphrates river waters", "Irrigation canals diverted Euphrates river waters."),
        make_claim("c7", "Grain storage silos", "prevented", "seasonal famine", "Grain storage silos prevented seasonal famine."),
        make_claim("c8", "Trade routes", "expanded across", "Levant region", "Trade routes expanded across the Levant region."),
    ]
    return EvidenceGraph(
        graph_id="eg_sec1",
        run_id="run-001",
        source_pack_id="pack_sec1",
        version="v1.0.0",
        content_hash="hash_sec1_abc",
        status="ACCEPTED",
        claims=claims,
    )


def create_section2_graph() -> EvidenceGraph:
    """Analytical mechanism and process claims for Section 2."""
    claims = [
        make_claim("c2_1", "Glycolysis", "breaks down", "glucose into pyruvate", "Glycolysis breaks down glucose into two molecules of pyruvate."),
        make_claim("c2_2", "Mitochondrial membrane", "regulates", "proton gradient", "The mitochondrial inner membrane regulates proton gradient formation."),
        make_claim("c2_3", "ATP synthase", "triggers", "ATP synthesis", "ATP synthase triggers ATP synthesis via phosphorylation."),
        make_claim("c2_4", "Electron transport chain", "produces", "metabolic water", "The electron transport chain produces water as a byproduct."),
        make_claim("c2_5", "Cellular hypoxia", "causes", "lactic acid buildup", "Cellular hypoxia causes rapid lactic acid buildup in muscle cells."),
        make_claim("c2_6", "Enzyme inhibition", "decreases", "metabolic rate", "Enzyme inhibition directly decreases cellular metabolic rate."),
        make_claim("c2_7", "Krebs cycle", "generates", "NADH and FADH2", "The Krebs cycle generates key electron carriers NADH and FADH2."),
    ]
    return EvidenceGraph(
        graph_id="eg_sec2",
        run_id="run-001",
        source_pack_id="pack_sec2",
        version="v1.0.0",
        content_hash="hash_sec2_abc",
        status="ACCEPTED",
        claims=claims,
    )


def create_section3_graph() -> EvidenceGraph:
    """Argumentative opinion and viewpoint claims for Section 3."""
    claims = [
        make_claim("c3_1", "Ethicists", "argue that", "algorithms lack moral agency", "Ethicists argue that autonomous algorithms lack moral agency.", modality="argues"),
        make_claim("c3_2", "Legal scholars", "contend that", "strict liability applies", "Legal scholars contend that strict liability should apply to AI developers.", modality="contends"),
        make_claim("c3_3", "Economists", "hypothesize that", "automation displaces middle-income jobs", "Economists hypothesize that automation displaces middle-income jobs.", modality="hypothesizes"),
        make_claim("c3_4", "Sociologists", "suggest that", "algorithmic bias perpetuates inequality", "Sociologists suggest that algorithmic bias perpetuates systemic inequality.", modality="suggests"),
        make_claim("c3_5", "Technologists", "propose that", "explainable models mitigate harm", "Technologists propose that explainable models mitigate societal harm.", modality="proposes"),
        make_claim("c3_6", "Regulators", "debate whether", "auditing frameworks suffice", "Regulators debate whether voluntary auditing frameworks suffice.", modality="debates"),
        make_claim("c3_7", "Philosophers", "view", "machine consciousness as improbable", "Philosophers view machine consciousness as theoretically improbable.", modality="views"),
    ]
    return EvidenceGraph(
        graph_id="eg_sec3",
        run_id="run-001",
        source_pack_id="pack_sec3",
        version="v1.0.0",
        content_hash="hash_sec3_abc",
        status="ACCEPTED",
        claims=claims,
    )


# ---------------------------------------------------------------------------
# T05-01: Section 1/2/3 Blueprint Structure & Question Slots 1-40
# ---------------------------------------------------------------------------
def test_t05_01_section_blueprint_structure_and_slots_1_to_40():
    planner = BlueprintPlanner()
    sec_inputs = [
        SectionPlanInput(section_id=1, topic="Neolithic Farming", evidence_graph=create_section1_graph()),
        SectionPlanInput(section_id=2, topic="Cellular Respiration", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="AI Ethics", evidence_graph=create_section3_graph()),
    ]
    res = planner.plan_exam(run_id="run-001", blueprint_id="bp-001", section_inputs=sec_inputs)

    assert res.success is True
    assert res.status == "ACCEPTED"
    bp = res.blueprint
    assert bp is not None

    # Check total questions
    assert bp.total_questions == 40
    assert len(bp.sections) == 3

    # Check sections
    s1, s2, s3 = bp.sections

    # Section 1: TFNG 7 (Q1-7), Sentence Completion 6 (Q8-13)
    assert s1.section_id == 1
    assert s1.total_questions == 13
    assert len(s1.question_slots) == 13
    assert s1.question_slots[0].question_number == 1
    assert s1.question_slots[6].question_number == 7
    assert all(s.question_type == QuestionType.TRUE_FALSE_NOT_GIVEN for s in s1.question_slots[0:7])
    assert s1.question_slots[7].question_number == 8
    assert s1.question_slots[12].question_number == 13
    assert all(s.question_type == QuestionType.SENTENCE_COMPLETION for s in s1.question_slots[7:13])

    # Section 2: MCQ single 6 (Q14-19), Summary completion 7 (Q20-26)
    assert s2.section_id == 2
    assert s2.total_questions == 13
    assert len(s2.question_slots) == 13
    assert s2.question_slots[0].question_number == 14
    assert s2.question_slots[5].question_number == 19
    assert all(s.question_type == QuestionType.MULTIPLE_CHOICE_SINGLE for s in s2.question_slots[0:6])
    assert s2.question_slots[6].question_number == 20
    assert s2.question_slots[12].question_number == 26
    assert all(s.question_type == QuestionType.SUMMARY_COMPLETION for s in s2.question_slots[6:13])

    # Section 3: YNNG 7 (Q27-33), Short answer 7 (Q34-40)
    assert s3.section_id == 3
    assert s3.total_questions == 14
    assert len(s3.question_slots) == 14
    assert s3.question_slots[0].question_number == 27
    assert s3.question_slots[6].question_number == 33
    assert all(s.question_type == QuestionType.YES_NO_NOT_GIVEN for s in s3.question_slots[0:7])
    assert s3.question_slots[7].question_number == 34
    assert s3.question_slots[13].question_number == 40
    assert all(s.question_type == QuestionType.SHORT_ANSWER for s in s3.question_slots[7:14])

    # Contiguity check: Q1 to Q40 without missing or duplicate
    all_q_numbers = [slot.question_number for s in bp.sections for slot in s.question_slots]
    assert all_q_numbers == list(range(1, 41))


# ---------------------------------------------------------------------------
# T05-02: Source 1000 Words But Only 1 Repeated Fact Rejected (Generator Count = 0)
# ---------------------------------------------------------------------------
def test_t05_02_source_repetitive_single_fact_rejected():
    # 10 repetitive claims with the exact same subject/predicate/object
    repetitive_claims = [
        make_claim(f"c_rep_{i}", "Photosynthesis", "produces", "glucose in plant leaves", "Photosynthesis produces glucose in plant leaves.")
        for i in range(10)
    ]
    graph = EvidenceGraph(
        graph_id="eg_rep",
        run_id="run-rep",
        source_pack_id="pack_rep",
        version="v1.0.0",
        content_hash="hash_rep",
        status="ACCEPTED",
        claims=repetitive_claims,
    )

    res = evaluate_source_suitability(graph, section_id=1)
    assert res.is_suitable is False
    assert res.rejection_code == "SOURCE_INSUFFICIENT_DIVERSITY"
    assert res.action == "NEEDS_SOURCES"

    # Planner must fail before calling passage generator
    planner = BlueprintPlanner()
    sec_inputs = [
        SectionPlanInput(section_id=1, topic="Photosynthesis", evidence_graph=graph),
        SectionPlanInput(section_id=2, topic="Cellular Respiration", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="AI Ethics", evidence_graph=create_section3_graph()),
    ]
    plan_res = planner.plan_exam(run_id="run-rep", blueprint_id="bp-rep", section_inputs=sec_inputs)

    assert plan_res.success is False
    assert plan_res.status == "SOURCE_INSUFFICIENT"
    assert plan_res.action == "NEEDS_SOURCES"
    assert plan_res.blueprint is None


# ---------------------------------------------------------------------------
# T05-03: Section 3 Lacking Viewpoints/Arguments Rejected (No Fake Opinions)
# ---------------------------------------------------------------------------
def test_t05_03_section3_without_viewpoints_rejected():
    # Purely factual claims, zero opinion or argumentative keywords
    pure_factual_claims = [
        make_claim(f"c_fact_{i}", f"Mineral_{i}", "crystallizes at", f"{i * 100} degrees Celsius", f"Mineral {i} crystallizes at {i * 100} degrees Celsius.")
        for i in range(8)
    ]
    graph = EvidenceGraph(
        graph_id="eg_facts",
        run_id="run-facts",
        source_pack_id="pack_facts",
        version="v1.0.0",
        content_hash="hash_facts",
        status="ACCEPTED",
        claims=pure_factual_claims,
    )

    res = evaluate_source_suitability(graph, section_id=3)
    assert res.is_suitable is False
    assert res.rejection_code == "SOURCE_INSUFFICIENT_OPINIONS"
    assert res.action == "NEEDS_SOURCES"
    assert "must not fabricate fake opinion claims" in res.rejection_reason


# ---------------------------------------------------------------------------
# T05-04: Blueprint Referencing Rejected or Stale Graph Fails Before Generation
# ---------------------------------------------------------------------------
def test_t05_04_rejected_or_stale_graph_fails_validation():
    rejected_graph = EvidenceGraph(
        graph_id="eg_rej",
        run_id="run-rej",
        source_pack_id="pack_rej",
        version="v1.0.0",
        content_hash="hash_rej",
        status="REJECTED",
        claims=create_section1_graph().claims,
    )

    planner = BlueprintPlanner()
    sec_inputs = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=rejected_graph),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph()),
    ]
    plan_res = planner.plan_exam(run_id="run-rej", blueprint_id="bp-rej", section_inputs=sec_inputs)

    assert plan_res.success is False
    assert plan_res.status == "STALE_OR_REJECTED_GRAPH"
    assert plan_res.action == "NEEDS_SOURCES"
    assert "must be ACCEPTED" in plan_res.reason


# ---------------------------------------------------------------------------
# T05-05: Budget Oversubscription Prevention & Scaling
# ---------------------------------------------------------------------------
def test_t05_05_budget_allocation_and_cap_enforcement():
    planner = BlueprintPlanner()
    # Request 30,000 tokens per section = 90,000 total tokens, but parent cap is 50,000
    sec_inputs = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=create_section1_graph(), max_tokens=30000, max_candidates_per_slot=2),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph(), max_tokens=30000, max_candidates_per_slot=2),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph(), max_tokens=30000, max_candidates_per_slot=2),
    ]
    # Scaling factor = 50000 / 90000 = 0.555 >= 0.5 -> should scale down
    res = planner.plan_exam(run_id="run-bud", blueprint_id="bp-bud", section_inputs=sec_inputs, parent_budget_cap_tokens=50000)

    assert res.success is True
    bp = res.blueprint
    assert bp is not None
    total_tokens = sum(s.budget_allocation.max_tokens_allocated for s in bp.sections)
    assert total_tokens <= 50000
    # Candidates scaled down to 1
    assert all(s.budget_allocation.max_candidates_per_slot == 1 for s in bp.sections)

    # Severe oversubscription (parent cap = 20,000 < 0.5 * 90,000) -> fails closed
    sec_inputs_severe = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=create_section1_graph(), max_tokens=30000),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph(), max_tokens=30000),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph(), max_tokens=30000),
    ]
    res_severe = planner.plan_exam(run_id="run-bud-sev", blueprint_id="bp-bud-sev", section_inputs=sec_inputs_severe, parent_budget_cap_tokens=20000)
    assert res_severe.success is False
    assert res_severe.status == "BUDGET_EXCEEDED"


# ---------------------------------------------------------------------------
# T05-06: Deterministic Blueprint Generation & Stable Hash
# ---------------------------------------------------------------------------
def test_t05_06_deterministic_planning_stable_hash():
    planner = BlueprintPlanner()
    sec_inputs_1 = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=create_section1_graph()),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph()),
    ]
    sec_inputs_2 = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=create_section1_graph()),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph()),
    ]

    res1 = planner.plan_exam(run_id="run-det", blueprint_id="bp-det", section_inputs=sec_inputs_1)
    res2 = planner.plan_exam(run_id="run-det", blueprint_id="bp-det", section_inputs=sec_inputs_2)

    assert res1.success is True and res2.success is True
    assert res1.blueprint.content_hash == res2.blueprint.content_hash
    assert len(res1.blueprint.content_hash) == 64  # SHA-256


# ---------------------------------------------------------------------------
# T05-07: Policy Parity & Calibrated Difficulty Prohibition
# ---------------------------------------------------------------------------
def test_t05_07_calibrated_difficulty_prohibited():
    planner = BlueprintPlanner()
    sec_inputs = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=create_section1_graph()),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph()),
    ]
    res = planner.plan_exam(run_id="run-pol", blueprint_id="bp-pol", section_inputs=sec_inputs)
    assert res.success is True
    bp = res.blueprint
    # Reconstruct with calibrated difficulty
    tampered_slots = list(bp.sections[0].question_slots)
    tampered_slots[0] = tampered_slots[0].model_copy(
        update={"target_difficulty": TargetDifficulty(level=DifficultyLevel.FOUNDATION, rationale="Calibrated band 7.5", is_calibrated=True)}
    )
    tampered_sec = bp.sections[0].model_copy(update={"question_slots": tampered_slots})
    tampered_bp = bp.model_copy(update={"sections": [tampered_sec, bp.sections[1], bp.sections[2]]})
    issues = validate_blueprint(tampered_bp)
    calibrated_issues = [i for i in issues if i.code == "BLUEPRINT_CALIBRATED_DIFFICULTY_PROHIBITED"]
    assert len(calibrated_issues) == 1
    assert calibrated_issues[0].severity.value == "CRITICAL"
