-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:00.909409
-- Source: ielts-mentor.com
-- Title: You Are Going To Spend Vacation In City In Foreign Country
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Going To Spend Vacation In City In Foreign Country';

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
  E'You Are Going To Spend Vacation In City In Foreign Country',
  E'You should spend about\n20\nminutes on this task.\nYou are going to spend your vacation in a city in a foreign country. You have never been there before. Your cousin has a friend who lives there.\nWrite a letter to your cousin''s friend. In your letter,\nintroduce yourself\nsay why you are making this trip\nask some questions about the city (e.g. places to see, things to do, things to bring)\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Ethan,\\nHope you are doing great. I am Pollard Jeremy, a maternal cousin of Gill from Canada and have heard a lot about you from him. I am writing to say hello and get some information about Melbourne, where I will visit next month with my wife and daughter.\\nGill must have informed you that I might write to you and I truly appreciate your time as I know you are terribly busy. However, when I mentioned my trip to Gill, he enthusiastically recommended you. You might remember me from the wedding ceremony of Gill last year when he introduced you to me.\\nI am planning to spend some quality time in Melbourne where I solely intend to spend the summer holidays with my family. I have done some online research and learned a few things about Melbourne but this is my first trip to Australia and I thought you would be the best person to recommend to me some hotels, tourists spots, child-friendly amusement parks and dining places. I intend to stay for around one month and would like to be on my budget. Are there any tips for daily commuting? What type of dresses should we bring to Melbourne during this time?\\nI do not know anybody there and your tips would be a great help to me.\\nNo more today. Stay fine and write back to me at your convenience.\\nWarm wishes,\\nPollard", "Dear Mr Rudy,\\nHope this letter doesn’t come to you as a surprise since we have never met before. Actually, I am a cousin of Alex Turner, who is a friend of yours, and he suggested me that I should write to you and ask for some information from you before visiting \\"Athens\\" where you are currently living in. By the way, I am planning to visit Athens because I have got two weeks'' vacation from my work, and I want to spend it in a beautiful European city and Athens is my first choice.\\nAnyway, given the long period of time you have lived in this city, I am sure that you would be able to guide me properly and provide me with some information about the place before visiting it. So, can you please tell me about the weather of that place during the months of March and April? How expensive is the taxi service there? Besides, I would also like to get some information about what kinds of food and drinks are popular there, and what are my options as far as finding some affordable accommodation is concerned.\\nI will wait for your response.\\nYours sincerely,\\nDavid Russett\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.67 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSk\\n8 years\\nGT Writing Task Topic 1: You are going to spend your vacation in a city in a foreign country. You have never been there before. Your cousin has a friend who lives there.Write a letter to your cousin''s friend. in your letter Introduce Yourself Say why you are making this trip Ask some questions about the city (e.g. places to see, things to do, things to bring)Letter Answer: Dear Annie,Hope you are doing well. I am Sita, a close friend and relative of Isabella, from Turkey. I assume she has already called you and you have heard my name from her. I am Isabella''s second maternal cousin, residing in Brooklands Wille area. I am doing my Masters degree in Social Work. I have planned to visit your city during my winter vacation, possibly in mid-November, and do some works for my charity project and I thought you would be the best help I can manage in a city unknown to me. I haven''t been to Italy, though I have always wanted to. I have booked my hotel and would love to meet you in the first week of my arrival to take your suggestion about the best places to be and things to do. I wish you would join me. This would be fun. I would love to learn Italian way of living firsthand and wishing you would guide me. Also, I am longing to taste some Italian delicacies as they are my favourite. I heard the temperature would be quite low at that time. Any suggestion for me to pick appropriate dresses? Awaiting your reply as soon as possible.All the bestSita\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
