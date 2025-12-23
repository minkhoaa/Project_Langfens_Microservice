-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:00.524412
-- Source: ielts-mentor.com
-- Title: You Have Invited Friend To Come On Holiday
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Invited Friend To Come On Holiday';

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
  E'You Have Invited Friend To Come On Holiday',
  E'You should spend about\n20\nminutes on this task.\nYou have invited a friend to come to your house next holiday. He/she has asked you how to get to your house from the airport. However, you are going to the airport to receive him/her.\nWrite a letter to your friend. In your letter:\nexplain that you will meet him/her at the airport\nsay what you have planned for your friend\nwrite some important things that he/she might find useful\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Annie,\\nI hope you are doing fine. I am excited to have you with me in a few days. Yesterday, I received your letter in which you have asked for the direction to my house from the airport. Please do not worry about that; I will come to the airport to pick you up. I am eagerly waiting to have you at my house and spend some excellent time together.\\nI am really looking forward to meeting you and I have planned a few things for us. We can go to Mysore for a day trip. Mysore has a beautiful palace and a Zoo; which is a house of some exotic animals. Then I have also planned a 3 days'' trip to Ooty. Ooty is known as \\"Queens of Hills\\" and has pristine tea gardens and mesmerising views. I am sure you will love it.\\nSince Ooty is a cold and hilly place, please get some winter clothing and comfortable shoes. One thick jacket and a sweater would be good. Besides, you should bring any medicine you take as you won''t be able to purchase any medicine without a prescription.\\nLooking forward to meeting you soon.\\nWith love,\\nPreeti\\n[ by - Preeti Ghuraiya]", "Dear Alison,\\nI am quite excited about your visit to my house during the coming summer holidays. If there is no change in your flight schedule, I take it that you will come to visit me on 18th August. I also understand that you want the direction to my house from the airport. But, I think that it would be better if I come to the airport and pick you up instead.\\nJust to let you know a little about my plans, I will take you to a nice restaurant for dinner, after your arrival, where we will enjoy Italian food. The next morning, we will hit the road to travel to the most popular sea beach in my country which you have always wanted to visit. We will also visit a theatre to enjoy a movie, go to the museum and try some local food.\\nAlso, please don’t forget to bring some clothes suitable for the summer season since summers in my country are really hot unlike the summer weather in your country. Also, bring your prescription if you want to buy any medicine from here.\\nTake care. Can''t wait to meet you.\\nWarm wishes,\\nAdam Spencer\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.93 (7 Votes)\\nIELTS Letter Writing\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
