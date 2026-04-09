import asyncio
import logging

from fastapi import HTTPException
from langchain_core.exceptions import OutputParserException

from app.config import settings
from app.prompts.grammar_explain import GRAMMAR_EXPLAIN_PROMPT
from app.schemas import (
    GrammarBatchExplainResponse,
    GrammarExplainRequest,
    GrammarExplainResponse,
    SearchResult,
)
from app.services import gemini_service, search_service

logger = logging.getLogger(__name__)

VALID_CATEGORIES = {"tense", "subject-verb", "word-order", "article", "preposition", "pronoun", "collocation", "other"}


def _format_relevant_rules(rules: list[SearchResult]) -> str:
    """Format retrieved grammar rules for the prompt."""
    if not rules:
        return "No relevant grammar rules found in the knowledge base."
    parts = []
    for i, rule in enumerate(rules, 1):
        parts.append(f"--- Rule {i} ---\n{rule.text}")
    return "\n\n".join(parts)


def _parse_category(category: str) -> str:
    """Parse and validate category from LLM response."""
    if not category:
        return "other"
    normalized = category.lower().strip()
    return normalized if normalized in VALID_CATEGORIES else "other"


def _parse_grammar_response(raw_result: dict, error_text: str) -> GrammarExplainResponse:
    """Parse and validate grammar explanation from LLM response."""
    explanation = raw_result.get("explanation", "").strip()
    rule_description = raw_result.get("rule_description", "").strip()
    correct_form = raw_result.get("correct_form", error_text).strip()
    examples = raw_result.get("examples", [])
    if isinstance(examples, list):
        examples = [ex.strip() for ex in examples if isinstance(ex, str) and ex.strip()]
    category = _parse_category(raw_result.get("category", "other"))

    if not explanation:
        explanation = "An error occurred while generating the explanation."
    if not rule_description:
        rule_description = "Grammar rule explanation"
    if not correct_form:
        correct_form = error_text
    if not examples:
        examples = ["(No examples provided)"]

    return GrammarExplainResponse(
        explanation=explanation,
        rule_description=rule_description,
        correct_form=correct_form,
        examples=examples,
        category=category,
    )


async def explain_single(request: GrammarExplainRequest) -> GrammarExplainResponse:
    """Explain a single grammar error."""
    # Search for relevant grammar rules
    rules = await search_service.search(
        collection=settings.qdrant_collection_grammar,
        query=request.error_text,
        top_k=3,
        filters={},
    )

    # Prepare prompt variables
    variables = {
        "error_text": request.error_text,
        "context": request.context,
        "correct_form": request.correct_form,
        "language": request.language,
        "relevant_rules": _format_relevant_rules(rules),
    }

    try:
        if settings.use_ollama:
            result = await ollama_service.generate(
                prompt_template=GRAMMAR_EXPLAIN_PROMPT,
                variables=variables,
            )
        else:
            result = await gemini_service.generate(
                prompt_template=GRAMMAR_EXPLAIN_PROMPT,
                variables=variables,
            )
    except asyncio.TimeoutError:
        logger.warning(f"Grammar explanation timed out for: {request.error_text}")
        raise HTTPException(status_code=504, detail="Grammar explanation timed out")
    except OutputParserException as e:
        logger.warning(f"LLM parsing failed: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to parse grammar explanation: {e}")
    except Exception as e:
        logger.warning(f"LLM call failed: {e}")
        raise HTTPException(status_code=500, detail=f"Grammar explanation failed: {e}")

    return _parse_grammar_response(result, request.error_text)


async def _explain_single_with_error_handling(
    request: GrammarExplainRequest, semaphore: asyncio.Semaphore
) -> tuple[GrammarExplainResponse | None, bool]:
    """Wrapper for explain_single with error handling for batch processing."""
    async with semaphore:
        try:
            result = await asyncio.wait_for(
                explain_single(request),
                timeout=30.0,
            )
            return result, False
        except Exception as e:
            logger.warning(f"Failed to explain error '{request.error_text[:50]}...': {e}")
            return None, True


async def explain_batch(
    requests: list[GrammarExplainRequest], max_concurrent: int = 3
) -> GrammarBatchExplainResponse:
    """Explain multiple grammar errors with concurrency control."""
    if not requests:
        return GrammarBatchExplainResponse(results=[], failed_count=0, total_count=0)

    # Limit concurrency to max 5 as per requirements
    semaphore = asyncio.Semaphore(min(max_concurrent, 5))

    # Create tasks for all requests
    tasks = [
        _explain_single_with_error_handling(req, semaphore)
        for req in requests
    ]

    # Execute all tasks concurrently (semaphore limits actual concurrency)
    results = await asyncio.gather(*tasks, return_exceptions=True)

    # Process results
    explanations: list[GrammarExplainResponse] = []
    failed_count = 0

    for i, result in enumerate(results):
        if isinstance(result, Exception):
            logger.warning(f"Task {i} raised exception: {result}")
            failed_count += 1
        else:
            explanation, failed = result
            if failed or explanation is None:
                failed_count += 1
            else:
                explanations.append(explanation)

    return GrammarBatchExplainResponse(
        results=explanations,
        failed_count=failed_count,
        total_count=len(requests),
    )
