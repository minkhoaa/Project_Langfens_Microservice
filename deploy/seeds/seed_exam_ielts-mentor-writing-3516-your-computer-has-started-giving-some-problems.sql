-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:09.224717
-- Source: ielts-mentor.com
-- Title: Your Computer Has Started Giving Some Problems
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Computer Has Started Giving Some Problems';

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
  E'Your Computer Has Started Giving Some Problems',
  E'You should spend about\n20\nminutes on this task.\nYou have been working in a company for the last two years. Recently, your computer in the office has started giving some problems and it is affecting your work performance.\nWrite a letter to your manager. In your letter,\ndescribe the problem\nexplain how it is affecting your work\nwrite what you want him to do regarding it\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Mr / Mrs ...............,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Wayne,\\nI understand that you probably do not want to hear about another issue amid so many other problems, but I just do not have any other option but to inform you of the issue. The problem, I am talking about, is related to my desktop computer which I have been working with for the last one year so.\\nIn fact, my computer is giving me trouble on and off for more than a month as it keeps freezing on me momentarily, forcing me to stop my work until it comes back again. Sometimes, my computer becomes so hot that I become a little afraid to even touch it after working on it for a bit longer period of time. Needless to say, it is also running out of memory since many different pieces of software have been installed in it over the years, which is actually making the machine run even slower.\\nNaturally, because of these reasons, the productivity at my work is getting affected rather negatively. It takes me more time to finish a task that should not have taken such a lengthy time. It demotivates me as well.\\nTherefore, I would really appreciate it if you take proper steps to arrange to have a technician fix my computer at your earliest convenience.\\nYours sincerely,\\nRob Freeman\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.88 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nIkemefuna Eze\\n3 years 3 months\\nDear Mr Eze,\\nI am writing this letter to express my dissatisfaction with my computer in the office. While I never wanted to bother you with this problem, I think I am left with no option but to let you know about it, so there could be a replacement or at least get a technician to fix it, as this is affecting my performance at work.\\nLet me explain my situation in detail. Recently, my operating system has started showing some strange signs of problems like hanging or shutting down all of a sudden. Moreover, the keyboard that I use has also started showing a problem. I found out that some of the keys are not working very well. Keys such as the shift, control, Alt, and F2 often have partial contacts, and other times, do not function at all. A situation like this has adversely slowed down my work, consequently affecting the turnaround time in delivering my tasks.\\nI would like to suggest that please arrange to replace this keyboard for me and contract a technician to help with the operating system issue.\\nThank you for your usual consideration.\\nYours Faithfully\\nMary Ike\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
