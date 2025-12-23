-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:48.440815
-- Source: ielts-mentor.com
-- Title: Colleague Lent You Book That Helped Prepare For Presentation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Colleague Lent You Book That Helped Prepare For Presentation';

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
  E'Colleague Lent You Book That Helped Prepare For Presentation',
  E'You should spend about\n20\nminutes on this task.\nA colleague lent you a book that helped you to prepare for a presentation at work.\nWrite an email to your colleague thanking him/her. In the email,\nthank your colleague for lending you the book\nexplain how the book helped you\ntell him/her how the presentation went\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your email as follows:\nDear .........................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Jerry,\\nI hope that you''re in good health and spirit. I just wanted to tell you that I can’t thank you enough for lending me that book to prepare for my presentation, at a time when I thought that I would probably never be able to finish the presentation on time.\\nIf you are wondering how the book helped me, it didn’t only help me in organizing my thoughts on a rather critical subject like “the challenges of a small company in using cutting-edge technologies” and deliver it like a “pro” but also helped me immensely in providing me with the data to support my thoughts, at the end. Besides, the book also provided a great deal of information on how small companies could benefit from the research and development works of large companies – a prospect that our company is currently thinking to explore, in order to save some cost, by forging a partnership with them.\\nIn the end, I must say that my presentation was lauded by everybody who were present there till the end. Some of them even asked me questions to learn more about the subject. So, again, thank you!\\nYours sincerely,\\nJack\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.56 (8 Votes)\\nGT Writing Task 1\\nemail writing\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
