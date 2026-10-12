"""Versioned Prompts, Schemas, Asset Tracking, and Redacted Logging for Solvers (P10-02).

Invariants:
- Versioned prompts with deterministic asset IDs and SHA-256 hashes.
- Untrusted content isolated in secure XML-style envelopes.
- Redacted logging to prevent accidental leakage of canaries, keys, or private metadata.
- Strict JSON output schemas prohibiting hidden chain-of-thought.
"""

from __future__ import annotations

import hashlib
import json
import re
from typing import Any, Dict, List, Optional, Tuple

from app.contracts.solver import (
    AdversaryOutput,
    BlindSolverInput,
    SolverOutput,
)
from app.solvers.serializer import build_secure_envelope


SOLVER_PROMPT_VERSION = "v1.0.0"
ADVERSARY_PROMPT_VERSION = "v1.0.0"

SOLVER_ASSET_ID = f"asset_solver_prompt_{SOLVER_PROMPT_VERSION}"
ADVERSARY_ASSET_ID = f"asset_adversary_prompt_{ADVERSARY_PROMPT_VERSION}"


SOLVER_SYSTEM_PROMPT = """You are an expert, impartial IELTS Academic Reading solver.
Your task is to independently answer the provided student question using ONLY the approved passage provided in the <approved_passage> tags.

STRICT INVARIANTS:
1. Grounding: Answer strictly using facts and stance stated in the passage. Do not use outside knowledge.
2. Citation: You MUST cite at least one exact, verbatim text span from the passage that proves your answer. Spans must match passage text character-for-character with NO modifications, NO ellipsis ('...'), and NEVER copying from the question prompt. For NOT GIVEN, cite an exact sentence from the passage discussing the relevant topic. Every span MUST appear verbatim in <approved_passage>.
3. Justification: Provide a concise justification under 300 characters explaining why the passage confirms the answer. Do NOT generate internal chain-of-thought, scratchpads, or hidden reasoning.
4. Output Format: Respond with a single valid JSON object strictly matching this schema:
{
  "questionNumber": <int>,
  "normalizedAnswer": "<clean answer string: TRUE/FALSE/NOT GIVEN, YES/NO/NOT GIVEN, option letter A-D, or exact completion phrase>",
  "citedSpans": [
    {
      "spanText": "<exact verbatim quote from passage>",
      "startChar": <int or null>,
      "endChar": <int or null>
    }
  ],
  "justification": "<concise justification <= 300 characters>",
  "selfReportedConfidence": <float between 0.0 and 1.0>
}
Do not enclose in markdown blocks other than ```json if necessary. Return pure valid JSON."""


ADVERSARY_SYSTEM_PROMPT = """You are an adversarial IELTS Reading item reviewer.
Your mission is to detect ambiguity, multiple defensible answers, or ungrounded questions in student-visible IELTS test items.

STRICT INVARIANTS:
1. Adversarial Inspection: Determine whether:
   - MULTIPLE_VALID_OPTIONS: More than one option is defensible under fair interpretation of the passage, including when two options are paraphrases or synonymous descriptions of the same passage fact (making more than one option justifiable).
   - INTERPRETATION_SPLIT: The question prompt is split between contradictory passage claims.
   - UNSUPPORTED_KEY: No valid answer can be grounded in the passage.
   - KEY_CONTRADICTED: The intended answer is directly contradicted by the text.
   - VAGUE_PROMPT: The prompt is inherently ambiguous or unclear.
2. Grounding in Passage: Any alleged ambiguity MUST be backed by exact verbatim quotes from the approved passage.
   Allegations based on outside general knowledge or external facts NOT present in the passage must be flagged with "isGroundedInPassage": false.
3. Output Format: Respond with a single valid JSON object strictly matching this schema:
{
  "questionNumber": <int>,
  "isAmbiguous": <boolean>,
  "adversarySummary": "<concise summary of findings>",
  "identifiedAlternatives": [
    {
      "alternativeAnswer": "<alternative plausible answer or option letter>",
      "ambiguityType": "MULTIPLE_VALID_OPTIONS" | "INTERPRETATION_SPLIT" | "UNSUPPORTED_KEY" | "KEY_CONTRADICTED" | "VAGUE_PROMPT",
      "plausibilityScore": <float between 0.0 and 1.0>,
      "citedSpans": [
        {
          "spanText": "<exact verbatim quote from passage>",
          "startChar": <int or null>,
          "endChar": <int or null>
        }
      ],
      "reasoning": "<explanation of alternative>",
      "isGroundedInPassage": <boolean>
    }
  ]
}
Do not enclose in markdown blocks other than ```json if necessary. Return pure valid JSON."""


def get_solver_asset_info() -> Dict[str, str]:
    """Returns versioned asset tracking info for the blind solver prompt."""
    prompt_hash = hashlib.sha256(SOLVER_SYSTEM_PROMPT.encode("utf-8")).hexdigest()
    return {
        "assetId": SOLVER_ASSET_ID,
        "version": SOLVER_PROMPT_VERSION,
        "promptHash": prompt_hash,
    }


def get_adversary_asset_info() -> Dict[str, str]:
    """Returns versioned asset tracking info for the adversary prompt."""
    prompt_hash = hashlib.sha256(ADVERSARY_SYSTEM_PROMPT.encode("utf-8")).hexdigest()
    return {
        "assetId": ADVERSARY_ASSET_ID,
        "version": ADVERSARY_PROMPT_VERSION,
        "promptHash": prompt_hash,
    }


def build_solver_messages(blind_input: BlindSolverInput) -> List[Dict[str, str]]:
    """Builds chat messages for the blind solver using secure envelope serialization."""
    envelope = build_secure_envelope(blind_input.passage_text, blind_input.question)
    user_prompt = f"""Please independently solve the following IELTS Reading item using ONLY the passage enclosed below:

{envelope}

CRITICAL RULES:
1. Every character must be valid JSON with NO trailing quotes on numbers.
2. The <prompt> text is the QUESTION TO ANSWER, NOT the passage! NEVER cite from <prompt>.
3. For NOT GIVEN, you MUST cite an exact sentence from <approved_passage> discussing the general topic.
4. For YesNoNotGiven items, normalizedAnswer MUST be strictly YES, NO, or NOT GIVEN (never TRUE or FALSE). For TrueFalseNotGiven items, normalizedAnswer MUST be strictly TRUE, FALSE, or NOT GIVEN.
5. For MultipleChoiceSingle items, normalizedAnswer MUST be strictly the option letter (A, B, C, or D) matching your chosen option.
6. For completion or short answer items (SentenceCompletion, SummaryCompletion, ShortAnswer), normalizedAnswer MUST be the concise target phrase (maximum 3 words) taken directly from <approved_passage>, not the entire sentence.

Return your solution in the required JSON format."""
    return [
        {"role": "system", "content": SOLVER_SYSTEM_PROMPT},
        {"role": "user", "content": user_prompt},
    ]


def build_adversary_messages(blind_input: BlindSolverInput) -> List[Dict[str, str]]:
    """Builds chat messages for the adversarial verifier using secure envelope serialization."""
    envelope = build_secure_envelope(blind_input.passage_text, blind_input.question)
    user_prompt = f"""Please perform an adversarial review of the following IELTS Reading item to detect ambiguity or alternative answers:

{envelope}

CRITICAL ADVERSARIAL RULES:
1. For Multiple Choice items: carefully check whether ANY two options (e.g. A and B) are paraphrases, synonyms, or both factually supported by the text. If more than one option is defensible from the passage, you MUST set "isAmbiguous": true, "ambiguityType": "MULTIPLE_VALID_OPTIONS", and cite the passage text for the alternative. Only options explicitly listed in the <options> block may be evaluated.
2. For completion or short answer items: do NOT flag minor grammatical variants, determiners, or substrings of the same target entity as MULTIPLE_VALID_OPTIONS if they refer to the exact same passage concept. Flag ambiguity only if genuinely distinct factual answers from the passage can fill the blank.
3. Return ONLY a valid JSON object matching the required schema."""
    return [
        {"role": "system", "content": ADVERSARY_SYSTEM_PROMPT},
        {"role": "user", "content": user_prompt},
    ]


def redact_solver_payload(data: Any) -> Any:
    """Redacts internal keys, canary strings, and secrets for clean log output."""
    if isinstance(data, dict):
        redacted = {}
        for k, v in data.items():
            k_lower = str(k).lower()
            if any(term in k_lower for term in ("key", "secret", "token", "password", "canary", "hidden")):
                redacted[k] = "[REDACTED]"
            else:
                redacted[k] = redact_solver_payload(v)
        return redacted
    elif isinstance(data, list):
        return [redact_solver_payload(item) for item in data]
    elif isinstance(data, str):
        # Redact potential sensitive tokens or long prompt dumps
        if "sk-" in data or "Bearer " in data:
            return re.sub(r"(Bearer\s+|sk-)[A-Za-z0-9_\-]+", r"\1[REDACTED]", data)
        return data
    return data
