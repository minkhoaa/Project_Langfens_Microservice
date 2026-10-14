"""Phase 15 V2 verbatim-match boundary fix (agent B / D1).

Live campaign evidence: case 16, seed 101, Q9 completion answer
'mutant huntingtin (mHTT)' was rejected by `match_verbatim_in_passage`
because the passage continues with a hyphenated compound ('(mHTT)-related').
The answer is present verbatim; the trailing boundary incorrectly
classified '-' as a word-continuation.

This test pins the boundary matrix from the live evidence plus the
adjacent edge cases. The general rule being fixed:
    * the trailing guard is only needed when the answer itself ends in
      a word character (or in the existing set, ['\\w'-]),
    * when the answer ends in punctuation (e.g. ')'), the answer is
      already self-delimited on the right and the successor only needs
      to not be a word character.

Partial-word rejection ('rat' inside 'rat-free', 'huntingtin' inside
'huntingtin-like', 'oxygen' followed by a word char) is preserved
exactly. The leading guard is unchanged.

No loop / repair / policy code is exercised here. This file is a
pure unit test of the contract function; it does not import any
runtime classes and does not touch the LLM gateway.
"""

from __future__ import annotations

import pytest

from app.contracts.policies import match_verbatim_in_passage


# ---------------------------------------------------------------------------
# The 6-case boundary matrix straight from the live evidence.
# Case 1 is the genuine bug: a verbatim answer that ends in ')' is
# followed by '-' (a word-continuation char in the original guard)
# and is wrongly rejected. Cases 2..6 must all preserve their existing
# (correct) behavior — the partial-word rejections and the full
# word matches all stay as-is.
# ---------------------------------------------------------------------------

# (answer, passage, expected)
LIVE_MATRIX = [
    # (1) THE BUG: ')' followed by '-' must still match (the answer
    # is already self-delimited on the right, '-' is not a word char).
    (
        "mutant huntingtin (mHTT)",
        "…HD is driven by mutant huntingtin (mHTT)-related cellular and synaptic dysfunction…",
        True,
    ),
    # (2) Control: same answer followed by a space stays a match.
    (
        "mutant huntingtin (mHTT)",
        "…mutant huntingtin (mHTT) dysfunction…",
        True,
    ),
    # (3) Partial-word rejection: 'rat' must NOT match inside 'rat-free'.
    (
        "rat",
        "the strata were rat-free",
        False,
    ),
    # (4) Partial-word rejection: 'huntingtin' must NOT match inside 'huntingtin-like'.
    (
        "huntingtin",
        "driven by huntingtin-like proteins",
        False,
    ),
    # (5) Full-word match in the middle of a phrase is a valid verbatim
    # occurrence. The answer ends in a word char, both sides are spaces,
    # so this is the canonical "answer in the passage" case and is True.
    (
        "oxygen",
        "dissolved oxygen levels",
        True,
    ),
    # (6) Full-word match even when followed by another word.
    (
        "oxygen",
        "dissolved oxygen levels rose",
        True,
    ),
]


@pytest.mark.parametrize("answer,passage,expected", LIVE_MATRIX,
                         ids=[f"live_case_{i+1}" for i in range(len(LIVE_MATRIX))])
def test_phase15_v2rate_b_match_verbatim_in_passage_boundary_matrix(
    answer, passage, expected
):
    """The 6-case boundary matrix from live evidence.

    Case 1 (mHTT followed by '-related') is the proven false-positive:
    the function must return True. Cases 2..6 preserve their current
    behavior; the partial-word rejections stay False and the legitimate
    full-word matches stay True.
    """
    got = match_verbatim_in_passage(answer, passage)
    assert got is expected, (
        f"match_verbatim_in_passage({answer!r}, {passage!r}) returned {got}; "
        f"expected {expected}. Boundary rule: trailing guard runs only when "
        f"the answer itself ends in a word character; if it ends in "
        f"punctuation, the span is already self-delimited."
    )


# ---------------------------------------------------------------------------
# Adjacent edge cases. These pin the *general* rule, not just the live
# 6 cases. The leading guard is always the same; the trailing guard
# adapts to the last character of the answer.
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("answer,passage,expected,note", [
    # Edge: answer ends in ')' then space — should still match (the
    # punctuation already delimits the answer).
    (
        "(mHTT)",
        "driven by (mHTT) dysfunction",
        True,
        "answer-in-parens followed by space",
    ),
    # Edge: answer ends in ')' then end-of-string — should match.
    (
        "(mHTT)",
        "driven by (mHTT)",
        True,
        "answer-in-parens at end of passage",
    ),
    # Edge: answer ends in digit — full guard required; '8' followed by
    # '1' inside '81' must still be a partial match (rejected).
    (
        "8",
        "the year 81",
        False,
        "digit answer inside a longer numeric token",
    ),
    # Edge: answer ends in digit; full guard required; '99' as its own
    # word is fine.
    (
        "99",
        "in the year 99 BC",
        True,
        "digit answer as its own token",
    ),
    # Edge: answer ends in apostrophe (e.g. a contraction) — full guard
    # is required because '\'' is in the original class; "don't" must
    # not partial-match "don'ts" in the passage.
    (
        "don't",
        "people don'ts think so",
        False,
        "contraction followed by 's' is a partial-word extension",
    ),
    # Edge: answer ends in apostrophe and is a real full word.
    (
        "don't",
        "people don't think so",
        True,
        "contraction as a full word is a real verbatim match",
    ),
    # Edge: answer ends in hyphenated suffix — full guard, the trailing
    # '-' itself is in the class, so 'seven-year' inside 'seven-yearly'
    # must be rejected.
    (
        "seven-year",
        "the seven-yearly study concluded",
        False,
        "hyphenated answer must not extend into a longer hyphenated token",
    ),
    # Edge: answer ends in punctuation '.' — should match a real
    # sentence-final span (period is self-delimiting).
    (
        "Huntington's disease.",
        "Huntington's disease. It is a neurodegenerative disorder.",
        True,
        "answer ends in '.', preceded by word, followed by space",
    ),
    # Edge: answer is purely punctuation. The function should still
    # apply the rule (trailing guard relaxed to '(?!\\w)'); the leading
    # guard still applies.
    (
        ")",
        "the bracket ) closes",
        True,
        "punctuation-only answer matches a free-standing close paren",
    ),
    # Edge: an inflected compound is the same shape as the hyphenated one
    # that caused the live false positive. The possessive 's belongs to
    # the passage text that follows the answer, not to the answer itself,
    # so the verbatim span is still present.
    (
        "(mHTT)",
        "the toxic gain of function (mHTT)'s polyglutamine tract",
        True,
        "answer ends in ')' followed by a possessive inflection",
    ),
    # Edge: empty answer — schema invariant says this never happens,
    # but the function must remain safe.
    (
        "",
        "anything goes here",
        False,
        "empty answer never matches",
    ),
    # Edge: empty passage — same: no match.
    (
        "oxygen",
        "",
        False,
        "empty passage never matches",
    ),
])
def test_phase15_v2rate_b_match_verbatim_in_passage_general_rule_edges(
    answer, passage, expected, note
):
    """Adjacent edge cases pinning the general rule.

    Trailing guard is ``(?![\\w'-])`` when the answer ends in a
    word/quote/hyphen char; otherwise it relaxes to ``(?!\\w)`` because
    the answer is already self-delimited by its trailing punctuation.
    The leading guard is unchanged.
    """
    got = match_verbatim_in_passage(answer, passage)
    assert got is expected, (
        f"[{note}] match_verbatim_in_passage({answer!r}, {passage!r}) "
        f"returned {got}; expected {expected}."
    )
