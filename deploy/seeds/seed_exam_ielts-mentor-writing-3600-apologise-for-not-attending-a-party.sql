-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:56.267045
-- Source: ielts-mentor.com
-- Title: Apologise For Not Attending A Party
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Apologise For Not Attending A Party';

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
  E'Apologise For Not Attending A Party',
  E'You should spend about\n20\nminutes on this task.\nA friend of yours invited you to a home party he/she arranged. However, you have just missed this party. Now you want to apologise for not attending it.\nWrite a letter to your friend to apologise. In your letter,\napologise to your friend\nexplain why you did not attend the party\nsay what you plan to do to make up for missing the party\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ....................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Graham,\\nHope all is well at your end.  But, before anything else, please let me apologise to you because I couldn’t attend the party, which you organised about a week ago, despite my best efforts and intention.\\nAnd the reason, for which I missed your party, is that I needed to travel out of town the day before I was supposed to attend your party because I needed to spend some time in the company of my youngest uncle.  By the way, this uncle of mine, living and working abroad, has arrived in the country very recently rather unexpectedly on a short trip, and he had requested me to accompany him as well as do some choirs before he departed the town.  I thought that I still could make it to your party but things got a bit too hectic on my end as I was trying to help my uncle with his travel and choirs.\\nBut, of course, I''m free now.  So, how about going camping and fishing this coming weekend, together?  I''m sure, it is going to be just as fun as before.\\nBest regards,\\nMike\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.88 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
