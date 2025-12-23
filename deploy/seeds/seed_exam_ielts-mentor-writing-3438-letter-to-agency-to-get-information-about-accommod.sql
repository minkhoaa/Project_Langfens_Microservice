-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:22.405807
-- Source: ielts-mentor.com
-- Title: Letter To Agency To Get Information About Accommodation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Agency To Get Information About Accommodation';

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
  E'Letter To Agency To Get Information About Accommodation',
  E'You should spend about\n20\nminutes on this task.\nYou will go to a foreign country to stay there for one year, and you need a place to live in. You have decided to write to an agency for accommodation.\nWrite a letter to the agency to get information about accommodation.\nIn your letter, say:\nwhy you are going to this country\nwhat kind of accommodation you want\nwhen you will arrive\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to get some details about accommodation in Sydney that your agency can arrange for me.\\nI have been accepted at Macquarie University in a research-based Master''s degree programme, and I will start my classes next June. I will stay there for one year and my wife will accompany me during my stay there. Therefore, I need a separate accommodation, not the one the university has offered me in its residence hall.\\nI am looking for a studio apartment that will not cost me more than $1500 per month and is located within the walking distance of the university. It would be ideal if the apartment comes with a fully equipped kitchen and fully furnished rooms with windows that allow natural light and fresh air. It would be a bonus if we can access shopping malls, markets, a park and other public amenities without travelling a long distance.\\nI will fly to Sydney on 29th May and would highly appreciate it if you can send me details of several accommodations - the kind I am looking for, within the budget.\\nI am hoping to hear from you soon regarding this.\\nYours faithfully,\\nAvinash Kumar\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.50 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nRequesting-information-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nJatinder\\n5 years 8 months\\nDear Sir or Madam,\\nI am Anita Kapoor, writing this letter to request you to find suitable accommodation for my family and me.\\nWe have recently got a Canadian Holiday Work Visa. So we are coming over there a few months later. I have been selected for a software developer position in the Dell International, which is located in Toronto, Downtown. It is a one-year contractual job, and for my children and me, it''s an excellent opportunity to learn about foreign culture.\\nSo, I am looking for a two-bedroom apartment, which would cost not more than $1600 per month, and should be close to the subway station so that I can easily commute to and from my office. Additionally, there should be a school within walking distance from the apartment. Thus, I will be able to quickly drop and pick my children. Besides, the kitchen should be equipped with necessary facilities such as a refrigerator, microwave oven, stove and window attached to it.\\nWe will be arriving in Canada on the 23rd of March 2022. So, I want to finalize everything before that speculated date. I am hoping that your agency will arrange a suitable apartment for us to live in during our stay.\\nI am hoping to hear from you soon.\\nYours faithfully,\\nAnita Kapoor\\nReply\\nQuote\\nSachin\\n4 years 8 months\\nYou have written a letter in a very easy way, and from point to point.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
