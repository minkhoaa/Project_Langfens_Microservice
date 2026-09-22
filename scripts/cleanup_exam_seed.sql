-- Cleanup script: remove all exam data, keep exam 11111111 as standard
-- Run BEFORE re-seeding to ensure clean state
-- Usage: psql -U exam -d exam-db -f scripts/cleanup_exam_seed.sql

BEGIN;

-- Delete in correct order (foreign key constraints)
DELETE FROM exam_options WHERE question_id IN (
    SELECT eq."Id" FROM exam_questions eq
    JOIN exam_sections es ON es."Id" = eq."SectionId"
    WHERE es."ExamId" != '11111111-1111-1111-1111-111111111111'
);
DELETE FROM exam_questions WHERE "SectionId" IN (
    SELECT "Id" FROM exam_sections WHERE "ExamId" != '11111111-1111-1111-1111-111111111111'
);
DELETE FROM exam_question_groups WHERE "SectionId" IN (
    SELECT "Id" FROM exam_sections WHERE "ExamId" != '11111111-1111-1111-1111-111111111111'
);
DELETE FROM exam_sections WHERE "ExamId" != '11111111-1111-1111-1111-111111111111';
DELETE FROM exams WHERE "Id" != '11111111-1111-1111-1111-111111111111';

-- Verify only exam 11111111 remains
SELECT "Id"::text, "Slug", "Title" FROM exams;
SELECT COUNT(*) AS remaining_exams FROM exams;

COMMIT;
