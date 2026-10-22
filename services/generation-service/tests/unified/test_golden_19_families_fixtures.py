import json
from pathlib import Path
import pytest
from app.contracts.artifact import ArtifactEnvelope, ArtifactType
from app.contracts.question_type import QuestionPromptFamily
from app.reading_evaluation import evaluate_question
from app.section_runner import _parse_candidate_payload
from app.visual.evaluator import SvgVisualEvaluator

def test_golden_fixtures_cover_all_19_families():
    fixture_dir = Path(__file__).resolve().parents[1] / "fixtures/golden_19_families"
    manifest_file = fixture_dir / "all_19_families_manifest.json"
    assert manifest_file.exists(), "Manifest file all_19_families_manifest.json must exist"

    manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
    questions = manifest.get("questions", [])
    assert len(questions) >= 19, "Must contain at least 19 representative items"

    covered_types = set()
    svg_evaluator = SvgVisualEvaluator()

    for item in questions:
        q_type = item["questionType"]
        covered_types.add(q_type)
        provenance = item.get("provenance")
        assert provenance in ("minimax_live_accepted", "academically_grounded_golden_fixture"), (
            f"Invalid provenance '{provenance}' for {q_type}; must be explicitly labeled"
        )

        # 1. Parse candidate payload fail-closed
        parsed = _parse_candidate_payload(
            item["rawCandidate"],
            q_num=item["questionNumber"],
            q_type=q_type,
            passage_text=item["passageText"],
            claims_map=item["claimsMap"],
            claim_id=item["claimId"],
            difficulty=item.get("difficulty", "FOUNDATION"),
        )
        assert parsed["questionType"] == q_type
        assert len(parsed["explanation"]) >= 25, f"Explanation too short for {q_type}"
        assert parsed.get("answer") is not None or parsed.get("correctOption") is not None or parsed.get("answers") is not None

        # 2. Check for accidental answer leakage in prompt/statement
        prompt_text = (parsed.get("prompt") or parsed.get("statement") or "").lower()
        ans_str = str(parsed.get("answer") or "").lower()
        if q_type not in ("TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "CHOOSING_TITLE") and len(ans_str) > 3:
            # Multi-word completion answer should not be leaked in prompt
            assert ans_str not in prompt_text, f"Potential answer leakage: '{ans_str}' found in prompt '{prompt_text}'"

        # 3. For visual types (FLOW_CHART, DIAGRAM_LABEL), verify SVG compliance
        if q_type in ("FLOW_CHART", "DIAGRAM_LABEL"):
            svg_xml = item.get("svgXml")
            assert svg_xml, f"{q_type} fixture must supply an inline svgXml"
            res = svg_evaluator.evaluate(svg_xml, expected_callouts=[item["questionNumber"]])
            assert res.is_valid, f"SVG validation failed for {q_type}: {res.errors}"

        # 4. Mandatory fail-closed production evaluator verification
        envelope = ArtifactEnvelope.create(
            f"art_q_{item['questionNumber']}",
            ArtifactType.QUESTION,
            "run_golden_fixture",
            parsed,
            "1.0.0",
        )
        eval_results = evaluate_question(envelope, item["passageText"], item.get("difficulty", "FOUNDATION"), siblings=[])
        failed_evals = [e for e in eval_results if not e.is_pass()]
        assert not failed_evals, (
            f"Question {item['questionNumber']} ({q_type}) failed production evaluators: "
            f"{[(e.evaluator_id, [i.message for i in e.issues]) for e in failed_evals]}"
        )

    # Verify all 19 Academic Reading families are covered
    expected_19 = {
        QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN.value,
        QuestionPromptFamily.YES_NO_NOT_GIVEN.value,
        QuestionPromptFamily.SENTENCE_COMPLETION.value,
        QuestionPromptFamily.SUMMARY_COMPLETION.value,
        QuestionPromptFamily.SUMMARY_COMPLETION_BOX.value,
        QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE.value,
        QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE.value,
        QuestionPromptFamily.MATCHING_HEADING.value,
        QuestionPromptFamily.MATCHING_INFORMATION.value,
        QuestionPromptFamily.MATCHING_FEATURES.value,
        QuestionPromptFamily.MATCHING_ENDINGS.value,
        QuestionPromptFamily.TABLE_COMPLETION.value,
        QuestionPromptFamily.FLOW_CHART.value,
        QuestionPromptFamily.DIAGRAM_LABEL.value,
        QuestionPromptFamily.SHORT_ANSWER.value,
        QuestionPromptFamily.NOTE_COMPLETION.value,
        QuestionPromptFamily.FORM_COMPLETION.value,
        QuestionPromptFamily.CLASSIFICATION.value,
        QuestionPromptFamily.CHOOSING_TITLE.value,
    }
    missing = expected_19 - covered_types
    assert not missing, f"Missing IELTS Academic Reading families: {missing}"
