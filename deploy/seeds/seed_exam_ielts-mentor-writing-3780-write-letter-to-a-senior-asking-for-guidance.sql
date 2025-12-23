-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:35.551287
-- Source: ielts-mentor.com
-- Title: Write Letter To A Senior Asking For Guidance
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Letter To A Senior Asking For Guidance';

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
  E'Write Letter To A Senior Asking For Guidance',
  E'You should spend about\n20\nminutes on this task.\nLately, your company has informed you that you will be taking a lead role in an upcoming management project.\nWrite a letter to a senior asking for guidance and request him/her to share his/her experience with you.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Mr/ Mrs .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mrs Lopez,\\nI hope that you are doing well. I also hope that you are not too busy to help me with something really important. I am reaching out to you because I could definitely use some guidance and professional advice from a seasoned professional and executive like you. But, first, let me explain the situation to you.\\nI have recently been offered a leading role as an Assistant Project Manager for our new management project in the downtown area. While I feel quite excited and privileged to have been offered this important role, I am also nervous at the same time. And I am anxious, not because I am not qualified or skilled enough to handle a such big project, but because I have been asked to complete it within a rather impractical deadline, and that too with the help of a rather inexperienced crew of executives and professionals.\\nThankfully, I have learned that you have some solid experience in finishing such projects within very tight deadlines, and it is my wish that you would be kind enough to share those valuable experiences with me to make my job easier.\\nThank you in advance.\\nYours sincerely,\\nShean Lee\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.63 (16 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nOfficial-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nNguyễn Uyên\\n2 years 4 months\\nI have a new house.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
