-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:46.129589
-- Source: ielts-mentor.com
-- Title: Email To Company You Bought The Clothing From
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Email To Company You Bought The Clothing From';

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
  E'Email To Company You Bought The Clothing From',
  E'You should spend about\n20\nminutes on this task.\nYou have bought some clothing online and are not satisfied with your purchase.\nWrite an email to the company that you bought the clothing from. In your email,\ngive details of the purchase\ndescribe the problem\nexplain why you need a replacement urgently\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your email as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nLast week I bought some t-shirts and trousers from your online store, but I just do not think that I am fully satisfied with the purchase I made. The purchase included four t-shirts and three pairs of trousers which I was planning to use later as my summer outfits. I used my credit card to pay for those clothing items, and the online receipt number is GA- 5487.\\nTwo of the t-shirts were supposed to be of a round-neck collar while the other two were supposed to have a regular collar. But, when they arrived, I found all of those t-shirts to have round-neck collars. Not only that but also they were not in the colours that I chose when ordering them.  In fact, I wanted two of them to be of light navy blue colour and the remaining two black, but they all came out to be regular blue, instead. As for the trousers, two of them seem to be smaller sizes than what I actually ordered.\\nSo, please replace them at your earliest convenience because I do not really have any decent summer dresses to use this coming summer. If I do not hear from you within the next seven days, I would be forced to lodge a complaint to the \\"Consumer Rights Commission\\" office.\\nThank you in advance.\\nYours faithfully,\\nAmal Buksha", "Dear Sir or Madam,\\nI purchased an M-size blue woollen sweater from your online store (Order # E1208750) on February 20th. The item was delivered to me on February 24th, but unfortunately, I am not satisfied with the product that was delivered to me. I am hoping that you will replace the product urgently.\\nThe issue with the sweater is that it is a different colour and size from what I ordered. Instead of the blue medium-sized sweater, I received a black sweater in size L. Since I specifically ordered a blue medium-size sweater, that must be a mistake made by one of your staff.  I ordered the sweater for an upcoming event next week, so, I urgently require a replacement.\\nI kindly request that you arrange for the correct item to be sent to me as soon as possible. Please let me know how to proceed with returning the incorrect item.\\nI appreciate your prompt attention to this matter. Looking forward to your response.\\nYours faithfully,\\nAmelie Tennyson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.68 (14 Votes)\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nemail writing\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
