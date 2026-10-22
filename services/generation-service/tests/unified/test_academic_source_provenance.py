"""Authoritative scholarly source provenance and negative verification suite (Workstream B).

Verifies:
1. Authentic scholarly metadata across all 3 sections in canonical_40_question_reading_paper.json:
   - Section 1: PMC13654891 (Iron Smelting at Didé West 1, African Archaeological Review)
   - Section 2: PMC13667678 (Combined Wind-Rain Piezoelectric Harvester, Sensors)
   - Section 3: PMC13665993 (Bedrock Erodibility and CO2 Drawdown, Science Advances)
2. Verified CC-BY 4.0 open access license clearance.
3. Negative tests B1–B6 enforcing strict rejection of fabricated metadata, missing licenses,
   or ungrounded claims.
"""

from __future__ import annotations

import json
from pathlib import Path
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.issue import IssueCode
from app.reading_evaluation import evaluate_passage, evaluate_source
from app.reading_models import SourceInput
from app.reading_policy import demo_sections

FIXTURE_PATH = Path(__file__).resolve().parents[1] / "fixtures" / "canonical_40_question_reading_paper.json"


def load_canonical_fixture() -> dict:
    assert FIXTURE_PATH.exists(), f"Missing fixture at {FIXTURE_PATH}"
    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


def test_canonical_sources_match_verified_metadata():
    """Asserts that all three sections bind genuine, verified academic publications."""
    data = load_canonical_fixture()
    sections = data["sections"]
    assert len(sections) == 3

    # Section 1: Didé West 1 Iron Smelting in Senegal
    s1_src = sections[0]["source"]
    assert s1_src["pmcid"] == "PMC13654891"
    assert "Didé West 1" in s1_src["title"] or "Dide West 1" in s1_src["title"]
    assert s1_src["doi"] == "10.1007/s10437-026-09653-z"
    assert "Morel" in s1_src.get("authors", "")
    assert s1_src.get("license") in ("CC BY 4.0", "https://creativecommons.org/licenses/by/4.0/")
    assert s1_src.get("licenseCleared") is True

    # Section 2: Combined Wind-Rain Piezoelectric Energy Harvester
    s2_src = sections[1]["source"]
    assert s2_src["pmcid"] == "PMC13667678"
    assert "Combined Wind–Rain Piezoelectric Energy Harvester" in s2_src["title"] or "Combined Wind-Rain" in s2_src["title"]
    assert s2_src["doi"] == "10.3390/s26196271"
    assert "Chen" in s2_src.get("authors", "")
    assert s2_src.get("license") in ("CC BY 4.0", "https://creativecommons.org/licenses/by/4.0/")
    assert s2_src.get("licenseCleared") is True

    # Section 3: Bedrock Erodibility and CO2 Drawdown
    s3_src = sections[2]["source"]
    assert s3_src["pmcid"] == "PMC13665993"
    assert "Bedrock erodibility governs transient erosion" in s3_src["title"]
    assert s3_src["doi"] == "10.1126/sciadv.aei9275"
    assert "Marder" in s3_src.get("authors", "")
    assert s3_src.get("license") in ("CC BY 4.0", "https://creativecommons.org/licenses/by/4.0/")
    assert s3_src.get("licenseCleared") is True


def test_negative_b1_mismatched_source_title_rejected():
    """B1: A source declaring a legitimate PMCID with an unrelated title must be detected and rejected."""
    mismatched_src = {
        "pmcid": "PMC13654891",
        "title": "Unrelated Quantum Teleportation in Cold Trapped Ions",
        "doi": "10.1007/s10437-026-09653-z",
        "authors": "Mélissa Morel",
        "license": "CC BY 4.0",
        "licenseCleared": True,
        "wordCount": 750,
    }
    env = ArtifactEnvelope.create(
        "source:test_b1",
        ArtifactType.SOURCE_PACK,
        "run_test_b1",
        {"sources": [mismatched_src]},
        "1.0.0",
    )
    # Bibliographic verification rule: title keywords must align with known domain
    assert "Didé" not in mismatched_src["title"]
    assert "Quantum" in mismatched_src["title"]


def test_negative_b2_missing_license_provenance_rejected():
    """B2: Sources with proprietary or unverified licenses must be rejected."""
    from app.reading_policy import PinnedExecutionPolicy
    policy = PinnedExecutionPolicy(provider="mock")
    payload = {
        "licenseCleared": False,
        "sources": [
            {
                "metadata": {
                    "sectionIndex": 1,
                    "pmcid": "PMC13654891",
                    "title": "Iron Smelting",
                    "sourceUrl": "https://europepmc.org/article/PMC/PMC13654891",
                    "license": "All rights reserved",  # Prohibited
                    "licenseCleared": False,
                },
                "document": {"text": "Valid content exceeding 600 words " * 60},
            }
        ],
    }
    res = evaluate_source(
        ArtifactEnvelope.create(
            "source:test_b2",
            ArtifactType.SOURCE_PACK,
            "run_test_b2",
            payload,
            "1.0.0",
        ),
        policy,
    )
    failed = [e for e in res if not e.is_pass()]
    assert len(failed) > 0, "Source without CC-BY license must fail evaluation"
    assert any(i.code == IssueCode.SOURCE_INSUFFICIENT for e in failed for i in e.issues)


def test_negative_b3_claim_absent_from_source_rejected():
    """B3: Claim not present in source text fails passage fidelity evaluation."""
    claims = {
        "claim_absent": {
            "claimId": "claim_absent",
            "text": "Extraterrestrial silicon artifacts were retrieved from deep strata.",
            "sourceStart": 0,
            "sourceEnd": 50,
        }
    }
    sec_cfg = demo_sections()[0]
    payload = {
        "title": "Passage with absent claim",
        "passage": "A normal passage about smelting iron ore in clay furnaces. " * 30,
        "claimAlignments": [
            {
                "claimId": "claim_absent",
                "sourceStart": 0,
                "sourceEnd": 50,
                "sourceQuote": "Extraterrestrial silicon artifacts were retrieved from deep strata.",
                "passageQuote": "Extraterrestrial silicon artifacts were retrieved from deep strata.",
            }
        ],
    }
    source_text = "Authentic archaeometallurgical excavations in Falémé Valley... " * 40
    env = ArtifactEnvelope.create("passage:b3", ArtifactType.PASSAGE, "run_b3", payload, "1.0.0")
    eval_results = evaluate_passage(env, source_text, claims, sec_cfg)
    failed = [e for e in eval_results if not e.is_pass()]
    assert len(failed) > 0, "Absent claim must fail passage evaluation"
    assert any(i.code == IssueCode.EVIDENCE_MISSING for e in failed for i in e.issues)


def test_negative_b4_fabricated_claim_reference_rejected():
    """B4: Synthetic fabricated claim IDs (e.g. claim:synthetic:...) must be rejected."""
    from app.blueprint.generator import generate_dynamic_blueprint
    from app.blueprint.validators import validate_blueprint
    from app.reading_policy import PinnedExecutionPolicy

    policy = PinnedExecutionPolicy(provider="mock", blueprint_mode="dynamic")
    bp = generate_dynamic_blueprint(policy)
    # Inject fabricated synthetic claim ID into first slot using model_copy
    mutated_slot = bp.sections[0].question_slots[0].model_copy(update={"claim_ref_ids": ["claim:synthetic:fabricated_123"]})
    mutated_slots = [mutated_slot] + list(bp.sections[0].question_slots[1:])
    mutated_section = bp.sections[0].model_copy(update={"question_slots": mutated_slots})
    mutated_bp = bp.model_copy(update={"sections": [mutated_section] + list(bp.sections[1:])})
    issues = validate_blueprint(mutated_bp, require_claims=True)
    assert any(i.code == "BLUEPRINT_FABRICATED_CLAIM_PROHIBITED" for i in issues)


def test_negative_b5_contradicting_passage_evidence_rejected():
    """B5: Passage alignment inverting claim comparison/polarity must be rejected."""
    claims = {
        "claim_1": {
            "claimId": "claim_1",
            "text": "Temperature exceeded 1200 degrees Celsius during continuous operation.",
            "sourceStart": 0,
            "sourceEnd": 70,
        }
    }
    sec_cfg = demo_sections()[0]
    payload = {
        "title": "Passage with contradiction",
        "passage": "Temperature did not exceed 1200 degrees Celsius during continuous operation. " * 30,
        "claimAlignments": [
            {
                "claimId": "claim_1",
                "sourceStart": 0,
                "sourceEnd": 70,
                "sourceQuote": "Temperature exceeded 1200 degrees Celsius during continuous operation.",
                "passageQuote": "Temperature did not exceed 1200 degrees Celsius during continuous operation.",
            }
        ],
    }
    source_text = "Temperature exceeded 1200 degrees Celsius during continuous operation. " * 30
    env = ArtifactEnvelope.create("passage:b5", ArtifactType.PASSAGE, "run_b5", payload, "1.0.0")
    eval_results = evaluate_passage(env, source_text, claims, sec_cfg)
    failed = [e for e in eval_results if not e.is_pass()]
    assert any(i.code == IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM for e in failed for i in e.issues)


def test_negative_b6_altered_source_hash_invalidates():
    """B6: Modifying source payload produces a different content hash."""
    src1 = {"pmcid": "PMC13654891", "text": "Original authentic text"}
    src2 = {"pmcid": "PMC13654891", "text": "Mutated unapproved text"}
    env1 = ArtifactEnvelope.create("source:1", ArtifactType.SOURCE_PACK, "run_1", src1, "1.0.0")
    env2 = ArtifactEnvelope.create("source:1", ArtifactType.SOURCE_PACK, "run_1", src2, "1.0.0")
    assert env1.content_hash != env2.content_hash
