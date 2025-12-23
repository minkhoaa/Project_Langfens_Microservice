-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:38.605081
-- Source: ielts-mentor.com
-- Title: You Are Going To Have Family Party In Hotel
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Going To Have Family Party In Hotel';

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
  E'You Are Going To Have Family Party In Hotel',
  E'You should spend about\n20\nminutes on this task.\nYou are going to have a family party in a private room in a hotel.\nWrite a letter to the hotel manager.\nIn your letter, say:\nwhy you need to use this private room\nwhat you need them to provide for the party\ninquire about the price of the food you are ordering\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a local resident of Melbourne, writing to inquire about the availability of the private gala in your Rendezvous Hotel Melbourne on 27th November.\\nWe will rejoice in our parents'' 50th anniversary, a very special occasion for all of us, and have decided to celebrate the event at your hotel''s gala. We are expecting approximately 50 guests on the occasion. The ceremony is on 27th November and we are planning a dinner party and would like to rent the venue for the evening.\\nYou should be in charge of a buffet dinner for the guests, drinks, decoration and supervision of the event. We would need a projector and a large screen to share some wonderful memories of our parents at the event. Make sure there is an electricity backup. This is a distinctive event for us and we want to make it remarkable.\\nPlease inform me if the venue is available on that day and how much it would cost to hire it. Also, specify the menu and drink items in the buffet and their prices including GST. I would appreciate it if you can share your idea of decoration as well.\\nYours faithfully,\\nSarah Pauline\\nModel\\nAnswer 2:\\nDear Sir or Madam;\\nI intend to book a party venue at your hotel on 15th December 2023 and writing to inquire about its availability. Besides, I need information about the buffet menu for lunch, some additional facilities and their prices.\\nI and my wife have decided to celebrate our 5th marriage anniversary on 15th December. We are expecting approximately 30 guests and for that, we need a large party hall that comes with a reception area and private facilities. Furthermore, I need some arrangements for that day - a comprehensive buffet menu, anniversary cake with a greeting written on it, elegant decoration, drinks, soft music and some exciting toys for the children. A few of the guests are vegetarians, and we need your buffet to be vegetarian-friendly.\\nFinally, I am expecting you to have some staff members ready to serve the guests. I would be grateful if you could confirm the availability of your venue, and then send me the menu along with the prices for the food and service.\\nI am looking forward to your prompt reply.\\nYours faithfully,\\nRaymond Joseph\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.70 (15 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nRequesting-information-letter\\nInquiry Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
