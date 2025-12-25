-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T00:42:50.595772
-- Source: mini-ielts.com
-- Title: Fiddy Working Heritage Farm
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-fiddy-working-heritage-farm
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-fiddy-working-heritage-farm';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-fiddy-working-heritage-farm',
    'Fiddy Working Heritage Farm',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766597440/ielts/fiddy_thumbpad_1f31d044a367.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Fiddy Working Heritage Farm',
    E'## Questions 1-4\n\nComplete the notes below. Write **NO MORE THAN TWO WORDS** for each answer.\n\n### Safety rules:\n- **1.** take care not to harm any _______\n- **2.** not touch any _______\n- **3.** wear _______\n- **4.** not bring _______ into the farm, with certain exceptions\n\n---\n\n## Questions 5-10\n\nLabel the map below. Write the correct letter, **A-I**, next to Questions 5-10.\n\n### Map:\n\n![Farm Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766530670/ielts/listening-test-1-label-map_186689a6f18b.jpg)\n\n### Options:\n- **A** Fiddy House\n- **B** Farm Shop\n- **C** Covered picnic area\n- **D** Cafe\n- **E** Ticket Office\n- **F** Scarecrow\n- **G** Maze\n- **H** Black Barn\n- **I** Entrance\n\n**Questions:**\n- **5.** Scarecrow → _______\n- **6.** Maze → _______\n- **7.** Cafe → _______\n- **8.** Black Barn → _______\n- **9.** Covered picnic area → _______\n- **10.** Fiddy House → _______',
    E'# Fiddy Working Heritage Farm - Listening Practice\n\n**Instructions:**\nYou will hear a guide giving visitors information about Fiddy Working Heritage Farm. Listen carefully to the audio recording and answer the questions below.\n\n**Audio Format:**\n- You will hear the recording ONCE only\n- There are 10 questions in total\n- Questions 1-4 require you to complete notes about farm safety rules\n- Questions 5-10 require you to label locations on the farm map\n- Pay attention to the guide''s instructions and directions\n\n**About the Farm:**\nFiddy Working Heritage Farm is a traditional working farm that demonstrates historical farming methods and techniques. Visitors can explore various areas of the farm, learn about traditional crafts, and see how farming was done in the past.\n\n**Task:**\nFor Questions 1-4, complete the notes about safety rules. Write NO MORE THAN TWO WORDS for each answer.\nFor Questions 5-10, label the map by writing the correct letter (A-I) next to each location.\n\n**Timing:**\nThis is a short listening practice test. Take notes while listening to help you remember the key information given by the guide.'
  ,
    'https://www.youtube.com/embed/IXfa58mHqMM?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    '• take care not to harm any _______',
    '',
    '{"blank-q1": ["ANIMAL", "ANIMALS"]}'::jsonb
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
    '• not touch any _______',
    '',
    '{"blank-q2": ["TOOL", "TOOLS"]}'::jsonb
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
    '• wear _______',
    '',
    '{"blank-q3": ["SHOES"]}'::jsonb
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
    '• not bring _______ into the farm, with certain exceptions',
    '',
    '{"blank-q4": ["DOG", "DOGS"]}'::jsonb
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
    'Scarecrow',
    '',
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
    'Maze',
    '',
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
    'Cafe',
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
    'Black Barn',
    '',
    '{"info-q8": ["H", "h"]}'
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
    'Covered picnic area',
    '',
    '{"info-q9": ["C", "c"]}'
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
    'Fiddy House',
    '',
    '{"info-q10": ["A", "a"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'## Questions 1-4\n\nComplete the notes below. Write **NO MORE THAN TWO WORDS** for each answer.\n\n### Safety rules:\n- **1.** take care not to harm any _______\n- **2.** not touch any _______\n- **3.** wear _______\n- **4.** not bring _______ into the farm, with certain exceptions');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 10, E'## Questions 5-10\n\nLabel the map below. Write the correct letter, **A-I**, next to Questions 5-10.\n\n### Map:\n\n![Farm Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766530670/ielts/listening-test-1-label-map_186689a6f18b.jpg)\n\n### Options:\n- **A** Fiddy House\n- **B** Farm Shop\n- **C** Covered picnic area\n- **D** Cafe\n- **E** Ticket Office\n- **F** Scarecrow\n- **G** Maze\n- **H** Black Barn\n- **I** Entrance\n\n**Questions:**\n- **5.** Scarecrow → _______\n- **6.** Maze → _______\n- **7.** Cafe → _______\n- **8.** Black Barn → _______\n- **9.** Covered picnic area → _______\n- **10.** Fiddy House → _______');

END$$;


COMMIT;