-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:10.567892
-- Source: ielts-mentor.com
-- Title: Congratulate Colleague For Successfully Organising The Event
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Congratulate Colleague For Successfully Organising The Event';

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
  E'Congratulate Colleague For Successfully Organising The Event',
  E'You should spend about\n20\nminutes on this task.\nOne of your colleagues was in charge of organising an annual executive conference, and he/she has been successful in doing it. You want to congratulate your colleague on that.\nWrite a letter to this colleague. In your letter,\ncongratulate your colleague for successfully organising the event\nmention what you liked about it the most\nsay how much you would like him/her to organise other events as well\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Jeremy,\\nHope you are doing excellent. I am writing this letter to congratulate you on organizing this year''s annual executive conference quite successfully. But, you deserve this compliment even more because you have managed to organize this conference successfully on rather short notice as we were not sure until the last hour whether or not our CEO would be able to attend the conference.\\nI think it was an outstanding conference this year as everybody loved it. What I liked the most about the conference is its theme selection where the theme “Stronger as a team” inspired all the attendees to have some serious, honest and stimulating conversations among themselves. Even our company CEO, who doesn’t normally take that much interest in our annual conference, was pleased with your theme selection. Besides, your venue selection for the conference was also very wise because everybody was able to arrive there easily in public transportation instead of using some expensive taxi ride.\\nSo, it looks like you have the natural ability and talent to organize events. Therefore, I would be really glad if you start organizing other events like annual inter-departmental sports and annual corporate picnics from now on.\\nYours sincerely,\\nAndy Moore\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.83 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
