from app.prompts.writing_grade_criterion import (
    build_criterion_evidence_block,
    build_grade_prompt_criterion,
)

def test_evidence_block_renders_four_sections():
    refs_by_criterion = {
        "ta": [{"id": "ref-1", "text": "intro body", "band": 7.0}],
        "cc": [],
        "lr": [{"id": "ref-2", "text": "vocab", "band": 8.0}],
        "gr": [],
    }
    block = build_criterion_evidence_block(refs_by_criterion)
    assert "## Task Response" in block
    assert "## Coherence & Cohesion" in block
    assert "## Lexical Resource" in block
    assert "## Grammatical Range & Accuracy" in block
    assert "[ref-1]" in block
    assert "[ref-2]" in block
    # empty buckets must still be present so the LLM knows to look
    assert "No reference essays retrieved" in block

def test_prompt_includes_evidence_block_and_json_shape():
    prompt = build_grade_prompt_criterion(
        task="T",
        essay="E",
        word_count=300,
        rag_by_criterion={"ta": [], "cc": [], "lr": [], "gr": []},
        task_type="TASK_2",
    )
    assert "<criterion_evidence>" in prompt
    assert "evidence_ids" in prompt
    # The existing WRITING_GRADE_PROMPT_TASK2 body uses f-string-escaped
    # braces ({{ / }}), so the literal JSON keys are prefixed with `{`.
    # We assert on the key names to verify the JSON shape survived.
    assert '"ta":' in prompt
    assert '"b":' in prompt
    assert "## Task Response" in prompt
