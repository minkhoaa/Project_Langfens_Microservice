-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:48.999222
-- Source: ielts-mentor.com
-- Title: You Would Like Some Time Off From Your Work To Complete Qualification
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Would Like Some Time Off From Your Work To Complete Qualification';

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
  E'You Would Like Some Time Off From Your Work To Complete Qualification',
  E'You should spend about\n20\nminutes on this task.\nYou are studying for a qualification, and you would like some time off from your work to complete it.\nWrite a letter to your manager. In your letter:\nask for some time off to complete the qualification\nsuggest what you will do later at work if you have time off\nsay how the qualification will help your job or company\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to seek your approval to take 10 days off work in order to complete my term final and thesis paper for my MBA course. I am hoping that you would allow me to take the time off work from 8th November 2025 to 17th November 2025.\\nI am pursuing my MBA degree from Edinburgh University and to complete it, I need to submit my thesis paper by 15th November and take a few exams. I have 10 days of paid annual leaves and I have saved those for my term final. Now I am hoping to use those leaves and finish my MBA.\\nDespite my leave from the office, I will check my emails daily, respond to important ones and be available for emergency phone calls. Besides, I have already talked to James and he is ready to take a few important responsibilities of mine in the meantime. Once I get back to the office, I would endeavour to come earlier than usual and work on weekends, if needed, in order to catch up on anything I had missed.\\nI realise my temporary absence could be an inconvenience to the office but in the long run, our company will benefit from my knowledge and thesis activity which involves an empirical investigation into the impact of leadership on organisational performance. Since our company is considering a few training sessions for the team to enhance the leadership quality, my expertise could be useful.\\nI am looking forward to receiving your approval for the leave.\\nYours faithfully,\\nDavid Ferrer", "Dear Sir or Madam,\\nI am writing this letter to explore the possibility of having a fortnight off from my work, from 12th June to 27th June, in order to complete my Advance diploma course in Digital Business and Trade.\\nI am almost finished with the course, and now all I need to do is take the final exams which will start within two weeks. Luckily, I still have some unused annual leaves, and I want to finally use them up by taking the final exams to finish my diploma course. Having said that, however, if my company still feels that I would need to make up for those missing days at work, I would be more than happy to work on the weekends as well as show up early at work once the exams are over.\\nFor your kind information, this particular certification is important for me and the company since it will help me, in the capacity of a Senior Marketing Manager, to better position my company to tap into a huge number of prospective customers who want to buy our products online.\\nI look forward to hearing from you.\\nYours faithfully,\\nKelly Bower\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.94 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nAdari Durga Dora\\n4 years 3 months\\nDear Mr. Brown,\\nI am writing this letter to seek your permission to take one month''s leave to get over with my MBA exams.\\nI joined the MBA course last year at Andhra University, and a few days ago, the examination circular was released. I need to submit my thesis paper by 31st August this year and later take a few exams. I have 15 days of paid leaves and I have saved those for my final term exams. Now I am hoping to utilize those and finishing my MBA course.\\nDespite my leaves from the office during this month, I would be able to frequently check my emails and receive emergency phone calls. Besides, I have talked to Mr. Shiva for keeping me updated in the meantime. Once I get back to the office, I will work on weekends if needed in order to cover up any pending tasks.\\nI know my absence could be an inconvenience to work but in the long run, the company will benefit from my knowledge and thesis activity. Since our company is seeking a few training sessions for the team to enhance leadership qualities, I believe after I complete my MBA, I would be able to conduct those training sessions. It would be helpful for our employees as well as the companies.\\nI am looking forward to receiving your positive reply in this regard.\\nYours faithfully,\\nDurga Dora Adari\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
