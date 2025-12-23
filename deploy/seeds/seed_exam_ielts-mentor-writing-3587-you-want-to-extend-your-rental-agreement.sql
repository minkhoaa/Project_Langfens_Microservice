-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:01.015730
-- Source: ielts-mentor.com
-- Title: You Want To Extend Your Rental Agreement
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Want To Extend Your Rental Agreement';

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
  E'You Want To Extend Your Rental Agreement',
  E'You should spend about\n20\nminutes on this task.\nYou have been living in a rented apartment for the last two years. Your rental agreement will expire in two months, but you want to extend it for another two years.\nWrite a letter to the agency.\nIn your letter,\nintroduce yourself\nsay why you want to extend the contract\nmention what changes you would recommend in the contract\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nMy name is Andy Fowler, and I live in an apartment in the south block of the Stavrolia Apartment complex, operated by your agency.  And the reason, for which, I am writing this letter to you is that I want to renew the rental agreement for another two years since my current lease agreement is about to expire in the next couple of months.\\nI have been living in this apartment complex for the last two years, and my entire family have enjoyed living here since the day we arrived here because it is a nice neighbourhood.  But, the main reason, for which, I want to renew my rental agreement is that a major highway has recently been built, close to this apartment complex, which cuts my commuting time to work to almost half.\\nBy the way, I would also like to include a new term in the contract which should say that I will not be using the laundry facility of this apartment complex since I have got my own laundry machine now.  So please deduct this service cost from my monthly charges.\\nI would like to request that please renew my lease agreement for another two years with the new term in it at your earliest convenience.\\nYours faithfully,\\nAndy Fowler\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
