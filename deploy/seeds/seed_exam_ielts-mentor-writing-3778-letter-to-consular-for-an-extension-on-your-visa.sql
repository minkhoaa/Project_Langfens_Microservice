-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:36.716958
-- Source: ielts-mentor.com
-- Title: Letter To Consular For An Extension On Your Visa
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Consular For An Extension On Your Visa';

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
  E'Letter To Consular For An Extension On Your Visa',
  E'You should spend about\n20\nminutes on this task.\nYou have been staying in a foreign country for the last two years, and your visa is about to expire next June. However, you are planning to take a three-months professional course. You will need a visa extension.\nWrite a letter to the consular in the embassy and ask for an extension on your visa.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am an international student in the United Kingdom, and I came on a student visa about two years ago from India. Since then I have been living in this great country and studying to finish my post-graduation degree. If everything goes fine with my studies and according to the schedule, I should be able to complete my degree in Civil Engineering this coming June, which is only a few months away from now. So, no problem there, and I would like to thank you again for that.\\nBut, then, I am also thinking of continuing my education for another three months after finishing my post-graduation degree except, of course, the problem is that my visa is going to expire as soon as I finish my degree. By the way, I want to use these additional three months to pursue a professional diploma course in “AutoCAD” since it very much aligns with my ambition to prepare myself as a fine Engineer.\\nNow that you know why I want to stay another three months in your country, I would highly appreciate it if you grant me a visa extension for that period.\\nYours faithfully,\\nChetan Singh\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.38 (20 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
