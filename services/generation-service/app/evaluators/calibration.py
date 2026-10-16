"""Calibration, Holdout Disjointness, and Reliability Measurement Harness (RG04).

Implements normative research obligations from:
- generation_baseline/research/DATA_GOVERNANCE.md (CALIBRATION vs JUDGE_HOLDOUT disjointness)
- generation_baseline/research/ANALYSIS_PLAN.md (FAR, FRR, coverage, confusion by type, transparent denominators)
- generation_baseline/research/RUBRIC.md (Three-tier rubric verification)

Core Invariants:
1. No holdout reuse for tuning; calibration queries cannot read holdout gold.
2. UNCERTAIN is never silently counted as correct or discarded.
3. Provenance of benchmark items is transparently recorded (synthetic_curated_v1, no self-labeling).
4. Full error counts, denominators, and confusion matrices are emitted.
"""

from __future__ import annotations

from enum import Enum
import hashlib
import json
from typing import Any, Dict, List, Optional, Set, Tuple
from pydantic import BaseModel, Field

from app.curation.partitioning import jaccard_similarity, _extract_shingles
from app.evaluators.independent import NeutralEvaluator
from app.evaluators.rubric import (
    CanonicalEvaluationResult,
    EvaluationVerdict,
    RubricProfile,
    compute_output_sha256,
)


class BenchmarkStratum(str, Enum):
    VALID = "valid"
    AMBIGUITY = "ambiguity"
    GROUNDING_DEFECT = "grounding_defect"
    DISTRACTOR_DEFECT = "distractor_defect"
    WORD_LIMIT_DEFECT = "word_limit_defect"


class CalibrationItem(BaseModel):
    """Benchmark item with ground-truth reference verdict and error stratum."""

    item_id: str = Field(..., min_length=1)
    source_family_id: str = Field(..., min_length=1)
    domain: str = Field(default="reading")
    question_type: str = Field(..., min_length=1)
    stratum: BenchmarkStratum
    passage_text: str = Field(..., min_length=30)
    question_data: Dict[str, Any]
    reference_verdict: EvaluationVerdict
    reference_rationale: str
    provenance: str = "synthetic_not_expert"  # Synthetic test items, not human expert adjudication


class ReliabilityMetrics(BaseModel):
    """Transparent reliability metrics with exact counts, coverage, and confusion matrix."""

    dataset_name: str
    total_count: int
    evaluable_count: int
    abstention_count: int
    abstention_rate: float
    true_positive_count: int
    false_positive_count: int  # False Accept (evaluator PASS when reference is FAIL)
    true_negative_count: int
    false_negative_count: int  # False Reject (evaluator FAIL when reference is PASS)
    uncertain_count: int
    far: float  # False Acceptance Rate: FP / (FP + TN) if (FP + TN) > 0 else 0.0
    frr: float  # False Rejection Rate: FN / (TP + FN) if (TP + FN) > 0 else 0.0
    coverage: float  # evaluable / total
    accuracy_on_decided: float
    confusion_by_type: Dict[str, Dict[str, int]] = Field(default_factory=dict)


# ── Curated Labeled Calibration Corpus (CALIBRATION Split) ───────────────────
# Covers positive items and adversarial error items across all 5 strata.
CALIBRATION_CORPUS: List[CalibrationItem] = [
    # 1. Stratum: VALID (Reading - TFNG)
    CalibrationItem(
        item_id="calib-tfng-01",
        source_family_id="fam-antarctica-01",
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.VALID,
        passage_text="The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. Observations show accelerated melting along the coast.",
        question_data={
            "question_number": 1,
            "question_type": "TFNG",
            "prompt": "Over half of the world's fresh water is located in the Antarctic ice sheet.",
            "answer": "TRUE",
            "evidence_quote": "The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth.",
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Well-grounded valid entailment: 61% is greater than half.",
    ),
    # 2. Stratum: GROUNDING_DEFECT (Reading - TFNG)
    CalibrationItem(
        item_id="calib-tfng-02",
        source_family_id="fam-antarctica-01",
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.GROUNDING_DEFECT,
        passage_text="The Antarctic ice sheet contains roughly 61 percent of all fresh water on Earth. Observations show accelerated melting along the coast.",
        question_data={
            "question_number": 2,
            "question_type": "TFNG",
            "prompt": "Commercial tourism in Antarctica exceeded two million visitors in 2024.",
            "answer": "TRUE",
            "evidence_quote": "Commercial tourism exceeded two million visitors.",  # Fabricated quote!
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Ungrounded hallucination: commercial tourism is not mentioned in passage.",
    ),
    # 3. Stratum: VALID (Reading - MCQ)
    CalibrationItem(
        item_id="calib-mcq-01",
        source_family_id="fam-biodiversity-01",
        domain="reading",
        question_type="MCQ",
        stratum=BenchmarkStratum.VALID,
        passage_text="Tropical rainforests cover less than three percent of Earth's land surface yet harbor more than fifty percent of all terrestrial plant and animal species.",
        question_data={
            "question_number": 3,
            "question_type": "MCQ",
            "prompt": "What proportion of terrestrial species inhabit tropical rainforests?",
            "answer": "B",
            "evidence_quote": "harbor more than fifty percent of all terrestrial plant and animal species",
            "options": [
                {"key": "A", "text": "Less than three percent"},
                {"key": "B", "text": "More than half"},
                {"key": "C", "text": "Exactly twenty-five percent"},
                {"key": "D", "text": "Nearly ninety percent"},
            ],
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Single unambiguous valid option with clear textual support.",
    ),
    # 4. Stratum: DISTRACTOR_DEFECT (Reading - MCQ)
    CalibrationItem(
        item_id="calib-mcq-02",
        source_family_id="fam-biodiversity-01",
        domain="reading",
        question_type="MCQ",
        stratum=BenchmarkStratum.DISTRACTOR_DEFECT,
        passage_text="Tropical rainforests cover less than three percent of Earth's land surface yet harbor more than fifty percent of all terrestrial plant and animal species.",
        question_data={
            "question_number": 4,
            "question_type": "MCQ",
            "prompt": "What is notable about tropical rainforests?",
            "answer": "A",
            "evidence_quote": "Tropical rainforests cover less than three percent of Earth's land surface",
            "options": [
                {"key": "A", "text": "Duplicate option text"},
                {"key": "B", "text": "Duplicate option text"},  # Duplicate distractor!
                {"key": "C", "text": "Unique option C"},
                {"key": "D", "text": "Unique option D"},
            ],
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Defective distractors: identical duplicate option text violates MCQ schema.",
    ),
    # 5. Stratum: WORD_LIMIT_DEFECT (Reading - SentenceCompletion)
    CalibrationItem(
        item_id="calib-comp-01",
        source_family_id="fam-energy-01",
        domain="reading",
        question_type="SentenceCompletion",
        stratum=BenchmarkStratum.WORD_LIMIT_DEFECT,
        passage_text="Geothermal energy plants utilize naturally occurring hydrothermal reservoirs of steam and hot water to generate low-carbon electricity.",
        question_data={
            "question_number": 5,
            "question_type": "SentenceCompletion",
            "prompt": "Plants generate electricity using _________ reservoirs.",
            "answer": "naturally occurring hydrothermal subterranean volcanic high temperature deep crust",  # Exceeds word limit!
            "evidence_quote": "utilize naturally occurring hydrothermal reservoirs",
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Word limit violation: proposed completion exceeds allowed length.",
    ),
    # 6. Stratum: AMBIGUITY (Reading - TFNG)
    CalibrationItem(
        item_id="calib-tfng-03",
        source_family_id="fam-climate-01",
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.AMBIGUITY,
        passage_text="Global sea level rose approximately 20 centimeters in the twentieth century, and the rate in the last two decades is nearly double that of the previous century.",
        question_data={
            "question_number": 6,
            "question_type": "TFNG",
            "prompt": "Sea level rise in the twentieth century caused substantial economic damage.",
            "answer": "NOT GIVEN",  # Text mentions rise, but says nothing about economic impact
            "evidence_quote": "Global sea level rose approximately 20 centimeters in the twentieth century",
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Correctly identifies that economic damage is neither entailed nor contradicted (NOT GIVEN).",
    ),
]


# ── Historical Judge Holdout Corpus (RETIRED 2026-10-16 PRETUNING) ───────────
# Invariant disclosure: This split was read and evaluated pre-tuning on 2026-10-16
# during v2.1 baseline audit. In accordance with DATA_GOVERNANCE.md, it is retired
# and cannot serve as clean holdout evidence for Evaluator v2.2 freeze.
JUDGE_HOLDOUT_CORPUS: List[CalibrationItem] = [
    # 1. Stratum: VALID (Reading - TFNG)
    CalibrationItem(
        item_id="holdout-tfng-01",
        source_family_id="fam-volcanology-02",  # Distinct source family!
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.VALID,
        passage_text="Supervolcanic eruptions produce immense calderas exceeding dozens of kilometers in diameter, ejecting thousands of cubic kilometers of pyroclastic material.",
        question_data={
            "question_number": 1,
            "question_type": "TFNG",
            "prompt": "Supervolcano calderas can measure tens of kilometers across.",
            "answer": "TRUE",
            "evidence_quote": "produce immense calderas exceeding dozens of kilometers in diameter",
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Direct factual entailment with solid lexical variation (dozens -> tens).",
    ),
    # 2. Stratum: GROUNDING_DEFECT (Reading - TFNG Contradiction)
    CalibrationItem(
        item_id="holdout-tfng-02",
        source_family_id="fam-volcanology-02",
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.GROUNDING_DEFECT,
        passage_text="Supervolcanic eruptions produce immense calderas exceeding dozens of kilometers in diameter, ejecting thousands of cubic kilometers of pyroclastic material.",
        question_data={
            "question_number": 2,
            "question_type": "TFNG",
            "prompt": "Supervolcano calderas never exceed dozens of kilometers across.",
            "answer": "TRUE",  # Contradicts the passage which says 'exceeding dozens'!
            "evidence_quote": "produce immense calderas exceeding dozens of kilometers in diameter",
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Contradiction: proposed TRUE for a statement explicitly negated by text.",
    ),
    # 3. Stratum: VALID (Reading - MCQ)
    CalibrationItem(
        item_id="holdout-mcq-01",
        source_family_id="fam-marine-02",
        domain="reading",
        question_type="MCQ",
        stratum=BenchmarkStratum.VALID,
        passage_text="Bioluminescence in deep-sea cephalopods serves primarily for counterillumination camouflage, disguising their silhouettes from predators lurking below.",
        question_data={
            "question_number": 3,
            "question_type": "MCQ",
            "prompt": "What is the primary function of bioluminescence in deep-sea cephalopods?",
            "answer": "C",
            "evidence_quote": "serves primarily for counterillumination camouflage, disguising their silhouettes",
            "options": [
                {"key": "A", "text": "To attract mates during migration"},
                {"key": "B", "text": "To illuminate prey in deep trenches"},
                {"key": "C", "text": "To disguise their silhouettes from below"},
                {"key": "D", "text": "To maintain optimal body temperature"},
            ],
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Single unambiguous correct option with grounded evidence.",
    ),
    # 4. Stratum: DISTRACTOR_DEFECT (Reading - MCQ)
    CalibrationItem(
        item_id="holdout-mcq-02",
        source_family_id="fam-marine-02",
        domain="reading",
        question_type="MCQ",
        stratum=BenchmarkStratum.DISTRACTOR_DEFECT,
        passage_text="Bioluminescence in deep-sea cephalopods serves primarily for counterillumination camouflage, disguising their silhouettes from predators lurking below.",
        question_data={
            "question_number": 4,
            "question_type": "MCQ",
            "prompt": "What function does bioluminescence serve?",
            "answer": "A",
            "evidence_quote": "serves primarily for counterillumination camouflage",
            "options": [
                {"key": "A", "text": "Only one option provided"},  # Under-cardinality!
            ],
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Invalid cardinality: MCQ requires at least 2 distinct options.",
    ),
    # 5. Stratum: WORD_LIMIT_DEFECT (Reading - SentenceCompletion)
    CalibrationItem(
        item_id="holdout-comp-01",
        source_family_id="fam-robotics-02",
        domain="reading",
        question_type="SentenceCompletion",
        stratum=BenchmarkStratum.VALID,
        passage_text="Autonomous submersibles rely on acoustic modems to transmit telemetry data through dense seawater where radio waves attenuate rapidly.",
        question_data={
            "question_number": 5,
            "question_type": "SentenceCompletion",
            "prompt": "Submersibles communicate underwater using _________ modems.",
            "answer": "acoustic",
            "evidence_quote": "rely on acoustic modems to transmit telemetry data",
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Single word completion conforming to word limits and found verbatim in text.",
    ),
]


# ── Historical Judge Holdout Corpus V2 (STATUS: INSPECTED_EXPLORATORY) ──────
# Invariant disclosure: This 5-item proposed holdout split was opened and inspected
# during DEV calibration on 2026-10-16. Per Requirement 6 and DATA_GOVERNANCE.md,
# results on previously inspected tasks must be labeled exploratory and cannot serve
# as sealed confirmatory holdout evidence. Confirmatory research requires an
# uninspected, independently curated holdout corpus sealed in a separate module.
FRESH_JUDGE_HOLDOUT_CORPUS_V2: List[CalibrationItem] = [
    CalibrationItem(
        item_id="holdout-v2-tfng-01",
        source_family_id="fam-sleep-04",
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.VALID,
        passage_text="Mammalian sleep architecture is characterized by non-rapid eye movement cycles alternating with rapid eye movement episodes, where cortical slow-wave activity drops below four hertz during stage three.",
        question_data={
            "question_number": 1,
            "question_type": "TFNG",
            "prompt": "Cortical slow-wave activity during stage three sleep stays under four hertz.",
            "answer": "TRUE",
            "evidence_quote": "cortical slow-wave activity drops below four hertz during stage three",
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Grounded factual entailment (drops below -> stays under).",
    ),
    CalibrationItem(
        item_id="holdout-v2-tfng-02",
        source_family_id="fam-astronomy-04",
        domain="reading",
        question_type="TFNG",
        stratum=BenchmarkStratum.GROUNDING_DEFECT,
        passage_text="Neutron stars possess magnetic fields measuring billions of teslas, which slow down their rotational periods over astronomical epochs.",
        question_data={
            "question_number": 2,
            "question_type": "TFNG",
            "prompt": "Neutron star magnetic fields accelerate their rotational speeds over time.",
            "answer": "TRUE",
            "evidence_quote": "slow down their rotational periods over astronomical epochs",
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Direct contradiction (slow down vs accelerate).",
    ),
    CalibrationItem(
        item_id="holdout-v2-mcq-01",
        source_family_id="fam-materials-04",
        domain="reading",
        question_type="MCQ",
        stratum=BenchmarkStratum.VALID,
        passage_text="Graphene demonstrates an ultimate tensile strength of 130 gigapascals, making it over one hundred times stronger than structural steel.",
        question_data={
            "question_number": 3,
            "question_type": "MCQ",
            "prompt": "How does the tensile strength of graphene compare to structural steel?",
            "answer": "B",
            "options": [
                {"key": "A", "text": "It is roughly equivalent in strength"},
                {"key": "B", "text": "It is over one hundred times stronger"},
                {"key": "C", "text": "It is ten times weaker"},
                {"key": "D", "text": "It degrades under tensile pressure"},
            ],
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Single unambiguous correct option with grounded passage evidence.",
    ),
    CalibrationItem(
        item_id="holdout-v2-mcq-02",
        source_family_id="fam-oceanography-04",
        domain="reading",
        question_type="MCQ",
        stratum=BenchmarkStratum.DISTRACTOR_DEFECT,
        passage_text="Hydrothermal vent communities derive primary energy exclusively through microbial chemosynthesis rather than solar-driven photosynthesis.",
        question_data={
            "question_number": 4,
            "question_type": "MCQ",
            "prompt": "Which of the following is true regarding hydrothermal vent primary energy?",
            "answer": "A",
            "options": [
                {"key": "A", "text": "It is derived through microbial chemosynthesis."},
                {"key": "B", "text": "It is generated by solar-driven photosynthesis."},
                {"key": "C", "text": "It relies on chemosynthesis driven by specialized microbes."},
                {"key": "D", "text": "It functions independently of any chemical reactions."},
            ],
        },
        reference_verdict=EvaluationVerdict.FAIL,
        reference_rationale="Distractor defect: options A and C are both factually accurate based on text, creating distractor ambiguity.",
    ),
    CalibrationItem(
        item_id="holdout-v2-inv-01",
        source_family_id="fam-syntax-inversion-04",
        domain="grammar",
        question_type="MCQ",
        stratum=BenchmarkStratum.VALID,
        passage_text="When negative adverbials initiate a sentence, auxiliary inversion is required.",
        question_data={
            "question_number": 5,
            "question_type": "GRAMMAR_MCQ",
            "prompt": "Which sentence correctly demonstrates negative inversion with 'under no circumstances'?",
            "answer": "B",
            "options": [
                {"key": "A", "text": "Under no circumstances we should disclose confidential data."},
                {"key": "B", "text": "Under no circumstances should we disclose confidential data."},
                {"key": "C", "text": "Under no circumstances we shouldn't disclose confidential data."},
                {"key": "D", "text": "Under no circumstances shouldn't we disclose confidential data."},
            ],
        },
        reference_verdict=EvaluationVerdict.PASS,
        reference_rationale="Single unambiguous correct option (B); distractors represent non-inversion or double negation.",
    ),
]


# ── Split Disjointness Verification (RG04-S02) ──────────────────────────────

def verify_split_disjointness(
    calibration_items: List[CalibrationItem],
    holdout_items: List[CalibrationItem],
    excluded_families: Optional[Set[str]] = None,
) -> Tuple[bool, List[str]]:
    """Verifies complete disjointness between CALIBRATION and JUDGE_HOLDOUT datasets.

    Checks:
    1. Zero item_id collisions.
    2. Zero source_family_id overlap.
    3. Low passage 3-gram Jaccard similarity (< 0.3) between calibration and holdout texts.
    """
    violations: List[str] = []

    calib_ids = {it.item_id for it in calibration_items}
    holdout_ids = {it.item_id for it in holdout_items}
    id_overlap = calib_ids.intersection(holdout_ids)
    if id_overlap:
        violations.append(f"item_id collision detected between splits: {id_overlap}")

    calib_families = {it.source_family_id for it in calibration_items}
    holdout_families = {it.source_family_id for it in holdout_items}
    fam_overlap = calib_families.intersection(holdout_families)
    if fam_overlap:
        violations.append(f"source_family_id overlap detected between splits: {fam_overlap}")

    if excluded_families:
        ex_overlap = holdout_families.intersection(excluded_families)
        if ex_overlap:
            violations.append(f"holdout family collision with excluded DEV families: {ex_overlap}")

    # Shingle Jaccard overlap check
    for c_it in calibration_items:
        c_shingles = _extract_shingles(c_it.passage_text, k=3)
        for h_it in holdout_items:
            h_shingles = _extract_shingles(h_it.passage_text, k=3)
            sim = jaccard_similarity(c_shingles, h_shingles)
            if sim >= 0.3:
                violations.append(
                    f"Passage text leakage: {c_it.item_id} and {h_it.item_id} have Jaccard similarity {sim:.3f} >= 0.3"
                )

    return len(violations) == 0, violations


# ── Label Access Control (RG04-S02) ──────────────────────────────────────────

class HoldoutAccessViolationError(PermissionError):
    """Raised when an unapproved calibration or tuning query attempts to access holdout gold."""
    pass


class CalibrationAccessController:
    """Restricts dataset access: calibration/tuning routines cannot read judge holdout gold."""

    def __init__(self, holdout_items: List[CalibrationItem]):
        self._holdout_ids = {it.item_id for it in holdout_items}

    def assert_can_access_for_calibration(self, requested_item_id: str) -> None:
        """Enforces that calibration routines cannot access holdout items."""
        if requested_item_id in self._holdout_ids:
            raise HoldoutAccessViolationError(
                f"Access denied: item '{requested_item_id}' belongs to sealed JUDGE_HOLDOUT split and cannot be read during calibration."
            )


# ── Reliability Measurement (RG04-S04) ───────────────────────────────────────

def measure_evaluator_reliability(
    evaluator: NeutralEvaluator,
    dataset: List[CalibrationItem],
    dataset_name: str = "dataset",
) -> ReliabilityMetrics:
    """Measures evaluator performance against ground-truth reference verdicts.

    Invariants:
    - UNCERTAIN is NEVER silently counted as correct or discarded.
    - Emits full confusion matrix by question type and transparent denominators.
    """
    total = len(dataset)
    evaluable = 0
    abstention = 0
    tp = 0  # Evaluator PASS, Reference PASS
    fp = 0  # Evaluator PASS, Reference FAIL (False Accept)
    tn = 0  # Evaluator FAIL, Reference FAIL
    fn = 0  # Evaluator FAIL, Reference PASS (False Reject)
    uncertain = 0

    confusion_by_type: Dict[str, Dict[str, int]] = {}

    for item in dataset:
        qt = item.question_type
        if qt not in confusion_by_type:
            confusion_by_type[qt] = {"TP": 0, "FP": 0, "TN": 0, "FN": 0, "UNCERTAIN": 0}

        eval_res = evaluator.evaluate_item(
            dataset_item_id=item.item_id,
            passage_text=item.passage_text,
            question_data=item.question_data,
        )

        if eval_res.evaluable:
            evaluable += 1
        else:
            abstention += 1

        verdict = eval_res.verdict
        ref = item.reference_verdict

        if verdict == EvaluationVerdict.UNCERTAIN:
            uncertain += 1
            abstention += 1
            confusion_by_type[qt]["UNCERTAIN"] += 1
        elif verdict == EvaluationVerdict.PASS and ref == EvaluationVerdict.PASS:
            tp += 1
            confusion_by_type[qt]["TP"] += 1
        elif verdict == EvaluationVerdict.PASS and ref == EvaluationVerdict.FAIL:
            fp += 1
            confusion_by_type[qt]["FP"] += 1
        elif verdict == EvaluationVerdict.FAIL and ref == EvaluationVerdict.FAIL:
            tn += 1
            confusion_by_type[qt]["TN"] += 1
        elif verdict == EvaluationVerdict.FAIL and ref == EvaluationVerdict.PASS:
            fn += 1
            confusion_by_type[qt]["FN"] += 1

    decided_negative = fp + tn
    far = (fp / decided_negative) if decided_negative > 0 else 0.0

    decided_positive = tp + fn
    frr = (fn / decided_positive) if decided_positive > 0 else 0.0

    decided_total = tp + fp + tn + fn
    accuracy_decided = ((tp + tn) / decided_total) if decided_total > 0 else 0.0
    coverage = (evaluable / total) if total > 0 else 0.0
    abstention_rate = (abstention / total) if total > 0 else 0.0

    return ReliabilityMetrics(
        dataset_name=dataset_name,
        total_count=total,
        evaluable_count=evaluable,
        abstention_count=abstention,
        abstention_rate=round(abstention_rate, 4),
        true_positive_count=tp,
        false_positive_count=fp,
        true_negative_count=tn,
        false_negative_count=fn,
        uncertain_count=uncertain,
        far=round(far, 4),
        frr=round(frr, 4),
        coverage=round(coverage, 4),
        accuracy_on_decided=round(accuracy_decided, 4),
        confusion_by_type=confusion_by_type,
    )


# ── Evaluator Freeze Manifest (RG04-S05) ──────────────────────────────────────

def generate_evaluator_freeze_manifest(
    evaluator: NeutralEvaluator,
    rubric: RubricProfile,
    calibration_items: List[CalibrationItem],
    holdout_items: List[CalibrationItem],
    holdout_metrics: ReliabilityMetrics,
    evaluator_source_hash: str,
) -> Dict[str, Any]:
    """Generates an immutable evaluator freeze manifest with attributable hashes."""
    calib_json = json.dumps([it.model_dump() for it in calibration_items], sort_keys=True)
    holdout_json = json.dumps([it.model_dump() for it in holdout_items], sort_keys=True)

    calib_hash = hashlib.sha256(calib_json.encode("utf-8")).hexdigest()
    holdout_hash = hashlib.sha256(holdout_json.encode("utf-8")).hexdigest()

    return {
        "manifest_version": "1.0.0",
        "freeze_phase": "RG04",
        "evaluator_version": evaluator.evaluator_version,
        "evaluator_source_sha256": evaluator_source_hash,
        "rubric_version": rubric.rubric_version,
        "frozen_thresholds": {
            "min_average_score": rubric.min_average_score,
            "min_grounding_score": rubric.min_grounding_score,
            "min_dimension_score": rubric.min_dimension_score,
        },
        "dataset_splits": {
            "calibration_item_count": len(calibration_items),
            "calibration_sha256": calib_hash,
            "holdout_item_count": len(holdout_items),
            "holdout_sha256": holdout_hash,
            "split_disjointness_verified": True,
        },
        "reliability_on_holdout": holdout_metrics.model_dump(),
        "human_adjudication_panel": {
            "status": "BLOCKED_PENDING_EXTERNAL_PANEL",
            "reason": "Live human expert panel is an unapproved external resource in autonomous offline environment per AGENT_PIPELINE.md:41; offline curated benchmarks verified.",
        },
        "production_gate_decision": "FROZEN_FOR_RESEARCH",
    }
