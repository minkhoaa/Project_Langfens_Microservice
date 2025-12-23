-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:21.913299
-- Source: ielts-mentor.com
-- Title: Letter To Financial Organization That Gives Money To Students
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Financial Organization That Gives Money To Students';

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
  E'Letter To Financial Organization That Gives Money To Students',
  E'You should spend about\n20\nminutes on this task.\nYou have learned that a financial organisation in your city gives money as a loan to students who like to take a part-time course. You are interested to do the course and have decided to take a loan.\nWrite a letter to a local financial organisation. In your letter,\ngive your qualifications and work experience\ngive details about the course\nexplain how this course will help you\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,\nModel\nAnswer 1:\nDear Sir or Madam,\nI am writing to inquire about the student loan that your bank grants to aspiring students or professionals to help them finish skill development courses as part-timers. I am a graduate and my major is physics. I would like to apply for the loan your bank is offering.\nI have earned my bachelor degree from the University of Edinburgh in 2016 and have been working in a local manufacturing company since then as a junior executive. Now I feel that I need advanced computer skills to further my career and better perform in my work field.\nThe skill development course that I am planning to enrol in offers a comprehensive six-month-long curriculum intended to enhance the computing skills of professionals. It includes advanced MS Excel, Database Programming, Computer-aided Design (CAD), and many other aspects that a professional in the manufacturing sector can utilise.\nAs the use of computers and software is predominant in our organisation, I would not be able to perform excellently without the skills this course offers. The database concept and Computer-aided Design (CAD) can help me execute my daily tasks in a more efficient manner. To advance my career, I see no alternatives than to learn those. However, I need financial help as this course is expensive.\nI am hoping that you would disburse the loan so that I can take the course. I need a loan of not more than $3000, and I am willing to repay the monthly instalment incurred from the loan over the next two years.\nI would really appreciate your consideration and a positive reply.\nYours faithfully,\nNathan Adam',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to inquire about the loan your bank disburses to aspiring students for a few affiliated courses. I am willing to take a part-time Microsoft Office course at Skill Tech and hoping that you would grant me a small loan.\\nPlease, let me take a minute to provide you with some details about me and my background. I hold a degree in Internal Auditing, and most of my works are based on computers. To date, I have conducted internal audits of many organizations ranging from small companies to large public companies. But still, I don’t have facile command in Microsoft Office as most of my previous clients used the alternative software. I came to know that your organization grants fund up to one thousand dollars to students who want to take such courses. I believe this course will greatly help me in my upcoming audit assignments and will make me stand out from the rest of my peers.\\nMy intention in writing this letter is to ask that you consider acknowledging a self-motivated individual who could make the most of your funds. I would, therefore, request you to grand me a loan of $1000 which I am willing to repay within the next year.\\nHoping to receive your supportive reply soon.\\nYours faithfully,\\nSameed Qureshi\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
