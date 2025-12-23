-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:37.427521
-- Source: ielts-mentor.com
-- Title: You Want To Rent Out Small Apartment To A Family
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Want To Rent Out Small Apartment To A Family';

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
  E'You Want To Rent Out Small Apartment To A Family',
  E'You should spend about\n20\nminutes on this task.\nYou want to rent out a small apartment to a family, and you have decided to advertise it.\nWrite a letter to the editor of a local newspaper asking to advertise your ad on the front page of the newspaper. In your letter,\ngive details of the ad that you want to publish\nmention that you want the ad to be published on the front page\nsay how you would like to pay for the advertisement\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a resident of Longhorn city, and I thought that your local but very popular newspaper would be a great platform to publish my ad for renting my small apartment.\\nThis advertisement should include information like how many persons can stay in the apartment, what kind of amenities or services it offers to its tenants, and how long the initial lease should be. Apart from these, the advertisement should include my contact details so that prospective tenants can contact me.\\nSo, based on the information above, I want you to publish an advert for me in your newspaper, and I think that it should be a few lines long. But, regardless of how many lines or words should my advertisement contain, I want it to be published on the front page of your newspaper so that it gets a maximum number of views.\\nAnd as for the payment of the publishing cost of the ad, please send me an invoice, citing the amount of money to be paid, and I will immediately send a check to you. If you want, I could deposit the money into your bank account also.\\nI hope to hear from you soon.\\nYours faithfully,\\nPeter Lazarus\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.41 (23 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
