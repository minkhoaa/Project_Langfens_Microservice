-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T11:46:43.926579
-- Source: mini-ielts.com
-- Title: An IT project for Tuners
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-an-it-project-for-tuners
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-an-it-project-for-tuners'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-an-it-project-for-tuners';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-an-it-project-for-tuners';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-an-it-project-for-tuners';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-an-it-project-for-tuners',
    'An IT project for Tuners',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - An IT project for Tuners',
    E'**Questions 1-6**\n\nWhat is the tutor''s opinion of the following company projects?\n\nChoose **FIVE** answers from the box, and write the correct letter, **A-H**, next to questions 1-6.\n\n---\n\n**Tutor''s opinion**\n\n**A** It would be very rewarding for the student.\n\n**B** It is too ambitious.\n\n**C** It would be difficult to evaluate.\n\n**D** It wouldn''t be sufficiently challenging.\n\n**E** It would involve extra costs.\n\n**F** It is beyond the student''s current ability.\n\n**G** It is already being done by another student.\n\n**H** It would probably have the greatest impact on the company.\n\n---\n\n**Questions 7-8**\nChoose **TWO** letters, **A-E**.\n\n**Questions 9-10**\nChoose **TWO** letters, **A-E**.\n',
    E'# Passage\n\n# IT Project for Tuners - Listening Test\n\n## Questions 1-6: Match Company Projects to Tutor''s Opinion\nWhat is the tutor''s opinion of the following company projects?\nChoose from options **A-H** below.\n\n### Tutor''s Opinions (A-H)\n| Letter | Opinion |\n|--------|---------|\n| A | It would be very rewarding for the student |\n| B | It is too ambitious |\n| C | It would be difficult to evaluate |\n| D | It wouldn''t be sufficiently challenging |\n| E | It would involve extra costs |\n| F | It is beyond the student''s current ability |\n| G | It is already being done by another student |\n| H | It would probably have the greatest impact on the company |\n\n### Company Projects\n1. **Customer database**\n2. **Online sales catalogue**\n3. **Payroll**\n4. **Stock inventory**\n5. **Internal/external email system**\n6. **Holiday entitlement**\n\n---\n\n## Questions 7-8: Software Testing Features\nChoose TWO letters, A-E.\n\n## Questions 9-10: Focus Group Problems\nChoose TWO letters, A-E.\n'
  ,
    'https://www.youtube.com/embed/oK2BZAbKGx4?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Customer database',
    'Choose the correct answer.',
    '{"info-q1": ["D", "d"]}'
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
    'Online sales catalogue',
    'Choose the correct answer.',
    '{"info-q2": ["B", "b"]}'
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
    'Payroll',
    'Choose the correct answer.',
    '{"info-q3": ["A", "a"]}'
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
    'Stock inventory',
    'Choose the correct answer.',
    '{"info-q4": ["H", "h"]}'
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
    'Internal/external email system',
    'Choose the correct answer.',
    '{"info-q5": ["F", "f"]}'
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
    'Holiday entitlement',
    'Choose the correct answer.',
    '{"info-q6": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO features of the software testing process are mentioned?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Personal relationships.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Cultural differences.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Division of labour.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Group leadership.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Group size.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO problems with focus groups are mentioned?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Punctuality.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Organisation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Accessibility.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Helpfulness.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Teaching materials.', false);


END$$;


COMMIT;