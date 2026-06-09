-- ============================================
-- Speaking Exams: seed ImageUrl for all rows
-- Generated: 2026-06-08
--
-- Idempotent UPDATEs — safe to re-run.
-- All URLs point to Cloudinary (consistent with the
-- reading/listening/writing convention).
-- ============================================

BEGIN;

-- Part 1 — Personal questions
UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935695/ielts/speaking/part1-introduce-yourself.png'
 WHERE "Title" = 'Introduce Yourself';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935697/ielts/speaking/part1-family-and-friends.png'
 WHERE "Title" = 'Family and Friends';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935699/ielts/speaking/part1-hometown.png'
 WHERE "Title" = 'Hometown';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935702/ielts/speaking/part1-hobbies.png'
 WHERE "Title" = 'Hobbies';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935704/ielts/speaking/part1-work-or-study.png'
 WHERE "Title" = 'Work or Study';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935706/ielts/speaking/part1-daily-routine.png'
 WHERE "Title" = 'Daily Routine';

-- Part 2 — Cue cards
UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935709/ielts/speaking/part2-describe-friend.png'
 WHERE "Title" = 'Describe a Friend';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935711/ielts/speaking/part2-describe-place.png'
 WHERE "Title" = 'Describe a Place';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935714/ielts/speaking/part2-describe-object.png'
 WHERE "Title" = 'Describe an Object';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935717/ielts/speaking/part2-describe-event.png'
 WHERE "Title" = 'Describe an Event';

-- Part 3 — Discussion
UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935719/ielts/speaking/part3-discuss-technology.png'
 WHERE "Title" = 'Technology';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935785/ielts/speaking/part3-discuss-environment.png'
 WHERE "Title" = 'Environment';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935788/ielts/speaking/part3-discuss-education.png'
 WHERE "Title" = 'Education';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935790/ielts/speaking/part3-discuss-work.png'
 WHERE "Title" = 'Work and Career';

UPDATE speaking_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780935792/ielts/speaking/part3-discuss-tradition.png'
 WHERE "Title" = 'Tradition';

COMMIT;

-- Verification
SELECT "Title", "ImageUrl"
  FROM speaking_exams
 WHERE "ImageUrl" != ''
 ORDER BY "ExamType", "Title";
