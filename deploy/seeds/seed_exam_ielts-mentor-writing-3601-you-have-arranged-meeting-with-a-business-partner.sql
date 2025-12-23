-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:55.734098
-- Source: ielts-mentor.com
-- Title: You Have Arranged Meeting With A Business Partner
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Arranged Meeting With A Business Partner';

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
  E'You Have Arranged Meeting With A Business Partner',
  E'You should spend about\n20\nminutes on this task.\nYou have arranged a meeting with a business partner. Unfortunately, you have to change the arrangement.\nWrite a letter to your business partner. In your letter,\napologise for the changes\nexplain the reason why the changes were needed\nexplain the new arrangement\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ....................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Martin,\\nI hope this letter finds you in good health and spirit. I am writing this letter to offer you a formal apology since I will have to postpone the upcoming business meeting between us which is set for 14th of March. I know that the news of this meeting deferment would probably upset you a little but once I explain the situation to you, you would understand as to why I exactly need to postpone this important business meeting.\\nOn 14th March, the day when we were supposed to have the meeting, my young nephew is going to play for his high school team for the first time in an inter-district soccer tournament match, and I have been asked by my beloved nephew to watch the game live from the stadium. Besides, I also did not want to miss the special moment since it was I who initially taught him how to play soccer.\\nSo, now that you know the reason behind the postponement of the meeting, could we please perhaps hold the meeting a day later on the 15th of March so that I could enjoy some special family time with my nephew?\\nI hope to meet you soon.\\nYours truly,\\nMilan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.54 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nIELTS Apology Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
