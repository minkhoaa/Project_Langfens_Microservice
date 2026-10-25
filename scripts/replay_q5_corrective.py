#!/usr/bin/env python3
"""Offline replay of saved Q5 payloads; never dispatches a provider or writes a DB."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "services/generation-service"))

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.reading_evaluation import (
    _has_category_marker_conflict, claim_discriminators,
    compute_substantive_grounding_ratio, evaluate_question,
    verify_question_claim_provenance,
)
from app.section_runner import _parse_candidate_payload, _parse_single_candidate
from app.solvers.adjudication import adjudicate_item
from app.solvers.adversary import parse_and_validate_adversary_output
from app.solvers.comparison import compare_answers
from app.solvers.serializer import build_blind_solver_input
from app.solvers.solver import parse_and_validate_solver_output

SNAPSHOT = ROOT / "reports/hybrid_13q_post_hardening_2250820f-0ed9-42cb-80e8-70bcc38f2a7e.json"


def load_history():
    snapshot = json.loads(SNAPSHOT.read_text())
    artifacts = [(a, json.loads(a["PayloadJson"])) for a in snapshot["all_artifacts"]]
    passage = next(p for a, p in artifacts if a["ArtifactType"] == "Passage")
    claims = next(p["claims"] for a, p in artifacts if a["ArtifactType"] == "EvidenceGraph")
    claims = {c["claimId"]: c for c in claims}
    blueprint = next(p for a, p in artifacts if a["ArtifactType"] == "ExamBlueprint")
    slot = blueprint["sections"][0]["questionSlots"][4]
    operations = {o["OperationId"]: json.loads(o["ResultRefJson"]) for o in snapshot["operations"]["actual_db_operations"] if o["OperationType"] == "PROVIDER_CALL"}
    return snapshot, artifacts, passage, claims, slot, operations


def replay():
    snap, arts, passage_payload, claims, slot, ops = load_history()
    passage = passage_payload["passage"]
    bound_id = slot["claimRefIds"][0]
    bound = claims[bound_id]["text"]
    rows = []
    for version in (1, 2, 3):
        op = ops[f"op:{snap['run_id']}:question:5:1_{version}"]
        raw = op["parsed_payload"]
        selected = _parse_candidate_payload(raw, 5, slot["questionType"], passage, claims, bound_id, "FOUNDATION", is_not_given_target=slot["isNotGivenTarget"])
        historical = next(p for a, p in arts if a["ArtifactType"] == "Question" and p.get("questionNumber") == 5 and a["Version"] == version)
        for idx, cand in enumerate(raw["candidates"]):
            row = {"version": version, "candidate": idx, "raw": cand, "bound_claim": bound,
                   "advisory_target_penalty": int(cand["answer"] == "NOT_GIVEN"),
                   "selected": selected["statement"] == cand["prompt"],
                   "historically_selected": historical["statement"] == cand["prompt"]}
            try:
                parsed = _parse_single_candidate(cand, raw, 5, slot["questionType"], passage, claims, bound_id, "FOUNDATION")
                row["parsed"] = parsed
                quote = parsed["passageEvidence"]["text"]
                row["bound_ratio"] = compute_substantive_grounding_ratio(bound, quote)[0]
                bm, qm = claim_discriminators(bound), claim_discriminators(quote)
                row["bound_markers"], row["quote_markers"] = sorted(bm), sorted(qm)
                row["competing_claims"] = [
                    {"id": cid, "text": c["text"], "ratio": compute_substantive_grounding_ratio(c["text"], quote)[0],
                     "marker_conflict": _has_category_marker_conflict(bm, qm, claim_discriminators(c["text"]))}
                    for cid, c in claims.items() if cid != bound_id and compute_substantive_grounding_ratio(c["text"], quote)[0] >= .4
                ]
                provenance = verify_question_claim_provenance(parsed, slot, claims, passage)
                row["parser_rejection"] = [[code.value, msg] for code, msg in provenance]
                art = ArtifactEnvelope.create("question:replay:5", ArtifactType.QUESTION, snap["run_id"], parsed, "offline-replay", version=version)
                row["evaluations"] = [{"id": e.evaluator_id, "status": e.status.value, "issues": [i.model_dump(mode="json", by_alias=True) for i in e.issues]} for e in evaluate_question(art, passage, "FOUNDATION", [], blueprint_slot=slot, claims=claims)]
                if row["historically_selected"]:
                    sr = ops[f"op_solve_{snap['run_id']}_question:{snap['run_id']}:5_{version}"]
                    ar = ops[f"op_adv_{snap['run_id']}_question:{snap['run_id']}:5_{version}"]
                    solver, errors = parse_and_validate_solver_output(sr["raw_text"], passage, 5, slot["questionType"])
                    blind = build_blind_solver_input(passage, parsed)
                    adv, adv_errors, rejected = parse_and_validate_adversary_output(ar["raw_text"], passage, 5, student_question=blind.question)
                    adj = adjudicate_item(compare_answers(parsed["answer"], solver.normalized_answer if solver else "", slot["questionType"], 5), adv, passage, solver, blind.question)
                    row["blind_replay"] = {"solver_raw": sr["raw_text"], "solver": solver.model_dump(mode="json", by_alias=True) if solver else None, "solver_errors": errors,
                                          "adversary_raw": ar["raw_text"], "adversary": adv.model_dump(mode="json", by_alias=True) if adv else None, "adversary_errors": adv_errors, "rejected_alternatives": rejected,
                                          "adjudication": adj.model_dump(mode="json", by_alias=True)}
                else:
                    row["blind_replay"] = "NOT_RUN: no historical solver/adversary payload for this proposition; cannot reuse another candidate's answers"
            except ValueError as exc:
                row["parser_rejection"] = str(exc)
            rows.append(row)
    return {"snapshot": str(SNAPSHOT.relative_to(ROOT)), "slot": slot, "rows": rows}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = replay()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n")
    for row in result["rows"]:
        print(f"V{row['version']} c{row['candidate']} {row['raw']['answer']} selected={row['selected']} rejection={row['parser_rejection']}")
        print("  evidence:", row.get("parsed", {}).get("passageEvidence"))
        print("  semantic:", next((e for e in row.get("evaluations", []) if e["id"] == "eval_question_semantic"), None))
        if isinstance(row.get("blind_replay"), dict):
            print("  adjudication:", row["blind_replay"]["adjudication"])
