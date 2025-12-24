-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T12:23:10.353175
-- Source: mini-ielts.com
-- Title: The Horton Castle site
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-the-horton-castle-site
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-the-horton-castle-site'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-horton-castle-site';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-horton-castle-site';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-the-horton-castle-site';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-the-horton-castle-site',
    'The Horton Castle site',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766537322/ielts/the-horton-castle-site-_thumbp_45a5534b4d93.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - The Horton Castle site',
    E'**Questions 1-6:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 7-10:**\nChoose the correct letter, **A**, **B**, **C** or **D**.',
    E'# The Horton Castle Site - Stages in Doing a Tourism Case Study\n\n---\n\n## Questions 1-6\n\nChoose **SIX** answers from the box and write the correct letter, **A-H**, next to Questions 1-6.\n\n### Options:\n- **A** patterns\n- **B** names\n- **C** sources\n- **D** questions\n- **E** employees\n- **F** solutions\n- **G** headings\n- **H** officials\n\n### STAGES IN DOING A TOURISM CASE STUDY\n\n**RESEARCH**\n- Locate and read relevant articles, noting key information and also **1** _______\n- Identify a problem or need\n- Select interviewees - these may be site **2** _______, visitors or city **3** _______\n- Prepare and carry out interviews. If possible, collect statistics.\n- Check whether **4** _______ of interviewees can be used\n\n↓\n\n**ANALYSIS**\n- Select relevant information and try to identify **5** _______\n- Decide on the best form of visuals\n\n↓\n\n**WRITING THE CASE STUDY**\n- Give some background before writing the main sections\n- Do NOT end with **6** _______\n\n---\n\n## Questions 7-10\n\nChoose the correct letter, **A, B** or **C**.\n\n### The Horton Castle site\n\n**7.** Natalie and Dave agree one reason why so few people visit Horton Castle is that\n- **A** the publicity is poor.\n- **B** it is difficult to get to.\n- **C** there is little there of interest.\n\n**8.** Natalie and Dave agree that the greatest problem with a visitor centre could be\n- **A** covering the investment costs.\n- **B** finding a big enough space for it.\n- **C** dealing with planning restrictions.\n\n**9.** What does Dave say about conditions in the town of Horton?\n- **A** There is a lot of unemployment.\n- **B** There are few people of working age.\n- **C** There are opportunities for skilled workers.\n\n**10.** According to Natalie, one way to prevent damage to the castle site would be to\n- **A** insist visitors have a guide.\n- **B** make visitors keep to the paths.\n- **C** limit visitor numbers.\n'
  ,
    'https://www.youtube.com/embed/fsI13tne7Sc');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Locate and read relevant articles, noting key information and also',
    '',
    '{"info-q1": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Select interviewees - these may be site',
    '',
    '{"info-q2": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'visitors or city',
    '',
    '{"info-q3": ["H", "h"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Check whether _______ of interviewees can be used',
    '',
    '{"info-q4": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Select relevant information and try to identify',
    '',
    '{"info-q5": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Do NOT end with',
    '',
    '{"info-q6": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Natalie and Dave agree one reason why so few people visit Horton Castle is that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the publicity is poor.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. it is difficult to get to.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. there is little there of interest.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Natalie and Dave agree that the greatest problem with a visitor centre could be',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covering the investment costs.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. finding a big enough space for it.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. dealing with planning restrictions.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does Dave say about conditions in the town of Horton?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There is a lot of unemployment.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. There are few people of working age.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. There are opportunities for skilled workers.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'According to Natalie, one way to prevent damage to the castle site would be to',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. insist visitors have a guide.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. make visitors keep to the paths.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. limit visitor numbers.', false);


END$$;


COMMIT;