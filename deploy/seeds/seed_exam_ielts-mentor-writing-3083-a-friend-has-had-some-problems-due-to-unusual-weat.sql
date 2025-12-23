-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:51.712211
-- Source: ielts-mentor.com
-- Title: A Friend Has Had Some Problems Due To Unusual Weather
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'A Friend Has Had Some Problems Due To Unusual Weather';

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
  E'A Friend Has Had Some Problems Due To Unusual Weather',
  E'You should spend about\n20\nminutes on this task.\nYou have recently heard that a friend of yours has had some problems as a result of some unusual weather.\nWrite a letter to your friend. In your letter:\n-  express your concern\n(i.e. say you are sorry to hear what has happened)\n-  tell him/her about a similar experience that you once had\n-  give some advice, or offer help\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,\nSample Answer 1:\nDear Rachel,\nI''m horrified to learn from your letter about the storm that hit your city recently. I''m so sorry that it even damaged your house. How awful to come home from a holiday with your child to find the damaged house! I wish it did never happen.\nI understand how you must feel, as I had a similar experience a few years ago when a sudden storm hit our city. I came home from a trip to find that the windows of the house were broken and the rainwater had damaged my floor and the carpet. It was very upsetting and I had to spend a large sum of money to replace the window glasses and to buy a new carpet.\nIf I can do anything for you I’d be happy to help. I can come over the weekend and help you in any way possible. Please don''t be upset by the event as you had nothing to do about it. Better concentrate on getting the insurance money and redecorate the house.\nSee you soon. Take care.\nBest wishes,\nSophia',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Rachel,\\nI''m horrified to learn from your letter about the storm that hit your city recently. I''m so sorry that it even damaged your house. How awful to come home from a holiday with your child to find the damaged house! I wish it did never happen.\\nI understand how you must feel, as I had a similar experience a few years ago when a sudden storm hit our city. I came home from a trip to find that the windows of the house were broken and the rainwater had damaged my floor and the carpet. It was very upsetting and I had to spend a large sum of money to replace the window glasses and to buy a new carpet.\\nIf I can do anything for you I’d be happy to help. I can come over the weekend and help you in any way possible. Please don''t be upset by the event as you had nothing to do about it. Better concentrate on getting the insurance money and redecorate the house.\\nSee you soon. Take care.\\nBest wishes,\\nSophia", "Dear Edward,\\nI am so sorry to learn from my cousin that your house has been badly damaged by the recent flash flood due to some sudden and excessive rain in your area. To be honest, I have never really heard of this kind of unusual weather before, especially, in the part of our country where you live.\\nAnyway, I thought that only the area, in which I live now, is susceptive to such unusual weather since it is a rather low-lying land. In fact, I also faced a similar kind of situation about 5 years ago when the river, surrounding my town, suddenly had swollen because of some excessive rain and caused a flood in a significant part of our town, including my own house. Of course, the flood water had disappeared as suddenly and quickly just as it had arrived, but enough damage to my house was already done.\\nSo, don’t worry as you will soon get over with this shock just as I did during my crisis. Also, try to remain as positive as possible and think that you still have a house left that can be fixed sooner or later. Moreover, if you need any help, please do not hesitate to ask me.\\nWarm wishes,\\nJulian Anderson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.78 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSiddharth Kumar\\n5 years 5 months\\nLetter.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
