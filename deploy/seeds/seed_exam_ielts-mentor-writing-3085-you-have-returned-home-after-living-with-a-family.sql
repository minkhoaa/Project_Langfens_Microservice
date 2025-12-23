-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:50.723387
-- Source: ielts-mentor.com
-- Title: You Have Returned Home After Living With A Family
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Returned Home After Living With A Family';

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
  E'You Have Returned Home After Living With A Family',
  E'You should spend about\n20\nminutes on this task.\nYou have just returned home after living with a family in an English-speaking country for six months. You now realise that you left a small bag of personal possessions in your room.\nWrite to the family describing the things you left behind. Ask them to send those items to you. Offer to cover the cost.\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,\nSample Answer 1:\nDear Mrs Beth,\nI have safely reached home last Tuesday. I want to thank you for the warm hospitality and kindness that you and your family have rendered to me. It felt just like home living with all of you. As you are already aware that I was racing against time and rushing to catch my flight, I left a bag with my laptop, charger and some books in my room. I did not realize it at that time and it only occurred to me halfway through the flight.\nThese books and the laptop are utterly important for my research. Besides, all of my works are saved on my laptop. I will highly appreciate it if you can go through the trouble of sending me the bag with its contents through a courier. Kindly use the FedEx service as they are quick and reliable in my country.\nThe approximate weight of the bag will be around five kilograms, and I would like to bear the cost of the courier. Please provide me with your bank details as I will deposit the amount into your account in advance.\nI will be very grateful to you for this act of kindness. Thank you once again.\nYours Sincerely,\nFaisal Ahmed\n[Written by -\nFaisal\n]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mrs Beth,\\nI have safely reached home last Tuesday. I want to thank you for the warm hospitality and kindness that you and your family have rendered to me. It felt just like home living with all of you. As you are already aware that I was racing against time and rushing to catch my flight, I left a bag with my laptop, charger and some books in my room. I did not realize it at that time and it only occurred to me halfway through the flight.\\nThese books and the laptop are utterly important for my research. Besides, all of my works are saved on my laptop. I will highly appreciate it if you can go through the trouble of sending me the bag with its contents through a courier. Kindly use the FedEx service as they are quick and reliable in my country.\\nThe approximate weight of the bag will be around five kilograms, and I would like to bear the cost of the courier. Please provide me with your bank details as I will deposit the amount into your account in advance.\\nI will be very grateful to you for this act of kindness. Thank you once again.\\nYours Sincerely,\\nFaisal Ahmed\\n[", "Dear Mr and Mrs Griffin,\\nHope this letter finds you in good health and spirit. You will be glad to know that I have arrived home safely, but please also know that you will always be in my thoughts and prayer for the kindness and great hospitality you have shown to me during my stay at your home.\\nAnyway, if it is not too much of a trouble for you, I would like to ask for a favour from you, and which is to return a small bag of mine which I have accidentally left at your home before leaving Australia. This small bag is really important for me since it contains some valuable possessions, such as some important documents, a couple of gift items which you bought for me, a few beautiful souvenirs, and some beautiful pictures of my visits to different parts of Australia.\\nPlease look for this bag on the top shelf of the wardrobe in the room, where I used to sleep and send it to me in a courier mail. I will send a money order to you to cover the courier cost as soon as I receive the bag.\\nYours sincerely,\\nNitesh Chauhan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.83 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
