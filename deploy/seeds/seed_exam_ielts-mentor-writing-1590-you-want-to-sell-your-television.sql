-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:54.429488
-- Source: ielts-mentor.com
-- Title: You Want To Sell Your Television
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Want To Sell Your Television';

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
  E'You Want To Sell Your Television',
  E'You should spend about\n20\nminutes on this task.\nYou want to sell your television. You think a friend of yours might like to buy it from you.\nWrite a letter to your friend. In your letter, explain -\nwhy you are selling the television\ndescribe the television\nsuggest a date when your friend can come and see it\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Rabbi,\\nHope you are doing well. I have recently got a job offer in New York and I am excited about it. I am planning to leave next month and would like to meet you sometime before my departure. I have decided not to ship my furniture to my destination. Instead, I want to sell them off. I think you might be interested to purchase my smart TV.\\nThe TV I own is an ultra-slim Samsung LED television and I purchased it around 6 months ago. It still has a warranty for 1 and a half years. I brought it from a branded Samsung showroom and it is a 43 inch Android TV. The outstanding features of this TV are 3-Dimensional view (3D), smart internet connection, latest Android OS, 256 GB internal memory, 10 years picture panel warranty and voice activation.\\nI believe you would be interested to have this TV, however, I advise you to have a clear demonstration of the functional and operational procedures of it. you can come to check it out next weekend, Saturday, 28th March. We can also negotiate the price at the same time.\\nKindly reply to me with your thoughts on buying this television.\\nHope to hear from you soon.\\nWarm wishes,\\nRamesh Roy\\n[", "Dear Alfred,\\nI hope you are doing great. It''s been a while since we have last met. Hope you are enjoying your new job. I am writing today regarding a television set that I want to sell and I think you might be interested to own it.\\nI am excited to tell you that I have been accepted to join the University of Berkshire for the Masters in Business program. Hopefully, I will be leaving for the UK next month. Since I will be living in the UK for the next 3 years, I am hoping to sell all my belongings that I will not be able to take with me. My one such possession is a TV set. It is a 40 inch Sony Smart TV with the Android operating system, and it is equipped with Wi-Fi and many other rich features such as the 3D view and surround sound system. I am willing to sell it to you at a cheap price as a token of my gratitude for your loyal friendship.\\nAs I will be departing from Lahore on 10th July, I hope you can drop by on 1st July and see the TV to figure out whether you want to buy it or not.\\nHoping to see you soon.\\nWarm wishes,\\nSam\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
