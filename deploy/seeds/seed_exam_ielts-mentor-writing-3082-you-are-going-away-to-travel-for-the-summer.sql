-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:52.132335
-- Source: ielts-mentor.com
-- Title: You Are Going Away To Travel For The Summer
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Going Away To Travel For The Summer';

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
  E'You Are Going Away To Travel For The Summer',
  E'You should spend about\n20\nminutes on this task.\nYou are going away to travel for the summer. A friend will be looking after your house while you are away.\nWrite a letter to your friend.\nIn your letter:\nsay where you are going\ndescribe how to look after your pet\nexplain some of the things your friend should do to look after your house\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ................,\nModel\nAnswer 1:\nDear Donna,\nI trust you are doing splendidly and enjoying the season. Thank you very much for agreeing to house-sit for me while I will be in Ireland to see my sister this summer. If you need to reach me for any reason, please ring my mobile phone. I trust you already have my number. Alternatively, you can find it on a sticky note placed on the land phone table.\nI will stay with my sister in Limerick city in Ireland and would return on 24th October. It was a relief when you agreed to house-sit for me. I owe you a big one!\nMy dog needs to be fed thrice a day - morning, noon and evening. Please put dog food in his dish at the proper time. You will find the food containers in the kitchen pantry. Also, please check throughout the day to make sure he has fresh water. You can take him outside in the evening if you like. He is very friendly and does not bark at night.\nI would like you to close the doors and windows in the evening and check the mailbox every other day. If someone asks about me, please inform them that I am away and could be reached on my mobile phone. Finally, water my plant every evening. The indoor cactus plants need water only when the soil is dry. Keep the outside lights on at night.\nI look forward to seeing you on my return.\nWarm wishes,\nElsa',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Valentina,\\nThank you for agreeing to house-sit for me the whole week while I will be away in Bali, Indonesia. If you need to contact me during this time, I’ll be staying at the Liberty Dive Resort. If it’s urgent, however, please ring my mobile phone, which I’ll keep with me at all times.\\nMy cat, Tommy, needs to be fed twice daily so each morning and evening put a handful of his food in his dish. I have reserved enough food for him and you can find it in the kitchen cabinet marked as Tommy. Also, please check throughout the day to make sure he has fresh water. You can give him a small bowl of milk in the evening. Finally, let him play outside in the evening but make sure he gets back before the dark settles in.\\nI would like you to water my plants, too. The indoor ones in the lounge only need water once every few days but the plants on the balcony need to be watered daily unless there has been heavy rain. Finally, for security, please clear my mailbox every day and keep the outside lights on at night.\\nI look forward to seeing you on my return.\\nYours ever,\\nIsabella\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
