-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T23:38:28.999325
-- Source: mini-ielts.com
-- Title: The work placement
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-the-work-placement
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-the-work-placement'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-work-placement';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-work-placement';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-the-work-placement';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-the-work-placement',
    'The work placement',
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
    'Listening Test - The work placement',
    E'**Questions 1-2:**\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** skills did Laura improve as a result of her work placement?\n\n---\n\n**Questions 3-4:**\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** immediate benefits did the company get from Laura''s work placement?\n\n---\n\n**Questions 5-10:**\n\nWhat source of information should Tim use at each of the following stages of the work placement?\n\nChoose **SIX** answers from the box and write the correct letter, **A-G**.',
    E'# Passage\n\n# The Work Placement - Listening Notes\n\n## Questions 1-2: Choose TWO letters, A-E\n\nWhich **TWO** skills did Laura improve as a result of her work placement?\n\n- A. communication\n- B. design\n- C. IT\n- D. marketing\n- E. organisation\n\n---\n\n## Questions 3-4: Choose TWO letters, A-E\n\nWhich **TWO** immediate benefits did the company get from Laura''s work placement?\n\n- A. updates for its software\n- B. cost savings\n- C. an improved image\n- D. new clients\n- E. a growth in sales\n\n---\n\n## Questions 5-10: Matching\n\nWhat source of information should Tim use at each of the following stages of the work placement?\n\n**Sources of information:**\n- A. company manager\n- B. company''s personnel department\n- C. personal tutor\n- D. psychology department\n- E. mentor\n- F. university careers officer\n- G. internet\n\n**Stages of the work placement procedure:**\n- 5. obtaining booklet\n- 6. discussing options\n- 7. getting updates\n- 8. responding to invitation for interview\n- 9. informing about outcome of interview\n- 10. requesting a reference'
  ,
    'https://www.youtube.com/embed/363riunV1PM?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which skill did Laura improve as a result of her work placement? (Answer 1 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. communication', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. design', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. IT', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. marketing', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. organisation', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which skill did Laura improve as a result of her work placement? (Answer 2 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. communication', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. design', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. IT', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. marketing', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. organisation', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which immediate benefit did the company get from Laura''s work placement? (Answer 1 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. updates for its software', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. cost savings', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. an improved image', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. new clients', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. a growth in sales', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which immediate benefit did the company get from Laura''s work placement? (Answer 2 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. updates for its software', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. cost savings', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. an improved image', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. new clients', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. a growth in sales', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'obtaining booklet',
    'Choose the correct answer.',
    '{"info-q5": ["D", "d"]}'
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
    'discussing options',
    'Choose the correct answer.',
    '{"info-q6": ["F", "f"]}'
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
    'getting updates',
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
    'responding to invitation for interview',
    'Choose the correct answer.',
    '{"info-q8": ["B", "b"]}'
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
    'informing about outcome of interview',
    'Choose the correct answer.',
    '{"info-q9": ["E", "e"]}'
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
    'requesting a reference',
    'Choose the correct answer.',
    '{"info-q10": ["C", "c"]}'
  );


END$$;


COMMIT;