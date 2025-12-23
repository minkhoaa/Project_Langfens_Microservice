-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:12.597983
-- Source: ielts-mentor.com
-- Title: You Are Applying For Job And Need Letter Of Reference
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Applying For Job And Need Letter Of Reference';

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
  E'You Are Applying For Job And Need Letter Of Reference',
  E'You should spend about\n20\nminutes on this task.\nYou are applying for a job and need a letter of reference from someone who knew you when you were at college.\nWrite a letter to one of your old teachers asking for a reference. In your letter:\nsay what job you have applied for\nexplain why you want this job\nsuggest what information the teacher should include\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Hampson,\\nI am Muller Fortner, one of your research assistants and lucky students, whom you have bestowed your blessing, wisdom and guidance during my academic years at MIU University. Today, I am writing to ask a favour from you- to write a reference letter for me that I would require to submit to a prospective employer.\\nI have been one of your most ardent students and we have finished several projects together including the \\"Impact of Western attitude to developing countries\\" which was published in \\"The Social Affair\\" magazine. After I have completed my post-graduation in Social Science from MIU University in December 2024, I have been trying to start a job and recently I have been invited to an interview as a researcher at Social Hub, an international company that works for social welfare in many countries.\\nI applied for the job because it would enable me to closely work with other talented researchers and let me contribute to great social causes. I hope you would be happy if I get the job and continue doing the things you always wanted me to do.\\nI hope you would be kind enough to write a reference letter for me mentioning how you know me, my strength, academic performance and how I might be suitable for a research-based job.\\nThank you in advance. I look forward to getting your reply soon.\\nRespectfully yours,\\nMuller Fortner", "Dear Mr Joey Morgan,\\nIt is great to have this opportunity to communicate with a great and learned person like you again, and I also hope that you are doing well.\\nActually, I am writing this letter to request you to write me a letter of reference since I have applied for the position of Quality Control Officer at a very prestigious garments factory in our country. By the way, this job would prove out to be important for me since it would allow me to gain some valuable experience in different kinds of garments items before starting my own clothing exporting business someday.\\nThe garments factory authority has no problem with my qualifications, skills and other credentials, but they want to learn a bit more about my academic life, extra-curricular activities, soft skills as well as my professional life, and hence the request for the reference letter. They want to know things like how serious and punctual student I really was as a college student, and what soft skills I had as a student.\\nSo, I would like to request you to prepare a letter of reference for me so that I can finally get the job to fulfil my ultimate career aspiration.\\nYours sincerely,\\nPeter Comb\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.90 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nZakir Siraj\\n11 years 3 months\\nFor IELTS preparation.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
