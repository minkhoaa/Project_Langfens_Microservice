-- ============================================
-- Exam Service: populate ImageUrl for reading/listening/placement rows
-- Generated: 2026-06-08
--
-- Idempotent UPDATEs — safe to re-run.
-- All URLs point to Cloudinary.
-- ============================================

BEGIN;

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936277/ielts/exams/ielts-listening-practice-1.png'
 WHERE "Slug" = 'ielts-listening-practice-1';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936280/ielts/exams/ielts-reading-practice-1.png'
 WHERE "Slug" = 'ielts-reading-practice-1';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936282/ielts/exams/ielts-mentor-academic-reading-119.png'
 WHERE "Slug" = 'ielts-mentor-ielts-academic-reading-test-119';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936284/ielts/exams/ielts-mentor-nutmeg.png'
 WHERE "Slug" = 'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936286/ielts/exams/ielts-mentor-driverless-cars.png'
 WHERE "Slug" = 'ielts-mentor-reading-test-119-passage-2-driverless-cars';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936288/ielts/exams/ielts-mentor-exploration.png'
 WHERE "Slug" = 'ielts-mentor-reading-test-119-passage-3-what-is-exploration';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936291/ielts/exams/ielts-mentor-roman-ship.png'
 WHERE "Slug" = 'ielts-mentor-reading-test-116-passage-1-roman-shipbuilding-and-navigation';

UPDATE exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780936293/ielts/exams/english-placement-a2-c1.png'
 WHERE "Slug" = 'english-placement-a2-c1-sample-01';

COMMIT;

-- Verification
SELECT "Slug", "ImageUrl"
  FROM exams
 WHERE "ImageUrl" != ''
   AND "Slug" IN (
     'ielts-listening-practice-1',
     'ielts-reading-practice-1',
     'ielts-mentor-ielts-academic-reading-test-119',
     'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice',
     'ielts-mentor-reading-test-119-passage-2-driverless-cars',
     'ielts-mentor-reading-test-119-passage-3-what-is-exploration',
     'ielts-mentor-reading-test-116-passage-1-roman-shipbuilding-and-navigation',
     'english-placement-a2-c1-sample-01'
   )
 ORDER BY "Slug";
