-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T06:39:10.249838
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
    E'**Questions 1-2:** Choose TWO letters, A-E.\n\n**Questions 3-7:** Complete the table. Write NO MORE THAN THREE WORDS AND/OR A NUMBER.\n\n**Questions 8-10:** Choose THREE answers from the box. Write the correct letter, A-G.',
    E'# Hollylands Museum & Education Centre\n\n---\n\n## Questions 1-2\n\nChoose **TWO** letters, **A-E**.\n\n**1.** Which **TWO** activities for school groups need to be booked one week in advance?\n\n- **A** drama workshops\n- **B** garden sculpture experience  \n- **C** painting demonstrations\n- **D** tours for the blind\n- **E** video making\n\n**2.** Which **TWO** facilities are closed in winter?\n\n- **A** adventure playground\n- **B** artists'' studio\n- **C** cafe\n- **D** mini zoo\n- **E** shop\n\n---\n\n## Questions 3-7\n\nComplete the notes below. Write **NO MORE THAN THREE WORDS AND/OR A NUMBER** for each answer.\n\n### HOLLYLANDS MUSEUM & EDUCATION CENTRE - Exhibitions\n\n**History in Pictures**\n- Starting date: **3** _______\n- Points to remember: opportunity to go on an old bus\n\n**4** _______ (exhibition name)\n- Starting date: 19th September\n- Points to remember: visitors can use **5** _______ service\n\n**6** _______ (exhibition name)\n- Starting date: 11th November\n- Points to remember: competition prize: **7** _______ for 2 people\n\n---\n\n## Questions 8-10\n\nWhich place does each location relate to? Look at the map below.\n\nChoose **THREE** answers from the box and write the correct letter, **A-G**, next to questions **8-10**.\n\n### Options:\n- **A** bicycle parking\n- **B** drinks machine\n- **C** first aid room\n- **D** manager''s office\n- **E** telephones\n- **F** ticket office\n- **G** toilets\n\n### Map:\n\n![Hollylands Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766532669/ielts/m20_resized_b51818a0cbf6.jpg)\n\n**Questions:**\n- **8** Location marked 8: _______\n- **9** Location marked 9: _______\n- **10** Location marked 10: _______\n'
  ,
    'https://www.youtube.com/embed/yx_Oezp8uj8');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO activities are offered to visitors at Hollylands? Choose TWO letters, A-E.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. drama workshops', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. garden sculpture experience', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. painting demonstrations', true);
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
    'Which TWO facilities are available at Hollylands? Choose TWO letters, A-E.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. adventure playground', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. artists'' studio', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. cafe', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. mini zoo', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. shop', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Opens: _______',
    '',
    '{"blank-q3": ["28TH AUGUST"]}'::jsonb
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
    'Current exhibition: _______',
    '',
    '{"blank-q4": ["PEOPLE AT WORK"]}'::jsonb
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
    'visitors can use _______',
    '',
    '{"blank-q5": ["CAREERS ADVICE"]}'::jsonb
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
    'Exhibition area: _______',
    '',
    '{"blank-q6": ["LAND FROM AIR"]}'::jsonb
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
    'Latest addition: _______',
    '',
    '{"blank-q7": ["BALLOON TRIP"]}'::jsonb
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
    'First event',
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
    'Second event',
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
    'Third event',
    '',
    '{"info-q10": ["C", "c"]}'
  );


END$$;


COMMIT;