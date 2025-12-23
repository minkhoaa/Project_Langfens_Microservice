-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:08.805925
-- Source: ielts-mentor.com
-- Title: The Manager At Your Company Is Going To Retire Next Month
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'The Manager At Your Company Is Going To Retire Next Month';

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
  E'The Manager At Your Company Is Going To Retire Next Month',
  E'You should spend about\n20\nminutes on this task.\nThe manager at the company you work for is going to retire next month. The manager’s assistant has invited some suggestions about what kind of event they should do to say goodbye to him.\nWrite a letter to your manager''s assistant. In your letter,\nsay what kind of event you have in your mind\nmention why you liked him/her as a manager\nwhat kind of present can be given to your manager\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Mr / Mrs...............,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Linda,\\nThank you for taking me into confidence to request some suggestions from my end regarding how to send a befitting farewell and “goodbye” to our manager, Mr Oliver. Well, while I have rather limited experience in these kinds of things, I would surely like to offer some suggestions in order to throw a successful farewell party for our manager at a nice hotel- preferably at Grand Boutique Party Centre and Hotel. I think a buffet lunch would be deserving and suitable.\\nOur manager deserves this kind of party because he truly has been an inspirational leader throughout the years through his hard works and diligence. Besides, his contributions to our overall marketing strategy and the daily operation of the department have ensured phenomenal growth for our company. But, what I really like the most about him is that he has never given up on any of his subordinates and instead has always taken personal initiatives to help us do better at our jobs.\\nBy the way, I have some great gift ideas for our favourite outgoing manager, including a nice looking, leather-made executive bag, a branded wristwatch and a metal desktop clock and finally, a pencil holder.\\nAnyway, that is all the suggestions I have for you now. Let me know what you think of them.\\nYours sincerely,\\nOscar Leo\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.63 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nMuneer Alam\\n4 years 6 months\\nDear Julia,\\nI am writing in response to your request asking suggestions about the farewell event you are planning for Mr James, who will be leaving us soon. I think we should organize a small party for the occasion, keeping his preferences in mind. We should also give him a nice souvenir.\\nI think this is a great idea that you are planning a special event to honour our retiring manager Mr James. As we all know he is a simple and down-to-earth person, I advise we arrange a small party in the office meeting hall. We need to keep it simplistic without any excessive lighting or loud music. Mr James is a nature-lover and it would be great if we decorate the place with lots of flowers and pot plants.\\nMr James has been an excellent manager and I am sure everyone loves him as much as I do. He has been very encouraging and supportive to his subordinates. He has always stood for our rights while getting the work done without doing any compromise with the quality. These traits make him an exceptional executive and every one of us will miss him once he is gone.\\nWe should also make some collection by making a small contribution on everyone''s part so that we could buy a nice gift for him. In my opinion, a decent executive wristwatch would be perfect for this occasion. Also, we should gift him a momento that he would love to keep with him.\\nGiven all the things Mr James has done for us over all these years, let us make this farewell event a memorable one for him as well as for us.\\nYours sincerely,\\nKhalid\\nReply\\nQuote\\nS K\\n5 years 3 months\\nThe manager at the company you work for is going to retire next month. The manager’s assistant has invited some suggestions about what kind of event they should do to say goodbye to him.\\nWrite a letter to your manager''s assistant. In your letter,\\n- say what kind of event you have in your mind\\n- mention why you liked him/her as a manager\\n- what kind of present can be given to your manager\\nWrite at least 150 words.\\nDear Mrs Marie,\\nI am writing this letter in response to your message that I received yesterday regarding the arrangement for our dear manager David Moore''s send-off party. Thank you for seeking my opinion on this matter.\\nI would like to suggest a rooftop party with buffet dinner at the White Fort Hotel since it''s really spacious, located at a convenient spot, can accommodate a large number of guests and offer some delicious menus. Also, it would be a great idea to give an elaborated speech from us about his life and career and the good things he has done for the company while some pictures and videos playing at the backdrop of the talk. You already know how enthusiastic I am about taking photographs so I can act as a photographer in this programme.\\nDavid Moore is an admiration not only for me but also for all our staffs. I''ve always adored him for his honesty,work-oriented skills and dedication to his work. I believe we can give him a collection of hardcover books as he an avid reader. I already know the types of books he would like.\\nYours sincerely,\\nSandra Nima\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
