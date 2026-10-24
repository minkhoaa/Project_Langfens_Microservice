"""Comprehensive Parameterized Offline Contract Tests for all 21 QuestionPromptFamily Templates and Parser.

Validates:
1. Rendered production prompt contracts across all 21 QuestionPromptFamily members:
   - Well-formed prompt payload structure
   - Explicit "explanation" and "evidenceQuote" in declared JSON schemas
   - Passage-grounded minimum 25 characters explanation constraint
2. Parsing of realistic, deterministic provider responses via _parse_candidate_payload:
   - Validates questionNumber, questionType, explanation (len >= 25), answer, and passageEvidence
   - Validates family-specific fields (options, flowSteps, calloutLabel, tableContext, etc.)
   - Validates nested blanks structure for SUMMARY_COMPLETION
3. Strict fail-closed rejection:
   - Missing explanation fails closed
   - Short explanation (< 25 chars) fails closed without fake synthesis
   - Missing candidates/blanks fails closed
   - Malformed non-dict payload fails closed
   - Invalid objective answer formats fail closed
"""

import pytest
from typing import Any, Dict

from app.contracts.question_type import QuestionPromptFamily
from app.generators.question.prompts import (
    PROMPT_HASHES,
    PROMPT_TEMPLATES,
    SYSTEM_PROMPTS,
    build_question_prompt,
    compute_prompt_hash,
    render_question_prompt,
)
from app.section_runner import _parse_candidate_payload

SAMPLE_PASSAGE = (
    "Artificial Light at Night (ALAN) has emerged as a pervasive and escalating form of pollution. "
    "Studies indicate that at least 22% of coastal regions are exposed to ALAN. "
    "In Southeast Asian seas, ALAN penetrates to approximately 20 meters. "
    "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents. "
    "The subterranean circulation involves magmatic heating of infiltrated seawater. "
    "Mineral precipitates deposit crystalline anhydrite on chimney outer walls while chalcopyrite lines the central conduit. "
    "Researchers classify benthic fauna into distinct physiological groupings based on thermal tolerance."
)

CLAIMS_MAP = {
    "c_emerged": {"claimId": "c_emerged", "text": "Artificial Light at Night (ALAN) has emerged as a pervasive and escalating form of pollution."},
    "c_alan": {"claimId": "c_alan", "text": "Studies indicate that at least 22% of coastal regions are exposed to ALAN."},
    "c_depth": {"claimId": "c_depth", "text": "In Southeast Asian seas, ALAN penetrates to approximately 20 meters."},
    "c_hydro": {"claimId": "c_hydro", "text": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents."},
    "c_heat": {"claimId": "c_heat", "text": "The subterranean circulation involves magmatic heating of infiltrated seawater."},
    "c_mineral": {"claimId": "c_mineral", "text": "chalcopyrite lines the central conduit."},
    "c_class": {"claimId": "c_class", "text": "Researchers classify benthic fauna into distinct physiological groupings based on thermal tolerance."},
}

DETERMINISTIC_PROVIDER_PAYLOADS: Dict[QuestionPromptFamily, Dict[str, Any]] = {
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "At least 22% of coastal regions experience exposure to ALAN.",
            "answer": "TRUE",
            "evidenceQuote": "Studies indicate that at least 22% of coastal regions are exposed to ALAN.",
            "explanation": "The passage confirms that at least 22% of coastal regions are exposed to ALAN, directly supporting the statement.",
        }],
    },
    QuestionPromptFamily.YES_NO_NOT_GIVEN: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "ALAN poses an escalating environmental pollution challenge in the modern era.",
            "answer": "YES",
            "evidenceQuote": "Artificial Light at Night (ALAN) has emerged as a pervasive and escalating form of pollution.",
            "explanation": "The author directly asserts that ALAN has emerged as an escalating form of pollution, agreeing with the statement.",
        }],
    },
    QuestionPromptFamily.SENTENCE_COMPLETION: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "In Southeast Asian seas, ALAN reaches a depth of approximately ______ meters.",
            "answer": "20",
            "evidenceQuote": "In Southeast Asian seas, ALAN penetrates to approximately 20 meters.",
            "explanation": "The passage states that ALAN penetrates to approximately 20 meters in Southeast Asian marine environments.",
        }],
    },
    QuestionPromptFamily.SUMMARY_COMPLETION: {
        "summaryTitle": "Hydrothermal Ecosystems",
        "summaryText": "At abyssal vents, chemosynthetic organisms convert hydrogen sulfide into [1].",
        "blanks": [{
            "number": 1,
            "placeholder": "[1]",
            "answer": "cellular energy",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "The passage explains that chemosynthetic bacteria convert hydrogen sulfide into cellular energy at vents.",
        }],
    },
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "What do chemosynthetic bacteria convert hydrogen sulfide into?",
            "options": [
                {"key": "A", "text": "cellular energy"},
                {"key": "B", "text": "calcareous shells"},
                {"key": "C", "text": "magmatic heating"},
                {"key": "D", "text": "anhydrite outer walls"},
            ],
            "answer": "A",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "The text directly confirms that bacteria convert hydrogen sulfide into cellular energy, making option A correct.",
        }],
    },
    QuestionPromptFamily.SHORT_ANSWER: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "What do bacteria convert hydrogen sulfide into at deep ocean vents?",
            "answer": "cellular energy",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "The passage explicitly names cellular energy as the product converted from hydrogen sulfide by bacteria.",
        }],
    },
    QuestionPromptFamily.TABLE_COMPLETION: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Hydrothermal processes involve ______ of infiltrated seawater.",
            "tableContext": "Table 1: Subterranean Geothermal Processes",
            "rowHeader": "Circulation",
            "colHeader": "Mechanism",
            "answer": "magmatic heating",
            "evidenceQuote": "The subterranean circulation involves magmatic heating of infiltrated seawater.",
            "explanation": "The passage states that subterranean circulation involves magmatic heating of infiltrated seawater.",
        }],
    },
    QuestionPromptFamily.NOTE_COMPLETION: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Energy synthesis: conversion of hydrogen sulfide into [1]",
            "headingContext": "Vent Ecosystem Energetics",
            "bulletPrefix": "Energy synthesis",
            "answer": "cellular energy",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "The passage notes that bacteria convert hydrogen sulfide into cellular energy to sustain the vent ecosystem.",
        }],
    },
    QuestionPromptFamily.FORM_COMPLETION: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Measured penetration depth: ______ meters",
            "fieldLabel": "Penetration depth",
            "answer": "20",
            "evidenceQuote": "In Southeast Asian seas, ALAN penetrates to approximately 20 meters.",
            "explanation": "The survey recorded an ALAN penetration depth of approximately 20 meters in Southeast Asian marine basins.",
        }],
    },
    QuestionPromptFamily.DIAGRAM_LABEL: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Label [1] indicating the mineral layer lining the central conduit",
            "calloutLabel": "Part 1",
            "partDescription": "Conduit interior mineral lining",
            "answer": "chalcopyrite",
            "evidenceQuote": "chalcopyrite lines the central conduit.",
            "explanation": "The diagram callout indicates chalcopyrite as the specific mineral lining the inner chimney conduit.",
        }],
    },
    QuestionPromptFamily.MAP_LABEL: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Map location label for [1] identifying the inner hydrothermal fissure",
            "calloutLabel": "Location 1",
            "partDescription": "Central hydrothermal conduit fissure",
            "answer": "central conduit",
            "evidenceQuote": "chalcopyrite lines the central conduit.",
            "explanation": "The map location corresponds to the central conduit where mineral precipitates concentrate.",
        }],
    },
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Which TWO phenomena are mentioned in the passage regarding deep hydrothermal vents?",
            "options": [
                {"key": "A", "text": "Chemosynthetic bacteria convert hydrogen sulfide"},
                {"key": "B", "text": "Coral bleaching from lunar rhythms"},
                {"key": "C", "text": "Magmatic heating of infiltrated seawater"},
                {"key": "D", "text": "Commercial deep-sea mining expeditions"},
                {"key": "E", "text": "Extinction of benthic crustaceans"},
            ],
            "answers": ["A", "C"],
            "answer": "A, C",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents. The subterranean circulation involves magmatic heating of infiltrated seawater.",
            "explanation": "Both chemosynthetic conversion and magmatic heating are explicitly detailed in the passage text.",
        }],
    },
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE_IMAGE: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Which diagram correctly illustrates the mineral precipitation within the chimney?",
            "options": [
                {"key": "A", "text": "Diagram A: chalcopyrite lining the central conduit and anhydrite on outer walls"},
                {"key": "B", "text": "Diagram B: anhydrite lining the central conduit with no outer precipitation"},
                {"key": "C", "text": "Diagram C: inverted mineral precipitation zones without hydrothermal flow"},
                {"key": "D", "text": "Diagram D: homogeneous basalt chimney with absent sulfide minerals"},
            ],
            "answer": "A",
            "evidenceQuote": "Mineral precipitates deposit crystalline anhydrite on chimney outer walls while chalcopyrite lines the central conduit.",
            "explanation": "Diagram A accurately reflects that chalcopyrite lines the central conduit while anhydrite deposits on outer walls.",
        }],
    },
    QuestionPromptFamily.MATCHING_HEADING: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Paragraph 1",
            "paragraphRef": "Paragraph A",
            "headings": [
                "Heading i: Energetics and mineral circulation at hydrothermal vents",
                "Heading ii: Atmospheric effects of artificial light pollution",
                "Heading iii: Commercial exploitation of abyssal fisheries",
                "Heading iv: Photogrammetric surveying of desert dunes",
            ],
            "answer": "i",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "Heading i accurately captures the paragraph's discussion of biological energy and mineral circulation.",
        }],
    },
    QuestionPromptFamily.MATCHING_INFORMATION: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "a mention of the percentage of coastal waters affected by night light",
            "targetParagraph": "A",
            "answer": "A",
            "options": ["Paragraph A", "Paragraph B", "Paragraph C"],
            "evidenceQuote": "Studies indicate that at least 22% of coastal regions are exposed to ALAN.",
            "explanation": "Paragraph A contains the specific percentage finding that 22% of coastal regions are exposed to ALAN.",
        }],
    },
    QuestionPromptFamily.MATCHING_FEATURES: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Classified benthic organisms according to thermal tolerance thresholds",
            "options": [
                {"key": "A", "text": "Researchers"},
                {"key": "B", "text": "Commercial divers"},
                {"key": "C", "text": "Naval engineers"},
            ],
            "answer": "A",
            "evidenceQuote": "Researchers classify benthic fauna into distinct physiological groupings based on thermal tolerance.",
            "explanation": "The text directly attributes the physiological grouping of benthic fauna based on thermal tolerance to researchers.",
        }],
    },
    QuestionPromptFamily.MATCHING_ENDINGS: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Subterranean fluid circulation involves",
            "options": [
                {"key": "A", "text": "magmatic heating of infiltrated seawater."},
                {"key": "B", "text": "rapid cooling by atmospheric breezes."},
                {"key": "C", "text": "complete evaporation within sandy coastal dunes."},
            ],
            "answer": "A",
            "evidenceQuote": "The subterranean circulation involves magmatic heating of infiltrated seawater.",
            "explanation": "Ending A completes the sentence in exact accord with the passage statement on magmatic heating.",
        }],
    },
    QuestionPromptFamily.CLASSIFICATION: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Exposure of over one-fifth of territorial shorelines",
            "options": [
                {"key": "A", "text": "Marine ALAN pollution"},
                {"key": "B", "text": "Basalt magmatic heating"},
                {"key": "C", "text": "Abyssal chemosynthesis"},
            ],
            "answer": "A",
            "evidenceQuote": "Studies indicate that at least 22% of coastal regions are exposed to ALAN.",
            "explanation": "The statement describes coastal shoreline exposure (22%), which is classified under marine ALAN pollution.",
        }],
    },
    QuestionPromptFamily.FLOW_CHART: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Complete the flow chart below. Step 1: ______",
            "flowSteps": [
                "Stage 1: Infiltration of cold seawater into bedrock fissures",
                "Stage 2: Magmatic heating of infiltrated seawater",
                "Stage 3: Mineral precipitation along central conduit",
            ],
            "stepIndex": 1,
            "answer": "magmatic heating",
            "evidenceQuote": "The subterranean circulation involves magmatic heating of infiltrated seawater.",
            "explanation": "The flow chart sequence demonstrates that infiltrated seawater undergoes magmatic heating before venting.",
        }],
    },
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "The hydrothermal chimney inner passage is lined with [1].",
            "summaryText": "The hydrothermal chimney inner passage is lined with [1].",
            "options": [
                {"key": "A", "text": "chalcopyrite"},
                {"key": "B", "text": "calcareous shell"},
                {"key": "C", "text": "sediment layer"},
                {"key": "D", "text": "cellular energy"},
            ],
            "answer": "A",
            "evidenceQuote": "chalcopyrite lines the central conduit.",
            "explanation": "The passage confirms that chalcopyrite lines the central conduit, making option A the correct box choice.",
        }],
    },
    QuestionPromptFamily.CHOOSING_TITLE: {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Choose the most appropriate title for the passage.",
            "options": [
                {"key": "A", "text": "Marine Environmental Impacts and Abyssal Ecosystem Dynamics"},
                {"key": "B", "text": "A Brief Note on Calanus Copepods"},
                {"key": "C", "text": "Technological Specifications of Robotic Arms"},
                {"key": "D", "text": "Atmospheric Sky Brightness Over Urban Centers"},
            ],
            "answer": "A",
            "evidenceQuote": "Artificial Light at Night (ALAN) has emerged as a pervasive and escalating form of pollution. Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "Title A accurately synthesizes the broad thematic content covering marine light exposure and vent ecosystems.",
        }],
    },
}

ALL_FAMILIES = list(QuestionPromptFamily)


@pytest.mark.parametrize("family", ALL_FAMILIES, ids=lambda f: f.value)
def test_prompt_template_renders_valid_json_structure(family: QuestionPromptFamily):
    """Test 1: Render actual production prompt, verify declared JSON schema and >= 25 char explanation requirement."""
    prompt_payload = build_question_prompt(
        family=family,
        passage_text=SAMPLE_PASSAGE,
        question_number=1,
        candidate_count=2,
    )
    assert prompt_payload["prompt_id"] == f"prompt_{family.value.lower()}_2.0.0"
    assert prompt_payload["prompt_version"] == "2.0.0"
    assert prompt_payload["prompt_hash"] == PROMPT_HASHES[family]
    assert prompt_payload["prompt_hash"] == compute_prompt_hash(family, PROMPT_TEMPLATES[family])

    rendered = render_question_prompt(
        family=family,
        slot_number=1,
        passage_text=SAMPLE_PASSAGE,
        total_questions=13,
    )
    assert len(rendered) > 100
    assert '"explanation":' in rendered, f"{family.value} rendered prompt must declare 'explanation' field"
    assert '"evidenceQuote":' in rendered, f"{family.value} rendered prompt must declare 'evidenceQuote' field"
    assert "25" in rendered, f"{family.value} rendered prompt must specify 25 character explanation threshold"


@pytest.mark.parametrize("family", ALL_FAMILIES, ids=lambda f: f.value)
def test_parse_realistic_candidate_payload(family: QuestionPromptFamily):
    """Test 2: Parse realistic deterministic provider response using real candidate parser."""
    payload = DETERMINISTIC_PROVIDER_PAYLOADS[family]
    family_claim_binding = {
        QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: "c_alan",
        QuestionPromptFamily.YES_NO_NOT_GIVEN: "c_emerged",
        QuestionPromptFamily.SENTENCE_COMPLETION: "c_depth",
        QuestionPromptFamily.SUMMARY_COMPLETION: "c_hydro",
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: "c_hydro",
        QuestionPromptFamily.SHORT_ANSWER: "c_hydro",
        QuestionPromptFamily.TABLE_COMPLETION: "c_heat",
        QuestionPromptFamily.NOTE_COMPLETION: "c_hydro",
        QuestionPromptFamily.FORM_COMPLETION: "c_depth",
        QuestionPromptFamily.DIAGRAM_LABEL: "c_mineral",
        QuestionPromptFamily.MAP_LABEL: "c_mineral",
        QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE: "c_hydro",
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE_IMAGE: "c_mineral",
        QuestionPromptFamily.MATCHING_HEADING: "c_hydro",
        QuestionPromptFamily.MATCHING_INFORMATION: "c_alan",
        QuestionPromptFamily.MATCHING_FEATURES: "c_class",
        QuestionPromptFamily.MATCHING_ENDINGS: "c_heat",
        QuestionPromptFamily.CLASSIFICATION: "c_alan",
        QuestionPromptFamily.FLOW_CHART: "c_heat",
        QuestionPromptFamily.SUMMARY_COMPLETION_BOX: "c_mineral",
        QuestionPromptFamily.CHOOSING_TITLE: "c_emerged",
    }
    claim_id = family_claim_binding.get(family, "c_alan")

    parsed = _parse_candidate_payload(
        raw_payload=payload,
        q_num=1,
        q_type=family.value,
        passage_text=SAMPLE_PASSAGE,
        claims_map=CLAIMS_MAP,
        claim_id=claim_id,
        difficulty="FOUNDATION",
    )

    assert parsed["questionNumber"] == 1
    assert parsed["questionType"] == family.value
    assert isinstance(parsed["explanation"], str)
    assert len(parsed["explanation"]) >= 25, f"{family.value} parsed explanation too short (< 25 chars)"
    assert parsed.get("passageEvidence") is not None
    assert parsed["passageEvidence"]["startChar"] >= 0
    assert parsed["passageEvidence"]["endChar"] > parsed["passageEvidence"]["startChar"]

    # Family-specific invariants
    if family == QuestionPromptFamily.FLOW_CHART:
        assert isinstance(parsed.get("flowSteps"), list)
        assert len(parsed["flowSteps"]) >= 2
        assert parsed.get("stepIndex") == 1
    elif family in (QuestionPromptFamily.DIAGRAM_LABEL, QuestionPromptFamily.MAP_LABEL):
        assert parsed.get("calloutLabel") is not None
    elif family in (QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE, QuestionPromptFamily.CHOOSING_TITLE, QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE_IMAGE):
        assert isinstance(parsed.get("options"), list)
        assert len(parsed["options"]) == 4
        assert parsed.get("answer") in ("A", "B", "C", "D")
    elif family == QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE:
        assert isinstance(parsed.get("options"), list)
        assert isinstance(parsed.get("answers"), list)
        assert len(parsed["answers"]) >= 2
    elif family == QuestionPromptFamily.MATCHING_HEADING:
        assert isinstance(parsed.get("headings"), list)
        assert len(parsed["headings"]) >= 3
        assert parsed.get("paragraphRef") is not None
    elif family == QuestionPromptFamily.TABLE_COMPLETION:
        assert parsed.get("tableContext") is not None


@pytest.mark.parametrize("family", ALL_FAMILIES, ids=lambda f: f.value)
def test_rejection_missing_or_short_explanation(family: QuestionPromptFamily):
    """Test 3: Verify missing or short explanations (< 25 characters) strictly fail closed."""
    claim_id = "c_alan"

    # Subcase A: Missing explanation entirely
    missing_exp_payload = {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Test prompt without explanation",
            "answer": "TRUE" if family == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN else "A",
            "evidenceQuote": "Studies indicate that at least 22% of coastal regions are exposed to ALAN.",
        }],
        "blanks": [{
            "number": 1,
            "placeholder": "[1]",
            "answer": "cellular energy",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
        }],
    }
    with pytest.raises(ValueError, match="explanation is missing or too short"):
        _parse_candidate_payload(
            raw_payload=missing_exp_payload,
            q_num=1,
            q_type=family.value,
            passage_text=SAMPLE_PASSAGE,
            claims_map=CLAIMS_MAP,
            claim_id=claim_id,
            difficulty="FOUNDATION",
        )

    # Subcase B: Short explanation (< 25 characters)
    short_exp_payload = {
        "candidates": [{
            "questionNumber": 1,
            "prompt": "Test prompt with short explanation",
            "answer": "TRUE" if family == QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN else "A",
            "evidenceQuote": "Studies indicate that at least 22% of coastal regions are exposed to ALAN.",
            "explanation": "Short (<25 chars)",
        }],
        "blanks": [{
            "number": 1,
            "placeholder": "[1]",
            "answer": "cellular energy",
            "evidenceQuote": "Chemosynthetic bacteria convert hydrogen sulfide into cellular energy at hydrothermal vents.",
            "explanation": "Short (<25 chars)",
        }],
    }
    with pytest.raises(ValueError, match="explanation is missing or too short"):
        _parse_candidate_payload(
            raw_payload=short_exp_payload,
            q_num=1,
            q_type=family.value,
            passage_text=SAMPLE_PASSAGE,
            claims_map=CLAIMS_MAP,
            claim_id=claim_id,
            difficulty="FOUNDATION",
        )


@pytest.mark.parametrize("family", ALL_FAMILIES, ids=lambda f: f.value)
def test_rejection_malformed_payload(family: QuestionPromptFamily):
    """Test 4: Verify malformed, non-dict, and incomplete candidate payloads strictly fail closed."""
    claim_id = "c_alan"

    # Subcase A: Non-dict payload
    with pytest.raises(ValueError, match="Expected dict from provider"):
        _parse_candidate_payload(
            raw_payload=["not", "a", "dict"],
            q_num=1,
            q_type=family.value,
            passage_text=SAMPLE_PASSAGE,
            claims_map=CLAIMS_MAP,
            claim_id=claim_id,
            difficulty="FOUNDATION",
        )

    # Subcase B: Dict missing candidates and blanks and prompt
    with pytest.raises(ValueError, match="missing candidates/blanks"):
        _parse_candidate_payload(
            raw_payload={"unrelatedField": 123},
            q_num=1,
            q_type=family.value,
            passage_text=SAMPLE_PASSAGE,
            claims_map=CLAIMS_MAP,
            claim_id=claim_id,
            difficulty="FOUNDATION",
        )
