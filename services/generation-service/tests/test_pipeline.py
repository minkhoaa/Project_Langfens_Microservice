"""Pipeline and generation contract tests for IELTS Reading paper generation."""
from __future__ import annotations

import json
from unittest.mock import AsyncMock, patch
from uuid import UUID

import pytest
from httpx import ASGITransport, AsyncClient

from app.extractor import parse_full_text
from app.main import app
from app.pipeline import (
    COUNTS,
    TYPES,
    _words,
    extend_passage,
    generate_section,
    repair_evidence,
    replace_rejected_question,
    review_answers,
    review_passage_source,
    trim_passage,
    validate_group_candidate,
    validate_passage_content,
    validate_section,
)
from app.prompts import build_group_instruction


def xml_with_license(license_url: str, words: int = 650) -> bytes:
    body = " ".join(["biodiversity"] * words)
    return (
        f'<article xmlns:xlink="http://www.w3.org/1999/xlink">'
        f"<front><article-title>Research title</article-title>"
        f"<contrib contrib-type='author'><name><given-names>Ada</given-names><surname>Example</surname></name></contrib>"
        f'<article-id pub-id-type="doi">10.1000/test</article-id>'
        f'<license xlink:href="{license_url}"/></front>'
        f"<body><sec><p>{body}</p></sec></body></article>"
    ).encode()


def valid_section(index: int) -> dict:
    passage = "Scientists found species in the forest and measured changes over time. " * 70
    assert 720 <= _words(passage) <= 915
    groups = []
    number = sum(sum(c) for c in COUNTS[: index - 1]) + 1
    for kind, count in zip(TYPES[index - 1], COUNTS[index - 1]):
        questions = []
        for _ in range(count):
            options = (
                ["TRUE", "FALSE", "NOT GIVEN"]
                if kind == "TRUE_FALSE_NOT_GIVEN"
                else ["YES", "NO", "NOT GIVEN"]
                if kind == "YES_NO_NOT_GIVEN"
                else ["A. forest", "B. ocean", "C. desert", "D. river"]
                if kind == "MULTIPLE_CHOICE_SINGLE"
                else []
            )
            questions.append(
                {
                    "number": number,
                    "prompt": f"What did scientists measure in question {number}? "
                    + (
                        f"[{number}]"
                        if kind in ("SENTENCE_COMPLETION", "SUMMARY_COMPLETION")
                        else ""
                    ),
                    "answer": options[0] if options else "species",
                    "options": options,
                    "evidenceQuote": "Scientists found species in the forest",
                    "explanation": "The passage explicitly states that scientists found species.",
                }
            )
            number += 1
        groups.append(
            {
                "type": kind,
                "instruction": build_group_instruction(
                    kind, questions[0]["number"], questions[-1]["number"]
                ),
                "questions": questions,
            }
        )
    return {"title": f"Passage {index}", "passage": passage, "groups": groups}


def test_generated_section_rejects_unsupported_and_duplicate_questions():
    section = valid_section(1)
    validate_section(section, 1)
    section["groups"][0]["questions"][0]["evidenceQuote"] = "an invented statement that is absent"
    with pytest.raises(ValueError, match="Evidence"):
        validate_section(section, 1)
    section = valid_section(1)
    section["groups"][0]["questions"][1]["prompt"] = section["groups"][0]["questions"][0]["prompt"]
    with pytest.raises(ValueError, match="Duplicate"):
        validate_section(section, 1)


def test_evidence_repair_does_not_replace_a_missing_quote_with_a_keyword_match():
    passage = "Scientists found species in the forest and measured changes over time. Another team studied oceans."
    missing_quote = "The scientists found many species within a forest."
    questions = [{"prompt": "Where did scientists find species?", "evidenceQuote": missing_quote}]
    repair_evidence(questions, passage)
    assert questions[0]["evidenceQuote"] == missing_quote


def test_completion_validation_accepts_three_words_and_a_number():
    passage = "The final result was 3.5 million learners."
    question = {
        "number": 8,
        "prompt": "The final result was [8].",
        "answer": "3.5 million learners",
        "options": [],
        "evidenceQuote": passage,
        "explanation": "The passage gives the final result in this exact phrase.",
    }
    validate_group_candidate("SENTENCE_COMPLETION", 1, 8, [question], passage)


def test_completion_validation_rejects_answer_leakage_in_stem():
    section = valid_section(1)
    section["groups"][1]["questions"][0]["prompt"] = "The forest contained species [8]."
    with pytest.raises(ValueError, match="leak"):
        validate_section(section, 1)


def test_section_validation_rejects_generic_completion_instruction():
    section = valid_section(1)
    section["groups"][1]["instruction"] = "Choose the correct answer based on the passage."
    with pytest.raises(ValueError, match="instruction"):
        validate_section(section, 1)


def test_section_validation_rejects_internal_section_heading_in_passage():
    section = valid_section(1)
    section["passage"] = "Section 3: Sustained Argument\n\n" + section["passage"]
    with pytest.raises(ValueError, match="internal section label"):
        validate_section(section, 1)


@pytest.mark.asyncio
async def test_answer_review_returns_a_verdict_and_reason_for_each_question():
    reviews = [
        {"number": 1, "valid": True, "issues": [], "reason": ""},
        {"number": 2, "valid": False, "issues": ["unsupported"], "reason": "The passage does not state this."},
    ]
    with patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate:
        generate.return_value = {"reviews": reviews}
        result = await review_answers(
            "Passage text.",
            [
                {
                    "type": "TRUE_FALSE_NOT_GIVEN",
                    "instruction": "...",
                    "questions": [
                        {"number": 1, "prompt": "Statement one", "answer": "TRUE"},
                        {"number": 2, "prompt": "Statement two", "answer": "NOT GIVEN"},
                    ],
                }
            ],
        )

    assert result == {1: reviews[0], 2: reviews[1]}
    instruction = generate.await_args.kwargs["variables"]["instruction"].casefold()
    assert "answer leakage" in instruction
    assert "multiple correct options" in instruction
    assert "connected summary" in instruction
    assert "direct phrase lookups" in instruction
    assert "too_direct" in instruction


@pytest.mark.asyncio
async def test_answer_review_rejects_a_missing_question_verdict():
    with patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate:
        generate.return_value = {"reviews": [{"number": 1, "valid": True, "issues": [], "reason": ""}]}
        with pytest.raises(ValueError, match="every question"):
            await review_answers(
                "Passage text.",
                [
                    {
                        "type": "TRUE_FALSE_NOT_GIVEN",
                        "instruction": "...",
                        "questions": [
                            {"number": 1, "prompt": "Statement one", "answer": "TRUE"},
                            {"number": 2, "prompt": "Statement two", "answer": "NOT GIVEN"},
                        ],
                    }
                ],
            )


@pytest.mark.asyncio
async def test_passage_source_review_reports_overstated_claims():
    findings = [
        {
            "claimQuote": "The tool caused a better result.",
            "issue": "causal_overstatement",
            "reason": "The source reports correlation only.",
        }
    ]
    with patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate:
        generate.return_value = {"passed": False, "findings": findings}
        result = await review_passage_source(
            "The study found a correlation between tool use and scores.",
            "The tool caused a better result.",
        )

    assert result == findings
    instruction = generate.await_args.kwargs["variables"]["instruction"].casefold()
    assert "correlation into causation" in instruction
    assert "outcomes the source did not measure" in instruction


@pytest.mark.asyncio
async def test_passage_source_review_rejects_conflicting_verdict():
    with patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate:
        generate.return_value = {
            "passed": True,
            "findings": [{"claimQuote": "Claim.", "issue": "unsupported_claim", "reason": "Not in source."}],
        }
        with pytest.raises(ValueError, match="conflicts with its findings"):
            await review_passage_source("Source.", "Passage.")

        generate.return_value = {"passed": False, "findings": []}
        with pytest.raises(ValueError, match="conflicts with its findings"):
            await review_passage_source("Source.", "Passage.")

@pytest.mark.asyncio
@pytest.mark.parametrize("issue", ["causal_overstatement", "overstated_certainty", "unsupported_claim"])
async def test_generation_fails_closed_when_causal_or_unsupported_findings_persist(issue):
    """Regression test: Unresolved causal overstatement, overstated certainty, or unsupported claims must fail closed."""
    generated = valid_section(1)
    article = {
        "pmcid": "PMC123",
        "title": "Research title",
        "doi": "10.1000/test",
        "url": "https://europepmc.org/articles/PMC123",
        "license": "https://creativecommons.org/licenses/by/4.0",
        "wordCount": 800,
        "authors": "Ada Example",
        "content": "Source text.",
    }
    persistent_finding = [{"claimQuote": "Claim quote.", "issue": issue, "reason": "Persistent fidelity defect."}]
    with patch("app.pipeline.fetch_source", new_callable=AsyncMock, return_value=article), \
         patch("app.pipeline.review_passage_source", new_callable=AsyncMock, return_value=persistent_finding) as mock_review, \
         patch("app.pipeline.generate_json", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = {"text": f"{generated['title']}\n\n{generated['passage']}"}
        from app.pipeline import _generate_section_once
        with pytest.raises(ValueError, match="Source-fidelity review rejected the revised passage"):
            await _generate_section_once(
                "Topic", 1, {"pmcid": "PMC123"},
                run_id="run_test", epoch=1,
                lease_owner=UUID("00000000-0000-0000-0000-000000000001"),
                parent_operation_id="op_test",
            )
        # Must have attempted revision loop and checked findings multiple times before failing closed
        assert mock_review.await_count >= 2

@pytest.mark.asyncio
@pytest.mark.parametrize("index", [1, 2, 3])
async def test_generation_uses_section_and_question_type_prompts(index):
    generated = valid_section(index)
    article = {
        "pmcid": "PMC123",
        "title": "Research title",
        "doi": "10.1000/test",
        "url": "https://europepmc.org/articles/PMC123",
        "license": "https://creativecommons.org/licenses/by/4.0",
        "wordCount": 800,
        "authors": "Ada Example",
        "content": "Source text.",
    }
    reviews = {
        number: {"number": number, "valid": True, "issues": [], "reason": ""}
        for group in generated["groups"]
        for q in group["questions"]
        for number in [q["number"]]
    }
    with patch("app.pipeline.fetch_source", new_callable=AsyncMock) as fetch, \
         patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate, \
         patch("app.pipeline.review_passage_source", new_callable=AsyncMock) as review_passage, \
         patch("app.pipeline.review_answers", new_callable=AsyncMock) as review_ans:
        fetch.return_value = article
        review_passage.return_value = []
        review_ans.return_value = reviews
        generate.side_effect = [
            {"text": f"{generated['title']}\n\n{generated['passage']}"},
            {"questions": generated["groups"][0]["questions"]},
            {"questions": generated["groups"][1]["questions"]},
        ]

        section = await generate_section(
            "topic", index, {"pmcid": "PMC123"},
            run_id="run_test", epoch=1,
            lease_owner=UUID("00000000-0000-0000-0000-000000000001"),
            parent_operation_id="op_test",
        )

    assert section["title"] == generated["title"]
    assert section["passage"] == generated["passage"].strip()
    passage_call = generate.await_args_list[0].kwargs
    passage_instruction = passage_call["variables"]["instruction"].casefold()
    assert "preserve the study's limitations" in passage_instruction
    assert "do not turn correlation into causation" in passage_instruction
    assert "do not include internal section labels" in passage_instruction
    assert ("must contain a sustained argument" in passage_instruction) is (index == 3)


@pytest.mark.asyncio
async def test_defensive_question_extraction_handles_bare_list():
    """Defensive extraction: LLM returning bare list [] should be parsed correctly."""
    generated = valid_section(1)
    article = {
        "pmcid": "PMC123",
        "title": "Research title",
        "doi": "10.1000/test",
        "url": "https://europepmc.org/articles/PMC123",
        "license": "https://creativecommons.org/licenses/by/4.0",
        "wordCount": 800,
        "authors": "Ada Example",
        "content": "Source text.",
    }
    reviews = {
        number: {"number": number, "valid": True, "issues": [], "reason": ""}
        for group in generated["groups"]
        for q in group["questions"]
        for number in [q["number"]]
    }
    with patch("app.pipeline.fetch_source", new_callable=AsyncMock) as fetch, \
         patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate, \
         patch("app.pipeline.review_passage_source", new_callable=AsyncMock) as review_passage, \
         patch("app.pipeline.review_answers", new_callable=AsyncMock) as review_ans:
        fetch.return_value = article
        review_passage.return_value = []
        review_ans.return_value = reviews
        # Bare list returned for question groups instead of {"questions": [...]}
        generate.side_effect = [
            {"text": f"{generated['title']}\n\n{generated['passage']}"},
            generated["groups"][0]["questions"],  # bare list
            generated["groups"][1]["questions"],  # bare list
        ]

        section = await generate_section(
            "topic", 1, {"pmcid": "PMC123"},
            run_id="run_test", epoch=1,
            lease_owner=UUID("00000000-0000-0000-0000-000000000001"),
            parent_operation_id="op_test",
        )
        assert len(section["groups"]) == 2
        assert len(section["groups"][0]["questions"]) == 7


@pytest.mark.asyncio
async def test_short_passage_is_extended():
    passage = "Scientists found species in the forest. " * 105  # ~420 words
    with patch("app.pipeline.generate_json", new_callable=AsyncMock) as generate:
        generate.return_value = {"text": "Researchers measured population changes over time. " * 32}
        extended = await extend_passage(passage, "Article text.", "Topic", index=1)

    assert _words(extended) > _words(passage)


def test_overlong_passage_is_trimmed():
    passage = "Scientists documented forest biodiversity in repeated annual surveys. " * 120
    trimmed = trim_passage(passage)
    assert 720 <= _words(trimmed) <= 900


@pytest.mark.asyncio
async def test_section_endpoint_ndjson_streaming(monkeypatch):
    monkeypatch.setenv("EXAMSERVICE__INTERNAL__API__KEY", "test-pipeline-key")
    auth_headers = {"X-Internal-Service-Key": "test-pipeline-key"}
    generated = valid_section(1)
    article = {
        "pmcid": "PMC123",
        "title": "Research title",
        "doi": "10.1000/test",
        "url": "https://europepmc.org/articles/PMC123",
        "license": "https://creativecommons.org/licenses/by/4.0",
        "wordCount": 800,
        "authors": "Ada Example",
        "content": "Source text.",
    }
    with patch("app.facade.GenerationFacade.generate_section", new_callable=AsyncMock) as mock_gen:
        async def fake_generate_section(topic, index, source, progress=None, **kwargs):
            if progress:
                await progress("Information", "Step 1 complete")
                await progress("Information", "Step 2 complete")
            return generated

        mock_gen.side_effect = fake_generate_section

        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test", headers=auth_headers) as ac:
            resp = await ac.post(
                "/api/v1/autogen/reading-paper/section",
                json={
                    "topic": "Biodiversity",
                    "index": 1,
                    "source": article,
                    "runId": "run_test",
                    "epoch": 1,
                    "leaseOwner": "00000000-0000-0000-0000-000000000001",
                    "parentOperationId": "op_test",
                },
                headers={"Accept": "application/x-ndjson"},
            )
            assert "application/x-ndjson" in resp.headers.get("content-type", "")

            lines = [json.loads(line) for line in resp.text.strip().split("\n") if line.strip()]
            types = [item["type"] for item in lines]
            assert "log" in types
            assert "result" in types
            result_item = next(item for item in lines if item["type"] == "result")
            assert result_item["section"]["title"] == generated["title"]
