-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:43.967098
-- Source: ielts-mentor.com
-- Title: You Bought Mobile Phone And It Was Faulty
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Bought Mobile Phone And It Was Faulty';

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
  E'You Bought Mobile Phone And It Was Faulty',
  E'You should spend about\n20\nminutes on this task.\nYou have just bought a new mobile phone from a website on the internet. When it was delivered, the phone was faulty.\nWrite a letter to the company.\nIn the letter:\nintroduce yourself\nexplain the situation\nstate what action you want to be taken\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Wesley Phillip from Boston, USA, writing to inform you that, three days ago, I ordered a Samsung Galaxy A23 smartphone from your online store. I was excited when it arrived earlier today but very disappointed to find that the product was faulty and not the one I ordered! I am hoping you will replace it immediately.\\nIn relation to the specifics of the order, I purchased this mobile phone through your website called Phone and Gadgets on July 17th using my PayPal account. The order number is 56900145, and I am attaching a copy of my receipt.\\nThe issue with the phone is that the front camera does not work, and the internal memory is 64 GB, though I ordered a 128 GB phone. The description of the item on your website clearly shows it is a 128 GB phone, so I am sure this is a mistake made on your side while dispatching the product.\\nAs a solution, and because I really like this specific model, I am hoping that you will agree to replace the phone according to the specification of the order. Otherwise, I would like a full refund and I will be contacting PayPal complaints if I do not hear back from you in regards to this within a week.\\nThank you for giving the matter your attention and I hope to hear your reply soon.\\nYours faithfully,\\nWesley Phillip", "Dear Sir or Madam,\\nI have recently purchased an iPhone (14 Plus, 4 GB/128 GB, black colour) from your online store, and to my utmost disappointment, when I unwrapped the packet, I found a faulty phone instead of a fresh and new one. I am hoping that you would replace it soon.\\nI am Sarah Liam, a resident of Edmonton, Alberta, and I placed the order on 14th January 2023 from your e-commerce website. The order number is STR-4546514, and I paid with my VISA credit card. The next day when the parcel reached my home, I stripped the package only to notice that I was delivered a defective phone.\\nFirst of all, the phone screen has some visible scratch marks, which is unlikely. The internal memory of the phone is 64 GB, though I ordered a 128 GB phone! This must have been an oversight from your delivery department. The phone hung after a few minutes only to deepen my disappointment.\\nI have not paid for a faulty or refurbished phone and would like to hear why I was delivered a flawed product in the first place. Moreover, I expect someone from your company replaces my phone at my location so that I do not have to travel to your office.\\nI am attaching a copy of my order confirmation email and receipt with this letter for your kind consideration.\\nYours faithfully,\\nSarah Liam\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.00 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
