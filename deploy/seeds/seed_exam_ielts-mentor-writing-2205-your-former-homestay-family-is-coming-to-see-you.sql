-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:15.962080
-- Source: ielts-mentor.com
-- Title: Your Former Homestay Family Is Coming To See You
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Former Homestay Family Is Coming To See You';

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
  E'Your Former Homestay Family Is Coming To See You',
  E'You should spend about\n20\nminutes on this task.\nYour former homestay family is coming to see you in your home country and stay from January 31st to February 10th.\nWrite them a letter. In your letter:\nmake plans to meet them at a convenient location\nspecify a time and date\nsuggest some activities you may all participate in during their visit\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr & Mrs Johnson,\\nI trust you are doing fine and enjoying the season. I am surprised to hear that you are visiting the United Kingdom in a few days and I am really happy about it. I am sure you will enjoy your holiday here and the climate at this time of the year is bright and sunny. I cannot wait to meet you.\\nAs you have already said, you are going to stay in a hotel in London. My house is almost 10 hours driveway from London city centre. I hope you will be free on February 4th so that we can meet on that day. When you come to Belfast, give me a ring or send me an SMS two hours prior so that I can meet you there. Early morning (around 9:00 am) would be better but I can meet you anytime you want. We will have our lunch together in a restaurant where I went many times and I quite like their environment and food.\\nThere are many tourist spots in Belfast so I am sure you both will enjoy your time. I will be very glad if you agree to stay at our home for a couple of days as my parents are very eager to meet you. I have told them about you and they are expecting you. During your stay at our home, we can go to see popular historical museums, beaches, amusement parks and other attractive places near my hometown. We would love to give you a taste of our traditional food.\\nLooking forward to seeing you both soon.\\nSincerely yours,\\nSonia Vincent\\n[", "Dear Mr Shawn,\\nI must tell you how excited I am after learning the news that you will be visiting my country from January 31st to February 10th. In fact, right after reading your letter, I started to check the information on all the good hotels in my country in case if you are not too sure where to stay or what kind of hotels to choose.\\nIt seems like I have not seen you in ages, and so I do not like to waste any time meeting you as soon as you come to the airport. Just let me know the exact time when you would arrive at the airport, and I will pick you up from there. But, if you do not want me to receive you at the airport, I can meet you at the famous “Cherry Shopping Mall” in our capital city on the 10th of January at around 5:00 pm.\\nBy the way, I have already made some plans to take part in some activities, such as visiting the largest botanical garden in my country as well as enjoying the complete view of our capital city at night from the tallest tower.\\nHave a safe flight. See you soon.\\nYours sincerely,\\nChris Reid\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (6 Votes)\\nIELTS Letter Writing\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nNazia\\n7 years 8 months\\nDear Mr and Mrs Khan,Hope you are all doing great and this letter finds you in good spirit. I am delighted to know that you are planning to visit my country next month. I am sure you will enjoy your vacation in my homeland with your friends and family.As per your travel itinerary, you will arrive at the Pakistan International Airport on 31st January and will stay in Karachi up until 10th February. You also wrote that you will stay with your friend at Landhi Town. I would love to meet you all as soon as possible. I invite you to visit my house which is only 40 minutes drive from your friend''s house. However, I would like to meet you sometime during the first week of your arrival. I can meet you at a restaurant, preferably at the sea view restaurant, near the place you will reside.We can spend some time at sea view restaurant and enjoy the sunset at the beach. Afterwards, we can order a few traditional foods and can enjoy our dinner together. As you are visiting my homeland for the first time, I would suggest you visit the National Museum, Tomb of Quaid-e-Azam, Sea Port and Food Streets. I can accompany you to a few famous shopping malls where you might do some shopping. I am very much excited about your trip and hope that we will spend quality time. Looking forward to welcoming you soon.Regards,Nazia\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
