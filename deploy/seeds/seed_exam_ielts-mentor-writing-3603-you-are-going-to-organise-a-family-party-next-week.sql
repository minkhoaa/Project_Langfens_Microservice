-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:54.825887
-- Source: ielts-mentor.com
-- Title: You Are Going To Organise A Family Party Next Week
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Going To Organise A Family Party Next Week';

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
  E'You Are Going To Organise A Family Party Next Week',
  E'You should spend about\n20\nminutes on this task.\nYou are going to organise a family party next week at your home. You want to invite a friend to this party.\nWrite a letter to your friend inviting him/her to attend the party. In your letter,\nexplain why you are organising the party\ndescribe what you are planning to do\nsay why you want your friend to come to the party\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ....................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Carl,\\nHope all is well at your end with you and your family. I know that you don’t really like to attend any kind of party, but I still took the liberty to invite you to one since it''s going to involve mostly the family members of my extended family. After all, I''m well aware of the fact that you don’t really feel comfortable being around strangers.\\nOh, in case you are wondering, my family has decided to organize this party in order to congratulate my youngest uncle who recently has received his license to practice medicine after struggling for almost two years! This party is going to be more like a casual party, it won’t include too many things except enjoying some freshly-made dinner, and light music, which were especially enjoyed by my uncle when he still was a student.\\nThe party is going to be held on 23rd August, this month, and I''d very much like you to join it since this is going to allow you an opportunity to recuperate from the boredom of some tough engineering lessons and mid-term examinations.\\nWarm regards,\\nMario\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.42 (13 Votes)\\nIELTS Letter Writing\\nAcademic Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
