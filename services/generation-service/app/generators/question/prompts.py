"""Prompt Families and Templates for Six-Type Question Generation (Phase 09 / P09-01).

Implements versioned prompt assets for all 6 canonical IELTS Academic Reading question types:
1. TrueFalseNotGiven (TFNG)
2. YesNoNotGiven (YNNG)
3. SentenceCompletion (SC)
4. SummaryCompletion (SMC)
5. MultipleChoiceSingle (MCQ)
6. ShortAnswer (SA)

Includes:
- Versioned prompt IDs, hashes, and schemas.
- Untrusted passage/evidence data envelopes.
- Explicit constraints (exact verbatim quote, <= 3 words, 4 options A-D).
- No leakage of holdout evaluation samples.
"""

from __future__ import annotations

from enum import Enum
import hashlib
import json
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field

QUESTION_PROMPT_VERSION = "2.0.0"


class QuestionPromptFamily(str, Enum):
    TRUE_FALSE_NOT_GIVEN = "TrueFalseNotGiven"
    YES_NO_NOT_GIVEN = "YesNoNotGiven"
    SENTENCE_COMPLETION = "SentenceCompletion"
    SUMMARY_COMPLETION = "SummaryCompletion"
    MULTIPLE_CHOICE_SINGLE = "MultipleChoiceSingle"
    SHORT_ANSWER = "ShortAnswer"

    @classmethod
    def from_raw(cls, val: Any) -> "QuestionPromptFamily":
        if isinstance(val, QuestionPromptFamily):
            return val
        s = str(getattr(val, "value", val)).strip().replace("_", "").lower()
        for member in cls:
            if member.value.lower() == s or member.name.replace("_", "").lower() == s:
                return member
        return cls.TRUE_FALSE_NOT_GIVEN

# ── System Instructions per Family ──────────────────────────────────────────

SYSTEM_PROMPTS: Dict[QuestionPromptFamily, str] = {
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate True/False/Not Given questions strictly based on the provided passage.\n"
        "RULES:\n"
        "- TRUE: The statement agrees with the information in the passage.\n"
        "- FALSE: The statement contradicts the information in the passage.\n"
        "- NOT GIVEN: There is no information on this in the passage.\n"
        "- Provide a verbatim evidence quote for TRUE and FALSE questions.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.YES_NO_NOT_GIVEN: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Yes/No/Not Given questions focusing on the author's claims, opinions, or stance.\n"
        "RULES:\n"
        "- YES: The statement agrees with the claims or opinions of the writer.\n"
        "- NO: The statement contradicts the claims or opinions of the writer.\n"
        "- NOT GIVEN: It is impossible to say what the writer thinks about this.\n"
        "- Provide a verbatim evidence quote for YES and NO questions.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.SENTENCE_COMPLETION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Sentence Completion questions based on the provided passage.\n"
        "RULES:\n"
        "- The answer must be strictly ONE, TWO, OR THREE WORDS (1-3 words maximum, NEVER 4+ words) and/or a NUMBER taken directly from the passage.\n"
        "- The sentence stem must contain exactly one blank indicator: '______'.\n"
        "- The answer must be a verbatim substring of the passage.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.SUMMARY_COMPLETION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate a coherent Summary Completion group based on a section of the provided passage.\n"
        "RULES:\n"
        "- The summary must be a coherent, grammatically connected paragraph.\n"
        "- Each blank must be marked with a numbered placeholder: '[1]', '[2]', etc.\n"
        "- Answers must be strictly ONE, TWO, OR THREE WORDS (1-3 words maximum, NEVER 4+ words) copied character-for-character as a contiguous verbatim span from the passage.\n"
        "- NEVER include parenthetical abbreviations (e.g. write 'alpha-synuclein', not 'alpha-synuclein (a-syn)') or multi-part coordinates in a blank answer.\n"
        "- Every blank in the group MUST have a distinct answer.\n"
        "- ANTI-LEAKAGE INVARIANT: The answer for ANY blank must NEVER appear anywhere in the summaryText outside of its numbered placeholder! The summary must never reveal or repeat any of the missing answers.\n"
        "- Every blank MUST include an exact verbatim sentence from the passage in evidenceQuote.\n"
        "- Blanks must be ordered monotonically and follow the flow of the passage.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Multiple Choice questions (single correct answer) based on the provided passage.\n"
        "RULES:\n"
        "- Provide exactly four options with keys 'A', 'B', 'C', 'D'.\n"
        "- Exactly one option must be the correct answer grounded in the passage.\n"
        "- Distractors must be plausible based on passage themes but clearly incorrect or unsupported.\n"
        "- Distractors must not be identical or duplicate each other.\n"
        "- Output strictly valid JSON without trailing commas before closing brackets or braces."
    ),
    QuestionPromptFamily.SHORT_ANSWER: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Short Answer questions based on the provided passage.\n"
        "RULES:\n"
        "- Questions must begin with a clear interrogative (What, Which, Where, When, How, etc.).\n"
        "- The answer must be NO MORE THAN THREE WORDS and/or a NUMBER verbatim from the passage.\n"
        "- Do not produce conjoined answers ('X and Y') for singular questions.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
}


def compute_prompt_hash(family: QuestionPromptFamily, template: str) -> str:
    content = f"{family.value}:{QUESTION_PROMPT_VERSION}:{template}"
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


PROMPT_TEMPLATES: Dict[QuestionPromptFamily, str] = {
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} distinct True/False/Not Given question candidates with diverse answers (include TRUE, FALSE, and NOT GIVEN across the candidates).\n"
        "Target slot: question #{question_number}. Target distinct factual evidence across different paragraphs for question #{question_number}.\n\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "...",\n'
        '      "answer": "TRUE" | "FALSE" | "NOT GIVEN",\n'
        '      "evidenceQuote": "verbatim passage quote",\n'
        '      "explanation": "..."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.YES_NO_NOT_GIVEN: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} distinct Yes/No/Not Given question candidates with diverse answers (include YES, NO, and NOT GIVEN across the candidates).\n"
        "Target slot: question #{question_number}.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "...",\n'
        '      "answer": "YES" | "NO" | "NOT GIVEN",\n'
        '      "evidenceQuote": "verbatim passage quote",\n'
        '      "explanation": "..."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.SENTENCE_COMPLETION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} distinct Sentence Completion candidates for question #{question_number}.\n"
        "Instruction: Complete the sentence using NO MORE THAN THREE WORDS (1 to 3 words only) from the passage.\n"
        "RULES:\n"
        "- The target answer MUST be strictly 1, 2, or 3 words (NEVER 4 or more words) taken VERBATIM from the passage.\n"
        "- Write original sentences summarizing specific distinct facts from the passage with a single '______' blank.\n"
        "- Do NOT reuse generic introductory phrases (e.g. 'The researchers observed that ______'). Write authentic, diverse grammatical structures.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "<Original grammatical sentence testing a key passage fact with a \'______\' blank>",\n'
        '      "answer": "verbatim text (1 to 3 words only)",\n'
        '      "evidenceQuote": "verbatim context quote",\n'
        '      "wordCount": 1-3\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.SUMMARY_COMPLETION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate a coherent Summary Completion group variant with {blank_count} blanks starting at question #{start_number}.\n"
        "RULES:\n"
        "- Write a single coherent summary paragraph testing distinct facts across {blank_count} numbered blanks: [1], [2], ..., [{blank_count}].\n"
        "- Each answer MUST be 1, 2, or 3 words maximum (NEVER 4+ words, NEVER skip words or parentheticals from the passage span; pick a clean 1-2 word verbatim noun phrase).\n"
        "- All {blank_count} blank answers MUST be mutually distinct.\n"
        "- ANTI-LEAKAGE: DO NOT include any of the {blank_count} answer strings anywhere else in the summaryText outside the placeholders. Paraphrase surrounding context so no answer word is repeated in summaryText.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "summaryTitle": "...",\n'
        '  "summaryText": "Paragraph with [1], [2], ..., [{blank_count}]...",\n'
        '  "blanks": [\n'
        "    {{\n"
        '      "number": {start_number},\n'
        '      "placeholder": "[1]",\n'
        '      "answer": "verbatim answer (1-3 words only)",\n'
        '      "evidenceQuote": "exact verbatim passage sentence"\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Multiple Choice question candidates (4 options each: A, B, C, D).\n"
        "Target slot: question #{question_number}.\n\n"
        "Output strictly valid JSON (ensure NO trailing commas):\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "...",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "..."}},\n'
        '        {{"key": "B", "text": "..."}},\n'
        '        {{"key": "C", "text": "..."}},\n'
        '        {{"key": "D", "text": "..."}}\n'
        "      ],\n"
        '      "answer": "A",\n'
        '      "evidenceQuote": "verbatim passage quote",\n'
        '      "explanation": "Brief explanation of why option A is correct."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.SHORT_ANSWER: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Short Answer question candidates.\n"
        "Target slot: question #{question_number}.\n"
        "Instruction: Answer using NO MORE THAN THREE WORDS from the passage.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "What did scientists find in the sediment layers?",\n'
        '      "answer": "verbatim answer (<= 3 words)",\n'
        '      "evidenceQuote": "verbatim sentence",\n'
        '      "wordCount": 1-3\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
}

PROMPT_HASHES: Dict[QuestionPromptFamily, str] = {
    f: compute_prompt_hash(f, PROMPT_TEMPLATES[f]) for f in QuestionPromptFamily
}


def build_question_prompt(
    family: QuestionPromptFamily,
    passage_text: str,
    question_number: int,
    candidate_count: int = 3,
    blank_count: int = 4,
    target_focus: Optional[str] = None,
) -> Dict[str, str]:
    """Builds sanitized prompt data payload for the requested question family."""
    # Sanitize passage text to avoid envelope injection
    sanitized_passage = passage_text.replace("</passage_material>", "&lt;/passage_material&gt;")
    template = PROMPT_TEMPLATES[family]
    user_prompt = template.format(
        passage_text=sanitized_passage,
        question_number=question_number,
        candidate_count=candidate_count,
        blank_count=blank_count,
        start_number=question_number,
    )
    if target_focus and target_focus.strip():
        user_prompt += f"\n\nFOCUS PARAGRAPH FOR QUESTION #{question_number}:\n\"\"\"\n{target_focus.strip()}\n\"\"\"\nFocus candidate questions on facts and details from this paragraph section to ensure broad coverage across the passage."
    return {
        "prompt_id": f"prompt_{family.value.lower()}_{QUESTION_PROMPT_VERSION}",
        "prompt_version": QUESTION_PROMPT_VERSION,
        "prompt_hash": PROMPT_HASHES[family],
        "system_instruction": SYSTEM_PROMPTS[family],
        "user_prompt": user_prompt,
    }
