-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:32.256814
-- Source: ielts-mentor.com
-- Title: You Had Holiday Overseas Where You Stayed With Some Friends
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Had Holiday Overseas Where You Stayed With Some Friends';

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
  E'You Had Holiday Overseas Where You Stayed With Some Friends',
  E'You should spend about\n20\nminutes on this task.\nLast month you had a holiday overseas where you stayed with some friends. They have just sent you some photos of your holiday.\nWrite a letter to your friends.\nIn your letter,\nthank them for the photos and for the holiday\nexplain why you didn''t write earlier\ninvite them to come and stay with you\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...............,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mark and Lucy,\\nHope you''re doing great. I had a great time with you guys. Thank you so much both for the remarkable holiday in your city and for the lovely photos that you sent me yesterday.\\nCanada is certainly a spectacular country with an extraordinary landscape, vibrant culture and wildlife, particularly up in the area where you are. The holiday is over, but I''ll never forget the way you treated me - it was fabulous.\\nSorry, it has taken me so long to write back and thank you. Almost as soon as I landed back in Italy, I got extremely busy with my office work. Besides, a severe cold forced me to take a few days off from the office, and I struggled to regain momentum at work and at home.\\nI would like to invite both of you to visit Italy. We''ll be celebrating our parent''s 40th marriage anniversary next month, and I expect you on this special occasion. I''ll take you to some of the famous places in Italy including Rome. Best known for housing ancient Roman structures and the Vatican City, Rome has stunning cathedrals and Renaissance architecture. I am sure you''ll enjoy your time here.\\nI would love to see you both soon. Take care and write back.\\nWarm wishes,\\nEmily", "Dear Thomas and Eva,\\nThank you so much for sending me the photos of the holidays that I spent with you guys over the last month. Believe it or not, it was one of the best holidays of my life with so many happy and joyful moments to cherish for a long time to come.\\nI especially remember our time at the famous beach restaurant where we enjoyed eating some of the biggest lobsters with garlic sauce and butter on the side. And, talking about the photos, I think the photos we took while riding on the horses at a horse ranch were some of the most natural-looking pictures I''ve ever taken.\\nBy the way, I must say sorry to you because I didn’t write to you early enough after receiving the photos from you. It is just that I got really busy dealing with some new assignments at work as well as moving to a new home.  Anyway, it is my turn to invite you to my place and spend some time with me because I think that you would like my new place.\\nWarm wishes,\\nSophia", "Dear David, James & Ethan,\\nHope you all are doing great. I cannot express how much I enjoyed my time with you guys, and how terribly I miss those days that I spent with you. I received your letter yesterday and was quite surprised to find some of the best pictures we took during our holiday in Singapore.\\nI guess this is the best opportunity to thank you for a great holiday and the fabulous pictures that would remind me of a grand tour to Singapore. As soon as I got back to Australia, I got busy with my thesis paper that I am supposed to submit before the end of the current semester. This is my last semester at the university and I will be free for a while after that and I would love to have you at my place.\\nWhy don''t you all come and visit me at the end of this December? I am sure we will have a magnificent time together.\\nStay fine and keep in touch.\\nWarm wishes,\\nAlex", "Dear Emma and Jenifer,\\nI cannot thank you enough for the hospitality you have shown me during my stay at your house. Also, I am writing to say thanks for the great photos you have couriered me. I am hoping you two would visit me during the summer vacation.\\nI was greatly surprised by the beauty of Venice in Italy and the days I spent with you. Each day was magical. The fabulous canals in Venice lined with Renaissance and Gothic palaces were heavenly. However, you two had been excellent hosts and I can never express how much I enjoyed my time with you. A huge thank you for making my holidays special and sending some of the very best photos we took during this holiday.\\nMy apology for not writing to you earlier. I had been busy with the office and I guess you already know how sometimes I struggle to manage everything in my life. I had to travel to Brisbane twice to meet my mom whose health condition is deteriorating these days.\\nI would love to have you both with me during the summer vacation. Please plan for the trip and I am sure you will enjoy your time in Australia. Take care and stay fine.\\nWarm wishes,\\nKelly", "Dear Phillip,\\nIt is so great to hear from you guys! Hope you all are doing fine. Just so you know, I am so happy and glad that you have sent me all those fabulous pictures from our short-lived but precious holidays that we enjoyed in your country last month.\\nNo doubt, your country, Italy, is way more exotic and beautiful than I initially expected. The food, lakes, coastline, colosseums, Venice canals, streets, shopping mall – all were so amazingly gorgeous! By the way, I would also like to especially thank you for organizing the trip to Venice canals for me because I thought that I was too tired to visit that exceptionally dreamy place. You all look so great in those pictures!\\nHowever, I am so sorry that I could not write to you earlier as I got insanely busy with my works, emails and papers which I needed to take care of immediately after coming back from that holiday. But, I surely would like for all of you to come and visit me in the next month when my office will remain closed for a few days.\\nYours sincerely,\\nRoger Stone\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.36 (22 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nAyesha Saad\\n4 years 3 months\\nGood.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
