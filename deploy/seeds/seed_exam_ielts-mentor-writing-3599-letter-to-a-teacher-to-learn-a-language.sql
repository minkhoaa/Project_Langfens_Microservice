-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:56.753230
-- Source: ielts-mentor.com
-- Title: Letter To A Teacher To Learn A Language
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To A Teacher To Learn A Language';

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
  E'Letter To A Teacher To Learn A Language',
  E'You should spend about\n20\nminutes on this task.\nYou want to learn a language. A teacher who teaches this language lives near the area where you live.\nWrite a letter to the teacher. In your letter,\nsay how you came to know about him/her\nexplain why you want to learn this language\nask what help he/she can offer\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ....................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mrs Ichika,\\nMy name is Fiona Gilbert, and I am writing this letter to you with the hope that I will be able to receive some help from you with regard to learning the Japanese language.  Oh, in case you are wondering, one of my good friends, who helped you find a new place for you to live a few months ago, actually gave me the information about you.\\nI want to learn this language mainly because I am planning to move to Japan after a year to do an internship in Industrial Engineering so that I can get some first-hand experience in the advanced engineering process and technologies.  In fact, doing this internship in Japan will offer me a definite edge over the others as far as getting a better job opportunity in the engineering sector is concerned, especially, in my country.\\nNow, I am aware of the fact that you are probably too busy to help me with the Japanese language, but I would really appreciate some of your precious time per week to learn this language.  Also, please provide me with some specific instructions on how to best master this language easily.\\nI hope to hear a positive reply from you soon.\\nYours sincerely,\\nFiona Gilbert\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.88 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
