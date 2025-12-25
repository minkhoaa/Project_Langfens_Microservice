-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T09:53:18.403846
-- Source: mini-ielts.com
-- Title: Dolphin Conservation Trust
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-dolphin-conservation-trust
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-dolphin-conservation-trust'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-dolphin-conservation-trust';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-dolphin-conservation-trust';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-dolphin-conservation-trust';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-dolphin-conservation-trust',
    'Dolphin Conservation Trust',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766629717/ielts/dolphin-conservation-trust_thu_3686f4bd381d.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Dolphin Conservation Trust',
    E'**Questions 1-2:**\nChoose **TWO** letters, **A-E**.\n\n---\n\n**Questions 3-5:**\nChoose the correct letter, **A**, **B**, or **C**.\n\n---\n\n**Questions 6-10:**\nWhich dolphin does Alice make each of the following comments about?\nWrite the correct letter, **A**, **B**, **C** or **D**, next to questions 6-10.\n\n*NB You may use any letter more than once.*\n\n### Dolphins\n- **A** Moondancer\n- **B** Echo\n- **C** Kiwi\n- **D** Samson',
    E'# Listening Test - Dolphin Conservation Trust\n\nThis is a listening practice test about the Dolphin Conservation Trust featuring an interview with Alice, who works with the organization. Listen carefully to the audio recording and answer the questions below.\n\n**Instructions:**\nYou will hear the recording ONCE only. Answer all questions based on what you hear in the audio.\n\n**About the Audio:**\nThis test includes multiple choice questions and matching questions. In the first part, you will hear Alice discussing the Dolphin Conservation Trust organization and its activities. In the second part, she talks about individual dolphins in the adoption program and their unique characteristics.\n\n**Question Topics:**\n- Information about the Dolphin Conservation Trust organization\n- Details about Alice''s experience and the Charity Commission award\n- Matching comments about individual dolphins (Moondancer, Echo, Kiwi, Samson) to their characteristics\n\nListen carefully for specific details mentioned by the speakers and take notes if needed during the audio playback.'
  ,
    'https://www.youtube.com/embed/V2puNsehQHQ?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO things does Alice say about the Dolphin Conservation Trust?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Children make up most of the membership.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It''s the country''s largest conservation organisation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It helps finance campaigns for changes in fishing practices.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It employs several dolphin experts full-time.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Volunteers help in various ways.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Why is Alice so pleased the Trust has won the Charity Commission award?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It has brought in extra money.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It made the work of the trust better known.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It has attracted more members.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Alice says oil exploration causes problems to dolphins because of',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. noise.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. oil leaks.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. movement of ships.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Alice became interested in dolphins when',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. she saw one swimming near her home.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. she heard a speaker at her school.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. she read a book about them.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'It has not been seen this year.',
    '',
    '{"info-q5": ["B", "b"]}'
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
    'It is photographed more than the others.',
    '',
    '{"info-q6": ["C", "c"]}'
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
    'It is always very energetic.',
    '',
    '{"info-q7": ["D", "d"]}'
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
    'It is the newest one in the scheme.',
    '',
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
    'It has an unusual shape.',
    '',
    '{"info-q9": ["A", "a"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 1, E'## Questions 1-2\n\nChoose **TWO** letters, **A-E**.\n\nWhich TWO things does Alice say about the Dolphin Conservation Trust?\n\n- **A** Children make up most of the membership.\n- **B** It''s the country''s largest conservation organisation.\n- **C** It helps finance campaigns for changes in fishing practices.\n- **D** It employs several dolphin experts full-time.\n- **E** Volunteers help in various ways.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 2, 4, E'## Questions 3-5\n\nChoose the correct letter, **A**, **B**, or **C**.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 5, 9, E'## Questions 6-10\n\nWhich dolphin does Alice make each of the following comments about?\n\nWrite the correct letter, **A**, **B**, **C** or **D**, next to questions 6-10.\n\n*NB You may use any letter more than once.*\n\n### Dolphins\n- **A** Moondancer\n- **B** Echo\n- **C** Kiwi\n- **D** Samson');

END$$;


COMMIT;