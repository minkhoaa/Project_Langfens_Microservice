-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:56.292365
-- Source: ielts-mentor.com
-- Title: You Bought New Hd Television Last Week
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Bought New Hd Television Last Week';

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
  E'You Bought New Hd Television Last Week',
  E'You should spend about\n20\nminutes on this task.\nYou bought a new HD television last week. At first, it seemed to work perfectly but after a few hours a line appeared across the TV and the sound seemed a little strange. You cannot take the TV back to the shop so you have decided to write to them.\nWrite a letter of complaint to the shop. In your letter,\ngive them the background information\ndescribe the problem\nask them to resolve the issue\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Mr Bruce,\nThree days ago I purchased an LG smart television from your store. I was excited when I bought it from your store but very disappointed to find that only after a few hours, the product malfunctioned. I am sure it was poorly produced and I am hoping you would send someone to my house to check it and then replace it.\nIn relation to the specifics of the order, I purchased a 54-inch LG smart HD TV from your brand shop located in the Tandridge District on August 14th using my Visa credit card. The order number is 5874210 and I am attaching a copy of my receipt.\nThe issue with the TV is that a black line appears across the TV screen. Though it disappears after a while, it emerges again if the TV is on for a couple of hours. Moreover, the sound quality is strange and it has nothing to do with the audio settings. The TV is now unusable and I’m sure this is a manufacturing flaw.\nAs a solution, and because I really like the functionality of this television, I am hoping that you will agree to send someone to my house to check it and then replace it with a new one. Otherwise, I would like a full refund.\nThank you for giving the matter your attention and I hope to hear your reply soon.\nYours faithfully,\nIsabella Evelyn',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Bruce,\\nThree days ago I purchased an LG smart television from your store. I was excited when I bought it from your store but very disappointed to find that only after a few hours, the product malfunctioned. I am sure it was poorly produced and I am hoping you would send someone to my house to check it and then replace it.\\nIn relation to the specifics of the order, I purchased a 54-inch LG smart HD TV from your brand shop located in the Tandridge District on August 14th using my Visa credit card. The order number is 5874210 and I am attaching a copy of my receipt.\\nThe issue with the TV is that a black line appears across the TV screen. Though it disappears after a while, it emerges again if the TV is on for a couple of hours. Moreover, the sound quality is strange and it has nothing to do with the audio settings. The TV is now unusable and I’m sure this is a manufacturing flaw.\\nAs a solution, and because I really like the functionality of this television, I am hoping that you will agree to send someone to my house to check it and then replace it with a new one. Otherwise, I would like a full refund.\\nThank you for giving the matter your attention and I hope to hear your reply soon.\\nYours faithfully,\\nIsabella Evelyn", "Dear Sir or Madam,\\nI am writing to notify you of the problem I am having with the television that I purchased from your store on 29th March 2020. It was just fine when I checked it in the store but it started acting strangely and I am hoping you would send someone to check it.\\nI bought a 48 inch Samsung HD Flat FH4003 TV from your showroom in Author Street, Leevart area, on 29th March 2020. The TV worked fine for the first few hours and then suddenly started erratic behaviours! I cannot bring it to your store to claim my warranty because my car is in the repairing shop and I have an important exam next week. A thin dark line appears on the screen and it goes away after a while. This happens every time I start the TV. The sound of the TV was superb at the beginning but it sounds strange now. People''s voice has become robotic and I am sure it is not related to sound settings.\\nIt is quite disappointing to have a faulty product, especially from a reputed brand. I would request you to send someone to my place and have the television checked. Afterwards, please provide me with a new one of the same model and make sure this one has no issue!\\nYours faithfully,\\nDavid Crown\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.60 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
