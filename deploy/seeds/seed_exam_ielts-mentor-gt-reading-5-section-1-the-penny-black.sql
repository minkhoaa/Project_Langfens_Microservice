-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T12:16:36.709868
-- Source: ielts-mentor.com
-- Title: GT Reading 5 Section 1 - The Penny Black
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-5-section-1-the-penny-black
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-5-section-1-the-penny-black'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-1-the-penny-black';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-1-the-penny-black';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-5-section-1-the-penny-black';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-5-section-1-the-penny-black',
    'GT Reading 5 Section 1 - The Penny Black',
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
    'Reading Passage - GT Reading 5 Section 1 - The Penny Black',
    E'**Questions 28-30:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 31-34:**\nMatch each statement with the correct person.\n\n**List of People:**\n- **A.** Rowland Hill\n- **B.** Lord Lichfield  \n- **C.** Cheverton\n- **D.** Tristram Hunt\n\n---\n\n**Questions 35-40:**\nComplete the notes. Write **NO MORE THAN TWO WORDS** for each answer.\n\n---\n\n# The Penny Black\n\nIt might not have looked very impressive, but the Penny Black, now 170 years old, was the first stamp to be created and it launched the modern postal system in Britain.',
    E'**Paragraph A.**\nBefore 1840 and the arrival of the Penny Black, you had to be rich and patient to use the Royal Mail. Delivery was charged according to the miles travelled and the number of sheets of paper used; a 2-page letter sent from Edinburgh to London, for example, would have cost 2 shillings, or more than £7 in today\'\'s money. And when the top-hatted letter carrier came to deliver it, it was the recipient who had to pay for the postage.\n\n**Paragraph B.**\nThe state of mail had been causing concern throughout the 1830s, but it was Rowland Hill, an inventor, teacher and social reformer from Kidderminster, who proposed a workable plan for change. Worried that a dysfunctional, costly service would stifle communication, he believed reform would stimulate trade and business.\n\n**Paragraph C.**\nHill\'\'s proposal for the penny post was so radical that Lord Lichfield said, \'\'Of all the wild and visionary schemes which I ever heard of, it is the most extravagant.\'\' But merchants and reformers backed Hill.\n\n**Paragraph D.**\nHill quickly settled on \'\'a bit of paper covered at the back with a glutinous wash\'\'. The Treasury launched a design competition. Cheverton\'\'s submission used a portrait of Queen Victoria engraved for a commemorative coin. The words \'\'Postage\'\' and \'\'One Penny\'\' were added alongside ornamental stars. Nobody thought to add the word \'\'Britain\'\'.\n\n**Paragraph E.**\nThe Penny Black was an instant hit. By end of 1840, more than 160 million letters had been sent - more than double the previous year.\n\n**Paragraph F.**\nHill and his supporters rightly predicted that cheaper post would improve the \'\'diffusion of knowledge\'\'.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'One of the characteristics of the postal service before the 1840s was that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. postmen were employed by various organisations.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. letters were restricted to a certain length.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. distance affected the price of postage.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. the price of delivery kept going up.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Letter writers in the 1830s',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. were not responsible for the cost of delivery.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. tried to fit more than one letter into an envelope.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. could only send letters to people living in cities.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. knew all letters were automatically read by postal staff.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What does the text say about Hill in the 1830s?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He was the first person to express concern.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He considered it more efficient for mail to be delivered by rail.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He felt reform was necessary for commercial development.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. His plan received support from all important figures.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_FEATURES',
    'READING',
    2,
    'His inspiration came from a particular picture.',
    'Choose the correct answer.',
    '{"feature-q31": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He claimed the postal system would lead to spread of information.',
    'Choose the correct answer.',
    '{"feature-q32": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He organised the creation of the first stamp.',
    'Choose the correct answer.',
    '{"feature-q33": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He expressed doubts about plans to change the postal service.',
    'Choose the correct answer.',
    '{"feature-q34": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    35,
    'SHORT_ANSWER',
    'READING',
    2,
    'Design came about as a result of a competition organised by the _______',
    'Write the correct answer from the passage.',
    ARRAY['Treasury']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SHORT_ANSWER',
    'READING',
    2,
    'Based on an engraving of Queen Victoria featured on a _______',
    'Write the correct answer from the passage.',
    ARRAY['coin', 'commemorative coin']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SHORT_ANSWER',
    'READING',
    2,
    'The stamp had pictures of _______ as decoration',
    'Write the correct answer from the passage.',
    ARRAY['stars', 'ornamental stars']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SHORT_ANSWER',
    'READING',
    2,
    'No mention of _______ as plan was for domestic use only',
    'Write the correct answer from the passage.',
    ARRAY['Britain', 'word Britain']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SHORT_ANSWER',
    'READING',
    2,
    'The _______ proved to be ineffective',
    'Write the correct answer from the passage.',
    ARRAY['ink', 'red ink']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SHORT_ANSWER',
    'READING',
    2,
    'In 1842, the _______ of the stamp was changed.',
    'Write the correct answer from the passage.',
    ARRAY['colour', 'color']::text[]
  );


END$$;


COMMIT;