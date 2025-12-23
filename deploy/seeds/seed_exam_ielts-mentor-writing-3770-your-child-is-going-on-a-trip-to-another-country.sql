-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:41.746611
-- Source: ielts-mentor.com
-- Title: Your Child Is Going On A Trip To Another Country
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Child Is Going On A Trip To Another Country';

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
  E'Your Child Is Going On A Trip To Another Country',
  E'You should spend about\n20\nminutes on this task.\nYour child is going on a trip to another country for a week. The school authority is looking for some parents who can join the trip. You are interested in going with the children.\nWrite a letter to the head of the school. In your letter,\nsay why you want to join the team\nmention what you can do to assist\nalso ask questions related to the trip\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am the father of one of your students called Terry Anderson, and I am writing this letter to explore the possibility of joining you on a trip to Italy that the school has arranged.\\nI want to accompany your team as it will allow me to visit Italy, which once upon a time used to be the centre of world civilization, and have many attractive places to visit and many exciting activities to participate in. I also want to join the team to have a great time, and that too with my son! Besides, this trip will allow me to see a long-time friend of mine with whom I studied together at a foreign university who is originally from Italy.\\nBy the way, including me in your team would certainly be an advantage because I can speak Italy. I can also free the youngsters from their boredom by sharing some funny and interesting stories with them. Besides, I also know how to prepare some quick snacks in case they go hungry.\\nBut, before I really join you, I have a couple of questions to ask. Will I be allowed to roam around in the city separately with my son? Will there be other staff members with us to help the children?\\nI am looking forward to hearing from you soon.\\nYours faithfully,\\nKeith Anderson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.23 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nKutman\\n2 years 2 months\\nHi Barbie.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
