-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:05.112282
-- Source: ielts-mentor.com
-- Title: You And Your Family Are Planning To Spend Weekend At Seaside Hotel
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You And Your Family Are Planning To Spend Weekend At Seaside Hotel';

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
  E'You And Your Family Are Planning To Spend Weekend At Seaside Hotel',
  E'You should spend about\n20\nminutes on this task.\nYou and your family are planning to spend a weekend at a seaside hotel.\nWrite a letter to the hotel for making the arrangement. In your letter say,\nwhen you will be arriving and leaving\nwhat type of rooms you would like and ask how much the weekend will cost\ninquire about activities and places of interest near the hotel\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to you to make the necessary arrangements for our stay at your hotel on 22nd and 23rd November. I will travel with my parents, wife and 7 years old son. I am hoping that you would be able to provide us with suitable accommodation and assist us to enjoy our trip.\\nWe will arrive on 22nd November and check out from your hotel on 24th November before 12.00 pm. We are expecting two double size bedrooms with attached bathrooms, hot water and air cooler facilities. We would prefer rooms with a sea view and room service. I would really appreciate it if the rooms are on the same floor.\\nI am also interested to know about recreational activities in the vicinity. Despite my parent’s age, they are very lively and would love to go to the theatre, beach and amusement parks, if available. I would also like to know about the market, where we can buy traditional items and souvenirs.\\nPlease notify me of the cost that will incur on our trip at your earliest with the facilities you can offer. I am expecting a comprehensive reply from your side about the details of the activities and other information I requested.\\nI look forward to hearing from you soon.\\nYours faithfully,\\nFahad Sultan\\n[", "Dear Sir or Madam,\\nI am planning to spend a weekend with my family at your hotel and would like to request you to make the necessary arrangements for us. My wife and my daughter will accompany me and I hope you can arrange a large deluxe room for us from 14th July to 16th July. I am hoping that you would inform me of the availability of the room with a few other details at your earliest.\\nWe will be arriving on Thursday, 14th July at around 3:00 pm. We will spend the weekend and will check-out from the hotel on Saturday- 17th July, before 11.30 am. Please make sure that the room has a balcony, attached bathroom and air cooler and offers a sea view. Not to mention, the room should be large and adequately furnished.\\nKindly let me know the cost of spending the weekend at your hotel for the mentioned dates. Also, advise if you have any weekend package for the families.\\nWe will be visiting the place for the first time, so I would appreciate it if you could inform us about the places worth visiting.\\nThank you in advance.\\nYours faithfully,\\nMansoor Rahim\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
