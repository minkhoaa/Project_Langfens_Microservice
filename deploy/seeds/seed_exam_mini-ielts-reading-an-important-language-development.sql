-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T22:31:48.687554
-- Source: mini-ielts.com
-- Title: An important language development
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-an-important-language-development
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-an-important-language-development'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-an-important-language-development';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-an-important-language-development';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-an-important-language-development';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-an-important-language-development',
    'An important language development',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - An important language development',
    E'**Questions 1-5:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 6-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'# Passage\n\n**Paragraph A.**\n\n\\nCuneiform, the world’s first known system of handwriting, originated some 6.000 years ago in Summer in what is now southern Iraq. It was most often inscribed on palm­sized, rectangular clay tablets measuring several centimetres across, although occasionally, larger tablets or cylinders were used. Clay was an excellent medium for writing. Other surfaces which have been employed - for example, parchment, papyrus and paper - are not long - lasting and are easily destroyed by fire and water. But clay has proved to be resistant to those particular kinds of damage.\\n\\n**Paragraph B.**\n\n\\nThe word ‘cuneiform’ actually refers to the marks or signs inscribed in the clay. The original cuneiform signs consisted of a series of lines - triangular, vertical, diagonal and horizontal. Sumerian writers would impress these lines into the wet clay with a stylus - a long, thin, pointed instrument which looked somewhat like a pen. Oddly, the signs were often almost too small to see with the naked eye. Cuneiform signs were used for the writing of at least a dozen languages. This is similar to how the Latin alphabet is used today for writing English, French, Spanish and German for example.\\n\\n**Paragraph C.**\n\n\\nBefore the development of cuneiform, tokens were used by the Sumerians to record certain information. For example, they might take small stones and use them as tokens or representations of something else, like a goat. A number of tokens, then, might mean a herd of goat. These tokens might then be placed in a cloth container and provided to a buyer as a receipt for a transaction, perhaps five tokens for five animals. It was not that different from what we do today when we buy some bread and the clerk gives us back a piece of paper with numbers on it to confirm the exchange.\\n\\n**Paragraph D.**\n\n\\nBy the 4 th century BCE, the Sumerians had adapted this system to a form of writing. They began putting tokens in a container resembling an envelope, and now made of clay instead of cloth. They then stamped the outside to indicate the number and type of tokens inside. A person could then ‘read’ what was stamped on the container and know what was inside.\\n\\n**Paragraph E.**\n\n\\nGradually, Sumerians developed symbols for words. When first developed, each symbol looked like the concrete thing it represented. For example, an image which resembled the drawing of a sheep meant just that. Then another level of abstraction was introduced when symbols were developed for intangible ideas such as ‘female’ of ‘hot’ or ‘God’. Cuneiform, in other words, evolved from a way used primarily to track and store information into a way to represent the world symbolically. Over the centuries, the marks became ever more abstract, finally evolving into signs that looked nothing like what they referred to, just as the letters ‘h-o-u-s-e’ have no visual connection to the place we live in. At this last stage in the evolution of cuneiform, the signs took the form of tringles, which became common cuneiform signs.\\n\\n**Paragraph F.**\n\n\\nAs the marks became more abstract, the system became more efficient because there were fewer marks a ‘reader’ needed to learn. But cuneiform also became more complex because society itself was becoming more complex, so there were more ideas and concepts that needed to be expressed. However, most linguists and historians agree cuneiform developed primarily as a tool for accounting. Of the cuneiform tablets that have been discovered, excavated and translated, about 75 percent contain this type of practical information, rather than artistic or imaginative work.\\n\\n**Paragraph G.**\n\n\\nCuneiform writing was used for thousands of years, but it eventually ceased to be used in everyday life. In fact, it died out and remained unintelligible for almost 2.000 years. In the late 19 th century, a British army officer, Henry Rawlinson, discovered cuneiform inscriptions which had been carved in the surface of rocks in the Behistun mountains in what is present-day Iran. Rawlinson made impressions of the marks on large pieces of paper, as he balanced dangerously on the surrounding rocks.\\n\\n**Paragraph H.**\n\n\\nRawlinson took his copies home to Britain and studied them for years to determine what each line stood for, and what each group of symbols meant. He found that in the writing on those particular rocks every word was repeated three times in three languages: Old Persian, Elamite and Babylonian. Since the meanings in these languages were already known to linguists, he could thus translate the cuneiform. Eventually, he fully decoded the cuneiform marks and he discovered that they described the life of Darius, a king of the Persian Empire in the 5 th century BCE.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Cuneiform tablets were produced in different shapes and sizes.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'When Sumerian writers marked on the clay tablets, the tablets were dry',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Cuneiform was often difficult to read because of its size.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'A number of languages adopted cuneiform.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Cuneiform signs, can be found in some modern alphabets.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'tokens, for example, _______ were often used',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": ["stones"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'the first tokens were kept in containers made of _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["cloth"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'tokens were used as a _______ to give when selling something',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q8": ["receipt"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'tokens were put in a container that looked like a clay _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q9": ["envelope"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'at first, signs looked like what they indicated, e.g. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q10": ["sheep"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'eventually, cuneiform signs shaped like _______ were developed',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q11": ["triangles"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'according to experts, cuneiform was mainly used for _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q12": ["accounting"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Rawlinson copied inscriptions onto _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q13": ["paper"]}'::jsonb
  );


END$$;


COMMIT;