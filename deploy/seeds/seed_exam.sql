BEGIN;
-- Ensure uuid generator is available
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup old IELTS reading samples by slug prefix
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" LIKE 'ielts-reading-sample-%'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id" AND s."ExamId" = e."Id" AND e."Slug" LIKE 'ielts-reading-sample-%';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id" AND e."Slug" LIKE 'ielts-reading-sample-%';
DELETE FROM exams WHERE "Slug" LIKE 'ielts-reading-sample-%';

-- Generate 10 complete IELTS Reading exams, each with 3 sections and 14 questions
DO $$
DECLARE
  i int;
  exam_id uuid;
  sec_id1 uuid;
  sec_id2 uuid;
  sec_id3 uuid;
  qid uuid;
  oid uuid;
BEGIN
  FOR i IN 1..10 LOOP
    exam_id := gen_random_uuid();
    INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
    VALUES (
      exam_id,
      'ielts-reading-sample-'||i,
      'IELTS Reading Sample Test '||i,
      'Auto-generated sample exam #'||i||' for bulk testing. 3 sections, 14 questions.',
      'IELTS','B2','PUBLISHED',60, now()
    );

    -- Section 1: T/F/NG (6)
    sec_id1 := gen_random_uuid();
    INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd") VALUES (
      sec_id1, exam_id, 1,
      'Reading Passage 1 — Coffee (v'||i||')',
      '# Passage\n\nAuto-generated text about coffee v'||i||'. Answer Q1–Q6: True / False / Not Given.'
    );

    -- Insert 6 T/F/NG questions
    FOR qid IN SELECT gen_random_uuid() LOOP END LOOP; -- dummy to declare qid
    FOR q IN 1..6 LOOP
      qid := gen_random_uuid();
      INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd") VALUES (
        qid, sec_id1, q, 'TRUE_FALSE_NOT_GIVEN','READING',1,
        q||') Statement about coffee v'||i||' ('||q||').', 'Auto-generated explanation.'
      );
      -- 3 options T/F/NG (make True correct on odd q, False correct on even q)
      INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
        (gen_random_uuid(), qid, 1, 'True',   (q % 2 = 1)),
        (gen_random_uuid(), qid, 2, 'False',  (q % 2 = 0)),
        (gen_random_uuid(), qid, 3, 'Not Given', false);
    END LOOP;

    -- Section 2: MCQ (4)
    sec_id2 := gen_random_uuid();
    INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd") VALUES (
      sec_id2, exam_id, 2,
      'Reading Passage 2 — Urban Bees (v'||i||')',
      '# Passage\n\nAuto-generated text about urban bees v'||i||'. Answer Q7–Q10: Choose one option.'
    );
    FOR q IN 1..4 LOOP
      qid := gen_random_uuid();
      INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd") VALUES (
        qid, sec_id2, q, 'MULTIPLE_CHOICE_SINGLE','READING',2,
        (6+q)||') Question about bees v'||i||' ('||q||').', 'Auto-generated explanation.'
      );
      -- 4 options; correct is idx = ((q % 4) + 1)
      INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
        (gen_random_uuid(), qid, 1, 'Option A', ((q % 4) = 0)),
        (gen_random_uuid(), qid, 2, 'Option B', ((q % 4) = 1)),
        (gen_random_uuid(), qid, 3, 'Option C', ((q % 4) = 2)),
        (gen_random_uuid(), qid, 4, 'Option D', ((q % 4) = 3));
    END LOOP;

    -- Section 3: MCQ (4)
    sec_id3 := gen_random_uuid();
    INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd") VALUES (
      sec_id3, exam_id, 3,
      'Reading Passage 3 — Remote Work (v'||i||')',
      '# Passage\n\nAuto-generated text about remote work v'||i||'. Answer Q11–Q14: Choose one option.'
    );
    FOR q IN 1..4 LOOP
      qid := gen_random_uuid();
      INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd") VALUES (
        qid, sec_id3, q, 'MULTIPLE_CHOICE_SINGLE','READING',2,
        (10+q)||') Question about remote work v'||i||' ('||q||').', 'Auto-generated explanation.'
      );
      INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
        (gen_random_uuid(), qid, 1, 'Option A', ((q % 4) = 0)),
        (gen_random_uuid(), qid, 2, 'Option B', ((q % 4) = 1)),
        (gen_random_uuid(), qid, 3, 'Option C', ((q % 4) = 2)),
        (gen_random_uuid(), qid, 4, 'Option D', ((q % 4) = 3));
    END LOOP;

  END LOOP;
END$$;

COMMIT;
