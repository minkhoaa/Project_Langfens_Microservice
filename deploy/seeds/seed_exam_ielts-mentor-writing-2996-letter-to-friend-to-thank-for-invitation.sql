-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:58.600822
-- Source: ielts-mentor.com
-- Title: Letter To Friend To Thank For Invitation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Friend To Thank For Invitation';

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
  E'Letter To Friend To Thank For Invitation',
  E'You should spend about\n20\nminutes on this task.\nYour friend is celebrating her birthday soon and has invited you to a party. But you are unable to come because you are going to attend an important meeting that day.\nWrite a letter to your friend. In your letter:\nthank him/her for the invitation\nexplain why you cannot come\npropose to meet another day\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...............,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Samantha,\\nHow lovely it is to receive your letter exactly when I was thinking of you. I am so happy that things are wonderful at your end. I am overwhelmed to be invited to your birthday party on the coming 24th November 2025.  I wish you an advance happy birthday and thank you for inviting me. It means a lot to me.\\nI sincerely wish to meet you at your birthday party to say happy birthday in person, but unfortunately, the date contradicts our board meeting schedule. It saddens me to say that I will not be able to make it as I will be at the meeting the whole day. This meeting is utterly important for all the staff and there is no way to skip it. I wish I truly could!\\nI would, however, like to meet you sometime in December as I will visit your city during this time. I will bring you a birthday present and I am sure we will enjoy our time together.\\nWith lots of love and best wishes for our lovely birthday girl.\\nSonia", "Dear Martha,\\nHope you and your family are doing great. It''s been a long since we last saw each other. It was great to get your postcard from Dallas yesterday and I''m thrilled to learn that you''re going to celebrate your birthday on 20th June. Happy birthday, Martha.\\nI am so happy for you and wish you a prosperous life and a joyful birthday celebration. I would like to profoundly thank you for your invitation.\\nMartha, I''m so sorry that I can''t attend your birthday party as I will be in Manhattan the whole week for my professional responsibility. My company asked me to be there on 18th June to resolve some problems with an accounting system we have in Manhattan. You will be in my thoughts and I owe you a birthday present!\\nI''ll meet you after I return from my official trip - perhaps during the first week of July.\\nMany thanks for your invitation and happy birthday to you.\\nWarm wishes,\\nFadi\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
