-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:16.486907
-- Source: ielts-mentor.com
-- Title: You Have Seen An Advertisement For A Community College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Seen An Advertisement For A Community College';

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
  E'You Have Seen An Advertisement For A Community College',
  E'You should spend about\n20\nminutes on this task.\nYou have seen an advertisement for a community college that needs teachers for night classes.\nWrite a letter to the community college. In your letter,\nsay why you are writing\ndescribe your interest to work as an English teacher\nexplain why you would be a suitable teacher for that community college\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing this letter to express my interest to work as an English teacher at your community college on the night shift. I am applying for this post in response to an advertisement which was published in a local daily newspaper a couple of days ago.\\nI have been looking for this kind of opportunity for a long time to teach English, but, because of my day-time job, I have not been able to do it so far. Now that you are offering such an opportunity, I want to grab it with my two hands, not only to teach the arts of English communication to the students but also to contribute to a good cause.\\nIn support of my eligibility to teach English at your college, I have completed a Bachelor degree in Education, and I have a short certification course on \\"Grammar, Vocabulary and Accent Training\\". Besides, I have also done some home tutoring in English teaching for young children before.\\nI am confident that I will be able to do a fine job of teaching English at your college, only if you give me a chance.\\nYours faithfully,\\nJamie Bower\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.56 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
