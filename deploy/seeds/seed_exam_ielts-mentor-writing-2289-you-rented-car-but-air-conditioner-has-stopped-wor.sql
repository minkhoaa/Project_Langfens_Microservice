-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:13.266477
-- Source: ielts-mentor.com
-- Title: You Rented Car But Air Conditioner Has Stopped Working
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Rented Car But Air Conditioner Has Stopped Working';

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
  E'You Rented Car But Air Conditioner Has Stopped Working',
  E'You should spend about\n20\nminutes on this task.\nYou rented a car from a car rental company. The air conditioner has stopped working. You phoned the company a week ago but it still has not been repaired.\nWrite a letter to the company. In your letter\nintroduce yourself\nexplain the situation\nsay what action you would like the company to take\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nI am writing to draw your attention to a problem with the car I hired from your company, Phillip Car Rental, City Center branch in Colombo, on 24th November. I rented it for a month and paid fifteen days'' rent upfront. The cooling system of the car stopped working the day after I rented it and even after my written complaint, it has not been sorted out. I am hoping that you would either fix it or replace it with a good one.\nI am a regular customer of Phillip Car Rental company - registered customer number CCR321 and this time I took a Toyota Corolla car. During the time of hiring, the car was working fine. However, on the next day, while travelling to the airport to drop off my uncle, I felt the air condition was not working properly and now it is completely dead. I brought this issue to your office a week ago and was promised an immediate solution. Nevertheless, the issue is yet to be resolved.\nAccording to the rental agreement, I am entitled to have a solution to this problem. I would be grateful if you could repair the air conditioning system of the car within the next 24 hours or replace it with another one. Otherwise, I would have to register a complaint to the consumer rights authority.\nI look forward to hearing from you soon.\nYours faithfully,\nJanak Senevirathne\n[Written by - Janaka]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to draw your attention to a problem with the car I hired from your company, Phillip Car Rental, City Center branch in Colombo, on 24th November. I rented it for a month and paid fifteen days'' rent upfront. The cooling system of the car stopped working the day after I rented it and even after my written complaint, it has not been sorted out. I am hoping that you would either fix it or replace it with a good one.\\nI am a regular customer of Phillip Car Rental company - registered customer number CCR321 and this time I took a Toyota Corolla car. During the time of hiring, the car was working fine. However, on the next day, while travelling to the airport to drop off my uncle, I felt the air condition was not working properly and now it is completely dead. I brought this issue to your office a week ago and was promised an immediate solution. Nevertheless, the issue is yet to be resolved.\\nAccording to the rental agreement, I am entitled to have a solution to this problem. I would be grateful if you could repair the air conditioning system of the car within the next 24 hours or replace it with another one. Otherwise, I would have to register a complaint to the consumer rights authority.\\nI look forward to hearing from you soon.\\nYours faithfully,\\nJanak Senevirathne\\n[", "Dear Sir or Madam,\\nMy name is John Timothy, and I rented a car from your company on 24th June. Unfortunately, the car has a major problem and need your attention to fix the issue.\\nAs per the rental agreement, I would keep the car for three weeks, and if there are any problems with the car, your company would take care of them as quickly as possible. But, it looks like your rental company is not following through with the agreement terms. To explain the situation, the AC of my car stopped working within a couple of days of renting it. I immediately called your company to fix it, but after 5 days, it still has not got fixed.\\nPlease understand that I travel quite a lot in this scorching heat, and I do not see a chance that I can do it for another day without the AC. Therefore, based on the problem, I would highly appreciate it if you fix the car today. But, if that is not an option, please give me another car without any problem.\\nI hope to hear from you soon.\\nYours faithfully,\\nJohn Timothy\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.53 (15 Votes)\\nIELTS Letter Writing\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nIELTS Mentor\\n8 years 6 months\\nDear Sandy, we will have more rigid moderation on those contents. Thanks for your great recommendation.\\nReply\\nQuote\\nSandy\\n8 years 6 months\\nMentor team,Before uploading such letters, I guess your team should review the contents, especially grammar. Let''s say, the letter"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
