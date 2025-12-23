-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:02.518670
-- Source: ielts-mentor.com
-- Title: Your Neighbour Often Listens To Loud Music Late At Night
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Neighbour Often Listens To Loud Music Late At Night';

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
  E'Your Neighbour Often Listens To Loud Music Late At Night',
  E'You should spend about\n20\nminutes on this task.\nYour next-door neighbour often listens to loud music late at night. Because of the loud music, you often have problems sleeping.\nWrite a letter to the authority of the building.\nIn your letter,\ndescribe the situation\nexplain the problems it is causing you\npropose a solution to the problem\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI live on the north side of your Daffodil apartment complex, Building 4, flat 5-D, next to the lake, and I am writing this letter to inform you about a problem that I have been facing lately.\\nActually, the issue is that one of my next-door neighbours has been causing this problem by playing loud music till very late at night.  I do not exactly mind this kind of noise once in a while, especially if they are heard during the weekend or holidays. But it has become a cause of concern, to say the least, as it pretty much an every night thing and prevents me from having a good-night sleep. And, as you perhaps know, how sloppy and slow one becomes at work without proper sleep at night. I, of course, have tried to reason with my neighbour on multiple occasions by telling him about my sleep problem, but he just does not seem to care about my concern at all.\\nTherefore, I would like to request you to intervene to solve this problem as a person of authority so that I can have some good sleep, at least, during the weekdays.\\nYours faithfully,\\nJimmy Falon\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.50 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
