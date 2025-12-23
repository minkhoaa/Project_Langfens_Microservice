-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:11.086866
-- Source: ielts-mentor.com
-- Title: Thank Your Friend And Say That You Enjoyed The Meal
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Thank Your Friend And Say That You Enjoyed The Meal';

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
  E'Thank Your Friend And Say That You Enjoyed The Meal',
  E'You should spend about\n20\nminutes on this task.\nOne of your friends invited you for a meal with his/her family in their home. You enjoyed the meal and had been happy to be introduced to his/her family.\nWrite a letter to your friend. In your letter,\nthank your friend and say that you enjoyed the meal\nsay what else you liked about this visit\nask your friend to meet you someday at a restaurant\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Fanny,\\nHope all is well at your end. I''d like to thank you for the wonderful meal that I enjoyed at your home with your entire family last week. The food, you served, was just so great and delicious. In fact, the pizza at your home was the best homemade pizza I''ve ever tried!\\nI also very much enjoyed the pleasant atmosphere at your home and liked the idea that you introduced your entire family to me one by one right after arriving at your place. Besides, I enjoyed your family videos from the past, especially, when you were a little child. On top of that, the location of your home is excellent as it has plenty of space around it. Finally, the small but very beautifully maintained orchard garden at the back of your home was breathtaking.\\nBut, anyway, now that you''ve been kind enough to invite me to your home for a great meal, I would also like to invite you to a favourite restaurant of mine for some dinner this coming weekend.\\nHope you would come.\\nWarm wishes,\\nMiller\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.43 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
