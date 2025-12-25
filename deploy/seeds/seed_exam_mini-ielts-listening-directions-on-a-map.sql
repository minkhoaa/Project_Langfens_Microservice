-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T00:13:09.027568
-- Source: mini-ielts.com
-- Title: Directions on a map
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-directions-on-a-map
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-directions-on-a-map'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-directions-on-a-map';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-directions-on-a-map';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-directions-on-a-map';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-directions-on-a-map',
    'Directions on a map',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766530792/ielts/map_thumbpad_00309ddc0d7c.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Directions on a map',
    E'## Questions 1-3\n\nListen to three speakers giving directions. For each speaker, identify which block (A-E) on the map they are directing someone to.\n\nWrite the correct letter, **A-E**.\n\n### Options:\n- **A** Block A\n- **B** Block B\n- **C** Block C\n- **D** Block D\n- **E** Block E\n\n### Map:\n\n![Directions Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766530794/ielts/map_e4f4dbedaf34.jpg)\n\n**Questions:**\n- **1.** Speaker 1 is giving directions to Block: _______\n- **2.** Speaker 2 is giving directions to Block: _______\n- **3.** Speaker 3 is giving directions to Block: _______',
    E'# Directions on a Map - Listening Practice\n\n**Instructions:**\nYou will hear three different speakers giving directions to different locations on a map. Listen carefully to each speaker and identify which block (A, B, C, D, or E) they are directing someone to.\n\n**Audio Format:**\n- You will hear the recording ONCE only\n- There are 3 questions in total\n- Each speaker describes a route to a specific block on the map\n- Pay attention to directional language (left, right, straight ahead, etc.)\n\n**Task:**\nFor each question, identify which block the speaker is giving directions to by selecting the correct letter from the map provided.\n\n**Map Reference:**\nThe map shows different blocks labeled A through E. Use the visual reference in the instruction section to match the spoken directions with the correct location.\n\n**Timing:**\nThis is a short listening practice test. Take notes while listening to help you remember the key directional information given by each speaker.'
  ,
    'https://www.youtube.com/embed/2gb9uvGyjOo?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Speaker 1 is giving directions to Block',
    '',
    '{"info-q1": ["A", "a"]}'
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
    'Speaker 2 is giving directions to Block',
    '',
    '{"info-q2": ["C", "c"]}'
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
    'Speaker 3 is giving directions to Block',
    '',
    '{"info-q3": ["B", "b"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 3, E'## Questions 1-3\n\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.');

END$$;


COMMIT;