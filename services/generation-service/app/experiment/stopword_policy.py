"""Standard tokenization and stopword policy for RQ2_DATASET_V2.

Defines the authoritative English closed-class stopword set and tokenization functions
used for distinguishing raw 3-grams from content-word shingles, enforcing zero content-word
overlap against quarantined sources, and auditing lexical false positives.
"""

from __future__ import annotations

import re
from typing import List, Set

# Authoritative English closed-class stopword set (articles, prepositions, conjunctions, pronouns, auxiliary verbs)
STANDARD_ENGLISH_STOPWORDS: Set[str] = {
    "a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are", "aren",
    "as", "at", "be", "because", "been", "before", "being", "below", "between", "both", "but", "by",
    "can", "cannot", "could", "did", "do", "does", "doing", "down", "during", "each", "few", "for",
    "from", "further", "had", "has", "have", "having", "he", "her", "here", "hers", "herself", "him",
    "himself", "his", "how", "i", "if", "in", "into", "is", "it", "its", "itself", "just", "me", "more",
    "most", "my", "myself", "no", "nor", "not", "now", "of", "off", "on", "once", "only", "or", "other",
    "our", "ours", "ourselves", "out", "over", "own", "same", "she", "should", "so", "some", "such",
    "than", "that", "the", "their", "theirs", "them", "themselves", "then", "there", "these", "they",
    "this", "those", "through", "to", "too", "under", "until", "up", "very", "was", "wasn", "we",
    "were", "what", "when", "where", "which", "while", "who", "whom", "why", "with", "would", "you", "your"
}


def tokenize_raw_words(text: str) -> List[str]:
    """Tokenizes text into lowercase alphanumeric words."""
    return re.findall(r"\b[a-zA-Z0-9]+\b", text.lower())


def tokenize_content_words(text: str) -> List[str]:
    """Extracts content words, filtering out standard closed-class stopwords and 1-char tokens."""
    tokens = tokenize_raw_words(text)
    return [t for t in tokens if t not in STANDARD_ENGLISH_STOPWORDS and len(t) > 1]


def extract_raw_3grams(text: str) -> Set[str]:
    """Extracts raw word 3-grams including stop words."""
    tokens = tokenize_raw_words(text)
    if len(tokens) < 3:
        return set(tokens)
    return {" ".join(tokens[i : i + 3]) for i in range(len(tokens) - 2)}


def extract_content_word_3grams(text: str) -> Set[str]:
    """Extracts 3-grams formed strictly of content words (excluding stopwords)."""
    c_tokens = tokenize_content_words(text)
    if len(c_tokens) < 3:
        return set()
    return {" ".join(c_tokens[i : i + 3]) for i in range(len(c_tokens) - 2)}


def extract_verbatim_spans(text: str, span_length: int = 6) -> Set[str]:
    """Extracts contiguous sequences of exactly span_length words."""
    tokens = tokenize_raw_words(text)
    if len(tokens) < span_length:
        return set()
    return {" ".join(tokens[i : i + span_length]) for i in range(len(tokens) - span_length + 1)}


def is_pure_function_word_3gram(shingle: str) -> bool:
    """Checks whether all tokens in a 3-gram are closed-class stopwords."""
    words = shingle.split()
    return len(words) == 3 and all(w in STANDARD_ENGLISH_STOPWORDS for w in words)
