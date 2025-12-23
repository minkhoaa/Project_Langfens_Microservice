-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:49.804097
-- Source: ielts-mentor.com
-- Title: You Are Organising Executive Event For Company
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Organising Executive Event For Company';

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
  E'You Are Organising Executive Event For Company',
  E'You should spend about\n20\nminutes on this task.\nYou are organising an executive event for the company you work for.\nWrite a letter to the person in charge of a venue that you are considering for the event and ask for detailed information regarding dates, services and costs.\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am pleased to inform you that we have chosen your resort as the venue for our company''s prestigious annual conference. I am responsible for the event''s planning and execution and hence writing for some details. I am hoping that you would answer my queries so that I can book it well in advance.\\nWe are planning to host the conference at the end of July and need the venue for the whole evening. Please notify its availability either on 24th or on 26th July. We are expecting 40 guests on the programme and need the menu for dinner and drinks. Some of our guests are coming from overseas so we will require some continental dishes. We also need a projector and electricity backup so that we can show some presentations to our overseas partners without any interruption. Kindly inform me of the breakdown costs of your service, venue, food and drinks in the return mail.\\nPlease be noted that the event is profoundly important for us and any sort of flaws will detriment our company''s image as well as yours so I hope you will be rigorous in providing your service.\\nI am looking forward to hearing from you soon.\\nYours faithfully,\\nJohn Augustin\\n[", "Dear Sir or Madam,\\nI am writing this letter to request some information about your conference centre which we are planning to reserve for an important official event on 15th August 2025.\\nTo give you some details about the event, we want to rent the conference centre from 5 pm to 10 pm in order to organise an annual award-giving ceremony for our top employees of the year, which will be attended by at least 100 people. During this period, we would also expect you to arrange some refreshments for us such as fresh coffee, fruit juice, and some top quality pastries. And, once we finish the party, we also want you to serve dinner for us. So please give me details of the venue, the menu you would arrange and other facilities that you can offer with the breakdown of the cost.\\nIn addition to that, we would also require a high-resolution LCD projector and a Wi-Fi connection facility for our Laptops. Please inform me if you can arrange that for us. Besides, the perfect seating arrangement for all of our 100 staff members is also expected. Finally, we also require facilities for welcome drinks for guests.\\nTherefore, based on these requirements, please provide a quote for all the prices which you will charge us for all the services we will use.\\nYours faithfully,\\nKatie Derham\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (4 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nInquiry Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
