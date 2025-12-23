-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:15.001695
-- Source: ielts-mentor.com
-- Title: You Want To Apply To Private College Seeking Admission
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Want To Apply To Private College Seeking Admission';

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
  E'You Want To Apply To Private College Seeking Admission',
  E'You should spend about\n20\nminutes on this task.\nYou want to apply to a private college seeking admission for a bachelor degree. You are experiencing financial problems at the moment and can not get admitted to the college without some help.\nWrite a letter to the Principal of the college explaining your situation and ask for information on scholarships or other means of financial help available.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Jonathon Mitch, and I am writing this letter in order to receive some necessary information regarding scholarships and tuition subsidies - aimed at helping undergraduate students financially, which is offered by your college. I have recently graduated from high school with a GPA of 3.85 on a scale of 4, and I want to apply to get admitted to your college to continue my study for a Bachelor degree.\\nI need this information because my family is currently suffering from some economic hardship. They will not be able to pay me for my educational expenses since my father, the only income-earning member of my family, has got laid off from his job very recently. Besides, as a low middle-income family, we do not have any kind of savings which would help me meet all of my educational expenses at a prestigious private college like yours without some sort of financial help. So I am hoping for your kind consideration and help.\\nI would like to thank you for your time and consideration in advance.\\nYours faithfully,\\nJonathon Mitch\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.18 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
