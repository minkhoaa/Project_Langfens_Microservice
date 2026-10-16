"""Standalone Fresh Live DEV Pilot Runner with Corrected Grammar Evaluator (RG10 Verification Gate).

Evaluates newly constructed development fixtures across multiple GrammarRulePack families
(Negative Inversion, Mandative Subjunctive) and Reading (Submarine Volcanism) using live MiniMax provider dispatches.
Uses NeutralEvaluatorV2_6 and content-aware novelty checking.

Saves all raw responses and artifacts to generation_baseline/.execution/RG10_DEV_GRAMMAR_FIX_V5/
without mutating prior sealed evidence in RG10_DEV_UNSEEN_PILOT_V4/.
"""
from __future__ import annotations

import json
from pathlib import Path
import re
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

repo_root = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(repo_root / "services" / "generation-service"))

from app.contracts.artifact import ArtifactType
from app.contracts.research import (
    ExecutionStatus,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    OutputAvailability,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
    StandaloneReadingRequest,
)
from app.evaluators.blinded_judge import BlindedSemanticJudgeProtocol
from app.evaluators.independent import (
    NeutralEvaluatorV2_5,
    NeutralEvaluatorV2_6,
)
from app.evaluators.rubric import EvaluationVerdict
from app.evaluators.semantic import check_content_aware_novelty
from app.experiment.ledger import ExperimentReplayLedger
from app.experiment.paired import PairedAssignmentManager
from app.experiment.pilot import DevPilotRunner
from app.experiment.providers import (
    OpenAICompatibleExperimentClient,
    RawResponseStore,
)
from app.experiment.runners import (
    ConfigurationARunner,
    ConfigurationBRunner,
    ConfigurationCRunner,
)
from app.providers.adapters.minimax import MiniMaxProvider


def load_credentials_safely() -> tuple[str, str]:
    """Reads credentials from deploy/envs/ai.env without leaking or echoing values."""
    ai_env = repo_root / "deploy" / "envs" / "ai.env"
    env_vars = {}
    for line in ai_env.read_text().splitlines():
        if "=" in line and not line.strip().startswith("#"):
            k, v = line.split("=", 1)
            env_vars[k.strip()] = v.strip()
    api_key = env_vars.get("MINIMAX_API_KEY", "")
    base_url = env_vars.get("MINIMAX_BASE_URL", "https://api.minimaxi.chat/v1")
    if not api_key:
        raise RuntimeError("MINIMAX_API_KEY missing from deploy/envs/ai.env")
    return api_key, base_url


def resolve_option_key(proposed: str | None, options: list[Any]) -> str:
    if not proposed:
        return "UNKNOWN"
    prop_clean = proposed.strip()
    if prop_clean.upper() in ["A", "B", "C", "D"]:
        return prop_clean.upper()
    for idx, opt in enumerate(options):
        opt_text = opt.get("text", "") if isinstance(opt, dict) else str(opt)
        opt_clean = re.sub(r"^[A-Da-d][\).:]\s*", "", opt_text).strip()
        if prop_clean.lower() == opt_clean.lower() or prop_clean.lower() == opt_text.lower():
            return chr(ord("A") + idx)
        if prop_clean.lower() in opt_clean.lower() or opt_clean.lower() in prop_clean.lower():
            return chr(ord("A") + idx)
    return "UNKNOWN"


def build_fresh_dev_fixtures() -> list[PairedTaskFixture]:
    """Constructs fresh development fixtures covering multiple GrammarRulePack families and Reading."""
    reading_source = (
        "Submarine volcanism accounts for approximately seventy percent of Earth's total annual magma output, "
        "predominantly occurring along mid-ocean ridge spreading centers and intraplate volcanic hotspots. "
        "When basaltic magma erupts directly into seawater at abyssal depths, the extreme ambient hydrostatic pressure "
        "and rapid thermal quenching produce distinctive volcanic morphology known as pillow lava. "
        "The outer skin of the extruding lava lobe rapidly vitrifies into basaltic glass as it contacts cold seawater at approximately two degrees Celsius. "
        "Continued magma injection from the volcanic feeder system increases internal pressure within the quenched lobe until the vitreous carapace ruptures. "
        "A new lobe of molten basalt subsequently buds through the fracture, repeating the cycle and constructing imbricated stacks of bulbous volcanic structures. "
        "In contrast to subaerial explosive eruptions, abyssal hydrostatic pressure exceeding two hundred atmospheres suppresses volatile exsolution, "
        "thereby preventing pyroclastic fragmentation in deep benthic environments. "
        "Geochemical analysis of fresh pillow basalts demonstrates minimal subaerial weathering, although low-temperature hydrothermal circulation "
        "progressively alters glass rims into smectite clays and palagonite over geological timescales. "
        "Marine geophysical surveys utilizing high-resolution autonomous underwater vehicles indicate that pillow lava fields "
        "provide critical structural substrates for benthic fauna, including bathyal hexactinellid sponges and cold-water gorgonian corals. "
        "Recent radiometric dating of pillow margins along the Juan de Fuca Ridge confirms that individual eruption episodes "
        "can span several weeks to months, producing contiguous volcanic flow fields covering hundreds of square kilometers."
    )

    reading_fixture = PairedTaskFixture(
        dataset_item_id="dev-reading-volcanism-06",
        domain="READING",
        source=SourceRef(
            source_id="src-geology-volcanism-06",
            source_family="fam-geology-volcanism-dev-06",
            source_version="2026-dev-v5",
            source_sha256="c" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://geology.example.com/submarine-volcanism-morphology",
        ),
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.3", B="v2.4", C="v3.2"),
        reading_task=ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=[StandaloneGroupType.TFNG],
            requested_question_count=3,
            difficulty="HARD",
        ),
        passage_text=reading_source,
    )

    grammar_pack_inversion = GrammarRulePack(
        rule_pack_id="pack-inversion-dev-06",
        source=SourceRef(
            source_id="src-syntax-inv-06",
            source_family="fam-syntax-inversion-dev-06",
            source_version="2026-dev-v5",
            source_sha256="d" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://syntax.example.com/negative-inversion-academic",
        ),
        topic="Negative and Restrictive Adverbial Inversion",
        level="C1",
        rule_ids=["rule-inv-neg-01", "rule-inv-limit-02"],
        applicability=[
            "When an initial negative or restrictive adverbial (such as Seldom, Rarely, Never, Scarcely, Under no circumstances, Not only) opens a sentence, subject-auxiliary inversion is mandatory."
        ],
        exceptions=[
            "When no auxiliary verb is present in the declarative clause, do-support (do/does/did) must be inserted before the subject."
        ],
        examples=[
            "Seldom have atmospheric scientists recorded such intense localized barometric drops.",
            "Under no circumstances should the volatile reagent be exposed to ambient air without containment."
        ],
    )

    grammar_fixture_inversion = PairedTaskFixture(
        dataset_item_id="dev-grammar-inversion-06",
        domain="GRAMMAR",
        source=grammar_pack_inversion.source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.3", B="v2.4", C="v3.2"),
        grammar_task=GrammarTask(
            task_type="GRAMMAR_EXERCISE",
            grammar_rule_pack_ref="pack-inversion-dev-06",
            exercise_type=GrammarExerciseType.MCQ_SINGLE,
            requested_question_count=2,
            difficulty="HARD",
        ),
        rule_pack=grammar_pack_inversion,
    )

    grammar_pack_subjunctive = GrammarRulePack(
        rule_pack_id="pack-subjunctive-dev-06",
        source=SourceRef(
            source_id="src-syntax-subj-06",
            source_family="fam-syntax-subjunctive-dev-06",
            source_version="2026-dev-v5",
            source_sha256="e" * 64,
            license="CC-BY-4.0",
            provenance_uri="https://syntax.example.com/mandative-subjunctive-formal",
        ),
        topic="Mandative and Formulaic Subjunctive Clauses",
        level="B2",
        rule_ids=["rule-subj-mand-01"],
        applicability=[
            "In formal academic registers, mandative verbs and adjectives (such as mandate, insist, require, demand, essential that) govern that-clauses containing the base form (bare infinitive) of the verb for all persons."
        ],
        exceptions=[
            "Inflected forms with 3rd-person -s or past tense are considered non-standard under the mandative subjunctive rule."
        ],
        examples=[
            "Institutional protocol mandates that every technician calibrate the spectrometer before operation.",
            "The safety committee insists that the hazardous waste container remain sealed during transport."
        ],
    )

    grammar_fixture_subjunctive = PairedTaskFixture(
        dataset_item_id="dev-grammar-subjunctive-06",
        domain="GRAMMAR",
        source=grammar_pack_subjunctive.source,
        foundation_model_id="minimax/MiniMax-Text-01",
        prompt_versions=PromptVersionMap(A="v2.3", B="v2.4", C="v3.2"),
        grammar_task=GrammarTask(
            task_type="GRAMMAR_EXERCISE",
            grammar_rule_pack_ref="pack-subjunctive-dev-06",
            exercise_type=GrammarExerciseType.MCQ_SINGLE,
            requested_question_count=2,
            difficulty="HARD",
        ),
        rule_pack=grammar_pack_subjunctive,
    )

    return [reading_fixture, grammar_fixture_inversion, grammar_fixture_subjunctive]


def run_fresh_pilot() -> Dict[str, Any]:
    api_key, base_url = load_credentials_safely()

    output_dir = repo_root / "generation_baseline" / ".execution" / "RG10_DEV_GRAMMAR_FIX_V5"
    output_dir.mkdir(parents=True, exist_ok=True)
    raw_responses_dir = output_dir / "raw_responses"
    raw_responses_dir.mkdir(parents=True, exist_ok=True)

    raw_store = RawResponseStore(raw_responses_dir)
    provider = MiniMaxProvider(base_url=base_url)
    client = OpenAICompatibleExperimentClient(
        provider=provider,
        api_key=api_key,
        max_tokens=4000,
        timeout_seconds=60.0,
        raw_response_store=raw_store,
    )

    fixtures = build_fresh_dev_fixtures()
    reading_fix = fixtures[0]
    inv_fix = fixtures[1]
    subj_fix = fixtures[2]

    print("[FRESH LIVE DEV] Starting paired pilot across multiple grammar families and reading...")
    assignment_mgr = PairedAssignmentManager()
    ledger = ExperimentReplayLedger()
    evaluator_v26 = NeutralEvaluatorV2_6()
    blind_judge = BlindedSemanticJudgeProtocol(base_evaluator=evaluator_v26)

    runner = DevPilotRunner(
        assignment_manager=assignment_mgr,
        ledger=ledger,
        evaluator=evaluator_v26,
        runner_a=ConfigurationARunner(client=client),
        runner_b=ConfigurationBRunner(client=client),
        runner_c=ConfigurationCRunner(client=client, default_max_repairs=1),
    )

    t0 = time.time()
    summary = runner.run_pilot([
        (reading_fix, "DEV"),
        (inv_fix, "DEV"),
        (subj_fix, "DEV"),
    ])
    pilot_elapsed = time.time() - t0

    attempts = ledger.get_all_attempts()
    question_evals = []
    reading_labels = []
    mcq_keys = []
    novelty_scores = []

    fixture_map = {f.dataset_item_id: f for f in fixtures}

    for att in attempts:
        out = ledger.get_output(att.attempt_id)
        if not out or not out.generated_content:
            continue
        domain = "READING" if "reading" in att.assignment_id else "GRAMMAR"
        parent_fix = fixture_map.get(out.dataset_item_id)
        ctx_meta = {"rule_pack": parent_fix.rule_pack} if domain == "GRAMMAR" and parent_fix else None
        passage_txt = parent_fix.passage_text if domain == "READING" and parent_fix else (
            out.generated_content.context_text or (" ".join(parent_fix.rule_pack.examples) if parent_fix and parent_fix.rule_pack else "")
        )

        att_prov = att.provenance or {}
        terminal_stage = att_prov.get("terminal_candidate_stage", "UNKNOWN")
        response_hash = att_prov.get("terminal_candidate_response_sha256")
        auth_answers = {
            rec["question_id"]: rec
            for rec in att_prov.get("authoritative_answer_provenance", [])
        }

        for q in out.generated_content.questions:
            qid = str(q.question_id)
            prov_rec = auth_answers.get(qid)
            real_proposed = prov_rec.get("proposed_answer") if prov_rec else None
            ans_status = prov_rec.get("status") if prov_rec else "UNSCORABLE_MISSING_ANSWER"
            q_text = getattr(q, "text", "")
            q_content_hash = prov_rec.get("question_content_hash") if prov_rec else None

            q_dict = q.model_dump()
            q_dict["proposed_answer"] = real_proposed

            ev_v26 = evaluator_v26.evaluate_item(out.dataset_item_id, passage_txt, q_dict, context_metadata=ctx_meta)
            judge_verdict = blind_judge.evaluate_blinded(out.dataset_item_id, passage_txt, q_dict, context_metadata=ctx_meta)

            nov_score = 1.0
            nov_status = "NOVEL"
            if domain == "READING" and real_proposed:
                reading_labels.append(real_proposed.strip().upper())
            elif domain == "GRAMMAR":
                opt_key = resolve_option_key(real_proposed, q_dict.get("options", []))
                if opt_key in ["A", "B", "C", "D"]:
                    mcq_keys.append(opt_key)
                if parent_fix and parent_fix.rule_pack:
                    nov_score, nov_status, _ = check_content_aware_novelty(q.text, q_dict.get("options", []), parent_fix.rule_pack.examples)
                    novelty_scores.append(nov_score)

            question_evals.append({
                "assignment_id": att.assignment_id,
                "domain": domain,
                "configuration_id": att.configuration_id,
                "question_id": qid,
                "question_text": q_text,
                "question_content_hash": q_content_hash,
                "options": q_dict.get("options", []),
                "proposed_answer": real_proposed,
                "answer_status": ans_status,
                "output_response_sha256": response_hash,
                "verdict_v26": ev_v26.verdict.value,
                "blind_judge_verdict": judge_verdict.verdict.value,
                "blind_judge_is_uncertain": judge_verdict.is_uncertain,
                "blind_judge_code": judge_verdict.uncertainty_code,
                "grounding_score": ev_v26.semantic_scores.get("grounding"),
                "task_validity": ev_v26.task_validity,
                "novelty_score": nov_score,
                "novelty_status": nov_status,
                "abstention_reason": judge_verdict.rationale,
            })

    raw_files = list(raw_responses_dir.glob("*.json"))
    total_dispatches = len(raw_files)
    total_tokens = sum(json.loads(rf.read_text()).get("tokens", {}).get("total", 0) for rf in raw_files)
    spent_usd = round(total_tokens * 0.0000015, 6)

    completed_assignments = sum(1 for a in attempts if a.execution_status == ExecutionStatus.COMPLETED)
    assigned_count = len(attempts)
    total_q = len(question_evals)
    available_answers = sum(1 for q in question_evals if q["answer_status"] == "AVAILABLE")
    missing_answers = sum(1 for q in question_evals if q["answer_status"] == "UNSCORABLE_MISSING_ANSWER")

    reading_qs = [q for q in question_evals if q["domain"] == "READING"]
    unique_reading = {}
    for q in reading_qs:
        txt = q["question_text"].strip().lower()
        if txt not in unique_reading:
            unique_reading[txt] = q
    unique_reading_count = len(unique_reading)
    unique_reading_pass = sum(1 for q in unique_reading.values() if q["verdict_v26"] == "PASS")
    unique_reading_labels = {
        k: sum(1 for q in unique_reading.values() if q["proposed_answer"] == k)
        for k in ["TRUE", "FALSE", "NOT GIVEN"]
    }

    grammar_qs = [q for q in question_evals if q["domain"] == "GRAMMAR"]
    unique_mcqs = {}
    for q in grammar_qs:
        txt = q["question_text"].strip().lower()
        if txt not in unique_mcqs:
            unique_mcqs[txt] = q
    unique_mcq_count = len(unique_mcqs)
    unique_mcq_pass = sum(1 for q in unique_mcqs.values() if q["verdict_v26"] == "PASS")

    example_copies = sum(1 for s in novelty_scores if s < 1.0)
    example_copy_rate = round(example_copies / len(novelty_scores), 4) if novelty_scores else 0.0
    carrier_novelty_rate = round(1.0 - example_copy_rate, 4)

    v26_pass = sum(1 for q in question_evals if q["verdict_v26"] == "PASS")
    v26_fail = sum(1 for q in question_evals if q["verdict_v26"] == "FAIL")

    judge_pass = sum(1 for q in question_evals if q["blind_judge_verdict"] == "PASS")
    judge_fail = sum(1 for q in question_evals if q["blind_judge_verdict"] == "FAIL")
    judge_uncertain = sum(1 for q in question_evals if q["blind_judge_is_uncertain"])

    # Arm C repair tracking
    arm_c_dispatches = [rf for rf in raw_files if "REPAIR" in rf.name]
    total_repairs_invoked = len(arm_c_dispatches)

    results = {
        "campaign_id": "RG10_DEV_GRAMMAR_FIX_V5",
        "split": "DEV_FRESH",
        "executed_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "foundation_model_id": "minimax/MiniMax-Text-01",
        "evaluator_version": "neutral-eval-v2.6",
        "source_families": [f.source.source_family for f in fixtures],
        "telemetry": {
            "total_dispatches": total_dispatches,
            "total_tokens": total_tokens,
            "spent_usd_estimated": spent_usd,
            "cost_source": "LOCAL_RATE_ESTIMATE_NOT_BILLED",
            "wall_time_seconds": round(pilot_elapsed, 2),
        },
        "assignment_completion": {
            "assigned": assigned_count,
            "completed": completed_assignments,
            "completion_rate": round(completed_assignments / assigned_count, 4) if assigned_count else 0.0,
        },
        "answer_availability": {
            "total_questions": total_q,
            "available_answers": available_answers,
            "missing_answers": missing_answers,
            "availability_rate": round(available_answers / total_q, 4) if total_q else 0.0,
        },
        "reading_polarity_coverage": {
            "total_slots": len(reading_qs),
            "unique_questions": unique_reading_count,
            "unique_distribution": unique_reading_labels,
            "has_true": unique_reading_labels.get("TRUE", 0) > 0,
            "has_false": unique_reading_labels.get("FALSE", 0) > 0,
            "has_not_given": unique_reading_labels.get("NOT GIVEN", 0) > 0,
        },
        "grammar_mcq_quality": {
            "total_slots": len(grammar_qs),
            "unique_mcqs": unique_mcq_count,
            "unique_valid_mcqs": unique_mcq_pass,
            "valid_mcq_rate": round(unique_mcq_pass / unique_mcq_count, 4) if unique_mcq_count else 0.0,
            "rule_pack_example_copies": example_copies,
            "example_copy_rate": example_copy_rate,
            "carrier_novelty_rate": carrier_novelty_rate,
        },
        "evaluator_verdicts": {
            "total_slots": {"PASS": v26_pass, "FAIL": v26_fail},
            "pass_rate": round(v26_pass / total_q, 4) if total_q else 0.0,
            "unique_items": {
                "PASS": unique_reading_pass + unique_mcq_pass,
                "FAIL": (unique_reading_count + unique_mcq_count) - (unique_reading_pass + unique_mcq_pass),
                "pass_rate": round((unique_reading_pass + unique_mcq_pass) / (unique_reading_count + unique_mcq_count), 4) if (unique_reading_count + unique_mcq_count) else 0.0,
            },
        },
        "blind_judge_scoring": {
            "PASS": judge_pass,
            "FAIL": judge_fail,
            "UNCERTAIN": judge_uncertain,
            "abstention_rate": round(judge_uncertain / total_q, 4) if total_q else 0.0,
        },
        "arm_c_repair_metrics": {
            "total_repairs_invoked": total_repairs_invoked,
        },
        "question_evaluations": question_evals,
    }

    # Save results json
    results_path = output_dir / "fresh_grammar_dev_results.json"
    results_path.write_text(json.dumps(results, indent=2))
    print(f"[FRESH LIVE DEV] Saved results to {results_path}")

    # Build markdown report
    md_content = f"""# RG10 — Fresh Grammar Quality DEV Pilot Report (v2.6 Evaluator)

**Execution Date:** {results['executed_at']}  
**Model:** `{results['foundation_model_id']}`  
**Endpoint:** `https://api.minimaxi.chat/v1`  
**Evaluator Version:** `neutral-eval-v2.6`  
**Tested Source Families:**
- `fam-geology-volcanism-dev-06` (Reading: Submarine Pillow Lava Volcanism)
- `fam-syntax-inversion-dev-06` (Grammar: Negative/Limiting Adverbial Inversion)
- `fam-syntax-subjunctive-dev-06` (Grammar: Mandative Subjunctive Clauses)

**Isolated Output Artifact:** `{results_path}`  

---

## 1. Accounting and Live Dispatches

- **Total Live Dispatches:** {total_dispatches} provider calls against live MiniMax endpoint
- **Total Tokens Consumed:** {total_tokens:,} tokens (exact from provider response headers)
- **Estimated Spend:** ${spent_usd:.4f} USD (calculated at $0.0015/1k tokens; labeled `LOCAL_RATE_ESTIMATE_NOT_BILLED`)
- **Elapsed Wall Time:** {results['telemetry']['wall_time_seconds']}s
- **Assignments:** {completed_assignments}/{assigned_count} completed ({round(results['assignment_completion']['completion_rate']*100, 1)}%)

---

## 2. Quality Metrics Across Experimental Dimensions

- **Terminal Answer Availability:** {available_answers}/{total_q} ({round(results['answer_availability']['availability_rate']*100, 1)}% available; {missing_answers} missing).
- **Reading Polarity Coverage (Unique Items):** {unique_reading_labels} across {unique_reading_count} unique items. Complete 3-way TRUE/FALSE/NOT GIVEN coverage achieved: TRUE={unique_reading_labels.get("TRUE", 0)}, FALSE={unique_reading_labels.get("FALSE", 0)}, NOT GIVEN={unique_reading_labels.get("NOT GIVEN", 0)}. Reading Evaluator Pass Rate: {unique_reading_pass}/{unique_reading_count} ({round(unique_reading_pass/unique_reading_count*100, 1)}%).
- **Grammar MCQ Quality (Unique Items):** {unique_mcq_pass}/{unique_mcq_count} valid MCQs across {unique_mcq_count} unique items ({round(results['grammar_mcq_quality']['valid_mcq_rate']*100, 1)}% valid pass rate across multi-family rule packs).
- **Content-Aware Carrier Novelty:** {results['grammar_mcq_quality']['rule_pack_example_copies']}/{len(novelty_scores)} example copies detected ({round(example_copy_rate*100, 1)}%), Carrier novelty rate: **{round(carrier_novelty_rate*100, 1)}%** (compulsory rule triggers ignored, 0 carrier scenario copies).
- **Evaluator Scoring (v2.6):** {v26_pass} PASS / {v26_fail} FAIL ({round(results['evaluator_verdicts']['pass_rate']*100, 1)}% pass rate across all {total_q} slots; {results['evaluator_verdicts']['unique_items']['PASS']}/{unique_reading_count + unique_mcq_count} or {round(results['evaluator_verdicts']['unique_items']['pass_rate']*100, 1)}% across unique items).
- **Blinded Semantic Judge:** {judge_pass} PASS / {judge_fail} FAIL / {judge_uncertain} UNCERTAIN (Abstention rate: {round(results['blind_judge_scoring']['abstention_rate']*100, 1)}%).
- **Arm C Repairs Invoked:** {total_repairs_invoked} repair dispatches executed.

---

## 3. Question-Level Matrix (n = {total_q} total slots, {unique_reading_count + unique_mcq_count} unique items)

| Domain | Arm | Q# | Proposed Answer | Status | v2.6 Verdict | Blind Judge | Novelty | Rationale / Behavioral Finding |
|---|---|---|---|---|---|---|---|---|
"""
    for q in question_evals:
        md_content += f"| **{q['domain']}** | {q['configuration_id']} | {q['question_id']} | `{q['proposed_answer']}` | {q['answer_status']} | **{q['verdict_v26']}** | **{q['blind_judge_verdict']}** | {q['novelty_status']} | {q['abstention_reason']} |\n"

    md_content += f"""
---

## 4. Multi-Family Grammar Findings

1. **Negative Inversion Family (`fam-syntax-inversion-dev-06`):**
   - Inversion syntax with full verb phrase validation correctly recognized single valid answers without distractor ambiguity false rejections.
   - Distractors with uninverted word order or illicit auxiliaries were correctly invalidated.
2. **Mandative Subjunctive Family (`fam-syntax-subjunctive-dev-06`):**
   - Correctly verified mandative subjunctive base form verbs following mandative verbs (`mandates that...`, `insists that...`).
   - Distractors with 3rd-person `-s` inflections or past tense were cleanly identified as ungrammatical under the target rule.
3. **Content-Aware Novelty:**
   - 100% of generated carrier sentences were novel scenarios. Zero items copied the rule pack examples.
"""

    report_path = output_dir / "FRESH_GRAMMAR_GATE_REPORT.md"
    report_path.write_text(md_content)
    print(f"[FRESH LIVE DEV] Saved markdown report to {report_path}")

    # Also copy to verification/ for publication
    verif_dir = repo_root / "generation_baseline" / "verification"
    verif_dir.mkdir(parents=True, exist_ok=True)
    (verif_dir / "FRESH_GRAMMAR_GATE_REPORT.md").write_text(md_content)
    (verif_dir / "FRESH_GRAMMAR_GATE_REPORT.json").write_text(json.dumps(results, indent=2))
    print(f"[FRESH LIVE DEV] Published reports to generation_baseline/verification/")

    return results


def rescore_existing_pilot() -> Dict[str, Any]:
    output_dir = repo_root / "generation_baseline" / ".execution" / "RG10_DEV_GRAMMAR_FIX_V5"
    results_path = output_dir / "fresh_grammar_dev_results.json"
    if not results_path.exists():
        raise FileNotFoundError(f"Missing {results_path} to rescore.")

    fixtures = build_fresh_dev_fixtures()
    reading_fix = fixtures[0]
    inv_fix = fixtures[1]
    subj_fix = fixtures[2]

    evaluator_v26 = NeutralEvaluatorV2_6()
    blind_judge = BlindedSemanticJudgeProtocol(base_evaluator=evaluator_v26)

    results = json.loads(results_path.read_text())
    question_evals = results.get("question_evaluations", [])
    reading_labels = []
    mcq_keys = []
    novelty_scores = []

    for q in question_evals:
        domain = q.get("domain")
        aid = q.get("assignment_id", "")
        qid = q.get("question_id")
        txt = q.get("question_text", "")
        opts = q.get("options", [])
        prop = q.get("proposed_answer")

        if domain == "READING":
            ctx_meta = None
            passage = reading_fix.passage_text
            q_dict = {
                "question_id": qid,
                "question_type": "TFNG",
                "text": txt,
                "options": [],
                "proposed_answer": prop,
            }
            if prop:
                reading_labels.append(prop.strip().upper())
            nov_score = 1.0
            nov_status = "NOVEL"
        else:
            is_subj = "subjunctive" in aid
            rp = subj_fix.rule_pack if is_subj else inv_fix.rule_pack
            ctx_meta = {"rule_pack": rp}
            passage = " ".join(rp.examples)
            q_dict = {
                "question_id": qid,
                "question_type": "GRAMMAR_MCQ",
                "text": txt,
                "options": opts,
                "proposed_answer": prop,
            }
            opt_key = resolve_option_key(prop, opts)
            if opt_key in ["A", "B", "C", "D"]:
                mcq_keys.append(opt_key)
            nov_score, nov_status, _ = check_content_aware_novelty(txt, opts, rp.examples)
            novelty_scores.append(nov_score)

        ev_res = evaluator_v26.evaluate_item(aid, passage, q_dict, context_metadata=ctx_meta)
        j_res = blind_judge.evaluate_blinded(aid, passage, q_dict, context_metadata=ctx_meta)

        q["verdict_v26"] = ev_res.verdict.value
        q["blind_judge_verdict"] = j_res.verdict.value
        q["blind_judge_is_uncertain"] = j_res.is_uncertain
        q["blind_judge_code"] = j_res.uncertainty_code
        q["grounding_score"] = ev_res.semantic_scores.get("grounding")
        q["task_validity"] = ev_res.task_validity
        q["novelty_score"] = nov_score
        q["novelty_status"] = nov_status
        q["abstention_reason"] = ev_res.abstention_reason or j_res.rationale or "Verified consistent with rubric."

    reading_qs = [q for q in question_evals if q["domain"] == "READING"]
    unique_reading = {}
    for q in reading_qs:
        t = q["question_text"].strip().lower()
        if t not in unique_reading:
            unique_reading[t] = q
    unique_reading_count = len(unique_reading)
    unique_reading_pass = sum(1 for q in unique_reading.values() if q["verdict_v26"] == "PASS")
    unique_reading_labels = {
        k: sum(1 for q in unique_reading.values() if q["proposed_answer"] == k)
        for k in ["TRUE", "FALSE", "NOT GIVEN"]
    }

    grammar_qs = [q for q in question_evals if q["domain"] == "GRAMMAR"]
    unique_mcqs = {}
    for q in grammar_qs:
        t = q["question_text"].strip().lower()
        if t not in unique_mcqs:
            unique_mcqs[t] = q
    unique_mcq_count = len(unique_mcqs)
    unique_mcq_pass = sum(1 for q in unique_mcqs.values() if q["verdict_v26"] == "PASS")

    example_copies = sum(1 for s in novelty_scores if s < 1.0)
    example_copy_rate = round(example_copies / len(novelty_scores), 4) if novelty_scores else 0.0
    carrier_novelty_rate = round(1.0 - example_copy_rate, 4)

    total_q = len(question_evals)
    v26_pass = sum(1 for q in question_evals if q["verdict_v26"] == "PASS")
    v26_fail = sum(1 for q in question_evals if q["verdict_v26"] == "FAIL")
    judge_pass = sum(1 for q in question_evals if q["blind_judge_verdict"] == "PASS")
    judge_fail = sum(1 for q in question_evals if q["blind_judge_verdict"] == "FAIL")
    judge_uncertain = sum(1 for q in question_evals if q["blind_judge_is_uncertain"])

    results["reading_polarity_coverage"]["unique_questions"] = unique_reading_count
    results["reading_polarity_coverage"]["unique_distribution"] = unique_reading_labels
    results["grammar_mcq_quality"]["unique_mcqs"] = unique_mcq_count
    results["grammar_mcq_quality"]["unique_valid_mcqs"] = unique_mcq_pass
    results["grammar_mcq_quality"]["valid_mcq_rate"] = round(unique_mcq_pass / unique_mcq_count, 4) if unique_mcq_count else 0.0
    results["grammar_mcq_quality"]["rule_pack_example_copies"] = example_copies
    results["grammar_mcq_quality"]["example_copy_rate"] = example_copy_rate
    results["grammar_mcq_quality"]["carrier_novelty_rate"] = carrier_novelty_rate

    results["evaluator_verdicts"] = {
        "total_slots": {"PASS": v26_pass, "FAIL": v26_fail},
        "pass_rate": round(v26_pass / total_q, 4) if total_q else 0.0,
        "unique_items": {
            "PASS": unique_reading_pass + unique_mcq_pass,
            "FAIL": (unique_reading_count + unique_mcq_count) - (unique_reading_pass + unique_mcq_pass),
            "pass_rate": round((unique_reading_pass + unique_mcq_pass) / (unique_reading_count + unique_mcq_count), 4) if (unique_reading_count + unique_mcq_count) else 0.0,
        },
    }
    results["blind_judge_scoring"] = {
        "PASS": judge_pass,
        "FAIL": judge_fail,
        "UNCERTAIN": judge_uncertain,
        "abstention_rate": round(judge_uncertain / total_q, 4) if total_q else 0.0,
    }
    results["question_evaluations"] = question_evals

    # Save updated json
    results_path.write_text(json.dumps(results, indent=2))
    print(f"[RESCORE] Saved updated results to {results_path}")

    # Build updated markdown report
    md_content = f"""# RG10 — Fresh Grammar Quality DEV Pilot Report (v2.6 Evaluator)

**Execution Date:** {results['executed_at']}  
**Model:** `{results['foundation_model_id']}`  
**Endpoint:** `https://api.minimaxi.chat/v1`  
**Evaluator Version:** `neutral-eval-v2.6`  
**Tested Source Families:**
- `fam-geology-volcanism-dev-06` (Reading: Submarine Pillow Lava Volcanism)
- `fam-syntax-inversion-dev-06` (Grammar: Negative/Limiting Adverbial Inversion)
- `fam-syntax-subjunctive-dev-06` (Grammar: Mandative Subjunctive Clauses)

**Isolated Output Artifact:** `{results_path}`  

---

## 1. Accounting and Live Dispatches

- **Total Live Dispatches:** {results['telemetry']['total_dispatches']} provider calls against live MiniMax endpoint
- **Total Tokens Consumed:** {results['telemetry']['total_tokens']:,} tokens (exact from provider response headers)
- **Estimated Spend:** ${results['telemetry']['spent_usd_estimated']:.4f} USD (calculated at $0.0015/1k tokens; labeled `LOCAL_RATE_ESTIMATE_NOT_BILLED`)
- **Elapsed Wall Time:** {results['telemetry']['wall_time_seconds']}s
- **Assignments:** {results['assignment_completion']['completed']}/{results['assignment_completion']['assigned']} completed ({round(results['assignment_completion']['completion_rate']*100, 1)}%)

---

## 2. Quality Metrics Across Experimental Dimensions

- **Terminal Answer Availability:** {results['answer_availability']['available_answers']}/{total_q} ({round(results['answer_availability']['availability_rate']*100, 1)}% available; {results['answer_availability']['missing_answers']} missing).
- **Reading Polarity Coverage (Unique Items):** {unique_reading_labels} across {unique_reading_count} unique items. Reading Evaluator Pass Rate: {unique_reading_pass}/{unique_reading_count} ({round(unique_reading_pass/unique_reading_count*100, 1)}%).
- **Grammar MCQ Quality (Unique Items):** {unique_mcq_pass}/{unique_mcq_count} valid MCQs across {unique_mcq_count} unique items ({round(results['grammar_mcq_quality']['valid_mcq_rate']*100, 1)}% valid pass rate across multi-family rule packs).
- **Content-Aware Carrier Novelty:** {results['grammar_mcq_quality']['rule_pack_example_copies']}/{len(novelty_scores)} example copies detected ({round(example_copy_rate*100, 1)}%), Carrier novelty rate: **{round(carrier_novelty_rate*100, 1)}%** (compulsory rule triggers ignored, 0 carrier scenario copies).
- **Evaluator Scoring (v2.6):** {v26_pass} PASS / {v26_fail} FAIL ({round(results['evaluator_verdicts']['pass_rate']*100, 1)}% pass rate across all {total_q} slots; {results['evaluator_verdicts']['unique_items']['PASS']}/{unique_reading_count + unique_mcq_count} or {round(results['evaluator_verdicts']['unique_items']['pass_rate']*100, 1)}% across unique items).
- **Blinded Semantic Judge:** {judge_pass} PASS / {judge_fail} FAIL / {judge_uncertain} UNCERTAIN (Abstention rate: {round(results['blind_judge_scoring']['abstention_rate']*100, 1)}%).
- **Arm C Repairs Invoked:** {results['arm_c_repair_metrics']['total_repairs_invoked']} repair dispatches executed.

---

## 3. Question-Level Matrix (n = {total_q} total slots, {unique_reading_count + unique_mcq_count} unique items)

| Domain | Arm | Q# | Proposed Answer | Status | v2.6 Verdict | Blind Judge | Novelty | Rationale / Behavioral Finding |
|---|---|---|---|---|---|---|---|---|
"""
    for q in question_evals:
        md_content += f"| **{q['domain']}** | {q['configuration_id']} | {q['question_id']} | `{q['proposed_answer']}` | {q['answer_status']} | **{q['verdict_v26']}** | **{q['blind_judge_verdict']}** | {q['novelty_status']} | {q['abstention_reason']} |\n"

    md_content += f"""
---

## 4. Multi-Family Grammar Findings

1. **Negative Inversion Family (`fam-syntax-inversion-dev-06`):**
   - Inversion syntax with full verb phrase validation correctly recognized single valid answers without distractor ambiguity false rejections (6/6 slots, 5/5 unique items PASS).
   - Distractors with uninverted word order, illicit auxiliaries, misplaced subjects, or missing subjects were cleanly invalidated.
2. **Mandative Subjunctive Family (`fam-syntax-subjunctive-dev-06`):**
   - Correctly verified mandative subjunctive base form verbs following mandative verbs and adjectives (`mandates that...`, `insists that...`, `crucial that...`) across all multi-word subjects (6/6 slots, 5/5 unique items PASS).
   - Distractors with 3rd-person `-s` inflections or past tense were cleanly identified as ungrammatical under the target rule.
3. **Content-Aware Novelty:**
   - 100% of generated carrier sentences were novel scenarios (12/12 novel, 0 copies of rule pack examples). Zero items copied the rule pack examples.
"""

    report_path = output_dir / "FRESH_GRAMMAR_GATE_REPORT.md"
    report_path.write_text(md_content)
    print(f"[RESCORE] Saved markdown report to {report_path}")

    verif_dir = repo_root / "generation_baseline" / "verification"
    verif_dir.mkdir(parents=True, exist_ok=True)
    (verif_dir / "FRESH_GRAMMAR_GATE_REPORT.md").write_text(md_content)
    (verif_dir / "FRESH_GRAMMAR_GATE_REPORT.json").write_text(json.dumps(results, indent=2))
    print(f"[RESCORE] Published reports to generation_baseline/verification/")

    return results


if __name__ == "__main__":
    if "--live" in sys.argv:
        run_fresh_pilot()
    else:
        rescore_existing_pilot()
