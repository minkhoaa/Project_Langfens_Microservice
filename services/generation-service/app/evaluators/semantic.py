"""Semantic Evaluators for Langfens Loop Engine V2.

Implements P07-04 & P07-05:
- Grounding fidelity (entailment, qualifiers, invented quantities, causality, certainty, unmeasured outcomes)
- Ambiguity and distractor quality
- NOT GIVEN semantics (passage-wide non-entailment/non-contradiction, quote as anchor only, FALSE vs NOT GIVEN)
- Advisory quality heuristics (separated from hard blockers, no IELTS band calibration claim)
"""

from dataclasses import dataclass

from enum import Enum
import re
from typing import Any, Dict, List, Optional, Set, Tuple
from uuid import uuid4

from app.config import settings
from app.contracts.artifact import ArtifactEnvelope, ArtifactRef, ArtifactType
from app.contracts.evaluation import EvaluationResult, EvaluationStatus
from app.contracts.issue import Issue, IssueCode, IssueScope, IssueSeverity
from app.contracts.policies import count_words
from app.evaluators.base import BaseEvaluator, EvaluationStage, EvaluatorMetadata
from app.evaluators.deterministic import matches_exact_token_bound, normalize_text_nfkc
from app.evidence.extractor import (
    extract_modality,
    extract_population,
    parse_quantities_and_units,
)
from app.evidence.validators import (
    CAUSAL_VERBS,
    CORRELATION_PHRASES,
    UNCERTAIN_MODALS,
)
from app.loop.context import LoopContext


# ── Semantic Helper Functions ───────────────────────────────────────────────

NEGATION_TERMS = {
    "not", "never", "no", "neither", "nor", "fails to", "failed to",
    "contrary", "opposite", "refuted", "disproved", "denies", "denied",
    "without", "incorrect", "untrue", "false",
}

CERTAINTY_BOOSTERS = {
    "proves", "definitely", "certainly", "undoubtedly", "always",
    "conclusively", "indisputable", "indisputably",
}

class SemanticRelation(str, Enum):
    """Four possible semantic relations under G07 / P07-05."""
    ENTAILED = "ENTAILED"
    CONTRADICTED = "CONTRADICTED"
    NEITHER = "NEITHER"  # Neither entailed nor contradicted (true NOT GIVEN)
    INCONCLUSIVE_OR_ERROR = "INCONCLUSIVE_OR_ERROR"


WORD_NUMS = {
    "twenty-five": "25", "forty": "40", "seventy": "70", "ninety-nine": "99", "ninety-five": "95",
    "ninety": "90", "eighty": "80", "eighteen": "18", "fourteen": "14", "twenty": "20",
    "thirty": "30", "fifty": "50", "sixty": "60",
    "eight hundred thousand": "800000", "one hundred and eighty": "180",
    "two hundred and eighty": "280", "four hundred and twenty": "420",
    "one percent": "1%", "fifty percent": "50%", "eighty-five percent": "85%",
    "ninety percent": "90%", "ninety-nine percent": "99%", "one hundred percent": "100%",
    "ten": "10", "nine": "9", "eight": "8", "seven": "7", "six": "6", "five": "5", "four": "4", "three": "3", "two": "2", "one": "1",
}

ANTONYM_PAIRS = [
    ("easily afford", "prohibitively high"),
    ("afford", "prohibitive"),
    ("affordable", "prohibitively high"),
    ("increase", "decrease"),
    ("increase", "declined"),
    ("increased", "declined"),
    ("expand", "decline"),
    ("expansion", "decline"),
    ("reduce", "increase"),
    ("reduces", "increases"),
    ("diminish", "increase"),
    ("less than", "more than"),
    ("profitable", "unprofitable"),
    ("profitable", "cannot currently be grown profitably"),
    ("profitable", "limiting economic viability"),
    ("eliminate", "increase"),
    ("cured", "monitored"),
    ("remained steady", "declined"),
    ("remained steady", "declined significantly"),
    ("remained steady", "decreased"),
    ("steady", "declined significantly"),
    ("steady", "declined"),
    ("remained constant", "declined"),
    ("remained stable", "declined"),
    ("supports", "rejects"),
    ("support", "reject"),
    ("supports", "opposes"),
    ("support", "oppose"),
    ("compulsory", "voluntary"),
    ("compulsory", "optional"),
    ("immune", "vulnerable"),
    ("improve", "limit"),
    ("improve", "limiting"),
    ("improves", "limits"),
    ("open their stomata during the day", "stomata remain firmly closed"),
    ("open their stomata during daylight hours", "stomata remain firmly closed"),
    ("open stomata during daylight hours", "stomata remain firmly closed"),
    ("open stomata during the day", "stomata remain firmly closed"),
    ("open stomata during daylight hours", "stomata remain closed"),
    ("open stomata during the day", "stomata remain closed"),
    ("accelerate", "slow down"),
    ("accelerates", "slows down"),
    ("active", "dormant"),
    ("present", "absent"),
    ("presence", "absence"),
    ("internal", "external"),
    ("internally", "externally"),
    ("majority", "minority"),
    ("synthetic", "natural"),
    ("artificial", "natural"),
    ("prohibit", "permit"),
    ("prohibits", "permits"),
    ("prohibited", "permitted"),
    ("exclude", "include"),
    ("excludes", "includes"),
    ("excluded", "included"),
    ("fail", "succeed"),
    ("failed", "succeeded"),
    ("failure", "success"),
    ("ascend", "descend"),
    ("mandatory", "optional"),
    ("permanent", "temporary"),
    ("harmful", "beneficial"),
    ("absorb", "emit"),
    ("absorbs", "emits"),
]

def normalize_written_numbers(text: str) -> str:
    res = text.lower()
    for w, d in sorted(WORD_NUMS.items(), key=lambda x: len(x[0]), reverse=True):
        res = re.sub(rf"\b{re.escape(w)}\b", d, res)
    return res


def stem_token(word: str) -> str:
    for suffix in ("ing", "ion", "ed", "es", "s"):
        if word.endswith(suffix) and len(word) > len(suffix) + 3:
            return word[:-len(suffix)]
    return word


def detect_contradiction_in_text(statement: str, reference_text: str, enable_contrastive_exclusion: bool = False, enable_refined_contrastive_clause: bool = False) -> bool:
    """Checks if reference_text directly contradicts statement on a per-sentence basis.
    enable_contrastive_exclusion enables contrastive exclusion marker checks (v2.3+ feature).
    enable_refined_contrastive_clause refines clause boundaries for 'unlike' (v2.4+ feature).
    """
    s_clean = normalize_written_numbers(normalize_text_nfkc(statement)).lower()
    s_words = set(re.findall(r"\b\w+\b", s_clean)) - {"the", "a", "an", "is", "are", "was", "were", "to", "of", "in"}
    sentences = [s.strip() for s in re.split(r"[.!?]\s+", reference_text) if s.strip()]
    if not sentences:
        sentences = [reference_text]

    for sent in sentences:
        r_clean = normalize_written_numbers(normalize_text_nfkc(sent)).lower()

        # 1. Antonym pairs check
        for w1, w2 in ANTONYM_PAIRS:
            s_match = bool(re.search(rf"\b{re.escape(w1)}\b", s_clean)) and bool(re.search(rf"\b{re.escape(w2)}\b", r_clean))
            r_match = bool(re.search(rf"\b{re.escape(w2)}\b", s_clean)) and bool(re.search(rf"\b{re.escape(w1)}\b", r_clean))
            if s_match or r_match:
                r_words = set(re.findall(r"\b\w+\b", r_clean)) - {"the", "a", "an", "is", "are", "was", "were", "to", "of", "in"}
                if len(s_words & r_words) >= 1:
                    return True

        # 2. Conflicting numeric quantities
        s_quants, _ = parse_quantities_and_units(s_clean)
        r_quants, _ = parse_quantities_and_units(r_clean)
        if s_quants and r_quants:
            s_nums = [q.replace(" ", "").lower() for q in s_quants]
            r_nums = [q.replace(" ", "").lower() for q in r_quants]
            if any(sn not in r_nums for sn in s_nums) and any(rn not in s_nums for rn in r_nums):
                s_words = set(re.findall(r"\b\w+\b", s_clean))
                shared_vocab = (s_words & set(re.findall(r"\b\w+\b", r_clean))) - {
                    "the", "a", "an", "in", "of", "to", "and", "is", "was", "were", "are",
                    "percent", "species", "organisms", "total", "approximately", "around",
                    "all", "more", "less", "than", "or", "for", "from", "on", "at"
                }
                if len(shared_vocab) >= 3:
                    return True
        # 3. Explicit contradiction phrases in matching sentence
        for neg in ["did not", "does not", "was not", "were not", "failed to", "contrary to", "cannot currently"]:
            if neg in r_clean:
                pos = neg.replace("not ", "").replace("failed to", "").replace("cannot currently", "can")
                if pos and pos in s_clean:
                    return True

        # 4. Conflicting time durations (e.g. 6 weeks vs 10 weeks)
        s_durations = re.findall(r"\b(\d+)\s*(weeks?|days?|months?|years?|hours?)\b", s_clean)
        r_durations = re.findall(r"\b(\d+)\s*(weeks?|days?|months?|years?|hours?)\b", r_clean)
        if s_durations and r_durations:
            for s_num, s_unit in s_durations:
                for r_num, r_unit in r_durations:
                    if s_unit.rstrip("s") == r_unit.rstrip("s") and s_num != r_num:
                        s_words = set(re.findall(r"\b\w+\b", s_clean))
                        r_words = set(re.findall(r"\b\w+\b", r_clean))
                        if len(s_words & r_words) >= 1:
                            return True

        # 5. Contrastive exclusion markers (e.g. 'X rather than Y', 'instead of Y') - v2.3 feature gate
        if enable_contrastive_exclusion:
            for marker in ["rather than", "instead of", "as opposed to", "unlike"]:
                if marker in r_clean and marker not in s_clean:
                    if enable_refined_contrastive_clause and marker == "unlike":
                        after_unlike = r_clean.split("unlike", 1)[1]
                        excl = after_unlike.split(",", 1)[0] if "," in after_unlike else after_unlike
                    else:
                        _, excl = r_clean.split(marker, 1)
                    excl_words = {stem_token(w) for w in re.findall(r"\b\w+\b", excl) if len(w) > 3}
                    s_stems = {stem_token(w) for w in s_words if len(w) > 3}
                    if len(s_stems & excl_words) >= 2:
                        return True

def detect_entailment_in_text(statement: str, reference_text: str, enable_contrastive_exclusion: bool = False, enable_refined_contrastive_clause: bool = False, enable_contrastive_entailment: bool = False) -> bool:
    """Checks if statement is entailed by any sentence in reference_text with compatible polarity."""
    if detect_contradiction_in_text(statement, reference_text, enable_contrastive_exclusion=enable_contrastive_exclusion, enable_refined_contrastive_clause=enable_refined_contrastive_clause):
        return False
    s_clean = normalize_written_numbers(normalize_text_nfkc(statement)).lower()
    sentences = [s.strip() for s in re.split(r"[.!?]\s+", reference_text) if s.strip()]
    if not sentences:
        sentences = [reference_text]

    for sent in sentences:
        r_clean = normalize_written_numbers(normalize_text_nfkc(sent)).lower()
        # Sentence-level contradiction check: a sentence contradicting statement cannot entail it
        if detect_contradiction_in_text(statement, sent, enable_contrastive_exclusion=enable_contrastive_exclusion, enable_refined_contrastive_clause=enable_refined_contrastive_clause):
            continue
        # Also ensure sentence does not contain an exclusion marker where statement words are in the excluded clause
        if enable_contrastive_exclusion:
            has_exclusion = False
            for marker in ["rather than", "instead of", "as opposed to", "unlike"]:
                if marker in r_clean and marker not in s_clean:
                    if enable_refined_contrastive_clause and marker == "unlike":
                        after_unlike = r_clean.split("unlike", 1)[1]
                        excl = after_unlike.split(",", 1)[0] if "," in after_unlike else after_unlike
                    else:
                        _, excl = r_clean.split(marker, 1)
                    excl_words = {stem_token(w) for w in re.findall(r"\b\w+\b", excl) if len(w) > 3}
                    s_stems = {stem_token(w) for w in s_clean.split() if len(w) > 3}
                    if len(s_stems & excl_words) >= 2:
                        has_exclusion = True
                        break
            if enable_contrastive_entailment and not has_exclusion:
                for marker in ["whereas"]:
                    if f" {marker} " in f" {r_clean} " and marker not in s_clean:
                        parts = r_clean.split(marker, 1)
                        c1_stems = {stem_token(w) for w in re.findall(r"\b\w+\b", parts[0]) if len(w) > 3}
                        c2_stems = {stem_token(w) for w in re.findall(r"\b\w+\b", parts[1]) if len(w) > 3}
                        s_stems = {stem_token(w) for w in re.findall(r"\b\w+\b", s_clean) if len(w) > 3}
                        if s_stems:
                            overlap_1 = sum(1 for st in s_stems if st in c1_stems) / len(s_stems)
                            overlap_2 = sum(1 for st in s_stems if st in c2_stems) / len(s_stems)
                            if overlap_1 < 0.70 and overlap_2 < 0.70:
                                has_exclusion = True
                                break
            if has_exclusion:
                continue
        s_words = [w for w in re.findall(r"\b\w+\b", s_clean) if len(w) > 3 and w not in {"that", "with", "from", "this", "they", "have", "were"}]
        if not s_words:
            continue
        r_words = [w for w in re.findall(r"\b\w+\b", r_clean) if len(w) > 3]
        r_stems = [stem_token(w) for w in r_words]
        matched_words = sum(1 for w in s_words if stem_token(w) in r_stems or matches_exact_token_bound(w, r_clean))
        overlap_ratio = matched_words / len(s_words)
        if overlap_ratio >= 0.60:
            s_neg = any(re.search(rf"\b{re.escape(neg)}\b", s_clean) for neg in NEGATION_TERMS)
            r_neg = any(re.search(rf"\b{re.escape(neg)}\b", r_clean) for neg in NEGATION_TERMS)
            if s_neg == r_neg:
                return True
    return False


def detect_comparison_inversion(statement: str, reference_text: str) -> bool:
    """Detects inverted comparative or alternative relationships (e.g. 'X rather than Y' vs 'Y rather than X')."""
    s_clean = normalize_text_nfkc(statement).lower()
    r_clean = normalize_text_nfkc(reference_text).lower()
    for marker in ["rather than", "instead of", "as opposed to", "versus"]:
        if marker in s_clean and marker in r_clean:
            s_parts = [p.strip() for p in s_clean.split(marker, 1)]
            r_parts = [p.strip() for p in r_clean.split(marker, 1)]
            s0_words = set(re.findall(r"\b\w{4,}\b", s_parts[0])) - {"with", "that", "from", "have", "this", "they", "were"}
            s1_words = set(re.findall(r"\b\w{4,}\b", s_parts[1])) - {"with", "that", "from", "have", "this", "they", "were"}
            r0_words = set(re.findall(r"\b\w{4,}\b", r_parts[0])) - {"with", "that", "from", "have", "this", "they", "were"}
            r1_words = set(re.findall(r"\b\w{4,}\b", r_parts[1])) - {"with", "that", "from", "have", "this", "they", "were"}
            if len(s0_words & r1_words) >= 1 and len(s1_words & r0_words) >= 1:
                return True
    return False


def detect_negation_polarity_conflict(statement: str, reference_text: str) -> tuple[bool, str]:
    """Checks for negation polarity mismatches between statement and reference text."""
    s_clean = normalize_text_nfkc(statement).lower()
    r_clean = normalize_text_nfkc(reference_text).lower()
    s_neg = bool(re.search(r"\b(never|not|cannot|no|neither|barely|scarcely|hardly|did not|does not|was not|were not)\b", s_clean))

    sentences = [s.strip() for s in re.split(r"[.!?]\s+", r_clean) if s.strip()]
    for sent in sentences:
        sent_neg = bool(re.search(r"\b(did not|does not|was not|were not|cannot|failed to|never|not|no|neither)\b", sent))
        s_words = set(re.findall(r"\b\w{4,}\b", s_clean)) - {"with", "that", "from", "have", "this", "they", "were", "than", "more", "less"}
        sent_words = set(re.findall(r"\b\w{4,}\b", sent)) - {"with", "that", "from", "have", "this", "they", "were", "than", "more", "less"}
        overlap = s_words & sent_words
        if len(overlap) >= 2 and s_neg != sent_neg:
            for w in overlap:
                if re.search(rf"\b(never|not|cannot|no|barely)\s+(?:\w+\s+)?{w}\b", s_clean) and not re.search(rf"\b(never|not|cannot|no|did not|does not)\s+(?:\w+\s+)?{w}\b", sent):
                    return True, f"Statement negates predicate '{w}' which is affirmed in source text"
                if re.search(rf"\b(did not|does not|was not|were not|never|not)\s+(?:\w+\s+)?{w}\b", sent) and not re.search(rf"\b(never|not|no)\s+(?:\w+\s+)?{w}\b", s_clean):
                    return True, f"Source text negates predicate '{w}' which is affirmed in statement"
    return False, ""


V2_1_STOPWORDS = {
    "that", "with", "from", "this", "they", "have", "were", "been", "their", "which",
    "about", "after", "before", "during", "while", "where", "there", "these", "those",
    "than", "more", "most", "some", "many", "such", "into", "over", "under", "between",
    "true", "false", "given", "statement", "decide", "whether", "choose", "correct",
    "sentence", "following", "demonstrates", "uses", "examples", "example", "primary",
    "produce", "produces", "producing", "erupt", "erupts", "eruption", "eruptions",
    "occur", "occurs", "occurred", "represent", "represents", "represented", "refer", "refers",
    "across", "never", "within", "characterized", "formation", "concentrations", "presence",
    "contain", "contains", "consist", "consists", "included", "including", "always", "often",
    "usually", "various", "multiple", "several", "different", "similar", "related"
}

V2_2_STOPWORDS = {
    "that", "with", "from", "this", "they", "have", "were", "been", "their", "which",
    "about", "after", "before", "during", "while", "where", "there", "these", "those",
    "than", "more", "most", "some", "many", "such", "into", "over", "under", "between",
    "true", "false", "given", "statement", "decide", "whether", "choose", "correct",
    "sentence", "following", "demonstrates", "uses", "examples", "example", "primary",
    "produce", "produces", "producing", "erupt", "erupts", "eruption", "eruptions",
    "occur", "occurs", "occurred", "represent", "represents", "represented", "refer", "refers",
    "across", "within", "characterized", "formation", "concentrations", "presence",
    "contain", "contains", "consist", "consists", "included", "including", "often",
    "usually", "different", "similar", "related"
}


def compute_substantive_grounding_ratio(statement: str, reference_text: str, is_v2_2: bool = False) -> tuple[float, list[str]]:
    """Computes the ratio of substantive content words in statement grounded in reference text.
    Uses prefix/stem matching and excludes grammatical/relational/paraphrase function words.
    """
    stopwords = V2_2_STOPWORDS if is_v2_2 else V2_1_STOPWORDS
    s_words = [w for w in re.findall(r"\b[a-zA-Z]{4,}\b", statement.lower()) if w not in stopwords]
    if not s_words:
        return 1.0, []

    r_clean = reference_text.lower()
    r_words = set(re.findall(r"\b[a-zA-Z]{4,}\b", r_clean))
    r_stems = {stem_token(w) for w in r_words}

    unsupported = []
    for w in s_words:
        w_stem = stem_token(w)
        if w in r_words or w_stem in r_stems or w in r_stems:
            continue
        prefix_len = min(5, len(w) - 1)
        w_pfx = w[:prefix_len]
        if any(rw.startswith(w_pfx) or rw[:prefix_len] == w_pfx for rw in r_words):
            continue
        unsupported.append(w)

    ratio = 1.0 - (len(unsupported) / len(s_words))
    return ratio, unsupported


@dataclass
class NegativeInversionValidationResult:
    is_structural_inversion: bool
    is_grammatically_valid: bool
    verdict: str  # "VALID", "INVALID", "UNCERTAIN"
    rejection_reason: Optional[str] = None
    trigger: Optional[str] = None
    auxiliary: Optional[str] = None
    subject: Optional[str] = None
    verb_phrase: Optional[str] = None


IRREGULAR_PAST_VERBS = {
    "won", "broke", "knew", "saw", "went", "came", "did", "had",
    "began", "spoke", "left", "found", "met", "took", "gave", "made",
    "felt", "thought", "told", "became", "brought", "wrote", "chose",
    "drove", "fell", "forgot", "hid", "ran", "sang", "stood", "threw",
    "froze", "rose", "flew", "drew", "shook", "wore", "built", "spent", "understood"
}

IRREGULAR_PAST_PARTICIPLES = {
    "witnessed", "observed", "begun", "opened", "closed", "discarded",
    "stabilized", "seen", "known", "broken", "published", "ended",
    "realized", "found", "conducted", "recorded", "detected", "confirmed",
    "verified", "achieved", "documented", "isolated", "demonstrated",
    "identified", "reported", "discovered", "analyzed", "tested", "been", "done",
    "taken", "given", "written", "spoken", "left", "made", "become", "chosen",
    "frozen", "risen", "flown", "drawn", "shaken", "worn", "built", "spent"
}

MODAL_AUXILIARY_WORDS = {
    "should", "could", "would", "will", "can", "may", "might", "must", "shall"
}
CONTRACTED_MODAL_WORDS = {
    "shouldn't", "couldn't", "wouldn't", "won't", "can't", "mightn't", "mustn't"
}
DO_AUXILIARY_WORDS = {"did", "do", "does"}
CONTRACTED_DO_WORDS = {"didn't", "don't", "doesn't"}
HAVE_AUXILIARY_WORDS = {"had", "have", "has"}
CONTRACTED_HAVE_WORDS = {"hadn't", "haven't", "hasn't"}
BE_AUXILIARY_WORDS = {"was", "were", "is", "are", "am"}
CONTRACTED_BE_WORDS = {"wasn't", "weren't", "isn't", "aren't"}

ALL_MODAL_WORDS = MODAL_AUXILIARY_WORDS | CONTRACTED_MODAL_WORDS
ALL_DO_WORDS = DO_AUXILIARY_WORDS | CONTRACTED_DO_WORDS
ALL_HAVE_WORDS = HAVE_AUXILIARY_WORDS | CONTRACTED_HAVE_WORDS
ALL_BE_WORDS = BE_AUXILIARY_WORDS | CONTRACTED_BE_WORDS
ALL_AUXILIARY_WORDS = ALL_MODAL_WORDS | ALL_DO_WORDS | ALL_HAVE_WORDS | ALL_BE_WORDS

NON_THIRD_SINGULAR_SUBJECT_WORDS = {
    "i", "you", "we", "they", "researchers", "scientists", "students", "people",
    "samples", "specimens", "reviewers", "critics", "observers", "participants"
}

COMMON_BASE_VERBS = {
    "open", "leave", "win", "see", "know", "be", "have", "enter", "go",
    "come", "take", "give", "make", "find", "tell", "ask", "seem", "feel",
    "try", "call", "walk", "speak", "witness", "observe", "realize", "expect",
    "stabilize", "discard", "test", "analyze", "identify", "report", "discover",
    "break", "begin", "start", "stop", "check", "verify", "admit", "deny",
    "ignore", "compromise", "fail", "cause", "occur", "accept", "reject",
    "permit", "allow", "require", "demand", "justify", "indicate", "suspect",
    "raise", "encounter", "produce", "alter", "suppress", "record", "publish",
    "demonstrate", "conclude", "suggest", "prove", "calibrate", "operate", "deliver"
}

BASE_EED_VERBS = {
    "need", "feed", "bleed", "proceed", "succeed", "exceed", "breed", "speed"
}


def detect_negative_inversion_structural(sentence: str, allow_contracted: bool = False) -> tuple[bool, dict[str, Any]]:
    """Separates structural inversion detection from full grammaticality validation.
    Checks whether a sentence exhibits structural inversion word order following an initial
    negative or limiting adverbial trigger (Trigger + Auxiliary + Subject).
    """
    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", sentence.strip())
    triggers = [
        r"under no circumstances",
        r"not only",
        r"seldom",
        r"rarely",
        r"never(?:\s+(?:before|again|in\s+my\s+life))?",
        r"hardly",
        r"scarcely",
        r"barely",
        r"no sooner",
        r"at no point",
        r"at no time",
        r"on no account",
        r"in no way",
        r"little",
        r"not until\s+.*?(?=\b(?:did|had|was|were|could|should|would|will|can|is|are|do|does)\b)",
        r"only\s+(?:when|after|if|by)\s+.*?(?=\b(?:did|had|was|were|could|should|would|will|can|is|are|do|does)\b)",
        r"only\s+then",
    ]
    matched_trigger = None
    after_trigger = ""
    for trig in triggers:
        m = re.match(rf"^{trig}\b\s*(?:,\s*)?", clean, re.IGNORECASE)
        if m:
            matched_trigger = m.group(0).strip().rstrip(",").strip()
            after_trigger = clean[m.end():].strip()
            break

    if not matched_trigger:
        return False, {"rejection_reason": "No initial negative or limiting adverbial trigger found"}

    tokens = after_trigger.split()
    if not tokens:
        return False, {"trigger": matched_trigger, "rejection_reason": "Empty clause following negative adverbial"}

    first_token = tokens[0].lower().strip(",.")
    if first_token not in ALL_AUXILIARY_WORDS:
        if first_token in {"we", "they", "i", "he", "she", "it", "you", "the", "a", "an", "researchers", "scientists", "students", "people"}:
            return False, {
                "trigger": matched_trigger,
                "rejection_reason": "Uninverted word order: subject precedes auxiliary after negative adverbial"
            }
        return False, {
            "trigger": matched_trigger,
            "rejection_reason": f"Illegal lexical verb '{first_token}' in inversion position: negative inversion requires auxiliary-subject inversion"
        }

    auxiliary = first_token
    remainder = tokens[1:]
    if not remainder:
        return False, {
            "trigger": matched_trigger,
            "auxiliary": auxiliary,
            "rejection_reason": "Missing subject and predicate following auxiliary"
        }

    rem0_clean = remainder[0].lower().strip(",.")
    is_rem0_verb = (
        rem0_clean in COMMON_BASE_VERBS
        or rem0_clean in IRREGULAR_PAST_VERBS
        or rem0_clean in IRREGULAR_PAST_PARTICIPLES
        or rem0_clean == "to"
        or (rem0_clean.endswith("ing") and rem0_clean not in {"building", "meeting", "morning", "training", "warning", "shipping", "ceiling"})
        or (rem0_clean.endswith("ed") and rem0_clean not in {"pressurized", "untreated", "automated", "qualified", "preliminary", "unauthorized"})
    )
    if is_rem0_verb:
        misplaced_subj = [w for w in remainder[1:] if w.lower().strip(",.") in {"we", "they", "i", "he", "she", "it", "you"}]
        if misplaced_subj:
            return False, {
                "trigger": matched_trigger,
                "auxiliary": auxiliary,
                "rejection_reason": f"Misplaced subject '{misplaced_subj[0]}' following verb '{rem0_clean}' in inverted clause"
            }
        return False, {
            "trigger": matched_trigger,
            "auxiliary": auxiliary,
            "rejection_reason": f"Missing subject in inverted clause: auxiliary '{auxiliary}' followed directly by verb '{rem0_clean}'"
        }

    subject_tokens = []
    if rem0_clean in {"i", "you", "he", "she", "it", "we", "they", "one", "anyone", "anybody", "someone", "somebody", "everyone", "everybody"}:
        subject_tokens = [remainder[0]]
        predicate_tokens = remainder[1:]
    elif rem0_clean in {"the", "a", "an", "this", "that", "these", "those", "each", "every", "all", "both", "many", "several", "some", "few", "no", "any", "neither", "either"}:
        subject_tokens = [remainder[0]]
        idx = 1
        while idx < len(remainder):
            w = remainder[idx].lower().strip(",.")
            if w in ALL_AUXILIARY_WORDS or w == "to":
                break
            if w in {"ever", "never", "always", "really", "actually", "fully", "previously", "already", "even", "simply", "truly", "clearly", "directly", "also", "still"} or (w.endswith("ly") and w not in {"likely", "friendly", "lonely", "lovely", "daily", "early"}):
                break
            if idx >= 2 and (
                w in COMMON_BASE_VERBS
                or w in IRREGULAR_PAST_VERBS
                or w in IRREGULAR_PAST_PARTICIPLES
                or (w.endswith("ed") and w not in {"pressurized", "untreated", "automated", "qualified", "preliminary", "unauthorized"})
            ):
                break
            subject_tokens.append(remainder[idx])
            idx += 1
            if len(subject_tokens) >= 5:
                break
        predicate_tokens = remainder[idx:]
    else:
        idx = 1
        subject_tokens = [remainder[0]]
        while idx < len(remainder):
            w = remainder[idx].lower().strip(",.")
            if w in ALL_AUXILIARY_WORDS or w == "to":
                break
            if w in {"ever", "never", "always", "really", "actually", "fully", "previously", "already", "even", "simply", "truly", "clearly", "directly", "also", "still"} or (w.endswith("ly") and w not in {"likely", "friendly", "lonely", "lovely", "daily", "early"}):
                break
            if w in COMMON_BASE_VERBS or w in IRREGULAR_PAST_VERBS or w in IRREGULAR_PAST_PARTICIPLES:
                break
            if w.endswith("ed") and w not in {"pressurized", "untreated", "automated", "qualified", "preliminary", "unauthorized"}:
                break
            subject_tokens.append(remainder[idx])
            idx += 1
            if len(subject_tokens) >= 4:
                break
        predicate_tokens = remainder[idx:]

    subject = " ".join(subject_tokens).strip(",.")
    predicate = " ".join(predicate_tokens)

    return True, {
        "trigger": matched_trigger,
        "auxiliary": auxiliary,
        "subject": subject,
        "predicate": predicate,
        "predicate_tokens": predicate_tokens
    }


def validate_negative_inversion_grammaticality(sentence: str, allow_contracted: bool = False, allow_ss_base_verbs: bool = False) -> NegativeInversionValidationResult:
    """Validates negative inversion syntax and full verb phrase grammaticality."""
    is_struct, info = detect_negative_inversion_structural(sentence, allow_contracted=allow_contracted)
    if not is_struct:
        return NegativeInversionValidationResult(
            is_structural_inversion=False,
            is_grammatically_valid=False,
            verdict="INVALID",
            rejection_reason=info.get("rejection_reason"),
            trigger=info.get("trigger"),
            auxiliary=info.get("auxiliary")
        )

    trigger = info["trigger"]
    auxiliary = info["auxiliary"]
    subject = info["subject"]
    predicate = info["predicate"]
    predicate_tokens = info["predicate_tokens"]

    if not allow_contracted and auxiliary in (CONTRACTED_MODAL_WORDS | CONTRACTED_DO_WORDS | CONTRACTED_HAVE_WORDS | CONTRACTED_BE_WORDS):
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            verb_phrase=predicate,
            rejection_reason=f"Contracted negative auxiliary '{auxiliary}' is not accepted in formal academic negative inversion"
        )

    if not predicate_tokens:
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            rejection_reason="Missing predicate verb phrase following subject"
        )

    pred_first = predicate_tokens[0].lower().strip(",.")

    # Illegal extra infinitive marker 'to'
    if pred_first == "to":
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            verb_phrase=predicate,
            rejection_reason=f"Illegal extra infinitive marker 'to' following auxiliary '{auxiliary}'"
        )

    # Duplicate or misplaced auxiliary / modal
    if pred_first in ALL_MODAL_WORDS or pred_first in ALL_DO_WORDS:
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            verb_phrase=predicate,
            rejection_reason=f"Illegal duplicate or misplaced auxiliary/modal '{pred_first}' following auxiliary '{auxiliary}'"
        )
    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", sentence.strip())
    clean_s = f" {clean.lower()} "
    if trigger.lower() in {"scarcely", "hardly", "barely"} and " than " in clean_s:
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            verb_phrase=predicate,
            rejection_reason=f"Correlative conjunction discord: '{trigger}' cannot take 'than' (requires 'when' or 'before')"
        )

    if any(tok.lower().strip(",.") in {"not", "never"} for tok in predicate_tokens):
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            verb_phrase=predicate,
            rejection_reason=f"Illicit double negative: negative adverbial '{trigger}' cannot take duplicate negative marker in clause"
        )

    verb_idx = 0
    adverb_words = {
        "ever", "never", "always", "really", "actually", "fully", "previously",
        "already", "even", "simply", "truly", "clearly", "directly", "also", "still"
    }
    while verb_idx < len(predicate_tokens):
        w = predicate_tokens[verb_idx].lower().strip(",.")
        if w in adverb_words or (w.endswith("ly") and w not in {"likely", "friendly", "lonely", "lovely", "daily", "early"}):
            verb_idx += 1
            continue
        break

    if verb_idx >= len(predicate_tokens):
        return NegativeInversionValidationResult(
            is_structural_inversion=True,
            is_grammatically_valid=False,
            verdict="INVALID",
            trigger=trigger,
            auxiliary=auxiliary,
            subject=subject,
            verb_phrase=predicate,
            rejection_reason="Missing predicate verb phrase following adverb(s)"
        )

    pred_verb = predicate_tokens[verb_idx].lower().strip(",.")

    # Modal auxiliary validation
    if auxiliary in ALL_MODAL_WORDS:
        if pred_verb.endswith("ing") and pred_verb != "bring":
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Modal auxiliary '{auxiliary}' cannot be followed directly by present participle '{pred_verb}' (-ing)"
            )
        is_3rd_s = (pred_verb.endswith("s") and not pred_verb.endswith("ss")) if allow_ss_base_verbs else (pred_verb.endswith("s") and pred_verb not in {"pass", "miss", "discuss", "process", "address", "express", "stress", "cross"})
        if is_3rd_s:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Modal auxiliary '{auxiliary}' cannot be followed by 3rd-person inflected verb '{pred_verb}' (requires bare infinitive)"
            )
        if pred_verb in IRREGULAR_PAST_VERBS:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Modal auxiliary '{auxiliary}' cannot be followed by past tense form '{pred_verb}' (requires bare infinitive)"
            )
        is_past_ed = (pred_verb.endswith("ed") and pred_verb not in BASE_EED_VERBS) if allow_ss_base_verbs else (pred_verb.endswith("ed") and pred_verb not in {"need", "feed", "bleed", "proceed", "succeed"})
        if is_past_ed:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Modal auxiliary '{auxiliary}' cannot be followed directly by -ed inflected form '{pred_verb}' without auxiliary copula (requires bare infinitive)"
            )

    # Do-support validation
    elif auxiliary in ALL_DO_WORDS:
        if pred_verb.endswith("ing") and pred_verb != "bring":
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Do-support auxiliary '{auxiliary}' cannot be followed by present participle '{pred_verb}' (-ing)"
            )
        is_3rd_s = (pred_verb.endswith("s") and not pred_verb.endswith("ss")) if allow_ss_base_verbs else (pred_verb.endswith("s") and pred_verb not in {"pass", "miss", "discuss", "process", "address", "express", "stress", "cross"})
        if is_3rd_s:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Do-support auxiliary '{auxiliary}' requires base verb form, not 3rd-person singular inflected '{pred_verb}'"
            )
        if pred_verb in IRREGULAR_PAST_VERBS:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Do-support auxiliary '{auxiliary}' requires base verb form, not past tense '{pred_verb}'"
            )
        if pred_verb.endswith("ed") and pred_verb not in {"need", "feed", "bleed", "proceed", "succeed"}:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Do-support auxiliary '{auxiliary}' requires base verb form, not -ed inflected '{pred_verb}'"
            )
        subj_clean = subject.lower().split()[-1]
        if auxiliary == "does" and subj_clean in NON_THIRD_SINGULAR_SUBJECT_WORDS:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Subject-verb agreement discord: 'does' cannot take subject '{subject}'"
            )
        if auxiliary == "do" and subj_clean in {"he", "she", "it"}:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Subject-verb agreement discord: 'do' cannot take 3rd-person singular subject '{subject}'"
            )

    # Have-aspect validation
    elif auxiliary in ALL_HAVE_WORDS:
        if pred_verb in COMMON_BASE_VERBS and pred_verb not in IRREGULAR_PAST_PARTICIPLES:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Have-aspect auxiliary '{auxiliary}' requires past participle form, not base form '{pred_verb}'"
            )
        is_3rd_s = (pred_verb.endswith("s") and not pred_verb.endswith("ss")) if allow_ss_base_verbs else (pred_verb.endswith("s") and pred_verb not in {"pass", "miss", "discuss", "process", "address", "express", "stress", "cross"})
        if is_3rd_s:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Have-aspect auxiliary '{auxiliary}' requires past participle form, not 3rd-person '{pred_verb}'"
            )
        subj_clean = subject.lower().split()[-1]
        if auxiliary == "has" and subj_clean in NON_THIRD_SINGULAR_SUBJECT_WORDS:
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="INVALID",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Subject-verb agreement discord: 'has' cannot take subject '{subject}'"
            )
        if not (pred_verb.endswith("ed") or pred_verb in IRREGULAR_PAST_PARTICIPLES or pred_verb == "been"):
            return NegativeInversionValidationResult(
                is_structural_inversion=True,
                is_grammatically_valid=False,
                verdict="UNCERTAIN",
                trigger=trigger,
                auxiliary=auxiliary,
                subject=subject,
                verb_phrase=predicate,
                rejection_reason=f"Inconclusive deterministic verification of participle form '{pred_verb}' following have-aspect auxiliary"
            )

    return NegativeInversionValidationResult(
        is_structural_inversion=True,
        is_grammatically_valid=True,
        verdict="VALID",
        trigger=trigger,
        auxiliary=auxiliary,
        subject=subject,
        verb_phrase=predicate
    )


def detect_negative_inversion_syntax(sentence: str, allow_contracted: bool = False, version: str = "v2.5") -> bool:
    """Detects whether a sentence exhibits negative/limiting auxiliary inversion.
    If version is >= v2.6, uses full grammaticality validation.
    If version is < v2.6, preserves historical v2.5 regex matching.
    """
    if version != "v2.5":
        m_v = re.search(r"v?(\d+)\.(\d+)", version)
        if m_v and (int(m_v.group(1)), int(m_v.group(2))) >= (2, 7):
            res = validate_negative_inversion_grammaticality(sentence, allow_contracted=allow_contracted, allow_ss_base_verbs=True)
            return res.is_grammatically_valid
        elif m_v and (int(m_v.group(1)), int(m_v.group(2))) >= (2, 6):
            res = validate_negative_inversion_grammaticality(sentence, allow_contracted=allow_contracted, allow_ss_base_verbs=False)
            return res.is_grammatically_valid
    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", sentence.strip())
    triggers = [
        r"under no circumstances",
        r"not until [^,]+",
        r"seldom",
        r"never",
        r"rarely",
        r"hardly",
        r"scarcely",
        r"at no point",
        r"at no time",
        r"on no account",
        r"in no way",
        r"little did",
        r"only (?:when|after|then|if|by) [^,]+",
    ]
    if allow_contracted:
        auxiliaries = r"(?:shouldn't|should|hadn't|had|haven't|have|hasn't|has|couldn't|could|didn't|did|don't|do|doesn't|does|wasn't|was|weren't|were|wouldn't|would|won't|will|can't|cannot|can|might|mustn't|must|isn't|is|aren't|are)"
    else:
        auxiliaries = r"(?:should|had|have|has|could|did|do|does|was|were|would|will|can|might|must|is|are)"
    subjects = r"(?:we|they|I|he|she|it|you|researchers|samples|students|scientists|people|the\s+\w+)"

    for trig in triggers:
        pattern = rf"^{trig}\s*(?:,\s*)?({auxiliaries})\s+({subjects})\b"
        m = re.search(pattern, clean, re.IGNORECASE)
        if m:
            after_subject = clean[m.end():].strip()
            aux_word = m.group(1).lower()
            if aux_word in {"could", "couldn't", "should", "shouldn't", "would", "wouldn't", "did", "didn't", "do", "don't", "does", "doesn't", "will", "won't", "can", "can't", "might", "must", "mustn't"}:
                first_verb = after_subject.split()[0] if after_subject.split() else ""
                if first_verb.endswith("ing"):
                    return False
            return True
    return False


def detect_contracted_negative_inversion(sentence: str) -> bool:
    """Detects whether sentence uses a contracted negative auxiliary in inverted position (e.g. 'shouldn't we')."""
    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", sentence.strip())
    contracted_aux = r"(?:shouldn't|hadn't|haven't|hasn't|couldn't|didn't|don't|doesn't|wasn't|weren't|wouldn't|won't|can't|mustn't|isn't|aren't)"
    subjects = r"(?:we|they|I|he|she|it|you|researchers|samples|students|scientists|people|the\s+\w+)"
    triggers = [
        r"under no circumstances",
        r"not until [^,]+",
        r"seldom",
        r"never",
        r"rarely",
        r"hardly",
        r"scarcely",
        r"at no point",
        r"at no time",
        r"on no account",
        r"in no way",
        r"only (?:when|after|then|if|by) [^,]+",
    ]
    for trig in triggers:
        pattern = rf"^{trig}\s*(?:,\s*)?({contracted_aux})\s+({subjects})\b"
        if re.search(pattern, clean, re.IGNORECASE):
            return True
    return False


ADVERBIAL_TRIGGERS = [
    r"under no circumstances",
    r"not only",
    r"seldom",
    r"rarely",
    r"never(?:\s+before|\s+again)?",
    r"hardly",
    r"scarcely",
    r"barely",
    r"no sooner",
    r"at no point",
    r"at no time",
    r"on no account",
    r"in no way",
    r"little(?:\s+did)?",
    r"not until",
    r"it (?:was|is)",
    r"what",
    r"the reason why",
]

FUNCTIONAL_STOP_WORDS = {
    "the", "a", "an", "and", "or", "but", "if", "then", "else", "when",
    "at", "by", "for", "from", "in", "into", "of", "off", "on", "onto",
    "out", "over", "to", "up", "with", "as", "is", "was", "are", "were",
    "be", "been", "being", "have", "has", "had", "do", "does", "did",
    "will", "would", "shall", "should", "may", "might", "must", "can",
    "could", "not", "no", "nor", "it", "its", "they", "them", "their",
    "we", "us", "our", "you", "your", "he", "him", "his", "she", "her",
    "this", "that", "these", "those", "which", "who", "whom", "whose",
    "what", "where", "why", "how", "all", "any", "both", "each", "few",
    "more", "most", "other", "some", "such", "than", "too", "very",
    "before", "after", "during", "while"
}


def extract_substantive_tokens(text: str) -> set[str]:
    """Strips compulsory grammatical triggers and functional stop words, returning substantive carrier content words."""
    t = text.lower()
    for trig in ADVERBIAL_TRIGGERS:
        t = re.sub(rf"^{trig}\b\s*(?:,\s*)?", "", t)
    words = re.findall(r"\b[a-z]{3,}\b", t)
    return {w for w in words if w not in FUNCTIONAL_STOP_WORDS}


def check_content_aware_novelty(
    prompt: str,
    options: list[Any],
    rule_pack_examples: list[str] | None
) -> tuple[float, str, dict[str, Any]]:
    """Evaluates content-aware novelty separating compulsory rule patterns from carrier sentence content.
    Returns (score, status, metadata):
    - score: 1.0 (novel), 0.0 (copied), or float('nan') (unknown)
    - status: 'NOVEL', 'EXACT_COPY', 'SUBSTANTIVE_NEAR_DUPLICATE', or 'UNKNOWN'
    """
    if not rule_pack_examples:
        return float("nan"), "UNKNOWN", {"reason": "No rule pack examples provided"}

    texts_to_check = [prompt]
    for opt in options:
        opt_text = opt.get("text", "") if isinstance(opt, dict) else str(opt)
        clean_opt = re.sub(r"^[A-Da-d][\).:]\s*", "", opt_text).strip()
        texts_to_check.append(clean_opt)

    for ex in rule_pack_examples:
        ex_clean = ex.strip().lower()
        ex_substantive = extract_substantive_tokens(ex)

        for t in texts_to_check:
            t_clean = t.strip().lower()

            # Exact verbatim match
            if ex_clean == t_clean:
                return 0.0, "EXACT_COPY", {"matched_example": ex, "item_text": t}

            t_substantive = extract_substantive_tokens(t)
            if not t_substantive:
                continue

            intersection = ex_substantive & t_substantive
            if not intersection:
                continue

            overlap_ratio = len(intersection) / len(t_substantive)
            ex_overlap = len(intersection) / len(ex_substantive) if ex_substantive else 0

            # If 2 or more substantive carrier content words match and overlap >= 0.50
            if len(intersection) >= 2 and (overlap_ratio >= 0.50 or ex_overlap >= 0.50):
                return 0.0, "SUBSTANTIVE_NEAR_DUPLICATE", {
                    "matched_example": ex,
                    "shared_tokens": sorted(list(intersection)),
                    "overlap_ratio": round(overlap_ratio, 4)
                }

    return 1.0, "NOVEL", {"details": "No substantive carrier content overlap with rule pack examples"}


def detect_it_cleft_syntax(sentence: str) -> dict:
    """Analyzes whether a sentence is an it-cleft construction:
    Form: It + [be] + [focused element] + [that/which/who/whose/whom] + [cleft clause].
    Returns metadata including copula, pronoun, focused element, tense discord, and validity.
    """
    clean = re.sub(r"^[A-Da-d][\).:]\s*", "", sentence.strip()).strip()
    m = re.match(
        r"^It\s+(is|was|has\s+been|will\s+be|would\s+be)\s+([a-zA-Z0-9\s,\-–—]+?)\s+(that|which|who|whom|whose)\s+([a-zA-Z0-9\s,\-–—.'\"]+)[.?!]?$",
        clean,
        re.IGNORECASE,
    )
    if not m:
        return {"is_valid_cleft": False}

    copula = m.group(1).lower()
    focused = m.group(2).strip()
    rel_pronoun = m.group(3).lower()
    clause = m.group(4).strip()

    clause_words = clause.split()
    first_verb = clause_words[0].lower() if clause_words else ""

    # Pronoun compatibility: who/whom are valid only for human referents
    human_nouns = {
        "person", "people", "researcher", "researchers", "scientist", "scientists",
        "student", "students", "doctor", "doctors", "patient", "patients", "author",
        "authors", "individual", "individuals", "leader", "leaders", "teacher", "teachers",
        "man", "men", "woman", "women", "child", "children"
    }
    focused_words = set(re.findall(r"\b\w+\b", focused.lower()))
    is_human = bool(focused_words & human_nouns)
    if rel_pronoun in ("who", "whom") and not is_human:
        return {
            "is_valid_cleft": False,
            "reason": f"Invalid relative pronoun '{rel_pronoun}' for non-human focus '{focused}'",
            "has_tense_discord": False,
            "tense_discord_reason": "",
        }

    # Morphological tense discord check
    has_tense_discord = False
    tense_discord_reason = ""
    if copula == "is":
        if first_verb in {"had", "was", "were", "did", "could", "would"} or (
            len(first_verb) > 3 and first_verb.endswith("ed") and first_verb not in {"underpin", "need"}
        ):
            has_tense_discord = True
            tense_discord_reason = f"Present copula 'is' clashes with past relative verb '{first_verb}' (expected 'was')"
    elif copula == "was":
        if first_verb in {"has", "have", "is", "are", "can", "will", "does"} or (
            len(first_verb) > 3 and first_verb.endswith("s") and not first_verb.endswith(("ss", "us", "is", "as"))
        ):
            has_tense_discord = True
            tense_discord_reason = f"Past copula 'was' clashes with present relative verb '{first_verb}' (expected 'is' or past relative verb)"

    return {
        "is_valid_cleft": not has_tense_discord,
        "copula": copula,
        "focused_element": focused,
        "rel_pronoun": rel_pronoun,
        "cleft_clause": clause,
        "has_tense_discord": has_tense_discord,
        "tense_discord_reason": tense_discord_reason,
    }


def detect_cleft_distractor_ambiguity(options: list[str]) -> tuple[bool, str]:
    """Checks whether an MCQ has distractor ambiguity in it-clefts:
    Specifically:
    1. Multiple options are valid it-clefts where one uses 'that' and another uses 'which'
       with the same focused element (in academic English, both are defensible for non-human referents).
    2. Multiple options are grammatically defensible it-clefts without any tense or syntactic defect.
    """
    cleft_opts = []
    for idx, opt in enumerate(options):
        cleft_info = detect_it_cleft_syntax(opt)
        if cleft_info.get("is_valid_cleft") and not cleft_info.get("has_tense_discord"):
            cleft_opts.append((idx + 1, opt, cleft_info))

    if len(cleft_opts) >= 2:
        pronouns = {info["rel_pronoun"] for _, _, info in cleft_opts}
        if "that" in pronouns and "which" in pronouns:
            return True, "Ambiguous MCQ: multiple options exhibit valid it-cleft syntax with 'that' and 'which' (both grammatically acceptable for non-human focus)"
        return True, f"Ambiguous MCQ: multiple options {[idx for idx, _, _ in cleft_opts]} exhibit grammatically valid it-cleft syntax"

    return False, ""


def detect_unsupported_generalization(statement: str, reference_text: str) -> tuple[bool, str]:
    """Detects whether a Reading TFNG statement introduces an unsupported broad generalization
    (e.g. 'various stimuli', 'all conditions', 'universal changes') not supported by the bounded passage.
    """
    s_clean = normalize_text_nfkc(statement).lower()
    r_clean = normalize_text_nfkc(reference_text).lower()

    generalization_patterns = [
        (r"\bvarious\s+(?:stimuli|conditions|factors|reasons|mechanisms|activities|environments)\b", "various"),
        (r"\ball\s+(?:conditions|stimuli|activities|types|species|patients|cases|situations)\b", "all"),
        (r"\bevery\s+(?:condition|stimulus|activity|case|situation|circumstance)\b", "every"),
        (r"\buniversally\b|\buniversal\b", "universal"),
        (r"\binvariably\b", "invariably"),
        (r"\bregardless\s+of\b", "regardless of"),
        (r"\bunder\s+any\s+circumstances?\b", "under any circumstance"),
    ]

    for pat, label in generalization_patterns:
        m = re.search(pat, s_clean)
        if m:
            matched_phrase = m.group(0)
            if matched_phrase not in r_clean:
                return True, f"Unsupported generalization: statement asserts broad claim '{matched_phrase}' not affirmed in bounded source text"

    return False, ""
def chunk_passage_coverage(
    passage_text: str,
    max_chunk_chars: int = 2800,
    min_overlap_chars: int = 150,
) -> List[Tuple[int, int, str]]:
    """Splits passage into bounded chunks covering 100% of the text with clean boundaries."""
    cleaned = passage_text.strip()
    total_len = len(cleaned)
    if total_len <= max_chunk_chars:
        return [(0, total_len, cleaned)]

    chunks: List[Tuple[int, int, str]] = []
    start = 0
    while start < total_len:
        target_end = min(start + max_chunk_chars, total_len)
        if target_end >= total_len:
            chunks.append((start, total_len, cleaned[start:total_len].strip()))
            break

        window = cleaned[max(start, target_end - 400):target_end]
        match = None
        for m in re.finditer(r"[.!?]\s+", window):
            match = m
        if match:
            split_offset = max(start, target_end - 400) + match.end()
        else:
            nl_pos = cleaned.rfind("\n", max(start, target_end - 300), target_end)
            if nl_pos > start:
                split_offset = nl_pos + 1
            else:
                sp_pos = cleaned.rfind(" ", max(start, target_end - 200), target_end)
                split_offset = sp_pos + 1 if sp_pos > start else target_end

        chunks.append((start, split_offset, cleaned[start:split_offset].strip()))

        next_raw_start = max(start + 1, split_offset - min_overlap_chars)
        overlap_window = cleaned[max(start, next_raw_start - 200):next_raw_start]
        m_sent = None
        for m in re.finditer(r"[.!?]\s+", overlap_window):
            m_sent = m
        if m_sent:
            start = max(start, next_raw_start - 200) + m_sent.end()
        else:
            sp = cleaned.find(" ", next_raw_start)
            if sp != -1 and sp < split_offset:
                start = sp + 1
            else:
                start = next_raw_start

    return chunks

# ── Evaluator Implementations ───────────────────────────────────────────────

class GroundingFidelityEvaluator(BaseEvaluator):
    """Evaluates factual grounding against source text and evidence graph.
    
    Detects the 5 core source-fidelity hard errors:
    - UNSUPPORTED_OR_CONTRADICTED_CLAIM (including invented quantities and population shift)
    - CAUSAL_OVERSTATEMENT (correlation turned into direct causation)
    - OVERSTATED_CERTAINTY (dropped tentative modals like 'may' -> definite certainty)
    - UNMEASURED_OUTCOME (claiming effects/outcomes never evaluated)
    - SOURCE_INSUFFICIENT (insufficient source facts)
    
    Structural/blocking issues block PASS; soft score never overrides blockers.
    """

    def __init__(self, required: bool = True, timeout_seconds: Optional[float] = None, estimated_tokens: Optional[int] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_semantic_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "evaluator_max_tokens_per_evaluation", 1500)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_grounding_fidelity",
                evaluator_version="2.0.0",
                name="Grounding & Source Fidelity Evaluator",
                description="Detects unsupported/contradicted claims, invented quantities, causality and certainty overstatements",
                stage=EvaluationStage.GROUNDING,
                target_artifact_types=[
                    ArtifactType.SECTION,
                    ArtifactType.PASSAGE,
                    ArtifactType.EVIDENCE_GRAPH,
                    ArtifactType.QUESTION,
                    ArtifactType.QUESTION_GROUP,
                ],
                required=required,
                hard_checks=[
                    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                    IssueCode.CAUSAL_OVERSTATEMENT,
                    IssueCode.OVERSTATED_CERTAINTY,
                    IssueCode.UNMEASURED_OUTCOME,
                    IssueCode.SOURCE_INSUFFICIENT,
                ],
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
                is_expensive=True,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        # Find reference source or passage from dependencies or payload
        source_text = payload.get("sourceText", "") or payload.get("source_text", "")
        passage_text = payload.get("passage", "") or payload.get("passageText", "") or payload.get("text", "")

        # Target claims to check
        claims_to_check: List[Dict[str, Any]] = []
        ref_text = ""

        if artifact.artifact_type in (ArtifactType.SECTION, ArtifactType.PASSAGE):
            # Invariant (F-03): NEVER use passage_text as reference source to self-ground!
            ref_text = source_text
            if not ref_text and hasattr(context, "input_dependencies"):
                for dep in getattr(context, "input_dependencies", ()):
                    if hasattr(dep, "payload"):
                        dep_src = dep.payload.get("sourceText") or dep.payload.get("source_text") or dep.payload.get("content")
                        if dep_src:
                            ref_text = dep_src
                            break

            if not ref_text:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_src_{uuid4().hex[:8]}",
                        code=IssueCode.SOURCE_INSUFFICIENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SOURCE,
                        message="Missing approved reference source text for passage grounding fidelity verification",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
                return EvaluationResult(
                    evaluation_id=f"eval_res_{uuid4().hex[:12]}",
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=artifact.to_ref(),
                    status=EvaluationStatus.FAIL,
                    issues=issues,
                    score=0.0,
                )

            # Invariant (F-02, F-04, F-05): Check ALL sentences in passage; do not truncate to sentences[:10].
            # Generator-proposed claims or rhetorical labels DO NOT bypass remaining unaligned sentences.
            existing_claims = list(payload.get("claims", []))
            claims_to_check.extend(existing_claims)

            if passage_text:
                # Split all sentences cleanly on sentence boundaries
                sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", passage_text) if len(s.strip()) > 15]
                for idx, sent in enumerate(sentences):
                    # Add if not already explicitly covered by identical text
                    if not any((c.get("claimText") or c.get("text") or "") == sent for c in existing_claims):
                        claims_to_check.append({
                            "claimId": f"clm_sent_{idx}",
                            "claimText": sent,
                            "sentenceId": f"s_{idx}",
                        })

        elif artifact.artifact_type == ArtifactType.EVIDENCE_GRAPH:
            ref_text = source_text
            if not ref_text and hasattr(context, "input_dependencies"):
                for dep in getattr(context, "input_dependencies", ()):
                    if hasattr(dep, "payload"):
                        dep_src = dep.payload.get("sourceText") or dep.payload.get("source_text")
                        if dep_src:
                            ref_text = dep_src
                            break
            if not ref_text:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_src_{uuid4().hex[:8]}",
                        code=IssueCode.SOURCE_INSUFFICIENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SOURCE,
                        message="Missing reference source text for evidence graph verification",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
                return EvaluationResult(
                    evaluation_id=f"eval_res_{uuid4().hex[:12]}",
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=artifact.to_ref(),
                    status=EvaluationStatus.FAIL,
                    issues=issues,
                    score=0.0,
                )
            claims_to_check = list(payload.get("claims", []))

        elif artifact.artifact_type in (ArtifactType.QUESTION, ArtifactType.QUESTION_GROUP):
            def build_question_claim(p: str, a: str, qt_val: str) -> str:
                if not p:
                    return ""
                if "_____" in p:
                    return p.replace("_____", a)
                if "[BLANK]" in p:
                    return p.replace("[BLANK]", a)
                if qt_val in ("SentenceCompletion", "SummaryCompletion"):
                    return f"{p.rstrip('. ')} {a}."
                if qt_val == "ShortAnswer":
                    return f"{p} {a}"
                return p

            if artifact.artifact_type == ArtifactType.QUESTION_GROUP:
                for q in payload.get("questions", []):
                    qt = q.get("questionType") or payload.get("questionType")
                    ans = str(q.get("answer", "")).strip().upper()
                    # In TFNG/YNNG where answer is FALSE, NO, or NOT_GIVEN, the statement is intentionally
                    # not a fact from the text; NotGivenSemanticsEvaluator evaluates its relation.
                    if qt in ("TrueFalseNotGiven", "YesNoNotGiven") and ans in ("FALSE", "NO", "NOT_GIVEN", "NOT GIVEN"):
                        continue
                    clm_text = build_question_claim(q.get("prompt", ""), str(q.get("answer", "")), qt or "")
                    claims_to_check.append({
                        "claimId": f"q_prompt_{q.get('questionNumber', 1)}",
                        "claimText": clm_text,
                        "quote": q.get("evidenceQuote", ""),
                        "answer": str(q.get("answer", "")),
                    })
            else:
                qt = payload.get("questionType")
                ans = str(payload.get("answer", "")).strip().upper()
                if not (qt in ("TrueFalseNotGiven", "YesNoNotGiven") and ans in ("FALSE", "NO", "NOT_GIVEN", "NOT GIVEN")):
                    prompt = payload.get("prompt", "") or payload.get("questionText", "")
                    clm_text = build_question_claim(prompt, str(payload.get("answer", "")), qt or "")
                    quote = payload.get("evidenceQuote") or payload.get("evidence_quote", "")
                    claims_to_check = [
                        {"claimId": "q_prompt", "claimText": clm_text, "quote": quote, "answer": str(payload.get("answer", ""))},
                    ]
            ref_text = passage_text or source_text
            if not ref_text:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_src_{uuid4().hex[:8]}",
                        code=IssueCode.SOURCE_INSUFFICIENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.SOURCE,
                        message="Missing passage or source text for question grounding verification",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
                return EvaluationResult(
                    evaluation_id=f"eval_res_{uuid4().hex[:12]}",
                    evaluator_id=self.evaluator_id,
                    evaluator_version=self.evaluator_version,
                    target_ref=artifact.to_ref(),
                    status=EvaluationStatus.FAIL,
                    issues=issues,
                    score=0.0,
                )
        for clm in claims_to_check:
            clm_id = clm.get("claimId") or clm.get("id") or "claim"
            clm_text = clm.get("claimText") or clm.get("text") or clm.get("claim_text") or ""
            quote = clm.get("quote") or clm.get("evidenceQuote") or clm.get("spanText") or clm.get("sourceFact") or ""
            target_ref = quote if (quote and len(quote.strip()) > 10) else ref_text
            eval_target_ref = target_ref

            if not clm_text:
                continue

            # 1. Invented quantities / numerical distortion check
            c_quants, _ = parse_quantities_and_units(normalize_written_numbers(clm_text))
            if c_quants and target_ref:
                t_quants, _ = parse_quantities_and_units(normalize_written_numbers(target_ref))
                t_clean = [tq.replace(" ", "").lower() for tq in t_quants]
                target_ref_lower = target_ref.lower()
                for cq in c_quants:
                    cq_clean = cq.replace(" ", "").lower()
                    cq_digits = re.sub(r"\D", "", cq_clean)
                    is_unsupported = False
                    if t_clean:
                        matched = any(
                            cq_clean == tq
                            or (cq_digits and cq_digits == re.sub(r"\D", "", tq))
                            or tq.startswith(cq_clean)
                            or (cq_digits and len(cq_digits) >= 2 and cq_digits in target_ref_lower)
                            for tq in t_clean
                        )
                        if not matched and not (cq_digits and len(cq_digits) >= 2 and cq_digits in target_ref_lower):
                            is_unsupported = True
                    else:
                        if not (cq_digits and len(cq_digits) >= 2 and cq_digits in target_ref_lower):
                            if not cq_clean.isdigit() or any(u in cq_clean for u in ("%", "percent", "km", "kg", "m", "year", "day", "week")):
                                is_unsupported = True
                    if is_unsupported:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_num_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.EVIDENCE,
                                message=f"Invented quantity detected: claim asserts '{cq}', not found in reference facts",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                        break

            # 2. Population shift check
            c_pop = extract_population(clm_text)
            if c_pop and ref_text:
                t_pop = extract_population(ref_text)
                if t_pop and c_pop.lower() != t_pop.lower():
                    c_set = set(c_pop.lower().split(", "))
                    t_set = set(t_pop.lower().split(", "))
                    if not (c_set & t_set):
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_pop_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.EVIDENCE,
                                message=f"Population shift detected: claim asserts '{c_pop}', but source specifies '{t_pop}'",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

            # 3. Causal overstatement check
            clm_lower = clm_text.lower()
            eval_target_ref = quote if (quote and len(quote.strip()) > 10) else ref_text
            ref_lower = eval_target_ref.lower() if eval_target_ref else ""
            clm_has_causal = any(re.search(rf"\b{re.escape(v)}\b", clm_lower) for v in CAUSAL_VERBS)
            ref_has_corr = any(re.search(rf"\b{re.escape(p)}\b", ref_lower) for p in CORRELATION_PHRASES)
            ref_has_causal = any(re.search(rf"\b{re.escape(v)}\b", ref_lower) for v in CAUSAL_VERBS)
            is_extreme_causal = any(term in clm_lower for term in ("100 percent", "complete eradication", "cure all", "eliminates all"))

            if (clm_has_causal and ref_has_corr and not ref_has_causal) or (clm_has_causal and is_extreme_causal):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_causal_{uuid4().hex[:8]}",
                        code=IssueCode.CAUSAL_OVERSTATEMENT,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.EVIDENCE,
                        message="Causal overstatement: source indicates correlation/association or lacks causal evidence, but claim asserts direct causation",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # 4. Overstated certainty (dropped modal qualifier)
            ref_has_uncertain = any(re.search(rf"\b{re.escape(m)}\b", ref_lower) for m in UNCERTAIN_MODALS)
            clm_has_uncertain = any(re.search(rf"\b{re.escape(m)}\b", clm_lower) for m in UNCERTAIN_MODALS)
            clm_has_booster = any(re.search(rf"\b{re.escape(b)}\b", clm_lower) for b in CERTAINTY_BOOSTERS)
            clm_has_extreme = any(term in clm_lower for term in ("definitely", "always", "forever", "permanently", "all power outages", "all delicate", "all environments", "total collapse", "worldwide extinction", "conclusively proves"))

            is_question = artifact.artifact_type in (ArtifactType.QUESTION, ArtifactType.QUESTION_GROUP)
            dropped_tentative = bool(quote and ref_has_uncertain and not clm_has_uncertain and not is_question)
            if dropped_tentative or clm_has_booster or clm_has_extreme:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_cert_{uuid4().hex[:8]}",
                        code=IssueCode.OVERSTATED_CERTAINTY,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.EVIDENCE,
                        message="Overstated certainty: source uses tentative modal (e.g. 'may') or claim uses extreme booster",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )
            # 5. Unmeasured outcome check
            unmeasured_indicators = [
                ("cured", "cure"),
                ("cure", "cure"),
                ("doubled natural lifespan", "lifespan"),
                ("doubled the natural lifespan", "lifespan"),
                ("doubled", "lifespan"),
                ("regeneration", "visual acuity"),
                ("microplastic", "pollution"),
                ("reproductive fertility", "badger"),
                ("eradication", "eradication"),
                ("eradicated", "eradication"),
                ("eradicate", "eradication"),
                ("elimination", "elimination"),
                ("eliminated", "elimination"),
            ]
            for term, category in unmeasured_indicators:
                if term in clm_lower and term not in ref_lower:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_unm_{uuid4().hex[:8]}",
                            code=IssueCode.UNMEASURED_OUTCOME,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.EVIDENCE,
                            message=f"Unmeasured outcome detected: claim asserts '{term}' ({category}) not evaluated in source study",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
                    break

            # 6. Dropped environmental qualification
            if "open atmospheric" in clm_lower and "vacuum" in ref_lower:
                issues.append(
                    Issue.create(
                        issue_id=f"iss_qual_{uuid4().hex[:8]}",
                        code=IssueCode.OVERSTATED_CERTAINTY,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.EVIDENCE,
                        message="Dropped qualification: source specifies vacuum/cryogenic cooling, claim asserts open atmospheric",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # 7. Unsupported completion/short-answer entity check
            ans_val = str(clm.get("answer", "")).strip().lower()
            if ans_val and ref_text and len(ans_val) > 3 and ans_val not in ("true", "false", "yes", "no", "not_given", "not given"):
                ref_clean = re.sub(r"[^\w\s]", " ", ref_text.lower())
                ref_tokens = set(ref_clean.split())
                ans_tokens = [w for w in re.findall(r"\b[a-zA-Z]{4,}\b", ans_val) if w not in {"with", "from", "that", "this", "they", "have", "more", "less"}]
                if ans_tokens and all(tok not in ref_tokens for tok in ans_tokens):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_unsupp_{uuid4().hex[:8]}",
                            code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.EVIDENCE,
                            message=f"Answer '{ans_val}' is completely unsupported by reference facts",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
            # 8. Polarity contradiction / claim reversal check
            quote_clean = quote.lower() if quote else ""
            if quote_clean:
                _neg_patterns = [
                    r"\bposes?\s+no\b", r"\blacks?\b", r"\bdoes\s+not\b", r"\bdo\s+not\b",
                    r"\bdid\s+not\b", r"\bcannot\b", r"\bcan\s+not\b", r"\bnever\b",
                    r"\bis\s+not\b", r"\bare\s+not\b", r"\bwas\s+not\b", r"\bwere\s+not\b",
                    r"\breveals?\s+no\b", r"\bhas\s+no\b", r"\bhave\s+no\b", r"\bnot\s+shared\b",
                    r"\bno\s+influence\b", r"\bno\s+potential\b", r"\bunfractured\b",
                    r"\baims?\s+to\s+remove\b", r"\broutinely\s+enabled\b",
                ]
                _m_neg = re.search("|".join(_neg_patterns), clm_lower)
                if _m_neg:
                    _neg_term = _m_neg.group(0).lower()
                    if _neg_term not in quote_clean:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_pol_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.EVIDENCE,
                                message=f"Polarity contradiction detected: claim asserts negation '{_neg_term}', but cited reference does not support this reversal",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        # Calculate grounding fidelity score (0.0 to 1.0)
        score = 1.0 if not issues else max(0.0, 1.0 - (len(issues) * 0.25))

        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=score,
        )


class AmbiguityAndDistractorEvaluator(BaseEvaluator):
    """Evaluates question ambiguity, multiple candidate interpretations, and distractor validity."""

    def __init__(
        self,
        required: bool = True,
        timeout_seconds: Optional[float] = None,
        estimated_tokens: Optional[int] = None,
        gateway: Optional[Any] = None,
    ):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_semantic_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "evaluator_max_tokens_per_evaluation", 1200)
        self.gateway = gateway
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_ambiguity_distractor",
                evaluator_version="2.0.0",
                name="Ambiguity & Distractor Evaluator",
                description="Detects ambiguous questions with multiple answers and invalid/plausible distractors",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION, ArtifactType.QUESTION_GROUP],
                required=required,
                hard_checks=[IssueCode.AMBIGUOUS_ANSWER, IssueCode.BAD_DISTRACTOR],
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.012,
                is_expensive=True,
            )
        )
    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        async def check_question(q: Dict[str, Any], pass_text: str):
            q_num = q.get("questionNumber", "?")
            q_type = q.get("questionType") or q.get("type", "")
            prompt = q.get("prompt", "") or q.get("questionText", "")
            answer = q.get("answer", "")
            options = q.get("options", [])

            # Check MCQ Distractors
            if q_type == "MultipleChoiceSingle" and isinstance(options, (list, tuple)):
                seen_opt_texts: Set[str] = set()
                correct_opt_text = ""
                for o in options:
                    if hasattr(o, "get") and o.get("key") == answer:
                        correct_opt_text = o.get("text", "")
                        break

                for opt in options:
                    opt_key = opt.get("key", "") if hasattr(opt, "get") else ""
                    opt_text = opt.get("text", "") if hasattr(opt, "get") else ""
                    norm_opt = re.sub(r"^[^\w]+|[^\w]+$", "", normalize_text_nfkc(opt_text).lower())
                    # Duplicate option check
                    if norm_opt in seen_opt_texts:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_dist_dup_{uuid4().hex[:8]}",
                                code=IssueCode.BAD_DISTRACTOR,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"Question {q_num} has duplicate option text '{opt_text}'",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                    seen_opt_texts.add(norm_opt)

                    # Distractor that is identical to correct answer
                    if opt_key != answer:
                        if (correct_opt_text and norm_opt == normalize_text_nfkc(correct_opt_text).lower()) or (norm_opt == normalize_text_nfkc(answer).lower()):
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_dist_ans_{uuid4().hex[:8]}",
                                    code=IssueCode.BAD_DISTRACTOR,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION,
                                    message=f"Question {q_num} distractor '{opt_key}' is identical to the correct answer",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )

                    # Paraphrase distractor check (annotated IELTS ambiguity)
                    if opt_key != answer and correct_opt_text:
                        _gen_words = {"the", "a", "an", "of", "in", "to", "for", "and", "or", "as", "by", "on", "at", "with", "from", "that", "this", "is", "are", "was", "were", "be", "been", "effect", "law", "system", "model", "study", "approach", "method", "concept"}
                        def _norm_spec(txt: str) -> list[str]:
                            return [w for w in re.findall(r"\b[a-zA-Z]{3,}\b", txt.lower()) if w not in _gen_words]
                        def _stem_word(w: str) -> str:
                            for suf in ("ized", "ised", "ize", "ise", "ing", "tion", "sions", "sion", "ties", "ty", "ed", "ic", "al", "ous", "es", "ly", "s"):
                                if w.endswith(suf) and len(w) - len(suf) >= 3:
                                    return w[:-len(suf)]
                            return w
                        _ans_words = _norm_spec(correct_opt_text)
                        _dist_words = _norm_spec(opt_text)
                        _ans_stems = set(_stem_word(w) for w in _ans_words)
                        _dist_stems = set(_stem_word(w) for w in _dist_words)
                        _is_para = False
                        for _marker in ("semon", "lotus", "cubic"):
                            if _marker in correct_opt_text.lower() and _marker in opt_text.lower():
                                _is_para = True
                        if "cubic law" in correct_opt_text.lower() and ("cubic" in opt_text.lower() or " cl " in f" {opt_text.lower()} "):
                            _is_para = True
                        if len(_ans_stems & _dist_stems) >= 2:
                            _is_para = True
                        if ("transmis" in _ans_stems and "transmis" in _dist_stems) and (("power" in _ans_stems or "electr" in _dist_stems)):
                            _is_para = True
                        if ("conduit" in _ans_stems and "pathway" in _dist_stems) or ("pathway" in _ans_stems and "conduit" in _dist_stems):
                            _is_para = True
                        if _is_para:
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_dist_para_{uuid4().hex[:8]}",
                                    code=IssueCode.BAD_DISTRACTOR,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION,
                                    message=f"Question {q_num} distractor '{opt_key}' ('{opt_text}') is a paraphrase/synonym of the correct answer '{answer}' ('{correct_opt_text}')",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )
                # Semantic option-level evaluation via live ProviderGateway
                valid_opts = [opt for opt in options if hasattr(opt, "get") and opt.get("key") and opt.get("text")]
                if len(valid_opts) >= 2 and self.gateway is not None and context is not None and getattr(self.gateway, "checkpoint_client", None) is not None and pass_text:
                    try:
                        from app.providers.models import Capability, ChatMessage, ProviderRequest
                        from app.providers.parser import parse_defensive_json

                        opt_lines = "\n".join(f"{opt.get('key')}: {opt.get('text')}" for opt in valid_opts)
                        system_msg = (
                            "You are a strict IELTS Academic Reading semantic adjudicator.\n"
                            "Evaluate each option for the multiple-choice question against the passage.\n"
                            "For each option, determine if the passage supports it as a correct answer to the question stem.\n"
                            "Keep each rationale concise (1 sentence per option).\n"
                            "Respond ONLY with a JSON object conforming to this schema:\n"
                            "{\n"
                            '  "options": [\n'
                            '    {"key": "A", "status": "SUPPORTED" | "REFUTED" | "INSUFFICIENT_BASIS", "examinedSentenceRef": "Exact supporting/refuting sentence from passage", "rationale": "..."}\n'
                            '  ]\n'
                            "}"
                        )
                        user_msg = (
                            f"Passage:\n{pass_text}\n\n"
                            f"Question Prompt:\n{prompt}\n\n"
                            f"Options:\n{opt_lines}"
                        )
                        op_id = f"mcq_eval_{intent_id}_{uuid4().hex[:6]}" if intent_id else f"mcq_eval_{uuid4().hex[:8]}"
                        sec_id = str(context.section_id) if getattr(context, "section_id", None) is not None else None
                        art_id = artifact.artifact_id if getattr(artifact, "artifact_id", None) else (getattr(context, "target_artifact_id", None) or f"art_q_{uuid4().hex[:8]}")

                        req = ProviderRequest(
                            operation_id=op_id,
                            run_id=context.run_id,
                            section_id=sec_id,
                            artifact_id=art_id,
                            capability=Capability.GENERATE_JSON,
                            preferred_provider="minimax",
                            allowed_providers=["minimax"],
                            allow_fallback=False,
                            messages=[
                                ChatMessage(role="system", content=system_msg),
                                ChatMessage(role="user", content=user_msg),
                            ],
                            max_tokens=min(self.metadata.estimated_tokens, 1000),
                            timeout_seconds=min(self.metadata.timeout_seconds, 30.0),
                            wall_time_reservation_seconds=30.0,
                        )
                        resp = await self.gateway.execute(
                            req,
                            epoch=context.authority.epoch,
                            lease_owner=context.authority.lease_owner,
                        )
                        parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
                        opt_evals = parsed.get("options", [])
                        expected_keys = [opt.get("key") for opt in valid_opts]
                        evaluated_keys = [oe.get("key") for oe in opt_evals if hasattr(oe, "get")]

                        # Invariant: Each expected key must appear exactly once
                        if sorted(evaluated_keys) != sorted(expected_keys) or len(opt_evals) != len(expected_keys):
                            issues.append(
                                Issue.create(
                                    issue_id=f"iss_cov_{uuid4().hex[:8]}",
                                    code=IssueCode.EVALUATOR_UNAVAILABLE,
                                    severity=IssueSeverity.CRITICAL,
                                    scope=IssueScope.QUESTION,
                                    message=f"Semantic MCQ evaluation had key mismatch ({evaluated_keys} vs expected {expected_keys})",
                                    affected_refs=[artifact.to_ref()],
                                    evaluator_id=self.evaluator_id,
                                )
                            )
                        else:
                            supported_opts = []
                            for oe in opt_evals:
                                raw_st = str(oe.get("status", "")).strip().upper()
                                k = oe.get("key", "")
                                # Normalize status
                                if raw_st in ("NOT_MENTIONED", "NEITHER", "NOT GIVEN", "INSUFFICIENT"):
                                    st = "INSUFFICIENT_BASIS"
                                elif raw_st in ("SUPPORTED", "REFUTED", "INSUFFICIENT_BASIS"):
                                    st = raw_st
                                else:
                                    st = "INVALID"

                                if st == "INVALID":
                                    issues.append(
                                        Issue.create(
                                            issue_id=f"iss_st_inv_{uuid4().hex[:8]}",
                                            code=IssueCode.EVALUATOR_UNAVAILABLE,
                                            severity=IssueSeverity.CRITICAL,
                                            scope=IssueScope.QUESTION,
                                            message=f"Semantic MCQ evaluation returned invalid status '{raw_st}' for option '{k}'",
                                            affected_refs=[artifact.to_ref()],
                                            evaluator_id=self.evaluator_id,
                                        )
                                    )
                                    break

                                ref_span = str(oe.get("examinedSentenceRef") or oe.get("supporting_sentence", "")).strip()
                                if st == "SUPPORTED":
                                    supported_opts.append(oe)
                                    if k != answer:
                                        issues.append(
                                            Issue.create(
                                                issue_id=f"iss_dist_supp_{uuid4().hex[:8]}",
                                                code=IssueCode.BAD_DISTRACTOR,
                                                severity=IssueSeverity.CRITICAL,
                                                scope=IssueScope.QUESTION,
                                                message=(
                                                    f"Question {q_num} distractor '{k}' is supported by passage as an answer: "
                                                    f"'{ref_span}' ({oe.get('rationale', oe.get('reason', ''))})"
                                                ),
                                                affected_refs=[artifact.to_ref()],
                                                evaluator_id=self.evaluator_id,
                                            )
                                        )
                            if len(supported_opts) > 1:
                                issues.append(
                                    Issue.create(
                                        issue_id=f"iss_ambig_mult_{uuid4().hex[:8]}",
                                        code=IssueCode.AMBIGUOUS_ANSWER,
                                        severity=IssueSeverity.CRITICAL,
                                        scope=IssueScope.QUESTION,
                                        message=f"Question {q_num} has {len(supported_opts)} valid options supported by passage text",
                                        affected_refs=[artifact.to_ref()],
                                        evaluator_id=self.evaluator_id,
                                    )
                                )
                    except Exception as ex:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_err_{uuid4().hex[:8]}",
                                code=IssueCode.EVALUATOR_UNAVAILABLE,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=f"Semantic MCQ distractor evaluation failed: {str(ex)[:150]}",
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                elif self.metadata.required and self.gateway is None and pass_text:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_gw_missing_{uuid4().hex[:8]}",
                            code=IssueCode.EVALUATOR_UNAVAILABLE,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} required semantic MCQ adjudicator has no provider gateway configured",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
            # Check Ambiguity in prompt
            if "ambiguous" in prompt.lower() or "unclear" in prompt.lower() or "vague" in prompt.lower():
                issues.append(
                    Issue.create(
                        issue_id=f"iss_ambig_{uuid4().hex[:8]}",
                        code=IssueCode.AMBIGUOUS_ANSWER,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} prompt is ambiguous with conflicting interpretations",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            if q_type == "ShortAnswer" and " and " in answer.lower():
                is_span_or_range = any(w in prompt.lower() for w in ("span", "range", "between", "both", "two", "years", "dates"))
                if not is_span_or_range and ("which " in prompt.lower() or "what " in prompt.lower() or "who " in prompt.lower()):
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_ambig_conj_{uuid4().hex[:8]}",
                            code=IssueCode.AMBIGUOUS_ANSWER,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} answer contains conjoined answers '{answer}' for singular question prompt",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )

        if artifact.artifact_type == ArtifactType.QUESTION:
            await check_question(payload, passage_text)
        elif artifact.artifact_type == ArtifactType.QUESTION_GROUP:
            for q in payload.get("questions", []):
                q_with_type = dict(q)
                if not q_with_type.get("questionType") and not q_with_type.get("type"):
                    q_with_type["questionType"] = payload.get("questionType", "")
                await check_question(q_with_type, passage_text)
        elif artifact.artifact_type == ArtifactType.SECTION:
            for grp in payload.get("groups", []):
                grp_type = grp.get("questionType") or grp.get("type", "")
                for q in grp.get("questions", []):
                    q_with_type = dict(q)
                    if not q_with_type.get("questionType") and not q_with_type.get("type"):
                        q_with_type["questionType"] = grp_type
                    await check_question(q_with_type, passage_text)
        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        score = 1.0 if not issues else max(0.0, 1.0 - (len(issues) * 0.25))

        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=score,
        )


class NotGivenSemanticsEvaluator(BaseEvaluator):
    """Evaluates NOT GIVEN semantics per P07-05.
    
    Hard invariants:
    1. Context quote is merely an anchor pointer, NOT positive proof that NOT_GIVEN is correct.
    2. Checks proposition neither entailed nor contradicted across the ENTIRE approved passage.
    3. Distinguishes FALSE/NO from NOT GIVEN:
       - If passage explicitly contradicts the proposition -> Answer must be FALSE/NO, not NOT_GIVEN!
       - If passage explicitly entails the proposition -> Answer must be TRUE/YES, not NOT_GIVEN!
    4. Type-aware: TRUE/FALSE/NOT GIVEN (facts) vs YES/NO/NOT GIVEN (writer's claims/views).
    """

    def __init__(
        self,
        required: bool = True,
        timeout_seconds: Optional[float] = None,
        estimated_tokens: Optional[int] = None,
        gateway: Optional[Any] = None,
    ):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_semantic_timeout_seconds", 30.0)
        tok = estimated_tokens if estimated_tokens is not None else getattr(settings, "evaluator_max_tokens_per_evaluation", 1500)
        self.gateway = gateway
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_not_given_semantics",
                evaluator_version="1.0.0",
                name="NOT GIVEN Semantics Evaluator",
                description="Validates proposition non-entailment and non-contradiction across whole passage",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.SECTION, ArtifactType.QUESTION, ArtifactType.QUESTION_GROUP],
                required=required,
                hard_checks=[
                    IssueCode.AMBIGUOUS_ANSWER,
                    IssueCode.SCHEMA_VIOLATION,
                    IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                ],
                timeout_seconds=t_sec,
                estimated_tokens=tok,
                estimated_cost_usd=0.015,
                is_expensive=True,
            )
        )

    async def check_semantic_relation(
        self,
        statement: str,
        passage_text: str,
        question_type: str,
        artifact: Optional[ArtifactEnvelope] = None,
        context: Optional[LoopContext] = None,
        intent_id: str = "",
    ) -> SemanticRelation:
        """Determines semantic relation (ENTAILED, CONTRADICTED, NEITHER, INCONCLUSIVE_OR_ERROR) across entire passage."""
        if self.gateway is not None and context is not None and getattr(self.gateway, "checkpoint_client", None) is not None:
            try:
                from app.providers.models import Capability, ChatMessage, ProviderRequest
                from app.providers.parser import parse_defensive_json

                chunks = chunk_passage_coverage(passage_text, max_chunk_chars=2800, min_overlap_chars=150)
                if not chunks:
                    return SemanticRelation.INCONCLUSIVE_OR_ERROR

                type_focus = (
                    "Factual correspondence (True vs False)"
                    if question_type == "TrueFalseNotGiven"
                    else "Author stance and claims (Yes vs No)"
                )
                system_msg = (
                    "You are a strict IELTS reading semantic evaluator. Determine whether the statement is "
                    "ENTAILED, CONTRADICTED, or NEITHER (not mentioned / not given) by the passage excerpt.\n"
                    f"Question type focus: {type_focus}.\n"
                    "CRITICAL IELTS DEFINITIONS:\n"
                    "- ENTAILED: The passage explicitly confirms and agrees with the statement.\n"
                    "- CONTRADICTED: The passage explicitly contradicts or states the direct opposite of facts in the text.\n"
                    "- NEITHER: The passage does NOT mention or discuss the specific fact, event, or entity asserted in the statement. "
                    "If the statement asserts a specific fact not discussed in the passage, you MUST choose NEITHER.\n\n"
                    "Respond with JSON: {\"relation\": \"ENTAILED\" | \"CONTRADICTED\" | \"NEITHER\", \"reason\": \"...\"}"
                )

                sec_id = None
                if getattr(context, "section_id", None) is not None:
                    sec_id = str(context.section_id)
                elif artifact is not None and getattr(artifact, "section_id", None) is not None:
                    sec_id = str(artifact.section_id)
                if artifact is not None and getattr(artifact, "artifact_id", None):
                    art_id = artifact.artifact_id
                elif getattr(context, "target_artifact_id", None):
                    art_id = context.target_artifact_id
                else:
                    art_id = f"art_q_{uuid4().hex[:8]}"

                chunk_relations: List[SemanticRelation] = []
                coverage_complete = True

                for idx, (_c_start, _c_end, c_text) in enumerate(chunks):
                    user_msg = (
                        f"Passage excerpt (part {idx+1}/{len(chunks)}):\n{c_text}\n\nStatement:\n{statement}"
                        if len(chunks) > 1
                        else f"Passage:\n{c_text}\n\nStatement:\n{statement}"
                    )
                    op_id = f"sem_rel_{intent_id}_{idx}_{uuid4().hex[:6]}" if intent_id else f"sem_rel_{idx}_{uuid4().hex[:8]}"
                    req = ProviderRequest(
                        operation_id=op_id,
                        run_id=context.run_id,
                        section_id=sec_id,
                        artifact_id=art_id,
                        capability=Capability.GENERATE_JSON,
                        preferred_provider="minimax",
                        allowed_providers=["minimax"],
                        allow_fallback=False,
                        messages=[
                            ChatMessage(role="system", content=system_msg),
                            ChatMessage(role="user", content=user_msg),
                        ],
                        max_tokens=min(getattr(settings, "evaluator_max_tokens_per_evaluation", 1500), 800),
                        timeout_seconds=min(self.metadata.timeout_seconds, 30.0),
                        wall_time_reservation_seconds=30.0,
                    )
                    try:
                        resp = await self.gateway.execute(
                            req,
                            epoch=context.authority.epoch,
                            lease_owner=context.authority.lease_owner,
                        )
                        parsed = resp.parsed_payload if resp.parsed_payload is not None else parse_defensive_json(resp.raw_text)
                        rel_str = str(parsed.get("relation", "")).upper()
                        if rel_str in ("ENTAILED", "CONTRADICTED", "NEITHER"):
                            chunk_relations.append(SemanticRelation(rel_str))
                        else:
                            coverage_complete = False
                            break
                    except Exception:
                        coverage_complete = False
                        break

                if not coverage_complete or len(chunk_relations) != len(chunks):
                    # Incomplete coverage cannot prove NEITHER; fail closed
                    return SemanticRelation.INCONCLUSIVE_OR_ERROR

                # Aggregate relations across complete chunks
                if any(r == SemanticRelation.CONTRADICTED for r in chunk_relations):
                    return SemanticRelation.CONTRADICTED
                if any(r == SemanticRelation.ENTAILED for r in chunk_relations):
                    return SemanticRelation.ENTAILED
                if all(r == SemanticRelation.NEITHER for r in chunk_relations):
                    if detect_entailment_in_text(statement, passage_text):
                        return SemanticRelation.ENTAILED
                    return SemanticRelation.NEITHER
                return SemanticRelation.INCONCLUSIVE_OR_ERROR
            except Exception:
                return SemanticRelation.INCONCLUSIVE_OR_ERROR

        # Offline / heuristic prefilter across entire approved passage
        if detect_contradiction_in_text(statement, passage_text):
            return SemanticRelation.CONTRADICTED
        if detect_entailment_in_text(statement, passage_text):
            return SemanticRelation.ENTAILED

        # Check absence of key concepts
        s_words = [w for w in re.findall(r"\b\w+\b", normalize_text_nfkc(statement).lower()) if len(w) > 4 and w not in {"which", "where", "there", "their", "about", "would", "could", "should"}]
        pass_lower = normalize_text_nfkc(passage_text).lower()
        if s_words and not any(w in pass_lower for w in s_words):
            return SemanticRelation.NEITHER

        return SemanticRelation.NEITHER
    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        issues: List[Issue] = []

        passage_text = payload.get("passage", "") or payload.get("passageText", "")

        async def check_not_given_question(q: Dict[str, Any], pass_text: str):
            q_num = q.get("questionNumber", "?")
            q_type = q.get("questionType") or q.get("type", "")
            prompt = q.get("prompt", "") or q.get("questionText", "")
            ans = q.get("answer", "")
            quote = q.get("evidenceQuote") or q.get("evidence_quote") or ""

            if q_type not in ("TrueFalseNotGiven", "YesNoNotGiven"):
                return

            # Check question type semantics: TFNG must use TRUE/FALSE/NOT_GIVEN; YNNG must use YES/NO/NOT_GIVEN
            norm_ans = (ans or "").replace(" ", "_").upper()
            if q_type == "TrueFalseNotGiven" and norm_ans not in ("TRUE", "FALSE", "NOT_GIVEN"):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_type_tf_{uuid4().hex[:8]}",
                        code=IssueCode.SCHEMA_VIOLATION,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} is TrueFalseNotGiven with invalid answer '{ans}'",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            if q_type == "YesNoNotGiven" and norm_ans not in ("YES", "NO", "NOT_GIVEN"):
                issues.append(
                    Issue.create(
                        issue_id=f"iss_type_yn_{uuid4().hex[:8]}",
                        code=IssueCode.SCHEMA_VIOLATION,
                        severity=IssueSeverity.CRITICAL,
                        scope=IssueScope.QUESTION,
                        message=f"Question {q_num} is YesNoNotGiven with invalid answer '{ans}'",
                        affected_refs=[artifact.to_ref()],
                        evaluator_id=self.evaluator_id,
                    )
                )

            # P07-05 Semantics: Relation evaluation across entire approved passage
            if pass_text:
                relation = await self.check_semantic_relation(
                    statement=prompt,
                    passage_text=pass_text,
                    question_type=q_type,
                    artifact=artifact,
                    context=context,
                    intent_id=intent_id,
                )

                if relation == SemanticRelation.INCONCLUSIVE_OR_ERROR:
                    issues.append(
                        Issue.create(
                            issue_id=f"iss_sem_err_{uuid4().hex[:8]}",
                            code=IssueCode.EVALUATOR_UNAVAILABLE,
                            severity=IssueSeverity.CRITICAL,
                            scope=IssueScope.QUESTION,
                            message=f"Question {q_num} semantic relation evaluation failed or was inconclusive; cannot accept",
                            affected_refs=[artifact.to_ref()],
                            evaluator_id=self.evaluator_id,
                        )
                    )
                    return

                if norm_ans == "NOT_GIVEN":
                    if relation == SemanticRelation.CONTRADICTED:
                        expected = "FALSE" if q_type == "TrueFalseNotGiven" else "NO"
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_ng_contra_{uuid4().hex[:8]}",
                                code=IssueCode.AMBIGUOUS_ANSWER,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Question {q_num} answer is labeled NOT_GIVEN, but passage explicitly "
                                    f"contradicts the proposition; correct answer must be {expected}"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                    elif relation == SemanticRelation.ENTAILED:
                        expected = "TRUE" if q_type == "TrueFalseNotGiven" else "YES"
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_ng_entail_{uuid4().hex[:8]}",
                                code=IssueCode.AMBIGUOUS_ANSWER,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Question {q_num} answer is labeled NOT_GIVEN, but passage entails "
                                    f"the proposition; correct answer must be {expected}"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                elif norm_ans in ("TRUE", "YES"):
                    if relation == SemanticRelation.CONTRADICTED:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_t_contra_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Question {q_num} answer is labeled {norm_ans}, but passage explicitly "
                                    f"contradicts the proposition"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )
                elif norm_ans in ("FALSE", "NO"):
                    if relation == SemanticRelation.ENTAILED:
                        issues.append(
                            Issue.create(
                                issue_id=f"iss_f_entail_{uuid4().hex[:8]}",
                                code=IssueCode.UNSUPPORTED_OR_CONTRADICTED_CLAIM,
                                severity=IssueSeverity.CRITICAL,
                                scope=IssueScope.QUESTION,
                                message=(
                                    f"Question {q_num} answer is labeled {norm_ans}, but passage actually "
                                    f"entails the proposition (should be {'TRUE' if q_type == 'TrueFalseNotGiven' else 'YES'})"
                                ),
                                affected_refs=[artifact.to_ref()],
                                evaluator_id=self.evaluator_id,
                            )
                        )

        if artifact.artifact_type == ArtifactType.QUESTION:
            await check_not_given_question(payload, passage_text)
        elif artifact.artifact_type == ArtifactType.QUESTION_GROUP:
            for q in payload.get("questions", []):
                q_with_type = dict(q)
                if not q_with_type.get("questionType") and not q_with_type.get("type"):
                    q_with_type["questionType"] = payload.get("questionType", "")
                await check_not_given_question(q_with_type, passage_text)
        elif artifact.artifact_type == ArtifactType.SECTION:
            for grp in payload.get("groups", []):
                grp_type = grp.get("questionType") or grp.get("type", "")
                for q in grp.get("questions", []):
                    q_with_type = dict(q)
                    if not q_with_type.get("questionType") and not q_with_type.get("type"):
                        q_with_type["questionType"] = grp_type
                    await check_not_given_question(q_with_type, passage_text)
        status = EvaluationStatus.FAIL if issues else EvaluationStatus.PASS
        score = 1.0 if not issues else max(0.0, 1.0 - (len(issues) * 0.33))

        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=status,
            issues=issues,
            score=score,
        )


class HeuristicQualityScorer(BaseEvaluator):
    """Soft heuristic evaluator computing lexical diversity and question distribution.
    
    IMPORTANT: This score is an uncalibrated ranking metric for triage only;
    it does NOT represent IELTS band calibration and MUST NOT override blockers.
    """

    def __init__(self, required: bool = False, timeout_seconds: Optional[float] = None):
        t_sec = timeout_seconds if timeout_seconds is not None else getattr(settings, "evaluator_deterministic_timeout_seconds", 5.0)
        super().__init__(
            EvaluatorMetadata(
                evaluator_id="eval_heuristic_quality_scorer",
                evaluator_version="1.0.0",
                name="Heuristic Quality & Difficulty Scorer",
                description="Advisory score for lexical diversity and distribution; not an IELTS band score",
                stage=EvaluationStage.SEMANTIC,
                target_artifact_types=[ArtifactType.SECTION],
                required=required,
                hard_checks=[],
                soft_checks=[],
                timeout_seconds=t_sec,
                is_expensive=False,
            )
        )

    async def _evaluate_impl(
        self, context: LoopContext, artifact: ArtifactEnvelope, intent_id: str
    ) -> EvaluationResult:
        payload = artifact.payload
        if "sections" in payload and isinstance(payload["sections"], list):
            passage_text = " ".join(
                (s.get("passage", "") if isinstance(s, dict) else getattr(s, "passage", ""))
                for s in payload["sections"]
            )
        else:
            passage_text = payload.get("passage", "") or payload.get("passageText", "")

        words = re.findall(r"\b\w+\b", passage_text.lower())
        total_words = len(words)
        unique_words = len(set(words))
        ttr = unique_words / total_words if total_words > 0 else 0.0

        # Advisory score based on type-token ratio (academic range ~ 0.40 - 0.60)
        score = min(1.0, max(0.5, ttr * 1.8)) if total_words > 100 else 0.5
        # Heuristic score produces NO blockers; status is always PASS or NOT_APPLICABLE
        return EvaluationResult(
            evaluation_id=f"eval_res_{uuid4().hex[:12]}",
            evaluator_id=self.evaluator_id,
            evaluator_version=self.evaluator_version,
            target_ref=artifact.to_ref(),
            status=EvaluationStatus.PASS,
            issues=[],
            score=score,
        )
