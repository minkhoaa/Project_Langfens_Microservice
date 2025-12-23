-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:03.421371
-- Source: ielts-mentor.com
-- Title: You Are Having Graduation Party Next Saturday
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Having Graduation Party Next Saturday';

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
  E'You Are Having Graduation Party Next Saturday',
  E'You should spend about\n20\nminutes on this task.\nYou are having a graduation party next Saturday night. You have invited 50 people to celebrate at an outdoor barbecue evening, which may continue till late night.\nWrite a letter to your elderly neighbour. In your letter:\nexplain what will be happening\noffer your apologies in advance\ninvite him/her to visit your house someday\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any address.\nBegin your letter as follows:\nDear Mr / Ms ..................,\nSample Answer 1:\nDear Ms Kelly,\nI am your next-door neighbour James and writing to inform you that I have recently graduated from the Bradford Union School. To celebrate this special event, I and my family have invited a few guests to a house party on Saturday night. I am afraid this will last till late at night and the noise might disturb you. My sincere apology for that in advance.\nThe graduation party will begin at around 8.00 pm on Saturday and we are expecting approximately 50 guests. We have arranged for an outdoor party, mainly a barbecue party and a music gala, and the guests are mainly my friends and relatives. We have arranged an outdoor stage where a few people would talk and two of my friends would sing. My friends would be cheering up and have loud conversations during the party and I am afraid the music might disrupt your sleep.\nPlease accept my sincere apology in advance for the commotion from the party and the gathering. I hope you would be kind enough to endure this disturbance considering how special this event is for me.\nPlease do visit us someday at your convenience over dinner so that we can have a pleasant conversation. I really enjoyed our last discussion and would love to talk to you again.\nYours sincerely,\nJames Grant',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Ms Kelly,\\nI am your next-door neighbour James and writing to inform you that I have recently graduated from the Bradford Union School. To celebrate this special event, I and my family have invited a few guests to a house party on Saturday night. I am afraid this will last till late at night and the noise might disturb you. My sincere apology for that in advance.\\nThe graduation party will begin at around 8.00 pm on Saturday and we are expecting approximately 50 guests. We have arranged for an outdoor party, mainly a barbecue party and a music gala, and the guests are mainly my friends and relatives. We have arranged an outdoor stage where a few people would talk and two of my friends would sing. My friends would be cheering up and have loud conversations during the party and I am afraid the music might disrupt your sleep.\\nPlease accept my sincere apology in advance for the commotion from the party and the gathering. I hope you would be kind enough to endure this disturbance considering how special this event is for me.\\nPlease do visit us someday at your convenience over dinner so that we can have a pleasant conversation. I really enjoyed our last discussion and would love to talk to you again.\\nYours sincerely,\\nJames Grant", "Dear Ms Courtney,\\nHope that you and your family are doing well by the grace of Almighty. I am one of your good neighbours, and I am writing this letter to inform you about a graduation party, which I am planning to hold, the next Saturday night.\\nI fully understand that the party might cause you some inconvenience since I have invited about 50 people to enjoy an outdoor barbeque evening, which might create some noise. Besides, the party may continue till late at night where a few of my friends might even venture to sing along with their guitars while enjoying the night. Of course, we will try to keep the noise and sound as low as we can, but in case if it does trouble you, I would like to apologize to you in advance.\\nBut, on the other hand, instead of just sitting at your home, you could also join our party because if you do, I can certainly guarantee you that we will do everything to make sure that you enjoy our party. In fact, we would feel honoured if you join our party.\\nYours sincerely,\\nAaron Johnson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.92 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nIELTS Apology Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nLucas Varghese Thomas\\n8 years 2 months\\nDear Mr Andrews,Good Evening! My name is Lucas and I am your next door neighbour. I am holding a graduation party next Saturday at 8 pm as I have recently graduated from the college. I have made all preparation and going to invite around 50 guests to participate on this occasion. This is basically a barbecue feast that will continue until midnight. Most of the guests are my friends and classmates from the college. I would appreciate if you could allow me to organize this. I assume there would be music and loud chats and I humbly apologize in advance for this. I wanted to invite you personally to my graduation party but since you have visitors coming I wanted to apologize for this inconvenience. I would like to make up to you by inviting you for a small get together this Wednesday when my family is coming to meet me. So kindly accept my invitation and join me this week.I am anxiously looking forward to your reply.Regards,Lucas Varghese Thomas\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
