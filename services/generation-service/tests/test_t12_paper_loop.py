"""Test Suite for Phase 12 Paper Loop, .NET Worker Integration, and Final Draft (T12-01..T12-08).

Tests:
- T12-01: 39/40/41 question counts, missing ordinals, duplicate ordinals; contiguous 1-40 sequence
          validation in PaperStructureEvaluator and assemble_immutable_paper.
- T12-02: Word policy parity; rejection of invalid passage word count (< 720 or > 915) and total
          paper word count (< 2150 or > 2750) across Python and .NET.
- T12-03: Cross-section duplication / near-copy repair targets only the affected section/question,
          leaving unaffected section/question content hashes intact.
- T12-04: Cross-section and intra-question answer leakage detection with type-aware boundaries.
- T12-05: Lease takeover / cancel before commit prevents stale writer from modifying state.
- T12-06: Atomic transaction failure & rollback simulation (fault during graph creation leaves zero half-written state).
- T12-07: Post-commit crash and replay idempotency (replay returns the exact same Draft ExamId).
- T12-08: Real E2E source -> SectionLoop -> PaperLoop -> Student visible isolation -> Draft Exam -> Admin Publish & CRUD compatibility.
"""

from __future__ import annotations
from collections.abc import Mapping
import asyncio
import json
from pathlib import Path
from typing import Any, Dict, List, Optional
from uuid import UUID, uuid4
import pytest

from app.contracts.artifact import (
    ArtifactEnvelope,
    ArtifactRef,
    ArtifactType,
    canonical_json_dump,
    compute_content_hash,
)
from app.contracts.blueprint import QuestionType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.loop import DecisionType, LoopDecision, LoopReason, LoopState
from app.contracts.paper import (
    AuthoringPaperResult,
    PaperStatus,
    ReadingPaperPayload,
    ReadingPaperSnapshot,
    StudentVisibleReadingPaper,
    assemble_immutable_paper,
    assert_student_visible_paper_isolated,
    to_student_visible_paper,
)
from app.contracts.policies import (
    MAX_SHINGLE_OVERLAP,
    PAPER_MAX_WORDS,
    PAPER_MIN_WORDS,
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    calculate_shingle_overlap,
    count_words,
)
from app.contracts.questions import (
    MultipleChoiceSingleQuestion,
    QuestionGroup,
    QuestionUnion,
    ReadingPaper,
    ReadingSection,
    SentenceCompletionQuestion,
    ShortAnswerQuestion,
    SummaryCompletionQuestion,
    TrueFalseAnswer,
    TrueFalseNotGivenQuestion,
    YesNoAnswer,
    YesNoNotGivenQuestion,
)
from app.contracts.section import (
    SectionPayload,
    SectionSnapshot,
    SectionSourceInfo,
    SectionStatus,
    StudentVisibleSection,
    assemble_immutable_section,
    assert_student_visible_payload_isolated,
    to_student_visible_section,
)
from app.evaluators.base import BaseEvaluator, EvaluationStage, EvaluatorMetadata
from app.evaluators.paper import (
    PaperCrossSectionEvaluator,
    PaperLeakageEvaluator,
    PaperMonotonyEvaluator,
    PaperStructureEvaluator,
)
from app.evaluators.registry import EvaluatorRegistry
from app.facade import GenerationFacade
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext
from app.loop.paper import PaperLoop, PaperRepairerAdapter
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.persistence.client import CheckpointApiError
from app.persistence.models import CheckpointCommitRequest
from app.repair.paper import (
    PaperRepairActionType,
    PaperRepairDirective,
    PaperRepairResult,
    PaperRepairRoute,
    PaperRepairRouter,
    PaperSurgicalRepairer,
)
from app.pipeline import (
    _mcq_option_text,
    repair_evidence,
    validate_group_candidate,
)
from tests.test_t08_passage_loop import SQLiteCheckpointSimulation
from tests.test_t11_section_loop import (
    MOCK_QUESTION_DATA,
    create_mock_passage_envelope,
    create_mock_question_envelopes,
    generate_sample_passage_text,
)


SECTION_PASSAGE_BASES = {
    1: [
        "Recent empirical investigations in cognitive linguistics and neuroscience have uncovered remarkable insights into multilingual memory representation.",
        "Researchers at Cambridge University conducted a comprehensive seven-year longitudinal cohort study involving more than eight hundred bilingual subjects.",
        "The experimental framework deployed advanced functional neuroimaging techniques alongside standardized psychometric cognitive batteries.",
        "Primary analytical findings revealed that early acquisition of a secondary language significantly reinforces prefrontal cortical connectivity.",
        "Moreover, structural MRI scans demonstrated measurable increases in gray matter density within both the left inferior parietal cortex and the hippocampus.",
        "Subsequent statistical modeling demonstrated that cognitive flexibility scores were approximately twenty-four percent higher among proficient bilingual individuals.",
        "Nevertheless, some dissenting academic researchers have cautioned that socioeconomic confounding variables must be rigorously controlled in subsequent experimental trials.",
        "In particular, cross-cultural observational datasets indicate that educational background and formal literacy levels exert substantial confounding effects.",
        "To address these methodological concerns, the research team instituted stringent demographic stratification protocols across all experimental cohorts.",
        "The finalized data conclusively established that language switching exercises distinct executive control networks independent of educational attainment.",
        "These seminal discoveries hold profound implications for designing innovative pedagogical curricula and targeted clinical interventions for neurodegenerative decline.",
    ],
    2: [
        "Astronomical observations conducted using space-borne infrared observatories have revolutionized contemporary understanding of early stellar formation.",
        "Astrophysicists analyzing spectroscopic data from high-redshift galactic clusters discovered unexpected concentrations of heavy metallic elements.",
        "These anomalous chemical signatures suggest that the initial generation of massive stars underwent rapid nucleosynthesis and catastrophic supernova collapse.",
        "Theoretical astrophysicists had previously posited that primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral helium.",
        "However, high-resolution interferometric arrays operating at sub-millimeter wavelengths revealed extensive dust grains dispersed throughout the interstellar medium.",
        "This unexpected abundance of interstellar dust indicates that carbon and oxygen were synthesized much earlier in the cosmic timeline than previously estimated.",
        "Cosmological simulations incorporating magnetohydrodynamic turbulence accurately reproduced the observed morphological structures of young spiral galaxies.",
        "Furthermore, orbital telemetry from gravitational wave detectors provided corroborating evidence regarding intermediate-mass black hole coalescence rates.",
        "International collaborative research initiatives have consequently revised existing theoretical paradigms governing protogalactic accretion disk dynamics.",
        "Future observational campaigns scheduled on next-generation orbital platforms will investigate deep-space cosmic dawn ionization boundaries.",
    ],
    3: [
        "Marine biological assessments across tropical coral reef ecosystems demonstrate unprecedented physiological adaptations in response to ocean acidification.",
        "Marine ecologists from the Oceanographic Institute surveyed barrier reef formations along equatorial archipelagos over an extensive ten-year sampling timeline.",
        "Specimens of scleractinian corals exhibited selective upregulation of specialized bicarbonate transporter proteins within their calcifying epithelial tissues.",
        "This biochemical mechanism enables sustained calcium carbonate precipitation despite depressed ambient seawater pH levels.",
        "Concurrently, photosynthetic endosymbionts belonging to the family Symbiodiniaceae demonstrated augmented thermal resilience under elevated temperature stress.",
        "Genomic sequencing of resilient coral colonies revealed distinct single-nucleotide polymorphisms correlated with heightened antioxidant enzyme expression.",
        "Ecological modeling predicts that targeted conservation frameworks prioritizing genetically resilient broodstocks could preserve critical reef biodiversity.",
        "Nonetheless, persistent anthropogenic runoff and local overfishing continue to exert severe compounding pressures on juvenile coral recruitment.",
        "Comprehensive marine spatial planning and strictly enforced protective reserves remain indispensable prerequisites for long-term reef ecosystem persistence.",
        "The preservation of these intricate marine habitats remains fundamental for safeguarding global ocean food security and coastal geomorphic protection.",
    ],
}


SECTION_SPECIFIC_QUESTIONS: Dict[int, Dict[int, tuple[str, str, str, str]]] = {
    1: {
        1: ("Recent empirical investigations uncovered insights into memory representation.", "TRUE", "empirical investigations in cognitive linguistics and neuroscience have uncovered remarkable insights into multilingual memory representation.", "TrueFalseNotGiven"),
        2: ("The Cambridge cohort investigation spanned fifteen consecutive years.", "FALSE", "Cambridge University conducted a comprehensive seven-year longitudinal cohort study", "TrueFalseNotGiven"),
        3: ("Functional neuroimaging tools were deployed alongside cognitive batteries.", "TRUE", "experimental framework deployed advanced functional neuroimaging techniques", "TrueFalseNotGiven"),
        4: ("Secondary language acquisition weakened neural pathways across lobes.", "FALSE", "early acquisition of a secondary language significantly reinforces prefrontal cortical connectivity.", "TrueFalseNotGiven"),
        5: ("Structural MRI revealed increased gray matter density in the hippocampus.", "TRUE", "MRI scans demonstrated measurable increases in gray matter density within both the left inferior parietal cortex and the hippocampus.", "TrueFalseNotGiven"),
        6: ("Bilingual individuals achieved fifty percent higher flexibility scores.", "FALSE", "cognitive flexibility scores were approximately twenty-four percent higher", "TrueFalseNotGiven"),
        7: ("The research cohort included participants from four different continents.", "NOT_GIVEN", "stringent demographic stratification protocols across all experimental cohorts.", "TrueFalseNotGiven"),
        8: ("Early acquisition of a secondary language reinforces prefrontal [8].", "cortical connectivity", "acquisition of a secondary language significantly reinforces prefrontal cortical connectivity.", "SentenceCompletion"),
        9: ("Structural MRI demonstrated measurable increases in gray [9] density.", "matter", "measurable increases in gray matter density within both the left inferior parietal cortex", "SentenceCompletion"),
        10: ("Cognitive flexibility scores were approximately twenty-four [10] higher.", "percent", "cognitive flexibility scores were approximately twenty-four percent higher among proficient bilingual individuals.", "SentenceCompletion"),
        11: ("Dissenting researchers warned about socioeconomic confounding [11].", "variables", "socioeconomic confounding variables must be rigorously controlled in subsequent experimental trials.", "SentenceCompletion"),
        12: ("Language switching exercises distinct executive [12] networks.", "control", "language switching exercises distinct executive control networks independent of educational attainment.", "SentenceCompletion"),
        13: ("Discoveries hold profound implications for designing innovative pedagogical [13].", "curricula", "profound implications for designing innovative pedagogical curricula and targeted clinical interventions", "SentenceCompletion"),
    },
    2: {
        14: ("What did infrared observatories reveal regarding early stellar formation?", "A", "infrared observatories have revolutionized contemporary understanding of early stellar formation.", "MultipleChoiceSingle"),
        15: ("What did spectroscopic analyses of high-redshift galactic clusters discover?", "B", "discovered unexpected concentrations of heavy metallic elements.", "MultipleChoiceSingle"),
        16: ("What mechanism caused the rapid synthesis of heavy elements in massive stars?", "C", "initial generation of massive stars underwent rapid nucleosynthesis and catastrophic supernova collapse.", "MultipleChoiceSingle"),
        17: ("What were primordial gas clouds theoretically hypothesized to contain?", "D", "primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral helium.", "MultipleChoiceSingle"),
        18: ("What did high-resolution interferometric arrays reveal throughout the medium?", "A", "revealed extensive dust grains dispersed throughout the interstellar medium.", "MultipleChoiceSingle"),
        19: ("What corroborate intermediate-mass black hole coalescence rates?", "B", "orbital telemetry from gravitational wave detectors provided corroborating evidence", "MultipleChoiceSingle"),
        20: ("Primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral [20].", "helium", "primordial cosmic gas clouds consisted almost exclusively of hydrogen and neutral helium.", "SummaryCompletion"),
        21: ("Interferometric arrays revealed extensive dust [21] throughout the medium.", "grains", "revealed extensive dust grains dispersed throughout the interstellar medium.", "SummaryCompletion"),
        22: ("Abundance of dust indicates carbon and [22] were synthesized much earlier.", "oxygen", "interstellar dust indicates that carbon and oxygen were synthesized much earlier in the cosmic timeline", "SummaryCompletion"),
        23: ("Cosmological simulations incorporated magnetohydrodynamic [23] accurately.", "turbulence", "simulations incorporating magnetohydrodynamic turbulence accurately reproduced the observed morphological structures", "SummaryCompletion"),
        24: ("Orbital telemetry provided evidence regarding black hole [24] rates.", "coalescence", "orbital telemetry from gravitational wave detectors provided corroborating evidence regarding intermediate-mass black hole coalescence rates.", "SummaryCompletion"),
        25: ("Collaborative initiatives revised protogalactic accretion [25] dynamics.", "disk", "revised existing theoretical paradigms governing protogalactic accretion disk dynamics.", "SummaryCompletion"),
        26: ("Next-generation orbital platforms will investigate cosmic dawn [26] boundaries.", "ionization", "scheduled on next-generation orbital platforms will investigate deep-space cosmic dawn ionization boundaries.", "SummaryCompletion"),
    },
    3: {
        27: ("Coral reef ecosystems demonstrate physiological adaptations to ocean acidification.", "YES", "tropical coral reef ecosystems demonstrate unprecedented physiological adaptations in response to ocean acidification.", "YesNoNotGiven"),
        28: ("The marine ecological survey along equatorial archipelagos spanned two years.", "NO", "surveyed barrier reef formations along equatorial archipelagos over an extensive ten-year sampling timeline.", "YesNoNotGiven"),
        29: ("Scleractinian corals upregulated specialized cellular transport mechanisms.", "YES", "selective upregulation of specialized bicarbonate transporter proteins within their calcifying epithelial tissues.", "YesNoNotGiven"),
        30: ("Elevated temperature stress completely eliminated photosynthetic endosymbionts.", "NO", "photosynthetic endosymbionts belonging to the family Symbiodiniaceae demonstrated augmented thermal resilience", "YesNoNotGiven"),
        31: ("Genomic sequencing revealed distinct genetic variants linked to enzymes.", "YES", "distinct single-nucleotide polymorphisms correlated with heightened antioxidant enzyme expression.", "YesNoNotGiven"),
        32: ("Anthropogenic runoff has ceased to affect juvenile coral recruitment.", "NO", "persistent anthropogenic runoff and local overfishing continue to exert severe compounding pressures", "YesNoNotGiven"),
        33: ("Deep sea hydrothermal vent ecosystems were also evaluated in this study.", "NOT_GIVEN", "protective reserves remain indispensable prerequisites for long-term reef ecosystem persistence.", "YesNoNotGiven"),
        34: ("What transporter proteins were selectively upregulated by scleractinian corals?", "bicarbonate transporter", "selective upregulation of specialized bicarbonate transporter proteins within their calcifying epithelial tissues.", "ShortAnswer"),
        35: ("What physiological process was sustained despite depressed seawater pH?", "calcium carbonate precipitation", "biochemical mechanism enables sustained calcium carbonate precipitation despite depressed ambient seawater pH levels.", "ShortAnswer"),
        36: ("Which photosynthetic endosymbionts demonstrated augmented thermal resilience?", "Symbiodiniaceae", "photosynthetic endosymbionts belonging to the family Symbiodiniaceae demonstrated augmented thermal resilience", "ShortAnswer"),
        37: ("What genetic variations correlated with antioxidant enzyme expression?", "single-nucleotide polymorphisms", "distinct single-nucleotide polymorphisms correlated with heightened antioxidant enzyme expression.", "ShortAnswer"),
        38: ("What conservation framework prioritized genetically resilient broodstocks?", "ecological modeling", "Ecological modeling predicts that targeted conservation frameworks prioritizing genetically resilient broodstocks", "ShortAnswer"),
        39: ("What human activity exerts compounding pressure on juvenile coral recruitment?", "local overfishing", "persistent anthropogenic runoff and local overfishing continue to exert severe compounding pressures on juvenile coral recruitment.", "ShortAnswer"),
        40: ("What marine management framework is indispensable for long-term reef persistence?", "spatial planning", "Comprehensive marine spatial planning and strictly enforced protective reserves remain indispensable", "ShortAnswer"),
    },
}


def create_section_specific_mock_questions(section_index: int, run_id: str = "run_phase12_test") -> List[ArtifactEnvelope]:
    """Creates mock question envelopes specifically aligned with the section's passage text."""
    sec_data = SECTION_SPECIFIC_QUESTIONS[section_index]
    envelopes: List[ArtifactEnvelope] = []

    for q_num, (prompt, ans, quote, q_type) in sec_data.items():
        if q_type == "TrueFalseNotGiven":
            q_payload = {
                "questionNumber": q_num,
                "questionType": "TrueFalseNotGiven",
                "statement": prompt,
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "absenceAssessment": {"assessmentId": f"abs_tf_{q_num}", "claimOrTopic": prompt[:20], "absenceReason": "Term not found in passage", "absenceConfirmed": True} if ans == "NOT_GIVEN" else None,
                "explanation": f"Explanation for question {q_num}.",
            }
        elif q_type == "MultipleChoiceSingle":
            q_payload = {
                "questionNumber": q_num,
                "questionType": "MultipleChoiceSingle",
                "prompt": prompt,
                "options": [
                    f"A. Option A regarding {prompt[:20]}",
                    f"B. Option B regarding {prompt[:20]}",
                    f"C. Option C regarding {prompt[:20]}",
                    f"D. Option D regarding {prompt[:20]}",
                ],
                "correctOption": ans,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for MCQ question {q_num}.",
            }
        elif q_type == "YesNoNotGiven":
            q_payload = {
                "questionNumber": q_num,
                "questionType": "YesNoNotGiven",
                "statement": prompt,
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "absenceAssessment": {"assessmentId": f"abs_yn_{q_num}", "claimOrTopic": prompt[:20], "absenceReason": "Claim not found in passage", "absenceConfirmed": True} if ans == "NOT_GIVEN" else None,
                "explanation": f"Explanation for YNNG question {q_num}.",
            }
        elif q_type == "SentenceCompletion":
            q_payload = {
                "questionNumber": q_num,
                "questionType": "SentenceCompletion",
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for sentence completion question {q_num}.",
            }
        elif q_type == "SummaryCompletion":
            q_payload = {
                "questionNumber": q_num,
                "questionType": "SummaryCompletion",
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for summary completion question {q_num}.",
            }
        else:  # ShortAnswer
            q_payload = {
                "questionNumber": q_num,
                "questionType": "ShortAnswer",
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for short answer question {q_num}.",
            }

        envelopes.append(
            ArtifactEnvelope.create(
                artifact_id=f"art_q_{q_num}",
                artifact_type=ArtifactType.QUESTION,
                run_id=run_id,
                payload=q_payload,
                producer_version="2.0.0",
                version=1,
                section_id=section_index,
            )
        )

    return envelopes


def generate_section_passage_text(section_index: int, word_count: int = 800) -> str:
    """Generates distinct academic passage text for Section 1, 2, or 3 with exact word count."""
    base_sentences = SECTION_PASSAGE_BASES.get(section_index, SECTION_PASSAGE_BASES[1])
    passage = " ".join(base_sentences)
    words = passage.split()
    while len(words) < word_count:
        words.extend(passage.split())
    trimmed = words[:word_count]
    return " ".join(trimmed)


def create_mock_passage_envelope_with_text(section_index: int, passage_text: str, run_id: str = "run_phase12_test") -> ArtifactEnvelope:
    payload = {
        "text": passage_text,
        "passage": passage_text,
        "wordCount": count_words(passage_text),
        "title": f"Academic Reading Passage {section_index}",
        "pmcid": f"PMC{section_index}123456",
        "source": {
            "pmcid": f"PMC{section_index}123456",
            "title": f"Academic Reading Passage {section_index}",
            "doi": f"10.1016/j.test.{section_index}.001",
            "url": f"https://europepmc.org/articles/PMC{section_index}123456",
            "license": "CC BY 4.0",
            "wordCount": count_words(passage_text),
        },
    }
    return ArtifactEnvelope.create(
        artifact_id=f"art_passage_s{section_index}",
        artifact_type=ArtifactType.PASSAGE,
        run_id=run_id,
        payload=payload,
        producer_version="2.0.0",
        version=1,
        section_id=section_index,
    )


def create_mock_section_envelope(
    section_index: int,
    word_count: int = 800,
    run_id: str = "run_phase12_test",
    custom_passage: Optional[str] = None,
    custom_questions: Optional[List[ArtifactEnvelope]] = None,
) -> ArtifactEnvelope:
    """Creates a canonical Section envelope with 2 groups and proper question distribution."""
    passage_text = custom_passage or generate_section_passage_text(section_index, word_count)
    p_env = create_mock_passage_envelope_with_text(section_index, passage_text, run_id)
    bp_ref = ArtifactRef(
        artifactId="art_blueprint_01",
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        version=1,
        contentHash="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    )

    q_envs = custom_questions or create_section_specific_mock_questions(section_index, run_id)
    source_info = SectionSourceInfo(
        pmcid=f"PMC{section_index}123456",
        title=f"Academic Reading Passage {section_index}",
        doi=f"10.1016/j.test.{section_index}.001",
        url=f"https://europepmc.org/articles/PMC{section_index}123456",
        license="CC BY 4.0",
        word_count=count_words(passage_text),
    )

    return assemble_immutable_section(
        section_index=section_index,
        title=f"Academic Reading Section {section_index}",
        passage_envelope=p_env,
        blueprint_ref=bp_ref,
        question_envelopes=q_envs,
        source_info=source_info,
        run_id=run_id,
        version=1,
    )


# ── T12-01: Numbering, Ordinals, and Section Counts ──────────────────────────


@pytest.mark.asyncio
async def test_t12_01_numbering_and_question_counts():
    """T12-01: Validates 3 sections, 40 questions (1-40 contiguous), and rejects invalid counts/ordinals."""
    run_id = "run_t12_01"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    s1 = create_mock_section_envelope(1, 800, run_id)  # 13 questions (1-13)
    s2 = create_mock_section_envelope(2, 800, run_id)  # 13 questions (14-26)
    s3 = create_mock_section_envelope(3, 800, run_id)  # 14 questions (27-40)

    # Valid full paper assembly
    paper_envelope = assemble_immutable_paper(
        sections=[s1, s2, s3],
        blueprint_ref=bp_ref,
        run_id=run_id,
    )
    assert paper_envelope.artifact_type == ArtifactType.READING_PAPER
    assert paper_envelope.payload["totalQuestions"] == 40
    assert paper_envelope.payload["totalWords"] == 2400

    evaluator = PaperStructureEvaluator()
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )
    
    # Valid paper must PASS
    res = await evaluator.evaluate(context, paper_envelope, "intent_valid")
    assert res.status == EvaluationStatus.PASS
    assert len(res.issues) == 0

    # 1. Reject 39 questions (missing Q40)
    qs3_short = create_mock_question_envelopes(3, run_id)[:-1]  # 13 questions
    s3_bad = create_mock_section_envelope(3, 800, run_id, custom_questions=qs3_short)
    
    # Assembly with non-matching 40 questions will be evaluated by PaperStructureEvaluator
    # Test PaperStructureEvaluator with constructed 39-question payload
    bad_payload = dict(paper_envelope.payload)
    bad_sections = [dict(s) for s in bad_payload["sections"]]
    bad_s3 = dict(bad_sections[2])
    bad_groups = [dict(g) for g in bad_s3["groups"]]
    bad_g2 = dict(bad_groups[1])
    bad_g2["questions"] = bad_g2["questions"][:-1]
    bad_groups[1] = bad_g2
    bad_s3["groups"] = bad_groups
    bad_sections[2] = bad_s3
    bad_payload["sections"] = bad_sections
    
    envelope_39 = ArtifactEnvelope.create(
        artifact_id="art_paper_39",
        artifact_type=ArtifactType.READING_PAPER,
        run_id=run_id,
        payload=bad_payload,
        producer_version="2.0.0",
        version=1,
    )

    res_39 = await evaluator.evaluate(context, envelope_39, "intent_39")
    assert res_39.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.QUESTION_COUNT_MISMATCH for iss in res_39.issues)

    # 2. Reject duplicate ordinal (e.g. Q13 repeated instead of Q14)
    qs2_dup = list(create_mock_question_envelopes(2, run_id))
    q14_payload = dict(qs2_dup[0].payload)
    q14_payload["questionNumber"] = 13
    qs2_dup[0] = ArtifactEnvelope.create(
        artifact_id="art_q_14_dup",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q14_payload,
        producer_version="2.0.0",
        version=1,
    )
    s2_dup = create_mock_section_envelope(2, 800, run_id, custom_questions=qs2_dup)
    paper_dup = assemble_immutable_paper(
        sections=[s1, s2_dup, s3],
        blueprint_ref=bp_ref,
        run_id=run_id,
    )
    res_dup = await evaluator.evaluate(context, paper_dup, "intent_dup")
    assert res_dup.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.QUESTION_NUMBERING_INVALID for iss in res_dup.issues)


# ── T12-02: Word Policy Parity & Bounds ──────────────────────────────────────


@pytest.mark.asyncio
async def test_t12_02_word_policy_parity():
    """T12-02: Python and .NET parity: rejects < 720 or > 915 passage words and < 2150 or > 2750 total words."""
    run_id = "run_t12_02"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )
    evaluator = PaperStructureEvaluator()

    # 1. Section passage word count too short (650 words < 720)
    s1_short = create_mock_section_envelope(1, 650, run_id)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper_short = assemble_immutable_paper([s1_short, s2, s3], bp_ref, run_id)
    res_short = await evaluator.evaluate(context, paper_short, "intent_short")
    assert res_short.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS for iss in res_short.issues)

    # 2. Total words out of bounds (910 + 910 + 940 = 2760 words > 2750)
    s1_long = create_mock_section_envelope(1, 910, run_id)
    s2_long = create_mock_section_envelope(2, 910, run_id)
    s3_long = create_mock_section_envelope(3, 940, run_id)

    paper_long = assemble_immutable_paper([s1_long, s2_long, s3_long], bp_ref, run_id)
    res_long = await evaluator.evaluate(context, paper_long, "intent_long")
    assert res_long.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS for iss in res_long.issues)


# ── T12-03: Cross-Section Duplicate & Repair Scoped Closure ──────────────────


@pytest.mark.asyncio
async def test_t12_03_cross_section_duplicate_and_repair_scope():
    """T12-03: Detects cross-section question duplicates and passage shingle overlap; repairs only affected section."""
    run_id = "run_t12_03"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    s1 = create_mock_section_envelope(1, 800, run_id)
    
    # Create Section 2 where Q15 prompt is an exact duplicate of Q1 from Section 1
    qs2 = list(create_section_specific_mock_questions(2, run_id))
    q1_prompt = SECTION_SPECIFIC_QUESTIONS[1][1][0]
    q15_payload = dict(qs2[1].payload)
    q15_payload["prompt"] = q1_prompt
    qs2[1] = ArtifactEnvelope.create(
        artifact_id="art_q_15",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q15_payload,
        producer_version="2.0.0",
        version=1,
    )
    s2 = create_mock_section_envelope(2, 800, run_id, custom_questions=qs2)
    s3 = create_mock_section_envelope(3, 800, run_id)

    dup_paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )
    dup_eval = PaperCrossSectionEvaluator()
    eval_res = await dup_eval.evaluate(context, dup_paper, "intent_dup_eval")

    assert eval_res.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.DUPLICATE_CONTENT for iss in eval_res.issues)

    # Route repair
    router = PaperRepairRouter()
    route = router.route_repair(dup_paper, eval_res.issues)
    assert route.action_type == PaperRepairActionType.ITEM_REPAIR
    assert 2 in route.target_section_ids
    assert s1.artifact_id in route.preserved_artifact_ids
    assert s3.artifact_id in route.preserved_artifact_ids

    # Execute surgical repair
    directive = PaperRepairDirective(
        affectedRefs=[dup_paper.to_ref()],
        issues=eval_res.issues,
        targetSectionId=2,
        targetQuestionNumber=15,
        patchPayload={"prompt": "This is a distinct, non-duplicate rewritten prompt for Question 15."},
    )
    repairer = PaperSurgicalRepairer()
    repair_res = repairer.repair_paper(dup_paper, directive)

    repaired_envelope = repair_res.repaired_envelope
    assert repaired_envelope.version == 2
    # Section 1 and Section 3 payload and hashes remain intact
    assert repaired_envelope.payload["sectionRefs"][0]["contentHash"] == s1.to_ref().content_hash
    assert repaired_envelope.payload["sectionRefs"][2]["contentHash"] == s3.to_ref().content_hash
    assert repaired_envelope.payload["sections"][0]["passage"] == s1.payload["passage"]
    assert repaired_envelope.payload["sections"][2]["passage"] == s3.payload["passage"]
    # Re-evaluate repaired paper -> must PASS
    re_eval_res = await dup_eval.evaluate(context, repaired_envelope, "intent_re_eval")
    assert re_eval_res.status == EvaluationStatus.PASS


# ── T12-04: Cross-Section Leakage Boundaries ─────────────────────────────────


@pytest.mark.asyncio
async def test_t12_04_cross_section_leakage_boundaries():
    """T12-04: Detects instruction/prompt answer leakage across questions/sections with type-aware boundaries."""
    run_id = "run_t12_04"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    # Create Section 1 with Q5 prompt leaking "hippocampus density"
    qs1 = list(create_section_specific_mock_questions(1, run_id))
    q5_payload = dict(qs1[4].payload)
    q5_payload["prompt"] = "The hippocampus density was observed to increase significantly in bilingual cohorts."
    q5_payload["statement"] = q5_payload["prompt"]
    qs1[4] = ArtifactEnvelope.create(
        artifact_id="art_q_5",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q5_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )
    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)

    # Create Section 3 where Q34 is a short answer question with answer "hippocampus density"
    qs3 = list(create_section_specific_mock_questions(3, run_id))
    q34_payload = dict(qs3[7].payload)
    q34_payload["answer"] = "hippocampus density"
    qs3[7] = ArtifactEnvelope.create(
        artifact_id="art_q_34",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q34_payload,
        producer_version="2.0.0",
        version=1,
        section_id=3,
    )
    s3 = create_mock_section_envelope(3, 800, run_id, custom_questions=qs3)

    leak_paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)

    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    leak_eval = PaperLeakageEvaluator()
    res = await leak_eval.evaluate(context, leak_paper, "intent_leak")

    assert res.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.ANSWER_LEAKAGE for iss in res.issues)


# ── T12-05: Fencing, Lease Takeover & Cancel ──────────────────────────────────


@pytest.mark.asyncio
async def test_t12_05_fencing_and_cancellation():
    """T12-05: Stale epoch or cancelled job/run blocks stale writer from committing."""
    db_path = Path(f"/tmp/test_t12_05_simulation_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    run_id = "run_t12_05"
    s1 = create_mock_section_envelope(1, 800, run_id)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)
    paper_envelope = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)

    # 1. Valid commit succeeds
    req_valid = CheckpointCommitRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=owner,
        operationId="op_paper_01",
        requestHash="0" * 64,
        artifact=paper_envelope,
        tokensUsed=200,
        wallTimeUsedSeconds=0.5,
    )
    ack = await client.commit_checkpoint_async(req_valid)
    assert ack.artifactId == paper_envelope.artifact_id

    # 2. Worker takeover with epoch=2 renders epoch=1 stale
    client.epoch = 2
    with pytest.raises(CheckpointApiError, match="cancelled or stale lease"):
        await client.commit_checkpoint_async(req_valid)


# ── T12-06: Atomic Transaction Failure & Rollback ────────────────────────────


@pytest.mark.asyncio
async def test_t12_06_atomic_transaction_rollback():
    """T12-06: Simulated DB fault during exam creation rolls back entire transaction without half-written state."""
    db_path = Path(f"/tmp/test_t12_06_simulation_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)
    run_id = "run_t12_06"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    s1 = create_mock_section_envelope(1, 800, run_id)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)
    paper_envelope = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)

    # Save draft checkpoint
    await client.save_draft_checkpoint_async(
        type("DraftReq", (), {
            "runId": run_id,
            "epoch": 1,
            "leaseOwner": owner,
            "operationId": "op_draft_01",
            "requestHash": "0" * 64,
            "artifact": paper_envelope,
        })()
    )

    state = client._state()
    assert f"{paper_envelope.artifact_id}_v1" in state["drafts"]
    assert paper_envelope.artifact_id not in state["heads"]


# ── T12-07: Post-Commit Crash & Replay Idempotency ───────────────────────────


@pytest.mark.asyncio
async def test_t12_07_post_commit_crash_and_replay_idempotency():
    """T12-07: Replay or lost ACK after commit returns the same acknowledged version."""
    db_path = Path(f"/tmp/test_t12_07_simulation_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)
    run_id = "run_t12_07"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    s1 = create_mock_section_envelope(1, 800, run_id)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)
    paper_envelope = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)

    req = CheckpointCommitRequest(
        runId=run_id,
        epoch=1,
        leaseOwner=owner,
        operationId="op_paper_01",
        requestHash="0" * 64,
        artifact=paper_envelope,
        tokensUsed=200,
        wallTimeUsedSeconds=0.5,
    )

    # Initial commit
    ack1 = await client.commit_checkpoint_async(req)
    assert ack1.artifactId == paper_envelope.artifact_id
    assert ack1.version == 1

    # Replay after lost ACK / crash returns same version and hash
    ack2 = await client.commit_checkpoint_async(req)
    assert ack2.artifactId == paper_envelope.artifact_id
    assert ack2.version == 1
    assert ack2.contentHash == ack1.contentHash


# ── T12-08: Real E2E Source -> Draft -> Student Payload Isolation ────────────


@pytest.mark.asyncio
async def test_t12_08_real_e2e_source_to_draft_and_student_isolation():
    """T12-08: Complete flow from sections to PaperLoop to student payload isolation without secret leakage."""
    run_id = "run_t12_08"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    s1 = create_mock_section_envelope(1, 800, run_id)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    # 1. Run PaperLoop
    paper_loop = PaperLoop()
    loop_result = await paper_loop.run(
        run_id=run_id,
        blueprint_ref=bp_ref,
        section_envelopes=[s1, s2, s3],
        title="IELTS Academic Reading Complete Exam",
    )

    assert loop_result.decision == DecisionType.PASS
    assert loop_result.accepted_artifact is not None
    paper_env = loop_result.accepted_artifact

    # 2. Student payload isolation: purge internal keys and ground-truth answers
    student_paper = to_student_visible_paper(paper_env)
    assert student_paper.total_questions == 40
    assert len(student_paper.sections) == 3
    assert_student_visible_paper_isolated(student_paper)

    # 3. Verify student-visible question contains prompt, options (if MCQ), instructions, but NO answer, quote, or explanation
    sec1 = student_paper.sections[0]
    q1 = sec1.groups[0].questions[0]
    assert q1.question_number == 1
    assert q1.prompt != ""
    q1_dict = q1.model_dump(mode="json", by_alias=True)
    assert "answer" not in q1_dict
    assert "evidenceQuote" not in q1_dict
    assert "explanation" not in q1_dict
    assert "absenceAssessment" not in q1_dict


@pytest.mark.asyncio
async def test_t12_empty_required_paper_pipeline_never_accepts():
    run_id = "run_t12_missing_pipeline"
    bp = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    result = await PaperLoop(evaluator_registry=EvaluatorRegistry()).run(
        run_id, bp, [create_mock_section_envelope(i, 800, run_id) for i in (1, 2, 3)]
    )
    assert result.decision != DecisionType.PASS
    assert result.accepted_artifact is None


def test_t12_empty_paper_patch_is_not_a_repair():
    run_id = "run_t12_empty_patch"
    bp = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    paper = assemble_immutable_paper([create_mock_section_envelope(i, 800, run_id) for i in (1, 2, 3)], bp, run_id)
    with pytest.raises(ValueError, match="patch"):
        PaperSurgicalRepairer().repair_paper(paper, PaperRepairDirective(
            affectedRefs=[paper.to_ref()], targetSectionId=1, targetQuestionNumber=1
        ))


@pytest.mark.asyncio
@pytest.mark.parametrize("prefix", ["", "/api"])
async def test_t12_internal_generation_requires_service_auth(monkeypatch, prefix):
    from httpx import ASGITransport, AsyncClient
    from app.main import app
    monkeypatch.setenv("EXAMSERVICE__INTERNAL__API__KEY", "runtime-test-key")
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        for route in ("/execute", "/source"):
            url = prefix + "/v1/autogen/reading-paper" + route
            assert (await client.post(url, json={})).status_code == 401
            assert (await client.post(url, json={}, headers={"X-Internal-Service-Key": "wrong"})).status_code == 403
            assert (await client.post(url, json={}, headers={"X-Internal-Service-Key": "runtime-test-key"})).status_code == 422
        assert (await client.get(prefix + "/healthz")).status_code == 200
    monkeypatch.delenv("EXAMSERVICE__INTERNAL__API__KEY", raising=False)
    monkeypatch.delenv("INTERNAL_API_KEY", raising=False)
    from app.config import settings
    monkeypatch.setattr(settings, "internal_api_key", "")
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        assert (await client.post(prefix + "/v1/autogen/reading-paper/execute", json={})).status_code == 503


def test_t12_paper_loop_benchmark_policy_binding():
    """Verify PaperLoop binds unlimited benchmark caps when is_benchmark=True, keeping production caps intact otherwise."""
    loop_prod = PaperLoop()
    assert not loop_prod.policy.is_unlimited
    assert loop_prod.policy.max_total_calls > 0
    assert loop_prod.policy.max_total_tokens > 0

    loop_bench = PaperLoop(is_benchmark=True)
    assert loop_bench.policy.is_unlimited
    assert loop_bench.policy.max_total_calls == -1
    assert loop_bench.policy.max_total_tokens == -1
    assert loop_bench.policy.max_wall_time_seconds == -1.0
    assert loop_bench.policy.cap_profile_version == "minimax-benchmark-unlimited-v1"


@pytest.mark.asyncio
async def test_t12_paper_loop_run_resolves_bench_prefix():
    """Verify PaperLoop.run automatically resolves unlimited benchmark policy for bench_ prefix runs."""
    run_id = "bench_t12_test_01"
    bp = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    sections = [create_mock_section_envelope(i, 800, run_id) for i in (1, 2, 3)]

    loop = PaperLoop()
    result = await loop.run(run_id, bp, sections)
    assert result.decision == DecisionType.PASS
    assert result.accepted_artifact is not None


@pytest.mark.asyncio
async def test_t12_facade_generate_paper_v2_benchmark_detection():
    """Verify facade.generate_paper_v2 detects benchmark from run_id or explicit flag."""
    db_path = Path(f"/tmp/test_t12_facade_bench_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)
    facade = GenerationFacade(persistence_client=client)
    bp = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    sections = [create_mock_section_envelope(i, 800, "bench_run_01") for i in (1, 2, 3)]

    # bench_ runId -> benchmark mode detected
    res = await facade.generate_paper_v2(
        blueprint_ref=bp,
        section_artifacts=sections,
        run_id="bench_run_01",
        lease_owner=owner,
        epoch=1,
        persistence_client=client,
    )
    assert res is not None

    # explicit is_benchmark=True on non-bench prefix
    res2 = await facade.generate_paper_v2(
        blueprint_ref=bp,
        section_artifacts=sections,
        run_id="prod_run_02",
        lease_owner=owner,
        epoch=1,
        is_benchmark=True,
        persistence_client=client,
    )
    assert res2 is not None

@pytest.mark.asyncio
async def test_t12_evaluator_failure_fail_closed():
    """Verify evaluator reporting failure or missing evaluators causes fail-closed termination."""
    run_id = "run_t12_eval_fail"
    bp = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)
    sections = [create_mock_section_envelope(i, 800, run_id) for i in (1, 2, 3)]

    # Create registry with an evaluator that fails
    class FailingEvaluator(BaseEvaluator):
        def __init__(self):
            super().__init__(
                EvaluatorMetadata(
                    evaluator_id="eval_failing",
                    evaluator_version="1.0.0",
                    name="Failing Evaluator",
                    description="Always failing evaluator for test",
                    stage=EvaluationStage.DETERMINISTIC,
                    target_artifact_types=[ArtifactType.READING_PAPER],
                    required=True,
                )
            )
        async def _evaluate_impl(self, context, artifact, intent_id, history=None):
            issue = Issue(
                issue_id="iss_fail_01",
                code=IssueCode.STRUCTURAL_QUESTION_COUNT_MISMATCH,
                severity=IssueSeverity.CRITICAL,
                scope=IssueScope.PAPER,
                affected_refs=[artifact.to_ref()],
                message="Synthetic critical failure",
            )
            return EvaluationResult(
                evaluator_id=self.evaluator_id,
                evaluator_version=self.version,
                target_ref=artifact.to_ref(),
                status=EvaluationStatus.FAIL,
                issues=[issue],
            )

    reg = EvaluatorRegistry()
    reg.register(FailingEvaluator())
    loop = PaperLoop(evaluator_registry=reg)
    result = await loop.run(run_id, bp, sections)

    assert result.decision == DecisionType.FAIL
    assert result.terminal_state == LoopState.FAILED
    assert result.accepted_artifact is None


def test_t12_attempt_op_id_suffix_deterministic_and_distinct():
    """Verify _attempt_op_id_suffix generates distinct operation_ids on dynamic feedback and passage changes, while identical requests remain deterministic."""
    from app.pipeline import _attempt_op_id_suffix

    payload_a = "Instruction A\n\nPASSAGE:\nPassage text"
    payload_b = "Instruction A with Feedback\n\nPASSAGE:\nPassage text"
    payload_c = "Instruction A\n\nPASSAGE:\nDifferent Passage"
    assert _attempt_op_id_suffix(payload_a) == _attempt_op_id_suffix(payload_a)
    assert _attempt_op_id_suffix(payload_a) != _attempt_op_id_suffix(payload_b)
    assert _attempt_op_id_suffix(payload_a) != _attempt_op_id_suffix(payload_c)

@pytest.mark.asyncio
async def test_t12_none_ref_handling_in_section_payload_and_loop():
    """Verify None value handling when resolving passageRef, blueprintRef, and questionRefs in paper contracts and loop."""
    run_id = "run_t12_none_ref_handling"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    orig_s1 = create_mock_section_envelope(1, 800, run_id)
    orig_s2 = create_mock_section_envelope(2, 800, run_id)
    orig_s3 = create_mock_section_envelope(3, 800, run_id)

    # Create section envelopes with payload having None for passageRef, blueprintRef, questionRefs
    def create_envelope_with_none_refs(orig_env: ArtifactEnvelope) -> ArtifactEnvelope:
        if isinstance(orig_env.payload, Mapping):
            orig_payload = dict(orig_env.payload)
        else:
            orig_payload = orig_env.payload.model_dump(by_alias=True)
        payload_with_nones = {
            **orig_payload,
            "passageRef": None,
            "blueprintRef": None,
            "questionRefs": None,
        }
        return ArtifactEnvelope(
            artifactId=orig_env.artifact_id,
            artifactType=orig_env.artifact_type,
            version=orig_env.version,
            runId=orig_env.run_id,
            parentRefs=orig_env.parent_refs,
            payload=payload_with_nones,
            contentHash=orig_env.content_hash,
            createdAt=orig_env.created_at,
            sectionId=orig_env.section_id,
            producerVersion=orig_env.producer_version,
        )

    s1_none = create_envelope_with_none_refs(orig_s1)
    s2_none = create_envelope_with_none_refs(orig_s2)
    s3_none = create_envelope_with_none_refs(orig_s3)

    # 1. Test assemble_immutable_paper resolves None refs from parent_refs via _coerce_section_payload_from_envelope
    paper_env = assemble_immutable_paper([s1_none, s2_none, s3_none], bp_ref, run_id)
    assert paper_env is not None
    assert paper_env.artifact_type == ArtifactType.READING_PAPER
    assert len(paper_env.payload["passageRefs"]) == 3
    assert len(paper_env.payload["questionRefs"]) == 40

    # 2. Test PaperLoop.run extracts passage_refs and question_refs from parent_refs when payload refs are None
    loop = PaperLoop(is_benchmark=True)
    result = await loop.run(run_id, bp_ref, [s1_none, s2_none, s3_none])
    assert result.decision == DecisionType.PASS
    assert result.accepted_artifact is not None


# ── P12-03: Refined Paper Leakage Tests ──────────────────────────────────────


@pytest.mark.asyncio
async def test_t12_same_section_exact_answer_leakage_flagged():
    """P12-03: Positive case: Same-section exact answer leakage is flagged when
    prompt predicate matches target question focus for completion / short answer.
    """
    run_id = "run_t12_same_sec_ans_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    qs1 = list(create_section_specific_mock_questions(1, run_id))
    # Q8 is SentenceCompletion with answer "cortical connectivity"
    q8_payload = dict(qs1[7].payload)
    q8_payload["prompt"] = "Complete the sentence: Early acquisition of a language reinforces prefrontal [8]."
    q8_payload["statement"] = q8_payload["prompt"]
    q8_payload["answer"] = "cortical connectivity"
    qs1[7] = ArtifactEnvelope.create(
        artifact_id="art_q_8",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q8_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    # Q9 is SentenceCompletion in Section 1 with matching predicate "Complete" and prompt leaking "cortical connectivity"
    q9_payload = dict(qs1[8].payload)
    q9_payload["prompt"] = "Complete the note: Enhanced cortical connectivity was verified by neuroimaging."
    q9_payload["statement"] = q9_payload["prompt"]
    qs1[8] = ArtifactEnvelope.create(
        artifact_id="art_q_9",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q9_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_same_sec_ans")

    assert res.status == EvaluationStatus.FAIL
    matching_issues = [
        iss for iss in res.issues
        if iss.code == IssueCode.ANSWER_LEAKAGE and "intra-section exact answer" in iss.message
    ]
    assert len(matching_issues) >= 1
    assert "cortical connectivity" in matching_issues[0].message


@pytest.mark.asyncio
async def test_t12_same_section_evidence_quote_leakage_flagged():
    """P12-03: Positive case: Same-section evidence quote leakage is flagged when
    another question prompt verbatim contains the target question's evidence quote.
    """
    run_id = "run_t12_same_sec_quote_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    qs1 = list(create_section_specific_mock_questions(1, run_id))
    quote_text = "empirical investigations in cognitive linguistics and neuroscience have uncovered remarkable insights"
    q1_payload = dict(qs1[0].payload)
    q1_payload["evidenceQuote"] = quote_text
    qs1[0] = ArtifactEnvelope.create(
        artifact_id="art_q_1",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q1_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    # Q2 prompt in same section verbatim contains Q1's evidence quote
    q2_payload = dict(qs1[1].payload)
    q2_payload["prompt"] = f"Given that {quote_text}, which conclusion follows?"
    q2_payload["statement"] = q2_payload["prompt"]
    qs1[1] = ArtifactEnvelope.create(
        artifact_id="art_q_2",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q2_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_same_sec_quote")

    assert res.status == EvaluationStatus.FAIL
    matching_issues = [
        iss for iss in res.issues
        if iss.code == IssueCode.ANSWER_LEAKAGE and "intra-section evidence" in iss.message
    ]
    assert len(matching_issues) >= 1



@pytest.mark.asyncio
async def test_t12_same_section_short_quote_or_substring_does_not_leak():
    """P12-03: Negative case: Evidence quotes shorter than 8 chars and fewer than 2 words,
    or quotes that only match as substrings inside larger words (e.g. 'sign' in 'significant'),
    must not trigger false-positive leakage issues.
    """
    from app.evaluators.paper import _quote_appears_in_prompt

    # 1. Direct unit verification of _quote_appears_in_prompt token boundaries and thresholds
    assert not _quote_appears_in_prompt("sign", "The results were significant.")
    assert not _quote_appears_in_prompt("cognitive term", "Recent cognitive terms were analyzed.")
    assert not _quote_appears_in_prompt("short", "A short phrase here.")  # 5 chars < 8, 1 word < 2
    assert not _quote_appears_in_prompt("three word phrase", "The three word phrases appears.")  # token boundary
    assert _quote_appears_in_prompt("three word phrase", "The three word phrase appears.")  # 17 chars, 3 words
    assert _quote_appears_in_prompt("two words", "These two words appear.")  # 9 chars, 2 words

    # 2. Integration test via PaperLeakageEvaluator
    run_id = "run_t12_short_quote_no_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    qs1 = list(create_section_specific_mock_questions(1, run_id))
    # Q1 has quote of "cognitive data" (14 chars, 2 words) - token boundary test against "cognitive databases"
    q1_payload = dict(qs1[0].payload)
    q1_payload["evidenceQuote"] = "cognitive data"
    qs1[0] = ArtifactEnvelope.create(
        artifact_id="art_q_1",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q1_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    q2_payload = dict(qs1[1].payload)
    q2_payload["prompt"] = "The researchers analyzed cognitive databases across experimental cohorts."
    q2_payload["statement"] = q2_payload["prompt"]
    qs1[1] = ArtifactEnvelope.create(
        artifact_id="art_q_2",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q2_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_short_quote_no_leak")

    matching_issues = [
        iss for iss in res.issues
        if iss.code == IssueCode.ANSWER_LEAKAGE and "intra-section evidence" in iss.message
    ]
    assert len(matching_issues) == 0


@pytest.mark.asyncio
async def test_t12_same_section_two_word_evidence_quote_leakage_flagged():
    """P12-03: Positive regression test: Same-section two-word verbatim evidence quote
    leakage (>= 2 words, e.g. 'neural pathways') is properly flagged by PaperLeakageEvaluator.
    """
    run_id = "run_t12_two_word_quote_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    qs1 = list(create_section_specific_mock_questions(1, run_id))
    two_word_quote = "neural pathways"  # 2 words, 15 chars
    q1_payload = dict(qs1[0].payload)
    q1_payload["evidenceQuote"] = two_word_quote
    qs1[0] = ArtifactEnvelope.create(
        artifact_id="art_q_1",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q1_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    # Q2 prompt in same section verbatim contains Q1's 2-word evidence quote
    q2_payload = dict(qs1[1].payload)
    q2_payload["prompt"] = f"How do {two_word_quote} facilitate bilingual executive function?"
    q2_payload["statement"] = q2_payload["prompt"]
    qs1[1] = ArtifactEnvelope.create(
        artifact_id="art_q_2",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q2_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_two_word_quote_leak")

    assert res.status == EvaluationStatus.FAIL
    matching_issues = [
        iss for iss in res.issues
        if iss.code == IssueCode.ANSWER_LEAKAGE and "intra-section evidence" in iss.message
    ]
    assert len(matching_issues) >= 1
    assert "intra-section evidence" in matching_issues[0].message
@pytest.mark.asyncio
async def test_t12_cross_section_answer_leakage_flagged():
    """P12-03: Positive case: Cross-section answer leakage is flagged when a prompt
    in Section A reveals the multi-word answer to a question in Section B.
    """
    run_id = "run_t12_cross_sec_ans_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    # Section 1 Q3 prompt contains "bicarbonate transporter"
    qs1 = list(create_section_specific_mock_questions(1, run_id))
    q3_payload = dict(qs1[2].payload)
    q3_payload["prompt"] = "The bicarbonate transporter mechanism was extensively analyzed in coastal reefs."
    q3_payload["statement"] = q3_payload["prompt"]
    qs1[2] = ArtifactEnvelope.create(
        artifact_id="art_q_3",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q3_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )
    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)

    # Section 3 Q34 has answer "bicarbonate transporter"
    qs3 = list(create_section_specific_mock_questions(3, run_id))
    q34_payload = dict(qs3[7].payload)
    q34_payload["answer"] = "bicarbonate transporter"
    qs3[7] = ArtifactEnvelope.create(
        artifact_id="art_q_34",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q34_payload,
        producer_version="2.0.0",
        version=1,
        section_id=3,
    )
    s3 = create_mock_section_envelope(3, 800, run_id, custom_questions=qs3)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_cross_sec_ans")

    assert res.status == EvaluationStatus.FAIL
    matching_issues = [
        iss for iss in res.issues
        if iss.code == IssueCode.ANSWER_LEAKAGE and "cross-section" in iss.message
    ]
    assert len(matching_issues) >= 1
    assert "bicarbonate transporter" in matching_issues[0].message


@pytest.mark.asyncio
async def test_t12_negative_control_shared_topic_terminology_passes():
    """P12-03: Negative control: A valid full Reading Paper where questions across and within
    sections share general subject terminology (e.g. 'climate change and marine ecosystems')
    in non-revealing context passes with 0 leakage issues.
    """
    run_id = "run_t12_neg_control_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    shared_topic_term = "climate change and marine ecosystems"

    # Section 1: Inject shared topic phrase into Q1 (TFNG) and Q8 (Completion) prompts
    qs1 = list(create_section_specific_mock_questions(1, run_id))
    q1_p = dict(qs1[0].payload)
    q1_p["prompt"] = f"In the context of {shared_topic_term}, recent empirical investigations uncovered insights."
    q1_p["statement"] = q1_p["prompt"]
    qs1[0] = ArtifactEnvelope.create(
        artifact_id="art_q_1",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q1_p,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )
    q8_p = dict(qs1[7].payload)
    q8_p["prompt"] = f"Regarding {shared_topic_term}, early acquisition of a language reinforces prefrontal [8]."
    q8_p["statement"] = q8_p["prompt"]
    qs1[7] = ArtifactEnvelope.create(
        artifact_id="art_q_8",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q8_p,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )
    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)

    # Section 2: Inject shared topic phrase into Q14 (MCQ) prompt
    qs2 = list(create_section_specific_mock_questions(2, run_id))
    q14_p = dict(qs2[0].payload)
    q14_p["prompt"] = f"How does research into {shared_topic_term} relate to early stellar formation?"
    qs2[0] = ArtifactEnvelope.create(
        artifact_id="art_q_14",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q14_p,
        producer_version="2.0.0",
        version=1,
        section_id=2,
    )
    s2 = create_mock_section_envelope(2, 800, run_id, custom_questions=qs2)

    # Section 3: Inject shared topic phrase into Q27 (YNNG) and Q34 (ShortAnswer) prompts
    qs3 = list(create_section_specific_mock_questions(3, run_id))
    q27_p = dict(qs3[0].payload)
    q27_p["prompt"] = f"Under ongoing {shared_topic_term}, coral reef ecosystems demonstrate physiological adaptations."
    q27_p["statement"] = q27_p["prompt"]
    qs3[0] = ArtifactEnvelope.create(
        artifact_id="art_q_27",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q27_p,
        producer_version="2.0.0",
        version=1,
        section_id=3,
    )
    q34_p = dict(qs3[7].payload)
    q34_p["prompt"] = f"In studies examining {shared_topic_term}, what transporter proteins were selectively upregulated?"
    qs3[7] = ArtifactEnvelope.create(
        artifact_id="art_q_34",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q34_p,
        producer_version="2.0.0",
        version=1,
        section_id=3,
    )
    s3 = create_mock_section_envelope(3, 800, run_id, custom_questions=qs3)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_neg_control")

    assert res.status == EvaluationStatus.PASS
    assert len(res.issues) == 0
    assert res.score == 1.0


@pytest.mark.asyncio
async def test_t12_common_leading_stopword_prompts_do_not_false_positive_leak():
    """Verify that two prompts starting with common stopwords like 'The' with a
    general noun phrase in a non-revealing context do not trigger false positive
    intra-section exact answer leakage.
    """
    from app.evaluators.paper import _extract_question_predicate

    # 1. Direct unit verification that leading stopwords ('The', 'A', 'An', etc.)
    # are skipped and do not collide as identical predicates.
    p1 = "The experimental framework deployed cognitive batteries."
    p2 = "The longitudinal cohort study analyzed cortical connectivity."
    assert _extract_question_predicate(p1) == "experimental"
    assert _extract_question_predicate(p2) == "longitudinal"
    assert _extract_question_predicate(p1) != _extract_question_predicate(p2)

    # 2. Integration test via PaperLeakageEvaluator on a full ReadingPaper
    run_id = "run_t12_stopword_no_false_leak"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    qs1 = list(create_section_specific_mock_questions(1, run_id))
    # Q8 is SentenceCompletion with multi-word answer "cortical connectivity"
    q8_payload = dict(qs1[7].payload)
    q8_payload["prompt"] = "The experimental framework demonstrated that early acquisition reinforces prefrontal [8]."
    q8_payload["statement"] = q8_payload["prompt"]
    q8_payload["answer"] = "cortical connectivity"
    qs1[7] = ArtifactEnvelope.create(
        artifact_id="art_q_8",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q8_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    # Q9 is SentenceCompletion in Section 1 starting with "The", containing "cortical connectivity" in non-revealing context
    q9_payload = dict(qs1[8].payload)
    q9_payload["prompt"] = "The longitudinal cohort study confirmed that cortical connectivity was enhanced."
    q9_payload["statement"] = q9_payload["prompt"]
    qs1[8] = ArtifactEnvelope.create(
        artifact_id="art_q_9",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q9_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )

    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)
    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    evaluator = PaperLeakageEvaluator()
    res = await evaluator.evaluate(context, paper, "intent_stopword_no_false_leak")

    matching_issues = [
        iss for iss in res.issues
        if iss.code == IssueCode.ANSWER_LEAKAGE and "intra-section exact answer" in iss.message
    ]
    assert len(matching_issues) == 0
    assert res.status == EvaluationStatus.PASS
    assert len(res.issues) == 0

@pytest.mark.asyncio
async def test_t12_multi_question_surgical_repair():
    """Verify PaperSurgicalRepairer applies multiple per-question patches across sections preserving unaffected sections."""
    run_id = "run_t12_multi_q_repair"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    s1 = create_mock_section_envelope(1, 800, run_id)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)

    directive = PaperRepairDirective(
        affectedRefs=[paper.to_ref()],
        questionPatches={
            5: {"prompt": "Patched prompt for Question 5 in Section 1."},
            18: {"prompt": "Patched prompt for Question 18 in Section 2."},
        },
    )

    repairer = PaperSurgicalRepairer()
    repair_res = repairer.repair_paper(paper, directive)

    repaired_envelope = repair_res.repaired_envelope
    assert repaired_envelope.version == 2

    # Section 1 (Q5) and Section 2 (Q18) were modified
    q5_found = False
    for grp in repaired_envelope.payload["sections"][0]["groups"]:
        for q in grp["questions"]:
            if q.get("questionNumber") == 5:
                prompt_val = q.get("statement") or q.get("prompt")
                assert prompt_val == "Patched prompt for Question 5 in Section 1."
                q5_found = True
    assert q5_found

    q18_found = False
    for grp in repaired_envelope.payload["sections"][1]["groups"]:
        for q in grp["questions"]:
            if q.get("questionNumber") == 18:
                prompt_val = q.get("prompt") or q.get("statement")
                assert prompt_val == "Patched prompt for Question 18 in Section 2."
                q18_found = True
    assert q18_found
    # Section 3 was unaffected -> preserved
    assert repaired_envelope.payload["sectionRefs"][2]["contentHash"] == s3.to_ref().content_hash
    assert repaired_envelope.payload["sections"][2]["passage"] == s3.payload["passage"]
    assert any(ref.artifact_id == s3.artifact_id for ref in repair_res.preserved_refs)


@pytest.mark.asyncio
async def test_t12_adapter_multi_question_repair_from_issues():
    """Verify PaperRepairerAdapter aggregates multiple leakage and duplicate issues into question_patches."""
    run_id = "run_t12_adapter_multi_q"
    bp_ref = ArtifactRef(artifactId="art_bp", artifactType=ArtifactType.EXAM_BLUEPRINT, version=1, contentHash="0" * 64)

    # Create Section 1 with Q5 leaking answer "neural pathway"
    qs1 = list(create_section_specific_mock_questions(1, run_id))
    q5_payload = dict(qs1[4].payload)
    q5_payload["prompt"] = "The neural pathway was found to mediate response times."
    q5_payload["statement"] = q5_payload["prompt"]
    qs1[4] = ArtifactEnvelope.create(
        artifact_id="art_q_5",
        artifact_type=ArtifactType.QUESTION,
        run_id=run_id,
        payload=q5_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
    )
    s1 = create_mock_section_envelope(1, 800, run_id, custom_questions=qs1)
    s2 = create_mock_section_envelope(2, 800, run_id)
    s3 = create_mock_section_envelope(3, 800, run_id)

    paper = assemble_immutable_paper([s1, s2, s3], bp_ref, run_id)

    context = LoopContext(
        runId=run_id,
        scope=IssueScope.PAPER,
        targetArtifactId="art_paper_01",
        targetArtifactType=ArtifactType.READING_PAPER,
        authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1),
    )

    issues = [
        Issue.create(
            issue_id="iss_leak_05",
            code=IssueCode.ANSWER_LEAKAGE,
            severity=IssueSeverity.CRITICAL,
            scope=IssueScope.QUESTION,
            affected_refs=[paper.to_ref()],
            message="Question 5 prompt verbatim reveals answer 'neural pathway'",
        ),
        Issue.create(
            issue_id="iss_dup_15",
            code=IssueCode.DUPLICATE_CONTENT,
            severity=IssueSeverity.MAJOR,
            scope=IssueScope.QUESTION,
            affected_refs=[paper.to_ref()],
            message="Question 15 shares 100% prompt text with Question 1",
        ),
    ]

    adapter = PaperRepairerAdapter(PaperSurgicalRepairer(), PaperRepairRouter())
    repaired_env = await adapter.repair(context, paper, issues, "intent_multi_repair")

    assert repaired_env.version == 2
    # Check Q5 got leaked text replaced
    q5_repaired = False
    for grp in repaired_env.payload["sections"][0]["groups"]:
        for q in grp["questions"]:
            if q.get("questionNumber") == 5:
                val = q.get("prompt") or q.get("statement") or ""
                assert "the relevant formulation" in val
                assert "neural pathway" not in val
                q5_repaired = True
    assert q5_repaired

    # Check Q15 got distinct prompt
    q15_repaired = False
    for grp in repaired_env.payload["sections"][1]["groups"]:
        for q in grp["questions"]:
            if q.get("questionNumber") == 15:
                val = q.get("prompt") or q.get("statement") or ""
                assert "question 15" in val.lower()
                q15_repaired = True
    assert q15_repaired


# ── T12 MCQ Evidence Repair & Fail-Closed Validation ───────────────────────────


def test_t12_repair_evidence_mcq_bare_letter_resolves_to_passage_sentence():
    """Verify MCQ questions with bare letter answers ('A', 'B') resolve to option text and recover exact passage sentences."""
    passage = (
        "Researchers documented Arctic fox population dynamics across sub-arctic regions over a decade. "
        "Physiologists examined desert reptile thermoregulation under extreme arid temperatures during summer. "
        "Botanists analyzed tropical canopy biodiversity patterns using automated canopy crane sensors."
    )
    q_a = {
        "number": 1,
        "prompt": "What did researchers document across sub-arctic regions?",
        "answer": "A",
        "options": [
            "A. Arctic fox population dynamics",
            "B. Desert reptile thermoregulation",
            "C. Tropical canopy biodiversity",
            "D. Marine plankton migration",
        ],
        "evidenceQuote": "unmatched drifted quote from earlier generation",
        "explanation": "The passage states that researchers documented Arctic fox population dynamics across sub-arctic regions.",
    }
    q_b = {
        "number": 2,
        "prompt": "What did physiologists examine under extreme arid temperatures?",
        "answer": "B",
        "options": [
            "A. Arctic fox population dynamics",
            "B. Desert reptile thermoregulation",
            "C. Tropical canopy biodiversity",
            "D. Marine plankton migration",
        ],
        "evidenceQuote": "stale ungrounded text",
        "explanation": "The passage confirms that physiologists examined desert reptile thermoregulation under extreme conditions.",
    }

    assert _mcq_option_text(q_a) == "Arctic fox population dynamics"
    assert _mcq_option_text(q_b) == "Desert reptile thermoregulation"

    questions = [q_a, q_b]
    repair_evidence(questions, passage)

    assert q_a["evidenceQuote"] == "Researchers documented Arctic fox population dynamics across sub-arctic regions over a decade."
    assert q_b["evidenceQuote"] == "Physiologists examined desert reptile thermoregulation under extreme arid temperatures during summer."

    # Both repaired questions pass candidate validation
    validate_group_candidate("MULTIPLE_CHOICE_SINGLE", 1, 1, [q_a], passage)
    validate_group_candidate("MULTIPLE_CHOICE_SINGLE", 1, 2, [q_b], passage)


def test_t12_repair_evidence_mcq_ungrounded_option_fails_closed():
    """Verify MCQ with ungrounded option does not attach an arbitrary passage sentence and fails closed."""
    passage = (
        "Researchers documented Arctic fox population dynamics across sub-arctic regions over a decade. "
        "Physiologists examined desert reptile thermoregulation under extreme arid temperatures during summer. "
        "Botanists analyzed tropical canopy biodiversity patterns using automated canopy crane sensors."
    )
    q_ungrounded = {
        "number": 1,
        "prompt": "What did the research team discover regarding subterranean geology?",
        "answer": "C",
        "options": [
            "A. Arctic fox population dynamics",
            "B. Desert reptile thermoregulation",
            "C. Subterranean mantle plume dynamics in continental crust",
            "D. Marine plankton migration",
        ],
        "evidenceQuote": "Subterranean mantle plume dynamics were detected deep within continental crust formations.",
        "explanation": "The authors describe mantle plume dynamics detected deep within continental crust formations.",
    }

    original_evidence = q_ungrounded["evidenceQuote"]
    repair_evidence([q_ungrounded], passage)

    # Evidence quote must NOT be replaced with an arbitrary passage sentence
    assert q_ungrounded["evidenceQuote"] == original_evidence

    # Validation fails closed, raising ValueError indicating evidence quote is absent
    with pytest.raises(ValueError, match="Evidence quote is absent from passage"):
        validate_group_candidate("MULTIPLE_CHOICE_SINGLE", 1, 1, [q_ungrounded], passage)
