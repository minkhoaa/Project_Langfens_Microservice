-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:19.717240
-- Source: ielts-mentor.com
-- Title: Letter To Friend Describing File You Left
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Friend Describing File You Left';

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
  E'Letter To Friend Describing File You Left',
  E'You should spend about\n20\nminutes on this task.\nYou stayed at your friend’s house when you participated in a business seminar in Australia. You left a file with important documents in the room you stayed in.\nWrite a letter to your friend, describing the file and ask him/her to return it to you by post.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear James,\\nHope this letter finds you in good health and jovial spirit. It''s been almost a week since I left your place but the memories still linger as if it was just yesterday! I indeed enjoyed my stay at your place and had a great time together.\\nIf you had not been a great host, I definitely had to struggle to finish the professional seminar that I attended in Perth, Australia. I owe you a big one. I, however, must have been oblivious while I left for Perth Airport last week. I left a very important file at your house, in the room I stayed in. I possibly kept it in the wooden cabinet I used. It is a medium-size blue file-holder made of plastic and has my name inscribed on it. I have some important files in it including the certificate given by the seminar authority in Australia.\\nI would really appreciate it if you could post it to my address, preferably via Australia Post, as soon as possible. I will bear the courier cost. Take care and see you soon.\\nWarm wishes,\\nMorshed", "Dear Farah,\\nIt was great to see you after such a long time. I would also like to thank you again for being such an awesome host by offering me to stay at your house during my business seminar.\\nAnyway, the reason, for which I am bugging you again with this letter, is that while I left your home last Friday, I believe that I accidentally left a file with some important documents in it. I came to know about this file only after arriving at my home yesterday morning.\\nIf I remember it correctly, I think that I may have left the file in the bottom drawer of your TV stand in the living room where I was sleeping. I am pretty sure that you won’t miss the file since it is a standard size, yellow colour file envelope that has my name tag on it. By the way, the file contains some important financial documents.\\nPlease mail this file to me in courier service as soon as possible because, without these documents, I won’t be able to prepare my next quarterly report for my company CEO.\\nStay fine and have fun.\\nYours sincerely,\\nClaudia\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
