-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:44.361877
-- Source: ielts-mentor.com
-- Title: Write Letter To Course Instructor
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Letter To Course Instructor';

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
  E'Write Letter To Course Instructor',
  E'You should spend about\n20\nminutes on this task.\nYou are doing a three-months'' course at a training institute. You have recently been offered a full-time job at a company and you can not continue the course.\nWrite a letter to the course instructor. In the letter:\nexplain why you cannot continue the course\ndescribe the job you have been offered\nand ask if they have an evening course that you can continue\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...............,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Oliver,\\nI am a student at your training institute, writing to inform you that I am unable to continue my course as I am due to start a full-time job from next week. I am hoping that you would either let me continue the evening course or permit me to discontinue it.\\nI am currently enrolled in a three-month-long Graphics Design course at your institution, and so far the programme has proven to be immensely useful. I have just finished my first two weeks.\\nLast Monday, I got a call from Soft Tech, a reputed IT company, and I am expected to start my new job from the beginning of June. The timing will contradict my classes, and hence I would like to know if you have any evening courses that I can join.\\nAs a junior consultant at Soft Tech, I am expected to work from 9.00 AM to 6.00 PM and the new job means a lot to catch up. I, therefore, request you kindly transfer me to an evening course or permit me to discontinue the course.\\nYours sincerely,\\nHanson Ariana", "Dear Mrs Jenny,\\nI hope you are doing fine. I am one of your students and attending a three months training course, taught by you, on learning advanced IT Management skills. After attending this course for about a few weeks now, I must say that I am enjoying it since I have already learned quite a lot from it. But, unfortunately, it looks like I will not be able to continue this course any further because I have been offered a job at one of the largest private banks in our country.\\nAt the new job, I will be working as a Junior IT Manager where my roles and responsibilities would be to coordinate and plan the IT activities of my organization as well as determine its IT needs. Anyway, while I really like this new job, offered to me, I would also like to continue this amazing course.\\nSo, is there a possibility that you will start an evening course soon so that I can come back and take advantage of that opportunity?\\nI will wait for your response.\\nYours sincerely,\\nMalcolm Jarvis\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (4 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
