-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T09:06:23.318346
-- Source: mini-ielts.com
-- Title: New staff at theatre
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-new-staff-at-theatre
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-new-staff-at-theatre'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-new-staff-at-theatre';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-new-staff-at-theatre';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-new-staff-at-theatre';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-new-staff-at-theatre',
    'New staff at theatre',
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
    'Listening Test - New staff at theatre',
    E'Listen to the audio and answer the questions. For Questions 1-6, choose TWO letters A-E. For Questions 7-10, write the correct letter A-G next to each location.',
    E'# Passage\n\n# Listening Test - New Staff at Theatre\n\nWelcome to the orientation session at Amersham Theatre. This listening test is designed for new staff members and covers essential information about the theatre''s facilities, recent renovations, and building layout.\n\n## Part 1: Multiple Choice (Questions 1-6)\n\nYou will hear a conversation between the theatre manager and a new staff member discussing various topics:\n- Changes made during the recent refurbishment\n- Current facilities available to the public\n- Updates to the staff canteen\n\nListen carefully and choose TWO correct answers for each question group.\n\n## Part 2: Map Labelling (Questions 7-10)\n\nYou will hear a continuation of the tour where the manager describes the layout of the theatre. Label the locations on the floor plan including the box office, manager offices, and technical areas.\n\nListen to the audio recording and answer all questions.'
  ,
    'https://www.youtube.com/embed/n46mwotd5vw?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Choose TWO letters, A-E. Which TWO changes have been made to the theatre during the refurbishment?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Some rooms now have a different use.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. A different type of seating has been installed.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. An elevator has been installed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The outside of the building has been repaired.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Extra seats have been added.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Choose TWO letters, A-E. Which TWO facilities does the theatre currently offer for the public?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. A cafe', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. A shop', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. A gallery', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Parking', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Internet access', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Choose TWO letters, A-E. Which TWO changes does the speaker mention about the staff canteen?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. New furniture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Longer opening hours', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Healthier food', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. New vending machines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. A bigger area', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'box office',
    'Choose the correct answer.',
    '{"info-q7": ["G", "g"]}'
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
    'theatre manager''s office',
    'Choose the correct answer.',
    '{"info-q8": ["D", "d"]}'
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
    'lighting box',
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
    'artistic director''s office',
    'Choose the correct answer.',
    '{"info-q10": ["F", "f"]}'
  );


END$$;


COMMIT;