-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:16.460199
-- Source: ielts-mentor.com
-- Title: Write Letter To Invite Your Friend To Music Concert
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Letter To Invite Your Friend To Music Concert';

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
  E'Write Letter To Invite Your Friend To Music Concert',
  E'You should spend about\n20\nminutes on this task.\nYou are planning to go to a music concert in your town and would like a friend to accompany you. Write a letter to invite your friend to the concert you are planning to go to.\nIn your letter, say:\nwhat the content of the music concert is\nwhere and when the music concert is\nwhy you think your friend should go to this concert\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear .................,\nSample Answer 1:\nDear Taylor,\nIt has been a while since I have talked to you or met you in person.  So, I hope that everything is well with you. Anyway, I''m writing to request you to accompany me to a musical concert which will be held on July 25.\nWith regard to the concert and its content, it will be an open-air music concert which will take place at the National Football Stadium in my hometown in Montreal. I am asking you to go with me because I believe you will love the concert. A couple of your favourites and a few other top-class country singers are going to play some of their most popular music at the concert. Besides, some techno music will be played there, and I know how much you like it. Besides, I don’t think that I would really be able to enjoy the concert all by myself.\nSo, let me know what you think about the idea. But, if you are really interested to accompany me to the concert, just let me know within a few days so that I can purchase the tickets for both of us in advance.\nWarm wishes,\nJulian Gonzalez',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Taylor,\\nIt has been a while since I have talked to you or met you in person.  So, I hope that everything is well with you. Anyway, I''m writing to request you to accompany me to a musical concert which will be held on July 25.\\nWith regard to the concert and its content, it will be an open-air music concert which will take place at the National Football Stadium in my hometown in Montreal. I am asking you to go with me because I believe you will love the concert. A couple of your favourites and a few other top-class country singers are going to play some of their most popular music at the concert. Besides, some techno music will be played there, and I know how much you like it. Besides, I don’t think that I would really be able to enjoy the concert all by myself.\\nSo, let me know what you think about the idea. But, if you are really interested to accompany me to the concert, just let me know within a few days so that I can purchase the tickets for both of us in advance.\\nWarm wishes,\\nJulian Gonzalez", "Dear Emma,\\nHow are you? I haven''t seen you for a while and wish everything is fine. Anyway, I am writing because I am inviting you to enjoy a music concert titled ” EXO PLANET#2 – The EXO''LuXion” and it will be held on 17th August in Aisa-World Arena in Hong Kong. I am so eagerly waiting to enjoy this music concert together.\\nI am sure you already know that EXO band is a Chinese-South Korean boy band based in Seoul. Formed by S.M. Entertainment in 2011 it is now a famous music band in our area. I guess you know this band since you are a big fan of K-Pop music. They will perform 27 songs and play games with fans. ChanYeol (a member of this band) will solo a program that is dancing in the water. You can scream loudly for the members you like and in the meantime, that can help you release stress. You will see the silver sea which consists of glow sticks. It''s totally a fantastic world.\\nAnyway, do let me know if you can make it. My new number is at the top of the page, so you can give me a call anytime.\\nTake care and see you soon. I am looking forward to enjoying this music concert with you.\\nWarm wishes,\\nShirley\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
