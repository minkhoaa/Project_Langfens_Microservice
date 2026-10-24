"""Deterministic offline acceptance-bundle producer for the cross-language bridge.

Bridges Python evaluation execution with .NET persistence, verification, and grading:
1. Builds exact canonical envelopes with authentic identities, parent references, and content hashes:
   - Blueprint envelope (1)
   - Passage envelopes (3)
   - Question envelopes (40)
   - Section envelopes (3)
   - ReadingPaper envelope (1)
2. Executes actual production Python evaluators:
   - evaluate_paper: eval_paper_structure (2.0.0), eval_paper_cross_section (2.0.0),
     eval_paper_leakage (2.1.0), eval_paper_monotony (2.0.0), eval_paper_closure (1.0.0)
   - evaluate_section: for each section
   - evaluate_question: for each question
3. Produces exact serializable EvaluationResult records with:
   - evaluatorId and evaluatorVersion
   - targetRef
   - status, score, issues
   - inputDependencyRefs (all 47 parent references)
   - evaluatedAt timestamp
4. Serializes to shared JSON contract consumable directly by exam-service in .NET.
"""

from __future__ import annotations

import datetime
import json
from pathlib import Path
from typing import Any, Mapping, Optional

from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType, canonical_json_dump_prep
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.reading_evaluation import evaluate_paper, evaluate_question, evaluate_section
from app.reading_policy import PinnedExecutionPolicy
from app.visual.evaluator import SvgVisualEvaluator

FIXTURE_PATH = Path(__file__).resolve().parents[1] / "tests" / "fixtures" / "canonical_40_question_reading_paper.json"
DEFAULT_BUNDLE_PATH = Path(__file__).resolve().parents[1] / "tests" / "fixtures" / "canonical_40_question_acceptance_bundle.json"


def load_canonical_paper_fixture(path: Optional[Path] = None) -> dict[str, Any]:
    target = path or FIXTURE_PATH
    if not target.exists():
        raise FileNotFoundError(f"Canonical 40Q fixture not found at {target}")
    return json.loads(target.read_text(encoding="utf-8"))


def build_canonical_acceptance_bundle(
    fixture_data: Optional[dict[str, Any]] = None,
    policy: Optional[PinnedExecutionPolicy] = None,
    base_time: Optional[datetime.datetime] = None,
) -> dict[str, Any]:
    """Builds exact canonical artifact envelopes and runs genuine production evaluators."""
    fixture = fixture_data or load_canonical_paper_fixture()
    pol = policy or PinnedExecutionPolicy(provider="mock")

    now = base_time or datetime.datetime.now(datetime.timezone.utc)
    # Stagger timestamps deterministically so parent heads precede children and evaluations
    t_blueprint = now - datetime.timedelta(minutes=8)
    t_passage = now - datetime.timedelta(minutes=6)
    t_question = now - datetime.timedelta(minutes=4)
    t_section = now - datetime.timedelta(minutes=2)
    t_paper = now - datetime.timedelta(minutes=1)
    t_eval = now

    run_id = fixture["runId"]

    # 1. Blueprint Envelope
    bp_id = fixture["blueprintRef"]["artifactId"]
    bp_payload = {
        "totalQuestions": 40,
        "targetWordCountMin": 2150,
        "targetWordCountMax": 2750,
        "topic": "Contemporary Archaeological, Energy and Earth Systems Research",
    }
    bp_env = ArtifactEnvelope.create(
        bp_id,
        ArtifactType.EXAM_BLUEPRINT,
        run_id,
        bp_payload,
        "2.0.0",
        parent_refs=[],
        created_at=t_blueprint,
    )
    bp_ref = bp_env.to_ref()

    # 2. Section, Passage, and Question Envelopes
    sec_envs: list[ArtifactEnvelope] = []
    passage_envs: list[ArtifactEnvelope] = []
    question_envs: list[ArtifactEnvelope] = []
    all_q_refs: list[ArtifactRef] = []
    question_evaluations: list[EvaluationResult] = []
    section_evaluations: list[EvaluationResult] = []

    svg_eval = SvgVisualEvaluator()

    for s_idx, sec in enumerate(fixture["sections"]):
        sec_num = s_idx + 1
        sec_cfg = pol.section(sec_num)

        # Passage Envelope
        p_id = f"passage:canonical-40q-shared:{sec_num}"
        p_payload = {
            "text": sec["passage"],
            "passage": sec["passage"],
            "wordCount": sec["wordCount"],
            "source": sec["source"],
        }
        p_env = ArtifactEnvelope.create(
            p_id,
            ArtifactType.PASSAGE,
            run_id,
            p_payload,
            "2.0.0",
            section_id=sec_num,
            parent_refs=[bp_ref],
            created_at=t_passage,
        )
        p_ref = p_env.to_ref()
        passage_envs.append(p_env)

        # Questions in this section
        sec_q_refs: list[ArtifactRef] = []
        for grp in sec.get("groups", []):
            if grp.get("questionType") in ("DIAGRAM_LABEL", "FLOW_CHART"):
                grp_callouts = [q["questionNumber"] for q in grp["questions"]]
                svg_xml = grp.get("svgXml") or grp["questions"][0].get("svgXml")
                res = svg_eval.evaluate(svg_xml, expected_callouts=grp_callouts)
                if not res.is_valid:
                    raise ValueError(f"Visual asset validation failed in section {sec_num}: {res.errors}")

            for q in grp.get("questions", []):
                q_num = q["questionNumber"]
                q_id = f"question:canonical-40q-shared:{q_num}"
                q_env = ArtifactEnvelope.create(
                    q_id,
                    ArtifactType.QUESTION,
                    run_id,
                    q,
                    "2.0.0",
                    section_id=sec_num,
                    parent_refs=[p_ref, bp_ref],
                    created_at=t_question,
                )
                q_ref = q_env.to_ref()
                question_envs.append(q_env)
                sec_q_refs.append(q_ref)
                all_q_refs.append(q_ref)

                # Question evaluation
                q_evals = evaluate_question(q_env, sec["passage"], sec_cfg.difficulty.value, siblings=[])
                for ev in q_evals:
                    if ev.status != EvaluationStatus.PASS:
                        raise ValueError(f"Q{q_num} evaluator {ev.evaluator_id} failed: {[i.message for i in ev.issues]}")
                question_evaluations.extend(q_evals)

        # Section Envelope
        sec_id = f"section:canonical-40q-shared:{sec_num}"
        sec_parents = [p_ref, bp_ref] + sec_q_refs
        sec_payload = {
            "sectionId": sec_num,
            "title": sec["title"],
            "passage": sec["passage"],
            "wordCount": sec["wordCount"],
            "source": sec["source"],
            "passageRef": p_ref.model_dump(by_alias=True),
            "blueprintRef": bp_ref.model_dump(by_alias=True),
            "questionRefs": [r.model_dump(by_alias=True) for r in sec_q_refs],
            "groups": sec["groups"],
        }
        sec_env = ArtifactEnvelope.create(
            sec_id,
            ArtifactType.SECTION,
            run_id,
            sec_payload,
            "2.0.0",
            section_id=sec_num,
            parent_refs=sec_parents,
            created_at=t_section,
        )
        sec_envs.append(sec_env)

        # Section evaluation
        sec_evals = evaluate_section(sec_env, sec_cfg)
        for ev in sec_evals:
            if ev.status != EvaluationStatus.PASS:
                raise ValueError(f"Section {sec_num} evaluator {ev.evaluator_id} failed: {[i.message for i in ev.issues]}")
        section_evaluations.extend(sec_evals)

    # 3. Paper Envelope
    sec_refs = [s.to_ref() for s in sec_envs]
    passage_refs = [p.to_ref() for p in passage_envs]
    paper_parents = [bp_ref] + sec_refs + passage_refs + all_q_refs
    paper_id = fixture["paperId"]
    paper_payload = {
        "paperId": paper_id,
        "runId": run_id,
        "title": fixture["title"],
        "totalQuestions": 40,
        "totalWords": fixture["totalWords"],
        "blueprintRef": bp_ref.model_dump(by_alias=True),
        "sectionRefs": [r.model_dump(by_alias=True) for r in sec_refs],
        "passageRefs": [r.model_dump(by_alias=True) for r in passage_refs],
        "questionRefs": [r.model_dump(by_alias=True) for r in all_q_refs],
        "sections": [s.payload for s in sec_envs],
    }
    paper_env = ArtifactEnvelope.create(
        paper_id,
        ArtifactType.READING_PAPER,
        run_id,
        paper_payload,
        "2.0.0",
        parent_refs=paper_parents,
        created_at=t_paper,
    )

    # 4. Invoke Real Production Paper Evaluators
    paper_evals = evaluate_paper(paper_env, pol)
    for ev in paper_evals:
        if ev.status != EvaluationStatus.PASS:
            raise ValueError(f"Paper evaluator {ev.evaluator_id} failed: {[i.message for i in ev.issues]}")

    # Build all envelopes list
    all_envelopes = [bp_env] + passage_envs + question_envs + sec_envs + [paper_env]

    # Convert to serialized bundle format
    bundle = {
        "bundleVersion": "2.0.0",
        "producer": "app.acceptance_bridge",
        "producedAt": now.isoformat(),
        "runId": run_id,
        "paperId": paper_id,
        "paperArtifactRef": paper_env.to_ref().model_dump(by_alias=True),
        "envelopes": [env.model_dump(by_alias=True, mode="json") for env in all_envelopes],
        "evaluations": [ev.model_dump(by_alias=True, mode="json") for ev in paper_evals],
        "sectionEvaluations": [ev.model_dump(by_alias=True, mode="json") for ev in section_evaluations],
        "questionEvaluations": [ev.model_dump(by_alias=True, mode="json") for ev in question_evaluations],
        "sources": [s["source"] for s in fixture["sections"]],
        "sections": [canonical_json_dump_prep(s.payload) for s in sec_envs],
    }

    return bundle


def generate_and_save_acceptance_bundle(output_path: Optional[Path] = None) -> Path:
    target = output_path or DEFAULT_BUNDLE_PATH
    bundle = build_canonical_acceptance_bundle()
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(bundle, indent=2, ensure_ascii=False), encoding="utf-8")
    return target


if __name__ == "__main__":
    out = generate_and_save_acceptance_bundle()
    print(f"Successfully generated acceptance bundle at: {out}")
