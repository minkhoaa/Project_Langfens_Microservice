-- ============================================
-- Writing Exams: populate ImageUrl for Task 1 rows
-- Generated: 2026-06-08
--
-- Idempotent UPDATEs — safe to re-run.
-- Path is relative; the Next.js frontend serves
-- langfens-fe-app/public/ as the document root, so
-- "/writing-images/<file>.png" resolves to
-- http://<fe-host>/writing-images/<file>.png.
-- ============================================

BEGIN;

-- Academic Task 1: bar chart
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910909/ielts/writing-task1/task1-academic-bar-chart-population-by-age.png'
 WHERE "Slug" = 'task1-academic-bar-chart-population-by-age';

-- Academic Task 1: line graph
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910912/ielts/writing-task1/task1-academic-line-graph-internet-users.png'
 WHERE "Slug" = 'task1-academic-line-graph-internet-users';

-- Academic Task 1: pie chart
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910914/ielts/writing-task1/task1-academic-pie-chart-energy-sources.png'
 WHERE "Slug" = 'task1-academic-pie-chart-energy-sources';

-- Academic Task 1: process diagram (fetched from ielts-mentor.com)
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910917/ielts/writing-task1/task1-academic-process-bottle-recycling.png'
 WHERE "Slug" = 'task1-academic-process-bottle-recycling';

-- GT Task 1: letter — complaint
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910919/ielts/writing-task1/task1-gt-letter-complaint-noisy-neighbour.png'
 WHERE "Slug" = 'task1-gt-letter-complaint-noisy-neighbour';

-- GT Task 1: letter — job application
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910921/ielts/writing-task1/task1-gt-letter-job-application-receptionist.png'
 WHERE "Slug" = 'task1-gt-letter-job-application-receptionist';

-- GT Task 1: letter — ielts-mentor (marriage ceremony)
UPDATE writing_exams
   SET "ImageUrl" = 'https://res.cloudinary.com/df41zs8il/image/upload/v1780910922/ielts/writing-task1/ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o.png'
 WHERE "Slug" = 'ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o';

COMMIT;

-- Verification
SELECT "Slug", "ImageUrl" IS NOT NULL AND length("ImageUrl") > 0 AS has_image, "ImageUrl"
  FROM writing_exams
 WHERE "ExamType" = 1
 ORDER BY "Slug";
