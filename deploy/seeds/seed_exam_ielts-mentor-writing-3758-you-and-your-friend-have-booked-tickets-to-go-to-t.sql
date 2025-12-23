-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:48.935037
-- Source: ielts-mentor.com
-- Title: You And Your Friend Have Booked Tickets To Go To Theatre
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You And Your Friend Have Booked Tickets To Go To Theatre';

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
  E'You And Your Friend Have Booked Tickets To Go To Theatre',
  E'You should spend about\n20\nminutes on this task.\nYou and your friend have booked tickets to go to the theatre. You are now unable to go but have found another friend to accompany him/her instead.\nWrite a letter to your friend. In the letter,\nexplain why you can not go to the theatre with your friend\nsay who can go instead of you\ntell them why you think this person would be good to go with\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .........................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mike,\\nHope all is well on your end. I know that you''re going to get a bit disappointed, but the truth is I don’t think that I''ll be able to go to the theatre with you next Saturday evening. Let me just explain to you why I needed to change my plan.\\nActually, my boss is returning from Japan in the evening, on that day, and he has requested me to pick him up from the airport and head straight to the office to have an urgent meeting with me and the others. I don’t know exactly how long the meeting is going to last, but given the urgency of the meeting, I don’t think that it would end soon – soon enough to allow me to join you at the theatre on time.\\nSo, I guess, it is better if I just give the ticket to my cousin, Eric, so that he can go with you. By the way, you already have met Eric, and you should enjoy his company because he doesn’t just have a bubbly personality, but also are into the same kind of classic movies as we are!\\nPlease let me know your thought about it. Take care.\\nWarm wishes,\\nMathew\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.18 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
