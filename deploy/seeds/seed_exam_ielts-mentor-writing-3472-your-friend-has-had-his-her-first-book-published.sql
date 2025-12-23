-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:20.370683
-- Source: ielts-mentor.com
-- Title: Your Friend Has Had His Her First Book Published
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Friend Has Had His Her First Book Published';

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
  E'Your Friend Has Had His Her First Book Published',
  E'You should spend about\n20\nminutes on this task.\nYour friend has had his/her first book published a few days ago. He/she has recently sent you a copy of that book.\nWrite a letter to this friend. In your letter,\ncongratulate him/her for having his/her first book published\nthank your friend for sending you a copy of the book\nsay what do you think about the book\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Charles,\\nYou must be pretty excited to have your first book published within such a short time after finishing writing it. It is indeed such a great achievement of yours, and I surely would like to congratulate you on the occasion of such an amazing success. I also would like to thank you for sending me a copy of this book right away with your special signature on it.\\nAnyway, I''ve already read your book, and I must tell you that I''m truly impressed with your novel writing skills and abilities. I knew that you were passionate about writing stories, but I just didn’t think that you''d be able to write a novel with such ease and effect. The narrator (the main character) of your novel was very engaging while the other characters around it were as natural and lively as they could get. The caption of the book under the picture of a beautiful and playful rabbit is very illustrative, and the plot has just about enough twists and turns to engage the readers from start to end. All in all, it is a great book.\\nI''m sure this is the first book of a series of marvellous writings that we will see in the future.\\nWarm wishes,\\nAdam\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
