-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:49.403960
-- Source: ielts-mentor.com
-- Title: You Would Like Job Working In Summer Camp
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Would Like Job Working In Summer Camp';

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
  E'You Would Like Job Working In Summer Camp',
  E'You should spend about\n20\nminutes on this task.\nYou would like a job working in the summer camp which runs sports and outdoor activities for children and young people.\nWrite a letter to the organisers of the summer camp. In your letter,\nexplain what sort of work you would like to do\ndescribe your personality\nsay what relevant experience and skills you have\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI have recently found out about your desire to hire someone at the summer camp to help children and young people. I just thought that I should apply for this job and gain some rewarding experience this summer.\\nI am applying to work as a “Camp Leader” at your summer camp, and I am confident that I have the required qualifications, credentials and skills to supervise the children and young people and keep them happy and safe, while also coordinating all of their activities and developing new programmes for them at the same time.\\nIn the past, I worked with a large group of children at a local children’s club where I successfully helped them in developing new skills and hobbies. Besides, I also have experience working as a part-time physical instructor at an elementary school in my hometown. And as far as my personality is concerned, I am fairly healthy and energetic, passionate about my responsibilities, and I never lose my patience that easily.\\nSo, please consider me for the position of ''camp leader'' at your summer camp and see the difference I make with your children and youth.\\nI would be glad to hear a positive reply from you.\\nYours faithfully,\\nJames Cullen\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.89 (14 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\njob application\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
