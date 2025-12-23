-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:36.896017
-- Source: ielts-mentor.com
-- Title: You Borrowed Important Textbook From Classmate
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Borrowed Important Textbook From Classmate';

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
  E'You Borrowed Important Textbook From Classmate',
  E'You should spend about\n20\nminutes on this task.\nYou borrowed an important textbook during the last term from a classmate. You now realize your classmate has returned home overseas and you still have the book.\nWrite a letter to him/her.\nIn your letter:\napologize for the mistake\nfind out how important the book is to him/her\nsay what you will do\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...\n...\n.........\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Francisco,\\nHow are you? I hope you had a safe journey back to Portugal. I''m writing this letter to apologize for not returning your book as promised. I really am sorry that I could not return the book \\"Advanced Introduction to Behavioral Economics\\" before you had travelled to your home country.\\nI borrowed this book from you during the last term, and I''m indebted to you for lending me this book just before the term final exam. It was a great help. I intended to return it within a few days but to my bad, I totally forgot, which I deeply regret.\\nI''m not quite sure if this book is still important to you. If so, just let me know, and I''ll manage to send it to your address. I am ready to bear the courier cost. I can post it via express airmail immediately. Alternatively, I can send you some money so that you can buy it from your country. Please let me know what you want me to do.\\nPlease do write to me sometimes and stay fine.\\nWarm wishes,\\nMerrill", "Dear Stefano,\\nHope this letter finds you and your family in good health. I came to know from Jenny that you''ve permanently moved to your hometown in Italy. I''m writing this letter to apologize for the physics book that I borrowed from you during the last term but forgot to return. I''m now willing to return the book anytime you want.\\nI would like you to brief me on how important that physics book is to you. If I remember correctly, you have plans to pursue a master''s degree in physics from one of the universities in your country. I''m not sure if this book is going to help you in cracking the entrance exam.\\nBased on your response, I might courier it or send it through the post. As you are aware, Tom is visiting your hometown next month. If you can wait, I will send the book along with him. Also, this would make sure that your book is not misplaced.\\nI wish you success and look forward to hearing from you soon.\\nWarm wishes,\\nJasmine\\n[Authored by -\\nMishika\\n]", "Dear Sara,\\nHope you and your family are doing great. I didn''t attend classes for a few days due to a serious viral fever. Once I came back to join the class, I heard that you''ve moved to India. I hope you had a pleasant journey.\\nOn that day, I realized that I borrowed the ''Introduction to Computer Science'' book from you and forgot to return it. I''m really sorry for not returning your book as promised.\\nI guess, this book is very important to you for your further studies in India as you have told me once that you are joining an advanced computer course in your home country. Could you let me know if you really require this book for your next course? If so, how quickly do you need it?\\nI''m wondering whether I should send a scan-copy of this book or sent you money to buy the same copy from India. Alternatively, I can send this book via a courier service, and you''ll likely receive it in two weeks.\\nWaiting for your reply. Take care.\\nWarm regards,\\nJanaka\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
