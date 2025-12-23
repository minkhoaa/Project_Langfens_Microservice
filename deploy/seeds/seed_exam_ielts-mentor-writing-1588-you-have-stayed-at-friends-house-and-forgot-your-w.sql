-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:55.421868
-- Source: ielts-mentor.com
-- Title: You Have Stayed At Friends House And Forgot Your Watch
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Stayed At Friends House And Forgot Your Watch';

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
  E'You Have Stayed At Friends House And Forgot Your Watch',
  E'You should spend about\n20\nminutes on this task.\nYou have stayed at a friend’s house last weekend and forgot your watch there.\nWrite a letter to this friend. In your letter,\nthank him/her for the hospitality\ndescribe your watch and say where you could have left it\nsuggest a way how to get it back\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,\nSample Answer 1:\nDear Harish,\nI hope this letter finds you in good health. I would like to take this opportunity to express my gratitude for my stay at your home in Adelaide last weekend. I had a pleasant time over there and I can not thank you enough for the genuine hospitality you have offered me.\nAdelaide is an interesting place for shopping and a diverse range of shopping malls are located there. I bought a brand new Rolex wristwatch for my wife from Rundle street shopping centre keeping her approaching birthday in mind. I was actually tempted by the fascinating brown colour strap and square-shaped dial. The dial has roman numbers too. I am very excited about it.\nUnfortunately, I couldn’t find it in my luggage when I got back to Sydney. I remember keeping it in your living room- probably in a drawer of the large table. I want to gift it to my wife on her birthday next week and surprise her. However, this can be possible only if you take the burden to send it to my address.\nActually, James Brown - one of my colleagues, is travelling to Sydney from your place this weekend. I can request him to collect it from your house. He lives just a couple of miles away from your apartment. I will pass your address and contact number to him. I think you can hand it over to him without any trouble.\nI hope to see you soon in Sydney.\nWarm wishes,\nNavaretta\n[ Written by Ramesh ]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Harish,\\nI hope this letter finds you in good health. I would like to take this opportunity to express my gratitude for my stay at your home in Adelaide last weekend. I had a pleasant time over there and I can not thank you enough for the genuine hospitality you have offered me.\\nAdelaide is an interesting place for shopping and a diverse range of shopping malls are located there. I bought a brand new Rolex wristwatch for my wife from Rundle street shopping centre keeping her approaching birthday in mind. I was actually tempted by the fascinating brown colour strap and square-shaped dial. The dial has roman numbers too. I am very excited about it.\\nUnfortunately, I couldn’t find it in my luggage when I got back to Sydney. I remember keeping it in your living room- probably in a drawer of the large table. I want to gift it to my wife on her birthday next week and surprise her. However, this can be possible only if you take the burden to send it to my address.\\nActually, James Brown - one of my colleagues, is travelling to Sydney from your place this weekend. I can request him to collect it from your house. He lives just a couple of miles away from your apartment. I will pass your address and contact number to him. I think you can hand it over to him without any trouble.\\nI hope to see you soon in Sydney.\\nWarm wishes,\\nNavaretta\\n[", "Dear Dylan,\\nHope you are fine and enjoying the spring. I would like to thank you for a great weekend at your house. It was so exciting that I will always be grateful to you for being such a great host. I hope you can visit us soon with your wife and son and I look forward to spending some quality time together.\\nWhen I got back home, I noticed that I forgot my watch at your house. My best guess is that I have left it in the bathroom. Before leaving your house I took a shower and presumably that is the time when I left it there. It is a Seiko (Japan) Automatic diver''s analogue watch for men that comes with a circular dial. The strap and dial of the watch are black while the lug, buckle and bezel are silver. I am sure you will recognise it as soon as you see it.\\nI hope it would not be a trouble for you to send it to me. I really like this wristwatch and it was a gift from Maria. She would be disappointed if I lose it. Please send it via a courier service to my home address and I will bear the courier cost.\\nWish to see you all soon.\\nWarm wishes,\\nPeter\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.58 (6 Votes)\\nIELTS Letter Writing\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
