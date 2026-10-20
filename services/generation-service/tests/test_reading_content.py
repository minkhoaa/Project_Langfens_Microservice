"""Pure content contracts for the authoritative reading pipeline; never dispatch a provider."""
from datetime import datetime, timezone

import pytest

from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.evidence import EvidenceGraph, SourceOffset, VerifiedClaim
from app.contracts.policies import count_words
from app.reading_evaluation import (
    PAPER_EVALUATORS, evaluate_evidence, evaluate_passage, evaluate_paper,
    evaluate_question, result,
)
from app.reading_generation import build_blueprint, build_evidence, prepare_source
from app.reading_models import SourceInput
from app.reading_policy import PinnedExecutionPolicy


@pytest.fixture
def policy():
    return PinnedExecutionPolicy(provider="mock")


@pytest.fixture
def source():
    text = "\n\n".join(
        f"Researchers examined coastal habitat {i} using carefully recorded observations. "
        f"The measured response in habitat {i} was associated with seasonal variation. "
        "The observations may support a mechanism but do not establish universal causation. "
        "Independent teams compared their findings and discussed limitations of the method."
        for i in range(16)
    )
    return SourceInput(sectionIndex=1, pmcid="PMC1234567", title="Coastal habitat research",
                       url="https://pmc.ncbi.nlm.nih.gov/articles/PMC1234567/",
                       license="https://creativecommons.org/licenses/by/4.0/",
                       authors="A. Researcher", content=text)


def envelope(kind, payload, parents=(), artifact_id="artifact"):
    return ArtifactEnvelope.create(artifact_id, kind, "run-test", payload, "test/1", parent_refs=parents)


@pytest.mark.asyncio
async def test_source_normalizes_and_chunks_with_exact_offsets(source, policy):
    payload = await prepare_source(source, "run-test", policy)
    text = payload["sources"][0]["document"]["text"]
    assert count_words(text) >= policy.source_min_words
    assert payload["licenseCleared"] is True
    assert payload["rawContentHash"] != ""
    assert all(text[c["start_char"]:c["end_char"]] == c["text"] for c in payload["chunks"])


@pytest.mark.asyncio
@pytest.mark.parametrize("updates", [
    {"license": "unknown"}, {"license": "all rights reserved"},
    {"license": "not-cc-by"}, {"url": "http://invalid.test/PMC1234567"},
    {"content": "A short source."},
])
async def test_source_fails_closed_on_invalid_provenance_license_or_length(source, policy, updates):
    with pytest.raises(ValueError):
        await prepare_source(source.model_copy(update=updates), "run-test", policy)


@pytest.mark.asyncio
async def test_evidence_claims_have_exact_noncontradictory_offsets(source, policy):
    pack = await prepare_source(source, "run-test", policy)
    graph = build_evidence(pack, "run-test", 1, policy)
    text = pack["sources"][0]["document"]["text"]
    assert len(graph["claims"]) >= policy.min_verified_claims
    for claim in graph["claims"]:
        offsets = claim["offsets"]
        assert text[offsets["startChar"]:offsets["endChar"]] == claim["text"]


def test_evidence_rejects_offset_mismatch():
    graph = EvidenceGraph(graphId="graph", runId="run-test", claims=[
        VerifiedClaim(claimId="claim", text="A verified scientific claim.", sourceId="source",
                      offsets=SourceOffset(sourceId="source", startChar=1, endChar=29))])
    artifact = envelope(ArtifactType.EVIDENCE_GRAPH, graph.model_dump(mode="json", by_alias=True))
    evaluations = evaluate_evidence(artifact, {"source": "A verified scientific claim."}, 1)
    assert evaluations and not all(e.is_pass() for e in evaluations)


@pytest.mark.asyncio
async def test_one_blueprint_covers_all_selected_sections_before_provider_work(source, policy):
    sources = {}
    evidence = {}
    for index in (1, 2, 3):
        data = source.model_copy(update={"section_index": index, "pmcid": f"PMC123456{index}"})
        pack = await prepare_source(data, "run-test", policy)
        sources[index] = envelope(ArtifactType.SOURCE_PACK, pack, artifact_id=f"source-{index}")
        graph = build_evidence(pack, "run-test", index, policy)
        evidence[index] = envelope(ArtifactType.EVIDENCE_GRAPH, graph, (sources[index].to_ref(),), f"graph-{index}")
    blueprint = build_blueprint("run-test", "Coastal research", (1, 2, 3), sources, evidence, policy)
    assert [s["sectionId"] for s in blueprint["sections"]] == [1, 2, 3]
    assert [q["questionNumber"] for s in blueprint["sections"] for q in s["questionSlots"]] == list(range(1, 41))
    assert blueprint["totalQuestions"] == 40
    impossible = policy.model_copy(update={"run_token_cap": 1})
    with pytest.raises(ValueError, match="budget|Budget"):
        build_blueprint("run-test", "Coastal research", (1, 2, 3), sources, evidence, impossible)


def test_numeric_and_scientific_drift_fail_deterministically(policy):
    artifact = envelope(ArtifactType.PASSAGE, {
        "title": "Research", "passage": "The observed concentration was 50 milligrams in humans.",
        "claimAlignments": []})
    results = evaluate_passage(artifact, "The observed concentration was 5 milligrams in mice.", {}, policy.sections[0])
    assert not all(e.is_pass() for e in results)
    assert any(e.evaluator_id == "eval_passage_fidelity" and not e.is_pass() for e in results)


def test_question_rejects_nonverbatim_answer_and_invalid_offsets():
    passage = "The researchers sampled coastal sediment using a calibrated instrument."
    artifact = envelope(ArtifactType.QUESTION, {
        "questionNumber": 1, "questionType": "SHORT_ANSWER", "prompt": "What was sampled?",
        "answer": "moon rocks", "evidenceQuote": passage, "explanation": "The sample was explicitly identified in the passage.",
        "passageEvidence": {"startChar": 1, "endChar": len(passage), "text": passage}, "evidenceClaimRef": "claim"})
    assert not all(e.is_pass() for e in evaluate_question(artifact, passage, "FOUNDATION", ()))


def test_paper_requires_exactly_three_sections_and_forty_questions(policy):
    artifact = envelope(ArtifactType.READING_PAPER, {
        "sections": [], "totalQuestions": 0, "totalWords": 0,
        "sectionRefs": [], "passageRefs": [], "questionRefs": []})
    evaluations = evaluate_paper(artifact, policy)
    assert {e.evaluator_id: e.evaluator_version for e in evaluations if e.evaluator_id in PAPER_EVALUATORS} == PAPER_EVALUATORS
    assert not all(e.is_pass() for e in evaluations)
    assert all(e.target_ref == artifact.to_ref() and tuple(e.input_dependency_refs) == artifact.parent_refs for e in evaluations)


def test_evaluation_is_bound_to_target_dependencies_and_fresh_timestamp():
    artifact = envelope(ArtifactType.SOURCE_PACK, {"sources": []})
    evaluation = result(artifact, "eval_source", ())
    assert evaluation.is_pass()
    assert evaluation.target_ref == artifact.to_ref()
    assert evaluation.evaluated_at >= artifact.created_at
    assert evaluation.evaluated_at <= datetime.now(timezone.utc)
