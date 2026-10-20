"""Consumer-visible numbering, finite budgets and immutable configuration guarantees."""
import pytest
from pydantic import ValidationError

from app.reading_policy import PinnedExecutionPolicy, SectionConfig, GroupConfig


def test_demo_allocates_exactly_forty_contiguous_questions():
    policy = PinnedExecutionPolicy(provider="mock")
    sections = policy.sections
    assert [(s.index, s.start_number, sum(g.count for g in s.groups)) for s in sections] == [
        (1, 1, 13), (2, 14, 13), (3, 27, 14)
    ]
    assert [[g.question_type.value for g in s.groups] for s in sections] == [
        ["TRUE_FALSE_NOT_GIVEN", "SENTENCE_COMPLETION"],
        ["MULTIPLE_CHOICE_SINGLE", "SUMMARY_COMPLETION"],
        ["YES_NO_NOT_GIVEN", "SHORT_ANSWER"],
    ]


@pytest.mark.parametrize("field,value", [
    ("provider_call_seconds", 181), ("provider_call_seconds", 0),
    ("section_wall_seconds", 901), ("section_wall_seconds", -1),
    ("section_token_cap", 100001), ("section_token_cap", 0),
    ("max_candidates", 0), ("max_repairs", -1),
])
def test_rejects_unbounded_or_over_cap_execution(field, value):
    with pytest.raises(ValidationError):
        PinnedExecutionPolicy(provider="mock", **{field: value})


def test_demo_allocations_are_configuration_not_section_identity():
    custom = SectionConfig(
        index=2, start_number=14,
        groups=(GroupConfig(question_type="SHORT_ANSWER", count=13),),
        difficulty="MODERATE", editorial_objective="Trace explicit scientific comparisons.",
    )
    original = PinnedExecutionPolicy(provider="mock")
    configured = PinnedExecutionPolicy(provider="mock", sections=(original.sections[0], custom, original.sections[2]))
    assert configured.sections[1].groups[0].question_type.value == "SHORT_ANSWER"
    assert configured.sections[1].groups[0].count == 13
    assert configured.hash != original.hash
    assert original.sections[1].groups[0].question_type.value == "MULTIPLE_CHOICE_SINGLE"


def test_rejects_overlapping_section_numbering():
    policy = PinnedExecutionPolicy(provider="mock")
    overlapping = policy.sections[1].model_copy(update={"start_number": 13})
    with pytest.raises(ValidationError):
        PinnedExecutionPolicy(provider="mock", sections=(policy.sections[0], overlapping, policy.sections[2]))


def test_policy_is_frozen_and_hash_survives_wire_roundtrip():
    policy = PinnedExecutionPolicy(provider="mock")
    restored = PinnedExecutionPolicy.model_validate_json(policy.model_dump_json(by_alias=True))
    assert restored.hash == policy.hash
    with pytest.raises(ValidationError):
        policy.section_token_cap = 1
