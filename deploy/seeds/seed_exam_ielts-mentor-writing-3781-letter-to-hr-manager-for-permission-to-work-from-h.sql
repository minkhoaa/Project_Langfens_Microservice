-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:34.897957
-- Source: ielts-mentor.com
-- Title: Letter To Hr Manager For Permission To Work From Home
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Hr Manager For Permission To Work From Home';

-- Insert into writing_exams table
INSERT INTO "writing_exams" (
  "Id",
  "Title", 
  "TaskText",
  "ExamType",
  "Level",
  "Tags",
  "ModelAnswers",
  "CreatedAt",
  "CreatedBy"
)
VALUES (
  gen_random_uuid(),
  E'Letter To Hr Manager For Permission To Work From Home',
  E'You should spend about\n20\nminutes on this task.\nYour employer has recently allowed some employees to work remotely from home. You would also like to work from home.\nWrite a letter to the HR manager for permission to work from home for the next six months. In your letter,\nmention why you are writing\nexplain why you would like to work from home\nsay how this can benefit you and the company\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...........................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Brook,\\nI am writing this letter to seek your permission to avail the “work from home” facility for the next six months starting from the beginning of the next month. I am hoping that you would consider my request and permit me to work from home.\\nAnd I am dubbing this a “great opportunity” because it would definitely help me save a lot of time that is wasted commuting to and from the office, especially, when I live a bit too far from my office due to some family reasons. Moreover, less time in road traffic could also mean less stress, and when we have more time to finish our work and less stress, we are usually more productive at work.\\nThis arrangement would benefit both me and the office as I would be able to work more hours per week to finish the deadlines.\\nI am hoping that you would agree to let me work from home for the next six months starting from 1st February.\\nThank you in advance.\\nYours sincerely,\\nJohn Blair\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.42 (30 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nOfficial-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
