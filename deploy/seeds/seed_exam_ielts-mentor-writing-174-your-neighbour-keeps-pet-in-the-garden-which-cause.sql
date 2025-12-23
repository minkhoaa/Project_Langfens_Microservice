-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:18.434390
-- Source: ielts-mentor.com
-- Title: Your Neighbour Keeps Pet In The Garden Which Causes Problems
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Neighbour Keeps Pet In The Garden Which Causes Problems';

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
  E'Your Neighbour Keeps Pet In The Garden Which Causes Problems',
  E'You should spend about\n20\nminutes on this task.\nYour neighbour keeps a pet in the garden, which causes some problems for you. You have decided to write to this neighbour about the problems.\nWrite a letter to your neighbour. In your letter,\nsay who you are and why you are writing this letter\nexplain the problems\nsuggest how to solve the problems\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Blake,\\nI am Barry Sanders, your neighbour of house 25, writing this letter to talk about the dog that you keep in your garden. I own a dog, and you can understand that I love pets. But your dog is causing some problems for us. And I waited for more than a few weeks before writing this letter.\\nYour dog \\"Tom\\" is a nice pet, and when you are around, he creates little commotion to disturb anybody. But you travel a lot and confer the responsibility to your friend Hadden to take care of the dog when you are away. However, I do not think that Hadden is doing a decent job. Tom is often left alone with no adequate food and water, resulting in her excessive barking, which disturbs me and almost everyone around the neighbourhood. Hadden does not even come to see the dog and refill the food and drink pots every day. As a result, Tom barks even more in the early morning when the food or drink pot is empty.\\nTherefore, I would like to suggest that you ask Hadden to come and look after Tom every day and make sure he is taken care of properly. This will be helpful for your pet as well as us. Please give me a call when you get back from your vacation. We will discuss this further.\\nYours sincerely,\\nBarry Sanders\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.86 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nDerek\\n11 years 7 months\\nThanks for a good sample on GT IELTS writing task 1. This would be very helpful for others (IELTS students) as well.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
