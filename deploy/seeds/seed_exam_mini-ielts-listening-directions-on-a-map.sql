-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T03:48:51.841724
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
    E'**Questions 1-3:**\nLook at the campus plan and listen to three people giving directions.\nIn each case, which block do the directions lead to?\n\nChoose the correct letter, **A-E**.',
    E'# Directions on a Map\n\n## Listening: Campus Directions (Questions 1-3)\n\nListen to three people giving directions on campus. Look at the map and identify which block each speaker is giving directions to. This is a common type of IELTS Listening task where you need to follow spoken directions and match them to locations on a map or plan.\n\nIn this exercise, you will hear three different speakers, each giving directions to a specific building or block on the campus. Pay close attention to the directional language used, such as "turn left", "go straight", "on your right", and "opposite to" to help you identify the correct location.\n\n---\n\n## Campus Map (Questions 1-3)\n\n![Campus Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766530794/ielts/map_e4f4dbedaf34.jpg)\n\nThe map shows a campus layout with five labeled blocks: **A**, **B**, **C**, **D**, and **E**. Each speaker gives directions from a starting point to one of these blocks. Match each speaker (1-3) to the correct block letter (A-E) based on the directions you hear.\n\nListen carefully to the audio and select the correct answer for each speaker.'
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


END$$;


COMMIT;