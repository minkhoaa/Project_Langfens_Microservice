-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:57.268707
-- Source: ielts-mentor.com
-- Title: Advice Regarding Your Friends Parents Visit To Your Area
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Advice Regarding Your Friends Parents Visit To Your Area';

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
  E'Advice Regarding Your Friends Parents Visit To Your Area',
  E'You should spend about\n20\nminutes on this task.\nYour friend has written a letter to you asking for advice regarding a visit that his/her parents will be making to your area in the near future.\nWrite a letter to your friend. In your letter,\nrecommend a place where they can stay\nsuggest the places they can visit\noﬀer to do something with them\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ....................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Jessica,\\nI''m so glad to hear from you after a long time.  I''m also very happy that your parents are planning to visit the area where I live.  So, any idea as to exactly what time of the year your parents are planning to visit?  But, if I were them, I''d visit it during the spring because that’s when it becomes alive and more enjoyable due to the formation of some “bird colony”.\\nThey can also visit the large shopping mall during the daytime while visiting the small restaurants near the river during the evening.  They can enjoy some affordable but fresh food, in addition to visiting a famous but old olive garden there.  But, if they are not into any of these things, I''d be more than happy to accompany them to some temples, the museum, and also perhaps meet some very generous local residents.\\nBy the way, once they visit here, they can stay at one of the hotels on north Rupel Street since they are not only affordable but also close to the downtown.\\nHope to meet them soon.  Talk to you again!\\nBest wishes,\\nEmma\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.67 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
