-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:22.934643
-- Source: ielts-mentor.com
-- Title: You Forget Your Bag In Gym
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Forget Your Bag In Gym';

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
  E'You Forget Your Bag In Gym',
  E'You should spend about\n20\nminutes on this task.\nYou forget your bag in the gym and the gym management announced that it will be closed for a week for some renovation work. You need your bag as it has important things in it.\nWrite a letter to the manager of the gym. In your letter,\nintroduce yourself and describe your position\ngive them a description of your bag\ntell them what you want them to do\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Peter,\\nThree days ago I went to your Gold Body Gym and forgot the bag that I placed in cupboard 547. I was ill for the last two days and when I  went to the gym yesterday I was notified that the gym would be closed for a week. I need my bag urgently and I am hoping you will allow me to fetch my bag from the gym.\\nI have been a member of your gymnasium since 2022 and my membership number is 4580. The allocated cabinet that I use regularly is 547. I placed my bag in that closet and forgot it as I hurried to return home on 22nd March 2025. Due to my sickness, I was absent for the next two days and could not retrieve my bag.\\nIn relation to the specifics of the bag, it is a brown colour office bag that has my laptop, a few official documents, my credit card and a notebook in it. The bag has three zippers and a flexible handle.\\nNow that I heard that your gym would be closed for at least a week for renovation work, I am a bit worried. As a solution, and because I really need the bag, I am hoping that you would permit me to collect it from the gym sometime tomorrow.\\nThank you for giving the matter your attention and I hope to hear your reply soon.\\nYours sincerely,\\nAlex Carey", "Dear Mr Andrew,\\nI am a regular member of your True Fitness Gym in the West Delhi branch. I went to the gym last Friday, as usual, however, I was in a bit hurry for an official meeting and I forgot my bag in cupboard 167. Today I learned that the gymnasium will be closed for a week but I need the bag urgently. I am hoping that you would arrange a way to hand over the bag to me.\\nMy access card number is 99876 and I have been a member since the beginning of 2021. The authority has announced that the gym will be closed for renovation work but I need my bag along with its content urgently. My bag is black and has three zippers, one in the middle and two on the sides. It has my official laptop and wallet which includes my driving license and credit cards along with some cash. I would need them before I go to the office tomorrow morning.\\nI would request you to kindly instruct your ward boy to assist me in getting the bag from the cupboard when I come to the gym tomorrow morning. I understand the inconvenience this might cause you, and I would really appreciate your help.\\nI look forward to hearing from you soon.\\nYours sincerely,\\nGaurav Verma\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
