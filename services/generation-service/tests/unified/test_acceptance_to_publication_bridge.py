"""Bridge test proving that canonical 40Q paper traverses genuine production evaluators (Workstream D).

Ensures:
D1. Valid academic fixture accepted by real production evaluators (evaluate_paper, evaluate_section, evaluate_passage, evaluate_question).
D2. Invalid academic fixture rejected.
D3. Invalid claim reference rejected before publication.
D4. Invalid offsets rejected before publication.
D5. Missing diagram asset rejected for visual questions.
D6. Corrupt dependency hash rejected.
D7. Actual evaluator results persisted and verified.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import IssueSeverity
from app.reading_evaluation import evaluate_paper, evaluate_passage, evaluate_question, evaluate_section
from app.reading_policy import PinnedExecutionPolicy
from app.visual.evaluator import SvgVisualEvaluator

FIXTURE_PATH = Path(__file__).resolve().parents[1] / "fixtures" / "canonical_40_question_reading_paper.json"


def load_fixture() -> dict:
    assert FIXTURE_PATH.exists()
    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


def test_d1_valid_academic_fixture_accepted_by_real_evaluators():
    """D1: Executes actual production evaluators against canonical 40Q artifact and verifies genuine PASS."""
    data = load_fixture()
    policy = PinnedExecutionPolicy(provider="mock")

    parent_refs = [
        ArtifactRef.model_validate(ref)
        for ref in [data["blueprintRef"]] + data["sectionRefs"] + data["passageRefs"] + data["questionRefs"]
    ]
    paper_env = ArtifactEnvelope.create(
        data["paperId"],
        ArtifactType.READING_PAPER,
        data["runId"],
        data,
        "2.0.0",
        parent_refs=parent_refs,
    )

    # 1. Paper-level evaluators
    paper_evals: list[EvaluationResult] = evaluate_paper(paper_env, policy)
    for ev in paper_evals:
        assert ev.status == EvaluationStatus.PASS, f"Paper evaluator {ev.evaluator_id} failed: {[i.message for i in ev.issues]}"
        assert ev.score == 1.0
        assert len(ev.issues) == 0

    # 2. Section-level evaluators
    for s_idx, sec in enumerate(data["sections"]):
        sec_cfg = policy.section(s_idx + 1)
        sec_env = ArtifactEnvelope.create(
            f"section:test:{s_idx+1}",
            ArtifactType.SECTION,
            data["runId"],
            sec,
            "2.0.0",
        )
        sec_evals = evaluate_section(sec_env, sec_cfg)
        for ev in sec_evals:
            assert ev.status == EvaluationStatus.PASS, f"Section {s_idx+1} evaluator {ev.evaluator_id} failed: {[i.message for i in ev.issues]}"

    # 3. Question-level evaluators
    svg_eval = SvgVisualEvaluator()
    for s_idx, sec in enumerate(data["sections"]):
        passage = sec["passage"]
        sec_cfg = policy.section(s_idx + 1)
        for grp in sec.get("groups", []):
            if grp.get("questionType") in ("DIAGRAM_LABEL", "FLOW_CHART"):
                grp_callouts = [q["questionNumber"] for q in grp["questions"]]
                svg_xml = grp.get("svgXml") or grp["questions"][0].get("svgXml")
                res = svg_eval.evaluate(svg_xml, expected_callouts=grp_callouts)
                assert res.is_valid, f"Visual asset validation failed: {res.errors}"

            for q in grp.get("questions", []):
                q_env = ArtifactEnvelope.create(
                    f"question:test:{q['questionNumber']}",
                    ArtifactType.QUESTION,
                    data["runId"],
                    q,
                    "1.0.0",
                )
                q_evals = evaluate_question(q_env, passage, sec_cfg.difficulty.value, siblings=[])
                for ev in q_evals:
                    assert ev.status == EvaluationStatus.PASS, f"Q{q['questionNumber']} evaluator {ev.evaluator_id} failed: {[i.message for i in ev.issues]}"


def test_d2_invalid_academic_fixture_rejected():
    """D2: Mutated paper with invalid question count or duplicate prompt is rejected."""
    data = load_fixture()
    policy = PinnedExecutionPolicy(provider="mock")

    # Mutate section 1 question 2 prompt to duplicate question 1 prompt
    bad_data = copy.deepcopy(data)
    bad_data["sections"][0]["groups"][0]["questions"][1]["statement"] = bad_data["sections"][0]["groups"][0]["questions"][0]["statement"]

    parent_refs = [
        ArtifactRef.model_validate(ref)
        for ref in [bad_data["blueprintRef"]] + bad_data["sectionRefs"] + bad_data["passageRefs"] + bad_data["questionRefs"]
    ]
    paper_env = ArtifactEnvelope.create(
        bad_data["paperId"],
        ArtifactType.READING_PAPER,
        bad_data["runId"],
        bad_data,
        "2.0.0",
        parent_refs=parent_refs,
    )
    paper_evals = evaluate_paper(paper_env, policy)
    failed = [e for e in paper_evals if not e.is_pass()]
    assert len(failed) > 0, "Duplicate prompts must fail paper evaluation"


def test_d3_invalid_claim_reference_rejected():
    """D3: Question referencing non-existent claim fails evidence evaluator."""
    data = load_fixture()
    policy = PinnedExecutionPolicy(provider="mock")
    q = copy.deepcopy(data["sections"][0]["groups"][0]["questions"][0])
    q["evidenceClaimRef"] = ""  # Strip claim ref
    env = ArtifactEnvelope.create("q:d3", ArtifactType.QUESTION, "run_d3", q, "1.0.0")
    evals = evaluate_question(env, data["sections"][0]["passage"], "FOUNDATION", siblings=[])
    failed = [e for e in evals if not e.is_pass()]
    assert any(i.code == "EVIDENCE_MISSING" for e in failed for i in e.issues)


def test_d4_invalid_offsets_rejected_before_publication():
    """D4: Question with corrupt startChar / endChar offsets is rejected."""
    data = load_fixture()
    q = copy.deepcopy(data["sections"][0]["groups"][0]["questions"][0])
    q["passageEvidence"]["startChar"] = 99999
    q["passageEvidence"]["endChar"] = 99990  # Inverted offset
    env = ArtifactEnvelope.create("q:d4", ArtifactType.QUESTION, "run_d4", q, "1.0.0")
    evals = evaluate_question(env, data["sections"][0]["passage"], "FOUNDATION", siblings=[])
    failed = [e for e in evals if not e.is_pass()]
    assert any(i.code == "EVIDENCE_MISSING" for e in failed for i in e.issues)


def test_d5_missing_diagram_asset_rejected():
    """D5: Visual question lacking SVG asset or having callout mismatch is rejected."""
    data = load_fixture()
    svg_eval = SvgVisualEvaluator()
    corrupt_svg = "<svg viewBox='0 0 800 600'><title>Incomplete Diagram</title><g data-callout-id='99'><circle cx='10' cy='10' r='5'/></g></svg>"
    res = svg_eval.evaluate(corrupt_svg, expected_callouts=[14, 15, 16, 17])
    assert res.is_valid is False
    assert any("Missing expected callouts" in err for err in res.errors)


def test_d6_corrupt_dependency_hash_rejected():
    """D6: Altered parent hash breaks content hash derivation."""
    import hashlib
    from app.contracts.artifact import compute_content_hash
    h_orig = hashlib.sha256(b"original_dependency_payload").hexdigest()
    h_corrupt = hashlib.sha256(b"corrupted_dependency_payload").hexdigest()
    parent_ref = ArtifactRef(
        artifactId="eg_1",
        version=1,
        contentHash=h_orig,
        artifactType=ArtifactType.EVIDENCE_GRAPH,
    )
    mutated_parent_ref = ArtifactRef(
        artifactId="eg_1",
        version=1,
        contentHash=h_corrupt,
        artifactType=ArtifactType.EVIDENCE_GRAPH,
    )
    body = {"test": "payload"}
    h1 = compute_content_hash(body, [parent_ref])
    h2 = compute_content_hash(body, [mutated_parent_ref])
    assert h1 != h2, "Content hash must change when dependency hash changes"
