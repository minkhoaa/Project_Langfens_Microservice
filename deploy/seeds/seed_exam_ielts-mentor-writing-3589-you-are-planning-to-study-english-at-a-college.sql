-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:59.927226
-- Source: ielts-mentor.com
-- Title: You Are Planning To Study English At A College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Planning To Study English At A College';

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
  E'You Are Planning To Study English At A College',
  E'You should spend about\n20\nminutes on this task.\nYou are planning to study English at a college in an English-speaking country. You would like some information about their courses.\nWrite a letter to the college.\nIn your letter,\nask about the course they offer\nask about the cost of the course\nsay what kind of accommodation you want in the college hostel\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nMy name is Rubio Gonzalez, and I am writing this letter to explore the possibility of studying the English language at a prestigious college like yours.  Of course, before that can actually happen, I would need some information so that I can make an informed decision.\\nThe first thing, which I would like to know, is, what kinds of courses your college offers, as well as the duration of those courses, since I am particularly interested in pursuing a degree in the “English as a second language” programme.  By the way, I want to pursue this particular course since I believe that I already have a strong foundation in this international language. Besides, I believe that it will help me in my future career.\\nI would also love to know about the cost structures for this course, as well as other related expenses, to complete this course in due time.  And information regarding scholarships, grants and tuition subsidies for international students would also be highly appreciated.\\nFinally, it is also important to note that should I choose to pursue the course, I would prefer to use a single room occupancy at your college hostel.\\nThank you in advance.\\nYours faithfully,\\nRubio Gonzalez\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.05 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nInquiry Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
