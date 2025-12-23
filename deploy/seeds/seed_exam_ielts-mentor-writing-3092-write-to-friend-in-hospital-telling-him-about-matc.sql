-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:46.966817
-- Source: ielts-mentor.com
-- Title: Write To Friend In Hospital Telling Him About Match
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write To Friend In Hospital Telling Him About Match';

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
  E'Write To Friend In Hospital Telling Him About Match',
  E'You should spend about\n20\nminutes on this task.\nYou play a team sport with some friends. Last week a member of the team had an accident and was not able to play with you at the weekend. You decide to write to him/her in the hospital, telling him/her about the match.\nWrite a letter to your friend. In your letter,\ntell him/her which team won\nsay how you felt about the match\nask how he/she is doing\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Joseph,\\nI was quite horrified by the news that you broke your leg during the practice session and got admitted to a hospital. I''m writing to wish you a quick recovery and to let you know that we''ve won the match.\\nWithout your presence, the team was discouraged, and we missed you during the game. However, we wanted to win the match and bring the trophy to our college this year. Muller and Gordon both scored, and we won by 1 goal. The final score was 3-2, and the match was nerve-racking. I must say that we were lucky to have our usual composure. Not to mention, everyone talked about you before the game, and I felt your absence too.\\nI haven''t been able to meet you in the hospital, and I''m planning to do it first thing on Monday. How are you doing? I hope the broken bones are not much severe. Take rest, and stay relaxed. You''re in our prayers.\\nI''m hoping to talk to you in person soon.\\nWarm regards,\\nRichard", "Dear Conor,\\nI really pray and hope that you''re trying to remain positive and high-spirited after your accident. And, please also know that you''ve always been in the thoughts and prayers of our whole team since we heard about your shocking accident.\\nI think that this particular news is going to elate you and your spirit in a big way - our team has won against the “Brother’s Union” club in the last match which took place a couple of days ago. Our whole team surely missed you in the match, since you were one of our most experienced and valued players, but the win against tough opposition like the Brother’s Union Club felt really sweet to all of our team members. Besides, I felt that it was a complete win for our team since we played properly in all departments, including ball passing and saving many corner kicks.\\nSo, how long more do you need to stay at the hospital? We''re still not sure about the extent of damage or injury to your left leg. So, have you got the final X-ray report of your fracture? Wishing to have you among us soon.\\nWarm regards,\\nTim\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.55 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
