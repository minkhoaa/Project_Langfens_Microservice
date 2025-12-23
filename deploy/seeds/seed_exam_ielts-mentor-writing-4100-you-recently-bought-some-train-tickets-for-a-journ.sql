-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:32.179457
-- Source: ielts-mentor.com
-- Title: You Recently Bought Some Train Tickets For A Journey
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Recently Bought Some Train Tickets For A Journey';

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
  E'You Recently Bought Some Train Tickets For A Journey',
  E'You should spend about\n20\nminutes on this task.\nYou recently bought some train tickets for a journey a week in advance. When you went to the station to catch the train, you were told you could not use the tickets and the staff were very unhelpful to you.\nWrite a letter to the train company. In your letter,\ndescribe the problem you had with the tickets\nsay why you were unhappy with the staff\nsuggest what action the train company should take\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to formally complain about an issue I faced while attempting to travel with your company a week ago.  I hope you will take the necessary actions to address the issue and make sure it does not happen in the future.\\nIn relation to the problem that I faced, on 5th February, I purchased three train tickets online for a journey from Manchester to London on 11th February. However, upon arriving at the station with my parents, I was informed that our tickets were invalid, despite having received confirmation at the time of purchase. The explanation from your staff was vague and I was not given a clear reason why our tickets were not valid for the journey!\\nWhat disappointed me even more was the unhelpful attitude of the staff. Instead of assisting me in resolving the issue, they simply stated that I could not board the train and made no effort to explain the reason behind it. Their dismissive behaviour left me and my parents feeling frustrated and stranded, especially as we had important commitments in London that day.\\nGiven this inconvenience, I kindly request a full refund for our unusable tickets and proper compensation for the situation. Additionally, I urge you to provide better staff training in customer service to ensure passengers receive appropriate support in such situations.\\nI look forward to your prompt response.\\nYours faithfully,\\nEva Watson", "Dear Sir or Madam,\\nI am writing to formally express my disappointment regarding an issue I encountered while travelling with \\"VIA Rail Canada\\" on February 25, 2025. I had purchased two economy class tickets (Booking Reference: VRC123456) a week in advance for travel from Toronto Union Station to Montreal Central Station on Train #64, departing at 9:30 AM. However, upon arrival at the station, I was informed that my tickets were not valid, despite presenting the booking confirmation.\\nMoreover, the station staff were extremely unhelpful and dismissive. Instead of assisting me in resolving the issue, they repeatedly insisted that my only option was to purchase new tickets at a significantly higher price. When I asked for clarification on why my pre-booked tickets were not valid, I received vague and unprofessional responses, which left me frustrated and stranded.\\nI expect VIA Rail Canada to take responsibility for this inconvenience. I request a full refund for the tickets I was unable to use and a formal explanation of why this issue occurred. Additionally, I urge the company to improve staff training to ensure better customer service in the future.\\nPlease respond at your earliest convenience, as I would like to resolve this matter promptly.\\nYours faithfully,\\nJacob Hall\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (5 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nHarman\\n8 months 2 days\\nGood website for IELTS.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
