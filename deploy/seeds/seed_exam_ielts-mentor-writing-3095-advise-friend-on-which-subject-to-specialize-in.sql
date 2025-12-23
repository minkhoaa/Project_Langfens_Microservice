-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:45.671441
-- Source: ielts-mentor.com
-- Title: Advise Friend On Which Subject To Specialize In
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Advise Friend On Which Subject To Specialize In';

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
  E'Advise Friend On Which Subject To Specialize In',
  E'You should spend about\n20\nminutes on this task.\nYou have a friend who is about to enter university, and he/she wants you to advise him/her on which subject to specialize in – history, in which he is very interested, or computer science, which offers better job prospects.\nWrite a response letter to this friend.\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...............\n,\nSample Answer 1:\nDear Charles,\nI got so delighted to receive your letter yesterday and it was a pleasant surprise to know that you''ve already completed high school and would get admitted to a university soon. How time does fly!\nYou''ve asked my opinion on which subject to take as your major. I think you should follow your instinct and go for something you feel passionate about.\nI know you very closely and can advise that you do better when you feel connected to something. From your letter, I understand that your personal choice is history but your parents want you to follow your elder cousin Ryan''s track who is earning a lot from his IT career. Who says you cannot have a great career if you take history? I can give you many examples of when someone from a more demanding subject is doing mediocrely while someone from a traditional subject is doing quite excellently.\nI guess you personally want to study history, I''ve got that impression from your letter, and that''s why I would advise you to follow your own track and set an example for others instead of blindly walking through a street you do not want to be in.\nWarm wishes,\nSimmon',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Charles,\\nI got so delighted to receive your letter yesterday and it was a pleasant surprise to know that you''ve already completed high school and would get admitted to a university soon. How time does fly!\\nYou''ve asked my opinion on which subject to take as your major. I think you should follow your instinct and go for something you feel passionate about.\\nI know you very closely and can advise that you do better when you feel connected to something. From your letter, I understand that your personal choice is history but your parents want you to follow your elder cousin Ryan''s track who is earning a lot from his IT career. Who says you cannot have a great career if you take history? I can give you many examples of when someone from a more demanding subject is doing mediocrely while someone from a traditional subject is doing quite excellently.\\nI guess you personally want to study history, I''ve got that impression from your letter, and that''s why I would advise you to follow your own track and set an example for others instead of blindly walking through a street you do not want to be in.\\nWarm wishes,\\nSimmon", "Dear Diana,\\nHope this letter finds you in good health and spirit. I feel truly honoured and flattered since you''ve decided to take my advice into confidence with regard to choosing a subject of study before entering your university. However, this is not an easy decision to make - probably because none of us can be sure what the future would be like.\\nBut, again, since you have taken the trouble to ask for my advice, I''d suggest you go ahead with the “History” subject, primarily because you really like to study history. Besides, conventional wisdom suggests that whenever a person likes to do something, the chances are that he or she will become a real expert in that subject or profession, sooner rather than later.\\nFinally, in defence of studying History, the job prospect after studying this subject is no less than studying computer science since many universities would compete among themselves to recruit you as a faculty member to teach history if you have good results.\\nHowever, I would like you to think more as it is ultimately your future. I hope whatever you decide, would be best for you.\\nWarm wishes,\\nElina", "Dear Erlin,\\nHope you''re doing well. It was a pleasant surprise to receive your letter yesterday after so long, and it was great to learn that you''ve graduated from high school. I''m also excited that you''ve asked for my advice on choosing a major for your university study.\\nWell, I would recommend you to study computer science. I learned from your letter that you are more interested in graduating and specialising in history and have little knowledge of computer science, but the career prospects and your potential in computer science are far greater, in my opinion. I know how excited you felt every time you solved a math problem, or won a chess match. You''ll have plenty of such moments if you study computer science.\\nYou also need to consider your future career prospects while choosing a major at the university as it is going to determine what career you get into in the future, and how much money you can make. Since I''ve been studying computer science for the last one and a half years, I know how enjoyable this can be. I am positive you''ll also enjoy it and have a great career after you graduate from the university.\\nTake care.\\nYours truly,\\nEugene\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.82 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nCleo\\n6 years 10 months\\nTһanks for the gоߋd writeup.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
