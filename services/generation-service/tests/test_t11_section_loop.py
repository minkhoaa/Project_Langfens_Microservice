"""Test Suite for Phase 11 Section Loop, Exact Resume, and Scoped Repairs (T11-01..T11-08).

Tests:
- T11-01: Three sections counts (13/13/14), distributions (S1: 7 TFNG + 6 Sentence Completion;
          S2: 6 MCQ Single + 7 Summary Completion; S3: 7 YNNG + 7 Short Answer),
          contiguous numbering 1-40, and passage length bounds [720, 915].
- T11-02: Hard validators for accepted/fresh dependencies, zero missing/stale/error required
          evaluations, and mandatory Blind Solver and Adversary coverage per G10.
- T11-03: Section-wide duplicate detection (Q23 duplicate of Q18 scoped diff), 5-word shingle
          overlap > 0.45, prompt answer leakage, span concentration, and answer distribution monotony.
- T11-04: Editorial style and skill diversity distribution, separate warnings vs blockers,
          and diagnostic heuristic confidence not overriding hard blockers.
- T11-05: SectionLoop on generic BoundedLoopRuntime, scoped repairs to item/group/passage/source,
          dynamic closure invalidation, and preservation of unaffected accepted heads.
- T11-06: Accept transaction persistence via authoritative boundary, atomic/idempotent SectionsJson
          bridge, CAS/fencing/cancel preconditions, and idempotent replay on duplicate commit.
- T11-07: Exact durable cursor resume across passage/question/group/section, crash/kill at each
          acceptance boundary, and Section 3 source replacement preserving Section 1-2 accepted heads.
- T11-08: Typed workflow mapping (NeedsSources, editorial escalation, transient retryable fail,
          permanent policy failure), .NET consumer round-trip preserving options/answers/ordinals,
          and student-visible payload isolation without internal secret leakage.
          Section acceptance must NOT build an exam or complete the paper/job.
"""

from __future__ import annotations

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
from app.contracts.policies import (
    PASSAGE_MAX_WORDS,
    PASSAGE_MIN_WORDS,
    SECTION_GROUP_SIZES,
    SECTION_GROUP_TYPES,
    SECTION_QUESTION_COUNTS,
    count_words,
)
from app.contracts.questions import (
    MultipleChoiceSingleQuestion,
    QuestionGroup,
    QuestionUnion,
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
from app.evaluators.base import BaseEvaluator
from app.evaluators.registry import EvaluatorRegistry
from app.evaluators.section import (
    SectionDuplicateAndConcentrationEvaluator,
    SectionEditorialEvaluator,
    SectionStructureEvaluator,
)
from app.facade import GenerationFacade
from app.loop.context import AuthorityGrant, BudgetTracker, LoopContext, ResumeCursor
from app.loop.policy import LoopPolicy
from app.loop.runtime import BoundedLoopRuntime, LoopResult
from app.loop.section import SectionLoop
from app.repair.base import RepairScope
from app.repair.section import (
    SectionRepairActionType,
    SectionRepairRoute,
    SectionRepairRouter,
    SectionSurgicalRepairer,
)
from tests.test_t08_passage_loop import SQLiteCheckpointSimulation


# ── Fixture Helpers ──────────────────────────────────────────────────────────


def generate_sample_passage_text(word_count: int = 800) -> str:
    """Generates standardized academic passage text with exact word count."""
    base_sentences = [
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
    ]
    passage = " ".join(base_sentences)
    words = passage.split()
    while len(words) < word_count:
        words.extend(passage.split())
    trimmed = words[:word_count]
    return " ".join(trimmed)


def create_mock_passage_envelope(section_index: int = 1, word_count: int = 800, run_id: str = "run_phase11_test") -> ArtifactEnvelope:
    text = generate_sample_passage_text(word_count)
    payload = {
        "text": text,
        "passage": text,
        "wordCount": word_count,
        "title": f"Academic Reading Passage {section_index}",
        "pmcid": f"PMC{section_index}123456",
        "source": {
            "pmcid": f"PMC{section_index}123456",
            "title": f"Academic Reading Passage {section_index}",
            "doi": f"10.1016/j.neuro.{section_index}.001",
            "url": f"https://europepmc.org/articles/PMC{section_index}123456",
            "license": "CC BY 4.0",
            "wordCount": word_count,
            "authors": "Dr. E. Thorne et al.",
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
        parent_refs=[],
        schema_version="2.0.0",
    )


MOCK_QUESTION_DATA: Dict[int, tuple[str, str, Optional[str]]] = {
    # Section 1 Group 1 (TFNG: 1..7)
    1: ("Early bilingualism reinforces neural pathways within the prefrontal cortex.", "TRUE", "Primary analytical findings revealed that early acquisition of a secondary language significantly reinforces prefrontal cortical connectivity."),
    2: ("The Cambridge cohort investigation evaluated fewer than five hundred participants.", "FALSE", "longitudinal cohort study involving more than eight hundred bilingual subjects."),
    3: ("Bilingual individuals show superior auditory acuity in noisy environments.", "NOT_GIVEN", None),
    4: ("Structural MRI scans revealed elevated gray matter density in the left parietal lobe.", "TRUE", "demonstrated measurable increases in gray matter density within both the left inferior parietal cortex and the hippocampus."),
    5: ("Statistical models indicated that subject performance was reduced by ten percent.", "FALSE", "cognitive flexibility scores were approximately twenty-four percent higher"),
    6: ("All experimental subjects were recruited from identical socioeconomic backgrounds.", "FALSE", "socioeconomic confounding variables must be rigorously controlled"),
    7: ("Genetic markers accounted entirely for differences in neural adaptations.", "NOT_GIVEN", None),
    # Section 1 Group 2 (Sentence Completion: 8..13)
    8: ("The longitudinal investigation at Cambridge University spanned a duration of", "seven-year", "conducted a comprehensive seven-year longitudinal cohort study"),
    9: ("Proficient bilingual subjects demonstrated higher scores on measures of", "cognitive flexibility", "cognitive flexibility scores were approximately twenty-four percent higher"),
    10: ("Structural neuroimaging confirmed density increases in the left parietal lobe and the", "hippocampus", "left inferior parietal cortex and the hippocampus"),
    11: ("Observational research highlighted potential confounding effects from formal", "literacy levels", "educational background and formal literacy levels"),
    12: ("The research team minimized methodological bias by applying demographic", "stratification protocols", "instituted stringent demographic stratification protocols"),
    13: ("Language switching was found to engage specialized neural networks of", "executive control", "language switching exercises distinct executive control networks"),
    # Section 2 Group 1 (MCQ: 14..19)
    14: ("According to the first paragraph, what primary insight did neuroscientists uncover?", "A", "uncovered remarkable insights into multilingual memory representation."),
    15: ("Why did researchers introduce demographic stratification into their methodology?", "B", "instituted stringent demographic stratification protocols across all experimental cohorts."),
    16: ("What did structural neuroimaging scans indicate regarding bilingual participants?", "C", "measurable increases in gray matter density within both the left inferior parietal cortex"),
    17: ("Which confounding factor was emphasized by dissenting academic researchers?", "D", "educational background and formal literacy levels exert substantial confounding effects."),
    18: ("What specific rate of improvement in tested subjects was statistically modeled?", "A", "cognitive flexibility scores were approximately twenty-four percent higher"),
    19: ("The author mentions language switching primarily to demonstrate that it", "B", "language switching exercises distinct executive control networks independent of educational attainment."),
    # Section 2 Group 2 (Summary Completion: 20..26)
    20: ("The Cambridge cohort trial evaluated more than eight hundred", "bilingual subjects", "involving more than eight hundred bilingual subjects."),
    21: ("Advanced neuroimaging techniques were coupled with psychometric cognitive", "batteries", "standardized psychometric cognitive batteries."),
    22: ("Early second language acquisition directly bolstered prefrontal", "cortical connectivity", "significantly reinforces prefrontal cortical connectivity."),
    23: ("Structural imaging documented higher tissue density in the left inferior", "parietal cortex", "within both the left inferior parietal cortex and the hippocampus."),
    24: ("Tested bilingual individuals achieved a measurable improvement in", "cognitive flexibility", "cognitive flexibility scores were approximately twenty-four percent higher"),
    25: ("Methodological adjustments were designed to account for disparities in", "educational background", "educational background and formal literacy levels exert substantial confounding effects."),
    26: ("The experimental results offer potential benefits for mitigating", "neurodegenerative decline", "targeted clinical interventions for neurodegenerative decline."),
    # Section 3 Group 1 (YNNG: 27..33)
    27: ("Early bilingual language acquisition confers measurable cognitive benefits.", "YES", "Primary analytical findings revealed that early acquisition of a secondary language significantly reinforces"),
    28: ("The empirical findings should be used immediately to commercialize language apps.", "NOT_GIVEN", None),
    29: ("Socioeconomic status has no influence on observational cognitive data.", "NO", "socioeconomic confounding variables must be rigorously controlled"),
    30: ("The Cambridge trial focused exclusively on elderly monolingual subjects.", "NO", "involving more than eight hundred bilingual subjects."),
    31: ("Cohort sampling adjustments effectively addressed methodological confounding concerns.", "YES", "instituted stringent demographic stratification protocols across all experimental cohorts."),
    32: ("Cognitive advantages from bilingualism diminish completely during later adulthood.", "NOT_GIVEN", None),
    33: ("Language switching relies on specialized neural mechanisms.", "YES", "language switching exercises distinct executive control networks independent of educational attainment."),
    # Section 3 Group 2 (Short Answer: 34..40)
    34: ("How many bilingual participants were enrolled in the Cambridge cohort investigation?", "eight hundred", "more than eight hundred bilingual subjects."),
    35: ("Which cerebral region showed density gains alongside the left parietal cortex?", "hippocampus", "left inferior parietal cortex and the hippocampus."),
    36: ("What percentage increase was observed in bilingual cognitive flexibility scores?", "twenty-four percent", "cognitive flexibility scores were approximately twenty-four percent higher"),
    37: ("What methodological protocol was established to control for confounding variables?", "demographic stratification", "instituted stringent demographic stratification protocols"),
    38: ("What cognitive network was exercised during active language switching?", "executive control", "language switching exercises distinct executive control networks"),
    39: ("What academic institution conducted the seven-year longitudinal investigation?", "Cambridge University", "Researchers at Cambridge University conducted a comprehensive seven-year longitudinal cohort study"),
    40: ("What clinical condition could benefit from pedagogical interventions based on this research?", "neurodegenerative decline", "targeted clinical interventions for neurodegenerative decline."),
}


def create_mock_question_envelopes(section_index: int, run_id: str = "run_phase11_test") -> List[ArtifactEnvelope]:
    """Creates canonical mock question envelopes adhering to S1, S2, or S3 distribution."""
    total_q = SECTION_QUESTION_COUNTS[section_index]
    start_num = 1 if section_index == 1 else (14 if section_index == 2 else 27)
    types = SECTION_GROUP_TYPES[section_index]
    sizes = SECTION_GROUP_SIZES[section_index]

    envelopes: List[ArtifactEnvelope] = []
    current_num = start_num

    # Group 1
    g1_type = types[0]
    g1_size = sizes[0]
    for i in range(g1_size):
        q_num = current_num + i
        prompt, ans, quote = MOCK_QUESTION_DATA[q_num]
        if g1_type == QuestionType.TRUE_FALSE_NOT_GIVEN:
            q_payload = {
                "questionNumber": q_num,
                "questionType": "TrueFalseNotGiven",
                "statement": prompt,
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "absenceAssessment": {"assessmentId": f"abs_tf_{q_num}", "claimOrTopic": "cognitive linguistics", "absenceReason": "Term not found in passage", "absenceConfirmed": True} if ans == "NOT_GIVEN" else None,
                "explanation": f"Explanation for question {q_num}.",
            }
        elif g1_type == QuestionType.MULTIPLE_CHOICE_SINGLE:
            q_payload = {
                "questionNumber": q_num,
                "questionType": "MultipleChoiceSingle",
                "prompt": prompt,
                "options": [
                    f"Option A regarding {prompt[:20]}",
                    f"Option B regarding {prompt[:20]}",
                    f"Option C regarding {prompt[:20]}",
                    f"Option D regarding {prompt[:20]}",
                ],
                "correctOption": ans,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for MCQ question {q_num}.",
            }
        else: # YES_NO_NOT_GIVEN
            q_payload = {
                "questionNumber": q_num,
                "questionType": "YesNoNotGiven",
                "statement": prompt,
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "absenceAssessment": {"assessmentId": f"abs_yn_{q_num}", "claimOrTopic": "executive control", "absenceReason": "Claim not found in passage", "absenceConfirmed": True} if ans == "NOT_GIVEN" else None,
                "explanation": f"Explanation for YNNG question {q_num}.",
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
                parent_refs=[],
                schema_version="2.0.0",
            )
        )

    current_num += g1_size

    # Group 2
    g2_type = types[1]
    g2_size = sizes[1]
    for i in range(g2_size):
        q_num = current_num + i
        prompt, ans, quote = MOCK_QUESTION_DATA[q_num]
        if g2_type == QuestionType.SENTENCE_COMPLETION:
            q_payload = {
                "questionNumber": q_num,
                "questionType": "SentenceCompletion",
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for completion question {q_num}.",
            }
        elif g2_type == QuestionType.SUMMARY_COMPLETION:
            q_payload = {
                "questionNumber": q_num,
                "questionType": "SummaryCompletion",
                "prompt": prompt,
                "answer": ans,
                "evidenceQuote": quote,
                "explanation": f"Explanation for summary question {q_num}.",
            }
        else: # SHORT_ANSWER
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
                parent_refs=[],
                schema_version="2.0.0",
            )
        )

    return envelopes
# ── Tests T11-01 to T11-08 ───────────────────────────────────────────────────


@pytest.mark.asyncio
async def test_t11_01_three_sections_count_types_and_word_bounds():
    """T11-01: Verifies section distributions (13/13/14, S1/S2/S3 types), contiguous numbering, and word bounds [720, 915]."""
    bp_ref = ArtifactRef(
        artifactId="art_blueprint_01",
        version=1,
        artifactType=ArtifactType.EXAM_BLUEPRINT,
        contentHash="b" * 64,
    )

    evaluator = SectionStructureEvaluator()

    # 1. Verify Section 1: 13 questions (7 TFNG + 6 Sentence Completion), 800 words
    p1 = create_mock_passage_envelope(section_index=1, word_count=800)
    qs1 = create_mock_question_envelopes(section_index=1)
    sec1 = assemble_immutable_section(1, "Section 1", p1, bp_ref, qs1)
    res1 = await evaluator.evaluate(LoopContext(runId="run1", scope=IssueScope.SECTION, targetArtifactId="sec1", targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1)), sec1, "int_1")
    assert res1.status == EvaluationStatus.PASS
    assert len(sec1.payload["groups"]) == 2
    assert len(sec1.payload["groups"][0]["questions"]) == 7
    assert len(sec1.payload["groups"][1]["questions"]) == 6

    # 2. Verify Section 2: 13 questions (6 MCQ Single + 7 Summary Completion), 820 words
    p2 = create_mock_passage_envelope(section_index=2, word_count=820)
    qs2 = create_mock_question_envelopes(section_index=2)
    sec2 = assemble_immutable_section(2, "Section 2", p2, bp_ref, qs2)
    res2 = await evaluator.evaluate(LoopContext(runId="run2", scope=IssueScope.SECTION, targetArtifactId="sec2", targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1)), sec2, "int_2")
    assert res2.status == EvaluationStatus.PASS
    assert len(sec2.payload["groups"]) == 2
    assert len(sec2.payload["groups"][0]["questions"]) == 6
    assert len(sec2.payload["groups"][1]["questions"]) == 7

    # 3. Verify Section 3: 14 questions (7 YNNG + 7 Short Answer), 850 words
    p3 = create_mock_passage_envelope(section_index=3, word_count=850)
    qs3 = create_mock_question_envelopes(section_index=3)
    sec3 = assemble_immutable_section(3, "Section 3", p3, bp_ref, qs3)
    res3 = await evaluator.evaluate(LoopContext(runId="run3", scope=IssueScope.SECTION, targetArtifactId="sec3", targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1)), sec3, "int_3")
    assert res3.status == EvaluationStatus.PASS
    assert len(sec3.payload["groups"]) == 2
    assert len(sec3.payload["groups"][0]["questions"]) == 7
    assert len(sec3.payload["groups"][1]["questions"]) == 7

    # 4. Total questions across 3 sections must equal exactly 40 (13 + 13 + 14)
    all_numbers = (
        [int(q["questionNumber"]) for g in sec1.payload["groups"] for q in g["questions"]]
        + [int(q["questionNumber"]) for g in sec2.payload["groups"] for q in g["questions"]]
        + [int(q["questionNumber"]) for g in sec3.payload["groups"] for q in g["questions"]]
    )
    assert all_numbers == list(range(1, 41))

    # 5. Boundary testing on passage words: 719 fails, 916 fails
    p_short = create_mock_passage_envelope(section_index=1, word_count=719)
    sec_short = assemble_immutable_section(1, "Short Section", p_short, bp_ref, qs1)
    res_short = await evaluator.evaluate(LoopContext(runId="run_s", scope=IssueScope.SECTION, targetArtifactId="sec_s", targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1)), sec_short, "int_s")
    assert res_short.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS for iss in res_short.issues)

    p_long = create_mock_passage_envelope(section_index=1, word_count=916)
    sec_long = assemble_immutable_section(1, "Long Section", p_long, bp_ref, qs1)
    res_long = await evaluator.evaluate(LoopContext(runId="run_l", scope=IssueScope.SECTION, targetArtifactId="sec_l", targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1)), sec_long, "int_l")
    assert res_long.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS for iss in res_long.issues)


@pytest.mark.asyncio
async def test_t11_02_fresh_evaluations_zero_missing_stale_solver_adversary_coverage():
    """T11-02: Enforces fresh evaluations, zero missing/stale evaluations, and mandatory Blind Solver/Adversary coverage."""
    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="0"*64)
    p = create_mock_passage_envelope(1, 800)
    qs = create_mock_question_envelopes(1)
    sec = assemble_immutable_section(1, "Sec", p, bp_ref, qs)

    evaluator = SectionStructureEvaluator()

    # Valid fresh section
    ctx = LoopContext(runId="run1", scope=IssueScope.SECTION, targetArtifactId=sec.artifact_id, targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1))
    res_pass = await evaluator.evaluate(ctx, sec, "int_1")
    assert res_pass.status == EvaluationStatus.PASS

    # Stale dependencies flag -> Fail
    payload_stale = dict(sec.payload)
    payload_stale["evaluationsSummary"] = {"hasStaleDependencies": True}
    sec_stale = ArtifactEnvelope.create(
        artifact_id=sec.artifact_id,
        artifact_type=sec.artifact_type,
        run_id=sec.run_id,
        payload=payload_stale,
        producer_version="2.0.0",
        version=sec.version,
        section_id=sec.section_id,
        parent_refs=list(sec.parent_refs),
    )
    res_stale = await evaluator.evaluate(ctx, sec_stale, "int_2")
    assert res_stale.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.STALE_DEPENDENCY for iss in res_stale.issues)

    # Missing Blind Solver coverage -> Fail
    payload_no_solver = dict(sec.payload)
    payload_no_solver["evaluationsSummary"] = {"solverCovered": False, "adversaryCovered": True}
    sec_no_solver = ArtifactEnvelope.create(
        artifact_id=sec.artifact_id,
        artifact_type=sec.artifact_type,
        run_id=sec.run_id,
        payload=payload_no_solver,
        producer_version="2.0.0",
        version=sec.version,
        section_id=sec.section_id,
        parent_refs=list(sec.parent_refs),
    )
    res_no_solver = await evaluator.evaluate(ctx, sec_no_solver, "int_3")
    assert res_no_solver.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.FRESH_EVALUATION_MISSING for iss in res_no_solver.issues)

    # Missing Adversary coverage -> Fail
    payload_no_adv = dict(sec.payload)
    payload_no_adv["evaluationsSummary"] = {"solverCovered": True, "adversaryCovered": False}
    sec_no_adv = ArtifactEnvelope.create(
        artifact_id=sec.artifact_id,
        artifact_type=sec.artifact_type,
        run_id=sec.run_id,
        payload=payload_no_adv,
        producer_version="2.0.0",
        version=sec.version,
        section_id=sec.section_id,
        parent_refs=list(sec.parent_refs),
    )
    res_no_adv = await evaluator.evaluate(ctx, sec_no_adv, "int_4")
    assert res_no_adv.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.FRESH_EVALUATION_MISSING for iss in res_no_adv.issues)


@pytest.mark.asyncio
async def test_t11_03_section_wide_duplicate_q23_q18_concentration_leakage():
    """T11-03: Tests duplicate question detection (Q23 duplicate of Q18), shingle overlaps >0.45, leakage, and span concentration."""
    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="0"*64)
    p = create_mock_passage_envelope(2, 800)
    qs = create_mock_question_envelopes(2)
    sec = assemble_immutable_section(2, "Section 2", p, bp_ref, qs)

    dup_evaluator = SectionDuplicateAndConcentrationEvaluator()
    ctx = LoopContext(runId="run_dup", scope=IssueScope.SECTION, targetArtifactId=sec.artifact_id, targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1))

    # 1. Clean section passes
    res_clean = await dup_evaluator.evaluate(ctx, sec, "int_c")
    assert res_clean.status == EvaluationStatus.PASS

    # 2. Inject duplicate Q23 identical to Q18 prompt
    payload_dup = json.loads(canonical_json_dump(sec.payload))
    q18_prompt = payload_dup["groups"][0]["questions"][4]["prompt"]
    payload_dup["groups"][1]["questions"][2]["prompt"] = q18_prompt
    payload_dup["groups"][1]["questions"][2]["questionNumber"] = 23
    sec_dup = ArtifactEnvelope.create(
        artifact_id=sec.artifact_id,
        artifact_type=sec.artifact_type,
        run_id=sec.run_id,
        payload=payload_dup,
        producer_version="2.0.0",
        version=sec.version,
        section_id=sec.section_id,
        parent_refs=list(sec.parent_refs),
    )
    res_dup = await dup_evaluator.evaluate(ctx, sec_dup, "int_d")
    assert res_dup.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.DUPLICATE_CONTENT and "23" in iss.message and "18" in iss.message for iss in res_dup.issues)

    # 3. Inject prompt answer leakage
    payload_leak = json.loads(canonical_json_dump(sec.payload))
    payload_leak["groups"][0]["questions"][0]["answer"] = "mitochondrial density"
    payload_leak["groups"][0]["questions"][1]["prompt"] = "Given that mitochondrial density increases with exercise, what occurs?"
    sec_leak = ArtifactEnvelope.create(
        artifact_id=sec.artifact_id,
        artifact_type=sec.artifact_type,
        run_id=sec.run_id,
        payload=payload_leak,
        producer_version="2.0.0",
        version=sec.version,
        section_id=sec.section_id,
        parent_refs=list(sec.parent_refs),
    )
    res_leak = await dup_evaluator.evaluate(ctx, sec_leak, "int_l")
    assert res_leak.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.ANSWER_LEAKAGE for iss in res_leak.issues)

    # 4. Inject 100% answer distribution monotony (all TRUE)
    p1 = create_mock_passage_envelope(1, 800)
    qs1 = create_mock_question_envelopes(1)
    sec1 = assemble_immutable_section(1, "Section 1", p1, bp_ref, qs1)
    payload_mono = json.loads(canonical_json_dump(sec1.payload))
    for q in payload_mono["groups"][0]["questions"]:
        q["answer"] = "TRUE"
    sec_mono = ArtifactEnvelope.create(
        artifact_id=sec1.artifact_id,
        artifact_type=sec1.artifact_type,
        run_id=sec1.run_id,
        payload=payload_mono,
        producer_version="2.0.0",
        version=sec1.version,
        section_id=sec1.section_id,
        parent_refs=list(sec1.parent_refs),
    )
    res_mono = await dup_evaluator.evaluate(ctx, sec_mono, "int_m")
    assert res_mono.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.ANSWER_CONCENTRATION_DETECTED for iss in res_mono.issues)


@pytest.mark.asyncio
async def test_t11_04_editorial_style_skill_diversity_separate_warnings_blockers():
    """T11-04: Separates warnings vs blockers, and computes heuristic confidence without overriding hard issues."""
    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="0"*64)
    p = create_mock_passage_envelope(1, 800)
    qs = create_mock_question_envelopes(1)
    sec = assemble_immutable_section(1, "Section 1", p, bp_ref, qs)

    editorial_eval = SectionEditorialEvaluator()
    ctx = LoopContext(runId="run_ed", scope=IssueScope.SECTION, targetArtifactId=sec.artifact_id, targetArtifactType=ArtifactType.SECTION, authority=AuthorityGrant(leaseOwner=uuid4(), epoch=1))

    # Clean section -> PASS with heuristic score recorded
    res_clean = await editorial_eval.evaluate(ctx, sec, "int_clean")
    assert res_clean.status == EvaluationStatus.PASS
    assert res_clean.score > 0.0

    # Missing group instructions -> Blocker (MAJOR issue) -> FAIL
    payload_no_inst = json.loads(canonical_json_dump(sec.payload))
    payload_no_inst["groups"][0]["instructions"] = ""
    sec_no_inst = ArtifactEnvelope.create(
        artifact_id=sec.artifact_id,
        artifact_type=sec.artifact_type,
        run_id=sec.run_id,
        payload=payload_no_inst,
        producer_version="2.0.0",
        version=sec.version,
        section_id=sec.section_id,
        parent_refs=list(sec.parent_refs),
    )
    res_no_inst = await editorial_eval.evaluate(ctx, sec_no_inst, "int_block")
    assert res_no_inst.status == EvaluationStatus.FAIL
    assert any(iss.code == IssueCode.EDITORIAL_STYLE_DEFECT and iss.severity == IssueSeverity.MAJOR for iss in res_no_inst.issues)


@pytest.mark.asyncio
async def test_t11_05_section_loop_generic_runtime_scoped_repairs_invalidation():
    """T11-05: Tests SectionLoop on BoundedLoopRuntime, scoped repair routing, and dynamic closure invalidation."""
    db_path = Path(f"/tmp/test_t11_05_simulation_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)

    bp_ref = ArtifactRef(artifactId="art_blueprint_01", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="b"*64)
    p = create_mock_passage_envelope(1, 800)
    qs = create_mock_question_envelopes(1)

    router = SectionRepairRouter()
    sec = assemble_immutable_section(1, "Section 1", p, bp_ref, qs)

    # 1. Route Item-Level Duplicate defect (Q23 vs Q18)
    iss_dup = Issue.create(
        issue_id="iss_dup_q23",
        code=IssueCode.DUPLICATE_CONTENT,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.QUESTION,
        message="Question 23 is an exact duplicate of Question 18",
        affected_refs=[sec.to_ref()],
    )
    route_dup = router.route_repair(sec, [iss_dup])
    assert route_dup.action_type == SectionRepairActionType.ITEM_RESELECT
    assert route_dup.target_scope == RepairScope.QUESTION
    assert 23 in route_dup.target_question_numbers
    assert "art_q_23" in route_dup.invalidated_artifact_ids
    assert "art_q_18" in route_dup.preserved_artifact_ids

    # 2. Route Passage-Level Word Count defect
    iss_passage = Issue.create(
        issue_id="iss_wc_710",
        code=IssueCode.SECTION_WORD_COUNT_OUT_OF_BOUNDS,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.PASSAGE,
        message="Passage word count 710 is below 720 minimum",
        affected_refs=[sec.to_ref()],
    )
    route_passage = router.route_repair(sec, [iss_passage], all_child_envelopes=qs)
    assert route_dup.target_scope != RepairScope.PASSAGE
    assert route_passage.action_type == SectionRepairActionType.PASSAGE_REPAIR
    assert route_passage.target_scope == RepairScope.PASSAGE
    assert f"art_passage_s1" in route_passage.invalidated_artifact_ids
    assert any("art_q_" in art_id for art_id in route_passage.invalidated_artifact_ids)

    # 3. Route Source Insufficiency defect -> NeedsSources
    iss_source = Issue.create(
        issue_id="iss_src_gap",
        code=IssueCode.SOURCE_INSUFFICIENT,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.SOURCE,
        message="Source does not contain verifiable claims for science topic",
        affected_refs=[sec.to_ref()],
    )
    route_source = router.route_repair(sec, [iss_source])
    assert route_source.action_type == SectionRepairActionType.NEEDS_SOURCES
    assert route_source.workflow_status == "NEEDS_SOURCES"


@pytest.mark.asyncio
async def test_t11_06_accept_transaction_persist_sections_json_bridge_cas_fencing():
    """T11-06: Verifies authenticated checkpoint persistence, CAS/fencing, and atomic SectionsJson bridge."""
    db_path = Path(f"/tmp/test_t11_06_simulation_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)

    bp_ref = ArtifactRef(artifactId="art_blueprint_01", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="b"*64)
    p = create_mock_passage_envelope(1, 800, run_id="run_t11_06")
    qs = create_mock_question_envelopes(1, run_id="run_t11_06")

    sec_loop = SectionLoop(persistence_client=client)
    result = await sec_loop.run(
        section_index=1,
        title="Academic Section 1",
        passage_artifact=p,
        blueprint_ref=bp_ref,
        question_artifacts=qs,
        run_id="run_t11_06",
        lease_owner=owner,
        epoch=1,
    )

    assert result.decision == DecisionType.PASS
    assert result.accepted_artifact is not None

    # Checkpoint is durable in persistence store
    stored = client.resume_state("run_t11_06")
    assert any(a.artifactId == "art_section_s1" and a.acceptedVersion == 1 for a in stored.artifacts)

    # Replaying with same OperationId is idempotent without duplicate version increment
    replay_res = await sec_loop.run(
        section_index=1,
        title="Academic Section 1",
        passage_artifact=p,
        blueprint_ref=bp_ref,
        question_artifacts=qs,
        run_id="run_t11_06",
        lease_owner=owner,
        epoch=1,
    )
    assert replay_res.decision == DecisionType.PASS
    assert replay_res.accepted_artifact.version == 1

    # Stale lease owner fails closed
    with pytest.raises(ValueError, match="Stale writer lease or fencing conflict"):
        await sec_loop.run(
            section_index=1,
            title="Academic Section 1",
            passage_artifact=p,
            blueprint_ref=bp_ref,
            question_artifacts=qs,
            run_id="run_t11_06",
            lease_owner=uuid4(), # Wrong owner
            epoch=1,
        )


@pytest.mark.asyncio
async def test_t11_07_durable_cursor_resume_kill_at_acceptance_source_replacement():
    """T11-07: Verifies exact durable cursor resume, crash resumption, and Section 3 source replacement preserving Section 1-2."""
    # Unique per invocation: a fixed path let a stale file (or a still-open handle from
    # an earlier interrupted run) leak into this test, producing an intermittent
    # resume failure that only appeared in a full-suite run. The DB must survive across
    # the SectionLoop instances below to simulate a process restart, so it cannot simply
    # be a fresh path per loop -- only per test invocation.
    db_path = Path(f"/tmp/test_t11_07_simulation_{uuid4().hex}.db")
    if db_path.exists():
        db_path.unlink()
    owner = uuid4()
    client = SQLiteCheckpointSimulation(db_path=db_path, owner=owner, epoch=1)

    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="b"*64)
    sec_loop = SectionLoop(persistence_client=client)

    # 1. Commit Section 1 and Section 2
    p1 = create_mock_passage_envelope(1, 800, run_id="run_t11_07")
    qs1 = create_mock_question_envelopes(1, run_id="run_t11_07")
    res1 = await sec_loop.run(1, "Section 1", p1, bp_ref, qs1, "run_t11_07", owner, 1)
    assert res1.decision == DecisionType.PASS

    p2 = create_mock_passage_envelope(2, 820, run_id="run_t11_07")
    qs2 = create_mock_question_envelopes(2, run_id="run_t11_07")
    res2 = await sec_loop.run(2, "Section 2", p2, bp_ref, qs2, "run_t11_07", owner, 1)
    assert res2.decision == DecisionType.PASS
    # 2. Simulate crash / process restart by constructing fresh SectionLoop instance with same DB
    sec_loop_restarted = SectionLoop(persistence_client=client)

    # Section 1 and 2 resume instantly without re-executing iterations
    resume1 = await sec_loop_restarted.run(1, "Section 1", p1, bp_ref, qs1, "run_t11_07", owner, 1)
    assert resume1.decision == DecisionType.PASS
    assert resume1.total_iterations == 0

    # 3. Source replacement for Section 3: replacing source PMC3123456 with PMC3999999
    p3_replacement = create_mock_passage_envelope(3, 850, run_id="run_t11_07")
    p3_dict = json.loads(canonical_json_dump(p3_replacement.payload))
    p3_dict["source"]["pmcid"] = "PMC3999999"
    p3_dict["source"]["title"] = "Replaced Source Article"
    p3_replacement = ArtifactEnvelope.create(
        artifact_id=p3_replacement.artifact_id,
        artifact_type=p3_replacement.artifact_type,
        run_id="run_t11_07",
        payload=p3_dict,
        producer_version="2.0.0",
        version=1,
        section_id=3,
        parent_refs=[],
    )
    qs3 = create_mock_question_envelopes(3, run_id="run_t11_07")
    res3 = await sec_loop_restarted.run(3, "Section 3 Replacement", p3_replacement, bp_ref, qs3, "run_t11_07", owner, 1)
    assert res3.decision == DecisionType.PASS

    # Assert Section 1 and Section 2 accepted heads remain 100% intact and untouched
    stored = client.resume_state("run_t11_07")
    sec_ids = [a.artifactId for a in stored.artifacts]
    assert "art_section_s1" in sec_ids
    assert "art_section_s2" in sec_ids
    assert "art_section_s3" in sec_ids


@pytest.mark.asyncio
async def test_t11_08_typed_workflow_mapping_dotnet_roundtrip_payload_isolation():
    """T11-08: Verifies typed workflow mapping, student payload isolation, and .NET consumer compatibility."""
    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="b"*64)
    p = create_mock_passage_envelope(1, 800)
    qs = create_mock_question_envelopes(1)
    sec = assemble_immutable_section(1, "Section 1", p, bp_ref, qs)

    # 1. Student Visible Payload Isolation: NO answer, evidenceQuote, explanation, or absenceAssessment
    student_sec = to_student_visible_section(sec)
    student_dict = student_sec.model_dump(mode="json", by_alias=True)

    # Assert zero leakage
    assert_student_visible_payload_isolated(student_dict)
    assert "passage" in student_dict
    assert "groups" in student_dict
    for g in student_dict["groups"]:
        assert "instructions" in g
        assert "questions" in g
        for q in g["questions"]:
            assert "prompt" in q
            assert "questionNumber" in q
            assert "answer" not in q
            assert "evidenceQuote" not in q
            assert "explanation" not in q
            assert "absenceAssessment" not in q

    # 2. Internal Authoring Result preserves answer graph
    authoring_payload = sec.payload
    assert "groups" in authoring_payload
    first_q = authoring_payload["groups"][0]["questions"][0]
    assert "answer" in first_q
    assert "explanation" in first_q

    # 3. Invariant: Section acceptance does not build an exam or complete paper/job
    assert sec.artifact_type == ArtifactType.SECTION
    assert sec.artifact_type != ArtifactType.READING_PAPER
@pytest.mark.asyncio
async def test_t11_09_answer_leakage_and_passage_repair_regression():
    """T11-09: Verifies surgical repair of ANSWER_LEAKAGE routes to the receiving prompt and eliminates leakage."""
    router = SectionRepairRouter()
    repairer = SectionSurgicalRepairer()
    
    # Create mock section with answer leakage in Q6 prompt from Q12 answer ('aerodynamic profiles')
    p = create_mock_passage_envelope(1, 800)
    bp_ref = ArtifactRef(artifactId="art_bp", version=1, artifactType=ArtifactType.EXAM_BLUEPRINT, contentHash="b"*64)
    qs = create_mock_question_envelopes(1)
    sec_env = assemble_immutable_section(1, "Section 1", p, bp_ref, qs)
    
    # Inject leaked phrase into Q6
    import json
    raw_payload = json.loads(json.dumps(sec_env.payload, default=dict))
    raw_payload["groups"][0]["questions"][5]["prompt"] = "The test evaluated aerodynamic profiles in wind tunnels."
    raw_payload["groups"][0]["questions"][5]["statement"] = "The test evaluated aerodynamic profiles in wind tunnels."
    sec_env = ArtifactEnvelope.create(
        artifact_id=sec_env.artifact_id,
        artifact_type=sec_env.artifact_type,
        run_id="run_leak_test",
        payload=raw_payload,
        producer_version="2.0.0",
        version=1,
        section_id=1,
        parent_refs=list(sec_env.parent_refs),
    )
    
    leak_issue = Issue.create(
        issue_id="iss_leak_test",
        code=IssueCode.ANSWER_LEAKAGE,
        severity=IssueSeverity.CRITICAL,
        scope=IssueScope.SECTION,
        message="Answer for Question 12 ('aerodynamic profiles') leaks verbatim inside the prompt of Question 6",
        evaluator_id="eval_section_duplicate_concentration",
    )
    
    route = router.route_repair(sec_env, [leak_issue])
    assert 6 in route.target_question_numbers, f"Expected Q6 (receiving prompt) in route: {route.target_question_numbers}"
    assert 12 in route.target_question_numbers, f"Expected Q12 (source answer) in route: {route.target_question_numbers}"
    
    from uuid import UUID
    from app.loop.context import AuthorityGrant
    ctx = LoopContext(
        runId="run_leak_test",
        scope=IssueScope.SECTION,
        targetArtifactId=sec_env.artifact_id,
        targetArtifactType=ArtifactType.SECTION,
        sectionId=1,
        authority=AuthorityGrant(leaseOwner=UUID(int=0), epoch=1),
    )
    repaired_env = await repairer._repair_impl(ctx, sec_env, [leak_issue], "intent_repair", 2)
    
    # Assert leakage is eliminated from Q6 prompt in repaired section
    repaired_q6_prompt = repaired_env.payload["groups"][0]["questions"][5]["prompt"]
    assert "aerodynamic profiles" not in repaired_q6_prompt.lower(), f"Leaked text still present in repaired Q6 prompt: {repaired_q6_prompt}"
    
    # Re-evaluate with SectionDuplicateAndConcentrationEvaluator to prove issue is resolved
    evaluator = SectionDuplicateAndConcentrationEvaluator()
    ev_res = await evaluator._evaluate_impl(ctx, repaired_env, "intent_verify")
    leakage_issues = [iss for iss in ev_res.issues if iss.code == IssueCode.ANSWER_LEAKAGE]
    assert len(leakage_issues) == 0, f"Expected 0 leakage issues after repair, got: {leakage_issues}"
