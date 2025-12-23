-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:47.918947
-- Source: ielts-mentor.com
-- Title: You Borrowed Something From Friend And It Got Damaged
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Borrowed Something From Friend And It Got Damaged';

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
  E'You Borrowed Something From Friend And It Got Damaged',
  E'You should spend about\n20\nminutes on this task.\nYou have borrowed something from your friend and it has got damaged.\nWrite a letter to a friend. In your letter,\napologize for damaging the product/stuff\nexplain what happened\nsay how are you going to fix the issue\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,\nSample Answer 1:\nDear Wesley,\nHope you are doing fine. I am very contrite to say that the wristwatch I borrowed from you last week got damaged. It was an accident and I am ready to have it repaired from a branded shop.\nI am very sorry for this event and I cannot find words to show how miserable I feel about it. I know this is your favourite watch and a gift from your father.\nLast night I was travelling to my aunt''s house on my motorbike. At one point, while I was crossing the road, an elderly woman who was driving a sedan, opened the car door all of a sudden and that stroke my bike. She profoundly apologised but the damage was already made. I fall off the bike and your watch got damaged. The protection glass screen was smashed and the lug has a few scratches. Fortunately, it is running accurately.\nI would like to take it to the Seiko branded shop to have it fixed. I will bear the expenses and hopefully, you would not be too angry with me after it.\nWarm wishes,\nFranco',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Wesley,\\nHope you are doing fine. I am very contrite to say that the wristwatch I borrowed from you last week got damaged. It was an accident and I am ready to have it repaired from a branded shop.\\nI am very sorry for this event and I cannot find words to show how miserable I feel about it. I know this is your favourite watch and a gift from your father.\\nLast night I was travelling to my aunt''s house on my motorbike. At one point, while I was crossing the road, an elderly woman who was driving a sedan, opened the car door all of a sudden and that stroke my bike. She profoundly apologised but the damage was already made. I fall off the bike and your watch got damaged. The protection glass screen was smashed and the lug has a few scratches. Fortunately, it is running accurately.\\nI would like to take it to the Seiko branded shop to have it fixed. I will bear the expenses and hopefully, you would not be too angry with me after it.\\nWarm wishes,\\nFranco", "Dear Joseph,\\nHope you are doing great and enjoying your life. First of all, let me thank you for allowing me to use your digital blood pressure monitor, which I borrowed from you about a week ago in order to use it to monitor the blood pressure of my grandfather. But, I must apologize to you now because the device, you gave me, has been damaged accidentally.\\nLet me explain to you what actually happened. After using your machine for a few days, I noticed that it was not working properly. So, I checked the battery and found out that the batteries were getting weak. Naturally, I wanted to replace the old batteries with the new ones, and that’s when the machine got slipped out of my hand and fell on the concrete floor. Luckily, the machine was still running, but its display monitor had received a few cracks on it.\\nSo, just give me a few days as I am going to take your machine to a local electronic device repair shop so that I can get it fixed by replacing its display monitor before returning it to you.\\nI hope it would not be a big inconvenience to you.\\nWarm wishes,\\nJessica\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.94 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nShyna\\n6 years 3 months\\nI love this site. It really is helping me to prepare for the exam.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
