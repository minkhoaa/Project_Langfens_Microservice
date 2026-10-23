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
from typing import Any, Dict, List, Optional, Union
from pydantic import BaseModel, Field

from app.contracts.question_type import QuestionPromptFamily

QUESTION_PROMPT_VERSION = "2.0.0"
# ── System Instructions per Family ──────────────────────────────────────────

SYSTEM_PROMPTS: Dict[QuestionPromptFamily, str] = {
    QuestionPromptFamily.TRUE_FALSE_NOT_GIVEN: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate True/False/Not Given questions strictly based on the provided passage.\n"
        "RULES:\n"
        "- TRUE: The statement agrees with the information in the passage.\n"
        "- FALSE: The statement contradicts the information in the passage.\n"
        "- NOT GIVEN: There is no information on this in the passage.\n"
        "- Provide a verbatim evidence quote for TRUE and FALSE questions (or context anchor for NOT GIVEN).\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.YES_NO_NOT_GIVEN: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Yes/No/Not Given questions focusing on the author's claims, opinions, or stance.\n"
        "RULES:\n"
        "- YES: The statement agrees with the claims or opinions of the writer.\n"
        "- NO: The statement contradicts the claims or opinions of the writer.\n"
        "- NOT GIVEN: It is impossible to say what the writer thinks about this.\n"
        "- Provide a verbatim evidence quote for YES and NO questions (or context anchor for NOT GIVEN).\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.SENTENCE_COMPLETION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Sentence Completion questions based on the provided passage.\n"
        "RULES:\n"
        "- The answer must be strictly ONE, TWO, OR THREE WORDS (1-3 words maximum, NEVER 4+ words) and/or a NUMBER taken directly from the passage.\n"
        "- The sentence stem must contain exactly one blank indicator: '______'.\n"
        "- The answer must be a verbatim substring of the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
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
        "- Every blank MUST include a detailed passage-grounded explanation of at least 25 characters.\n"
        "- Blanks must be ordered monotonically and follow the flow of the passage.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Multiple Choice questions (single correct answer) based on the provided passage.\n"
        "RULES:\n"
        "- Provide exactly four options with keys 'A', 'B', 'C', 'D'.\n"
        "- Exactly ONE option must be the indisputably correct answer directly supported by the passage.\n"
        "- The 3 distractors MUST be unequivocally incorrect, clearly contradicted by the passage or completely unsupported.\n"
        "- NEVER create distractors that are partially true, true in a different context/region, or synonymous with the correct option.\n"
        "- The question stem MUST be specific and precise (including relevant geographic, temporal, or taxonomic conditions from the passage) so that ONLY ONE option is true.\n"
        "- Distractors must not be identical or duplicate each other.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Output strictly valid JSON without trailing commas before closing brackets or braces."
    ),
    QuestionPromptFamily.SHORT_ANSWER: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Short Answer questions based on the provided passage.\n"
        "RULES:\n"
        "- Questions must begin with a clear interrogative (What, Which, Where, When, How, etc.).\n"
        "- The answer must be NO MORE THAN THREE WORDS and/or a NUMBER verbatim from the passage.\n"
        "- Do not produce conjoined answers ('X and Y') for singular questions.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.TABLE_COMPLETION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Table Completion questions based on the provided passage.\n"
        "RULES:\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.NOTE_COMPLETION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Note Completion questions based on the provided passage.\n"
        "RULES:\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.FORM_COMPLETION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Form Completion questions based on the provided passage.\n"
        "RULES:\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.DIAGRAM_LABEL: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Diagram Label completion questions based on the provided passage.\n"
        "RULES:\n"
        "- Answer must be strictly 1-3 words verbatim from the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MAP_LABEL: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Map Label completion questions based on the provided passage.\n"
        "RULES:\n"
        "- Answer must be strictly 1-3 words verbatim from the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Multiple Choice questions with multiple correct options based on the provided passage.\n"
        "RULES:\n"
        "- Provide at least 5 options with at least 2 correct answers.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE_IMAGE: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Multiple Choice Single Image questions based on the provided passage.\n"
        "RULES:\n"
        "- Exactly one option must be the correct answer grounded in the passage.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MATCHING_HEADING: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Matching Heading questions based on the provided passage.\n"
        "RULES:\n"
        "- Headings use Roman numerals (i, ii, iii...).\n"
        "- Include at least one unused distractor heading.\n"
        "- Each heading matches at most one paragraph.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MATCHING_INFORMATION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Matching Information questions based on the provided passage.\n"
        "RULES:\n"
        "- Statements match paragraphs A, B, C...\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MATCHING_FEATURES: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Matching Features questions based on the provided passage.\n"
        "RULES:\n"
        "- Match statements to named features, researchers, or categories (A, B, C...).\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.MATCHING_ENDINGS: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Matching Sentence Endings questions based on the provided passage.\n"
        "RULES:\n"
        "- Match sentence beginnings to lettered endings (A, B, C...).\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.CLASSIFICATION: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Classification questions based on the provided passage.\n"
        "RULES:\n"
        "- Classify statements into categories (A, B, C...).\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.FLOW_CHART: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Flow Chart process ordering questions based on the provided passage.\n"
        "RULES:\n"
        "- Provide a sequence of distinct process step descriptions with a blank indicator for the target step.\n"
        "- Answer must be strictly 1-3 words taken verbatim from the passage.\n"
        "- Each step must describe a clear stage in the process.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Summary Completion (with a box of options) based on the provided passage.\n"
        "RULES:\n"
        "- The summary must be a coherent paragraph with blanks.\n"
        "- Provide a pool/box of options (words or phrases) from which answers are chosen.\n"
        "- Distractors in the box must be grammatically plausible but incorrect.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
        "- Respond in valid JSON adhering to the specified schema."
    ),
    QuestionPromptFamily.CHOOSING_TITLE: (
        "You are an expert Cambridge IELTS Academic Reading test writer.\n"
        "Generate Choosing a Title questions testing the main global idea or purpose of the passage.\n"
        "RULES:\n"
        "- Provide 4 title options (A, B, C, D).\n"
        "- Exactly one option captures the overall thesis; others are too narrow, too broad, or contradicted.\n"
        "- Provide an exact verbatim evidence quote from the passage.\n"
        "- Provide a detailed passage-grounded explanation of at least 25 characters for every question candidate.\n"
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
        "RULES:\n"
        "- TRUE: statement agrees with information in the passage.\n"
        "- FALSE: statement contradicts information in the passage.\n"
        "- NOT GIVEN: no information on this in the passage.\n"
        "- evidenceQuote: verbatim passage quote for TRUE/FALSE (or relevant context anchor for NOT GIVEN).\n"
        "- explanation: detailed passage-grounded justification (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Factual statement evaluated against passage facts",\n'
        '      "answer": "TRUE",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) showing why the statement is true, false, or not given."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.YES_NO_NOT_GIVEN: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} distinct Yes/No/Not Given question candidates with diverse answers (include YES, NO, and NOT GIVEN across the candidates).\n"
        "Target slot: question #{question_number}.\n\n"
        "RULES:\n"
        "- YES: statement agrees with author's claim or opinion.\n"
        "- NO: statement contradicts author's claim or opinion.\n"
        "- NOT GIVEN: impossible to say what the author thinks.\n"
        "- evidenceQuote: verbatim passage quote for YES/NO (or context anchor for NOT GIVEN).\n"
        "- explanation: detailed passage-grounded justification (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Statement reflecting or challenging an author claim or opinion",\n'
        '      "answer": "YES",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage reflecting the writer\'s claim",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why the statement agrees with, contradicts, or is not mentioned by the writer."\n'
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
        "- Do NOT reuse generic introductory phrases (e.g. 'The researchers observed that ______'). Write authentic, diverse grammatical structures.\n"
        "- Every candidate MUST include an exact verbatim sentence in evidenceQuote.\n"
        "- Every candidate MUST include a detailed passage-grounded explanation of at least 25 characters.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Original grammatical sentence testing a key passage fact with a \'______\' blank",\n'
        '      "answer": "verbatim text (1 to 3 words only)",\n'
        '      "evidenceQuote": "exact verbatim context quote from the passage",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) explaining how the passage context supports the answer.",\n'
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
        "- ANTI-LEAKAGE: DO NOT include any of the {blank_count} answer strings anywhere else in the summaryText outside the placeholders. Paraphrase surrounding context so no answer word is repeated in summaryText.\n"
        "- Every blank MUST include an exact verbatim sentence from the passage in evidenceQuote.\n"
        "- Every blank MUST include a detailed passage-grounded explanation of at least 25 characters.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "summaryTitle": "Concise summary title",\n'
        '  "summaryText": "Paragraph with [1], [2], ..., [{blank_count}]...",\n'
        '  "blanks": [\n'
        "    {{\n"
        '      "number": {start_number},\n'
        '      "placeholder": "[1]",\n'
        '      "answer": "verbatim answer (1-3 words only)",\n'
        '      "evidenceQuote": "exact verbatim passage sentence containing the answer",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) justifying the answer for this blank."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Multiple Choice question candidates (4 options each: A, B, C, D).\n"
        "Target slot: question #{question_number}.\n"
        "RULES:\n"
        "- Provide exactly four options with keys 'A', 'B', 'C', 'D'.\n"
        "- Exactly ONE option must be correct; 3 distractors must be unequivocally false or unsupported.\n"
        "- Every candidate MUST include an exact verbatim sentence from the passage in evidenceQuote.\n"
        "- Every candidate MUST include a detailed passage-grounded explanation of at least 25 characters.\n\n"
        "Output strictly valid JSON (ensure NO trailing commas):\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Specific question stem testing a key fact from the passage?",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "First option text"}},\n'
        '        {{"key": "B", "text": "Second option text"}},\n'
        '        {{"key": "C", "text": "Third option text"}},\n'
        '        {{"key": "D", "text": "Fourth option text"}}\n'
        "      ],\n"
        '      "answer": "A",\n'
        '      "evidenceQuote": "exact verbatim passage quote supporting option A",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) explaining why option A is correct and others are incorrect."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.SHORT_ANSWER: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Short Answer question candidates.\n"
        "Target slot: question #{question_number}.\n"
        "Instruction: Answer using NO MORE THAN THREE WORDS from the passage.\n"
        "RULES:\n"
        "- Questions must begin with a clear interrogative (What, Which, Where, When, How, etc.).\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Every candidate MUST include an exact verbatim sentence in evidenceQuote.\n"
        "- Every candidate MUST include a detailed passage-grounded explanation of at least 25 characters.\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "What did scientists find in the sediment layers?",\n'
        '      "answer": "verbatim answer (1-3 words)",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage containing the answer",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why this answer directly answers the question.",\n'
        '      "wordCount": 1-3\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.TABLE_COMPLETION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Table Completion candidates for question #{question_number}.\n"
        "RULES:\n"
        "- The prompt must contain a single blank indicator: '______'.\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Every candidate MUST include tableContext, rowHeader, colHeader, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Table row summary statement with blank \'______\'",\n'
        '      "tableContext": "Table title or structural context describing rows and columns",\n'
        '      "rowHeader": "Row category or item",\n'
        '      "colHeader": "Column category or metric",\n'
        '      "answer": "verbatim answer (1-3 words)",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage confirming this cell entry",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) showing where the row/column fact appears in the text."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.NOTE_COMPLETION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Note Completion candidates for question #{question_number}.\n"
        "RULES:\n"
        "- The prompt must contain a single blank indicator: '______'.\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Every candidate MUST include headingContext, bulletPrefix, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Note bullet with blank \'______\'",\n'
        '      "headingContext": "Section heading of the notes",\n'
        '      "bulletPrefix": "Key topic prefix",\n'
        '      "answer": "verbatim answer (1-3 words)",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage supporting the note",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) confirming the note bullet from the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.FORM_COMPLETION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Form Completion candidates for question #{question_number}.\n"
        "RULES:\n"
        "- The prompt must contain a single blank indicator: '______'.\n"
        "- Answer must be strictly 1-3 words and/or a number verbatim from the passage.\n"
        "- Every candidate MUST include fieldLabel, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Form field description with blank \'______\'",\n'
        '      "fieldLabel": "Name of the form field",\n'
        '      "answer": "verbatim answer (1-3 words)",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage containing the form detail",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) confirming the form field value from the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.DIAGRAM_LABEL: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Diagram Label completion candidates for question #{question_number}.\n"
        "RULES FOR DIAGRAM LABELS:\n"
        "- Each question candidate must provide a technical diagram callout layout description, part description, and blank callout number.\n"
        "- Answer must be strictly 1-3 words taken verbatim from the passage.\n"
        "- Every candidate MUST include calloutLabel, partDescription, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Diagram label for part/callout #{question_number} with blank \'______\'",\n'
        '      "calloutLabel": "Part {question_number}",\n'
        '      "partDescription": "Layout description of the component or diagram part",\n'
        '      "answer": "verbatim answer (1-3 words)",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage describing the part",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) identifying this component in the diagram from the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MAP_LABEL: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate {candidate_count} Map Label candidates for question #{question_number}.\n"
        "RULES FOR MAP LABELS:\n"
        "- Each question candidate must provide a map callout description, location description, and blank callout indicator.\n"
        "- Answer must be strictly 1-3 words taken verbatim from the passage.\n"
        "- Every candidate MUST include calloutLabel, partDescription, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Map location label for #{question_number} with blank \'______\'",\n'
        '      "calloutLabel": "Location {question_number}",\n'
        '      "partDescription": "Geographical or architectural layout description of the location",\n'
        '      "answer": "verbatim answer (1-3 words)",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage identifying the location",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) identifying this location on the map from the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_MULTIPLE: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Multiple Choice questions (choose TWO or THREE options) for question #{question_number}.\n"
        "RULES:\n"
        "- Provide at least 5 options with at least 2 correct answers.\n"
        "- Every candidate MUST include evidenceQuote and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Which TWO of the following statements are supported by the passage?",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "First option text"}},\n'
        '        {{"key": "B", "text": "Second option text"}},\n'
        '        {{"key": "C", "text": "Third option text"}},\n'
        '        {{"key": "D", "text": "Fourth option text"}},\n'
        '        {{"key": "E", "text": "Fifth option text"}}\n'
        '      ],\n'
        '      "answers": ["A", "C"],\n'
        '      "answer": "A, C",\n'
        '      "evidenceQuote": "exact verbatim passage quotes supporting the correct options",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why options A and C are correct and others are distractors."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MULTIPLE_CHOICE_SINGLE_IMAGE: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Multiple Choice Single Image questions for question #{question_number}.\n"
        "RULES:\n"
        "- Exactly one option must be the correct answer grounded in the passage.\n"
        "- Provide 4 distinct options (A, B, C, D).\n"
        "- Every candidate MUST include evidenceQuote and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Which diagram correctly illustrates the process described in the passage?",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "Diagram A: accurate process description"}},\n'
        '        {{"key": "B", "text": "Diagram B: inverted or incorrect step"}},\n'
        '        {{"key": "C", "text": "Diagram C: omitted critical stage"}},\n'
        '        {{"key": "D", "text": "Diagram D: contradictory flow"}}\n'
        '      ],\n'
        '      "answer": "A",\n'
        '      "evidenceQuote": "exact verbatim passage quotes describing the process structure",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) explaining why option A accurately matches the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MATCHING_HEADING: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Matching Heading candidates for question #{question_number}.\n"
        "RULES:\n"
        "- Headings use Roman numerals (i, ii, iii...).\n"
        "- Include a list of plausible headings (at least 3), with at least one unused distractor heading.\n"
        "- Every candidate MUST include paragraphRef, headings, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Paragraph {question_number}",\n'
        '      "paragraphRef": "Paragraph A",\n'
        '      "headings": [\n'
        '        "Heading i: First potential topic",\n'
        '        "Heading ii: Second potential topic",\n'
        '        "Heading iii: Third potential topic",\n'
        '        "Heading iv: Fourth potential topic (distractor)"\n'
        '      ],\n'
        '      "answer": "i",\n'
        '      "evidenceQuote": "exact verbatim topic or summary sentence from the paragraph",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) showing why heading i best captures the paragraph\'s theme."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MATCHING_INFORMATION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Matching Information candidates for question #{question_number}.\n"
        "RULES:\n"
        "- Statements match paragraphs A, B, C...\n"
        "- Every candidate MUST include targetParagraph, options, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "a mention of a specific phenomenon or event described in the text",\n'
        '      "targetParagraph": "A",\n'
        '      "answer": "A",\n'
        '      "options": ["Paragraph A", "Paragraph B", "Paragraph C", "Paragraph D"],\n'
        '      "evidenceQuote": "exact verbatim quote from Paragraph A containing this information",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why this information is found in Paragraph A."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MATCHING_FEATURES: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Matching Features candidates for question #{question_number}.\n"
        "RULES:\n"
        "- Match statements to named features, researchers, or categories (A, B, C...).\n"
        "- Every candidate MUST include options (at least 2), evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Finding or theory description",\n'
        '      "answer": "A",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "Feature or Person A"}},\n'
        '        {{"key": "B", "text": "Feature or Person B"}},\n'
        '        {{"key": "C", "text": "Feature or Person C"}}\n'
        '      ],\n'
        '      "evidenceQuote": "exact verbatim researcher finding quote from the passage",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) connecting the finding or theory to Feature A."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.MATCHING_ENDINGS: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Matching Sentence Endings candidates for question #{question_number}.\n"
        "RULES:\n"
        "- Match sentence beginnings to lettered endings (A, B, C...).\n"
        "- Every candidate MUST include options (at least 2), evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Sentence beginning statement requiring completion...",\n'
        '      "answer": "A",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "Ending completion A that forms an accurate statement"}},\n'
        '        {{"key": "B", "text": "Ending completion B distractor"}},\n'
        '        {{"key": "C", "text": "Ending completion C distractor"}}\n'
        '      ],\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage supporting the combined statement",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why Ending completion A correctly finishes the sentence."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.CLASSIFICATION: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Classification candidates for question #{question_number}.\n"
        "RULES:\n"
        "- Classify statements into categories (A, B, C...).\n"
        "- Every candidate MUST include options (at least 2), evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Characteristic or statement to classify",\n'
        '      "answer": "A",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "Category A definition or period"}},\n'
        '        {{"key": "B", "text": "Category B definition or period"}},\n'
        '        {{"key": "C", "text": "Category C definition or period"}}\n'
        '      ],\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage classifying the item into Category A",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) explaining why this item belongs in Category A based on the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.FLOW_CHART: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Flow Chart process ordering candidates for question #{question_number}.\n"
        "RULES FOR FLOW CHART:\n"
        "- Flow chart prompts must represent sequential processes with step layout descriptions and blank callout numbers.\n"
        "- Each step must describe a clear stage in the process.\n"
        "- Answer must be strictly 1-3 words taken verbatim from the passage.\n"
        "- Every candidate MUST include prompt, answer, flowSteps, stepIndex, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Complete the flow chart below. Step {question_number}: ______",\n'
        '      "answer": "verbatim step phrase (1-3 words)",\n'
        '      "flowSteps": [\n'
        '        "Stage 1: initial process step",\n'
        '        "Stage 2: subsequent process step with blank ______",\n'
        '        "Stage 3: final process step"\n'
        '      ],\n'
        '      "stepIndex": {question_number},\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage describing this process stage",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) justifying why this process step belongs here based on the passage."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.SUMMARY_COMPLETION_BOX: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Summary Completion with an options box for question #{question_number}.\n"
        "RULES:\n"
        "- The summary must be a coherent paragraph with blanks indicated by '[1]', '[2]', etc.\n"
        "- Provide a pool/box of options (words or phrases) with keys 'A', 'B', 'C', 'D' from which answers are chosen.\n"
        "- Distractors in the box must be grammatically plausible but incorrect.\n"
        "- Every candidate MUST include prompt, summaryText, options, answer, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Summary paragraph with blank [1] ...",\n'
        '      "summaryText": "Complete summary paragraph context containing blank [1] ...",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "correct option phrase"}},\n'
        '        {{"key": "B", "text": "distractor phrase 1"}},\n'
        '        {{"key": "C", "text": "distractor phrase 2"}},\n'
        '        {{"key": "D", "text": "distractor phrase 3"}}\n'
        '      ],\n'
        '      "answer": "A",\n'
        '      "evidenceQuote": "exact verbatim sentence from the passage supporting the summary statement",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why option A is the correct completion from the box."\n'
        "    }}\n"
        "  ]\n"
        "}}"
    ),
    QuestionPromptFamily.CHOOSING_TITLE: (
        "PASSAGE EXCERPT:\n<passage_material>\n{passage_text}\n</passage_material>\n\n"
        "Generate Choosing a Title candidates for question #{question_number}.\n"
        "RULES:\n"
        "- Provide 4 title options (A, B, C, D).\n"
        "- Exactly one option captures the overall thesis; others are too narrow, too broad, or contradicted.\n"
        "- Every candidate MUST include options, answer, evidenceQuote, and a detailed explanation (minimum 25 characters).\n\n"
        "Output JSON format:\n"
        "{{\n"
        '  "candidates": [\n'
        "    {{\n"
        '      "prompt": "Choose the most appropriate title for the passage.",\n'
        '      "answer": "A",\n'
        '      "options": [\n'
        '        {{"key": "A", "text": "Best overarching title capturing the central thesis"}},\n'
        '        {{"key": "B", "text": "Too specific title focusing on a single paragraph"}},\n'
        '        {{"key": "C", "text": "Too broad title generalizing beyond the text"}},\n'
        '        {{"key": "D", "text": "Inaccurate or contradicted title"}}\n'
        '      ],\n'
        '      "evidenceQuote": "exact verbatim sentence or sentences encapsulating the core passage theme",\n'
        '      "explanation": "Detailed passage-grounded explanation (minimum 25 characters) proving why title A best encompasses the full passage scope."\n'
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


def render_question_prompt(
    family: Union[QuestionPromptFamily, str],
    slot_number: int,
    passage_text: str,
    candidate_count: int = 3,
    blank_count: int = 4,
    total_questions: Optional[int] = None,
    target_focus: Optional[str] = None,
) -> str:
    """Renders a complete prompt string for question generation for any IELTS question family.

    Returns a combined, high-quality prompt with system instructions, passage envelope,
    slot constraints, and output JSON schema specifications.
    """
    resolved_family = QuestionPromptFamily.from_raw(family)
    prompt_payload = build_question_prompt(
        family=resolved_family,
        passage_text=passage_text,
        question_number=slot_number,
        candidate_count=candidate_count,
        blank_count=blank_count,
        target_focus=target_focus,
    )
    system_inst = prompt_payload.get("system_instruction", "")
    user_prompt = prompt_payload.get("user_prompt", "")
    meta_note = (
        f"\n[Generation Task: Question Family={resolved_family.name} ({resolved_family.value}), "
        f"Target Slot={slot_number}"
        + (f" of {total_questions}" if total_questions else "")
        + "]\n"
    )
    return f"{system_inst}\n\n{meta_note}\n{user_prompt}".strip()
