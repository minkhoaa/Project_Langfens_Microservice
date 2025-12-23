-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:15.526648
-- Source: ielts-mentor.com
-- Title: Building Management Should Purchase Extra Laundry Baskets
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Building Management Should Purchase Extra Laundry Baskets';

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
  E'Building Management Should Purchase Extra Laundry Baskets',
  E'You should spend about\n20\nminutes on this task.\nYou live in a high-rise building, which has a communal laundry room. Sometimes people don''t come in time to empty the machines and other residents have to wait for a washer or dryer. You think the building management should purchase 10 extra laundry baskets and make them available for such times, so the machines can be freed up.\nWrite to the Property Manager, Mr Watson. In your letter:\nexplain how long you have been a resident\ndescribe the problem\npropose your solution\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Watson,\\nI hope that you are doing well. I have been a resident of your Sky Village Apartment Complex for almost 5 years, and I must say that I have enjoyed living here all these years without any major problems. However, lately, I, like many other residents in your high-rising building, have been dealing with an issue which, I think, deserves some immediate attention from your part.\\nThis issue, I am talking about, is related to the efficient use of our communal laundry room where people sometimes have to wait for a significant period of time to use the washers and dryers in order to do their laundry because there are not just enough laundry baskets available in the room. This problem becomes even more acute when people do not bother to empty the washing machines and dryers on time when their laundry is done.\\nSo, based on these problems, I would really appreciate it if you purchase at least 10 extra laundry buckets so that the laundry users, waiting for their turns to do their laundry, can empty the laundry machines and keep their contents into those baskets. This will improve the situation to a great extent and reduce our waiting time significantly.\\nI hope to hear from you soon regarding this.\\nYours sincerely,\\nLance Donovan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.90 (5 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
