-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:03:24.269789
-- Source: mini-ielts.com
-- Title: Hollylands
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-hollylands
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-hollylands'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-hollylands';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-hollylands';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-hollylands';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-hollylands',
    'Hollylands',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766532670/ielts/holylands_thumbpad_dc615c9af12b.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Hollylands',
    E'## Questions 1-2\n\nChoose **TWO** letters, A-E.\n\n**1.** Which TWO activities are for school groups but MUST be booked at least one week in advance?\n\n- **A** drama workshops\n- **B** garden sculpture experience\n- **C** painting demonstrations\n- **D** tours for the blind\n- **E** video making\n\n**2.** Which TWO facilities are closed in winter?\n\n- **A** café\n- **B** museum shop\n- **C** picnic area\n- **D** souvenir stand\n- **E** toilets\n\n---\n\n## Questions 3-7\n\nComplete the table below. Write **NO MORE THAN THREE WORDS AND/OR A NUMBER** for each answer.\n\n### HOLLYLANDS MUSEUM & EDUCATION CENTRE\n\n| Starting Date | Exhibition Name | Special Feature |\n|---------------|----------------|-----------------|\n| **3.** _______ | History in Pictures | - |\n| 19th September | **4.** _______ | visitors can use **5.** _______ |\n| 11th November | **6.** _______ | - |\n| - | - | competition prize: **7.** _______ for 2 people |\n\n---\n\n## Questions 8-10\n\nLabel the plan below. Choose **THREE** answers from the box and write the letters next to questions 8-10.\n\n### Options:\n- **A** bicycle parking\n- **B** drinks machine\n- **C** first aid room\n- **D** manager''s office\n- **E** telephones\n- **F** ticket office\n- **G** toilets\n\n### Map:\n\n![Hollylands Centre Plan](https://res.cloudinary.com/df41zs8il/image/upload/v1766532669/ielts/m20_resized_b51818a0cbf6.jpg)\n\n**8.** Location 8: _______\n\n**9.** Location 9: _______\n\n**10.** Location 10: _______',
    E'# Hollylands Museum & Education Centre - Listening Practice\n\n**Instructions:**\nYou will hear information about Hollylands Museum and Education Centre. Listen carefully and answer the questions below.\n\n**About Hollylands:**\nHollylands Museum & Education Centre is a cultural and educational facility offering various activities for school groups and the general public. The centre features exhibitions, workshops, and educational programs throughout the year.\n\n**Facilities:**\nThe centre includes a museum, café, picnic area, souvenir stand, and various educational spaces. Some facilities operate seasonally, with certain areas closed during winter months.\n\n**Exhibitions:**\nThe centre hosts rotating exhibitions throughout the year, covering topics from local history to toys and seasonal celebrations. Visitors can enhance their experience with audio guides and participate in competitions.\n\n**Task:**\nListen to the recording and complete Questions 1-10. Pay attention to details about activities, facilities, exhibition schedules, and the centre''s layout.'
  ,
    'https://www.youtube.com/embed/yx_Oezp8uj8?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO activities are for school groups but MUST be booked at least one week in advance?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. drama workshops', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. garden sculpture experience', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. painting demonstrations', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. tours for the blind', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. video making', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO facilities are closed in winter?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. café', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. museum shop', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. picnic area', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. souvenir stand', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. toilets', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Starting date for ''History in Pictures'' exhibition: _______',
    '',
    '{"blank-q3": ["21st May"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Name of exhibition starting on 19th September: _______',
    '',
    '{"blank-q4": ["Toys through the Ages"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Visitors can use _______ during September exhibition',
    '',
    '{"blank-q5": ["audio guide"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Name of exhibition starting on 11th November: _______',
    '',
    '{"blank-q6": ["Christmas Past"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Competition prize for 2 people: _______',
    '',
    '{"blank-q7": ["family ticket"]}'::jsonb
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
    'Location 8 on map',
    '',
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
    'Location 9 on map',
    '',
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
    'Location 10 on map',
    '',
    '{"info-q10": ["C", "c"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 2, E'## Questions 1-2\n\nChoose **TWO** letters, A-E.\n\n**1.** Which TWO activities are for school groups but MUST be booked at least one week in advance?\n\n- **A** drama workshops\n- **B** garden sculpture experience\n- **C** painting demonstrations\n- **D** tours for the blind\n- **E** video making\n\n**2.** Which TWO facilities are closed in winter?\n\n- **A** café\n- **B** museum shop\n- **C** picnic area\n- **D** souvenir stand\n- **E** toilets');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 3, 7, E'## Questions 3-7\n\nComplete the table below. Write **NO MORE THAN THREE WORDS AND/OR A NUMBER** for each answer.\n\n### HOLLYLANDS MUSEUM & EDUCATION CENTRE\n\n| Starting Date | Exhibition Name | Special Feature |\n|---------------|----------------|-----------------|\n| **3.** _______ | History in Pictures | - |\n| 19th September | **4.** _______ | visitors can use **5.** _______ |\n| 11th November | **6.** _______ | - |\n| - | - | competition prize: **7.** _______ for 2 people |');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 8, 10, E'## Questions 8-10\n\nLabel the plan below. Choose **THREE** answers from the box and write the letters next to questions 8-10.\n\n### Options:\n- **A** bicycle parking\n- **B** drinks machine\n- **C** first aid room\n- **D** manager''s office\n- **E** telephones\n- **F** ticket office\n- **G** toilets\n\n### Map:\n\n![Hollylands Centre Plan](https://res.cloudinary.com/df41zs8il/image/upload/v1766532669/ielts/m20_resized_b51818a0cbf6.jpg)\n\n**8.** Location 8: _______\n\n**9.** Location 9: _______\n\n**10.** Location 10: _______');

END$$;


COMMIT;