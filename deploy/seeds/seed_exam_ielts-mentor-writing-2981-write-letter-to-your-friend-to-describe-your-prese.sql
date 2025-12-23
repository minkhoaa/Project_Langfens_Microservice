-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:06.650582
-- Source: ielts-mentor.com
-- Title: Write Letter To Your Friend To Describe Your Present Life
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Letter To Your Friend To Describe Your Present Life';

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
  E'Write Letter To Your Friend To Describe Your Present Life',
  E'You should spend about\n20\nminutes on this task.\nYou have recently migrated to another country. Now write a letter to your friend to describe your present life.\nIn your letter, say:\nwhen you have moved to this country\nwhy you chose this country\nhow things are now for you\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,\nSample\nAnswer 1:\nDear Kumar,\nHope you are doing fine. I''m so happy that you have finally decided to migrate to Canada, and I would say that it is a timely decision considering your career and children''s education. As you know I have migrated to Ontario, Canada last January and we are doing fine.\nIt was a big decision to migrate to another country but I am delighted that we have finally settled in. It''s been almost four months, and we already feel at home. The different weather was perhaps the hardest part to adapt to but we are doing excellent.\nAs you know, Canada has one of the highest immigration rates due to better job opportunities, cultural diversity, economic strength, and people''s tolerance to immigrants. On top of that, the superior education this country offers is unparalleled. Canada’s affordable education system has contributed to its appeal to immigrants and I primarily considered my daughter''s education before deciding to migrate to another country.\nI have managed a job in an accounting firm and the pay scale is really lucrative. We have rented a house near Ria''s school and it''s around 30 minutes drive away from my office.  Canadians are very nice people, especially Ontarians and I have already made a few friends. Home to Niagara Falls, Ontario is full of things to do and we are so amazed to explore new places each week. You can never get bored of living here since there''s much variety in everything. We have plenty of options to occupy our time.\nI would love to hear from you. Please do write back to me.\nWarm wishes,\nAshim',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Lee,\\nHope you and your family are doing fine. I''m sorry that I couldn’t get back to you with an update from my end earlier after moving to Australia about a month ago, but that’s so because I was terribly busy with getting my things organized after moving to this new country.\\nAnyway, now I am all set with my new life and trying to adapt to the new environment and conditions of this new country slowly. Of course, it will take a bit longer for me to understand the life and culture, but people are charming and friendly here. The place, where I live now, is a small town but it is certainly a beautiful place with lots of trees and beautiful landscape. So, I guess, you can say that I am enjoying my time here.\\nBy the way, in case if you were wondering, I decided to move to Australia because the profession and skills I have are in high demand here. I am expecting to work in Australia for at least 10 years.\\nThat should do it for now, but I sure would like to get back to you with some more updates soon.\\nWarm wishes,\\nGhim\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.94 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
