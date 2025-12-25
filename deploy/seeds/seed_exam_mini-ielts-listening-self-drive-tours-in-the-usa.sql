-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:43:09.041044
-- Source: mini-ielts.com
-- Title: Self-drive tours in the USA
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-self-drive-tours-in-the-usa
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-self-drive-tours-in-the-usa'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-self-drive-tours-in-the-usa';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-self-drive-tours-in-the-usa';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-self-drive-tours-in-the-usa';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-self-drive-tours-in-the-usa',
    'Self-drive tours in the USA',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766601678/ielts/download_thumbpad_ef97960718de.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Self-drive tours in the USA',
    E'## Questions 1-6\n\nComplete the notes below.\n\nWrite **ONE WORD** for each answer.\n\n### SELF-DRIVE TOURS IN THE USA\n\n**Example**\n- Name: Andrea Brown\n\n**Customer Details**\n- Address: 24, **(1)** ______ Road\n- Postcode: BH5 2OP\n- Phone: (mobile) 077 86 643 091\n- Heard about World Tours from: **(2)** ______\n\n**Trip Preferences**\n- Interested in: **(3)** ______ parks\n- Accommodation: staying in a **(4)** ______\n- Visit: a **(5)** ______\n- Visit: the **(6)** ______\n\n---\n## Questions 7-10\n\nComplete the table below.\n\nWrite **ONE WORD AND/OR A NUMBER** for each answer.\n\n| | **Trip One** | **Trip Two** |\n| :--- | :--- | :--- |\n| **Name** | Ardleigh | Grand |\n| **Number of days/Date** | 12 | **(7)** ______ |\n| **Total distance** | 980 km | 3000 km |\n| **Price (per person)** | £**(9)** ______ | £980 |\n| **Includes** | The **(8)** ______ | Free **(10)** ______ |\n',
    E'# Section 1: Self-Drive Tours in the USA\n\n**Instructions for the Candidate:**\n\nYou will hear a conversation between two people. One is a customer named Andrea Brown, and the other is a travel agent named Jamie from World Tours. They are discussing options for self-drive tours in the USA, specifically comparing two itineraries: the ''Ardleigh'' trip and the ''Grand'' trip.\n\n**Questions 1-10**\n\n**Questions 1-6**\nComplete the notes below.\nWrite **ONE WORD ONLY** for each answer.\n\n**Questions 7-10**\nComplete the table below.\nWrite **ONE WORD AND/OR A NUMBER** for each answer.\n\nPlease pay attention to specific details in the conversation, such as dates, costs, included activities, and accommodation types. You should read the questions before the audio begins to familiarize yourself with the information you need to identify. \n\n*Note: This text is provided for context. In the actual examination, you will only hear the audio recording.*'
  ,
    'https://www.youtube.com/embed/AS8_B5_-Xew?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Address: 24, _______ Road',
    '',
    '{"blank-q1": ["Ardleigh"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Heard about World Tours from: _______',
    '',
    '{"blank-q2": ["newspaper"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Interested in: _______ parks',
    '',
    '{"blank-q3": ["theme"]}'::jsonb
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
    'Accommodation: staying in a _______',
    '',
    '{"blank-q4": ["tent"]}'::jsonb
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
    'Visit: a _______',
    '',
    '{"blank-q5": ["castle"]}'::jsonb
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
    'Visit: the _______',
    '',
    '{"blank-q6": ["beach"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Trip Two - Date: _______',
    '',
    '{"blank-q7": ["2020"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Trip One - Includes: The _______',
    '',
    '{"blank-q8": ["flight"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Trip One - Price (per person): £_______',
    '',
    '{"blank-q9": ["429"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'TABLE_COMPLETION',
    'LISTENING',
    2,
    'Trip Two - Includes: Free _______',
    '',
    '{"blank-q10": ["dinner"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 6, E'## Questions 1-6\n\nComplete the notes below.\n\nWrite **ONE WORD** for each answer.\n\n### SELF-DRIVE TOURS IN THE USA\n\n**Example**\n- Name: Andrea Brown\n\n**Customer Details**\n- Address: 24, **(1)** ______ Road\n- Postcode: BH5 2OP\n- Phone: (mobile) 077 86 643 091\n- Heard about World Tours from: **(2)** ______\n\n**Trip Preferences**\n- Interested in: **(3)** ______ parks\n- Accommodation: staying in a **(4)** ______\n- Visit: a **(5)** ______\n- Visit: the **(6)** ______\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 7, 10, E'## Questions 7-10\n\nComplete the table below.\n\nWrite **ONE WORD AND/OR A NUMBER** for each answer.\n\n| | **Trip One** | **Trip Two** |\n| :--- | :--- | :--- |\n| **Name** | Ardleigh | Grand |\n| **Number of days/Date** | 12 | **(7)** ______ |\n| **Total distance** | 980 km | 3000 km |\n| **Price (per person)** | £**(9)** ______ | £980 |\n| **Includes** | The **(8)** ______ | Free **(10)** ______ |\n');

END$$;


COMMIT;