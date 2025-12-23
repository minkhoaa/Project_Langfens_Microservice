-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:43.477114
-- Source: ielts-mentor.com
-- Title: Your New Neighbours Have Recently Invited You To Party
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your New Neighbours Have Recently Invited You To Party';

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
  E'Your New Neighbours Have Recently Invited You To Party',
  E'You should spend about\n20\nminutes on this task.\nYour new neighbours have recently invited you to a party they are holding next Saturday. However, you have other plans on Saturday evening and cannot attend the party.\nWrite a letter to your neighbours. In your letter:\nthank them for the invitation\nmention what plans you already have\nsuggest when you can meet them\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Mr and Mrs ...............\n,\nSample Answer 1:\nDear Mr and Mrs Arthur,\nI would like to thank you for inviting us to the party you are holding at your home next Saturday. We are honoured to be invited. However, a prescheduled plan deters us from attending this much-welcomed party, and I am hoping that we can meet some other day.\nWe will have to be at the local airport to receive our uncle and his family on that very Saturday evening. They are travelling from Italy to meet us, and they are expected to land at the airport at 7.30 pm. We have assured them that we will be at the airport, and I am afraid we can not change the schedule. They will be visiting Canada for the first time and expecting us to escort them to our house.\nI wish we could have been at your home to enjoy the party and get to know some of your relatives. Hopefully, we will do that some other time. We can meet you on a weekend and have some quality time together. Please let me know when you can do that.\nWishing you a grand party and quality time with your guests.\nSincerely yours,\nMartin Cammy',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr and Mrs Arthur,\\nI would like to thank you for inviting us to the party you are holding at your home next Saturday. We are honoured to be invited. However, a prescheduled plan deters us from attending this much-welcomed party, and I am hoping that we can meet some other day.\\nWe will have to be at the local airport to receive our uncle and his family on that very Saturday evening. They are travelling from Italy to meet us, and they are expected to land at the airport at 7.30 pm. We have assured them that we will be at the airport, and I am afraid we can not change the schedule. They will be visiting Canada for the first time and expecting us to escort them to our house.\\nI wish we could have been at your home to enjoy the party and get to know some of your relatives. Hopefully, we will do that some other time. We can meet you on a weekend and have some quality time together. Please let me know when you can do that.\\nWishing you a grand party and quality time with your guests.\\nSincerely yours,\\nMartin Cammy", "Dear Mr and Mrs Nicholas,\\nI hope both of you are in good health and spirit, and I would like to take this opportunity to welcome you to our neighbourhood. I am also so glad and thankful to you because you have taken the trouble to extend me an invitation to join your party which you are planning to hold on next Saturday evening.\\nHowever, as much as I like the idea of attending your party, it looks like I will not be able to do so because I have some other plans for that evening. In fact, I will have to take my grandfather to the doctor that evening. Later on that evening, after visiting my grandfather’s doctor, I would also need to go and see off my nephew at the airport. So, this Saturday evening is going to be very busy for me, and I am sorry that I can not make it to your party on the same evening.\\nI would, however, be more than happy to meet you and greet you in person the next day at around 6:00 pm if you are free at that time. All you need to do is just let me know whether you can meet me then. Also, I can come over to your place or you can come to my house if you like.\\nYours sincerely,\\nGeorge Tobias\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
