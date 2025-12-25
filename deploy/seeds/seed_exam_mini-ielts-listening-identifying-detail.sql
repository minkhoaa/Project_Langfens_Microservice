-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:14:20.211505
-- Source: mini-ielts.com
-- Title: Identifying detail
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-identifying-detail
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-identifying-detail'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-identifying-detail';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-identifying-detail';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-identifying-detail';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-identifying-detail',
    'Identifying detail',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766600054/ielts/Identifying_detail_thumbpad_42766e99bad9.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Identifying detail',
    E'## Questions 1-3\n\nListen and decide which picture, **A**, **B** or **C**, matches the description.\n\n![Identifying Detail Images](https://res.cloudinary.com/df41zs8il/image/upload/v1766600059/ielts/Identifying_20detail_resized_c9d3e0549033.jpg)\n\n**1.** Which picture matches the description for Question 1?\n- **A** Picture A\n- **B** Picture B\n- **C** Picture C\n\n**2.** Which picture matches the description for Question 2?\n- **A** Picture A\n- **B** Picture B\n- **C** Picture C\n\n**3.** Which picture matches the description for Question 3?\n- **A** Picture A\n- **B** Picture B\n- **C** Picture C',
    E'# Identifying Detail - Listening Practice\n\n**Task Description:**\nIn this listening exercise, you will hear a series of short recordings. Your task is to identify specific details from the audio and match them to the correct visual representation.\n\n**Instructions:**\nListen carefully to the audio. For each question, look at the provided images (Picture A, Picture B, and Picture C). Decide which picture best matches the description you hear in the recording.\n\n**Tips for Identifying Details:**\n1.  **Focus on keywords:** Listen for specific nouns and adjectives that describe physical appearance, locations, or actions.\n2.  **Compare images:** Before the audio starts, quickly scan the images to note the differences between them.\n3.  **Eliminate options:** As you listen, rule out pictures that clearly do not match the description.\n4.  **Listen for distractors:** Be aware that the speaker may mention details from incorrect pictures to trick you.\n\n**Note:**\nThis practice test focuses on your ability to distinguish between similar visual options based on spoken descriptions. Pay close attention to subtle differences in the images.'
  ,
    'https://www.youtube.com/embed/Z9JSNb_jpO0?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which picture matches the description for Question 1?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Picture A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Picture B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Picture C', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which picture matches the description for Question 2?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Picture A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Picture B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Picture C', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which picture matches the description for Question 3?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Picture A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Picture B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Picture C', true);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 3, E'## Questions 1-3\n\nListen and decide which picture, **A**, **B** or **C**, matches the description.\n\n![Identifying Detail Images](https://res.cloudinary.com/df41zs8il/image/upload/v1766600059/ielts/Identifying_20detail_resized_c9d3e0549033.jpg)\n\n**1.** Which picture matches the description for Question 1?\n- **A** Picture A\n- **B** Picture B\n- **C** Picture C\n\n**2.** Which picture matches the description for Question 2?\n- **A** Picture A\n- **B** Picture B\n- **C** Picture C\n\n**3.** Which picture matches the description for Question 3?\n- **A** Picture A\n- **B** Picture B\n- **C** Picture C');

END$$;


COMMIT;