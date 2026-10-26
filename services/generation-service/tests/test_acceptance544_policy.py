"""Exact acceptance scope must not silently become dynamic or legacy allocation."""
import pytest
from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.reading_policy import PinnedExecutionPolicy, GroupConfig
from app.reading_generation import build_blueprint
from app.reading_evaluation import evaluate_blueprint


def policy():
    base = PinnedExecutionPolicy(provider="minimax")
    section = base.sections[0].model_copy(update={"groups": (
        GroupConfig(questionType="TRUE_FALSE_NOT_GIVEN", count=5),
        GroupConfig(questionType="TABLE_COMPLETION", count=4),
        GroupConfig(questionType="FLOW_CHART", count=4))})
    return PinnedExecutionPolicy.model_validate(dict(base.to_wire_dict(), blueprintMode="acceptance_5_4_4_v1", sections=[section.to_wire_dict() if hasattr(section, "to_wire_dict") else section.model_dump(by_alias=True)]))


def test_acceptance_rejects_incorrect_distribution():
    wire = policy().to_wire_dict()
    wire["sections"][0]["groups"][0]["count"] = 4
    with pytest.raises(ValueError, match="5/4/4"):
        PinnedExecutionPolicy.model_validate(wire)


def test_acceptance_cannot_allocate_thirteen_slots_from_one_eligible_claim():
    evidence = {"graphId": "eg", "sourcePackId": "src", "claims": [{"claimId": "c1", "sectionId": 1,
        "text": "During the construction process, workers heated copper material in a furnace for two hours.",
        "offsets": {"startChar": 0, "endChar": 101}, "verificationStatus": "VERIFIED", "isVerified": True}]}
    with pytest.raises(ValueError, match="eligible|distinct|claims"):
        build_blueprint("run", "offline", (1,), {}, {1: evidence}, policy())


def test_acceptance_blueprint_rejects_wrong_family_even_with_valid_numbering():
    p = policy()
    slots = [{"questionNumber": n, "questionType": "TRUE_FALSE_NOT_GIVEN", "claimRefIds": ["c1"]} for n in range(1,14)]
    art = ArtifactEnvelope.create("bp", ArtifactType.EXAM_BLUEPRINT, "run", {"sections": [{"sectionId": 1, "questionSlots": slots,
        "evidenceGraphRef": {"graphId": "eg"}, "passageObjectives": [{"objectiveId": "o"}]}]}, "1")
    assert not all(e.is_pass() for e in evaluate_blueprint(art, p, (1,)))
