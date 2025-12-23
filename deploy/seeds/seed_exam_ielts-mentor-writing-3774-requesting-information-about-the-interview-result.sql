-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:39.242321
-- Source: ielts-mentor.com
-- Title: Requesting Information About The Interview Result
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Requesting Information About The Interview Result';

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
  E'Requesting Information About The Interview Result',
  E'You should spend about\n20\nminutes on this task.\nWrite a letter to the manager of the HR department of a company requesting information about the interview that you attended but still waiting for results.\nIn your letter,\ndescribe the position you applied for\nwhy you think the interview went well\nwhy you need the result of the interview\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["]\\nDear Sir or Madam,\\nMy name is Jamie Ferguson, and I am writing this letter to enquire about the status of my job application and interview.\\nI applied for the position of Management Trainee at your company, and my interview took place on 14th March. Unfortunately, I have not got any decision yet from your end, even though I was told that the human resource department would inform me about a hiring decision on me within one week of the interview.\\nI am contacting you also because I thought that I did excellent in the interview. After all, four people quizzed me for almost 30 minutes, and yet, I never stumbled for once. At the end of my interview, they even told me that they were very impressed with my performance.\\nI need to know the result of this interview because I will have to decide on whether or not to renew my apartment lease within the next week or move to another area. If I am selected for the job, I will renew the rental lease.\\nSo, I hope that you understand the urgency of my situation and be kind enough to let me know about a hiring decision on me at your earliest convenience.\\nYours faithfully,\\nJamie Ferguson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.79 (14 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nInquiry Letter\\nOfficial-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
