-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T10:33:01.989453
-- Source: mini-ielts.com
-- Title: Visiting the Sheepmarket area
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-visiting-the-sheepmarket-area
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-visiting-the-sheepmarket-area'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-visiting-the-sheepmarket-area';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-visiting-the-sheepmarket-area';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-visiting-the-sheepmarket-area';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-visiting-the-sheepmarket-area',
    'Visiting the Sheepmarket area',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766633361/ielts/visiting-the-sheepmarket-area__112de0ac283e.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Visiting the Sheepmarket area',
    E'**Questions 1-4:**\nChoose the correct letter, **A**, **B** or **C**.\n\n---\n\n**Questions 5-10:**\nLabel the map below.\n\nWrite the correct letter, **A-I**, next to Questions 5-10.\n\n**Options:**\n- **A** Department Store\n- **B** Nucleus\n- **C** The Thumb\n- **D** Car Park\n- **E** Car Park\n- **F** The Museum\n- **G** Contemporary Art Gallery\n- **H** The Reynolds House\n- **I** The Warner Gallery',
    E'# Visiting the Sheepmarket area\n\nThis listening practice test focuses on the Sheepmarket area, one of the oldest and most historically significant parts of the city. Originally a place where farmers brought their sheep for market, it has now been transformed into a buzzing, vibrant district that is home to a growing community of professionals and designers.\n\nAs you listen to the podcast, you will learn about the area''s architecture, its thriving arts and crafts scene, and the various events held there, such as the Young Fashion competition. The guide also provides practical information regarding car parking and key attractions within the Sheepmarket.\n\n**Instructions:**\n- You will hear the recording **ONCE** only.\n- Answer all questions while you listen.\n- Questions 1-4: Choice the correct letter, **A**, **B** or **C**.\n- Questions 5-10: Map labeling (choose letters A-I)\n\n### Map for Questions 5-10:\n![Sheepmarket Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766633363/ielts/map_043fe18b850c.jpg)'
  ,
    'https://www.youtube.com/embed/nnd7qrQsYZs?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which is the most rapidly-growing group of residents in the Sheepmarket area?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. young families', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. university students', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. professionals', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The speaker says that the Sheepmarket is a main centre for',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the architecture of the area.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the manufacturing economy.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the arts and crafts.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Clothes designed by entrants for the Young Fashion competition must',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. be modelled by the designers themselves.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. be inspired by aspects of contemporary culture.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. be made from locally produced materials.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Car parking is free in some car parks if you',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. stay for less than an hour.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. buy something in the shops.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. park in the evenings or at weekends.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'The Reynolds House',
    '',
    '{"info-q5": ["H", "h"]}'
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
    'The Thumb',
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
    'The Museum',
    '',
    '{"info-q7": ["F", "f"]}'
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
    'The Contemporary Art Gallery',
    '',
    '{"info-q8": ["G", "g"]}'
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
    'The Warner Gallery',
    '',
    '{"info-q9": ["I", "i"]}'
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
    'Nucleus',
    '',
    '{"info-q10": ["B", "b"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'**Questions 1-4:**\nChoose the correct letter, **A**, **B** or **C**.\n\n**1.** Which is the most rapidly-growing group of residents in the Sheepmarket area?\n- **A** young families\n- **B** university students\n- **C** professionals\n\n**2.** The speaker says that the Sheepmarket is a main centre for\n- **A** the architecture of the area.\n- **B** the manufacturing economy.\n- **C** the arts and crafts.\n\n**3.** Clothes designed by entrants for the Young Fashion competition must\n- **A** be modelled by the designers themselves.\n- **B** be inspired by aspects of contemporary culture.\n- **C** be made from locally produced materials.\n\n**4.** Car parking is free in some car parks if you\n- **A** stay for less than an hour.\n- **B** buy something in the shops.\n- **C** park in the evenings or at weekends.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 10, E'**Questions 5-10:**\nLabel the map below.\n\nWrite the correct letter, **A-I**, next to Questions 5-10.\n\n### Map:\n![Sheepmarket Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766633363/ielts/map_043fe18b850c.jpg)\n\n**Options:**\n- **A** Department Store\n- **B** Nucleus\n- **C** The Thumb\n- **D** Car Park\n- **E** Car Park\n- **F** The Museum\n- **G** Contemporary Art Gallery\n- **H** The Reynolds House\n- **I** The Warner Gallery\n\n**5.** The Reynolds House: _______\n**6.** The Thumb: _______\n**7.** The Museum: _______\n**8.** The Contemporary Art Gallery: _______\n**9.** The Warner Gallery: _______\n**10.** Nucleus: _______');

END$$;


COMMIT;