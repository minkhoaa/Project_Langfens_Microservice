-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:18.444532
-- Source: ielts-mentor.com
-- Title: You Are Planning Surprise Birthday Party For A Friend
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Planning Surprise Birthday Party For A Friend';

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
  E'You Are Planning Surprise Birthday Party For A Friend',
  E'You should spend about\n20\nminutes on this task.\nYou are studying English at a private language school attended by many international students. You are planning a surprise birthday party for a friend who has been feeling particularly sad and homesick.\nWrite to another classmate and invite him/her to the party. In your letter:\nexplain the reason for the party\ngive the date and time of the party\nsuggest what the classmate could bring to the party\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Tim,\\nHow are you? Hope you''re enjoying the English lessons at the language school. Anyway, not sure if you''re aware of it, but our good classmate, Robin, from Turkey is going to have his 19th birthday next Friday, which falls on the 25th of September, and I''ve made a plan to make it a surprise birthday party just after our English language class.\\nBy the way, in case you haven’t noticed, currently, Robin is going through a rough time since he is feeling a bit more homesick than usual. Besides, he''s also struggling a lot to get used to this new culture of a foreign country. On top of that, the news of his little sister’s sickness has also made him depressed. In this kind of situation, giving him a big surprise on his birthday would certainly cheer him up.\\nAnyway, I already have a plan about who should bring what to the party. Timothy and Kelly should bring their specially-made flower cake while Johnson should bring his guitar to play his special tune.  As for you and me, we will bring the candles to decorate the cake and the banners to decorate the room.\\nLet''s have a great party to cheer Robin up!\\nWarm wishes,\\nJustin\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.23 (15 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nQ\\n4 years 1 month\\nDear Q,\\nSmile everyday!\\nReply\\nQuote\\nSara\\n5 years 6 months\\nDear Elizabeth,\\nHope you are doing great. I am writing this letter because I need your help in organizing a surprise birthday party for Amy. Lately, she has been complaining about how much she misses her parents and siblings, and her personality has changed drastically over the last few weeks! She became withdrawn and I often see her crying. So I thought we might arrange something to cheer her up and lift her spirit.\\nI have learned from her Facebook account that her birthday is on the first of July, that is about two weeks from now. I think we could arrange a surprise birthday party for her in the \\"Olive Gardens\\" restaurant as we have been there once and she admired the place. I would like to book a lunch reservation there for five to six persons. I would bear the cost and I would expect you to bring any kind of gifts to cheer Amy up.\\nSo, I think you could help me choose a gift for her as I am not sure what to buy. Please also bring a birthday card for Amy and if possible, talk to Jessica and Mark to join us. I am sure Amy will love it all.\\nAnyway, please give me a call or send me a message on Facebook. Take care,\\nWarm wishes,\\nMaria\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
