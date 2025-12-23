-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:40.306403
-- Source: ielts-mentor.com
-- Title: Letter To An Employment Agency For Part Time Job
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To An Employment Agency For Part Time Job';

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
  E'Letter To An Employment Agency For Part Time Job',
  E'You should spend about\n20\nminutes on this task.\nYou are looking for a part-time job. Write a letter to an employment agency.\nIn your letter:\n- introduce yourself\n- explain what sort of job you would like\n- say what experience and skills you have\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,\nSample Answer 1:\nDear Sir or Madam,\nI am Sebastian Holmes, looking for a part-time job in a graphics designing company and would like you to forward my CV to suitable companies.\nI have recently finished my high school diploma and would like to gain some professional experience. One of my high school friends, who recently managed a job through your agency, has recommended me your agency. I have a graphics design diploma certificate and experience in designing website mockups. I am passionate about designing websites, banners, advertisements, landing pages and logos, and looking forward to working for a company that works in the web designing industry.\nSince experience and not remuneration is my priority, I would like to work for a renowned company that solely works in the web and graphics designing industry with a credible portfolio. I will get admitted to a college in a month or two, and that is why flexible office time is another aspect I am looking for.\nI hope you would have a look at my CV, which I am also sending to you in the same envelope, and help me find a suitable job that I am so eagerly looking forward to having.\nYours faithfully,\nSebastian Holmes',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Sebastian Holmes, looking for a part-time job in a graphics designing company and would like you to forward my CV to suitable companies.\\nI have recently finished my high school diploma and would like to gain some professional experience. One of my high school friends, who recently managed a job through your agency, has recommended me your agency. I have a graphics design diploma certificate and experience in designing website mockups. I am passionate about designing websites, banners, advertisements, landing pages and logos, and looking forward to working for a company that works in the web designing industry.\\nSince experience and not remuneration is my priority, I would like to work for a renowned company that solely works in the web and graphics designing industry with a credible portfolio. I will get admitted to a college in a month or two, and that is why flexible office time is another aspect I am looking for.\\nI hope you would have a look at my CV, which I am also sending to you in the same envelope, and help me find a suitable job that I am so eagerly looking forward to having.\\nYours faithfully,\\nSebastian Holmes", "Dear Sir or Madam,\\nI have heard about your employment agency from my friend who recently got a two-year work placement at a Japanese company, courtesy of your wonderful efforts. Not to mention, of course, after hearing the success story from my friend, I have also decided to reach you and request you find a suitable part-time job for me.\\nTo introduce myself a little, I am a Greek national and currently studying at a university as a final-year student, majoring in Accounting Information Systems, here in Montreal. My current GPA is 3.5 if it really matters.\\nAs for what sort of job I want, an office job, preferably as an Accounting Clerk or Data Entry Operator would be a very ideal one. I should also have no problem working as a part-time Office Administrator, provided that the schedules, I am offered, do not conflict with my class schedules.\\nNow regarding my experience and skills, I have a very good typing speed, and I am very much computer literate. Besides, I am also good at multitasking, and I can speak little French, other than having a very good fluency in the English language.\\nI hope you would help me find a part-time job as soon as possible. Thank you in advance.\\nYours faithfully,\\nZoe Laskari\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.04 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
