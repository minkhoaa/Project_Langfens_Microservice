-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:18.882477
-- Source: ielts-mentor.com
-- Title: Letter To Your Friend Telling Him You Left Coat
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Your Friend Telling Him You Left Coat';

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
  E'Letter To Your Friend Telling Him You Left Coat',
  E'You should spend about\n20\nminutes on this task.\nYou have just spent a weekend at a friend’s house. When you returned home, you discovered you have left a coat containing some belongings in his house.\nWrite a letter to your friend telling him that you left the coat. Tell him what the coat looks like, where you think you left it and what was inside it. Make some suggestions about how to get it back.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Steven,\\nThanks very much for a great weekend and I really enjoyed my time at your house. Please say hello to Paula whose hospitality is unforgettable. I hope you both will be able to come and stay with me sometime soon.\\nRegrettably, I left my new coat at your house, I probably left it on the hooks in the guest room. Do you remember the black coat that I wore when I arrived at your house? It is a black tic classic fit car coat that goes down to mid-thigh level. It has a zippered inner bib, a quilted lining, three large buttons and side pockets on both sides. It''s made of wool and nylon and I am sure you will detect it as soon as you look at it.\\nI have left my wallet in the left pocket of the coat and the wallet contains my credit cards and some cash. I also put my Samsung Galaxy tab and an important document in the right pocket of it and this is really important for me. Laura will be in your town on Friday and I am hoping you would be able to give her a call so that she can collect it from your house. I have given her your phone number and she will be contacting you soon.\\nThanks again for a magnificent weekend and I hope to see you soon.\\nWarm wishes,\\nHaksoon Paik", "Dear Stephen,\\nHope this letter finds you in good health and spirit. Just so you know, I have had a great weekend at your house, and I hope that you also enjoyed that weekend. Anyway, I am writing this letter to you because I, unfortunately, forgot to pick up the new coat that I carried with me that weekend.\\nNow regarding the coat, it is a dark blue colour coat, with a white collar and light-white buttons. The coat also has two side pockets on the bottom part of it. Besides, it also has a furry headcover. If I remember it correctly, I may have either left it on the hooks of one of your doors or inside the wardrobe of the room in which I slept.\\nIt is important that I get back that coat soon because the temperature is going to drop significantly in the next few days, and I have put some important letters, a small gift item and my wristwatch in the pockets of it. I need the letters immediately as two of them are from my head office.\\nSo, I would really appreciate it if you hand over the coat to one of my colleagues who will be travelling by your place after a couple of days. I have already provided your phone number and address to my colleagues.\\nYours sincerely,\\nJack Kyle\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.50 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
