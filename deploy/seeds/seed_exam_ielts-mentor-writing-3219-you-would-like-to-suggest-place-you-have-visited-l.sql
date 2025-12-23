-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:35.080366
-- Source: ielts-mentor.com
-- Title: You Would Like To Suggest Place You Have Visited Lately
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Would Like To Suggest Place You Have Visited Lately';

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
  E'You Would Like To Suggest Place You Have Visited Lately',
  E'You should spend about\n20\nminutes on this task.\nYou have an extended family and every year you all get together to go on a family trip for a week. Your uncle is in charge of the plans this year and you would like to suggest a place you have visited lately.\nWrite a letter to your uncle.\nIn your letter:\nsuggest the place you have visited\ndescribe your experience about this place\nmention what you could do there\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Wallner,\\nHope you and aunt Alecia are doing great. It was a piece of delightful news that we will soon have a family trip together and you are in charge to finalise the arrangements. I am so excited about the upcoming holiday and looking forward to spending some great time with all of you.\\nI have lately been to Vienna, the capital city of Austria, and had a great experience. I think this would be a wonderful destination for us to enjoy our holiday together. Viena is regarded as the City of Music because of its musical legacy. The historic centre of Vienna is rich in architectural ensembles, grand buildings, monuments and parks. Plenty of spectacular culture and interesting places are within easy reach in this city, and I wish to be there again and witness a city revered by all.\\nWe can enjoy the music film festival on City Hall Square, stroll and taste food in magical surroundings, visit the Schönbrunn Zoo, the oldest zoo in the world, take a tour to the Ringstrasse by tram, do some shopping and be in a city which is considered one of the best livable cities in the world. I had been there only for a couple of days and my experience was fabulous.\\nI am quite positive all of us will enjoy our time in this city during our trip. I would like to know your thoughts about it.\\nTake care and stay fine. See you soon.\\nYours truly,\\nPowell", "Dear Uncle Seth,\\nHope all is well at your end. I know that you are thinking and planning hard to visit a great place for our next family trip, and I have a suggestion for you.  In fact, I am going to recommend a place which I have visited lately.\\nThe name of this place is “Cyprus”.  Cyprus is known as the \\"Jewel of the Mediterranean\\" and the birthplace of Aphrodite, the ancient goddess of love and beauty. I think I would never forget my experience of visiting this place because people are just so friendly there.\\nBesides, the cost there is relatively cheaper than in many other European countries.  However, the best thing to do in Cyprus is to enjoy its incredible weather. The summer is warm and dry, and perfect for enjoying the island''s many beaches. Even in winter, you''ll find the weather warm, compared to most parts of Europe. Besides, Cyprus has one of the oldest histories dating as far back as 1100 BC which once hosted successive superpowers including Assyrians, Egyptians, Persians and Romans.  All in all, it is a great place to visit.\\nI believe we will enjoy our time there.\\nYours sincerely,\\nJohn\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (13 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nMini\\n6 years 3 months\\nDear Jonh,\\nHow are you? It''s been a long time since we have interacted with each other for the last time. I was extremely busy with my exams and other priorities. However, now I''m free for a couple of days.\\nI came to know from Sita that you are in charge of organizing the family get-together. I''m eagerly waiting to greet you all. I would like to suggest a place i.e. Haridwar, a pilgrimage of Uttrakhand that I visited lately with my friends.\\nIt''s a picturesque city with hordes of tourists. Apart from the river Ganga, it has a beautiful view of itself. Lots of fun activities are organised throughout the day there. The evenings and early morning in the city are very memorable. We can enjoy our visits to temples and the scenic beauty of the city. In the evening, we can enjoy a different variety of street foods along with shopping the souvenirs.\\nHope to hear a positive reply from your side about this place.\\nLooking forward to meeting you all.\\nYours truly,\\nChandra\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
