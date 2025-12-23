-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:16.014473
-- Source: ielts-mentor.com
-- Title: Write To Gym Manager And Describe The Problem
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write To Gym Manager And Describe The Problem';

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
  E'Write To Gym Manager And Describe The Problem',
  E'You should spend about\n20\nminutes on this task.\nYou exercise regularly and have been a member of many different gyms. Recently, you moved into a new neighbourhood and joined a new gym. You have noticed that people at this gym do not bother to wipe down the machines after use and often leave dirty towels on the benches in the change rooms.\nWrite to the gym manager. In your letter:\nexplain who you are\ndescribe the problem exactly\nmake suggestions to improve the gym\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .........................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Fuller,\\nI am Neil Ryan, a lawyer by profession, have recently moved into this neighbourhood and joined your gym. So far, I have liked pretty much everything about your gym, including its large space and the state of the art exercising equipment. Besides, I also like the fact that the gym has some great safety measures in place to ensure enough safety and security for its users.\\nHowever, when it comes to maintaining hygiene, the gym certainly could use some improvements. In fact, I have seen that most people, visiting your gym, do not bother to wipe down the machines after using them. Besides, some of them leave dirty towels often on the benches and the floor in the change rooms, which does not quite go well with the core message of promoting health and fitness by a place called “gym”.\\nSo, in view of this hygiene problem, I would like to suggest you provide a hygiene guideline for all the users of your gym while instructing your gym staff to be more proactive in keeping the gym and its equipment tidy and spotlessly clean. Thanks for your consideration.\\nYours sincerely,\\nNeil Ryan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.55 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
