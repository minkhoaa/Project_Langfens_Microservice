-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:44.734634
-- Source: ielts-mentor.com
-- Title: Suggest Colleague You Think Should Be Best Employee
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Suggest Colleague You Think Should Be Best Employee';

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
  E'Suggest Colleague You Think Should Be Best Employee',
  E'You should spend about\n20\nminutes on this task.\nEvery year, someone in the company where you work is chosen as the best employee. Your manager has asked staff members to make suggestions about who should be chosen this year.\nWrite a letter to your manager. In your letter,\nidentify a colleague who you think should be the best employee\nexplain what the job of this colleague involves\ngive reasons why the colleague should be chosen as the best employee\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Alan,\\nI would like to express my appreciation for the great initiative to take employees'' feedback for selecting the employee of the year. Personally, I would recommend Alfred Simmon for the title this year.\\nAlfred is an achiever, and his unparalleled leadership has brought innovation and enviable success to our company. As a project manager, his responsibility is to distribute works to the team members, coordinate them, liaison to the sales team, deliver the projects to the clients in time and everything in between.\\nHis dedication and friendly attitude have inspired many junior employees to work hard and be loyal to the company. He is a leader who sets examples to his subordinates, and this is exactly what a project manager in our company should be like. Nobody, in my opinion, deserves the title more than he does. By choosing him the employee of the year, we can show our recognition to the worthiest employee in the office.\\nYours sincerely,\\nDaniel Cabin", "Dear Mr George,\\nHope you are doing well. I am also feeling great since the time of the year is approaching for us again when we get to decide on the best employee of our company. And I think that Rebecca Graham, our Senior Marketing Manager, should be picked up as the best employee this year, simply because of the value and experience she brings to our company.\\nOf course, we all know how Rebecca Graham works tirelessly to motivate her entire crew of salespeople to increase the sales of our company, but what most of us do not know is that she always likes to visit the clients and dealers of our company by herself in order to get the feedbacks of our customers in real-time. Besides, she also works extra hours to train and teach her subordinates who fail to achieve their monthly sales targets in this very competitive market.\\nSo, once again, considering the contribution of Rebecca Graham, I believe she deserves to be the best employee in our company.\\nYours sincerely,\\nJonathon Louis\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.82 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
