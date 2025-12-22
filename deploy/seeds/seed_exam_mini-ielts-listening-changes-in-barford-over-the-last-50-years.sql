-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T12:34:33.217531
-- Source: mini-ielts.com
-- Title: Changes in Barford over the last 50 years
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-changes-in-barford-over-the-last-50-years
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-changes-in-barford-over-the-last-50-years'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-changes-in-barford-over-the-last-50-years';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-changes-in-barford-over-the-last-50-years';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-changes-in-barford-over-the-last-50-years';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-changes-in-barford-over-the-last-50-years',
    'Changes in Barford over the last 50 years',
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
    'Listening Test - Changes in Barford over the last 50 years',
    E'**Questions 1-5**\nChoose the correct letter, **A, B or C**.\n\n**Changes in Barford over the last 50 years**\n\n---\n\n**Questions 6-10**\nWhat is planned for each of the following facilities?\n\nChoose **FIVE** answers from the box and write the correct letter, **A-G**, next to Questions 6-10.\n\n**Plans**\n\n**A** It will move to a new location.\n\n**B** It will have its opening hours extended.\n\n**C** It will be refurbished.\n\n**D** It will be used for a different purpose.\n\n**E** It will have its opening hours reduced.\n\n**F** It will have new management.\n\n**G** It will be expanded.\n',
    E'# Passage\n\n# Changes in Barford over the last 50 years - Listening Test\n\n## Questions 1-5: Multiple Choice (A, B or C)\nChanges in Barford over the last 50 years\n\n## Questions 6-10: Matching Plans to Facilities\nWhat is planned for each of the following facilities?\n\n### Plans (A-G)\n| Letter | Plan |\n|--------|------|\n| A | It will move to a new location |\n| B | It will have its opening hours extended |\n| C | It will be refurbished |\n| D | It will be used for a different purpose |\n| E | It will have its opening hours reduced |\n| F | It will have new management |\n| G | It will be expanded |\n\n### Facilities\n- 6. Railway station car park\n- 7. Cinema\n- 8. Indoor market\n- 9. Library\n- 10. Nature reserve\n'
  ,
    'https://www.youtube.com/embed/tANSv6Pzd9I?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'In Shona’s opinion, why do fewer people use buses in Barford these days?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The buses are old and uncomfortable.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Fares have gone up too much.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. There are not so many bus routes.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What change in the road network is known to have benefited the town most?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the construction of a bypass', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the development of cycle paths', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the banning of cars from certain streets', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What is the problem affecting shopping in the town centre?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. lack of parking spaces', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. lack of major retailers', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. lack of restaurants and cafes', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does Shona say about medical facilities in Barford?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There is no hospital.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. New medical practices are planned.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The number of dentists is too low.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The largest number of people are employed in',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. manufacturing.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. services.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. education.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'railway station car park',
    'Choose the correct answer.',
    '{"info-q6": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'cinema',
    'Choose the correct answer.',
    '{"info-q7": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'indoor market',
    'Choose the correct answer.',
    '{"info-q8": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'library',
    'Choose the correct answer.',
    '{"info-q9": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'nature reserve',
    'Choose the correct answer.',
    '{"info-q10": ["F", "f"]}'
  );


END$$;


COMMIT;