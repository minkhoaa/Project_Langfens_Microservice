-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:19.909194
-- Source: ielts-mentor.com
-- Title: Friend Has Asked For Advice About A Problem At Work
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Friend Has Asked For Advice About A Problem At Work';

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
  E'Friend Has Asked For Advice About A Problem At Work',
  E'You should spend about\n20\nminutes on this task.\nA friend of yours has recently written to you asking for advice about a problem at work. You have had a similar problem at your workplace in the past.\nWrite a letter to your friend. In your letter,\ntell your friend how you feel about the problem\nexplain how you faced a similar situation in the past\nsuggest possible solutions to the problem\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sam,\\nHope you''re doing great. I''ve got your recent letter and learned about the problem, which you seem to be currently facing at your work. Of course, I feel a bit frustrated about this issue of yours, but please understand that this kind of problem is not very unique.\\nIn fact, I also had to deal with this type of problem about a couple of years ago when I was also asked to visit our manufacturing plant to train some junior staff members in a different city almost every other day, even though it was never a part of my job description. But, I kept doing it as long as I could, but then went on to prove to my upper management how the quality of my regular tasks was being affected rather negatively as I was getting a bit too tired of the long travel to finish my regular tasks on time.\\nLuckily, the upper management understood my problem as I spoke to them very candidly. I suggest, you also talk to your superior about your problem with some facts, and I''m sure that they will listen.\\nWishing you all the best. Take care.\\nWarm wishes,\\nGregory\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.36 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
