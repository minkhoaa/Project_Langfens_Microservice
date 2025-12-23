-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:58.331078
-- Source: ielts-mentor.com
-- Title: You Are Planning A Holiday Abroad
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Planning A Holiday Abroad';

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
  E'You Are Planning A Holiday Abroad',
  E'You should spend about\n20\nminutes on this task.\nYou are planning a holiday abroad and will be visiting a town where an old friend lives. You haven''t spoken to this friend in a few years.\nWrite a letter to your friend. In your letter,\ngive a brief update of your life since you were last in touch\nexplain why you will be travelling to his/her town\nsay what you plan to do when you visit his/her town\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Russel,\\nNot sure exactly when I heard from you the last time, but it must have been at least a few years since we spoke to each other. You''d be glad to know that I''ve switched to a different job as a Senior Accounting Manager which actually allows me to roam around different places instead of doing something just by sitting at a desk.  Besides, I also run a small café now during the weekend, right across the market near the new stadium, which you saw being built last time you visited me.\\nNow about the reason why I am exactly writing to you.  Actually, I will be visiting your town early next month to help my youngest uncle move with all of his stuff because he got a new job there. Oh, I hope that you can still remember my youngest uncle with some “limited mobility” issue.\\nHowever, when I visit your town, I''d also like to enjoy that famous horse race which takes place every year.  Besides, I would also like for you to take me to the open street market while I''m there.  So, hope to see you soon!\\nWarm wishes,\\nDavid\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.07 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
