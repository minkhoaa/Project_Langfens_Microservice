-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:03.790069
-- Source: ielts-mentor.com
-- Title: Letter To Hotel Manager Expressing Your Interest For Job
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Hotel Manager Expressing Your Interest For Job';

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
  E'Letter To Hotel Manager Expressing Your Interest For Job',
  E'You should spend about\n20\nminutes on this task.\nYou have seen an advertisement for a ''weekend work'' in a hotel in the town where you are staying. You have worked in a hotel before and think that the job would be suitable for you. Now you want to apply for the job.\nWrite a letter to the hotel manager expressing your interest. In your letter,\nintroduce yourself\nexplain why you think you would be suitable for the job\nask what work you would be expected to do\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nI am writing to apply for the part-time weekend job at your hotel that you advertised in the ''Daily Sunday Times'' newspaper on 5th July 2025. I have similar job experiences and I am hoping that you would look at my resume which I am attaching with this letter and consider me for the job.\nI am Preeti Ghuraiya, studying a general management course at Garden City College, Bangalore and I can fluently speak English and Hindi. This job opportunity looks very interesting and something in line with my work experience.\nI have worked as a receptionist and a front desk executive with Hotel Holiday Inn in Delhi from June 2021 till March 2024. I was responsible for interacting with clients, handling client check-in and checkout and so on. I also have some experience as a waitress. I believe my job experience would help me perform my responsibilities effectively in your hotel.\nThe job description in the newspaper does not give details of the responsibilities. Would you be able to let me know about the duties that I will be required to do and if you require any specific skills? I can start immediately and can work for the whole day every weekend.\nPlease let me know if you need further information regarding my job experience and education. I will be able to provide references for my experience.\nLooking forward to meeting you to discuss further.\nYours faithfully,\nPreeti Arora\n[ Penned by - Preeti]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to apply for the part-time weekend job at your hotel that you advertised in the ''Daily Sunday Times'' newspaper on 5th July 2025. I have similar job experiences and I am hoping that you would look at my resume which I am attaching with this letter and consider me for the job.\\nI am Preeti Ghuraiya, studying a general management course at Garden City College, Bangalore and I can fluently speak English and Hindi. This job opportunity looks very interesting and something in line with my work experience.\\nI have worked as a receptionist and a front desk executive with Hotel Holiday Inn in Delhi from June 2021 till March 2024. I was responsible for interacting with clients, handling client check-in and checkout and so on. I also have some experience as a waitress. I believe my job experience would help me perform my responsibilities effectively in your hotel.\\nThe job description in the newspaper does not give details of the responsibilities. Would you be able to let me know about the duties that I will be required to do and if you require any specific skills? I can start immediately and can work for the whole day every weekend.\\nPlease let me know if you need further information regarding my job experience and education. I will be able to provide references for my experience.\\nLooking forward to meeting you to discuss further.\\nYours faithfully,\\nPreeti Arora\\n[ Penned by - Preeti]", "Dear Sir or Madam,\\nI am writing this letter to express my interest in a part-time weekend work position at your hotel, which was advertised in one of the local newspapers in our town a couple of days ago.\\nTo introduce myself a little, I am a 21 years old university student, and I am currently studying in my final year at City University. My major is \\"Hotel and Tourism Management\\" and I am looking for a part-time job in a hotel to gain some hands-on knowledge. Since I live in the same town, I have had the opportunity to see your hotel. I also know how your hotel business contributes to the local economy of our town.\\nAnyway, I think that I would be able to offer a great service to your hotel since I have already worked at a hotel in the past as a part-time Front Desk Officer. Besides, I have also worked as a part-time waiter at one of the busiest restaurants in our town. Moreover, I am energetic, and I have good communication skills.\\nFinally, I am willing to start as soon as you ask me, only if you choose to hire me and tell me exactly what my roles and responsibilities should be at your hotel.\\nHope to hear from you soon.\\nYours faithfully,\\nChuck Moore\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.80 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSam\\n8 years 5 months\\nDear Sir/Madam,I am writing this letter in reference to your advertisement on ABC for hiring a weekend support staff in your hotel. I am 20 years old and live in the southern area of the city. I am studying Hotel Management at MVT Institute and will graduate next year. I am looking for a weekend job which can add values to my resume and where I can contribute from experience and knowledge.I have 1 year''s experience as an Account specialist in Holiday Inn, Delhi. I was responsible for bookings, arranging team dinners, customising rooms to check-out for selected corporate clients. I am well versed with Hotel''s day to day operations.The advertisement was very brief and did not mention about job responsibilitie s. Can you please share the job description, any specific skill set you are looking for?I will be happy to answer in person or over phone.Yours sincerely, (Name)\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
