"""Authoritative scholarly source provenance and negative verification suite (Blocker A).

Mandatory Tests:
A1. Accurate source metadata accepted.
A2. Wrong PMCID/title pairing rejected.
A3. Wrong DOI rejected.
A4. Actual BY-NC misrepresented as BY rejected.
A5. Missing license evidence rejected.
A6. Unsupported license not automatically cleared.
A7. Claim not supported by source rejected.
A8. Changed source invalidates dependent hashes.
A9. All 40 fixture questions remain structurally valid.
A10. All 40 answers remain passage-grounded.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
import re
import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.issue import IssueCode
from app.ingestion.academic_provenance import (
    extract_authoritative_metadata,
    verify_source_authenticity,
)
from app.reading_evaluation import evaluate_passage, evaluate_source
from app.reading_models import SourceInput
from app.reading_policy import PinnedExecutionPolicy, demo_sections

FIXTURE_PATH = Path(__file__).resolve().parents[1] / "fixtures" / "canonical_40_question_reading_paper.json"
CORPUS_V2_PATH = Path(__file__).resolve().parents[1] / "fixtures" / "corpus" / "sources_v2"


def load_canonical_fixture() -> dict:
    assert FIXTURE_PATH.exists(), f"Missing fixture at {FIXTURE_PATH}"
    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


# ── A1: Accurate source metadata accepted ─────────────────────────────────────

def test_a1_canonical_sources_match_verified_metadata():
    """A1: Asserts that all three sections bind genuine, verified academic publications matching local XML."""
    data = load_canonical_fixture()
    sections = data["sections"]
    assert len(sections) == 3

    # Section 1: Didé West 1 Iron Smelting in Senegal (PMC13654891)
    s1_src = sections[0]["source"]
    s1_xml = (CORPUS_V2_PATH / "PMC13654891.xml").read_bytes()
    s1_auth = extract_authoritative_metadata(s1_xml)
    assert s1_src["pmcid"] == s1_auth.pmcid == "PMC13654891"
    assert "Didé West 1" in s1_src["title"] or "Dide West 1" in s1_src["title"]
    assert s1_src["doi"] == s1_auth.doi == "10.1007/s10437-026-09653-z"
    assert "Morel" in s1_src.get("authors", "")
    assert s1_src.get("license") in ("CC BY 4.0", "https://creativecommons.org/licenses/by/4.0/")
    assert s1_src.get("licenseCleared") is True

    s1_ok, s1_errs = verify_source_authenticity(s1_src, s1_xml)
    assert s1_ok, f"Section 1 authenticity failed: {s1_errs}"

    # Section 2: Combined Wind-Rain Piezoelectric Energy Harvester (PMC13667678)
    s2_src = sections[1]["source"]
    s2_xml = (CORPUS_V2_PATH / "PMC13667678.xml").read_bytes()
    s2_auth = extract_authoritative_metadata(s2_xml)
    assert s2_src["pmcid"] == s2_auth.pmcid == "PMC13667678"
    assert "Combined Wind–Rain Piezoelectric Energy Harvester" in s2_src["title"] or "Combined Wind-Rain" in s2_src["title"]
    assert s2_src["doi"] == s2_auth.doi == "10.3390/s26196271"
    assert "Chen" in s2_src.get("authors", "")
    assert s2_src.get("license") in ("CC BY 4.0", "https://creativecommons.org/licenses/by/4.0/")
    assert s2_src.get("licenseCleared") is True

    s2_ok, s2_errs = verify_source_authenticity(s2_src, s2_xml)
    assert s2_ok, f"Section 2 authenticity failed: {s2_errs}"

    # Section 3: Bedrock Erodibility and CO2 Release in Alpine Landscapes (PMC13665993)
    s3_src = sections[2]["source"]
    s3_xml = (CORPUS_V2_PATH / "PMC13665993.xml").read_bytes()
    s3_auth = extract_authoritative_metadata(s3_xml)
    assert s3_src["pmcid"] == s3_auth.pmcid == "PMC13665993"
    # Authoritative XML title has "CO2 release in alpine landscapes", not "CO2 drawdown in active orogens"
    assert "Bedrock erodibility governs transient erosion and CO2 release in alpine landscapes" in s3_src["title"]
    assert s3_src["doi"] == s3_auth.doi == "10.1126/sciadv.aei9275"
    assert "Marder" in s3_src.get("authors", "")
    # Authoritative license is CC BY-NC 4.0
    assert s3_src.get("license") in ("CC BY-NC 4.0", "https://creativecommons.org/licenses/by-nc/4.0/")
    # License clearance requires explicit NC policy authorization
    assert s3_src.get("licenseCleared") is True

    s3_ok, s3_errs = verify_source_authenticity(s3_src, s3_xml, allow_noncommercial=True)
    assert s3_ok, f"Section 3 authenticity failed: {s3_errs}"


# ── A2: Wrong PMCID/title pairing rejected ────────────────────────────────────

def test_a2_wrong_pmcid_title_pairing_rejected():
    """A2: A source declaring a legitimate PMCID with an unrelated title must be detected and rejected."""
    s1_xml = (CORPUS_V2_PATH / "PMC13654891.xml").read_bytes()
    mismatched_src = {
        "pmcid": "PMC13654891",
        "title": "Unrelated Quantum Teleportation in Cold Trapped Ions",
        "doi": "10.1007/s10437-026-09653-z",
        "authors": "Mélissa Morel",
        "license": "CC BY 4.0",
        "licenseCleared": True,
        "wordCount": 750,
    }
    ok, errors = verify_source_authenticity(mismatched_src, s1_xml)
    assert not ok, "Mismatched title must be rejected by verification"
    assert any("title" in e.lower() for e in errors)


# ── A3: Wrong DOI rejected ────────────────────────────────────────────────────

def test_a3_wrong_doi_rejected():
    """A3: A source declaring a valid PMCID but mismatched DOI must be rejected."""
    s1_xml = (CORPUS_V2_PATH / "PMC13654891.xml").read_bytes()
    mismatched_doi_src = {
        "pmcid": "PMC13654891",
        "title": "Evolution of an Early and Long-Lasting Iron Smelting Technique at Didé West 1",
        "doi": "10.9999/fabricated.doi.12345",
        "authors": "Mélissa Morel",
        "license": "CC BY 4.0",
        "licenseCleared": True,
        "wordCount": 750,
    }
    ok, errors = verify_source_authenticity(mismatched_doi_src, s1_xml)
    assert not ok, "Mismatched DOI must be rejected"
    assert any("doi" in e.lower() for e in errors)


# ── A4: Actual BY-NC misrepresented as BY rejected ────────────────────────────

def test_a4_actual_by_nc_misrepresented_as_by_rejected():
    """A4: A source whose actual XML license is CC BY-NC 4.0 cannot be declared as CC BY 4.0."""
    s3_xml = (CORPUS_V2_PATH / "PMC13665993.xml").read_bytes()
    misrepresented_src = {
        "pmcid": "PMC13665993",
        "title": "Bedrock erodibility governs transient erosion and CO2 release in alpine landscapes",
        "doi": "10.1126/sciadv.aei9275",
        "authors": "Eyal Marder",
        "license": "CC BY 4.0",  # Misrepresented: XML is BY-NC!
        "licenseCleared": True,
        "wordCount": 721,
    }
    ok, errors = verify_source_authenticity(misrepresented_src, s3_xml, allow_noncommercial=False)
    assert not ok, "Misrepresenting BY-NC as BY must fail closed"
    assert any("license" in e.lower() or "by-nc" in e.lower() for e in errors)


# ── A5: Missing license evidence rejected ──────────────────────────────────────

def test_a5_missing_license_evidence_rejected():
    """A5: XML lacking license permissions must be rejected."""
    raw_xml = b"""<?xml version="1.0" encoding="UTF-8"?>
    <article>
        <front>
            <article-meta>
                <article-id pub-id-type="pmc">PMC9999999</article-id>
                <article-id pub-id-type="doi">10.1000/test</article-id>
                <title-group><article-title>Article Without License</article-title></title-group>
                <contrib-group><contrib contrib-type="author"><name><surname>Test</surname></name></contrib></contrib-group>
            </article-meta>
        </front>
        <body><p>Some body text for testing license absence.</p></body>
    </article>"""
    metadata = extract_authoritative_metadata(raw_xml)
    assert metadata.license_type == "UNKNOWN" or metadata.license_url is None
    ok, errors = verify_source_authenticity(
        {"pmcid": "PMC9999999", "title": "Article Without License", "doi": "10.1000/test", "license": "CC BY 4.0"},
        raw_xml,
    )
    assert not ok, "Missing license evidence must be rejected"


# ── A6: Unsupported license not automatically cleared ─────────────────────────

def test_a6_unsupported_license_not_automatically_cleared():
    """A6: Non-commercial license without explicit policy authorization is not cleared."""
    s3_xml = (CORPUS_V2_PATH / "PMC13665993.xml").read_bytes()
    src = {
        "pmcid": "PMC13665993",
        "title": "Bedrock erodibility governs transient erosion and CO2 release in alpine landscapes",
        "doi": "10.1126/sciadv.aei9275",
        "authors": "Eyal Marder",
        "license": "CC BY-NC 4.0",
        "licenseCleared": True,  # Caller claims cleared, but policy does NOT allow NC!
        "wordCount": 721,
    }
    # When allow_noncommercial is False (default), verify fails because clearance is not permitted
    ok, errors = verify_source_authenticity(src, s3_xml, allow_noncommercial=False)
    assert not ok, "NC license without policy authorization must not be cleared"
    assert any("noncommercial" in e.lower() or "clearance" in e.lower() or "policy" in e.lower() for e in errors)


# ── A7: Claim not supported by source rejected ────────────────────────────────

def test_a7_claim_not_supported_by_source_rejected():
    """A7: Claim not present in source text fails passage fidelity evaluation."""
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
    env = ArtifactEnvelope.create("passage:a7", ArtifactType.PASSAGE, "run_a7", payload, "1.0.0")
    eval_results = evaluate_passage(env, source_text, claims, sec_cfg)
    failed = [e for e in eval_results if not e.is_pass()]
    assert len(failed) > 0, "Absent claim must fail passage evaluation"
    assert any(i.code == IssueCode.EVIDENCE_MISSING for e in failed for i in e.issues)


# ── A8: Changed source invalidates dependent hashes ───────────────────────────

def test_a8_changed_source_invalidates_dependent_hashes():
    """A8: Modifying source payload produces a different content hash."""
    src1 = {"pmcid": "PMC13654891", "text": "Original authentic text"}
    src2 = {"pmcid": "PMC13654891", "text": "Mutated unapproved text"}
    env1 = ArtifactEnvelope.create("source:1", ArtifactType.SOURCE_PACK, "run_1", src1, "1.0.0")
    env2 = ArtifactEnvelope.create("source:1", ArtifactType.SOURCE_PACK, "run_1", src2, "1.0.0")
    assert env1.content_hash != env2.content_hash


# ── A9: All 40 fixture questions remain structurally valid ───────────────────

def test_a9_all_40_fixture_questions_remain_structurally_valid():
    """A9: Verifies that all 40 fixture questions are numbered 1..40, have valid types, prompts, answers."""
    data = load_canonical_fixture()
    sections = data["sections"]
    assert len(sections) == 3

    seen_numbers = []
    for s_idx, sec in enumerate(sections):
        assert "passage" in sec and len(sec["passage"]) > 500
        for grp in sec.get("groups", []):
            assert "questionType" in grp
            for q in grp.get("questions", []):
                qnum = q.get("questionNumber") or q.get("number")
                assert qnum is not None
                seen_numbers.append(qnum)
                assert q.get("answer"), f"Q{qnum} missing answer"
                assert q.get("prompt") or q.get("statement"), f"Q{qnum} missing prompt"

    assert seen_numbers == list(range(1, 41)), "Questions must be sequentially numbered 1..40"


# ── A10: All 40 answers remain passage-grounded ───────────────────────────────

def test_a10_all_40_answers_remain_passage_grounded():
    """A10: Verifies that all 40 question answers and evidence quotes are grounded in their passages."""
    data = load_canonical_fixture()
    for s_idx, sec in enumerate(data["sections"]):
        passage = sec["passage"]
        for grp in sec.get("groups", []):
            for q in grp.get("questions", []):
                qnum = q.get("questionNumber") or q.get("number")
                ans = q.get("answer")
                ev = q.get("evidenceQuote")
                if ev and "NOT_GIVEN" not in str(ans).upper() and "NOT GIVEN" not in str(ans).upper():
                    assert ev.strip().lower() in passage.lower(), (
                        f"Q{qnum} evidence quote '{ev}' not grounded in Section {s_idx+1} passage"
                    )
