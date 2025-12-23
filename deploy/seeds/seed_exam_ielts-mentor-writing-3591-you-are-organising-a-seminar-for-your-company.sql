-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:58.764743
-- Source: ielts-mentor.com
-- Title: You Are Organising A Seminar For Your Company
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Organising A Seminar For Your Company';

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
  E'You Are Organising A Seminar For Your Company',
  E'You should spend about\n20\nminutes on this task.\nYou are organising a seminar for your company. Write a letter to the manager of another department inviting them to give a presentation at the seminar.\nIn your letter,\ngive details of the seminar\ninvite them to give a presentation and say why you are inviting them\nsay what the presentation should be about\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Larry,\\nI hope I have not caught you at a busy and critical time.  Anyway, the reason, for which, I am writing this letter to you is that I am going to organize a seminar on “how to maintain a strict quality assurance policy” after a week, and I would very much like you and your team members from “procurement department” to give a presentation.\\nAfter all, we all in our company know how successful your department has been over the years in procuring the best quality raw materials for our company, and your inputs on how to maintain the best temperatures at our warehouses, where we stock our products, and how to pack them properly, especially during the rainy seasons, would certainly benefit our “production department” and company immensely.  In essence, your experience and thoughts in the seminar would go a long way to help us deliver the best quality products to our customers.\\nBy the way, the seminar will be conducted from 3:00 pm to 5:00 pm on Tuesday, which is 11th of December, and we surely would appreciate it if you oblige us with your valuable presence there in that seminar.\\nYours sincerely,\\nChaminda Charles\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.19 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
