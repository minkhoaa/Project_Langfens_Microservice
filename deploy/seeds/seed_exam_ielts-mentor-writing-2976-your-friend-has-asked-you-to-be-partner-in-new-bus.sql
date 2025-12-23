-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:09.373898
-- Source: ielts-mentor.com
-- Title: Your Friend Has Asked You To Be Partner In New Business
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Friend Has Asked You To Be Partner In New Business';

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
  E'Your Friend Has Asked You To Be Partner In New Business',
  E'You should spend about\n20\nminutes on this task.\nOne of your friends has asked you to be a partner in his/her new business.\nWrite a letter to reply to your friend''s offer. In your letter,\ngive your opinion of your friend''s business idea\ntell him/her whether or not you have decided to accept the offer\nand explain your reasons for this decision\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,\nSample\nAnswer 1:\nDear Smith,\nIt is a pleasure to be in touch with you after a long. I hope you are doing well. I am so excited to hear that you are finally pursuing a dream you have had for a long - owing and running your own business. My best wishes will always be with you.\nYour idea to start a motorbike showroom in Ghansoli is quite excellent and timely. This area does not have such showrooms and I have seen many people travelling 30 to 40 km to buy a motorcycle. They also visit the nearby town to get motorbike parts. Your business will tap into this market and I am quite positive would be a success.\nI believe opening a motorcycle showroom in Ghansoli is a very good idea and you can expect good returns on investment. Thanks for asking me to join you as a partner, but I am afraid I have to decline. I have my reason for this decision, and I have taken adequate time to determine it. I will be staying in Canada for a year to manage a sales team. This is a good career opportunity, and I cannot leave it as it is a one-time offer. Moreover, all the arrangements have already been made and cancelling it would hurt my career progress.\nI wish you good luck with your new venture and look forward to meeting you soon.\nWarm regards,\nHolmes\n[Written by -\nThiru\n]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Joseph,\\nHope you are doing excellent. I am sorry that I couldn’t write back to you early enough to let you know about my opinion on becoming a business partner of yours.\\nI know that you are really excited about your new business idea of supplying all kinds of raw meats in the stores of different cities, but after giving a lot of consideration to this new business idea of yours, I think that it is going to be a little riskier than what you would actually like to believe. Then, every business is more or less risky. Since raw meat is a perishable item, and as such, you need to be extra cautious about delivering these raw meats to the stores on time.\\nI am already running my gift shop and I don''t have enough money to invest in another business right now. So I don’t think that I can be your business partner at this time. But, I certainly thank you for your kind offer.\\nWishing you all the best.\\nWarm wishes,\\nFreddie\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.78 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
