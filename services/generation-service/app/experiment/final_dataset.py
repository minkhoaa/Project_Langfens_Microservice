"""Frozen paired FINAL dataset and task management (RG09-S01).

Implements normative research obligations from:
- generation_baseline/research/DATA_GOVERNANCE.md (Disjoint use-categories, source-family isolation)
- generation_baseline/research/FINAL_BATCH_RULES.md (Frozen 25-40 items per domain, max 5 items per batch)
- generation_baseline/contracts/JSON_SCHEMAS.json ($defs/ReadingTask, $defs/GrammarTask, $defs/PairedTaskFixture)

Invariants:
1. 25-40 Reading and 25-40 Grammar paired input items with balanced difficulty/type strata.
2. Family-disjoint: FINAL sources strictly exclude DEV, CALIBRATION, HOLDOUT, G15 campaign, and quarantined sources.
3. Full A/B/C assignment grid: 1 item -> exactly 3 paired assignments with stable IDs.
4. Genuine provenance: Real SHA256, verified open-access CC-BY-4.0 licenses and curated grammar rules.
5. Fails closed: Leaked DEV/CALIBRATION/G15 sources raise SourceFamilyOverlapError.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any, Dict, List, Literal, Optional, Set, Tuple

from pydantic import Field

from app.contracts.base import CanonicalBaseModel
from app.contracts.research import (
    ExperimentAssignment,
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    PairedTaskFixture,
    PromptVersionMap,
    ReadingTask,
    SourceRef,
    StandaloneGroupType,
)
from app.experiment.paired import DuplicateAssignmentError, PairedAssignmentManager


class SourceFamilyOverlapError(RuntimeError):
    """Raised when FINAL dataset overlaps with DEV, CALIBRATION, HOLDOUT, or G15 campaign sources."""


class DatasetStrataDefectError(ValueError):
    """Raised when frozen dataset lacks required balance across difficulty or question types."""


# Strictly excluded source families across DEV, CALIBRATION, HOLDOUT, G15, and quarantined sets
FORBIDDEN_DEV_CALIBRATION_FAMILIES: Set[str] = {
    # DEV passages
    "coral_reefs",
    "antarctic_ice",
    "renewable_energy",
    "urban_agri",
    # CALIBRATION corpus
    "fam-marine-01",
    "fam-energy-01",
    "fam-agri-01",
    # JUDGE_HOLDOUT corpus
    "fam-geology-01",
    "fam-marine-02",
    "fam-quantum-01",
    "fam-neuro-01",
    "fam-climate-01",
    # Canonical G15 campaign sources (seed 202 in test_phase15_v2rate_b_cas_integrity.py)
    "PMC13503497",
    "fam-pmc-13503497",
    "PMC13583341",
    "fam-pmc-13583341",
    "PMC13560651",
    "fam-pmc-13560651",
    # Consumed by RG07
    "PMC12804876",
    "fam-pmc-12804876",
    # Quarantined sources
    "PMC13001950",
    "PMC13391382",
    "PMC13550489",
    "PMC13572963",
    # Prior phase test sources
    "national_geographic",
    "cambridge_advanced",
    "oxford_academic",
    "academic_grammar_corpus",
    "marine_biology",
    "neuroscience",
}


# 7 Verified Clean Open-Access Sources (4 PMC text files + 3 eligible policy articles)
VERIFIED_CLEAN_READING_SOURCES = [
    {
        "source_type": "file",
        "filename": "PMC13621526.txt",
        "family": "fam-clean-pmc-13621526",
        "topic": "Controlled-Environment Plant Biology and LED Photoperiods",
        "license": "CC-BY-4.0",
        "uri": "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC13621526/",
    },
    {
        "source_type": "file",
        "filename": "PMC13604763.txt",
        "family": "fam-clean-pmc-13604763",
        "topic": "Biomimetic Hydrophobic Surfaces and Interfacial Free Energy",
        "license": "CC-BY-4.0",
        "uri": "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC13604763/",
    },
    {
        "source_type": "file",
        "filename": "PMC13517498.txt",
        "family": "fam-clean-pmc-13517498",
        "topic": "Distributed Sensor Networks and Transformer District Monitoring",
        "license": "CC-BY-4.0",
        "uri": "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC13517498/",
    },
    {
        "source_type": "file",
        "filename": "PMC13407692.txt",
        "family": "fam-clean-pmc-13407692",
        "topic": "Quantum Purification Fidelity under Symmetric Subspace Projections",
        "license": "CC-BY-4.0",
        "uri": "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC13407692/",
    },
    {
        "source_type": "eligible_policy",
        "pmcid": "PMC8910002",
        "family": "fam-clean-pmc-8910002",
        "topic": "Early Hydraulic Engineering in Mesopotamian Irrigation Networks",
        "license": "CC-BY-4.0",
        "uri": "https://europepmc.org/articles/PMC8910002",
    },
    {
        "source_type": "eligible_policy",
        "pmcid": "PMC8910003",
        "family": "fam-clean-pmc-8910003",
        "topic": "Hydrometallurgical Pathways for Lithium-Ion Battery Recycling",
        "license": "CC-BY-4.0",
        "uri": "https://europepmc.org/articles/PMC8910003",
    },
    {
        "source_type": "eligible_policy",
        "pmcid": "PMC8910005",
        "family": "fam-clean-pmc-8910005",
        "topic": "Cross-Linguistic Perspectives on Spatial Metaphors for Temporal Sequencing",
        "license": "CC-BY-4.0",
        "uri": "https://europepmc.org/articles/PMC8910005",
    },
]


# 7 Curated Grammar Rule Families for Grammar Tasks
GRAMMAR_FAMILIES_METADATA = [
    {
        "family": "fam-grammar-inversion-final",
        "topic": "Negative and Limiting Adverbial Inversion",
        "level": "C1",
        "rules": ["inv-neg-01", "inv-limit-02"],
        "examples": [
            "Seldom have researchers observed such pronounced discrepancies in field trials.",
            "Under no circumstances should raw experimental samples be discarded without logging.",
        ],
    },
    {
        "family": "fam-grammar-conditionals-final",
        "topic": "Mixed and Inverted Conditional Structures",
        "level": "B2",
        "rules": ["cond-mix-01", "cond-inv-02"],
        "examples": [
            "Had the calibration protocol been verified, the sensor drift would have been detected.",
            "Were the temperature to exceed sixty degrees, the enzyme would denature rapidly.",
        ],
    },
    {
        "family": "fam-grammar-clefts-final",
        "topic": "Cleft Sentences for Focus and Emphasis",
        "level": "C1",
        "rules": ["cleft-it-01", "cleft-wh-02"],
        "examples": [
            "It was the sudden pressure variance that triggered the safety shutdown.",
            "What the team discovered was a previously unknown metabolic pathway.",
        ],
    },
    {
        "family": "fam-grammar-subjunctive-final",
        "topic": "Mandative and Formulaic Subjunctive Clauses",
        "level": "B2",
        "rules": ["subj-mand-01", "subj-form-02"],
        "examples": [
            "The safety guidelines mandate that every researcher wear protective gear.",
            "Be that as it may, the empirical findings warrant further investigation.",
        ],
    },
    {
        "family": "fam-grammar-participles-final",
        "topic": "Reduced Relative and Adverbial Participle Clauses",
        "level": "B1",
        "rules": ["part-adv-01", "part-rel-02"],
        "examples": [
            "Having completed the initial run, the team compiled the diagnostic telemetry.",
            "Specimens collected during the cruise were preserved in cryogenic storage.",
        ],
    },
    {
        "family": "fam-grammar-modals-final",
        "topic": "Past Speculation and Deduction with Modal Auxiliaries",
        "level": "B2",
        "rules": ["mod-spec-01", "mod-ded-02"],
        "examples": [
            "The anomalous sensor readout must have resulted from localized power fluctuations.",
            "The deep benthic core could not have formed under aerated shallow water conditions.",
        ],
    },
    {
        "family": "fam-grammar-passives-final",
        "topic": "Impersonal and Reporting Passive Constructions",
        "level": "B1",
        "rules": ["pass-imp-01", "pass-rep-02"],
        "examples": [
            "It is widely believed that deep ocean trenches harbor unique extremophiles.",
            "The volcanic event is considered to have initiated regional climatic shifts.",
        ],
    },
]


class FinalDatasetRegistry:
    """Manages frozen, family-disjoint paired tasks for the final RQ2 benchmark."""

    def __init__(
        self,
        corpus_sources_dir: Optional[Path] = None,
        policies_dir: Optional[Path] = None,
    ) -> None:
        base_dir = Path(__file__).resolve().parent.parent.parent

        self._sources_dir = corpus_sources_dir or (
            base_dir / "services" / "generation-service" / "tests" / "fixtures" / "corpus" / "sources"
        )
        if not self._sources_dir.exists():
            alt = Path("tests/fixtures/corpus/sources")
            if alt.exists():
                self._sources_dir = alt.resolve()

        self._policies_dir = policies_dir or (
            base_dir / "services" / "generation-service" / "tests" / "fixtures" / "policies"
        )
        if not self._policies_dir.exists():
            alt_pol = Path("tests/fixtures/policies")
            if alt_pol.exists():
                self._policies_dir = alt_pol.resolve()

        self._reading_tasks: List[PairedTaskFixture] = []
        self._grammar_tasks: List[PairedTaskFixture] = []
        self._assignment_manager = PairedAssignmentManager()
        self._assignments: List[ExperimentAssignment] = []
        self._is_frozen: bool = False

    @property
    def is_frozen(self) -> bool:
        return self._is_frozen

    @property
    def reading_tasks(self) -> List[PairedTaskFixture]:
        return list(self._reading_tasks)

    @property
    def grammar_tasks(self) -> List[PairedTaskFixture]:
        return list(self._grammar_tasks)

    @property
    def assignments(self) -> List[ExperimentAssignment]:
        return list(self._assignments)

    def _load_eligible_policy_articles(self) -> Dict[str, Dict[str, Any]]:
        """Loads eligible article records from policies/sources_eligible.json."""
        eligible_path = self._policies_dir / "sources_eligible.json"
        if not eligible_path.exists():
            raise FileNotFoundError(f"Missing eligible sources file: {eligible_path}")
        data = json.loads(eligible_path.read_text(encoding="utf-8"))
        return {item["pmcid"]: item for item in data}

    def build_reading_final_tasks(self) -> List[PairedTaskFixture]:
        """Constructs 28 family-disjoint Reading tasks across 7 verified clean sources."""
        tasks: List[PairedTaskFixture] = []
        eligible_articles = self._load_eligible_policy_articles()

        difficulty_cycle = ["B1", "B2", "C1"]
        type_cycle = [
            StandaloneGroupType.TFNG,
            StandaloneGroupType.MCQ_SINGLE,
            StandaloneGroupType.SENTENCE_COMPLETION,
            StandaloneGroupType.SUMMARY_COMPLETION,
            StandaloneGroupType.YNNG,
            StandaloneGroupType.SHORT_ANSWER,
        ]

        item_idx = 1
        for meta in VERIFIED_CLEAN_READING_SOURCES:
            family = meta["family"]
            source_type = meta["source_type"]

            if source_type == "file":
                txt_path = self._sources_dir / meta["filename"]
                if not txt_path.exists():
                    raise FileNotFoundError(f"Missing corpus source text: {txt_path}")
                full_text = txt_path.read_text(encoding="utf-8").strip()
                source_identifier = meta["filename"].replace(".txt", "").lower()
            else:
                pmcid = meta["pmcid"]
                if pmcid not in eligible_articles:
                    raise KeyError(f"PMCID {pmcid} not found in sources_eligible.json")
                art = eligible_articles[pmcid]
                # Combine title and content for substantive text
                full_text = f"{art['title']}\n\n{art['content']}"
                source_identifier = pmcid.lower()

            if len(full_text) < 1200:
                raise ValueError(f"Source text for {source_identifier} is too short ({len(full_text)} chars)")

            # Segment into 4 distinct non-overlapping sections
            segment_length = len(full_text) // 4
            for sec_idx in range(4):
                start = sec_idx * segment_length
                end = (sec_idx + 1) * segment_length if sec_idx < 3 else len(full_text)
                passage_text = full_text[start:end].strip()

                passage_sha = hashlib.sha256(passage_text.encode("utf-8")).hexdigest()

                source_ref = SourceRef(
                    source_id=f"src-{source_identifier}-sec{sec_idx + 1:02d}",
                    source_family=family,
                    source_version="PMC-v1.0",
                    source_sha256=passage_sha,
                    license=meta["license"],
                    provenance_uri=meta["uri"],
                )

                difficulty = difficulty_cycle[(item_idx - 1) % len(difficulty_cycle)]
                group_type = type_cycle[(item_idx - 1) % len(type_cycle)]

                reading_task = ReadingTask(
                    task_type="READING_SINGLE_PASSAGE",
                    requested_groups=[group_type],
                    requested_question_count=4,
                    difficulty=difficulty,
                )

                fixture = PairedTaskFixture(
                    dataset_item_id=f"final-reading-{item_idx:03d}",
                    domain="READING",
                    source=source_ref,
                    foundation_model_id="minimax/MiniMax-Text-01",
                    prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
                    rubric_version="rubric-qgeval-v2.0",
                    reading_task=reading_task,
                    passage_text=passage_text,
                )
                tasks.append(fixture)
                item_idx += 1

        self.validate_disjointness(tasks)
        self.validate_strata(tasks, domain="READING")
        self._reading_tasks = tasks
        return tasks

    def build_grammar_final_tasks(self) -> List[PairedTaskFixture]:
        """Constructs 28 family-disjoint Grammar tasks across 7 curated grammar families."""
        tasks: List[PairedTaskFixture] = []

        difficulty_cycle = ["B1", "B2", "C1"]
        exercise_cycle = [
            GrammarExerciseType.MCQ_SINGLE,
            GrammarExerciseType.GAP_FILL,
            GrammarExerciseType.ERROR_CORRECTION,
        ]

        item_idx = 1
        for meta in GRAMMAR_FAMILIES_METADATA:
            family = meta["family"]
            topic = meta["topic"]
            rules = meta["rules"]
            examples = meta["examples"]

            for var_idx in range(4):
                rule_pack_id = f"grp-{family.replace('fam-grammar-', '').replace('-final', '')}-{var_idx + 1:02d}"
                difficulty = difficulty_cycle[(item_idx - 1) % len(difficulty_cycle)]
                exercise_type = exercise_cycle[(item_idx - 1) % len(exercise_cycle)]

                rule_content = f"{rule_pack_id}:{topic}:{difficulty}:{json.dumps(rules)}:{json.dumps(examples)}"
                rule_sha = hashlib.sha256(rule_content.encode("utf-8")).hexdigest()

                source_ref = SourceRef(
                    source_id=f"src-grammar-final-{item_idx:03d}",
                    source_family=family,
                    source_version="v1.0",
                    source_sha256=rule_sha,
                    license="synthetic_not_expert",
                    provenance_uri=f"https://langfens.internal/research/grammar/{rule_pack_id}",
                )

                rule_pack = GrammarRulePack(
                    rule_pack_id=rule_pack_id,
                    source=source_ref,
                    topic=topic,
                    level=difficulty,
                    rule_ids=rules,
                    applicability=["Academic IELTS Reading and Writing", "Grammar Accuracy"],
                    exceptions=["Colloquial spoken English registers"],
                    examples=examples,
                )

                grammar_task = GrammarTask(
                    task_type="GRAMMAR_EXERCISE",
                    grammar_rule_pack_ref=rule_pack_id,
                    exercise_type=exercise_type,
                    requested_question_count=5,
                    difficulty=difficulty,
                )

                fixture = PairedTaskFixture(
                    dataset_item_id=f"final-grammar-{item_idx:03d}",
                    domain="GRAMMAR",
                    source=source_ref,
                    foundation_model_id="minimax/MiniMax-Text-01",
                    prompt_versions=PromptVersionMap(A="v2.1", B="v2.2", C="v3.0"),
                    rubric_version="rubric-qgeval-v2.0",
                    grammar_task=grammar_task,
                    rule_pack=rule_pack,
                )
                tasks.append(fixture)
                item_idx += 1

        self.validate_disjointness(tasks)
        self.validate_strata(tasks, domain="GRAMMAR")
        self._grammar_tasks = tasks
        return tasks

    def validate_disjointness(self, tasks: List[PairedTaskFixture]) -> None:
        """Validates that no FINAL task shares a source family with DEV, CALIBRATION, HOLDOUT, or G15."""
        for task in tasks:
            family = task.source.source_family
            source_id = task.source.source_id
            if family in FORBIDDEN_DEV_CALIBRATION_FAMILIES or any(
                forbidden in family for forbidden in FORBIDDEN_DEV_CALIBRATION_FAMILIES
            ):
                raise SourceFamilyOverlapError(
                    f"FINAL task {task.dataset_item_id} leaks forbidden source family '{family}'"
                )
            if any(forbidden in source_id for forbidden in FORBIDDEN_DEV_CALIBRATION_FAMILIES):
                raise SourceFamilyOverlapError(
                    f"FINAL task {task.dataset_item_id} leaks forbidden source ID '{source_id}'"
                )

    def validate_strata(self, tasks: List[PairedTaskFixture], domain: str) -> None:
        """Validates balanced difficulty and type strata across dataset tasks."""
        if len(tasks) < 25 or len(tasks) > 40:
            raise DatasetStrataDefectError(
                f"FINAL dataset count must be between 25 and 40 items, got {len(tasks)}"
            )

        if domain == "READING":
            difficulties = {t.reading_task.difficulty for t in tasks if t.reading_task}
            expected_difficulties = {"B1", "B2", "C1"}
            if not expected_difficulties.issubset(difficulties):
                raise DatasetStrataDefectError(
                    f"Reading missing required difficulty strata: {expected_difficulties - difficulties}"
                )

            types: Set[StandaloneGroupType] = set()
            for t in tasks:
                if t.reading_task:
                    types.update(t.reading_task.requested_groups)
            if len(types) < 4:
                raise DatasetStrataDefectError(
                    f"Reading question types under-represented (found {len(types)}, expected >= 4)"
                )

        elif domain == "GRAMMAR":
            difficulties = {t.grammar_task.difficulty for t in tasks if t.grammar_task}
            expected_difficulties = {"B1", "B2", "C1"}
            if not expected_difficulties.issubset(difficulties):
                raise DatasetStrataDefectError(
                    f"Grammar missing required difficulty strata: {expected_difficulties - difficulties}"
                )

            ex_types = {t.grammar_task.exercise_type for t in tasks if t.grammar_task}
            expected_ex_types = {
                GrammarExerciseType.MCQ_SINGLE,
                GrammarExerciseType.GAP_FILL,
                GrammarExerciseType.ERROR_CORRECTION,
            }
            if not expected_ex_types.issubset(ex_types):
                raise DatasetStrataDefectError(
                    f"Grammar exercise types under-represented: {expected_ex_types - ex_types}"
                )

    def generate_paired_assignments(self, attempt_number: int = 1) -> List[ExperimentAssignment]:
        """Generates deterministic paired assignments for arms A, B, and C."""
        all_tasks = self._reading_tasks + self._grammar_tasks
        if not all_tasks:
            raise ValueError("No tasks registered in dataset registry")

        assignments: List[ExperimentAssignment] = []
        for task in all_tasks:
            arm_assignments = self._assignment_manager.create_paired_assignments(
                fixture=task, attempt_number=attempt_number
            )
            for asg in arm_assignments:
                self._assignment_manager.register_assignment(asg)
                assignments.append(asg)

        self._assignments = assignments
        self._is_frozen = True
        return assignments

    def partition_into_batches(
        self, max_items_per_batch: int = 5
    ) -> List[List[PairedTaskFixture]]:
        """Partitions tasks into batches of at most 5 items per FINAL_BATCH_RULES.md."""
        all_tasks = self._reading_tasks + self._grammar_tasks
        batches: List[List[PairedTaskFixture]] = []
        for i in range(0, len(all_tasks), max_items_per_batch):
            batches.append(all_tasks[i : i + max_items_per_batch])
        return batches
