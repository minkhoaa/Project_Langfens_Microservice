-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:54.285141
-- Source: ielts-mentor.com
-- Title: You And Your Friends Want To Start A Weekly Dance Club
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You And Your Friends Want To Start A Weekly Dance Club';

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
  E'You And Your Friends Want To Start A Weekly Dance Club',
  E'You should spend about\n20\nminutes on this task.\nYou and some of your friends want to start a weekly dance club, and you have found a hall that would be suitable to hold your meetings.\nWrite a letter to the owner of the hall. In your letter,\nexplain the dance project\nask if it is possible to rent the hall and under what terms\nstate what day and times you would like to use the hall\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nMy name is Mike Gregory and I am writing this letter to enquire about the possibility of renting your hall for the purpose of holding some meetings for our dance club.\\nWe will hold these meetings mainly to discuss a dance project that we want to successfully complete before the arrival of our national youth day so that the young artists, taking part in this dance project, can learn about their individual roles and responsibilities in the project. Again, please do not think that we want to rent your hall to actually practice dancing, rather we want it only to discuss how best we can organize and complete our upcoming dance project. By the way, we would like to use it only during the weekends from 5:00 pm to 9:00 pm for about 6 continuous weeks, and the meetings will be attended by about 15 to 20 people, each time.\\nSo, based on the information above, I was just wondering if you could rent us the hall, and should you choose to do so, please specify the terms and conditions upon which we both can agree.\\nYours faithfully,\\nMike Gregory\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.21 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
