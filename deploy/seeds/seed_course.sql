BEGIN;
-- Ensure uuid functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup by slug prefix
DELETE FROM lesson_completion WHERE "LessonId" IN (
  SELECT l."Id" FROM lesson l JOIN course c ON c."Id"=l."CourseId" WHERE c."Slug" LIKE 'intro-ielts-reading-%'
);
DELETE FROM enrollment WHERE "CourseId" IN (
  SELECT c."Id" FROM course c WHERE c."Slug" LIKE 'intro-ielts-reading-%'
);
DELETE FROM lesson WHERE "CourseId" IN (
  SELECT c."Id" FROM course c WHERE c."Slug" LIKE 'intro-ielts-reading-%'
);
DELETE FROM course WHERE "Slug" LIKE 'intro-ielts-reading-%';

-- Generate 10 courses, each 6 lessons (total 60+ rows)
DO $$
DECLARE
  i int;
  course_id uuid;
  lesson_id uuid;
  user_id uuid := '22222222-2222-2222-2222-222222222222';
BEGIN
  FOR i IN 1..10 LOOP
    course_id := gen_random_uuid();
    INSERT INTO course ("Id","Slug","Title","DescriptionMd","Category","Level","Status","CreatedAt","UpdatedAt") VALUES (
      course_id,
      'intro-ielts-reading-'||i,
      'Intro to IELTS Reading '||i,
      'Auto-generated course #'||i||' with 6 lessons.',
      'IELTS','B1','PUBLISHED', now() - (i||' days')::interval, now()
    );

    -- 6 lessons per course
    FOR j IN 1..6 LOOP
      lesson_id := gen_random_uuid();
      INSERT INTO lesson ("Id","CourseId","Idx","Title","ContentMd","DurationMin") VALUES (
        lesson_id, course_id, j,
        'Lesson '||j||' — Skill focus','Auto-generated content for lesson '||j||'.', 10 + (j*2)
      );
      -- mark lesson 1 completed for the user
      IF j = 1 THEN
        INSERT INTO lesson_completion ("Id","UserId","LessonId","CompletedAt") VALUES (
          gen_random_uuid(), user_id, lesson_id, now() - (i||' hours')::interval
        );
      END IF;
    END LOOP;

    -- Enrollment for the user
    INSERT INTO enrollment ("Id","UserId","CourseId","Status","EnrolledAt") VALUES (
      gen_random_uuid(), user_id, course_id, 'ACTIVE', now() - (i||' hours')::interval
    );
  END LOOP;
END$$;

COMMIT;
