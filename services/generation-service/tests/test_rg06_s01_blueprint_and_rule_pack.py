"""Unit tests for RG06-S01: Grammar exercise blueprint and rule pack."""

import json
from pathlib import Path
import jsonschema
import pytest
from pydantic import ValidationError

from app.contracts.research import (
    GrammarExerciseType,
    GrammarRulePack,
    GrammarTask,
    SourceRef,
    StandaloneGrammarRequest,
)


def load_schemas():
    schema_path = (
        Path(__file__).resolve().parents[3]
        / "generation_baseline"
        / "contracts"
        / "JSON_SCHEMAS.json"
    )
    return json.loads(schema_path.read_text())


def test_pos_rg06_s01_valid_grammar_blueprint_and_rule_pack():
    """POS-RG06-S01: Every generated unit pins rule version, license and difficulty target."""
    schemas = load_schemas()

    source = SourceRef(
        source_id="src-cambridge-grammar-01",
        source_family="cambridge_advanced_grammar",
        source_version="v2.1",
        source_sha256="a" * 64,
        license="CC-BY-SA-4.0",
        provenance_uri="https://grammar.cambridge.org/rules/conditional-inversion",
    )

    rule_pack = GrammarRulePack(
        rule_pack_id="grp-inversion-01",
        source=source,
        topic="Inversion in Conditional Sentences",
        level="C1",
        rule_ids=["rule-inv-01", "rule-inv-02"],
        applicability=[
            "Use 'Had I known...' in third conditional inverted structures without 'if'.",
            "Use 'Were you to ask...' in second conditional structures.",
        ],
        exceptions=[
            "Do not contract negated inverted verbs: 'Had I not known', NEVER 'Hadn't I known'."
        ],
        examples=[
            "Had we known about the storm, we would have postponed the flight.",
            "Were they to offer him the position, he would accept it.",
        ],
    )

    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref=rule_pack.rule_pack_id,
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=5,
        difficulty="C1",
    )

    req = StandaloneGrammarRequest(
        run_id="run-gram-01",
        dataset_item_id="gram-item-01",
        configuration_id="A",
        task=task,
        rule_pack=rule_pack,
    )

    # 1. Assert required pins
    assert req.rule_pack.source.source_version == "v2.1"
    assert req.rule_pack.source.license == "CC-BY-SA-4.0"
    assert req.task.difficulty == "C1"
    assert req.is_research_mode is True

    # 2. Validate against official JSON_SCHEMAS.json
    jsonschema.Draft202012Validator(
        {
            "$schema": schemas["$schema"],
            "$defs": schemas["$defs"],
            "$ref": "#/$defs/GrammarRulePack",
        }
    ).validate(rule_pack.model_dump())

    jsonschema.Draft202012Validator(
        {
            "$schema": schemas["$schema"],
            "$defs": schemas["$defs"],
            "$ref": "#/$defs/GrammarTask",
        }
    ).validate(task.model_dump())


def test_neg_rg06_s01_no_assumption_rule_validates_answer():
    """NEG-RG06-S01: No assumption that a retrieved rule validates generated answer.

    Rule provenance is not misrepresented as independently verified question gold.
    StandaloneGrammarRequest forbids marking rule_pack as gold answer authority.
    """
    source = SourceRef(
        source_id="src-cambridge-grammar-01",
        source_family="cambridge_advanced_grammar",
        source_version="v2.1",
        source_sha256="b" * 64,
        license="CC-BY-SA-4.0",
        provenance_uri="https://grammar.cambridge.org/rules/subjunctive",
    )

    rule_pack = GrammarRulePack(
        rule_pack_id="grp-subjunctive-01",
        source=source,
        topic="Present Subjunctive",
        level="B2",
        rule_ids=["rule-subj-01"],
        applicability=["Mandative subjunctive uses base verb form after demand/insist."],
        exceptions=["Informal British English often uses 'should + infinitive'."],
        examples=["I insist that he be present."],
    )

    task = GrammarTask(
        task_type="GRAMMAR_EXERCISE",
        grammar_rule_pack_ref=rule_pack.rule_pack_id,
        exercise_type=GrammarExerciseType.MCQ_SINGLE,
        requested_question_count=5,
        difficulty="B2",
    )

    req = StandaloneGrammarRequest(
        run_id="run-gram-neg-01",
        dataset_item_id="gram-item-neg-01",
        configuration_id="A",
        task=task,
        rule_pack=rule_pack,
    )

    # 1. Reject smuggling gold/verified authority into GrammarRulePack
    with pytest.raises(ValidationError):
        GrammarRulePack(
            rule_pack_id="grp-subjunctive-01",
            source=source,
            topic="Present Subjunctive",
            level="B2",
            rule_ids=["rule-subj-01"],
            applicability=["Mandative subjunctive uses base verb form after demand/insist."],
            exceptions=[],
            examples=["I insist that he be present."],
            gold_answer="be",  # FORBIDDEN: rule pack cannot claim question gold!
        )

    # 2. Reject smuggling verified gold answers into StandaloneGrammarRequest
    with pytest.raises(ValidationError):
        StandaloneGrammarRequest(
            run_id="run-gram-neg-02",
            dataset_item_id="gram-item-neg-02",
            configuration_id="A",
            task=task,
            rule_pack=rule_pack,
            verified_question_gold={"q1": "be"},  # FORBIDDEN!
        )

    # 3. Reject mutating rule pack or request in place (frozen=True)
    with pytest.raises(ValidationError):
        req.is_research_mode = False

    with pytest.raises(ValidationError):
        rule_pack.topic = "Mutated topic"

def test_edge_rg06_s01_malformed_and_missing_inputs():
    """EDGE-RG06-S01: Missing, empty, or malformed fields are safely rejected."""
    # 1. Invalid SHA256 length or non-hex
    with pytest.raises(ValidationError):
        SourceRef(
            source_id="src-invalid-sha",
            source_family="test",
            source_version="v1",
            source_sha256="not-a-valid-sha256-hex-digest",
            license="MIT",
            provenance_uri="uri://test",
        )

    # 2. Empty rule_ids
    with pytest.raises(ValidationError):
        GrammarRulePack(
            rule_pack_id="grp-empty-rules",
            source=SourceRef(
                source_id="src-test",
                source_family="test",
                source_version="v1",
                source_sha256="c" * 64,
                license="MIT",
                provenance_uri="uri://test",
            ),
            topic="Test",
            level="B1",
            rule_ids=[],  # Empty!
            applicability=["Applicable"],
            exceptions=[],
            examples=["Example"],
        )

    # 3. Empty examples
    with pytest.raises(ValidationError):
        GrammarRulePack(
            rule_pack_id="grp-empty-examples",
            source=SourceRef(
                source_id="src-test",
                source_family="test",
                source_version="v1",
                source_sha256="c" * 64,
                license="MIT",
                provenance_uri="uri://test",
            ),
            topic="Test",
            level="B1",
            rule_ids=["rule-1"],
            applicability=["Applicable"],
            exceptions=[],
            examples=[],  # Empty!
        )


def test_reg_rg06_s01_standalone_reading_and_existing_contracts_unaffected():
    """REG-RG06-S01: Adding grammar contracts does not mutate or regress ReadingTask."""
    from app.contracts.research import ReadingTask, StandaloneGroupType

    schemas = load_schemas()

    # 1. StandaloneGroupType must strictly contain ONLY the 6 frozen reading groups
    assert set(StandaloneGroupType.__members__.keys()) == {
        "TFNG",
        "SENTENCE_COMPLETION",
        "MCQ_SINGLE",
        "SUMMARY_COMPLETION",
        "YNNG",
        "SHORT_ANSWER",
    }

    # 2. ReadingTask must strictly reject any grammar group
    with pytest.raises(ValidationError):
        ReadingTask(
            task_type="READING_SINGLE_PASSAGE",
            requested_groups=["GRAMMAR_MCQ"],  # Forbidden in ReadingTask!
            requested_question_count=5,
            difficulty="B2",
        )

    # 3. Valid reading task validates against official JSON_SCHEMAS.json
    reading_task = ReadingTask(
        task_type="READING_SINGLE_PASSAGE",
        requested_groups=[StandaloneGroupType.TFNG],
        requested_question_count=6,
        difficulty="B2",
    )
    assert reading_task.task_type == "READING_SINGLE_PASSAGE"
    assert reading_task.requested_groups == [StandaloneGroupType.TFNG]

    jsonschema.Draft202012Validator(
        {
            "$schema": schemas["$schema"],
            "$defs": schemas["$defs"],
            "$ref": "#/$defs/ReadingTask",
        }
    ).validate(reading_task.model_dump())
