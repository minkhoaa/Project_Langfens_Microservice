-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:38.722106
-- Source: ielts-mentor.com
-- Title: Friend Wants To Get Information About An Elementary School
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Friend Wants To Get Information About An Elementary School';

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
  E'Friend Wants To Get Information About An Elementary School',
  E'You should spend about\n20\nminutes on this task.\nA friend wants to get some information about an elementary school where one of your cousins studies.\nWrite a letter to this friend. In your letter,\nsay why this school is a good elementary school\nmention how expensive it is\nexplain why your friend should get his/her child admitted there\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Bob,\\nI understand how challenging it can become to choose a good elementary school for our children these days. So, here, as you requested, I''ll try to provide some information on the elementary school, attended by my younger cousin, but please verify all the information before making a final decision.\\nThe school, attended by my cousin, has a good reputation for grooming the little ones by providing them with a “semi-structured” learning environment where they can learn and say anything they wish. The school also has several great “after school” programmes, through which the children don’t only have fun, but also learn many important and practical things. But, the best part is, they don’t have any homework – something that your child is certainly going to enjoy! In other words, they learn everything at their school! And all these come at a rather reasonable price, in comparison with the other schools.\\nSo, I think that you should get your child admitted there because he is not only going to enjoy learning there, but also he is going to do so at his own pace without any burden of extra study work at home.\\nWarm wishes,\\nJennifer\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.83 (12 Votes)\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nInformative-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
