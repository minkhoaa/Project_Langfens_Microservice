-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:08.792389
-- Source: ielts-mentor.com
-- Title: Your Friend Recently Had Birthday Celebration
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Friend Recently Had Birthday Celebration';

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
  E'Your Friend Recently Had Birthday Celebration',
  E'You should spend about\n20\nminutes on this task.\nOne of your friends recently had a birthday celebration, but you missed it and you forgot to tell your friend that you couldn''t attend.\nWrite a letter to your friend. In your letter,\napologise for missing the birthday celebration\nexplain why you missed it and why you didn''t tell your friend\nand say what you would like to do to show that you are sorry\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,\nSample\nAnswer 1:\nDear Pollock,\nI''m so sorry that I missed your birthday party and I hope you are not mad at me. I was so excited to have been invited to your birthday and I even had plans for the occasion. But the last moment of emergency compelled me to change my plan. I''m sorry that I even had not informed you.\nI hope you had a grand party on your birthday. I''m so happy to see the fabulous photos on Facebook. I wish I could''ve been there too. But just before your birthday, I got a call that from my hometown and was terribly shocked by the news that my grandfather had a heart attack. I flew to my hometown without any delay and had been there for a couple of days. Fortunately, my grandfather has recovered and is out of danger now.\nI would be terribly busy the whole week in my office due to a missed deadline. Hopefully, I will be at my usual pace within a few days. I would like to meet you at your home and stay at the weekends. I won''t forget your birthday present.\nWarm wishes,\nNickol',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Benjamin,\\nHope you are enjoying your life and your newly-found career. But, before anything else, please allow me to apologize to you first since I couldn’t attend your birthday. Even more frustrating for me is the fact that I couldn’t write to you early enough to tell you why I couldn’t attend your birthday.\\nAnyway, the reason, for which, I couldn’t attend your birthday is that I fell sick with nausea and stomach pain (probably because of some kind of food poisoning) just before the night of your birthday. Then, as soon as I felt little better two days later, I had to travel to another city because one of my foreign bosses arrived in our country, and I needed to accompany him for the next couple of days. So, you can guess how hectic the last few days have really been for me, so much so that I even forgot to write to you earlier and say that I am sorry.\\nAnyway, let bygones be bygones, and please allow me to say \\"Happy Birthday\\" once again. I would also like to take you to the most upscale restaurant in the town and buy you the most expensive and best dish that you have eaten.\\nSee you soon.\\nWarm wishes,\\nBevan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.69 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
