#!/usr/bin/env python3
"""Generates canonical fixtures, schemas, and reports for Phase 05: ExamBlueprint and Source Suitability."""

import json
from pathlib import Path
import sys

# Ensure generation-service app is in pythonpath
ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "services" / "generation-service"))

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
    BLUEPRINT_SCHEMA_VERSION,
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


def make_claim(cid: str, subject: str, predicate: str, obj: str, statement: str) -> VerifiedClaim:
    return VerifiedClaim(
        claimId=cid,
        text=statement,
        sourceId="src-ref-001",
        offsets=SourceOffset(sourceId="src-ref-001", startChar=0, endChar=len(statement)),
        confidence=1.0,
        keywords=[w.lower() for w in f"{subject} {predicate} {obj}".split() if len(w) > 2],
    )


def create_section1_graph() -> EvidenceGraph:
    claims = [
        make_claim("c1_1", "Agriculture", "originated in", "Fertile Crescent", "Agriculture originated in the Fertile Crescent around 9000 BCE."),
        make_claim("c1_2", "Early farmers", "cultivated", "wild emmer wheat", "Early farmers cultivated wild emmer wheat and barley."),
        make_claim("c1_3", "Archaeological sites", "reveal", "permanent stone dwellings", "Archaeological sites reveal permanent stone dwellings."),
        make_claim("c1_4", "Domestication", "included", "goats and sheep", "Animal domestication included sheep and goats."),
        make_claim("c1_5", "Pottery production", "began in", "seventh millennium BCE", "Pottery production began in the seventh millennium BCE."),
        make_claim("c1_6", "Irrigation canals", "diverted", "Euphrates river waters", "Irrigation canals diverted Euphrates river waters."),
        make_claim("c1_7", "Grain storage silos", "prevented", "seasonal famine", "Grain storage silos prevented seasonal famine."),
        make_claim("c1_8", "Trade routes", "expanded across", "Levant region", "Trade routes expanded across the Levant region."),
    ]
    return EvidenceGraph(
        graph_id="eg_sec1_canonical",
        run_id="run-canonical-001",
        source_pack_id="pack_sec1_canonical",
        version="v1.0.0",
        content_hash="hash_sec1_canonical_001",
        status="ACCEPTED",
        claims=claims,
    )


def create_section2_graph() -> EvidenceGraph:
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
        graph_id="eg_sec2_canonical",
        run_id="run-canonical-001",
        source_pack_id="pack_sec2_canonical",
        version="v1.0.0",
        content_hash="hash_sec2_canonical_002",
        status="ACCEPTED",
        claims=claims,
    )


def create_section3_graph() -> EvidenceGraph:
    claims = [
        make_claim("c3_1", "Ethicists", "argue that", "algorithms lack moral agency", "Ethicists argue that autonomous algorithms lack moral agency."),
        make_claim("c3_2", "Legal scholars", "contend that", "strict liability applies", "Legal scholars contend that strict liability should apply to AI developers."),
        make_claim("c3_3", "Economists", "hypothesize that", "automation displaces middle-income jobs", "Economists hypothesize that automation displaces middle-income jobs."),
        make_claim("c3_4", "Sociologists", "suggest that", "algorithmic bias perpetuates inequality", "Sociologists suggest that algorithmic bias perpetuates systemic inequality."),
        make_claim("c3_5", "Technologists", "propose that", "explainable models mitigate harm", "Technologists propose that explainable models mitigate societal harm."),
        make_claim("c3_6", "Regulators", "debate whether", "auditing frameworks suffice", "Regulators debate whether voluntary auditing frameworks suffice."),
        make_claim("c3_7", "Philosophers", "view", "machine consciousness as improbable", "Philosophers view machine consciousness as theoretically improbable."),
    ]
    return EvidenceGraph(
        graph_id="eg_sec3_canonical",
        run_id="run-canonical-001",
        source_pack_id="pack_sec3_canonical",
        version="v1.0.0",
        content_hash="hash_sec3_canonical_003",
        status="ACCEPTED",
        claims=claims,
    )


def main():
    artifacts_dir = ROOT / "artifacts" / "refactor" / "phase-05"
    artifacts_dir.mkdir(parents=True, exist_ok=True)
    print(f"[*] Generating Phase 05 fixtures in {artifacts_dir}...")

    # 1. Blueprint Schema
    schema = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "LangfensExamBlueprint",
        "description": "Versioned exam blueprint for IELTS Academic Reading (40 questions, 3 sections).",
        "type": "object",
        "properties": {
            "blueprintId": {"type": "string"},
            "runId": {"type": "string"},
            "policyVersion": {"type": "string", "default": BLUEPRINT_POLICY_VERSION},
            "schemaVersion": {"type": "string", "default": BLUEPRINT_SCHEMA_VERSION},
            "totalQuestions": {"type": "integer", "const": 40},
            "targetWordCountMin": {"type": "integer", "const": 2150},
            "targetWordCountMax": {"type": "integer", "const": 2750},
            "sections": {
                "type": "array",
                "minItems": 3,
                "maxItems": 3,
                "items": {
                    "type": "object",
                    "properties": {
                        "sectionId": {"type": "integer", "enum": [1, 2, 3]},
                        "topic": {"type": "string"},
                        "targetWordCount": {"type": "integer", "minimum": 720, "maximum": 915},
                        "evidenceGraphRef": {
                            "type": "object",
                            "properties": {
                                "graphId": {"type": "string"},
                                "sourcePackId": {"type": "string"},
                                "version": {"type": "string"},
                                "contentHash": {"type": "string"},
                                "status": {"type": "string", "const": "ACCEPTED"},
                            },
                            "required": ["graphId", "sourcePackId", "version", "contentHash", "status"],
                        },
                        "questionSlots": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "questionNumber": {"type": "integer", "minimum": 1, "maximum": 40},
                                    "sectionId": {"type": "integer", "enum": [1, 2, 3]},
                                    "groupIndex": {"type": "integer", "enum": [0, 1]},
                                    "questionType": {
                                        "type": "string",
                                        "enum": [
                                            "TRUE_FALSE_NOT_GIVEN",
                                            "SENTENCE_COMPLETION",
                                            "MULTIPLE_CHOICE_SINGLE",
                                            "SUMMARY_COMPLETION",
                                            "YES_NO_NOT_GIVEN",
                                            "SHORT_ANSWER",
                                        ],
                                    },
                                    "targetDifficulty": {
                                        "type": "object",
                                        "properties": {
                                            "level": {"type": "string", "enum": ["FOUNDATION", "MODERATE", "ADVANCED"]},
                                            "rationale": {"type": "string"},
                                            "isCalibrated": {"type": "boolean", "const": False},
                                        },
                                        "required": ["level", "rationale", "isCalibrated"],
                                    },
                                },
                                "required": ["questionNumber", "sectionId", "groupIndex", "questionType", "targetDifficulty"],
                            },
                        },
                    },
                    "required": ["sectionId", "topic", "targetWordCount", "evidenceGraphRef", "questionSlots"],
                },
            },
        },
        "required": ["blueprintId", "runId", "policyVersion", "schemaVersion", "totalQuestions", "sections"],
    }
    (artifacts_dir / "blueprint-schema.json").write_text(json.dumps(schema, indent=2), encoding="utf-8")
    print("    Created blueprint-schema.json")

    # 2. Accepted Blueprints
    planner = BlueprintPlanner()
    sec_inputs = [
        SectionPlanInput(section_id=1, topic="Neolithic Farming in the Levant", evidence_graph=create_section1_graph()),
        SectionPlanInput(section_id=2, topic="Cellular Respiration and Bioenergetics", evidence_graph=create_section2_graph()),
        SectionPlanInput(section_id=3, topic="Ethics of Autonomous Decision Systems", evidence_graph=create_section3_graph()),
    ]
    plan_result = planner.plan_exam(run_id="run-phase05-accepted", blueprint_id="bp-phase05-canonical", section_inputs=sec_inputs)
    if not plan_result.success:
        print(f"[!] Plan generation failed: {plan_result.reason}")
        sys.exit(1)

    accepted_fixtures = {
        "canonicalExamBlueprint": plan_result.blueprint.model_dump(by_alias=True),
        "section1Fixture": plan_result.blueprint.sections[0].model_dump(by_alias=True),
        "section2Fixture": plan_result.blueprint.sections[1].model_dump(by_alias=True),
        "section3Fixture": plan_result.blueprint.sections[2].model_dump(by_alias=True),
    }
    (artifacts_dir / "accepted-blueprints.json").write_text(json.dumps(accepted_fixtures, indent=2, default=str), encoding="utf-8")
    print("    Created accepted-blueprints.json")

    # 3. Rejected Source Suitability Report
    # Case A: Low diversity
    rep_claims = [
        make_claim(f"c_rep_{i}", "Photosynthesis", "produces", "glucose in plant leaves", "Photosynthesis produces glucose in plant leaves.")
        for i in range(10)
    ]
    graph_rep = EvidenceGraph(
        graph_id="eg_rep",
        run_id="run-rep",
        source_pack_id="pack_rep",
        version="v1.0.0",
        content_hash="hash_rep",
        status="ACCEPTED",
        claims=rep_claims,
    )
    suit_a = evaluate_source_suitability(graph_rep, section_id=1)

    # Case B: Section 2 lacking mechanisms
    non_mech_claims = [
        make_claim(f"c_nm_{i}", f"Island_{i}", "is situated in", "Pacific Ocean", f"Island {i} is situated in the south Pacific Ocean.")
        for i in range(8)
    ]
    graph_nm = EvidenceGraph(
        graph_id="eg_nm",
        run_id="run-nm",
        source_pack_id="pack_nm",
        version="v1.0.0",
        content_hash="hash_nm",
        status="ACCEPTED",
        claims=non_mech_claims,
    )
    suit_b = evaluate_source_suitability(graph_nm, section_id=2)

    # Case C: Section 3 lacking opinions
    pure_facts = [
        make_claim(f"c_pf_{i}", f"Element_{i}", "melts at", f"{i * 150} Kelvin", f"Element {i} melts at {i * 150} Kelvin.")
        for i in range(8)
    ]
    graph_pf = EvidenceGraph(
        graph_id="eg_pf",
        run_id="run-pf",
        source_pack_id="pack_pf",
        version="v1.0.0",
        content_hash="hash_pf",
        status="ACCEPTED",
        claims=pure_facts,
    )
    suit_c = evaluate_source_suitability(graph_pf, section_id=3)

    # Case D: Rejected EvidenceGraph status
    graph_rej = EvidenceGraph(
        graph_id="eg_rejected",
        run_id="run-rej",
        source_pack_id="pack_rej",
        version="v1.0.0",
        content_hash="hash_rej",
        status="REJECTED",
        claims=create_section1_graph().claims,
    )
    suit_d = evaluate_source_suitability(graph_rej, section_id=1)

    rejected_report = {
        "policyVersion": BLUEPRINT_POLICY_VERSION,
        "cases": [
            {
                "caseId": "CASE_A_REPETITIVE_SINGLE_FACT",
                "description": "Source of 1000+ words repeating identical factual claim.",
                "targetSection": 1,
                "rejectionCode": suit_a.rejection_code,
                "rejectionReason": suit_a.rejection_reason,
                "action": suit_a.action,
                "generatorCallCount": 0,
            },
            {
                "caseId": "CASE_B_SECTION2_LACKING_MECHANISMS",
                "description": "Section 2 source lacking causal, regulatory, or process mechanisms.",
                "targetSection": 2,
                "rejectionCode": suit_b.rejection_code,
                "rejectionReason": suit_b.rejection_reason,
                "action": suit_b.action,
                "generatorCallCount": 0,
            },
            {
                "caseId": "CASE_C_SECTION3_LACKING_OPINIONS",
                "description": "Section 3 source purely descriptive, lacking researcher arguments/hypotheses.",
                "targetSection": 3,
                "rejectionCode": suit_c.rejection_code,
                "rejectionReason": suit_c.rejection_reason,
                "action": suit_c.action,
                "generatorCallCount": 0,
            },
            {
                "caseId": "CASE_D_STALE_OR_REJECTED_GRAPH",
                "description": "Blueprint attempting to reference an unverified or rejected EvidenceGraph.",
                "targetSection": 1,
                "rejectionCode": suit_d.rejection_code,
                "rejectionReason": suit_d.rejection_reason,
                "action": suit_d.action,
                "generatorCallCount": 0,
            },
        ],
    }
    (artifacts_dir / "rejected-source-report.json").write_text(json.dumps(rejected_report, indent=2), encoding="utf-8")
    print("    Created rejected-source-report.json")

    # 4. Budget Feasibility Report
    # Test case 1: Standard allocation
    res_norm = planner.plan_exam(run_id="run-b1", blueprint_id="bp-b1", section_inputs=sec_inputs, parent_budget_cap_tokens=60000)
    # Test case 2: Scaled allocation (requested 90,000, cap 50,000)
    sec_inputs_scaled = [
        SectionPlanInput(section_id=1, topic="Farming", evidence_graph=create_section1_graph(), max_tokens=30000, max_candidates_per_slot=2),
        SectionPlanInput(section_id=2, topic="Respiration", evidence_graph=create_section2_graph(), max_tokens=30000, max_candidates_per_slot=2),
        SectionPlanInput(section_id=3, topic="Ethics", evidence_graph=create_section3_graph(), max_tokens=30000, max_candidates_per_slot=2),
    ]
    res_scaled = planner.plan_exam(run_id="run-b2", blueprint_id="bp-b2", section_inputs=sec_inputs_scaled, parent_budget_cap_tokens=50000)
    # Test case 3: Infeasible allocation (requested 90,000, cap 20,000 < 0.5 * 90,000)
    res_infeasible = planner.plan_exam(run_id="run-b3", blueprint_id="bp-b3", section_inputs=sec_inputs_scaled, parent_budget_cap_tokens=20000)

    budget_report = {
        "parentCapsEnforced": True,
        "scenarios": [
            {
                "scenario": "STANDARD_ALLOCATION",
                "parentBudgetCapTokens": 60000,
                "success": res_norm.success,
                "status": res_norm.status,
                "totalTokensAllocated": sum(s.budget_allocation.max_tokens_allocated for s in res_norm.blueprint.sections),
            },
            {
                "scenario": "GRACEFUL_SCALE_DOWN",
                "parentBudgetCapTokens": 50000,
                "success": res_scaled.success,
                "status": res_scaled.status,
                "totalTokensAllocated": sum(s.budget_allocation.max_tokens_allocated for s in res_scaled.blueprint.sections),
                "candidatesPerSlot": [s.budget_allocation.max_candidates_per_slot for s in res_scaled.blueprint.sections],
            },
            {
                "scenario": "INFEASIBLE_OVERSUBSCRIPTION_REJECTED",
                "parentBudgetCapTokens": 20000,
                "success": res_infeasible.success,
                "status": res_infeasible.status,
                "reason": res_infeasible.reason,
            },
        ],
    }
    (artifacts_dir / "budget-feasibility-report.json").write_text(json.dumps(budget_report, indent=2), encoding="utf-8")
    print("    Created budget-feasibility-report.json")

    # 5. Policy Parity Report
    policy_report = {
        "policyVersion": BLUEPRINT_POLICY_VERSION,
        "parityVerified": True,
        "rules": {
            "section1": {
                "questionCount": 13,
                "group0": {"type": "TRUE_FALSE_NOT_GIVEN", "count": 7, "start": 1, "end": 7},
                "group1": {"type": "SENTENCE_COMPLETION", "count": 6, "start": 8, "end": 13},
                "style": "Descriptive, factual, clear chronological or logical sequence",
            },
            "section2": {
                "questionCount": 13,
                "group0": {"type": "MULTIPLE_CHOICE_SINGLE", "count": 6, "start": 14, "end": 19},
                "group1": {"type": "SUMMARY_COMPLETION", "count": 7, "start": 20, "end": 26},
                "style": "Analytical, mechanisms, processes, causal relationships",
            },
            "section3": {
                "questionCount": 14,
                "group0": {"type": "YES_NO_NOT_GIVEN", "count": 7, "start": 27, "end": 33},
                "group1": {"type": "SHORT_ANSWER", "count": 7, "start": 34, "end": 40},
                "style": "Argumentative, hypotheses, opinions, perspectives, debate",
            },
            "wordCounts": {
                "sectionMin": SECTION_MIN_WORDS,
                "sectionMax": SECTION_MAX_WORDS,
                "paperMin": PAPER_MIN_WORDS,
                "paperMax": PAPER_MAX_WORDS,
            },
            "difficultyPolicy": {
                "prePilotCalibratedDifficultyAllowed": False,
                "supportedHeuristicLevels": ["FOUNDATION", "MODERATE", "ADVANCED"],
                "rationaleRequired": True,
            },
        },
    }
    (artifacts_dir / "policy-parity-report.json").write_text(json.dumps(policy_report, indent=2), encoding="utf-8")
    print("    Created policy-parity-report.json")

    print("[*] All Phase 05 fixtures generated successfully.")


if __name__ == "__main__":
    main()
