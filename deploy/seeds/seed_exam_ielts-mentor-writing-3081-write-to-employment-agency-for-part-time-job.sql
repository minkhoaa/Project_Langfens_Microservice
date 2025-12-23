-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:52.599759
-- Source: ielts-mentor.com
-- Title: Write To Employment Agency For Part Time Job
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write To Employment Agency For Part Time Job';

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
  E'Write To Employment Agency For Part Time Job',
  E'You should spend about\n20\nminutes on this task.\nYou are looking for a part-time job. Write a letter to an employment agency.\nIn your letter:\n- introduce yourself\n- explain what sort of job you would like\n- say what experience and skills you have\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to express my interest to get registered with your employment agency as I am looking for a suitable part-time job. I am hoping you would enlist me in your database and notify me of suitable job announcements and forward my resume to prospective employers.\\nI am Hansen Lee, an international student at the University of Westminster and my major is Business Administration. I am originally from Japan and will be staying in London for the next couple of years. To support my education cost and to gain some job experience, I am seeking a suitable part-time position.\\nI can work as an administrative assistant, customer experience manager or as a salesperson in a retail shop. I can spare time from 4.30 pm onwards on weekdays and full-time on weekends.\\nI have previously worked as a customer support officer in a call centre in Japan and as a sales executive in a superstore in London. I have attached my Curriculum Vitae with this letter for your kind consideration which further details my education and work experience.\\nI look forward to hearing from you and getting the details process to register with your job agency. Thank you in advance.\\nYours faithfully,\\nHansen Lee", "Dear Sir or Madam,\\nI have heard a lot about your employment agency because of your dedicated service to help people find employment. So, I am hoping that you would also help me find a suitable part-time job.\\nBut, before anything else, let me introduce myself. I am currently living in Kuala Lumpur and have just finished my Master’s degree in travel and tourism management from the University of Malay. And, now I would like to work as a part-time employee at an established tourist information centre.\\nAnyway, as far as my experience and skills are concerned, I have worked as a part-time customer service representative at a very busy and upscale 4-star hotel in the city where I am currently living now. Besides, I have also worked as a Cashier at a restaurant when I was finishing my Bachelor degree. Then, I can also speak the Chinese language, in addition to having great communication skills in English.\\nSo, based on my credentials and skills above, please help me find a suitable part-time job for me, preferably in the city where I am currently living now.\\nYours faithfully,\\nMohamed Zikri\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nAjit Sethy\\n3 years 11 months\\nApplication to employment Exchange Officer for registration.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
