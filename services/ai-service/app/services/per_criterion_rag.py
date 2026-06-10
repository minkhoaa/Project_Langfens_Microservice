"""Per-criterion RAG retrieval for writing grading.

Runs 4 parallel Qdrant searches (one per IELTS criterion) with
criterion-tuned query strings. Reuses the existing
search_and_reassemble primitive so the cache, index, and
failure-degradation logic are shared with the rest of the service.

In addition, runs a 5th parallel search against the grammar_knowledge
collection to ground the `gr` (Grammatical Range & Accuracy) criterion
on explicit rules rather than only on essay examples. The returned
`grammar_rules` list is consumed by `writing_grade_criterion` to render
a "Grammar rules" subsection inside the `gr` evidence block.
"""
import asyncio
import logging
from typing import Literal

from app.config import settings
from app.schemas import ReassembledEssay, SearchResult
from app.services import search_service

logger = logging.getLogger(__name__)

# Query templates per criterion. The base task is appended to each.
CRITERION_QUERIES: dict[str, str] = {
    "ta": "paragraph structure introduction body conclusion task response position",
    "cc": "coherence cohesive devices however furthermore consequently linking words",
    "lr": "academic vocabulary collocations precise synonyms paraphrase topic-specific",
    "gr": "complex sentence structures subordinate clauses passive voice conditionals accuracy",
}

# Query used to retrieve explicit grammar rules from the
# `grammar_knowledge` collection. Kept generic so it surfaces
# rule-typical entries (subject-verb agreement, articles, conditionals,
# tense, word order, prepositions) regardless of topic.
GRAMMAR_RULES_QUERY = "IELTS writing common grammatical errors subject verb agreement articles conditionals tense prepositions"

# How many grammar rules to inject into the `gr` evidence block. Small
# budget on purpose: 1-2 rules is enough to anchor the LLM and avoids
# diluting the per-criterion essay evidence with rule prose.
GRAMMAR_RULES_TOP_K = 2

# Built-in fallback rule set. Used when the `grammar_knowledge` Qdrant
# collection is empty (data file missing on disk, ingestion skipped, or
# the search returns no hits). Each entry has the same shape as a
# `SearchResult` (id, text, score, metadata) so downstream consumers
# (prompt builder, response mapper) don't need to special-case it.
# Categories align with the grammar service's VALID_CATEGORIES.
_FALLBACK_GRAMMAR_RULES: list[SearchResult] = [
    SearchResult(
        id="fallback-sv",
        text="Subject-verb agreement: a singular subject takes a singular verb, a plural subject takes a plural verb. 'The number of students has increased' (not 'have'). 'A number of students have increased'.",
        score=1.0,
        metadata={"category": "subject-verb"},
    ),
    SearchResult(
        id="fallback-article",
        text="Article use: count singular nouns need a/an (first mention) or the (subsequent or specific). 'Education is an important tool' (not 'a important' or no article on 'education' when used in a general sense). 'The government has announced' (specific referent).",
        score=1.0,
        metadata={"category": "article"},
    ),
    SearchResult(
        id="fallback-tense",
        text="Tense consistency: maintain the same tense within a paragraph unless a time shift is signaled. Academic writing typically uses present simple for facts and present perfect for recent actions with present relevance: 'Research has shown that exercise improves health.'",
        score=1.0,
        metadata={"category": "tense"},
    ),
]

async def _retrieve_one(
    criterion: str,
    task: str,
    task_type: str,
    essay: str = "",
    band_estimate: float | None = None,
) -> list[ReassembledEssay]:
    """One criterion's worth of RAG. Failures degrade to []."""
    # Include a snippet of the student's essay in the query so the vector
    # search surfaces reference essays that resemble the student's writing
    # in register/vocab, not only essays on the same topic. Without this,
    # a Band 3 essay and a Band 8 essay on the same topic return the same
    # high-band exemplars and the LLM anchors scores to the corpus median
    # (~Band 7) instead of to the student's actual level.
    essay_snippet = (essay or "")[:300]
    query = f"{task} {CRITERION_QUERIES[criterion]} {essay_snippet}".strip()

    # Scope the band_overall filter to the LLM-estimated band ± 2.0 so the
    # retrieved exemplars are near the student's level. Without this, the
    # corpus (78% Band 6.5-7.5) anchors every prompt to mid-band. The ±2.0
    # window is wide enough to allow a Band 5 essay to retrieve Band 4-7
    # neighbours for similarity, narrow enough to exclude the Band 8-9
    # exemplars that cause the inflation.
    if band_estimate is None:
        lo, hi = 2.0, 9.0
    else:
        lo = max(2.0, band_estimate - 2.0)
        hi = min(9.0, band_estimate + 2.0)

    filters = {
        "criterion": criterion,
        "task_type": task_type,
        "band_overall": {"gte": lo, "lte": hi},
    }
    try:
        return await search_service.search_and_reassemble(
            collection=settings.qdrant_collection_writing,
            query=query,
            top_k=3,
            filters=filters,
        )
    except Exception as exc:
        logger.warning("per_criterion_rag: %s query failed: %s", criterion, exc)
        return []

async def _retrieve_grammar_rules(task: str) -> list[SearchResult]:
    """Retrieve explicit grammar rules for the `gr` criterion.

    Uses the regular `search` primitive (not `search_and_reassemble`)
    because grammar rules are stored as single-chunk points without
    a parent_id reassembly structure. Failures degrade to the built-in
    fallback set so the `gr` evidence block and the FE pill row always
    have content to show (the fallback covers the most common IELTS
    grammar pitfalls).
    """
    query = f"{task} {GRAMMAR_RULES_QUERY}"
    try:
        hits = await search_service.search(
            collection=settings.qdrant_collection_grammar,
            query=query,
            top_k=GRAMMAR_RULES_TOP_K,
            filters={},
        )
    except Exception as exc:
        logger.warning("per_criterion_rag: grammar rules query failed: %s", exc)
        return _FALLBACK_GRAMMAR_RULES

    if hits:
        return hits

    logger.info(
        "per_criterion_rag: grammar_knowledge returned 0 hits — using built-in fallback rules"
    )
    return _FALLBACK_GRAMMAR_RULES

async def retrieve(task: str, task_type: str, essay: str = "", band_estimate: float | None = None) -> dict[str, list]:
    """Run the 4 criterion RAG queries plus the grammar-rules query in parallel.

    Returns a dict with 4 criterion essay lists and a `grammar_rules` list:
    ``{"ta": [...], "cc": [...], "lr": [...], "gr": [...], "grammar_rules": [...]}``.
    Callers that only consume the 4 criteria (the existing contract) keep
    working — the new key is additive.

    `band_estimate` scopes each criterion's band_overall filter to
    ±2.0 bands of the LLM-derived estimate. This prevents the corpus
    (78% Band 6.5-7.5) from anchoring low-band essays to mid-band.
    """
    criteria: tuple[Literal["ta", "cc", "lr", "gr"], ...] = ("ta", "cc", "lr", "gr")
    essay_results, grammar_rules = await asyncio.gather(
        asyncio.gather(*(_retrieve_one(c, task, task_type, essay, band_estimate) for c in criteria)),
        _retrieve_grammar_rules(task),
    )
    return {**dict(zip(criteria, essay_results)), "grammar_rules": grammar_rules}
