-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:28.293971
-- Source: ielts-mentor.com
-- Title: Your Friend Has Asked For Your Help To Find A Music Teacher
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Friend Has Asked For Your Help To Find A Music Teacher';

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
  E'Your Friend Has Asked For Your Help To Find A Music Teacher',
  E'You should spend about\n20\nminutes on this task.\nYour friend has asked for your help to find a music teacher for their child. You know someone who can teach their child music.\nWrite an email to your friend. In your email,\nexplain why he/she is suitable\nexplain his/her background related to music and teaching music\nexplain how they can get in touch\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Farah,\\nI hope you’re doing great! The other day, I remember you mentioned that you’re looking for a music teacher for your child. Since I was busy preparing food, I did not talk to you in detail about it. You''d be glad to know that I have the perfect recommendation for you.\\nMy friend Anup from school is an experienced music teacher who has been teaching children for over 7 years. I can assure you that he is highly skilled in guitar and violin and also has a great way of making lessons both educational and fun. I am quite positive that he would be a great music teacher for your child. Anil holds a degree in education and a diploma in music and has worked with students of all ages, helping them develop strong musical skills and a love for music.\\nIf you’d like to get in touch, you can reach Anil at +12554654978 or anil124.music(at).gmail.com. I’m sure he would be happy to discuss lessons and find a suitable schedule for your child.\\nLet me know if you need any further details!\\nWarm wishes,\\nMithila\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (4 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nemail writing\\nemail to friend\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
