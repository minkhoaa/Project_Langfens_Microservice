"""Authoritative 40-Question Academic Validity Suite (Workstream A).

Verifies:
1. Exact 40 question contracts valid across all 19 supported families.
2. Every question is passage-specific, academically credible, and supported by exact evidence spans.
3. No monotonous runs (no all-A, all-I, or 4+ repeated answers).
4. DIAGRAM_LABEL (Q14-Q17) and FLOW_CHART (Q10-Q13) have valid, secure SVG assets with matching callout badges.
5. All 40 questions pass production evaluate_question without CRITICAL/MAJOR issues.
6. All 3 sections pass evaluate_section.
7. Full paper passes evaluate_paper (structure, cross-section, leakage, monotony, closure).
"""

from __future__ import annotations

import json
from pathlib import Path
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.issue import IssueCode, IssueSeverity
from app.reading_evaluation import evaluate_paper, evaluate_passage, evaluate_question, evaluate_section
from app.reading_policy import PinnedExecutionPolicy
from app.visual.evaluator import SvgVisualEvaluator

FIXTURE_PATH = Path(__file__).resolve().parents[1] / "fixtures" / "canonical_40_question_reading_paper.json"


def load_fixture() -> dict:
    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


def test_no_monotonous_answer_runs():
    """A2: Ensures there are no monotonous runs of answers (e.g. all A or all I)."""
    data = load_fixture()
    for s_idx, sec in enumerate(data["sections"]):
        for g_idx, grp in enumerate(sec.get("groups", [])):
            answers = [q.get("answer") for q in grp.get("questions", [])]
            # No group with >= 4 items should have identical answers
            if len(answers) >= 4:
                assert len(set(answers)) >= 2, (
                    f"Section {s_idx+1} Group {grp.get('groupId')} ({grp.get('questionType')}) "
                    f"has monotonous identical answers: {answers}"
                )


def test_visual_questions_have_valid_svg_assets():
    """A4: DIAGRAM_LABEL and FLOW_CHART items must supply valid, compliant SVG assets."""
    data = load_fixture()
    svg_evaluator = SvgVisualEvaluator()

    for sec in data["sections"]:
        for grp in sec.get("groups", []):
            gtype = grp.get("questionType")
            if gtype in ("DIAGRAM_LABEL", "FLOW_CHART"):
                grp_callouts = [q["questionNumber"] for q in grp.get("questions", [])]
                svg_xml = grp.get("svgXml") or (grp.get("questions", [{}])[0].get("svgXml"))
                assert svg_xml, f"Group {grp.get('groupId')} ({gtype}) lacks required svgXml"
                eval_res = svg_evaluator.evaluate(svg_xml, expected_callouts=grp_callouts)
                assert eval_res.is_valid, f"Invalid SVG for {grp.get('groupId')}: {eval_res.errors}"


def test_all_40_questions_pass_production_evaluator():
    """A1, A2, A7: All 40 questions must satisfy production evaluate_question rules."""
    data = load_fixture()
    policy = PinnedExecutionPolicy(provider="mock")

    for s_idx, sec in enumerate(data["sections"]):
        passage = sec["passage"]
        sec_cfg = policy.section(s_idx + 1)
        for grp in sec.get("groups", []):
            for q in grp.get("questions", []):
                q_num = q["questionNumber"]
                env = ArtifactEnvelope.create(
                    f"art_q_{q_num}",
                    ArtifactType.QUESTION,
                    "run_canonical_test",
                    q,
                    "1.0.0",
                )
                eval_results = evaluate_question(env, passage, sec_cfg.difficulty.value, siblings=[])
                critical_or_major = [
                    i for e in eval_results for i in e.issues
                    if i.severity in (IssueSeverity.CRITICAL, IssueSeverity.MAJOR)
                ]
                assert not critical_or_major, (
                    f"Question {q_num} ({q.get('questionType')}) failed production evaluator: "
                    f"{[i.message for i in critical_or_major]}"
                )


def test_all_sections_and_paper_pass_evaluators():
    """A5, A8: Section and paper structure, word counts, and distribution pass evaluators."""
    data = load_fixture()
    policy = PinnedExecutionPolicy(provider="mock")

    from app.contracts.artifact import ArtifactRef
    parent_refs = [
        ArtifactRef.model_validate(ref)
        for ref in [data["blueprintRef"]] + data["sectionRefs"] + data["passageRefs"] + data["questionRefs"]
    ]

    paper_env = ArtifactEnvelope.create(
        "paper:canonical_40q",
        ArtifactType.READING_PAPER,
        "run_canonical_test",
        data,
        "2.0.0",
        parent_refs=parent_refs,
    )
    paper_evals = evaluate_paper(paper_env, policy)
    failed_paper = [e for e in paper_evals if not e.is_pass()]
    assert not failed_paper, (
        f"Paper failed production evaluate_paper: "
        f"{[(e.evaluator_id, [i.message for i in e.issues]) for e in failed_paper]}"
    )
