-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:35.324450
-- Source: ielts-mentor.com
-- Title: Your Neighbours Have Dog That Is Noisy At Night
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Neighbours Have Dog That Is Noisy At Night';

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
  E'Your Neighbours Have Dog That Is Noisy At Night',
  E'You should spend about\n20\nminutes on this task.\nYour neighbours have a dog that is noisy at night. You can’t sleep due to this.\nWrite a letter to your neighbours. In your letter:\ndescribe the problem with the dog\nexplain why it is important for you to sleep\noutline what your neighbours could do about the situation\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear Mr and Mrs .................,\nModel\nAnswer 1:\nDear Mr and Mrs Donald,\nI am Beth Scarlet, your next-door neighbour, writing to express my concern about the noise your dog makes at night. I intended to write to you a few days ago but waited patiently with the hope that the dog would stop barking loudly at night and will save me from writing a letter that sounds like a complaint letter. I am hoping that you would resolve the issue.\nFor more than a week your dog has been yelping aloud at night and I have no idea why! Just when I send my daughter to her bed, who is a school-goer and try to close my eyes, I can hear the deafening noise and this deters me from falling asleep. I have to get up before 6.00 am to prepare breakfast for my family, then take my daughter to her school and finally drive to my office. Interrupted sleep or lack of sound sleep leaves me dizzy the next day and this hurts my performance in my office.\nYou are great neighbours in every aspect and I am sure you will feel my stress regarding this. I do not own a pet and cannot advise you what should be done but I guess taking the dog to a specialist might be a good idea.\nYours sincerely,\nBeth Scarlet',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr and Mrs Hagel,\\nHope this letter finds you in good health and spirit. I am sorry that it has come to this, but I had no other choice but to write this letter to you. In fact, we have a situation with your dog here which keeps barking at night just when I try hard to go to sleep after a long and tiring day at work. Now, please don’t get me wrong as I really have nothing against dogs. In fact, I like spending time with a good and friendly dog. But, as for your dog, I am having a hard time dealing with the noise made by it.\\nBy the way, it is really important for me to have a good sleep because if I don’t, it becomes difficult for me to perform well at the hospital where I have to treat elderly people.\\nSo, I think, I have got my point across. So, I would like to request you to spend some more time with the dog and train him better, or alternatively, take him to a pet hospital to do something about his abrupt barking at night. But, if that doesn’t work, please try to take it to another room so that I can take some sleep at night.\\nYours sincerely,\\nFreddie John\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.76 (17 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nTazima\\n9 years 7 months\\nI found this website very helpful. Thank you, IELTS Mentor.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
