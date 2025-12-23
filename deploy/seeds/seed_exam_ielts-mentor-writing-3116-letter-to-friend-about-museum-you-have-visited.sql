-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:37.381558
-- Source: ielts-mentor.com
-- Title: Letter To Friend About Museum You Have Visited
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Friend About Museum You Have Visited';

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
  E'Letter To Friend About Museum You Have Visited',
  E'You should spend about\n20\nminutes on this task.\nYou have recently visited a museum. Now write a letter to your friend about the museum you have visited.\nWrite a letter to him/ her.\nIn your letter, write:\n- where you went\n- what you saw there\n- how you felt about it\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ......\n.........\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Laura,\\nI''ve just returned home from an exciting trip to Australia, and visiting the National Museum of Australia was one of the fabulous activities of this tour. I can''t wait to share my experience with you.\\nWe stayed in Australia for a week, and on our second day, we went to the National Museum of Australia, located on Acton Peninsula, next to the Australian National University in Canberra. The museum''s innovative use of new technologies is unprecedented. Initially, I thought that it''s not going to be a fun time but to my surprise, I actually got fascinated by the fabulous collection the museum has.\\nThe Entrance and the interior blew my mind away. The museum''s stunning architecture offered me an extraordinary opportunity to explore the rich and diverse stories of Australia and its people. From pre-colonial settlement to modern Australia, the museum has it all. The Pearling exhibition was excellent from a historical perspective. The museum is divided into 4 galleries and each has many glass cases filled with stories. The experience was stunning.\\nI wish you had been with me there. I''d absolutely recommend you visit this museum whenever possible.\\nI would like to meet you soon and tell you stories about my tour. Take care.\\nYours truly,\\nEmma", "Dear Ali,\\nHope you are doing well. I''ve something very interesting to share with you, and that''s why I''m writing to you today.\\nLast Thursday, my dad and I decided to take a trip to the Quetta Museum, a stunning Archaeological Museum, located on Steward Road, Balochistan. He wanted me to learn more about the history of our country, and this museum was a perfect place to start with.\\nThe museum is full of historical artefacts relating to the period before the separation of Pakistan and India. Among other things, it exhibits the first-ever constitution drafted for our country, and the first-ever proposed national anthem that was hand", "Dear Joy,\\nHope this letter finds you in good spirits and health. As you are aware, I''m currently in Chicago for a month for some professional work. I''m writing this letter to share my experience of visiting the ''Science Museum'' in Chicago Downtown, which I thought you would enjoy.\\nThe entry fee was $15 but I was lucky to get a free pass from one of my colleagues. This museum is visited by a large number of local citizens and international tourists. The ground floor displays the invention of robots, with many robots on display and details on how they were developed. I learned that theories based on the abacus were further expanded to enhance this technology. The first floor displays extinct animals, skeletons of dinosaurs and the history behind their extermination. This was quite interesting. The second floor has a shop where you can buy books and souvenirs. Kiosks are placed on all floors which provide extensive information about the displayed items.\\nIt was a great learning opportunity and a fabulous experience that I''ll cherish for a long. I wish you had been with me when I visited the museum.\\nWhy don''t you write me back about things you''ve done recently and enjoyed?\\nWarm wishes,\\nTom\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
