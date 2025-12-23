-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:50.037482
-- Source: ielts-mentor.com
-- Title: Write Letter To The Manager Of The Sports Centre
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Letter To The Manager Of The Sports Centre';

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
  E'Write Letter To The Manager Of The Sports Centre',
  E'You should spend about\n20\nminutes on this task.\nYou visit a sports centre regularly, and there is a problem with the changing rooms in it. You have complained about it several times but with no success.\nWrite a letter to the manager of the sports centre. In your letter,\ndescribe what the problem with the changing rooms is\nsay what happened the last time you complained\nexplain what you want the manager to do\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nIn recent weeks, we have found some issues with your otherwise well-managed sports centre, and I just thought that it was the time to bring those problems to your attention to ensure the reputation of your famous sports centre and the comfort of its users.\\nNow, let me explain the issues one by one. The first issue is that some of the doors of the changing rooms do not lock properly - probably because the lock systems have worn out or become old due to excessive use. Another problem is that sometimes, a foul smell hits us as soon as we enter those rooms either because they are not cleaned properly or do not get properly “deodorized”.\\nOf course, I have already complained to the supervisor, in charge of the maintenance of your sports centre, a couple of times, but it looks like the issues have not exactly been addressed or solved. The last time I complained to him was two months ago, and despite his promise to fix the issues, nothing significant has been done.\\nTherefore, I would appreciate it if you take the necessary steps to solve the problems, mentioned above, at your earliest convenience so that we all can get back to enjoying our time at your establishment, again, like we always did in the past.\\nYours faithfully,\\nMiranda Blake\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.46 (13 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
