-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:19.004807
-- Source: ielts-mentor.com
-- Title: Your Parents Will Be Celebrating 50Th Anniversary
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Parents Will Be Celebrating 50Th Anniversary';

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
  E'Your Parents Will Be Celebrating 50Th Anniversary',
  E'You should spend about\n20\nminutes on this task.\nYour parents will be celebrating their 50th anniversary next month. You are planning a big celebration, but you are not sure how to make the occasion really memorable. But you have a friend who can help.\nWrite to your friend Julia, who is a professional event planner. In your letter,\nexplain why this occasion is special\nask for her assistance\nset up a time to meet your friend to discuss your plans\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Julia,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Julia,\\nHope you are doing excellent. I am writing this letter because I need some advice from a professional event planner like you. And I need it because my parents are going to celebrate their 50th wedding anniversary soon, and I just don’t have a clue about how to make this occasion a memorable one.\\nBy the way, this 50th anniversary is going to be a special occasion for my parents because they''ve been through a lot of ups and downs in their 50 years of married life, and yet their love for each other seems to be as fresh and deep as the day when they got married. Of course, I''ve plans to buy them some perfect gifts and create a slideshow full of their memories, but I''m not too sure if that’s what will go with the appeal of such a grand occasion. Besides, I''m still undecided where to organise the event, how to decorate the venue and whom to invite.\\nSo, please meet me the day after tomorrow at around 5:30 pm at your office so that I can discuss my plans with you while also borrowing some of your expert ideas to turn this grand event into a successful one.\\nBest wishes,\\nLinda\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.57 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nletter to a friend\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nUmar\\n5 years 3 months\\nIt''s exceeding 150 words, it''s 208 words.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
