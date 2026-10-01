"""Task-aware prompt text for IELTS Academic Reading generation."""
from __future__ import annotations

SECTION_PROFILES = {
    1: (
        "Use an accessible factual, descriptive or explanatory approach with a clear sequence. "
        "Do not force a debate or sustained argument."
    ),
    2: (
        "Use a moderately analytical or process-focused approach. Develop connections between "
        "ideas and details without forcing a debate."
    ),
    3: (
        "Section 3 must contain a sustained argument with nuanced claims and a clear progression. "
        "Examine competing explanations or positions only when the source supports them."
    ),
}

GROUP_INSTRUCTIONS = {
    "TRUE_FALSE_NOT_GIVEN": (
        "TRUE if the passage supports each part of the statement; FALSE if the passage contradicts it; "
        "NOT GIVEN if it is neither stated nor contradicted."
    ),
    "YES_NO_NOT_GIVEN": (
        "YES if the writer expresses this view; NO if the writer expresses the opposite view; "
        "NOT GIVEN if the writer's view is neither stated nor contradicted."
    ),
    "MULTIPLE_CHOICE_SINGLE": "Choose the correct letter, A, B, C or D.",
    "SENTENCE_COMPLETION": (
        "Write NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer."
    ),
    "SUMMARY_COMPLETION": (
        "Complete the summary. Write NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer."
    ),
    "SHORT_ANSWER": (
        "Answer each question using NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage."
    ),
}


def build_passage_prompt(topic: str, index: int, source_title: str) -> str:
    """Build a source-faithful passage prompt for one IELTS section profile."""
    if index not in SECTION_PROFILES:
        raise ValueError("Section index must be 1–3")
    profile = SECTION_PROFILES[index]
    return (
        "Write an original IELTS Academic Reading passage for a non-specialist reader. "
        "Do not copy sentences from the source. Use 780–870 words and 7–9 paragraphs, with a clear "
        "progression and a concise title. "
        f"{profile} "
        "Paraphrase and synthesize only claims supported by the supplied source. Keep a neutral, "
        "measured academic voice; preserve the study's limitations, uncertainty, population, and "
        "outcomes actually measured. Do not turn correlation into causation or make claims about "
        "effects the study did not measure. Do not add outside facts or invented findings. "
        "Confine the passage strictly to the specific facts, dates, entities, materials, and mechanisms explicitly described in the SOURCE EXCERPTS. "
        "Under no circumstances should you extrapolate beyond the text, invent future developments, or introduce external historical technologies, events, or outcomes not explicitly documented in the source. "
        "Strictly adhere to entity attributes in the source: do not misattribute headquarters or nationality (e.g. do not group non-US institutions under US entities), and do not assert broader patterns or strategy without direct source evidence. "
        "Do not guess or invent expansions for abbreviations or acronyms (retain verbatim or omit if undefined in the source). "
        "Do not include internal section labels, generation instructions, question numbers, or commentary in the title or passage. "
        "Return only plain text. Begin the final answer immediately and keep internal reasoning brief. "
        f"Topic: {topic}. Section: {index}. Source: {source_title}."
    )


def build_passage_extension_prompt(topic: str, index: int, requested_words: int) -> str:
    """Build a section-aware, source-faithful prompt for continuing a short passage."""
    if index not in SECTION_PROFILES:
        raise ValueError("Section index must be 1–3")
    if requested_words < 1:
        raise ValueError("Requested continuation length must be positive")
    return (
        f"Continue the IELTS Academic Reading passage about {topic} with approximately {requested_words} "
        f"more words in 1–2 paragraphs. Keep the continuation consistent with the existing Section {index} "
        f"profile: {SECTION_PROFILES[index]} Use only claims supported by the supplied source excerpts. "
        "Preserve the study's limitations, uncertainty, population, methods, and outcomes actually measured. "
        "Do not turn correlation into causation, overstate findings, add outside facts, or repeat information "
        "already in the passage. Ground every sentence in the source excerpts without inventing new entities, biological mechanisms, treatments, historical eras, or unverified events. "
        "Confine the continuation strictly to expanding on verified details already in the SOURCE EXCERPTS; do not extrapolate beyond the source or introduce external historical developments, technologies, or events not present in the excerpts. "
        "Continue its voice and sequence, end with a complete sentence, and do not "
        "include a heading, section label, question number, or commentary. Return only the continuation text."
    )

def build_passage_revision_prompt(topic: str, index: int) -> str:
    """Build a section-aware prompt for correcting source-review findings."""
    if index not in SECTION_PROFILES:
        raise ValueError("Section index must be 1–3")
    return (
        f"Revise the IELTS Academic Reading passage about {topic} to fix only the listed source-fidelity problems. "
        f"Keep its existing title and follow the Section {index} profile: {SECTION_PROFILES[index]} "
        "Use only claims supported by the supplied source excerpts. Preserve the study's limitations, "
        "uncertainty, population, methods, and outcomes actually measured. Do not turn correlation into "
        "causation, overstate findings, add outside facts, or remove supported details. "
        "For each finding in REVIEW FINDINGS, you must explicitly eliminate the flagged issue: "
        "for causal_overstatement and overstated_certainty, replace strong causal assertions or dramatic verbs ('spurred', 'revolutionized', 'transformed') with neutral, measured phrasing strictly supported by the source; "
        "for unsupported_claim or unmeasured_outcome, remove the ungrounded assertion completely and substitute verified details from the SOURCE EXCERPTS. "
        "Verify entity attributes (including company or bank headquarters and nationality) strictly against the source, and avoid asserting ungrounded strategic patterns. "
        "Do not guess or invent expansions for abbreviations or acronyms (retain verbatim or omit if undefined in the source). "
        "Do not simply delete flagged content and shorten the passage; rephrase flagged sentences accurately to reflect the source, and expand on other verified source details to maintain paragraph development. "
        "Keep approximately 750–850 words. Do not include internal section labels, generation instructions, question numbers, "
        "or commentary. Return only the title on the first line, a blank line, and the full revised passage."
    )


def build_question_prompt(kind: str, count: int, first: int, last: int,
                          replacement: bool = False) -> str:
    """Build model instructions for one question group."""
    if kind not in GROUP_INSTRUCTIONS:
        raise ValueError(f"Unsupported Reading question type: {kind}")
    if count < 1 or last - first + 1 != count:
        raise ValueError("Question range does not match count")
    if replacement and count != 1:
        raise ValueError("A replacement prompt must contain exactly one question")

    shape = (
        '["TRUE", "FALSE", "NOT GIVEN"]' if kind == "TRUE_FALSE_NOT_GIVEN" else
        '["YES", "NO", "NOT GIVEN"]' if kind == "YES_NO_NOT_GIVEN" else
        '["A. ...", "B. ...", "C. ...", "D. ..."]' if kind == "MULTIPLE_CHOICE_SINGLE" else "[]"
    )
    if replacement:
        instruction = (
            f"Replace only question {first} of type {kind}; its previous version failed quality review. "
            "Use a different, unambiguous fact from the passage. Return JSON object "
            "{\"question\":{\"number\":integer,\"prompt\":string,\"answer\":string,"
            "\"options\":[string],\"evidenceQuote\":string,\"explanation\":string}}. "
            "The evidence quote must be a verbatim passage span of at least 15 characters; the explanation "
            "must be at least 25 characters and show how that evidence supports the answer. "
        )
    else:
        instruction = (
            f"Create exactly {count} separate IELTS Academic Reading question objects of type {kind}, "
            f"numbered {first}–{last}. Return one JSON object {{\"questions\":[...]}}. Each object must "
            "contain number (integer), prompt (string), answer (string), options (array of strings), "
            "evidenceQuote (string), and explanation (string). Number every question continuously from "
            f"{first} to {last} with no gaps, no duplicates, and no sub-parts. Set options to "
            f"{shape}. "
        )

    if kind == "TRUE_FALSE_NOT_GIVEN":
        instruction += (
            "Write distinct factual statements about explicit claims in the passage. Use a balanced distribution of "
            "TRUE, FALSE, and NOT GIVEN across the group; avoid all-TRUE or all-FALSE sets. "
            "TRUE means supported by the passage; "
            "FALSE means contradicted by the passage; "
            "NOT GIVEN means neither stated nor contradicted. "
            "FALSE means at least one part is directly contradicted by the passage. "
            "Do not use outside knowledge. The evidenceQuote must be a verbatim passage span."
        )
    elif kind == "YES_NO_NOT_GIVEN":
        instruction += (
            "Write distinct statements about the writer's views, arguments, or claims in the passage. Do not confuse "
            "the writer's view or claim with neutral reported facts. "
            "Judge only the writer's view or claim. "
            "YES means the writer explicitly agrees; NO means the writer expresses the opposite view; "
            "NOT GIVEN means neither stated nor contradicted. "
            "Aim for a balanced distribution across YES, NO, and NOT GIVEN. The evidenceQuote must be a verbatim passage span."
        )
    elif kind == "MULTIPLE_CHOICE_SINGLE":
        instruction += (
            "Write clear four-option stems asking about a key finding, mechanism, or relationship in the passage. "
            "Provide four distinct options labelled A. to D.. "
            "Ensure exactly one correct answer; the other three must be plausible distractors that are contradicted, unsupported, "
            "or irrelevant under the passage text. The answer field must match the correct option string verbatim "
            "(for example 'B. ...'). The evidenceQuote must support the correct option."
        )
    elif kind == "SENTENCE_COMPLETION":
        blanks = " and ".join([f"[{first + i}] for question {first + i}" for i in range(count)])
        instruction += (
            f"Write {count} separate sentences that each contain exactly one numbered blank marker using that question's own number: {blanks}. "
            "The answer for each question must be copied verbatim from the passage and contain NO MORE THAN THREE "
            "WORDS AND/OR A NUMBER. Do not include the answer inside the sentence stem; do not leak the answer before "
            "or after the blank. Each sentence must test a different detail from the passage."
        )
    elif kind == "SUMMARY_COMPLETION":
        blanks = ", ".join([f"[{first + i}]" for i in range(count)])
        instruction += (
            f"Write a connected summary paragraph containing exactly {count} numbered blanks: {blanks}. "
            "The blanks must appear in question number order. Each prompt field in the output must be one clause "
            "or sentence from that connected summary containing its single [{first}...{last}] blank, so the questions "
            "together form one coherent summary. The answer for each blank must be copied verbatim from the passage "
            "and contain NO MORE THAN THREE WORDS AND/OR A NUMBER. Do not leak the answer in the surrounding summary text."
        )
    elif kind == "SHORT_ANSWER":
        instruction += (
            "Write direct question prompts about specific facts in the passage. Each answer must be copied verbatim "
            "from the passage and contain NO MORE THAN THREE WORDS AND/OR A NUMBER. The prompt must not repeat or leak "
            "the answer phrase. Each question must target a distinct fact."
        )
    return instruction


def build_group_instruction(kind: str, first: int, last: int) -> str:
    """Build canonical section instructions presented to test takers."""
    if kind not in GROUP_INSTRUCTIONS:
        raise ValueError(f"Unsupported Reading question type: {kind}")
    return f"Questions {first}–{last}. {GROUP_INSTRUCTIONS[kind]}"
