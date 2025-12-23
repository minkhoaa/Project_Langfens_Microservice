-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:09.687283
-- Source: ielts-mentor.com
-- Title: Thank Friend For Having You At Their House
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Thank Friend For Having You At Their House';

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
  E'Thank Friend For Having You At Their House',
  E'You should spend about\n20\nminutes on this task.\nYou went to another city for a training course and stayed at a friend''s house for a week. They have been great hosts.\nWrite a letter to your friend. In your letter,\nthank them for having you at their house for a week\nexpress your gratitude for their hospitality\nsay how much you miss them\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Robert,\\nHope all is well at your end. I''m also carrying on well with my life and works. Anyway, I just wanted to let you know how grateful and thankful I really am for allowing me to stay at your house for the whole week in order to help me attend the training course in the last month. After all, it would have been really difficult for me to find another suitable place on such short notice since I was informed about the training programme only just a few days before the start of the training.\\nI''m also very much grateful for the kind and generous hospitality that were shown to me by your entire family. I especially enjoyed my afternoon snack time with your whole family after returning from my training. Besides, I also liked how you took me to do fishing at a nearby lake during the weekend while making a video of it. In fact, during that one week of stay at your place, I very much felt like a part of your great family, so no wonder that I miss all of you after leaving your city.\\nPlease send my gratitude to everyone in your family.\\nWarm wishes,\\nThomas\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.75 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nMd. Monjurul Hoque\\n4 years 8 months\\nDear Sir,\\nPlease help me in learning English. My number is +88-01866125967.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
