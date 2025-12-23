-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:55.130819
-- Source: ielts-mentor.com
-- Title: You Spent Weekend At Hotel In London And Left Bag
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Spent Weekend At Hotel In London And Left Bag';

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
  E'You Spent Weekend At Hotel In London And Left Bag',
  E'You should spend about\n20\nminutes on this task.\nYou have just spent a weekend staying at a Hotel in London. When you get home you find that you have left a bag at the hotel.\nWrite to the hotel manager.\nIn your letter,\nintroduce yourself\ndescribe the bag and its content that you left there\nexplain what you want the manager to do about it\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nI have recently stayed at your London Hilton hotel on Park Lane and regrettably left my bag in the room I stayed in. I am writing to seek your assistance and help regarding this and I would really appreciate it if you could courier it to my home address soon.\nI am Hubert Raymond, a senior executive at the Global management consulting firm McKinsey and had been to London for a business matter. I stayed at your hotel on 20th and 21st September in room 310. After I returned home to Cardiff, on 21st September, I realised that I missed a bag at your hotel.\nThe bag was probably placed in the cabinet beside the bed. It is a medium-size, leather made brown bag that has a large zipper on the top. It has two side pockets and the main zipper was locked. It contains a few dresses of mine, a diary, two fountain pens, a calculator, a PDA and a few important business documents. I really need my PDA and the documents for an upcoming presentation at my office.\nI would highly appreciate your cooperation in sending the bag to my home address which is stated at the top of the letter. I would bear the courier cost. Please use the ''Same Day Emergency Delivery'' service of DHL.\nThank you in advance for your kind cooperation.\nYours faithfully,\nHubert Raymond',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI have recently stayed at your London Hilton hotel on Park Lane and regrettably left my bag in the room I stayed in. I am writing to seek your assistance and help regarding this and I would really appreciate it if you could courier it to my home address soon.\\nI am Hubert Raymond, a senior executive at the Global management consulting firm McKinsey and had been to London for a business matter. I stayed at your hotel on 20th and 21st September in room 310. After I returned home to Cardiff, on 21st September, I realised that I missed a bag at your hotel.\\nThe bag was probably placed in the cabinet beside the bed. It is a medium-size, leather made brown bag that has a large zipper on the top. It has two side pockets and the main zipper was locked. It contains a few dresses of mine, a diary, two fountain pens, a calculator, a PDA and a few important business documents. I really need my PDA and the documents for an upcoming presentation at my office.\\nI would highly appreciate your cooperation in sending the bag to my home address which is stated at the top of the letter. I would bear the courier cost. Please use the ''Same Day Emergency Delivery'' service of DHL.\\nThank you in advance for your kind cooperation.\\nYours faithfully,\\nHubert Raymond", "Dear Sir or Madam,\\nI am writing to inform you that I may have left my duffel bag at your hotel before leaving the place. I am hoping that you would arrange to send the bag to my address.\\nTo give you some information about me, my name is Howard Jackson, and I stayed at your hotel from 12th to 14th March. I stayed in room 325 on the second floor. Not sure how I forgot to pick up that bag before leaving for the airport, but by the time I realized that I did not have my duffel bag with me, I was very much on my way to Melbourne. I guess that I have left it just below the bed.\\nAbout the bag that I have left, it is a white travel bag, with two blue straps around it, and it has only a single belt to hold and carry. It is not a big bag either, and it mostly contains some important personal stuff, like an expensive hair trimmer (given to me as a gift), a Samsung smartphone and some rare pictures of my nephews and nieces.\\nSo, please mail that bag to me as soon as you find it.\\nYours faithfully,\\nHoward Jackson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.88 (4 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nVictor\\n7 years 8 months\\nDear Sir or Madam,My name is Victor and I stayed at your hotel for four days, from 21/03/2018 to 25/03/2018, and checked out from your hotel at 11:00 AM on 25th March 2018. I am writing this letter to inform you that at the time of checking out, I was in hurry and I forgot my bag in the room 324. The bag I left is a medium-sized black colour bag with telescopic white colour handle. You can find my name Victor inscribed on it. The brand of the bag is Tommy Hilfiger. There is a zipped pocket on the front which has the brand logo and inside you can find my business card. The back pocket has some important documents along with personal stuff like a watch, wallet - a gift for my brother.If you find my bag, please keep it safe with you. I will come and collect it from you in a week during my next visit to your hotel.Yours Sincerely,Victo r\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
