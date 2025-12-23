-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:01.502528
-- Source: ielts-mentor.com
-- Title: You Are Doing A Diploma Course At A College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Doing A Diploma Course At A College';

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
  E'You Are Doing A Diploma Course At A College',
  E'You should spend about\n20\nminutes on this task.\nYou are currently doing a diploma course at a college, but you need to take a week off during this course.\nWrite a letter to the college Principal.\nIn your letter,\ngive details of your course\nexplain why you need a week off\nsay what you want the Principal to do\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nMy name is James Read, and I am currently attending the hospitality management diploma course as a final year student at your esteemed culinary institute.  I am supposed to finish the course in the next four months if everything goes on schedule.\\nI am writing this letter to request some time off from this course from 14th of August to 20st of August as I need to leave the town for a week in order to take my seriously ill and old aunt to the capital city of our country immediately for better treatment. By the way, my aunt does not have any children or husband who could actually help her during this kind of desperate situation.  Of course, I tried to approach the respectable chairman of my course, but he referred me to you since he does not really have the authority to grant any leave to anyone at this critical and important stage of the course for such a long period.\\nTherefore, I would like to request you to ask the chairman of my course to consider my situation favourably and grant me leave for the stipulated period of time mentioned above. I will be much obliged to your kindness.\\nYours faithfully,\\nJames Read\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (7 Votes)\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
