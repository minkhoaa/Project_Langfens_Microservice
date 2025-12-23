-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:43.933355
-- Source: ielts-mentor.com
-- Title: You Are Preparing An Event In Countryside
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Preparing An Event In Countryside';

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
  E'You Are Preparing An Event In Countryside',
  E'You should spend about\n20\nminutes on this task.\nYou are preparing an event in the countryside.\nWrite a letter to your friend and ask for help with the arrangements. In your letter,\ndescribe the event\nmention what arrangements have already been made\nsay how your friend can help\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Andrew,\\nHope you''re doing well. I''m writing this letter to you because I need your help in arranging an event in the countryside next week.\\nThis particular event is going to be about raising awareness against the obesity problem among young children. Since obesity among children is higher than ever before, I, as a youth sports coordinator in my district, want to do something to change it.\\nAs for making this event successful, I''ve already put together a plan for the sports and outdoor activities, in which young children can take part. Besides, I''ve also arranged for a mini-concert where young artists will perform to entertain the children. By the way, I also have invited some distinguished guests and health specialists, whose inputs on this particular issue would certainly go a long way to change the eating habits of the children in favour of a more balanced and healthy diet.\\nSo, you can say that I''ve covered a large portion of it to make this event successful, but I could certainly use help from you in arranging some healthy and fresh foods for our guests. After all, you are a nutritionist, and a very good one.\\nWarm wishes,\\nAbbey\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.14 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
